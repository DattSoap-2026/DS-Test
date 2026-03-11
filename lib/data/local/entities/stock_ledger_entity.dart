import 'package:isar/isar.dart';
import '../../../models/inventory/stock_ledger_entry.dart';
import '../base_entity.dart';

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
