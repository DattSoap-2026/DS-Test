import 'dart:convert';

import 'package:isar/isar.dart';
import '../local/base_entity.dart';
import '../local/entities/dealer_entity.dart';
import '../local/entities/sync_queue_entity.dart';
import '../../services/database_service.dart';

class DealerRepository {
  final DatabaseService _dbService;
  static const String _collectionName = 'dealers';

  DealerRepository(this._dbService);

  String _queueId(String recordId) => 'outbox_${_collectionName}_$recordId';

  Map<String, dynamic> _buildOutboxPayload(DealerEntity dealer) {
    return {
      'id': dealer.id,
      'name': dealer.name,
      'contactPerson': dealer.contactPerson,
      'mobile': dealer.mobile,
      'contactNumber': dealer.mobile,
      'alternateMobile': dealer.alternateMobile,
      'email': dealer.email,
      'address': dealer.address,
      'addressLine2': dealer.addressLine2,
      'city': dealer.city,
      'state': dealer.state,
      'pincode': dealer.pincode,
      'gstin': dealer.gstin,
      'pan': dealer.pan,
      'status': dealer.status,
      'commissionPercentage': dealer.commissionPercentage,
      'paymentTerms': dealer.paymentTerms,
      'territory': dealer.territory,
      'assignedRouteId': dealer.assignedRouteId,
      'assignedRouteName': dealer.assignedRouteName,
      'latitude': dealer.latitude,
      'longitude': dealer.longitude,
      'createdAt': dealer.createdAt,
      'isDeleted': dealer.isDeleted,
      'updatedAt': dealer.updatedAt.toIso8601String(),
    };
  }

  Future<void> _upsertOutboxInTxn(
    DealerEntity dealer, {
    required String action,
  }) async {
    _ensureCreatedAt(dealer, DateTime.now());
    final queueId = _queueId(dealer.id);
    final existing = await _dbService.syncQueue.getById(queueId);
    final item = SyncQueueEntity()
      ..id = queueId
      ..collection = _collectionName
      ..action = action
      ..dataJson = jsonEncode(_buildOutboxPayload(dealer))
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();
    await _dbService.syncQueue.put(item);
  }

  // ==================== READ OPERATIONS ====================

  /// Fetch all dealers - Local First
  Future<List<DealerEntity>> getAllDealers() async {
    return await _dbService.dealers
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Get dealers by status
  Future<List<DealerEntity>> getDealersByStatus(String status) async {
    return await _dbService.dealers
        .where()
        .filter()
        .statusEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Get dealers by territory
  Future<List<DealerEntity>> getDealersByTerritory(String territory) async {
    return await _dbService.dealers
        .where()
        .filter()
        .territoryEqualTo(territory)
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Get single dealer by ID
  Future<DealerEntity?> getDealerById(String id) async {
    return await _dbService.dealers.filter().idEqualTo(id).findFirst();
  }

  /// Search dealers by name, contact person, or mobile
  Future<List<DealerEntity>> searchDealers(String query) async {
    final lowerQuery = query.toLowerCase();
    return await _dbService.dealers
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group(
          (q) => q
              .nameContains(lowerQuery, caseSensitive: false)
              .or()
              .contactPersonContains(lowerQuery, caseSensitive: false)
              .or()
              .mobileContains(query),
        )
        .sortByName()
        .findAll();
  }

  // ==================== WRITE OPERATIONS ====================

  void _ensureCreatedAt(DealerEntity dealer, DateTime now) {
    try {
      final createdAt = dealer.createdAt;
      if (createdAt.trim().isNotEmpty) {
        return;
      }
    } catch (_) {
      // Missing createdAt is expected for some legacy/newly constructed entities.
    }
    dealer.createdAt = now.toIso8601String();
  }

  /// Create or Update Dealer - Local Commit
  Future<void> saveDealer(DealerEntity dealer) async {
    final now = DateTime.now();
    _ensureCreatedAt(dealer, now);
    dealer.updatedAt = now;
    dealer.syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.dealers.put(dealer);
      await _upsertOutboxInTxn(dealer, action: 'set');
    });
  }

  /// Update dealer status
  Future<void> updateStatus(String dealerId, String status) async {
    await _dbService.db.writeTxn(() async {
      final dealer = await _dbService.dealers
          .filter()
          .idEqualTo(dealerId)
          .findFirst();

      if (dealer != null) {
        dealer.status = status;
        dealer.updatedAt = DateTime.now();
        dealer.syncStatus = SyncStatus.pending;
        await _dbService.dealers.put(dealer);
        await _upsertOutboxInTxn(dealer, action: 'set');
      }
    });
  }

  /// Bulk update dealer status
  Future<void> bulkUpdateStatus(List<String> dealerIds, String status) async {
    await _dbService.db.writeTxn(() async {
      for (final id in dealerIds) {
        final dealer = await _dbService.dealers
            .filter()
            .idEqualTo(id)
            .findFirst();

        if (dealer != null) {
          dealer.status = status;
          dealer.updatedAt = DateTime.now();
          dealer.syncStatus = SyncStatus.pending;
          await _dbService.dealers.put(dealer);
          await _upsertOutboxInTxn(dealer, action: 'set');
        }
      }
    });
  }

  /// Soft delete dealer
  Future<void> deleteDealer(String dealerId) async {
    await _dbService.db.writeTxn(() async {
      final dealer = await _dbService.dealers
          .filter()
          .idEqualTo(dealerId)
          .findFirst();

      if (dealer != null) {
        dealer.isDeleted = true;
        dealer.updatedAt = DateTime.now();
        dealer.syncStatus = SyncStatus.pending;
        await _dbService.dealers.put(dealer);
        await _upsertOutboxInTxn(dealer, action: 'delete');
      }
    });
  }

  // ==================== SYNC SUPPORT ====================

  /// Get all pending dealers (for sync)
  Future<List<DealerEntity>> getPendingDealers() async {
    return await _dbService.dealers
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  /// Mark dealer as synced
  Future<void> markAsSynced(String dealerId) async {
    await _dbService.db.writeTxn(() async {
      final dealer = await _dbService.dealers
          .filter()
          .idEqualTo(dealerId)
          .findFirst();

      if (dealer != null) {
        dealer.syncStatus = SyncStatus.synced;
        await _dbService.dealers.put(dealer);
        final queueItem = await _dbService.syncQueue.getById(
          _queueId(dealer.id),
        );
        if (queueItem != null) {
          await _dbService.syncQueue.delete(queueItem.isarId);
        }
      }
    });
  }

  /// Batch save dealers (used during sync pull)
  Future<void> saveAllDealers(List<DealerEntity> dealers) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.dealers.putAll(dealers);
    });
  }
}
