import 'package:cloud_firestore/cloud_firestore.dart';

class StockLedgerEntry {
  final String id;
  final String productId;
  final String warehouseId;
  final DateTime transactionDate;
  final String transactionType; // IN, OUT, OPENING, ADJUSTMENT
  final String? referenceId; // Document ID (PO, Invoice, etc.)
  final double quantityChange; // +ve for IN, -ve for OUT
  final double runningBalance;
  final String unit;
  final String performedBy;
  final String? notes;

  StockLedgerEntry({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.transactionDate,
    required this.transactionType,
    this.referenceId,
    required this.quantityChange,
    required this.runningBalance,
    required this.unit,
    required this.performedBy,
    this.notes,
  });

  static DateTime _parseRemoteDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory StockLedgerEntry.fromJson(Map<String, dynamic> json) {
    return StockLedgerEntry(
      id: json['id'] as String,
      productId: json['productId'] as String,
      warehouseId: json['warehouseId'] as String,
      transactionDate: _parseRemoteDate(json['transactionDate']),
      transactionType: json['transactionType'] as String,
      referenceId: json['referenceId'] as String?,
      quantityChange: (json['quantityChange'] as num).toDouble(),
      runningBalance: (json['runningBalance'] as num).toDouble(),
      unit: json['unit'] as String,
      performedBy: json['performedBy'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'transactionType': transactionType,
      'referenceId': referenceId,
      'quantityChange': quantityChange,
      'runningBalance': runningBalance,
      'unit': unit,
      'performedBy': performedBy,
      'notes': notes,
    };
  }
}
