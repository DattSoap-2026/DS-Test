import 'dart:convert';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'offline_first_service.dart';
import '../services/database_service.dart';
import '../data/local/entities/trip_entity.dart';
import '../data/local/base_entity.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'outbox_codec.dart';
import 'notification_service.dart';

import '../models/types/sales_types.dart';
import '../models/types/user_types.dart';

const tripsCollection = CollectionRegistry.deliveryTrips;
const salesCollection = CollectionRegistry.sales;

// Delivery Trip model (from React DeliveryTrip interface)
class DeliveryTrip {
  final String id;
  final String tripId;
  final String vehicleNumber;
  final String driverName;
  final String? driverPhone;
  final List<String> salesIds;
  final String status; // 'pending', 'in_progress', 'completed'
  final String createdAt;
  final String? startedAt;
  final String? completedAt;
  final String? notes;

  DeliveryTrip({
    required this.id,
    required this.tripId,
    required this.vehicleNumber,
    required this.driverName,
    this.driverPhone,
    required this.salesIds,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.notes,
  });

  factory DeliveryTrip.fromJson(Map<String, dynamic> json) {
    return DeliveryTrip(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      driverName: json['driverName'] as String,
      driverPhone: json['driverPhone'] as String?,
      salesIds: (json['salesIds'] as List).map((e) => e.toString()).toList(),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String,
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      if (driverPhone != null) 'driverPhone': driverPhone,
      'salesIds': salesIds,
      'status': status,
      'createdAt': createdAt,
      if (startedAt != null) 'startedAt': startedAt,
      if (completedAt != null) 'completedAt': completedAt,
      if (notes != null) 'notes': notes,
    };
  }
}

class DispatchService extends OfflineFirstService {
  final DatabaseService _db;
  DispatchService(super.firebase, this._db);
  static const int _isarAnyOfChunkSize = 200;

  @override
  String get localStorageKey => 'local_delivery_trips';

  @override
  bool get useIsar => true;

  static const String _legacyMigrationFlag = 'migrated_trips_to_isar_v1';

  TripEntity _buildTripEntityFromMap(
    Map<String, dynamic> data, {
    required SyncStatus syncStatus,
  }) {
    final createdAt =
        data['createdAt']?.toString() ?? DateTime.now().toIso8601String();
    final updatedAt =
        DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
        DateTime.tryParse(createdAt) ??
        DateTime.now();

    return TripEntity()
      ..id = data['id']?.toString() ?? generateId()
      ..tripId = data['tripId']?.toString() ?? ''
      ..vehicleNumber = data['vehicleNumber']?.toString() ?? ''
      ..driverName = data['driverName']?.toString() ?? ''
      ..driverPhone = data['driverPhone']?.toString()
      ..salesIds = (data['salesIds'] as List?)
          ?.map((e) => e.toString())
          .toList()
      ..status = data['status']?.toString() ?? 'pending'
      ..createdAt = createdAt
      ..startedAt = data['startedAt']?.toString()
      ..completedAt = data['completedAt']?.toString()
      ..notes = data['notes']?.toString()
      ..updatedAt = updatedAt
      ..syncStatus = syncStatus;
  }

  Future<String> _enqueueTripForSync(Map<String, dynamic> tripData) async {
    final tripId = tripData['id']?.toString();
    if (tripId == null || tripId.isEmpty) return '';

    final queueId = 'delivery_trips_$tripId';
    final existing = await _db.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = tripsCollection
      ..action = 'set'
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: tripData,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _db.db.writeTxn(() async {
      await _db.syncQueue.put(entity);
    });
    return queueId;
  }

  Future<void> _dequeueTripForSync(String queueId) async {
    if (queueId.isEmpty) return;
    final existing = await _db.syncQueue.getById(queueId);
    if (existing == null) return;
    await _db.db.writeTxn(() async {
      await _db.syncQueue.delete(existing.isarId);
    });
  }

