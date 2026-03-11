import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OpeningStockEntry {
  final String id;
  final String productId;
  final String productType;
  final String warehouseId;
  final double quantity;
  final String unit; // Derived and locked from Product
  final double? openingRate; // Optional cost price per unit
  final String? batchNumber;
  final DateTime entryDate;
  final String reason; // "OPENING_STOCK"
  final String createdBy;
  final DateTime createdAt;

  OpeningStockEntry({
    required this.id,
    required this.productId,
    required this.productType,
    required this.warehouseId,
    required this.quantity,
    required this.unit,
    this.openingRate,
    this.batchNumber,
    required this.entryDate,
    this.reason = 'OPENING_STOCK',
    required this.createdBy,
    required this.createdAt,
  });

  static DateTime _parseRemoteDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory OpeningStockEntry.fromJson(Map<String, dynamic> json) {
    final parsedProductId = (json['productId'] as String?) ?? '';
    if (parsedProductId.isEmpty) {
      debugPrint('WARNING: Skipped opening stock document with null productId');
    }
    return OpeningStockEntry(
      id: (json['id'] as String?) ?? '',
      productId: parsedProductId,
      productType: (json['productType'] as String?) ?? '',
      warehouseId: (json['warehouseId'] as String?) ?? 'main',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: (json['unit'] as String?) ?? 'pcs',
      openingRate: (json['openingRate'] as num?)?.toDouble(),
      batchNumber: json['batchNumber'] as String?,
      entryDate: _parseRemoteDate(json['entryDate']),
      reason: json['reason'] as String? ?? 'OPENING_STOCK',
      createdBy: (json['createdBy'] as String?) ?? 'system',
      createdAt: _parseRemoteDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productType': productType,
      'warehouseId': warehouseId,
      'quantity': quantity,
      'unit': unit,
      'openingRate': openingRate,
      'batchNumber': batchNumber,
      'entryDate': Timestamp.fromDate(entryDate),
      'reason': reason,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
