enum RouteOrderProductionStatus {
  pending('pending'),
  ready('ready');

  final String value;
  const RouteOrderProductionStatus(this.value);

  static RouteOrderProductionStatus fromString(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return RouteOrderProductionStatus.values.firstWhere(
      (status) => status.value == normalized,
      orElse: () => RouteOrderProductionStatus.pending,
    );
  }
}

enum RouteOrderDispatchStatus {
  pending('pending'),
  dispatched('dispatched'),
  cancelled('cancelled');

  final String value;
  const RouteOrderDispatchStatus(this.value);

  static RouteOrderDispatchStatus fromString(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return RouteOrderDispatchStatus.values.firstWhere(
      (status) => status.value == normalized,
      orElse: () => RouteOrderDispatchStatus.pending,
    );
  }
}

enum RouteOrderSource {
  salesman('salesman'),
  dealerManager('dealerManager');

  final String value;
  const RouteOrderSource(this.value);

  static RouteOrderSource fromString(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return RouteOrderSource.values.firstWhere(
      (source) => source.value.toLowerCase() == normalized,
      orElse: () => RouteOrderSource.salesman,
    );
  }
}

class RouteOrderItem {
  final String productId;
  final String name;
  final int qty;
  final double price;
  final double subtotal;
  final String baseUnit;

  const RouteOrderItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.subtotal,
    required this.baseUnit,
  });

  factory RouteOrderItem.fromJson(Map<String, dynamic> json) {
    final qty = (json['qty'] as num?)?.toInt() ?? 0;
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final subtotal = (json['subtotal'] as num?)?.toDouble() ?? (qty * price);
    return RouteOrderItem(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      qty: qty,
      price: price,
      subtotal: subtotal,
      baseUnit: (json['baseUnit'] ?? 'Unit').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'qty': qty,
      'price': price,
      'subtotal': subtotal,
      'baseUnit': baseUnit,
    };
  }

  RouteOrderItem copyWith({
    String? productId,
    String? name,
    int? qty,
    double? price,
    double? subtotal,
    String? baseUnit,
  }) {
    final nextQty = qty ?? this.qty;
    final nextPrice = price ?? this.price;
    return RouteOrderItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      qty: nextQty,
      price: nextPrice,
      subtotal: subtotal ?? (nextQty * nextPrice),
      baseUnit: baseUnit ?? this.baseUnit,
    );
  }
}

class RouteOrder {
  final String id;
  final String orderNo;
  final String routeId;
  final String routeName;
  final String salesmanId;
  final String salesmanName;
  final String dealerId;
  final String dealerName;
  final String createdByRole;
  final RouteOrderProductionStatus productionStatus;
  final RouteOrderDispatchStatus dispatchStatus;
  final RouteOrderSource source;
  final bool isOrderBasedDispatch;
  final List<RouteOrderItem> items;
  final String? dispatchBeforeDate;
  final String createdAt;
  final String updatedAt;
  final String? dispatchId;
  final String? dispatchedAt;
  final String? dispatchedById;
  final String? dispatchedByName;
  final String? createdById;
  final String? createdByName;
  final String? productionUpdatedAt;
  final String? productionUpdatedById;
  final String? productionUpdatedByName;

  const RouteOrder({
    required this.id,
    required this.orderNo,
    required this.routeId,
    required this.routeName,
    required this.salesmanId,
    required this.salesmanName,
    required this.dealerId,
    required this.dealerName,
    required this.createdByRole,
    required this.productionStatus,
    required this.dispatchStatus,
    required this.source,
    required this.isOrderBasedDispatch,
    required this.items,
    this.dispatchBeforeDate,
    required this.createdAt,
    required this.updatedAt,
    this.dispatchId,
    this.dispatchedAt,
    this.dispatchedById,
    this.dispatchedByName,
    this.createdById,
    this.createdByName,
    this.productionUpdatedAt,
    this.productionUpdatedById,
    this.productionUpdatedByName,
  });

