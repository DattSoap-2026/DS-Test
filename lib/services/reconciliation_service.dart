import 'package:isar/isar.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/department_master_service.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';

class StockMismatch {
  final String locationId;
  final String productId;
  final double legacyValue;
  final double canonicalValue;
  final double delta;

  const StockMismatch({
    required this.locationId,
    required this.productId,
    required this.legacyValue,
    required this.canonicalValue,
    required this.delta,
  });
}

class ReconciliationReport {
  final DateTime generatedAt;
  final List<StockMismatch> warehouseMismatches;
  final List<StockMismatch> departmentMismatches;
  final List<StockMismatch> salesmanMismatches;
  final List<String> duplicateMovements;
  final List<String> stuckQueueItems;

  const ReconciliationReport({
    required this.generatedAt,
    required this.warehouseMismatches,
    required this.departmentMismatches,
    required this.salesmanMismatches,
    required this.duplicateMovements,
    required this.stuckQueueItems,
  });

  bool get isClean =>
      warehouseMismatches.isEmpty &&
      departmentMismatches.isEmpty &&
      salesmanMismatches.isEmpty &&
      duplicateMovements.isEmpty &&
      stuckQueueItems.isEmpty;
}

class ReconciliationService {
  final DatabaseService _dbService;
  final DepartmentMasterService _departmentMasterService;

  ReconciliationService(
    this._dbService, {
    DepartmentMasterService? departmentMasterService,
  }) : _departmentMasterService =
            departmentMasterService ?? DepartmentMasterService(_dbService);

  Future<ReconciliationReport> generateReport() async {
    final now = DateTime.now();
    final warehouseMismatches = await _checkWarehouseMismatches();
    final departmentMismatches = await _checkDepartmentMismatches();
    final salesmanMismatches = await _checkSalesmanMismatches();
    final duplicateMovements = await _checkDuplicateMovements();
    final stuckQueueItems = await _checkStuckQueueItems();

    return ReconciliationReport(
      generatedAt: now,
      warehouseMismatches: warehouseMismatches,
      departmentMismatches: departmentMismatches,
      salesmanMismatches: salesmanMismatches,
      duplicateMovements: duplicateMovements,
      stuckQueueItems: stuckQueueItems,
    );
  }

  Future<List<StockMismatch>> _checkWarehouseMismatches() async {
    final mismatches = <StockMismatch>[];
    final products = await _dbService.products.where().findAll();
    const warehouseLocationId = InventoryProjectionService.warehouseMainLocationId;

    for (final product in products.where((p) => !p.isDeleted)) {
      final legacyValue = product.stock ?? 0.0;
      final balanceId = '${warehouseLocationId}_${product.id}';
      final balance = await _dbService.stockBalances.get(fastHash(balanceId));
      final canonicalValue = balance?.quantity ?? 0.0;

      if ((legacyValue - canonicalValue).abs() > 0.001) {
        mismatches.add(StockMismatch(
          locationId: warehouseLocationId,
          productId: product.id,
          legacyValue: legacyValue,
          canonicalValue: canonicalValue,
          delta: legacyValue - canonicalValue,
        ));
      }
    }

    return mismatches;
  }

  Future<List<StockMismatch>> _checkDepartmentMismatches() async {
    final mismatches = <StockMismatch>[];
    final departmentStocks = await _dbService.departmentStocks.where().findAll();

    for (final stock in departmentStocks.where((s) => !s.isDeleted)) {
      final departmentId = _departmentMasterService.resolveCanonicalDepartmentId(
        stock.departmentName,
      );
      if (departmentId == null) continue;

      final legacyValue = stock.stock;
      final balanceId = '${departmentId}_${stock.productId}';
      final balance = await _dbService.stockBalances.get(fastHash(balanceId));
      final canonicalValue = balance?.quantity ?? 0.0;

      if ((legacyValue - canonicalValue).abs() > 0.001) {
        mismatches.add(StockMismatch(
          locationId: departmentId,
          productId: stock.productId,
          legacyValue: legacyValue,
          canonicalValue: canonicalValue,
          delta: legacyValue - canonicalValue,
        ));
      }
    }

    return mismatches;
  }

  Future<List<StockMismatch>> _checkSalesmanMismatches() async {
    final mismatches = <StockMismatch>[];
    final users = await _dbService.users.where().findAll();

    for (final user in users.where((u) => !u.isDeleted && u.isActive)) {
      final role = user.role?.trim().toLowerCase().replaceAll('_', ' ');
      if (role != 'salesman') continue;

      final locationId = InventoryProjectionService.salesmanLocationIdForUid(user.id);
      final allocatedStock = user.getAllocatedStock();

      for (final entry in allocatedStock.entries) {
        final productId = entry.key;
        final legacyValue = (entry.value.quantity + (entry.value.freeQuantity ?? 0)).toDouble();
        final balanceId = '${locationId}_$productId';
        final balance = await _dbService.stockBalances.get(fastHash(balanceId));
        final canonicalValue = balance?.quantity ?? 0.0;

        if ((legacyValue - canonicalValue).abs() > 0.001) {
          mismatches.add(StockMismatch(
            locationId: locationId,
            productId: productId,
            legacyValue: legacyValue,
            canonicalValue: canonicalValue,
            delta: legacyValue - canonicalValue,
          ));
        }
      }
    }

    return mismatches;
  }

  Future<List<String>> _checkDuplicateMovements() async {
    final duplicates = <String>[];
    final movements = await _dbService.stockMovements.where().findAll();
    final commandCounts = <String, int>{};

    for (final movement in movements) {
      final commandId = movement.commandId;
      commandCounts[commandId] = (commandCounts[commandId] ?? 0) + 1;
    }

    for (final entry in commandCounts.entries) {
      final command = await _dbService.inventoryCommands.get(fastHash(entry.key));
      if (command == null) continue;

      final expectedCount = _expectedMovementCount(command.commandType);
      if (expectedCount > 0 && entry.value > expectedCount) {
        duplicates.add(entry.key);
      }
    }

    return duplicates;
  }

  int _expectedMovementCount(String commandType) {
    switch (commandType) {
      case 'opening_set_balance':
        return 1;
      case 'department_issue':
      case 'department_return':
      case 'dispatch_create':
        return 1;
      case 'sale_complete':
        return 1;
      case 'bhatti_production_complete':
      case 'cutting_production_complete':
        return 0;
      default:
        return 0;
    }
  }

  Future<List<String>> _checkStuckQueueItems() async {
    final stuck = <String>[];
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final commands = await _dbService.inventoryCommands.where().findAll();

    for (final command in commands) {
      if (command.appliedLocally &&
          !command.appliedRemotely &&
          command.createdAt.isBefore(cutoff)) {
        stuck.add(command.commandId);
      }
    }

    return stuck;
  }
}
