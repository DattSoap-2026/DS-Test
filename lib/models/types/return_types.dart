// Return status lifecycle (unsold stock workflow)
// Flow: created → approved → received → completed
enum ReturnStatus {
  created('created'), // Salesman submits unsold items
  approved('approved'), // Supervisor approves return
  rejected('rejected'), // Supervisor rejects (quality issues, etc.)
  received('received'), // Stock physically received at warehouse
  completed('completed'); // Stock restored to inventory

  final String value;
  const ReturnStatus(this.value);

  static ReturnStatus fromString(String value) {
    return ReturnStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReturnStatus.created,
    );
  }
}

// Disposition for Customer Returns
enum ReturnDisposition {
  goodStock('Good Stock'),
  badStock('Bad Stock'),
  expired('Expired'),
  damaged('Damaged');

  final String value;
  const ReturnDisposition(this.value);
}

class ReturnRequest {
  final String id;
  final String returnType; // 'stock_return' or 'sales_return'
  final String salesmanId;
  final String salesmanName;
  final List<ReturnItem> items;
  final String reason;
  final String? reasonCode;
  final String status; // 'pending', 'approved', 'rejected'
  final String? disposition; // 'Good Stock' or 'Bad Stock' (for sales_return)
  final String createdAt;
  final String updatedAt;
  final String? approvedBy;
  // New field for Customer Return link
  final String? customerId;
  final String? customerName;
  final String? originalSaleId;

  ReturnRequest({
    required this.id,
    required this.returnType,
    required this.salesmanId,
    required this.salesmanName,
    required this.items,
    required this.reason,
    this.reasonCode,
    required this.status,
    this.disposition,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.customerId,
    this.customerName,
    this.originalSaleId,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'] as String,
      returnType: json['returnType'] as String,
      salesmanId: json['salesmanId'] as String,
      salesmanName: json['salesmanName'] as String,
      items:
          (json['items'] as List?)
              ?.map((item) => ReturnItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      reason: json['reason'] as String,
      reasonCode: json['reasonCode'] as String?,
      status: json['status'] as String? ?? 'pending',
      disposition: json['disposition'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      approvedBy: json['approvedBy'] as String?,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      originalSaleId: json['originalSaleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'returnType': returnType,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'items': items.map((item) => item.toJson()).toList(),
      'itemProductIds': items
          .map((item) => item.productId)
          .toList(), // Helper for queries
      'reason': reason,
      if (reasonCode != null) 'reasonCode': reasonCode,
      'status': status,
      if (disposition != null) 'disposition': disposition,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (customerId != null) 'customerId': customerId,
      if (customerName != null) 'customerName': customerName,
      if (originalSaleId != null) 'originalSaleId': originalSaleId,
    };
  }
}

class ReturnItem {
  final String productId;
  final String name;
  final double quantity;
  final String unit;
  final double? price;

  ReturnItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.price,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      if (price != null) 'price': price,
    };
  }
}
