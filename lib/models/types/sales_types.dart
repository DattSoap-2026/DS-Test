enum RecipientType { customer, dealer, salesman }

/// Sale status lifecycle (simplified - cash sales only)
/// Flow: created (order taken) → delivered (stock given) → completed (payment received)
enum SaleStatus {
  created('created'), // Order taken at shop
  delivered('delivered'), // Stock handed over on spot
  completed('completed'), // Payment received (cash)
  cancelled('cancelled'); // Order cancelled before delivery

  final String value;
  const SaleStatus(this.value);

  static SaleStatus fromString(String value) {
    return SaleStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SaleStatus.created,
    );
  }
}

/// State machine for sale status transitions
class SaleStateMachine {
  static const Map<SaleStatus, List<SaleStatus>> validTransitions = {
    SaleStatus.created: [
      SaleStatus.delivered, // Normal flow
      SaleStatus.cancelled, // Cancel before delivery
    ],
    SaleStatus.delivered: [
      SaleStatus.completed, // Payment received
    ],
    SaleStatus.completed: [], // Final state
    SaleStatus.cancelled: [], // Final state
  };

  /// Check if transition from one state to another is valid
  static bool canTransition(SaleStatus from, SaleStatus to) {
    return validTransitions[from]?.contains(to) ?? false;
  }

  /// Validate state transition, throws exception if invalid
  static void validateTransition(SaleStatus from, SaleStatus to) {
    if (!canTransition(from, to)) {
      final allowed =
          validTransitions[from]?.map((e) => e.value).join(', ') ?? 'none';
      throw Exception(
        'Invalid sale state transition: ${from.value} → ${to.value}\n'
        'Allowed transitions from ${from.value}: $allowed',
      );
    }
  }
}

enum SaleType { vanSale, directDealer, cashSale }

enum GstType { cgstSgst, igst, none }

class SaleItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final bool isFree;
  final double discount;
  final double? secondaryPrice;
  final double? conversionFactor;
  final String baseUnit;
  final String? secondaryUnit;
  final String? schemeName;
  final int returnedQuantity;
  final double? lineSubtotal;
  final double? lineItemDiscountAmount;
  final double? linePrimaryDiscountShare;
  final double? lineAdditionalDiscountShare;
  final double? lineNetAmount;
  final double? lineTaxAmount;
  final double? lineTotalAmount;

  /// AUDIT LOCK: Records the exact base-unit quantity deducted at time of sale.
  /// Immutable once set — never recalculated from conversionFactor.
  /// If secondaryUnit input mode is added in future, this is the source of truth.
  final int finalBaseQuantity;

  SaleItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.isFree = false,
    this.discount = 0,
    this.secondaryPrice,
    this.conversionFactor,
    required this.baseUnit,
    this.secondaryUnit,
    this.schemeName,
    this.returnedQuantity = 0,
    this.lineSubtotal,
    this.lineItemDiscountAmount,
    this.linePrimaryDiscountShare,
    this.lineAdditionalDiscountShare,
    this.lineNetAmount,
    this.lineTaxAmount,
    this.lineTotalAmount,
    int? finalBaseQuantity,
  }) : finalBaseQuantity = finalBaseQuantity ?? quantity;

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      isFree: json['isFree'] ?? false,
      discount: (json['discount'] ?? 0).toDouble(),
      secondaryPrice: json['secondaryPrice']?.toDouble(),
      conversionFactor: json['conversionFactor']?.toDouble(),
      baseUnit: json['baseUnit'] ?? '',
      secondaryUnit: json['secondaryUnit'],
      schemeName: json['schemeName'],
      returnedQuantity: json['returnedQuantity'] ?? 0,
      lineSubtotal: json['lineSubtotal']?.toDouble(),
      lineItemDiscountAmount: json['lineItemDiscountAmount']?.toDouble(),
      linePrimaryDiscountShare: json['linePrimaryDiscountShare']?.toDouble(),
      lineAdditionalDiscountShare:
          json['lineAdditionalDiscountShare']?.toDouble(),
      lineNetAmount: json['lineNetAmount']?.toDouble(),
      lineTaxAmount: json['lineTaxAmount']?.toDouble(),
      lineTotalAmount: json['lineTotalAmount']?.toDouble(),
      finalBaseQuantity: (json['finalBaseQuantity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'isFree': isFree,
      'discount': discount,
      'secondaryPrice': secondaryPrice,
      'conversionFactor': conversionFactor,
      'baseUnit': baseUnit,
      'secondaryUnit': secondaryUnit,
      'schemeName': schemeName,
      'returnedQuantity': returnedQuantity,
      if (lineSubtotal != null) 'lineSubtotal': lineSubtotal,
      if (lineItemDiscountAmount != null)
        'lineItemDiscountAmount': lineItemDiscountAmount,
      if (linePrimaryDiscountShare != null)
        'linePrimaryDiscountShare': linePrimaryDiscountShare,
      if (lineAdditionalDiscountShare != null)
        'lineAdditionalDiscountShare': lineAdditionalDiscountShare,
      if (lineNetAmount != null) 'lineNetAmount': lineNetAmount,
      if (lineTaxAmount != null) 'lineTaxAmount': lineTaxAmount,
      if (lineTotalAmount != null) 'lineTotalAmount': lineTotalAmount,
      'finalBaseQuantity': finalBaseQuantity,
    };
  }
}

