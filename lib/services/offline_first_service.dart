import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/network/connectivity_service.dart';
import '../core/sync/sync_queue_service.dart';
import '../core/sync/sync_service.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'base_service.dart';
import 'database_service.dart';
import 'outbox_codec.dart';

/// Base class for offline-first services
///
/// Provides reusable local storage operations for all services.
/// Local storage is the single source of truth.
/// Firebase sync is optional and non-blocking.
abstract class OfflineFirstService extends BaseService {
  final DatabaseService dbService;

  OfflineFirstService(super.firebaseServices, [DatabaseService? dbService])
    : dbService = dbService ?? DatabaseService.instance;

  /// Override in subclass to provide local storage key (for SharedPreferences fallback)
  String get localStorageKey;

  /// Whether this service uses Isar for local storage
  bool get useIsar => false;

  // ======================================
  // LOCAL STORAGE OPERATIONS (ISAR & SHPREFS)
  // ======================================

  /// Load all items from local storage
  Future<List<Map<String, dynamic>>> loadFromLocal() async {
    try {
      if (useIsar) {
        // Subclasses using Isar should override specific fetch logic or use this as a hint.
        // For now, this remains the SharedPreferences fallback.
        return [];
      }
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(localStorageKey);
      if (json != null) {
        final decoded = List<Map<String, dynamic>>.from(jsonDecode(json));
        return decoded.where((item) => item['isDeleted'] != true).toList();
      }
      return [];
    } catch (e) {
      handleError(e, 'loadFromLocal');
      return [];
    }
  }

  /// Save all items to local storage
  Future<void> saveToLocal(List<Map<String, dynamic>> items) async {
    try {
      if (useIsar) return; // Isar uses specific put() calls
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(localStorageKey, jsonEncode(items));
    } catch (e) {
      handleError(e, 'saveToLocal');
      rethrow;
    }
  }

  /// Add a single item to local storage
  Future<void> addToLocal(Map<String, dynamic> item) async {
    try {
      if (useIsar) return;
      final items = await loadFromLocal();
      items.add(item);
      await saveToLocal(items);
    } catch (e) {
      handleError(e, 'addToLocal');
      rethrow;
    }
  }

  /// Add multiple items to local storage (Bulk)
  Future<void> bulkAddToLocal(List<Map<String, dynamic>> newItems) async {
    try {
      if (useIsar) return;
      final items = await loadFromLocal();
      items.addAll(newItems);
      await saveToLocal(items);
    } catch (e) {
      handleError(e, 'bulkAddToLocal');
      rethrow;
    }
  }

