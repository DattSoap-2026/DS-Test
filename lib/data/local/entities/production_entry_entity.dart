import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'production_entry_entity.g.dart';

/// Represents a production item in a daily entry (embedded object)
@Embedded()
class ProductionItemEntity {
  /// Product ID
  late String productId;

  /// Product name
  late String productName;

  /// Batch number
  late String batchNumber;

  /// Total quantity produced in this batch
  late int totalBatchQuantity;

  /// Unit of measurement
  late String unit;

  /// Cost per unit
  late double costPerUnit;

  /// Total batch cost
  late double totalBatchCost;

  /// Optional notes
  String? notes;

  /// Convert to Firebase JSON format
  Map<String, dynamic> toFirebaseJson() {
    return {
      'productId': productId,
      'productName': productName,
      'batchNumber': batchNumber,
      'totalBatchQuantity': totalBatchQuantity,
      'unit': unit,
      'costPerUnit': costPerUnit,
      'totalBatchCost': totalBatchCost,
      if (notes != null) 'notes': notes,
    };
  }

  /// Create from Firebase JSON
  static ProductionItemEntity fromFirebaseJson(Map<String, dynamic> json) {
    return ProductionItemEntity()
      ..productId = json['productId'] as String
      ..productName = json['productName'] as String
      ..batchNumber = json['batchNumber'] as String
      ..totalBatchQuantity = (json['totalBatchQuantity'] as num).toInt()
      ..unit = json['unit'] as String? ?? 'Pcs'
      ..costPerUnit = (json['costPerUnit'] as num?)?.toDouble() ?? 0.0
      ..costPerUnit = (json['costPerUnit'] as num?)?.toDouble() ?? 0.0
      ..totalBatchCost = (json['totalBatchCost'] as num?)?.toDouble() ?? 0.0
      ..notes = json['notes'] as String?;
  }
}

/// Represents a daily Production Supervisor entry
/// This is an ONLINE-FIRST entity with automatic local caching
@Collection()
class ProductionDailyEntryEntity extends BaseEntity {
  /// Date of the entry (indexed for efficient queries)
  @Index()
  late DateTime date;

  /// Department code (e.g., 'production', 'warehouse')
  late String departmentCode;

  /// Department name
  late String departmentName;

  /// Team code (e.g., 'sona', 'gita')
  String? teamCode;

  /// List of production items (batches cut/produced)
  late List<ProductionItemEntity> items;

  /// User ID who created the entry
  late String createdBy;

  /// User name who created the entry
  late String createdByName;

  /// Creation timestamp
  late DateTime createdAt;

  /// Notes or additional comments
  String? notes;

  /// Convert to Firebase JSON format
  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      if (teamCode != null) 'teamCode': teamCode,
      'items': items.map((item) => item.toFirebaseJson()).toList(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  /// Create from Firebase JSON
  static ProductionDailyEntryEntity fromFirebaseJson(
    Map<String, dynamic> json,
  ) {
    final entity = ProductionDailyEntryEntity()
      ..id = json['id'] as String
      ..date = DateTime.parse(json['date'] as String)
      ..departmentCode = json['departmentCode'] as String
      ..departmentName = json['departmentName'] as String
      ..teamCode = json['teamCode'] as String?
      ..items =
          (json['items'] as List?)
              ?.map(
                (item) => ProductionItemEntity.fromFirebaseJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          []
      ..createdBy = json['createdBy'] as String
      ..createdByName = json['createdByName'] as String? ?? 'Unknown'
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      )
      ..notes = json['notes'] as String?
      ..syncStatus = SyncStatus
          .synced // Auto-cached entries are always synced
      ..isDeleted = json['isDeleted'] == true
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '');

    return entity;
  }
}