  Future<bool> _queueAndSyncTrip(Map<String, dynamic> tripData) async {
    final queueId = await _enqueueTripForSync(tripData);
    if (db == null) return false;
    try {
      await performSync('set', tripsCollection, tripData);
      await _dequeueTripForSync(queueId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, SaleEntity>> _loadSalesByIds(
    Iterable<String> saleIds,
  ) async {
    final ids = saleIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const <String, SaleEntity>{};

    final loaded = <SaleEntity>[];
    for (var i = 0; i < ids.length; i += _isarAnyOfChunkSize) {
      final end = (i + _isarAnyOfChunkSize < ids.length)
          ? i + _isarAnyOfChunkSize
          : ids.length;
      final chunk = ids.sublist(i, end);
      final chunkSales = await _db.sales
          .filter()
          .anyOf(chunk, (q, String id) => q.idEqualTo(id))
          .findAll();
      loaded.addAll(chunkSales);
    }

    return {for (final sale in loaded) sale.id: sale};
  }

  Future<void> _migrateLegacyTripsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_legacyMigrationFlag) ?? false;
    if (migrated) return;

    final jsonStr = prefs.getString(localStorageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    List<dynamic> legacyList;
    try {
      legacyList = jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return;
    }

    if (legacyList.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    final existingTrips = await _db.trips.where().findAll();
    final existingIds = existingTrips.map((e) => e.id).toSet();

    final existingQueueItems = await _db.syncQueue
        .filter()
        .collectionEqualTo(tripsCollection)
        .findAll();
    final queuedIds = <String>{};
    for (final item in existingQueueItems) {
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      final id = decoded.payload['id']?.toString();
      if (id != null && id.isNotEmpty) queuedIds.add(id);
    }

    await _db.db.writeTxn(() async {
      for (final entry in legacyList) {
        if (entry is! Map) continue;
        final data = Map<String, dynamic>.from(entry);
        final id = data['id']?.toString();
        if (id == null || id.isEmpty) continue;
        if (existingIds.contains(id)) continue;

        final isSynced = data['isSynced'] == true;
        final needsSync = !isSynced;

        final entity = _buildTripEntityFromMap(
          data,
          syncStatus: needsSync ? SyncStatus.pending : SyncStatus.synced,
        );
        await _db.trips.put(entity);
        existingIds.add(id);

        if (needsSync && !queuedIds.contains(id)) {
          final queueEntity = SyncQueueEntity()
            ..id = 'delivery_trips_$id'
            ..collection = tripsCollection
            ..action = 'set'
            ..dataJson = OutboxCodec.encodeEnvelope(
              payload: data,
              now: DateTime.now(),
              resetRetryState: true,
            )
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now()
            ..syncStatus = SyncStatus.pending;
          await _db.syncQueue.put(queueEntity);
          queuedIds.add(id);
        }
      }
    });

    await prefs.remove(localStorageKey);
    await prefs.setBool(_legacyMigrationFlag, true);
  }

  // Create delivery trip and link sales (same logic as React createDeliveryTripClient)
  Future<bool> createDeliveryTrip({
    required String vehicleNumber,
    required String driverName,
    String? driverPhone,
    required List<String> salesIds,
    String status = 'pending',
    String? notes,
  }) async {
    try {
      await _migrateLegacyTripsIfNeeded();
      final notifiedSalesmen = <String, String>{};

      // 1. Generate IDs locally
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tripIdDisplay =
          'TRIP-${timestamp.toString().substring(timestamp.toString().length - 6)}';
      final newDocId = generateId(); // From OfflineFirstService

      // 2. Prepare Entity for Isar
      final tripEntity = TripEntity()
        ..id = newDocId
        ..tripId = tripIdDisplay
        ..vehicleNumber = vehicleNumber
        ..driverName = driverName
        ..driverPhone = driverPhone
        ..salesIds = salesIds
        ..status = status
        ..notes = notes
        ..createdAt = DateTime.now().toIso8601String()
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.pending;

      final salesById = await _loadSalesByIds(salesIds);

      // TASK-07: Guard against duplicate sale assignment
      for (final saleId in salesIds) {
        final sale = salesById[saleId];
        if (sale == null) continue;
        final existingTripId = sale.tripId?.trim() ?? '';
        if (existingTripId.isNotEmpty) {
          throw Exception(
            'Sale $saleId is already assigned to trip $existingTripId. '
            'Remove it from the existing trip first.',
          );
        }
      }

      // 3. Save to Local DB (Isar) - LOCAL-FIRST
      await _db.db.writeTxn(() async {
        await _db.trips.put(tripEntity);

        // Also update local sales status to sync with trip
        final salesToUpdate = <SaleEntity>[];
        for (final saleId in salesIds) {
          final sale = salesById[saleId];
          if (sale != null) {
            sale.status = 'in_transit';
            sale.tripId = newDocId;
            sale.updatedAt = DateTime.now();
            sale.syncStatus = SyncStatus.pending; // Mark for sync
            salesToUpdate.add(sale);

            final salesmanId = sale.salesmanId.trim();
            if (salesmanId.isNotEmpty) {
              notifiedSalesmen[salesmanId] = sale.salesmanName.trim();
            }
          }
        }
        if (salesToUpdate.isNotEmpty) {
          await _db.sales.putAll(salesToUpdate);
        }
      });

      // 4. Queue for Firebase Sync (Isar-based fallback)
      final tripData = tripEntity.toDomain().toJson();
      final synced = await _queueAndSyncTrip(tripData);

      if (synced) {
        await _db.db.writeTxn(() async {
          final existing = await _db.trips.getById(newDocId);
          if (existing != null) {
            existing.syncStatus = SyncStatus.synced;
            existing.updatedAt = DateTime.now();
            await _db.trips.put(existing);
          }
        });
      }

      for (final entry in notifiedSalesmen.entries) {
        await NotificationService().publishNotificationEvent(
          title: 'Order Accepted',
          body: 'Your order is accepted for dispatch (Trip: $tripIdDisplay).',
          eventType: 'order_accepted',
          targetUserIds: {entry.key},
          targetRoles: const {UserRole.salesman},
          data: {
            'tripId': newDocId,
            'tripCode': tripIdDisplay,
            'salesmanId': entry.key,
            if (entry.value.isNotEmpty) 'salesmanName': entry.value,
            'status': 'in_transit',
          },
          route: '/dashboard/dispatch',
          forceSound: true,
        );
      }

      // Note: SyncManager will handle individual sales status updates if needed,
      // but common practice for "Dispatch" is a bulk update on the server side too.
      // We'll queue the link logic as a separate action if necessary or handle it in SyncManager.

      AppLogger.success(
        'Delivery Trip created locally: $tripIdDisplay',
        tag: 'Dispatch',
      );
      return true;
    } catch (e) {
      throw handleError(e, 'createDeliveryTrip');
    }
  }

  // Get sales ready for dispatch (offline-first)
  Future<List<Sale>> getDispatchableSales() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final sevenDaysAgoStr = sevenDaysAgo.toIso8601String();

      // Ensure we query Isar first
      final localSales = await dbService.sales
          .filter()
          .createdAtGreaterThan(sevenDaysAgoStr)
          .anyOf([
            'completed',
            'pending_dispatch',
          ], (q, String val) => q.statusEqualTo(val))
          .sortByCreatedAtDesc()
          .findAll();

      // If missing data, try bootstrap
      if (localSales.isEmpty) {
        final items = await bootstrapFromFirebase(
          collectionName: salesCollection,
        );
        if (items.isNotEmpty) {
          await dbService.db.writeTxn(() async {
            for (final item in items) {
              final entity = SaleEntity.fromDomain(Sale.fromJson(item));
              entity.syncStatus = SyncStatus.synced;
              await dbService.sales.put(entity);
            }
          });
          // Re-query
          final refreshed = await dbService.sales
              .filter()
              .createdAtGreaterThan(sevenDaysAgoStr)
              .anyOf([
                'completed',
                'pending_dispatch',
              ], (q, String val) => q.statusEqualTo(val))
              .sortByCreatedAtDesc()
              .findAll();

          return refreshed
              .map((e) => e.toDomain())
              .where((s) => s.tripId == null || s.tripId!.isEmpty)
              .toList();
        }
      }

      return localSales
          .map((e) => e.toDomain())
          .where((s) => s.tripId == null || s.tripId!.isEmpty)
          .toList();
    } catch (e) {
      throw handleError(e, 'getDispatchableSales');
    }
  }

  // Get all delivery trips (additional helper method)
  Future<List<DeliveryTrip>> getDeliveryTrips({
    String? status,
    int? limitCount,
  }) async {
    try {
      List<TripEntity> localTrips;
      if (status != null) {
        localTrips = await dbService.trips
            .filter()
            .statusEqualTo(status)
            .findAll();
      } else {
        localTrips = await dbService.trips.where().findAll();
      }
      localTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (limitCount != null && localTrips.length > limitCount) {
        localTrips = localTrips.sublist(0, limitCount);
      }

      if (localTrips.isEmpty) {
        final items = await bootstrapFromFirebase(
          collectionName: tripsCollection,
        );
        if (items.isNotEmpty) {
          await dbService.db.writeTxn(() async {
            for (final item in items) {
              final entity = _buildTripEntityFromMap(
                item,
                syncStatus: SyncStatus.synced,
              );
              await dbService.trips.put(entity);
            }
          });

          if (status != null) {
            localTrips = await dbService.trips
                .filter()
                .statusEqualTo(status)
                .findAll();
          } else {
            localTrips = await dbService.trips.where().findAll();
          }
          localTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (limitCount != null && localTrips.length > limitCount) {
            localTrips = localTrips.sublist(0, limitCount);
          }
        }
      }

      return localTrips.map((e) => e.toDomain()).toList();
    } catch (e) {
      throw handleError(e, 'getDeliveryTrips');
    }
  }

  // Get trips for a specific driver
  Future<List<DeliveryTrip>> getDriverTrips(String driverName) async {
    try {
      final localTrips = await dbService.trips
          .filter()
          .driverNameEqualTo(driverName)
          .sortByCreatedAtDesc()
          .findAll();

      if (localTrips.isEmpty) {
        // Optimization: rely on getDeliveryTrips to bootstrap if needed
        return [];
      }

      return localTrips.take(20).map((e) => e.toDomain()).toList();
    } catch (e) {
      throw handleError(e, 'getDriverTrips');
    }
  }

  // Get active trip for a specific driver
  Future<DeliveryTrip?> getActiveDriverTrip(String driverName) async {
    try {
      final localTrip = await dbService.trips
          .filter()
          .driverNameEqualTo(driverName)
          .statusEqualTo('in_transit')
          .findFirst();

      return localTrip?.toDomain();
    } catch (e) {
      throw handleError(e, 'getActiveDriverTrip');
    }
  }

  // Update trip status (additional helper method)
  // TASK-15: Trip state machine — legal transitions.
  static const _validTransitions = <String, List<String>>{
    'pending': ['in_progress', 'cancelled'],
    'in_progress': ['completed', 'cancelled'],
    'completed': [], // terminal state
    'cancelled': [], // terminal state
  };

  Future<bool> updateTripStatus(
    String tripId,
    String status, {
    String? startedAt,
    String? completedAt,
  }) async {
    try {
      final trip = await dbService.trips.filter().idEqualTo(tripId).findFirst();
      if (trip == null) {
        return false;
      }

      // TASK-15: Validate state transition
      final currentStatus = trip.status;
      final allowed = _validTransitions[currentStatus];
      if (allowed != null && !allowed.contains(status)) {
        throw StateError(
          'Invalid trip status transition: "$currentStatus" -> "$status". '
          'Allowed: ${allowed.isEmpty ? "none (terminal state)" : allowed.join(", ")}',
        );
      }

      await dbService.db.writeTxn(() async {
        trip.status = status;
        if (startedAt != null) trip.startedAt = startedAt;
        if (completedAt != null) trip.completedAt = completedAt;
        trip.updatedAt = DateTime.now();
        trip.syncStatus = SyncStatus.pending;
        await dbService.trips.put(trip);
      });

      final updateData = <String, dynamic>{
        'id': trip.id,
        'status': status,
        if (startedAt != null) 'startedAt': startedAt,
        if (completedAt != null) 'completedAt': completedAt,
      };

      final queueId =
          'delivery_trips_update_${trip.id}_${DateTime.now().millisecondsSinceEpoch}';
      final entity = SyncQueueEntity()
        ..id = queueId
        ..collection = tripsCollection
        ..action = 'update'
        ..dataJson = OutboxCodec.encodeEnvelope(
          payload: updateData,
          now: DateTime.now(),
          resetRetryState: true,
        )
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.pending;

      await dbService.db.writeTxn(() async {
        await dbService.syncQueue.put(entity);
      });

      // Try background sync if possible but don't strictly wait for success
      // In OfflineFirstService, this would be picked up by SyncManager

      return true;
    } catch (e) {
      throw handleError(e, 'updateTripStatus');
    }
  }

  // Backward compatibility method
  Future<List<DeliveryTrip>> getTrips({String? status, int? limit}) async {
    return getDeliveryTrips(status: status, limitCount: limit);
  }
}
