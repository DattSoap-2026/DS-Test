import 'package:cloud_firestore/cloud_firestore.dart';

class WarehouseTransfer {
  final String id;
  final String productId;
  final String productName;
  final String fromWarehouseId;
  final String fromWarehouseName;
  final String toWarehouseId;
  final String toWarehouseName;
  final double quantity;
  final String unit;
  final String transferredBy;
  final String transferredByName;
  final DateTime transferDate;
  final String? notes;
  final String? batchNumber;
  final DateTime createdAt;

  WarehouseTransfer({
    required this.id,
    required this.productId,
    required this.productName,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    required this.quantity,
    required this.unit,
    required this.transferredBy,
    required this.transferredByName,
    required this.transferDate,
    this.notes,
    this.batchNumber,
    required this.createdAt,
  });

  factory WarehouseTransfer.fromJson(Map<String, dynamic> json) {
    return WarehouseTransfer(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      fromWarehouseId: json['fromWarehouseId'] as String,
      fromWarehouseName: json['fromWarehouseName'] as String,
      toWarehouseId: json['toWarehouseId'] as String,
      toWarehouseName: json['toWarehouseName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      transferredBy: json['transferredBy'] as String,
      transferredByName: json['transferredByName'] as String,
      transferDate: _parseDate(json['transferDate']),
      notes: json['notes'] as String?,
      batchNumber: json['batchNumber'] as String?,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'fromWarehouseId': fromWarehouseId,
      'fromWarehouseName': fromWarehouseName,
      'toWarehouseId': toWarehouseId,
      'toWarehouseName': toWarehouseName,
      'quantity': quantity,
      'unit': unit,
      'transferredBy': transferredBy,
      'transferredByName': transferredByName,
      'transferDate': Timestamp.fromDate(transferDate),
      'notes': notes,
      'batchNumber': batchNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
