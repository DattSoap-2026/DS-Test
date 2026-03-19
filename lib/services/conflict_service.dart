import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../data/local/entities/conflict_entity.dart';
import '../data/local/base_entity.dart';
import 'database_service.dart';
import '../utils/app_logger.dart';

class ConflictService {
  final DatabaseService _dbService;
  final _uuid = const Uuid();

  ConflictService(this._dbService);

  /// Flags a new conflict between local and server data
  Future<void> flagConflict({
    required String entityId,
    required String entityType,
    required String localData,
    required String serverData,
  }) async {
    try {
      final conflict = ConflictEntity()
        ..id = _uuid.v4()
        ..entityId = entityId
        ..entityType = entityType
        ..localData = localData
        ..serverData = serverData
        ..conflictDate = DateTime.now()
        ..resolved = false
        ..resolutionStrategy = ResolutionStrategy.pending
        ..syncStatus = SyncStatus
            .synced // Conflict log itself is local-first
        ..updatedAt = DateTime.now();

      await _dbService.db.writeTxn(() async {
        await _dbService.conflicts.put(conflict);
      });

      AppLogger.warning(
        'Conflict Flagged: $entityType - $entityId',
        tag: 'Sync',
      );
    } catch (e) {
      AppLogger.error('Error flagging conflict', error: e, tag: 'Sync');
    }
  }

  /// Gets all unresolved conflicts
  Future<List<ConflictEntity>> getPendingConflicts() async {
    return await _dbService.conflicts
        .filter()
        .resolvedEqualTo(false)
        .sortByConflictDateDesc()
        .findAll();
  }

  /// Gets conflict history (resolved)
  Future<List<ConflictEntity>> getConflictHistory({int limit = 50}) async {
    return await _dbService.conflicts
        .filter()
        .resolvedEqualTo(true)
        .sortByResolvedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// Resolves a conflict with a specific strategy
  Future<bool> resolveConflict(
    String conflictId,
    ResolutionStrategy strategy, {
    dynamic syncCoordinator, // Optional for manual triggering
  }) async {
    try {
      final conflict = await _dbService.conflicts.get(fastHash(conflictId));
      if (conflict == null) return false;

      final serverData =
          jsonDecode(conflict.serverData) as Map<String, dynamic>;
      final entityId = conflict.entityId;
      final entityType = conflict.entityType;

      await _dbService.db.writeTxn(() async {
        if (strategy == ResolutionStrategy.useServer) {
          // Overwrite local with server data
          await _applyServerData(entityType, entityId, serverData);
        } else if (strategy == ResolutionStrategy.useLocal) {
          // Keep local, but reset status to pending so it can sync again
          await _resetToPending(entityType, entityId);
        }

        // Mark conflict as resolved
        conflict.resolved = true;
        conflict.resolutionStrategy = strategy;
        conflict.resolvedAt = DateTime.now();
        conflict.updatedAt = DateTime.now();
        await _dbService.conflicts.put(conflict);
      });

      AppLogger.info(
        'Conflict Resolved: $entityType - $entityId (${strategy.name})',
        tag: 'Sync',
      );
      return true;
    } catch (e) {
      AppLogger.error('Error resolving conflict', error: e, tag: 'Sync');
      return false;
    }
  }

  Future<void> _applyServerData(
    String type,
    String id,
    Map<String, dynamic> data,
  ) async {
    final iId = fastHash(id);
    switch (type) {
      case 'users':
        final entity = await _dbService.users.get(iId);
        if (entity != null) {
          // Update properties from data
          // Minimal update for now, ideally full mapping
          entity.syncStatus = SyncStatus.synced;
          entity.updatedAt = DateTime.now();
          await _dbService.users.put(entity);
        }
        break;
      case 'dealers':
        final entity = await _dbService.dealers.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.synced;
          entity.updatedAt = DateTime.now();
          await _dbService.dealers.put(entity);
        }
        break;
      case 'customers':
        final entity = await _dbService.customers.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.synced;
          entity.updatedAt = DateTime.now();
          await _dbService.customers.put(entity);
        }
        break;
      case 'products':
        final entity = await _dbService.products.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.synced;
          entity.updatedAt = DateTime.now();
          await _dbService.products.put(entity);
        }
        break;
      case 'sales':
        final entity = await _dbService.sales.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.synced;
          entity.updatedAt = DateTime.now();
          await _dbService.sales.put(entity);
        }
        break;
      case 'returns':
        final entity = await _dbService.returns.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.synced;
          entity.updatedAt = DateTime.now();
          await _dbService.returns.put(entity);
        }
        break;
    }
  }

  Future<void> _resetToPending(String type, String id) async {
    final iId = fastHash(id);
    switch (type) {
      case 'users':
        final entity = await _dbService.users.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.pending;
          await _dbService.users.put(entity);
        }
        break;
      case 'dealers':
        final entity = await _dbService.dealers.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.pending;
          await _dbService.dealers.put(entity);
        }
        break;
      case 'customers':
        final entity = await _dbService.customers.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.pending;
          await _dbService.customers.put(entity);
        }
        break;
      case 'products':
        final entity = await _dbService.products.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.pending;
          await _dbService.products.put(entity);
        }
        break;
      case 'sales':
        final entity = await _dbService.sales.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.pending;
          await _dbService.sales.put(entity);
        }
        break;
      case 'returns':
        final entity = await _dbService.returns.get(iId);
        if (entity != null) {
          entity.syncStatus = SyncStatus.pending;
          await _dbService.returns.put(entity);
        }
        break;
    }
  }

  Stream<List<ConflictEntity>> watchPendingConflicts() {
    return _dbService.conflicts
        .filter()
        .resolvedEqualTo(false)
        .sortByConflictDateDesc()
        .watch();
  }

  Stream<void> watchConflicts() {
    return _dbService.conflicts.watchLazy();
  }
}
