// Purchase Order Types for DattSoap
// Defines the data structure for procurement

/// Status of the purchase order lifecycle
enum PurchaseOrderStatus {
  draft('draft'),
  ordered('ordered'), // Placed with supplier
  partiallyReceived('partially_received'), // Partial stock received
  received('received'), // Stock physically received (fully)
  cancelled('cancelled');

  final String value;
  const PurchaseOrderStatus(this.value);

  static PurchaseOrderStatus fromString(String value) {
    return PurchaseOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PurchaseOrderStatus.draft,
    );
  }
}

/// Payment status for the PO
enum PurchaseOrderPaymentStatus {
  pending('pending'),
  partial('partial'),
  paid('paid');

  final String value;
  const PurchaseOrderPaymentStatus(this.value);

  static PurchaseOrderPaymentStatus fromString(String value) {
    return PurchaseOrderPaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PurchaseOrderPaymentStatus.pending,
    );
  }
}

/// Individual item in a Purchase Order
class PurchaseOrderItem {
  final String productId;
  final String name;
  final double quantity; // Quantity ordered
  final String unit; // Unit ordered (e.g., Box, Kg)
  final double unitPrice; // Cost per unit (Exclusive of GST)
  final double taxableAmount; // quantity * unitPrice - discount
  final double? discount; // Flat discount
  final double gstPercentage; // e.g., 18.0
  final double gstAmount; // taxableAmount * (gstPercentage / 100)
  final double total; // taxableAmount + gstAmount
  final double? receivedQuantity; // Quantity actually received
  final String? baseUnit; // Base unit for inventory conversion (e.g., Pcs)
  final double? conversionFactor; // To convert ordering unit to base unit

  PurchaseOrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.taxableAmount,
    this.discount,
    required this.gstPercentage,
    required this.gstAmount,
    required this.total,
    this.receivedQuantity,
    this.baseUnit,
    this.conversionFactor,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      taxableAmount: (json['taxableAmount'] ?? 0).toDouble(),
      discount: json['discount']?.toDouble(),
      gstPercentage: (json['gstPercentage'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      receivedQuantity: json['receivedQuantity']?.toDouble(),
      baseUnit: json['baseUnit'],
      conversionFactor: json['conversionFactor']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'taxableAmount': taxableAmount,
      'discount': discount,
      'gstPercentage': gstPercentage,
      'gstAmount': gstAmount,
      'total': total,
      'receivedQuantity': receivedQuantity,
      'baseUnit': baseUnit,
      'conversionFactor': conversionFactor,
    };
  }

  // Helper to calculate base quantity for inventory
  double get baseQuantityOrdered {
    if (baseUnit == null || conversionFactor == null) return quantity;
    if (unit == baseUnit) return quantity;
    return quantity * conversionFactor!;
  }
}

/// Main Purchase Order Entity
class PurchaseOrder {
  final String id;
  final String poNumber; // Human readable PO number e.g., PO-2024-001
  final String supplierId;
  final String supplierName;
  final PurchaseOrderStatus status;
  final PurchaseOrderPaymentStatus paymentStatus;
  final List<PurchaseOrderItem> items;

  // Accounting Fields
  final double subtotal; // Sum of taxableAmount of all items
  final double totalGst; // Sum of gstAmount of all items
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount; // subtotal + totalGst + roundOff
  final double roundOff;

  final String createdAt;
  final String? expectedDeliveryDate;
  final String? receivedAt;
  final String? notes;
  final String createdBy;
  final String createdByName;
  final String? gstType; // 'CGST+SGST' or 'IGST'
  final String? paymentMode; // 'Cash', 'Online', 'Check'
  final String? paymentReceivedBy; // Name of person who handed over cash
  final String? paymentNote; // Optional note

  /// Supplier's invoice number - used to prevent duplicate entries
  /// ARCHITECTURE LOCK: Must be unique per supplier to prevent double-booking
  final String? supplierInvoiceNumber;
  final String? invoiceDate;

  PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.paymentStatus,
    required this.items,
    required this.subtotal,
    required this.totalGst,
    this.cgstAmount = 0,
    this.sgstAmount = 0,
    this.igstAmount = 0,
    required this.totalAmount,
    this.roundOff = 0,
    required this.createdAt,
    required this.createdBy,
    required this.createdByName,
    this.expectedDeliveryDate,
    this.receivedAt,
    this.notes,
    this.gstType,
    this.paymentMode,
    this.paymentReceivedBy,
    this.paymentNote,
    this.supplierInvoiceNumber,
    this.invoiceDate,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] ?? '',
      poNumber: json['poNumber'] ?? '',
      supplierId: json['supplierId'] ?? '',
      supplierName: json['supplierName'] ?? 'Unknown Supplier',
      status: PurchaseOrderStatus.fromString(json['status'] ?? 'draft'),
      paymentStatus: PurchaseOrderPaymentStatus.fromString(
        json['paymentStatus'] ?? 'pending',
      ),
      items:
          (json['items'] as List?)
              ?.map((e) => PurchaseOrderItem.fromJson(e))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalGst: (json['totalGst'] ?? 0).toDouble(),
      cgstAmount: (json['cgstAmount'] ?? 0).toDouble(),
      sgstAmount: (json['sgstAmount'] ?? 0).toDouble(),
      igstAmount: (json['igstAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      roundOff: (json['roundOff'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdByName: json['createdByName'] ?? '',
      expectedDeliveryDate: json['expectedDeliveryDate'],
      receivedAt: json['receivedAt'],
      notes: json['notes'],
      gstType: json['gstType'],
      paymentMode: json['paymentMode'],
      paymentReceivedBy: json['paymentReceivedBy'],
      paymentNote: json['paymentNote'],
      supplierInvoiceNumber: json['supplierInvoiceNumber'],
      invoiceDate: json['invoiceDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poNumber': poNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.value,
      'paymentStatus': paymentStatus.value,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'totalGst': totalGst,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'totalAmount': totalAmount,
      'roundOff': roundOff,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'expectedDeliveryDate': expectedDeliveryDate,
      'receivedAt': receivedAt,
      'notes': notes,
      'gstType': gstType,
      'paymentMode': paymentMode,
      'paymentReceivedBy': paymentReceivedBy,
      'paymentNote': paymentNote,
      'supplierInvoiceNumber': supplierInvoiceNumber,
      'invoiceDate': invoiceDate,
    };
  }
}
