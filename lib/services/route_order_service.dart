import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:intl/intl.dart';

import '../models/types/route_order_types.dart';
import '../models/types/sales_types.dart';
import '../models/types/user_types.dart';
import '../utils/app_logger.dart';
import '../models/types/alert_types.dart';
import 'alert_service.dart';
import 'inventory_service.dart';
import 'offline_first_service.dart';
import '../data/local/entities/route_order_entity.dart';
import 'products_service.dart';
import 'users_service.dart';
import 'package:isar/isar.dart';

const routeOrdersCollection = 'route_orders';

class RouteOrderService extends OfflineFirstService {
  final InventoryService _inventoryService;
  final UsersService _usersService;
  final ProductsService _productsService;
  final AlertService _alertService;

  RouteOrderService(
    super.firebase,
    this._inventoryService,
    this._usersService,
    this._productsService,
    this._alertService,
  );

  @override
  String get localStorageKey => 'local_route_orders';

  @override
  bool get useIsar => true;

  bool get _isWindowsFirestoreListenerUnsafe =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  bool get _avoidAuthStateStreamsOnWindows =>
      _isWindowsFirestoreListenerUnsafe && kDebugMode;

  String _normalizeCreatedByRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized.contains('salesman')) return 'salesman';
    if (normalized.contains('dealer')) return 'dealerManager';
    return 'admin';
  }

  RouteOrderSource _resolveSource({
    required String createdByRole,
    RouteOrderSource? sourceOverride,
  }) {
    if (sourceOverride != null) return sourceOverride;
    final role = _normalizeCreatedByRole(createdByRole);
    return role == 'dealerManager'
        ? RouteOrderSource.dealerManager
        : RouteOrderSource.salesman;
  }

  String _buildOrderNo(String id, DateTime now) {
    final dateToken = DateFormat('yyyyMMdd').format(now);
    final suffix = id.length >= 4 ? id.substring(0, 4).toUpperCase() : id;
    return 'ORD-$dateToken-$suffix';
  }

  firestore.Query<Map<String, dynamic>> _buildQuery({
    String? routeId,
    String? salesmanId,
    RouteOrderProductionStatus? productionStatus,
    RouteOrderDispatchStatus? dispatchStatus,
    int limit = 200,
  }) {
    final firestoreDb = db;
    if (firestoreDb == null) {
      throw StateError('Firestore is not available.');
    }

    firestore.Query<Map<String, dynamic>> query = firestoreDb
        .collection(routeOrdersCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final normalizedRouteId = routeId?.trim();
    if (normalizedRouteId != null && normalizedRouteId.isNotEmpty) {
      query = query.where('routeId', isEqualTo: normalizedRouteId);
    }

    final normalizedSalesmanId = salesmanId?.trim();
    if (normalizedSalesmanId != null && normalizedSalesmanId.isNotEmpty) {
      query = query.where('salesmanId', isEqualTo: normalizedSalesmanId);
    }

    if (productionStatus != null) {
      query = query.where(
        'productionStatus',
        isEqualTo: productionStatus.value,
      );
    }

    if (dispatchStatus != null) {
      query = query.where('dispatchStatus', isEqualTo: dispatchStatus.value);
    }

    return query;
  }

  Future<List<RouteOrder>> _loadLocalOrders() async {
    final entities = await dbService.routeOrders.where().findAll();
    final orders = entities
        .where((e) => !e.isDeleted)
        .map((e) => e.toDomain())
        .toList();
    orders.sort((a, b) => b.createdDateTime.compareTo(a.createdDateTime));
    return orders;
  }

  Future<void> _cacheOrders(List<RouteOrder> orders) async {
    final entities = orders.map((o) => RouteOrderEntity.fromDomain(o)).toList();
    await dbService.db.writeTxn(() async {
      await dbService.routeOrders.putAll(entities);
    });
  }

  Future<void> _cacheOrder(RouteOrder order) async {
    final entity = RouteOrderEntity.fromDomain(order);
    await dbService.db.writeTxn(() async {
      await dbService.routeOrders.put(entity);
    });
  }

  Future<void> _applyLocalUpdate(
    String orderId,
    Map<String, dynamic> updates,
  ) async {
    final existing = await dbService.routeOrders.getById(orderId);
    if (existing == null) {
      // If applying an update and it doesn't exist, we can't easily construct the full entity without the domain object.
      // Usually updates are merging. If it doesn't exist locally, we might just ignore or create a dummy.
      // Given Isar requires strict schema, partial updates mean modifying the object.
      return;
    }

    // Apply limited partial updates typically expected in route_order_service
    if (updates.containsKey('productionStatus')) {
      existing.productionStatus = updates['productionStatus'] as String;
    }
    if (updates.containsKey('dispatchStatus')) {
      existing.dispatchStatus = updates['dispatchStatus'] as String;
    }
    if (updates.containsKey('productionUpdatedAt')) {
      existing.productionUpdatedAt = DateTime.tryParse(
        updates['productionUpdatedAt'] as String,
      );
    }
    if (updates.containsKey('productionUpdatedById')) {
      existing.productionUpdatedById =
          updates['productionUpdatedById'] as String?;
    }
    if (updates.containsKey('productionUpdatedByName')) {
      existing.productionUpdatedByName =
          updates['productionUpdatedByName'] as String?;
    }
    if (updates.containsKey('isDeleted')) {
      existing.isDeleted = updates['isDeleted'] as bool;
    }
    existing.updatedAt = DateTime.now();

    await dbService.db.writeTxn(() async {
      await dbService.routeOrders.put(existing);
    });
  }

  List<RouteOrder> _mapDocsToOrders(
    List<firestore.QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final orders = docs.where((doc) => doc.data()['isDeleted'] != true).map((
      doc,
    ) {
      final data = doc.data();
      return RouteOrder.fromJson({...data, 'id': data['id'] ?? doc.id});
    }).toList();
    orders.sort((a, b) => b.createdDateTime.compareTo(a.createdDateTime));
    return orders;
  }

  Future<RouteOrder?> getOrderById(String orderId) async {
    try {
      final normalizedId = orderId.trim();
      if (normalizedId.isEmpty) return null;

      final existing = await dbService.routeOrders
          .filter()
          .idEqualTo(normalizedId)
          .findFirst();
      if (existing != null) {
        if (existing.isDeleted) return null;
        return existing.toDomain();
      }

      final firestore = db;
      if (firestore == null) return null;

      final doc = await firestore
          .collection(routeOrdersCollection)
          .doc(normalizedId)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      if (data['isDeleted'] == true) return null;

      final order = RouteOrder.fromJson({...data, 'id': doc.id});
      await _cacheOrder(order);
      return order;
    } catch (e) {
      throw handleError(e, 'getOrderById');
    }
  }

  Future<List<RouteOrder>> getOrders({
    String? routeId,
    String? salesmanId,
    RouteOrderProductionStatus? productionStatus,
    RouteOrderDispatchStatus? dispatchStatus,
    int limit = 200,
  }) async {
    try {
      final localOrders = await _loadLocalOrders();
      if (localOrders.isNotEmpty) {
        final normalizedRouteId = routeId?.trim();
        final normalizedSalesmanId = salesmanId?.trim();
        final filtered = localOrders.where((order) {
          if (normalizedRouteId != null &&
              normalizedRouteId.isNotEmpty &&
              order.routeId != normalizedRouteId) {
            return false;
          }
          if (normalizedSalesmanId != null &&
              normalizedSalesmanId.isNotEmpty &&
              order.salesmanId != normalizedSalesmanId) {
            return false;
          }
          if (productionStatus != null &&
              order.productionStatus != productionStatus) {
            return false;
          }
          if (dispatchStatus != null &&
              order.dispatchStatus != dispatchStatus) {
            return false;
          }
          return true;
        }).toList();
        if (filtered.length > limit) {
          return filtered.sublist(0, limit);
        }
        return filtered;
      }

      if (localOrders.isEmpty && db != null) {
        final firestore = db;
        if (firestore != null) {
          final query = _buildQuery(
            routeId: routeId,
            salesmanId: salesmanId,
            productionStatus: productionStatus,
            dispatchStatus: dispatchStatus,
            limit: limit,
          );
          final snapshot = await query.get();
          final mapped = _mapDocsToOrders(snapshot.docs);
          await _cacheOrders(mapped);
          return mapped;
        }
      }
      return localOrders;
    } catch (e) {
      throw handleError(e, 'getOrders');
    }
  }

  Stream<List<RouteOrder>> watchOrders({
    String? routeId,
    String? salesmanId,
    RouteOrderProductionStatus? productionStatus,
    RouteOrderDispatchStatus? dispatchStatus,
    int limit = 200,
  }) async* {
    final firebaseAuth = auth;

    Stream<List<RouteOrder>> buildLocalStream() async* {
      Future<List<RouteOrder>> fetchFilteredOrders() async {
        return getOrders(
          routeId: routeId,
          salesmanId: salesmanId,
          productionStatus: productionStatus,
          dispatchStatus: dispatchStatus,
          limit: limit,
        );
      }

      // Yield initial state
      yield await fetchFilteredOrders();

      // Yield subsequent updates from local database changes
      yield* dbService.routeOrders.watchLazy().asyncMap((_) async {
        return fetchFilteredOrders();
      });
    }

    if (_avoidAuthStateStreamsOnWindows) {
      if (firebaseAuth?.currentUser == null) {
        yield const <RouteOrder>[];
        return;
      }
      yield* buildLocalStream();
      return;
    }

    if (firebaseAuth == null) {
      yield const <RouteOrder>[];
      return;
    }

    yield* firebaseAuth.authStateChanges().asyncExpand((authUser) {
      if (authUser == null) {
        return Stream.value(const <RouteOrder>[]);
      }
      return buildLocalStream();
    });
  }

  Future<String> createOrder({
    required String routeId,
    required String routeName,
    required String salesmanId,
    required String salesmanName,
    required String dealerId,
    required String dealerName,
    required String dispatchBeforeDate,
    required String createdByRole,
    RouteOrderSource? source,
    bool isOrderBasedDispatch = true,
    required List<RouteOrderItem> items,
    String? createdById,
    String? createdByName,
  }) async {
    try {
      final normalizedItems = items
          .where((item) => item.qty > 0)
          .map((item) => item.copyWith(subtotal: item.qty * item.price))
          .toList();
      if (normalizedItems.isEmpty) {
        throw ArgumentError('At least one valid item is required.');
      }
      if (routeId.trim().isEmpty || routeName.trim().isEmpty) {
        throw ArgumentError('Route is required.');
      }
      if (salesmanId.trim().isEmpty || salesmanName.trim().isEmpty) {
        throw ArgumentError('Salesman is required.');
      }

      final normalizedRole = _normalizeCreatedByRole(createdByRole);
      final resolvedSource = _resolveSource(
        createdByRole: normalizedRole,
        sourceOverride: source,
      );

      final parsedDispatchBeforeDate = DateTime.tryParse(dispatchBeforeDate);
      if (parsedDispatchBeforeDate == null) {
        throw ArgumentError('Dispatch before date is invalid.');
      }

      final normalizedDealerId = dealerId.trim();
      final normalizedDealerName = dealerName.trim();
      if (resolvedSource == RouteOrderSource.dealerManager &&
          (normalizedDealerId.isEmpty || normalizedDealerName.isEmpty)) {
        throw ArgumentError('Dealer is required for dealer manager orders.');
      }

      final now = DateTime.now();
      final nowIso = now.toIso8601String();
      final orderId = generateId();
      final orderNo = _buildOrderNo(orderId, now);
      final finalDealerId = normalizedDealerId.isEmpty
          ? '-'
          : normalizedDealerId;
      final finalDealerName = normalizedDealerName.isEmpty
          ? '-'
          : normalizedDealerName;

      final order = RouteOrder(
        id: orderId,
        orderNo: orderNo,
        routeId: routeId.trim(),
        routeName: routeName.trim(),
        salesmanId: salesmanId.trim(),
        salesmanName: salesmanName.trim(),
        dealerId: finalDealerId,
        dealerName: finalDealerName,
        createdByRole: normalizedRole,
        productionStatus: RouteOrderProductionStatus.pending,
        dispatchStatus: RouteOrderDispatchStatus.pending,
        source: resolvedSource,
        isOrderBasedDispatch: isOrderBasedDispatch,
        items: normalizedItems,
        dispatchBeforeDate: parsedDispatchBeforeDate.toIso8601String(),
        createdAt: nowIso,
        updatedAt: nowIso,
      );

      final payload = order.toJson()
        ..addAll({
          if (createdById != null && createdById.trim().isNotEmpty)
            'createdById': createdById.trim(),
          if (createdByName != null && createdByName.trim().isNotEmpty)
            'createdByName': createdByName.trim(),
          'createdAtEpoch': now.millisecondsSinceEpoch,
          'updatedAtEpoch': now.millisecondsSinceEpoch,
        });

      await _cacheOrder(order);
      await syncToFirebase(
        'set',
        payload,
        collectionName: routeOrdersCollection,
      );

      try {
        await _alertService.createAlert(
          title: 'New Route Order ${order.orderNo}',
          message:
              '${order.salesmanName} created order for ${order.routeName} (${order.totalItems} qty, Rs ${order.totalAmount.toStringAsFixed(0)}).',
          type: AlertType.other,
          severity: AlertSeverity.info,
          relatedId: order.id,
          // LOCKED: route-order create notification audience is strictly
          // production + store/admin roles only.
          targetRoles: AlertService.routeOrderNotificationTargetRoles,
          metadata: {
            AlertService.routeOrderEventTypeKey:
                AlertService.routeOrderCreatedEvent,
            'orderId': order.id,
            'orderNo': order.orderNo,
            'routeId': order.routeId,
            'routeName': order.routeName,
            'salesmanId': order.salesmanId,
            'salesmanName': order.salesmanName,
            'dealerId': order.dealerId,
            'dealerName': order.dealerName,
            'totalAmount': order.totalAmount,
            'totalQty': order.totalItems,
            'source': order.source.value,
            'createdByRole': normalizedRole,
          },
        );
      } catch (alertError) {
        AppLogger.warning(
          'Route order alert emit failed: $alertError',
          tag: 'RouteOrder',
        );
        AppLogger.warning(
          'Route order notification_events fallback skipped: notification_events are pull-only.',
          tag: 'RouteOrder',
        );
      }

      return order.id;
    } catch (e) {
      throw handleError(e, 'createOrder');
    }
  }

  Future<void> updateProductionStatus({
    required String orderId,
    required RouteOrderProductionStatus status,
    required String updatedById,
    required String updatedByName,
  }) async {
    try {
      final now = DateTime.now();
      final payload = {
        'id': orderId,
        'productionStatus': status.value,
        'productionUpdatedAt': now.toIso8601String(),
        'productionUpdatedById': updatedById,
        'productionUpdatedByName': updatedByName,
        'updatedAt': now.toIso8601String(),
        'updatedAtEpoch': now.millisecondsSinceEpoch,
      };

      await _applyLocalUpdate(orderId, payload);
      await syncToFirebase(
        'update',
        payload,
        collectionName: routeOrdersCollection,
      );

      // LOCKED: Route-order creation notifications must close once production
      // status advances from pending.
      if (status != RouteOrderProductionStatus.pending) {
        await _alertService.resolveRouteOrderAlerts(orderId: orderId);
      }
    } catch (e) {
      throw handleError(e, 'updateProductionStatus');
    }
  }

  Future<void> updateOrderBeforeDispatch({
    required String orderId,
    required List<RouteOrderItem> items,
    required String updatedById,
    required String updatedByName,
    String? dispatchBeforeDate,
  }) async {
    try {
      final normalizedOrderId = orderId.trim();
      if (normalizedOrderId.isEmpty) {
        throw ArgumentError('Order id is required.');
      }

      final normalizedItems = items
          .where((item) => item.qty > 0 && item.productId.trim().isNotEmpty)
          .map((item) => item.copyWith(subtotal: item.qty * item.price))
          .toList();
      if (normalizedItems.isEmpty) {
        throw ArgumentError('At least one valid item is required.');
      }

      final existingOrder = await getOrderById(normalizedOrderId);
      if (existingOrder == null) {
        throw StateError('Order not found.');
      }
      if (existingOrder.dispatchStatus != RouteOrderDispatchStatus.pending) {
        throw StateError(
          'Order ${existingOrder.orderNo} is ${existingOrder.dispatchStatus.value} and cannot be edited.',
        );
      }

      final now = DateTime.now();
      final payload = <String, dynamic>{
        'id': normalizedOrderId,
        'items': normalizedItems.map((item) => item.toJson()).toList(),
        'updatedAt': now.toIso8601String(),
        'updatedAtEpoch': now.millisecondsSinceEpoch,
        'lastEditedById': updatedById.trim(),
        'lastEditedByName': updatedByName.trim(),
        'lastEditedAt': now.toIso8601String(),
      };

      final normalizedDispatchBeforeDate = dispatchBeforeDate?.trim();
      if (normalizedDispatchBeforeDate != null &&
          normalizedDispatchBeforeDate.isNotEmpty) {
        payload['dispatchBeforeDate'] = normalizedDispatchBeforeDate;
      }

      await _applyLocalUpdate(normalizedOrderId, payload);
      await syncToFirebase(
        'update',
        payload,
        collectionName: routeOrdersCollection,
      );
    } catch (e) {
      throw handleError(e, 'updateOrderBeforeDispatch');
    }
  }

  Future<void> cancelOrderBeforeDispatch({
    required String orderId,
    required String cancelledById,
    required String cancelledByName,
    String? reason,
  }) async {
    try {
      final normalizedOrderId = orderId.trim();
      if (normalizedOrderId.isEmpty) {
        throw ArgumentError('Order id is required.');
      }

      final existingOrder = await getOrderById(normalizedOrderId);
      if (existingOrder == null) {
        throw StateError('Order not found.');
      }
      if (existingOrder.dispatchStatus == RouteOrderDispatchStatus.dispatched) {
        throw StateError(
          'Order ${existingOrder.orderNo} is already dispatched.',
        );
      }
      if (existingOrder.dispatchStatus == RouteOrderDispatchStatus.cancelled) {
        return;
      }

      final now = DateTime.now();
      final payload = <String, dynamic>{
        'id': normalizedOrderId,
        'dispatchStatus': RouteOrderDispatchStatus.cancelled.value,
        'cancelledAt': now.toIso8601String(),
        'cancelledById': cancelledById.trim(),
        'cancelledByName': cancelledByName.trim(),
        'updatedAt': now.toIso8601String(),
        'updatedAtEpoch': now.millisecondsSinceEpoch,
      };

      final normalizedReason = reason?.trim();
      if (normalizedReason != null && normalizedReason.isNotEmpty) {
        payload['cancelReason'] = normalizedReason;
      }

      await _applyLocalUpdate(normalizedOrderId, payload);
      await syncToFirebase(
        'update',
        payload,
        collectionName: routeOrdersCollection,
      );

      // LOCKED: cancelled orders should not stay in active route-order alerts.
      await _alertService.resolveRouteOrderAlerts(orderId: normalizedOrderId);
    } catch (e) {
      throw handleError(e, 'cancelOrderBeforeDispatch');
    }
  }

  Future<void> deleteOrderBeforeDispatch({
    required String orderId,
    required String deletedById,
    required String deletedByName,
  }) async {
    try {
      final normalizedOrderId = orderId.trim();
      if (normalizedOrderId.isEmpty) {
        throw ArgumentError('Order id is required.');
      }

      final existingOrder = await getOrderById(normalizedOrderId);
      if (existingOrder == null) {
        throw StateError('Order not found.');
      }
      if (existingOrder.dispatchStatus == RouteOrderDispatchStatus.dispatched) {
        throw StateError(
          'Order ${existingOrder.orderNo} is already dispatched.',
        );
      }

      final now = DateTime.now();
      final payload = {
        'id': normalizedOrderId,
        'isDeleted': true,
        'deletedAt': now.toIso8601String(),
        'deletedById': deletedById.trim(),
        'deletedByName': deletedByName.trim(),
        'updatedAt': now.toIso8601String(),
        'updatedAtEpoch': now.millisecondsSinceEpoch,
      };

      await _applyLocalUpdate(normalizedOrderId, payload);
      await syncToFirebase(
        'update',
        payload,
        collectionName: routeOrdersCollection,
      );

      // LOCKED: deleted orders should disappear from route-order alerts.
      await _alertService.resolveRouteOrderAlerts(orderId: normalizedOrderId);
    } catch (e) {
      throw handleError(e, 'deleteOrderBeforeDispatch');
    }
  }

  Future<void> markOrderDispatched({
    required String orderId,
    required String dispatchId,
    required String dispatchedById,
    required String dispatchedByName,
  }) async {
    try {
      final normalizedOrderId = orderId.trim();
      if (normalizedOrderId.isEmpty) {
        throw ArgumentError('Order id is required.');
      }

      final existingOrder = await getOrderById(normalizedOrderId);
      if (existingOrder == null) {
        throw StateError('Order not found.');
      }
      if (existingOrder.dispatchStatus == RouteOrderDispatchStatus.dispatched) {
        return;
      }
      if (existingOrder.dispatchStatus == RouteOrderDispatchStatus.cancelled) {
        throw StateError('Order ${existingOrder.orderNo} is cancelled.');
      }

      final now = DateTime.now();
      final payload = {
        'id': normalizedOrderId,
        'dispatchStatus': RouteOrderDispatchStatus.dispatched.value,
        'dispatchId': dispatchId.trim(),
        'dispatchedAt': now.toIso8601String(),
        'dispatchedById': dispatchedById.trim(),
        'dispatchedByName': dispatchedByName.trim(),
        'updatedAt': now.toIso8601String(),
        'updatedAtEpoch': now.millisecondsSinceEpoch,
      };

      await _applyLocalUpdate(normalizedOrderId, payload);
      await syncToFirebase(
        'update',
        payload,
        collectionName: routeOrdersCollection,
      );

      // LOCKED: dispatched orders are resolved and must not remain in alerts.
      await _alertService.resolveRouteOrderAlerts(orderId: normalizedOrderId);
    } catch (e) {
      throw handleError(e, 'markOrderDispatched');
    }
  }

  Future<String> dispatchOrder({
    required RouteOrder order,
    required String vehicleId,
    required String vehicleNumber,
    required String dispatchedById,
    required String dispatchedByName,
  }) async {
    try {
      if (order.dispatchStatus == RouteOrderDispatchStatus.dispatched) {
        throw StateError('Order ${order.orderNo} is already dispatched.');
      }
      if (order.dispatchStatus == RouteOrderDispatchStatus.cancelled) {
        throw StateError('Order ${order.orderNo} is cancelled.');
      }

      final allUsers = await _usersService.getUsers();
      AppUser? salesman;
      for (final user in allUsers) {
        if (user.id == order.salesmanId) {
          salesman = user;
          break;
        }
      }
      if (salesman == null) {
        throw StateError('Salesman not found for order ${order.orderNo}.');
      }

      final saleItems = <SaleItem>[];
      for (final item in order.items) {
        String baseUnit = item.baseUnit;
        if (baseUnit.trim().isEmpty) {
          final product = await _productsService.getProductById(item.productId);
          if (product != null && product.baseUnit.trim().isNotEmpty) {
            baseUnit = product.baseUnit;
          } else {
            baseUnit = 'Unit';
          }
        }

        saleItems.add(
          SaleItem(
            productId: item.productId,
            name: item.name,
            quantity: item.qty,
            price: item.price,
            baseUnit: baseUnit,
          ),
        );
      }

      final salesRoute =
          (salesman.assignedSalesRoute?.trim().isNotEmpty == true)
          ? salesman.assignedSalesRoute!.trim()
          : order.routeName;

      final dispatchId = await _inventoryService.dispatchToSalesman(
        salesman: salesman,
        vehicleId: vehicleId.trim(),
        vehicleNumber: vehicleNumber.trim(),
        dispatchRoute: order.routeName,
        salesRoute: salesRoute,
        items: saleItems,
        subtotal: order.totalAmount,
        totalAmount: order.totalAmount,
        userId: dispatchedById,
        userName: dispatchedByName,
        isOrderBasedDispatch: true,
        sourceOrderId: order.id,
        sourceOrderNo: order.orderNo,
        sourceDealerId: order.dealerId,
        sourceDealerName: order.dealerName,
        dispatchSource: 'order',
      );

      await markOrderDispatched(
        orderId: order.id,
        dispatchId: dispatchId,
        dispatchedById: dispatchedById,
        dispatchedByName: dispatchedByName,
      );

      return dispatchId;
    } catch (e, stack) {
      AppLogger.error(
        'dispatchOrder failed',
        error: e,
        stackTrace: stack,
        tag: 'RouteOrder',
      );
      throw handleError(e, 'dispatchOrder');
    }
  }
}