class SaleItemForUI extends SaleItem {
  final int stock;
  final int? salesmanStock;
  final double? simpleSchemeBuy;
  final double? simpleSchemeGet;

  SaleItemForUI({
    required super.productId,
    required super.name,
    required super.quantity,
    required super.price,
    super.isFree,
    super.discount,
    super.secondaryPrice,
    super.conversionFactor,
    required super.baseUnit,
    super.secondaryUnit,
    super.schemeName,
    super.returnedQuantity,
    required this.stock,
    this.salesmanStock,
    this.simpleSchemeBuy,
    this.simpleSchemeGet,
  });

  factory SaleItemForUI.fromJson(Map<String, dynamic> json) {
    return SaleItemForUI(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : (json['quantity'] ?? 0).toInt(),
      price: (json['price'] ?? 0).toDouble(),
      isFree: json['isFree'] as bool? ?? false,
      discount: (json['discount'] ?? 0).toDouble(),
      secondaryPrice: json['secondaryPrice']?.toDouble(),
      baseUnit: json['baseUnit'] ?? '',
      conversionFactor: json['conversionFactor']?.toDouble(),
      secondaryUnit: json['secondaryUnit'],
      stock: json['stock'] is int
          ? json['stock'] as int
          : (json['stock'] ?? 0).toInt(),
      salesmanStock: json['salesmanStock'] as int?,
      simpleSchemeBuy: json['simpleSchemeBuy']?.toDouble(),
      simpleSchemeGet: json['simpleSchemeGet']?.toDouble(),
      schemeName: json['schemeName'],
    );
  }
}

class CartItem extends SaleItemForUI {
  CartItem({
    required super.productId,
    required super.name,
    required super.quantity,
    required super.price,
    super.isFree,
    super.discount,
    super.secondaryPrice,
    super.conversionFactor,
    required super.baseUnit,
    super.secondaryUnit,
    required super.stock,
    super.salesmanStock,
    super.simpleSchemeBuy,
    super.simpleSchemeGet,
    super.schemeName,
  });

  SaleItemForUI toSaleItemForUI() {
    return SaleItemForUI(
      productId: productId,
      name: name,
      quantity: quantity,
      price: price,
      isFree: isFree,
      discount: discount,
      secondaryPrice: secondaryPrice,
      conversionFactor: conversionFactor,
      baseUnit: baseUnit,
      secondaryUnit: secondaryUnit,
      schemeName: schemeName,
      stock: stock,
      salesmanStock: salesmanStock,
      simpleSchemeBuy: simpleSchemeBuy,
      simpleSchemeGet: simpleSchemeGet,
    );
  }

  SaleItem toSaleItem() {
    return SaleItem(
      productId: productId,
      name: name,
      quantity: quantity,
      price: price,
      isFree: isFree,
      discount: discount,
      secondaryPrice: secondaryPrice,
      conversionFactor: conversionFactor,
      baseUnit: baseUnit,
      secondaryUnit: secondaryUnit,
      schemeName: schemeName,
      returnedQuantity: 0,
    );
  }

  CartItem copyWith({
    String? productId,
    String? name,
    int? quantity,
    double? price,
    bool? isFree,
    double? discount,
    double? secondaryPrice,
    double? conversionFactor,
    String? baseUnit,
    String? secondaryUnit,
    int? stock,
    int? salesmanStock,
    double? simpleSchemeBuy,
    double? simpleSchemeGet,
    String? schemeName,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      discount: discount ?? this.discount,
      secondaryPrice: secondaryPrice ?? this.secondaryPrice,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      baseUnit: baseUnit ?? this.baseUnit,
      secondaryUnit: secondaryUnit ?? this.secondaryUnit,
      stock: stock ?? this.stock,
      salesmanStock: salesmanStock ?? this.salesmanStock,
      simpleSchemeBuy: simpleSchemeBuy ?? this.simpleSchemeBuy,
      simpleSchemeGet: simpleSchemeGet ?? this.simpleSchemeGet,
      schemeName: schemeName ?? this.schemeName,
    );
  }
}

