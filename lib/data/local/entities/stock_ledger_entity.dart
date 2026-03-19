import 'package:isar/isar.dart';
import '../../../models/inventory/stock_ledger_entry.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'stock_ledger_entity.g.dart';

@Collection()
class StockLedgerEntity extends BaseEntity {
  @Index()
  late String productId;

  @Index()
  late String warehouseId;

  @Index()
  late DateTime transactionDate;

  @Index()
  late String transactionType; // IN, OUT, OPENING, ADJUSTMENT

  @Index()
  String? referenceId; // Document ID (PO, Invoice, etc.)

  late double quantityChange; // +ve for IN, -ve for OUT
  late double runningBalance;
  late String unit;

  @Index()
  late String performedBy;

  String? notes;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'transactionDate': transactionDate.toIso8601String(),
      'transactionType': transactionType,
      'referenceId': referenceId,
      'quantityChange': quantityChange,
      'runningBalance': runningBalance,
      'unit': unit,
      'performedBy': performedBy,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  /// Builds an entity from a sync-safe json map.
  static StockLedgerEntity fromJson(Map<String, dynamic> json) {
    return StockLedgerEntity()
      ..id = parseString(json['id'])
      ..productId = parseString(json['productId'])
      ..warehouseId = parseString(json['warehouseId'])
      ..transactionDate = parseDate(json['transactionDate'])
      ..transactionType = parseString(json['transactionType'])
      ..referenceId = parseString(json['referenceId'], fallback: '')
      ..quantityChange = parseDouble(json['quantityChange'])
      ..runningBalance = parseDouble(json['runningBalance'])
      ..unit = parseString(json['unit'])
      ..performedBy = parseString(json['performedBy'])
      ..notes = parseString(json['notes'], fallback: '')
      ..updatedAt = parseDate(
        json['updatedAt'] ?? json['lastModified'],
      )
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');
  }

  StockLedgerEntry toDomain() {
    return StockLedgerEntry(
      id: id,
      productId: productId,
      warehouseId: warehouseId,
      transactionDate: transactionDate,
      transactionType: transactionType,
      referenceId: referenceId,
      quantityChange: quantityChange,
      runningBalance: runningBalance,
      unit: unit,
      performedBy: performedBy,
      notes: notes,
    );
  }

  static StockLedgerEntity fromDomain(StockLedgerEntry domain) {
    return StockLedgerEntity()
      ..id = domain.id
      ..productId = domain.productId
      ..warehouseId = domain.warehouseId
      ..transactionDate = domain.transactionDate
      ..transactionType = domain.transactionType
      ..referenceId = domain.referenceId
      ..quantityChange = domain.quantityChange
      ..runningBalance = domain.runningBalance
      ..unit = domain.unit
      ..performedBy = domain.performedBy
      ..notes = domain.notes
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced;
  }
}
