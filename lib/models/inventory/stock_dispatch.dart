// Assuming this provides database access/abstractions if needed, otherwise standard import.
// Using standard imports for types if local entities are not strictly required for this DTO.

enum DispatchStatus { created, loaded, inTransit, received, closed }

class DispatchItem {
  final String productId;
  final String productName;
  final int quantity;
  final String unit;
  final double rate;
  final double amount;

  DispatchItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
  });

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    final name =
        (json['productName'] ?? json['name'] ?? json['product'] ?? '')
            .toString()
            .trim();
    final unit =
        (json['unit'] ??
                json['baseUnit'] ??
                json['uom'] ??
                json['secondaryUnit'])
            ?.toString() ??
        '';
    final quantity = (json['quantity'] as num?)?.toInt() ?? 0;
    final rate =
        (json['rate'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final amount =
        (json['amount'] as num?)?.toDouble() ?? (rate * quantity);
    return DispatchItem(
      productId: json['productId']?.toString() ?? '',
      productName: name.isNotEmpty ? name : 'Unknown',
      quantity: quantity,
      unit: unit,
      rate: rate,
      amount: amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'amount': amount,
    };
  }
}

class StockDispatch {
  final String id;
  final String dispatchId; // Human readable ID like DIS-2024-001
  final String salesmanId; // Reference to allocated_stock owner
  final String salesmanName;
  final String? storeId; // Originating store (optional)
  final String vehicleNumber;
  final String dispatchRoute;
  final String salesRoute;
  final List<DispatchItem> items;
  final DispatchStatus status;
  final int totalQuantity;
  final double totalAmount;
  final String source;
  final bool isOrderBasedDispatch;
  final String? orderId;
  final String? orderNo;
  final String? dealerId;
  final String? dealerName;
  final DateTime createdAt;
  final DateTime? receivedAt;

  StockDispatch({
    required this.id,
    required this.dispatchId,
    required this.salesmanId,
    required this.salesmanName,
    this.storeId,
    required this.vehicleNumber,
    required this.dispatchRoute,
    required this.salesRoute,
    required this.items,
    required this.status,
    required this.totalQuantity,
    required this.totalAmount,
    required this.source,
    required this.isOrderBasedDispatch,
    this.orderId,
    this.orderNo,
    this.dealerId,
    this.dealerName,
    required this.createdAt,
    this.receivedAt,
  });

  factory StockDispatch.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((e) => DispatchItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final totalQuantity =
        (json['totalQuantity'] as num?)?.toInt() ??
        items.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalAmount =
        (json['totalAmount'] as num?)?.toDouble() ??
        items.fold<double>(0, (sum, item) => sum + item.amount);
    final rawStatus = (json['status']?.toString().toLowerCase() ?? 'created')
        .trim();
    final normalizedStatus = rawStatus == 'completed'
        ? DispatchStatus.received.name
        : rawStatus;
    return StockDispatch(
      id: json['id']?.toString() ?? '',
      dispatchId: json['dispatchId']?.toString() ?? '',
      salesmanId: json['salesmanId']?.toString() ?? '',
      salesmanName: json['salesmanName']?.toString() ?? '',
      storeId: json['storeId']?.toString(),
      vehicleNumber: json['vehicleNumber']?.toString() ?? '',
      dispatchRoute:
          (json['dispatchRoute'] ?? json['route'] ?? '').toString().trim(),
      salesRoute:
          (json['salesRoute'] ?? json['dispatchRoute'] ?? '')
              .toString()
              .trim(),
      items: items,
      status: DispatchStatus.values.firstWhere(
        (e) =>
            e.name == normalizedStatus,
        orElse: () => DispatchStatus.created,
      ),
      totalQuantity: totalQuantity,
      totalAmount: totalAmount,
      source:
          (json['dispatchSource'] ?? json['source'] ?? 'direct')
              .toString()
              .trim(),
      isOrderBasedDispatch: json['isOrderBasedDispatch'] == true,
      orderId: json['orderId']?.toString(),
      orderNo: json['orderNo']?.toString(),
      dealerId: json['dealerId']?.toString(),
      dealerName: json['dealerName']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      receivedAt: json['receivedAt'] != null
          ? DateTime.tryParse(json['receivedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dispatchId': dispatchId,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      if (storeId != null) 'storeId': storeId,
      'vehicleNumber': vehicleNumber,
      'dispatchRoute': dispatchRoute,
      'salesRoute': salesRoute,
      'items': items.map((e) => e.toJson()).toList(),
      'status': status.name, // Storing as string 'created', 'received' etc.
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'dispatchSource': source,
      'isOrderBasedDispatch': isOrderBasedDispatch,
      if (orderId != null) 'orderId': orderId,
      if (orderNo != null) 'orderNo': orderNo,
      if (dealerId != null) 'dealerId': dealerId,
      if (dealerName != null) 'dealerName': dealerName,
      'createdAt': createdAt.toIso8601String(),
      if (receivedAt != null) 'receivedAt': receivedAt!.toIso8601String(),
    };
  }
}