class Sale {
  final String id;
  final String? humanReadableId;
  final String recipientType;
  final String recipientId;
  final String recipientName;
  final List<SaleItem> items;
  final List<String> itemProductIds;
  final double subtotal;
  final double itemDiscountAmount;
  final double discountPercentage;
  final double discountAmount;
  final double? additionalDiscountPercentage;
  final double? additionalDiscountAmount;
  final double taxableAmount;
  final String gstType;
  final double gstPercentage;
  final double? cgstAmount;
  final double? sgstAmount;
  final double? igstAmount;
  final double totalAmount;
  final double? roundOff;
  final String? tripId;
  final String? saleType;
  final String? createdByRole;
  final String? status;
  final bool? dispatchRequired;
  final String? vehicleNumber;
  final String? driverName;
  final String? route;
  final String? dispatchRoute;
  final String? salesRoute;
  final String salesmanId;
  final String salesmanName;
  final String createdAt;
  final double paidAmount;
  final String paymentStatus; // 'pending', 'partial', 'paid'
  final int month;
  final int year;
  // Commission Snapshot
  final double? commissionAmount;
  final String? commissionType;
  // Cancellation Fields
  String? cancelReason;
  String? cancelledBy;
  String? cancelledAt; // ISO timestamp

  Sale({
    required this.id,
    this.humanReadableId,
    required this.recipientType,
    required this.recipientId,
    required this.recipientName,
    required this.items,
    required this.itemProductIds,
    required this.subtotal,
    this.itemDiscountAmount = 0.0,
    required this.discountPercentage,
    required this.discountAmount,
    this.additionalDiscountPercentage,
    this.additionalDiscountAmount,
    required this.taxableAmount,
    required this.gstType,
    required this.gstPercentage,
    this.cgstAmount,
    this.sgstAmount,
    this.igstAmount,
    required this.totalAmount,
    this.roundOff,
    this.tripId,
    this.saleType,
    this.createdByRole,
    this.status,
    this.dispatchRequired,
    this.vehicleNumber,
    this.driverName,
    this.route,
    this.dispatchRoute,
    this.salesRoute,
    required this.salesmanId,
    required this.salesmanName,
    required this.createdAt,
    this.paidAmount = 0.0,
    this.paymentStatus = 'pending',
    required this.month,
    required this.year,
    this.commissionAmount,
    this.commissionType,
    this.cancelReason,
    this.cancelledBy,
    this.cancelledAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] ?? '',
      humanReadableId: json['humanReadableId'],
      recipientType: json['recipientType'] ?? 'customer',
      recipientId: json['recipientId'] ?? '',
      recipientName: json['recipientName'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => SaleItem.fromJson(e))
          .toList(),
      itemProductIds: (json['itemProductIds'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      itemDiscountAmount: (json['itemDiscountAmount'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      additionalDiscountPercentage: json['additionalDiscountPercentage']
          ?.toDouble(),
      additionalDiscountAmount: json['additionalDiscountAmount']?.toDouble(),
      taxableAmount: (json['taxableAmount'] ?? 0).toDouble(),
      gstType: json['gstType'] ?? 'none',
      gstPercentage: (json['gstPercentage'] ?? 0).toDouble(),
      cgstAmount: json['cgstAmount']?.toDouble(),
      sgstAmount: json['sgstAmount']?.toDouble(),
      igstAmount: json['igstAmount']?.toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      roundOff: json['roundOff']?.toDouble(),
      tripId: json['tripId'],
      saleType: json['saleType'],
      createdByRole: json['createdByRole'],
      status: json['status'],
      dispatchRequired: json['dispatchRequired'],
      vehicleNumber: json['vehicleNumber'],
      driverName: json['driverName'],
      route: json['route'],
      dispatchRoute: json['dispatchRoute'],
      salesRoute: json['salesRoute'],
      salesmanId: json['salesmanId'] ?? '',
      salesmanName: json['salesmanName'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      commissionType: json['commissionType'] as String?,
      cancelReason: json['cancelReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'humanReadableId': humanReadableId,
      'recipientType': recipientType,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'items': items.map((item) => item.toJson()).toList(),
      'itemProductIds': itemProductIds,
      'subtotal': subtotal,
      'itemDiscountAmount': itemDiscountAmount,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'additionalDiscountPercentage': additionalDiscountPercentage,
      'additionalDiscountAmount': additionalDiscountAmount,
      'taxableAmount': taxableAmount,
      'gstType': gstType,
      'gstPercentage': gstPercentage,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'totalAmount': totalAmount,
      'roundOff': roundOff,
      'tripId': tripId,
      'saleType': saleType,
      'createdByRole': createdByRole,
      'status': status,
      'dispatchRequired': dispatchRequired,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'route': route, // Legacy support
      'dispatchRoute': dispatchRoute,
      'salesRoute': salesRoute,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'createdAt': createdAt,
      'paidAmount': paidAmount,
      'paymentStatus': paymentStatus,
      'month': month,
      'year': year,
      if (commissionAmount != null) 'commissionAmount': commissionAmount,
      if (commissionType != null) 'commissionType': commissionType,
      if (cancelReason != null) 'cancelReason': cancelReason,
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      if (cancelledAt != null) 'cancelledAt': cancelledAt,
    };
  }
}