  /// Update an item in local storage
  Future<void> updateInLocal(String id, Map<String, dynamic> updates) async {
    try {
      if (useIsar) return;
      final items = await loadFromLocal();
      final index = items.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        items[index] = {...items[index], ...updates};
        await saveToLocal(items);
      }
    } catch (e) {
      handleError(e, 'updateInLocal');
      rethrow;
    }
  }

  /// Delete an item from local storage
  Future<void> deleteFromLocal(String id) async {
    try {
      if (useIsar) return;
      final items = await loadFromLocal();
      final now = getCurrentTimestamp();
      final index = items.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        items[index] = {
          ...items[index],
          'isDeleted': true,
          'deletedAt': now,
          'updatedAt': now,
        };
        await saveToLocal(items);
      }
    } catch (e) {
      handleError(e, 'deleteFromLocal');
      rethrow;
    }
  }

  /// Find a single item by ID in local storage
  Future<Map<String, dynamic>?> findInLocal(String id) async {
    try {
      if (useIsar) return null;
      final items = await loadFromLocal();
      final item = items.firstWhere(
        (item) => item['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      if (item.isNotEmpty && item['isDeleted'] == true) {
        return null;
      }
      return item.isEmpty ? null : item;
    } catch (e) {
      handleError(e, 'findInLocal');
      return null;
    }
  }

  /// Upsert (Update or Insert) an item in local storage
  Future<void> upsertToLocal(Map<String, dynamic> item) async {
    try {
      if (useIsar) return;
      final id = item['id']?.toString();
      if (id == null) return;

      final items = await loadFromLocal();
      final index = items.indexWhere((i) => i['id'] == id);

      if (index != -1) {
        // Update existing
        items[index] = {...items[index], ...item};
      } else {
        // Insert new
        items.add(item);
      }
      await saveToLocal(items);
    } catch (e) {
      handleError(e, 'upsertToLocal');
      rethrow;
    }
  }

  // ======================================
  // SYNC QUEUE OPERATIONS
  // ======================================

  /// Upsert item to durable sync queue.
  @protected
  Future<void> enqueue(Map<String, dynamic> item) async {
    try {
      final data = item['data'] as Map<String, dynamic>? ?? {};
      final collection = item['collection']?.toString() ?? '';
      final action = item['action']?.toString() ?? 'set';
      final explicitQueueId = item['queueId']?.toString().trim() ?? '';
      final documentId =
          data['id']?.toString().trim() ??
          OutboxCodec.tryExtractRecordId(explicitQueueId) ??
          '';
      if (collection.trim().isEmpty || documentId.isEmpty) {
        return;
      }

      await SyncQueueService.instance.addToQueue(
        collectionName: collection,
        documentId: documentId,
        operation: action,
        payload: data,
      );
    } catch (e) {
      handleError(e, 'enqueue');
    }
  }

  /// Remove item from sync queue
  @protected
  Future<void> dequeue(String queueId) async {
    try {
      final normalizedQueueId = queueId.trim();
      if (normalizedQueueId.isEmpty) {
        return;
      }

      final collection = OutboxCodec.tryExtractCollection(normalizedQueueId);
      final documentId = OutboxCodec.tryExtractRecordId(normalizedQueueId);
      if (collection == null || documentId == null) {
        return;
      }

      await SyncQueueService.instance.removeFromQueue(
        collectionName: collection,
        documentId: documentId,
      );
    } catch (e) {
      handleError(e, 'dequeue');
    }
  }

  // ======================================
  // FIREBASE SYNC (QUEUE-BASED)
  // ======================================

  /// Sync to Firebase with queue fallback
  /// 1. Upsert durable outbox item
  /// 2. Try immediate sync (optional)
  /// 3. Dequeue if success
  Future<void> syncToFirebase(
    String action,
    Map<String, dynamic> data, {
    String? collectionName,
    bool syncImmediately = true,
  }) async {
    final collection =
        collectionName ?? localStorageKey.replaceAll('local_', '');
    final payload = Map<String, dynamic>.from(data);
    final operation = _normalizeQueueOperation(action);
    final now = getCurrentTimestamp();
    final existingId = payload['id']?.toString().trim() ?? '';
    final documentId = existingId.isNotEmpty
        ? existingId
        : (operation == 'delete' ? '' : generateId());

    try {
      if (documentId.isEmpty) {
        return;
      }

      payload['id'] = documentId;
      payload['updatedAt'] ??= now;
      if (operation == 'delete') {
        payload['isDeleted'] = true;
        payload['deletedAt'] ??= now;
      } else {
        payload['isDeleted'] ??= false;
      }

      await SyncQueueService.instance.addToQueue(
        collectionName: collection,
        documentId: documentId,
        operation: operation,
        payload: payload,
      );

      if (!syncImmediately) return;

      if (ConnectivityService.instance.isOnline) {
        await SyncService.instance.syncAllPending();
      }
    } catch (e) {
      handleError(e, 'syncToFirebase');
    }
  }

  /// Bulk enqueue to Firebase outbox
  Future<void> bulkSyncToFirebase(
    String action,
    List<Map<String, dynamic>> itemsList, {
    String? collectionName,
  }) async {
    final collection =
        collectionName ?? localStorageKey.replaceAll('local_', '');
    final operation = _normalizeQueueOperation(action);

    try {
      for (final item in itemsList) {
        final payload = Map<String, dynamic>.from(item);
        final existingId = payload['id']?.toString().trim() ?? '';
        final documentId = existingId.isNotEmpty
            ? existingId
            : (operation == 'delete' ? '' : generateId());
        if (documentId.isEmpty) {
          continue;
        }

        payload['id'] = documentId;
        payload['updatedAt'] ??= getCurrentTimestamp();
        if (operation == 'delete') {
          payload['isDeleted'] = true;
          payload['deletedAt'] ??= getCurrentTimestamp();
        } else {
          payload['isDeleted'] ??= false;
        }

        await SyncQueueService.instance.addToQueue(
          collectionName: collection,
          documentId: documentId,
          operation: operation,
          payload: payload,
        );
      }
      if (ConnectivityService.instance.isOnline) {
        await SyncService.instance.syncAllPending();
      }
    } catch (e) {
      handleError(e, 'bulkSyncToFirebase');
    }
  }

  /// Returns all permanently-failed (dead-letter) sync queue items.
  ///
  /// These are items that exhausted their retry budget and were marked
  /// with [SyncStatus.conflict] by [_recordQueueFailure].
  Future<List<SyncQueueEntity>> getFailedSyncItems() async {
    final all = await dbService.syncQueue.where().findAll();
    return all.where((e) => e.syncStatus == SyncStatus.conflict).toList();
  }

  /// Resets a permanently-failed item back to [SyncStatus.pending] so the
  /// queue processor will retry it on the next sync cycle.
  Future<bool> retryFailedSyncItem(String queueId) async {
    try {
      final item = await dbService.syncQueue.getById(queueId);
      if (item == null) return false;
      item
        ..syncStatus = SyncStatus.pending
        ..updatedAt = DateTime.now();
      await dbService.db.writeTxn(() async {
        await dbService.syncQueue.put(item);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Permanently removes a failed sync queue item (admin discard).
  Future<bool> deleteFailedSyncItem(String queueId) async {
    try {
      final item = await dbService.syncQueue.getById(queueId);
      if (item == null) return false;
      await dbService.db.writeTxn(() async {
        await dbService.syncQueue.delete(item.isarId);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Override this in subclasses to implement custom sync logic (e.g., Transactions)
  /// Default implementation handles standard CRUD
  @protected
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final id = data['id'] as String?;
    final now = getCurrentTimestamp();
    var documentId = id ?? '';

    switch (action) {
      case 'add':
      case 'set':
        data['updatedAt'] ??= now;
        data['isDeleted'] ??= false;
        if (data['isDeleted'] == true) {
          data['deletedAt'] ??= now;
        } else if (!data.containsKey('deletedAt')) {
          data['deletedAt'] = null;
        }
        if (documentId.isEmpty) {
          final newId = generateId();
          data['id'] = newId;
          documentId = newId;
        }
        break;
      case 'update':
        data['updatedAt'] ??= now;
        data['isDeleted'] ??= false;
        if (data['isDeleted'] == true) {
          data['deletedAt'] ??= now;
        }
        if (documentId.isEmpty) {
          return;
        }
        break;
      case 'delete':
        if (documentId.isEmpty) {
          return;
        }
        if (_isFinancialCollection(collection)) {
          debugPrint(
            'Blocked delete for $collection/$documentId. Financial docs require reversal entries.',
          );
          return;
        }
        data = <String, dynamic>{
          'id': documentId,
          'isDeleted': true,
          'deletedAt': data['deletedAt'] ?? now,
          'updatedAt': data['updatedAt'] ?? now,
        };
        break;
      default:
        return;
    }

    if (documentId.isEmpty) {
      return;
    }
    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: documentId,
      operation: action,
      payload: data,
    );
    await SyncService.instance.pushAllPending();
  }

  bool _isFinancialCollection(String collection) {
    return collection == 'accounts' ||
        collection == 'vouchers' ||
        collection == 'voucher_entries';
  }

  /// Bootstrap local storage from Firebase (one-time)
  Future<List<Map<String, dynamic>>> bootstrapFromFirebase({
    required String collectionName,
  }) async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(collectionName)
          .get()
          .timeout(const Duration(seconds: 3));
      final items = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      if (items.isNotEmpty && !useIsar) {
        await saveToLocal(items);
      }

      return items;
    } catch (e) {
      handleError(e, 'bootstrapFromFirebase');
      return [];
    }
  }

  // ======================================
  // UTILITY METHODS
  // ======================================

  /// Generate a unique ID for new items
  String generateId() {
    return const Uuid().v4();
  }

  /// Get current ISO timestamp
  String getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }

  /// Add timestamps to data
  Map<String, dynamic> addTimestamps(
    Map<String, dynamic> data, {
    bool isNew = true,
  }) {
    final now = getCurrentTimestamp();
    if (isNew) {
      data['createdAt'] = now;
    }
    data['lastUpdatedAt'] = now;
    return data;
  }

  String _normalizeQueueOperation(String action) {
    switch (action.trim().toLowerCase()) {
      case 'add':
      case 'create':
        return 'create';
      case 'delete':
        return 'delete';
      case 'set':
      case 'update':
      default:
        return 'update';
    }
  }
}
