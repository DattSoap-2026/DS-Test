import 'package:isar/isar.dart';
import '../local/entities/production_entry_entity.dart';
import '../local/base_entity.dart';
import '../../services/database_service.dart';
import '../../services/production_service.dart';
import '../../services/inventory_service.dart';
import '../../core/firebase/firebase_config.dart';
import 'dart:developer' as developer;

/// Repository for Production Daily Entries
/// ONLINE-FIRST with automatic local caching
class ProductionRepository {
  final DatabaseService _dbService;
  final ProductionService _productionService;

  ProductionRepository(
    this._dbService,
    FirebaseServices firebase,
    InventoryService inventoryService,
  ) : _productionService = ProductionService(
        firebase,
        inventoryService,
        _dbService,
      );

  // ===== WRITE OPERATIONS (Online-First) =====

  /// Save production entry to Firebase, then auto-cache locally
  /// Returns the entry ID on success, null on failure
  /// Save production entry to Local Isar first, then attempt background sync.
  /// Returns the entry ID on success (local persistence), null on failure.
  Future<String?> saveProductionEntry({
    required DateTime date,
    required String departmentCode,
    required String departmentName,
    required List<ProductionItemEntity> items,
    required String createdBy,
    required String createdByName,
    String? teamCode,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final entryId =
          '${departmentCode}_${date.toIso8601String().split('T')[0]}';

      // 1. Create Entity (Pending Sync)
      final entity = ProductionDailyEntryEntity()
        ..id = entryId
        ..date = date
        ..departmentCode = departmentCode
        ..departmentName = departmentName
        ..teamCode = teamCode
        ..items = items
        ..createdBy = createdBy
        ..createdByName = createdByName
        ..createdAt = now
        ..updatedAt = now
        ..notes = notes
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;

      // 2. Save to Local Storage (Isar)
      await _dbService.db.writeTxn(() async {
        await _dbService.productionEntries.put(entity);
      });
      developer.log(
        'Production entry locally saved: $entryId',
        name: 'ProdRepo',
      );

      // 3. Attempt Immediate Sync (Best Effort)
      _tryImmediateSync(entity);

      return entryId;
    } catch (e) {
      developer.log(
        'Failed to save Production entry locally: $e',
        name: 'ProdRepo',
      );
      return null;
    }
  }

  /// Helper to attempt immediate sync without blocking UI return
  Future<void> _tryImmediateSync(ProductionDailyEntryEntity entity) async {
    try {
      final firebaseData = entity.toFirebaseJson();
      await _productionService.saveDailyEntry(firebaseData);

      // If successful, mark as synced locally
      await _dbService.db.writeTxn(() async {
        entity.syncStatus = SyncStatus.synced;
        await _dbService.productionEntries.put(entity);
      });
      developer.log(
        'Production entry immediately synced: ${entity.id}',
        name: 'ProdRepo',
      );
    } catch (e) {
      developer.log(
        'Immediate sync failed (offline?): $e',
        name: 'ProdRepo',
      );
      // Entity remains SyncStatus.pending for SyncManager to pick up later
    }
  }

  // ===== READ OPERATIONS (Cache-First, Local Only) =====

  /// Get production entries by date range (local only)
  Future<List<ProductionDailyEntryEntity>> getProductionEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? departmentCode,
  }) async {
    try {
      final db = _dbService.db;

      var query = db.productionDailyEntryEntitys
          .filter()
          .dateBetween(startDate, endDate, includeUpper: true)
          .isDeletedEqualTo(false);

      if (departmentCode != null) {
        query = query.departmentCodeEqualTo(departmentCode);
      }

      final results = await query.sortByDateDesc().findAll();
      developer.log(
        'Loaded ${results.length} production entries from cache',
      );
      return results;
    } catch (e) {
      developer.log('Failed to read production entries: $e');
      return [];
    }
  }

  /// Get latest production entry for a specific department (local only)
  Future<ProductionDailyEntryEntity?> getLatestProductionEntry(
    String departmentCode,
  ) async {
    try {
      final db = _dbService.db;

      final result = await db.productionDailyEntryEntitys
          .filter()
          .departmentCodeEqualTo(departmentCode)
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .findFirst();

      return result;
    } catch (e) {
      developer.log('Failed to read latest production entry: $e');
      return null;
    }
  }

  /// Get production entry by date (local only)
  Future<ProductionDailyEntryEntity?> getProductionEntryByDate({
    required DateTime date,
    required String departmentCode,
  }) async {
    try {
      final db = _dbService.db;

      final result = await db.productionDailyEntryEntitys
          .filter()
          .departmentCodeEqualTo(departmentCode)
          .dateEqualTo(date)
          .isDeletedEqualTo(false)
          .findFirst();

      return result;
    } catch (e) {
      developer.log('Failed to read production entry: $e');
      return null;
    }
  }

  // ===== AUTO-FETCH OPERATIONS =====

  /// Fetch production entries from Firebase and cache locally
  /// Used for background sync and initial data loading
  Future<void> fetchAndCacheProductionEntries({
    required DateTime startDate,
    required DateTime endDate,
    String? departmentCode,
  }) async {
    try {
      // Fetch from Firebase
      final firebaseEntries = await _productionService.getDailyEntries(
        startDate: startDate,
        endDate: endDate,
        departmentCode: departmentCode,
      );

      if (firebaseEntries.isEmpty) {
        developer.log(' No production entries to cache');
        return;
      }

      // Convert to entities
      final entities = firebaseEntries
          .map((json) => ProductionDailyEntryEntity.fromFirebaseJson(json))
          .toList();

      // Cache locally
      await _dbService.db.writeTxn(() async {
        await _dbService.productionEntries.putAll(entities);
      });

      developer.log('Cached ${entities.length} production entries');
    } catch (e) {
      developer.log('Failed to fetch production entries: $e');
      // Don't throw - offline is acceptable
    }
  }
}

