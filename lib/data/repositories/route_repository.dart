import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/customer_visit_entity.dart';
import '../local/entities/route_entity.dart';
import '../local/entities/route_order_entity.dart';
import '../local/entities/route_session_entity.dart';

/// Isar-first repository for route entities, orders, sessions, and visits.
class RouteRepository {
  RouteRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  Future<void> saveRoute(RouteEntity route) async {
    final id = _ensureId(route);
    final existing = await _dbService.routes.getById(id);
    route
      ..id = id
      ..createdAt = _safeString(() => route.createdAt, fallback: DateTime.now().toIso8601String())
      ..name = _safeString(() => route.name)
      ..isActive = route.isActive;

    await _stampForSync(route, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.routes.put(route);
    });

    await _enqueue(CollectionRegistry.routes, route.id, existing == null ? 'create' : 'update', route.toJson());
    await _syncIfOnline();
  }

  Future<List<RouteEntity>> getAllRoutes() {
    return _dbService.routes
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  Future<RouteEntity?> getRouteById(String id) {
    return _dbService.routes
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Stream<List<RouteEntity>> watchAllRoutes() {
    return _dbService.routes
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Future<void> deleteRoute(String id) async {
    final route = await _dbService.routes.getById(id);
    if (route == null || route.isDeleted) {
      return;
    }
    route
      ..isActive = false
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await _stampDeleted(route);
    await _dbService.db.writeTxn(() async {
      await _dbService.routes.put(route);
    });
    await _enqueue(CollectionRegistry.routes, route.id, 'delete', route.toJson());
    await _syncIfOnline();
  }

  Future<void> saveRouteOrder(RouteOrderEntity order) async {
    final id = _ensureId(order);
    final existing = await _dbService.routeOrders.getById(id);
    order
      ..id = id
      ..createdAt = _ensureDate(() => order.createdAt, existing?.createdAt)
      ..itemsJson = _safeString(() => order.itemsJson, fallback: '[]');

    await _stampForSync(order, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.routeOrders.put(order);
    });

    await _enqueue(
      CollectionRegistry.routeOrders,
      order.id,
      existing == null ? 'create' : 'update',
      order.toJson(),
    );
    await _syncIfOnline();
  }

  Future<RouteOrderEntity?> getRouteOrderById(String id) {
    return _dbService.routeOrders
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<RouteOrderEntity>> getOrdersByRoute(String routeId) {
    return _dbService.routeOrders
        .filter()
        .routeIdEqualTo(routeId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<RouteOrderEntity>> getOrdersBySalesman(String salesmanId) {
    return _dbService.routeOrders
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<RouteOrderEntity>> getOrdersByStatus(String status) async {
    final all = await getAllRouteOrders();
    return all
        .where((order) => order.productionStatus == status || order.dispatchStatus == status)
        .toList(growable: false);
  }

  Future<void> updateOrderStatus(String id, String status) async {
    final order = await _dbService.routeOrders.getById(id);
    if (order == null || order.isDeleted) {
      return;
    }
    order
      ..productionStatus = status
      ..dispatchStatus = status;
    await _updateRouteOrder(order);
  }

  Future<List<RouteOrderEntity>> getAllRouteOrders() {
    return _dbService.routeOrders
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Stream<List<RouteOrderEntity>> watchAllRouteOrders() {
    return _dbService.routeOrders
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> cancelOrder(String id, String reason) async {
    final order = await _dbService.routeOrders.getById(id);
    if (order == null || order.isDeleted) {
      return;
    }
    order
      ..productionStatus = 'cancelled'
      ..dispatchStatus = 'cancelled'
      ..cancelReason = reason
      ..cancelledAt = DateTime.now();
    await _updateRouteOrder(order);
  }

  Future<void> saveRouteSession(RouteSessionEntity session) async {
    final id = _ensureId(session);
    final existing = await _dbService.routeSessions.getById(id);
    session
      ..id = id
      ..createdAt = _safeString(() => session.createdAt, fallback: DateTime.now().toIso8601String())
      ..status = _safeString(() => session.status, fallback: 'active');

    await _stampForSync(session, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.routeSessions.put(session);
    });

    await _enqueue(
      CollectionRegistry.routeSessions,
      session.id,
      existing == null ? 'create' : 'update',
      session.toJson(),
    );
    await _syncIfOnline();
  }

  Future<RouteSessionEntity?> getSessionById(String id) {
    return _dbService.routeSessions
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<RouteSessionEntity>> getSessionsBySalesman(String salesmanId) {
    return _dbService.routeSessions
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<RouteSessionEntity?> getActiveSession(String salesmanId) {
    return _dbService.routeSessions
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .statusEqualTo('active')
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<RouteSessionEntity>> getAllSessions() {
    return _dbService.routeSessions
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Stream<List<RouteSessionEntity>> watchAllSessions() {
    return _dbService.routeSessions
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> closeSession(String id, DateTime endTime) async {
    final session = await _dbService.routeSessions.getById(id);
    if (session == null || session.isDeleted) {
      return;
    }
    session
      ..status = 'completed'
      ..endTime = endTime.toIso8601String();
    await _updateRouteSession(session);
  }

  Future<void> saveCustomerVisit(CustomerVisitEntity visit) async {
    final id = _ensureId(visit);
    final existing = await _dbService.customerVisits.getById(id);
    visit
      ..id = id
      ..createdAt = _safeString(() => visit.createdAt, fallback: DateTime.now().toIso8601String())
      ..status = _safeString(() => visit.status, fallback: 'in_progress');

    await _stampForSync(visit, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.customerVisits.put(visit);
    });

    await _enqueue(
      CollectionRegistry.customerVisits,
      visit.id,
      existing == null ? 'create' : 'update',
      visit.toJson(),
    );
    await _syncIfOnline();
  }

  Future<List<CustomerVisitEntity>> getVisitsBySession(String sessionId) {
    return _dbService.customerVisits
        .filter()
        .sessionIdEqualTo(sessionId)
        .and()
        .isDeletedEqualTo(false)
        .sortBySequenceNumber()
        .findAll();
  }

  Future<List<CustomerVisitEntity>> getVisitsByCustomer(String customerId) {
    return _dbService.customerVisits
        .filter()
        .customerIdEqualTo(customerId)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<CustomerVisitEntity>> getAllVisits() {
    return _dbService.customerVisits
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Stream<List<CustomerVisitEntity>> watchVisitsBySession(String sessionId) {
    return _dbService.customerVisits
        .filter()
        .sessionIdEqualTo(sessionId)
        .and()
        .isDeletedEqualTo(false)
        .sortBySequenceNumber()
        .watch(fireImmediately: true);
  }

  Future<void> _updateRouteOrder(RouteOrderEntity order) async {
    await _stampForSync(order, order);
    await _dbService.db.writeTxn(() async {
      await _dbService.routeOrders.put(order);
    });
    await _enqueue(CollectionRegistry.routeOrders, order.id, 'update', order.toJson());
    await _syncIfOnline();
  }

  Future<void> _updateRouteSession(RouteSessionEntity session) async {
    await _stampForSync(session, session);
    await _dbService.db.writeTxn(() async {
      await _dbService.routeSessions.put(session);
    });
    await _enqueue(CollectionRegistry.routeSessions, session.id, 'update', session.toJson());
    await _syncIfOnline();
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = entity.isDeleted ? entity.deletedAt : null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _stampDeleted(BaseEntity entity) async {
    entity
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _enqueue(
    String collectionName,
    String documentId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return _syncQueueService.addToQueue(
      collectionName: collectionName,
      documentId: documentId,
      operation: operation,
      payload: payload,
    );
  }

  String _ensureId(BaseEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _safeString(String Function() reader, {String fallback = ''}) {
    try {
      final value = reader().trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  DateTime _ensureDate(DateTime Function() reader, DateTime? fallback) {
    try {
      return reader();
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