  factory RouteOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .whereType<Map>()
        .map((item) => RouteOrderItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return RouteOrder(
      id: (json['id'] ?? '').toString(),
      orderNo: (json['orderNo'] ?? '').toString(),
      routeId: (json['routeId'] ?? '').toString(),
      routeName: (json['routeName'] ?? '').toString(),
      salesmanId: (json['salesmanId'] ?? '').toString(),
      salesmanName: (json['salesmanName'] ?? '').toString(),
      dealerId: (json['dealerId'] ?? '').toString(),
      dealerName: (json['dealerName'] ?? '').toString(),
      createdByRole: (json['createdByRole'] ?? '').toString(),
      productionStatus: RouteOrderProductionStatus.fromString(
        json['productionStatus']?.toString(),
      ),
      dispatchStatus: RouteOrderDispatchStatus.fromString(
        json['dispatchStatus']?.toString(),
      ),
      source: RouteOrderSource.fromString(json['source']?.toString()),
      isOrderBasedDispatch: json['isOrderBasedDispatch'] == true,
      items: items,
      dispatchBeforeDate: json['dispatchBeforeDate']?.toString(),
      createdAt:
          (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt:
          (json['updatedAt'] ?? DateTime.now().toIso8601String()).toString(),
      dispatchId: json['dispatchId']?.toString(),
      dispatchedAt: json['dispatchedAt']?.toString(),
      dispatchedById: json['dispatchedById']?.toString(),
      dispatchedByName: json['dispatchedByName']?.toString(),
      createdById: json['createdById']?.toString(),
      createdByName: json['createdByName']?.toString(),
      productionUpdatedAt: json['productionUpdatedAt']?.toString(),
      productionUpdatedById: json['productionUpdatedById']?.toString(),
      productionUpdatedByName: json['productionUpdatedByName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'routeId': routeId,
      'routeName': routeName,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'createdByRole': createdByRole,
      'productionStatus': productionStatus.value,
      'dispatchStatus': dispatchStatus.value,
      'source': source.value,
      'isOrderBasedDispatch': isOrderBasedDispatch,
      'items': items.map((item) => item.toJson()).toList(),
      if (dispatchBeforeDate != null) 'dispatchBeforeDate': dispatchBeforeDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (dispatchId != null) 'dispatchId': dispatchId,
      if (dispatchedAt != null) 'dispatchedAt': dispatchedAt,
      if (dispatchedById != null) 'dispatchedById': dispatchedById,
      if (dispatchedByName != null) 'dispatchedByName': dispatchedByName,
      if (createdById != null) 'createdById': createdById,
      if (createdByName != null) 'createdByName': createdByName,
      if (productionUpdatedAt != null) 'productionUpdatedAt': productionUpdatedAt,
      if (productionUpdatedById != null)
        'productionUpdatedById': productionUpdatedById,
      if (productionUpdatedByName != null)
        'productionUpdatedByName': productionUpdatedByName,
    };
  }

  DateTime get createdDateTime =>
      DateTime.tryParse(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);

  DateTime get updatedDateTime =>
      DateTime.tryParse(updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0);

  DateTime? get dispatchBeforeDateTime =>
      dispatchBeforeDate == null ? null : DateTime.tryParse(dispatchBeforeDate!);

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.qty);

  double get totalAmount =>
      items.fold<double>(0, (sum, item) => sum + item.subtotal);

  bool get isDispatched => dispatchStatus == RouteOrderDispatchStatus.dispatched;

  bool get isCancelled => dispatchStatus == RouteOrderDispatchStatus.cancelled;

  RouteOrder copyWith({
    String? id,
    String? orderNo,
    String? routeId,
    String? routeName,
    String? salesmanId,
    String? salesmanName,
    String? dealerId,
    String? dealerName,
    String? createdByRole,
    RouteOrderProductionStatus? productionStatus,
    RouteOrderDispatchStatus? dispatchStatus,
    RouteOrderSource? source,
    bool? isOrderBasedDispatch,
    List<RouteOrderItem>? items,
    String? dispatchBeforeDate,
    String? createdAt,
    String? updatedAt,
    String? dispatchId,
    String? dispatchedAt,
    String? dispatchedById,
    String? dispatchedByName,
    String? createdById,
    String? createdByName,
    String? productionUpdatedAt,
    String? productionUpdatedById,
    String? productionUpdatedByName,
  }) {
    return RouteOrder(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      salesmanId: salesmanId ?? this.salesmanId,
      salesmanName: salesmanName ?? this.salesmanName,
      dealerId: dealerId ?? this.dealerId,
      dealerName: dealerName ?? this.dealerName,
      createdByRole: createdByRole ?? this.createdByRole,
      productionStatus: productionStatus ?? this.productionStatus,
      dispatchStatus: dispatchStatus ?? this.dispatchStatus,
      source: source ?? this.source,
      isOrderBasedDispatch: isOrderBasedDispatch ?? this.isOrderBasedDispatch,
      items: items ?? this.items,
      dispatchBeforeDate: dispatchBeforeDate ?? this.dispatchBeforeDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dispatchId: dispatchId ?? this.dispatchId,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      dispatchedById: dispatchedById ?? this.dispatchedById,
      dispatchedByName: dispatchedByName ?? this.dispatchedByName,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      productionUpdatedAt: productionUpdatedAt ?? this.productionUpdatedAt,
      productionUpdatedById: productionUpdatedById ?? this.productionUpdatedById,
      productionUpdatedByName:
          productionUpdatedByName ?? this.productionUpdatedByName,
    );
  }
}

class RouteOrderDispatchPayload {
  final String routeOrderId;
  final String routeOrderNo;
  final RouteOrderSource source;
  final String routeId;
  final String routeName;
  final String salesmanId;
  final String salesmanName;
  final String dealerId;
  final String dealerName;
  final String vehicleId;
  final String vehicleNumber;
  final List<RouteOrderItem> items;
  final String? dispatchBeforeDate;

  const RouteOrderDispatchPayload({
    required this.routeOrderId,
    required this.routeOrderNo,
    required this.source,
    required this.routeId,
    required this.routeName,
    required this.salesmanId,
    required this.salesmanName,
    required this.dealerId,
    required this.dealerName,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.items,
    this.dispatchBeforeDate,
  });

  factory RouteOrderDispatchPayload.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .whereType<Map>()
        .map((item) => RouteOrderItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return RouteOrderDispatchPayload(
      routeOrderId: (json['routeOrderId'] ?? '').toString(),
      routeOrderNo: (json['routeOrderNo'] ?? '').toString(),
      source: RouteOrderSource.fromString(json['source']?.toString()),
      routeId: (json['routeId'] ?? '').toString(),
      routeName: (json['routeName'] ?? '').toString(),
      salesmanId: (json['salesmanId'] ?? '').toString(),
      salesmanName: (json['salesmanName'] ?? '').toString(),
      dealerId: (json['dealerId'] ?? '').toString(),
      dealerName: (json['dealerName'] ?? '').toString(),
      vehicleId: (json['vehicleId'] ?? '').toString(),
      vehicleNumber: (json['vehicleNumber'] ?? '').toString(),
      items: items,
      dispatchBeforeDate: json['dispatchBeforeDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeOrderId': routeOrderId,
      'routeOrderNo': routeOrderNo,
      'source': source.value,
      'routeId': routeId,
      'routeName': routeName,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'items': items.map((item) => item.toJson()).toList(),
      if (dispatchBeforeDate != null) 'dispatchBeforeDate': dispatchBeforeDate,
    };
  }
}
