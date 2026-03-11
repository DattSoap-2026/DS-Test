import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../data/local/entities/user_entity.dart';
import '../data/local/entities/trip_entity.dart';
import '../data/local/entities/product_entity.dart';
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/return_entity.dart';
import '../data/local/entities/bhatti_entry_entity.dart';
import '../data/local/entities/production_entry_entity.dart';
import '../data/local/entities/customer_entity.dart';
import '../data/local/entities/dealer_entity.dart';
import '../data/local/entities/tank_entity.dart';
import '../data/local/entities/tank_transaction_entity.dart';
import '../data/local/entities/tank_lot_entity.dart';
import '../data/local/entities/department_stock_entity.dart';
import '../data/local/entities/department_master_entity.dart';
import '../data/local/entities/inventory_command_entity.dart';
import '../data/local/entities/wastage_log_entity.dart';
import '../data/local/entities/bhatti_batch_entity.dart';
import '../data/local/entities/cutting_batch_entity.dart';
import '../data/local/entities/production_target_entity.dart';
import '../data/local/entities/detailed_production_log_entity.dart';
import '../data/local/entities/duty_session_entity.dart';
import '../data/local/entities/employee_entity.dart';
import '../data/local/entities/alert_entity.dart';
import '../data/local/entities/audit_log_entity.dart';
import '../data/local/entities/route_session_entity.dart';
import '../data/local/entities/customer_visit_entity.dart';
import '../data/local/entities/opening_stock_entity.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../data/local/entities/sync_metric_entity.dart';
import '../data/local/entities/conflict_entity.dart';
import '../data/local/entities/vehicle_entity.dart';
import '../data/local/entities/diesel_log_entity.dart';
import '../data/local/entities/sales_target_entity.dart';
import '../data/local/entities/scheme_entity.dart';
import '../data/local/entities/payroll_record_entity.dart';
import '../data/local/entities/leave_request_entity.dart';
import '../data/local/entities/attendance_entity.dart';
import '../data/local/entities/advance_entity.dart';
import '../data/local/entities/holiday_entity.dart';
import '../data/local/entities/performance_review_entity.dart';
import '../data/local/entities/employee_document_entity.dart';
import '../data/local/entities/vehicle_issue_entity.dart'; // Added
import '../data/local/entities/maintenance_log_entity.dart'; // Added
import '../data/local/entities/tyre_log_entity.dart'; // Added
import '../data/local/entities/account_entity.dart';
import '../data/local/entities/voucher_entity.dart';
import '../data/local/entities/voucher_entry_entity.dart';

import '../data/local/entities/payment_entity.dart';
import '../data/local/entities/route_entity.dart';
import '../data/local/entities/tyre_stock_entity.dart';
import '../data/local/entities/unit_entity.dart';
import '../data/local/entities/category_entity.dart';
import '../data/local/entities/product_type_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import '../data/local/entities/settings_cache_entity.dart';
import '../data/local/entities/custom_role_entity.dart';
import '../data/local/entities/inventory_location_entity.dart';
import '../data/local/entities/stock_balance_entity.dart';
import '../models/ai_brain_models.dart';
import '../data/local/entities/dispatch_entity.dart';
import '../data/local/entities/stock_movement_entity.dart';
import '../data/local/entities/route_order_entity.dart'; // Added
import '../data/local/entities/task_entity.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  static const String _dbName = 'dattsoap';
  static const String _legacyDbName = 'isar';
  static const String _encryptionKeyStorageKey = 'isar_encryption_key_v1';
  static const int _encryptionKeyLength = 32;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  final Random _random = Random.secure();

  late Isar _isar;
  bool _isInitialized = false;

  Isar get db {
    if (!_isInitialized) {
      throw IsarError('Database not initialized. Call init() first.');
    }
    return _isar;
  }

  Future<Uint8List> _loadOrCreateEncryptionKey() async {
    final existing = await _secureStorage.read(key: _encryptionKeyStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Url.decode(existing));
    }

    final bytes = List<int>.generate(
      _encryptionKeyLength,
      (_) => _random.nextInt(256),
    );
    final encoded = base64UrlEncode(bytes);
    await _secureStorage.write(key: _encryptionKeyStorageKey, value: encoded);
    return Uint8List.fromList(bytes);
  }

  Future<bool> _hasDbFile(String path, String name) async {
    final file = File(p.join(path, '$name.isar'));
    if (await file.exists()) return true;

    final dir = Directory(path);
    if (!await dir.exists()) return false;
    return dir.listSync().any(
      (entry) => p.basename(entry.path).startsWith(name),
    );
  }

  // NOTE: Isar community 3.1.0+1 does NOT support encryption.
  // Opening without encryption on all platforms.
  Future<Isar> _openEncryptedIsar(String path, Uint8List key) async {
    final schemas = [
      UserEntitySchema,
      TripEntitySchema,
      ProductEntitySchema,
      SaleEntitySchema,
      PaymentEntitySchema,
      ReturnEntitySchema,
      BhattiDailyEntryEntitySchema,
      ProductionDailyEntryEntitySchema,
      CustomerEntitySchema,
      DealerEntitySchema,
      TankEntitySchema,
      TankTransactionEntitySchema,
      TankLotEntitySchema,
      DepartmentStockEntitySchema,
      DepartmentMasterEntitySchema,
      InventoryCommandEntitySchema,
      InventoryLocationEntitySchema,
      StockBalanceEntitySchema,
      WastageLogEntitySchema,
      BhattiBatchEntitySchema,
      CuttingBatchEntitySchema,
      ProductionTargetEntitySchema,
      DispatchEntitySchema,
      StockMovementEntitySchema,
      RouteOrderEntitySchema, // Added
      TaskEntitySchema,
      DetailedProductionLogEntitySchema,
      DutySessionEntitySchema,
      EmployeeEntitySchema,
      AlertEntitySchema,
      AuditLogEntitySchema,
      RouteSessionEntitySchema,
      CustomerVisitEntitySchema,
      OpeningStockEntitySchema,
      StockLedgerEntitySchema,
      SyncMetricEntitySchema,
      ConflictEntitySchema,
      VehicleEntitySchema,
      DieselLogEntitySchema,
      SalesTargetEntitySchema,
      SchemeEntitySchema,
      PayrollRecordEntitySchema,
      LeaveRequestEntitySchema,
      AttendanceEntitySchema,
      AdvanceEntitySchema,
      PerformanceReviewEntitySchema,
      HolidayEntitySchema,
      EmployeeDocumentEntitySchema,
      MaintenanceLogEntitySchema,
      TyreLogEntitySchema,
      VehicleIssueEntitySchema, // Added
      AccountEntitySchema,
      VoucherEntitySchema,
      VoucherEntryEntitySchema,
      RouteEntitySchema,

      TyreStockEntitySchema,
      UnitEntitySchema,
      CategoryEntitySchema,
      ProductTypeEntitySchema,
      SyncQueueEntitySchema,
      SettingsCacheEntitySchema,
      CustomRoleEntitySchema,
      // AI Brain
      AIChatMessageSchema,
      AILearningItemSchema,
      AIInsightCacheSchema,
      AIBrainSettingsSchema,
    ];

    return Isar.open(schemas, directory: path, name: _dbName);
  }

  Future<Isar> _openLegacyIsar(String path) async {
    return Isar.open(
      [
        UserEntitySchema,
        TripEntitySchema,
        ProductEntitySchema,
        SaleEntitySchema,
        PaymentEntitySchema,
        ReturnEntitySchema,
        BhattiDailyEntryEntitySchema,
        ProductionDailyEntryEntitySchema,
        CustomerEntitySchema,
        DealerEntitySchema,
        TankEntitySchema,
        TankTransactionEntitySchema,
        TankLotEntitySchema,
        DepartmentStockEntitySchema,
        DepartmentMasterEntitySchema,
        InventoryCommandEntitySchema,
        InventoryLocationEntitySchema,
        StockBalanceEntitySchema,
        WastageLogEntitySchema,
        BhattiBatchEntitySchema,
        CuttingBatchEntitySchema,
        ProductionTargetEntitySchema,
        DispatchEntitySchema,
        StockMovementEntitySchema,
        RouteOrderEntitySchema, // Added
        TaskEntitySchema,
        DetailedProductionLogEntitySchema,
        DutySessionEntitySchema,
        EmployeeEntitySchema,
        AlertEntitySchema,
        AuditLogEntitySchema,
        RouteSessionEntitySchema,
        CustomerVisitEntitySchema,
        OpeningStockEntitySchema,
        StockLedgerEntitySchema,
        SyncMetricEntitySchema,
        ConflictEntitySchema,
        VehicleEntitySchema,
        DieselLogEntitySchema,
        SalesTargetEntitySchema,
        SchemeEntitySchema,
        PayrollRecordEntitySchema,
        LeaveRequestEntitySchema,
        AttendanceEntitySchema,
        AdvanceEntitySchema,
        PerformanceReviewEntitySchema,
        HolidayEntitySchema,
        EmployeeDocumentEntitySchema,
        MaintenanceLogEntitySchema,
        TyreLogEntitySchema,
        VehicleIssueEntitySchema, // Added
        AccountEntitySchema,
        VoucherEntitySchema,
        VoucherEntryEntitySchema,
        RouteEntitySchema,

        TyreStockEntitySchema,
        UnitEntitySchema,
        CategoryEntitySchema,
        ProductTypeEntitySchema,
        SyncQueueEntitySchema,
        SettingsCacheEntitySchema,
        CustomRoleEntitySchema,
        // AI Brain
        AIChatMessageSchema,
        AILearningItemSchema,
        AIInsightCacheSchema,
        AIBrainSettingsSchema,
      ],
      directory: path,
      name: _legacyDbName,
    );
  }

  Future<void> _deleteLegacyFiles(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return;
    for (final entry in dir.listSync()) {
      final base = p.basename(entry.path);
      if (base.startsWith(_legacyDbName)) {
        try {
          entry.deleteSync(recursive: true);
        } catch (e) {
          // It's safe to ignore if a legacy file couldn't be deleted temporarily
          // developer.log('Failed to delete legacy file ${entry.path}: $e');
        }
      }
    }
  }

  Future<Isar> _migrateLegacyToEncrypted(String path, Uint8List key) async {
    final legacy = await _openLegacyIsar(path);
    final encrypted = await _openEncryptedIsar(path, key);

    await encrypted.writeTxn(() async {
      final users = await legacy.userEntitys.where().findAll();
      if (users.isNotEmpty) await encrypted.userEntitys.putAll(users);
      final trips = await legacy.tripEntitys.where().findAll();
      if (trips.isNotEmpty) await encrypted.tripEntitys.putAll(trips);
      final products = await legacy.productEntitys.where().findAll();
      if (products.isNotEmpty) await encrypted.productEntitys.putAll(products);
      final sales = await legacy.saleEntitys.where().findAll();
      if (sales.isNotEmpty) await encrypted.saleEntitys.putAll(sales);
      final payments = await legacy.paymentEntitys.where().findAll();
      if (payments.isNotEmpty) {
        await encrypted.paymentEntitys.putAll(payments);
      }
      final returns = await legacy.returnEntitys.where().findAll();
      if (returns.isNotEmpty) await encrypted.returnEntitys.putAll(returns);
      final bhattiEntries = await legacy.bhattiDailyEntryEntitys
          .where()
          .findAll();
      if (bhattiEntries.isNotEmpty) {
        await encrypted.bhattiDailyEntryEntitys.putAll(bhattiEntries);
      }
      final productionEntries = await legacy.productionDailyEntryEntitys
          .where()
          .findAll();
      if (productionEntries.isNotEmpty) {
        await encrypted.productionDailyEntryEntitys.putAll(productionEntries);
      }
      final customers = await legacy.customerEntitys.where().findAll();
      if (customers.isNotEmpty) {
        await encrypted.customerEntitys.putAll(customers);
      }
      final dealers = await legacy.dealerEntitys.where().findAll();
      if (dealers.isNotEmpty) {
        await encrypted.dealerEntitys.putAll(dealers);
      }
      final tanks = await legacy.tankEntitys.where().findAll();
      if (tanks.isNotEmpty) await encrypted.tankEntitys.putAll(tanks);
      final tankTransactions = await legacy.tankTransactionEntitys
          .where()
          .findAll();
      if (tankTransactions.isNotEmpty) {
        await encrypted.tankTransactionEntitys.putAll(tankTransactions);
      }
      final tankLots = await legacy.tankLotEntitys.where().findAll();
      if (tankLots.isNotEmpty) {
        await encrypted.tankLotEntitys.putAll(tankLots);
      }
      final departmentStocks = await legacy.departmentStockEntitys
          .where()
          .findAll();
      if (departmentStocks.isNotEmpty) {
        await encrypted.departmentStockEntitys.putAll(departmentStocks);
      }
      final wastageLogs = await legacy.wastageLogEntitys.where().findAll();
      if (wastageLogs.isNotEmpty) {
        await encrypted.wastageLogEntitys.putAll(wastageLogs);
      }
      final dispatches = await legacy.dispatchEntitys.where().findAll();
      if (dispatches.isNotEmpty) {
        await encrypted.dispatchEntitys.putAll(dispatches);
      }
      final stockMovements = await legacy.stockMovementEntitys
          .where()
          .findAll();
      if (stockMovements.isNotEmpty) {
        await encrypted.stockMovementEntitys.putAll(stockMovements);
      }
      final routeOrders = await legacy.routeOrderEntitys.where().findAll();
      if (routeOrders.isNotEmpty) {
        await encrypted.routeOrderEntitys.putAll(routeOrders);
      }
      final tasks = await legacy.taskEntitys.where().findAll();
      if (tasks.isNotEmpty) {
        await encrypted.taskEntitys.putAll(tasks);
      }
      final bhattiBatches = await legacy.bhattiBatchEntitys.where().findAll();
      if (bhattiBatches.isNotEmpty) {
        await encrypted.bhattiBatchEntitys.putAll(bhattiBatches);
      }
      final cuttingBatches = await legacy.cuttingBatchEntitys.where().findAll();
      if (cuttingBatches.isNotEmpty) {
        await encrypted.cuttingBatchEntitys.putAll(cuttingBatches);
      }
      final productionTargets = await legacy.productionTargetEntitys
          .where()
          .findAll();
      if (productionTargets.isNotEmpty) {
        await encrypted.productionTargetEntitys.putAll(productionTargets);
      }
      final detailedProductionLogs = await legacy.detailedProductionLogEntitys
          .where()
          .findAll();
      if (detailedProductionLogs.isNotEmpty) {
        await encrypted.detailedProductionLogEntitys.putAll(
          detailedProductionLogs,
        );
      }
      final dutySessions = await legacy.dutySessionEntitys.where().findAll();
      if (dutySessions.isNotEmpty) {
        await encrypted.dutySessionEntitys.putAll(dutySessions);
      }
      final employees = await legacy.employeeEntitys.where().findAll();
      if (employees.isNotEmpty) {
        await encrypted.employeeEntitys.putAll(employees);
      }
      final alerts = await legacy.alertEntitys.where().findAll();
      if (alerts.isNotEmpty) await encrypted.alertEntitys.putAll(alerts);
      final auditLogs = await legacy.auditLogEntitys.where().findAll();
      if (auditLogs.isNotEmpty) {
        await encrypted.auditLogEntitys.putAll(auditLogs);
      }
      final routeSessions = await legacy.routeSessionEntitys.where().findAll();
      if (routeSessions.isNotEmpty) {
        await encrypted.routeSessionEntitys.putAll(routeSessions);
      }
      final customerVisits = await legacy.customerVisitEntitys
          .where()
          .findAll();
      if (customerVisits.isNotEmpty) {
        await encrypted.customerVisitEntitys.putAll(customerVisits);
      }
      final openingStocks = await legacy.openingStockEntitys.where().findAll();
      if (openingStocks.isNotEmpty) {
        await encrypted.openingStockEntitys.putAll(openingStocks);
      }
      final stockLedgers = await legacy.stockLedgerEntitys.where().findAll();
      if (stockLedgers.isNotEmpty) {
        await encrypted.stockLedgerEntitys.putAll(stockLedgers);
      }
      final syncMetrics = await legacy.syncMetricEntitys.where().findAll();
      if (syncMetrics.isNotEmpty) {
        await encrypted.syncMetricEntitys.putAll(syncMetrics);
      }
      final conflicts = await legacy.conflictEntitys.where().findAll();
      if (conflicts.isNotEmpty) {
        await encrypted.conflictEntitys.putAll(conflicts);
      }
      final vehicles = await legacy.vehicleEntitys.where().findAll();
      if (vehicles.isNotEmpty) await encrypted.vehicleEntitys.putAll(vehicles);
      final dieselLogs = await legacy.dieselLogEntitys.where().findAll();
      if (dieselLogs.isNotEmpty) {
        await encrypted.dieselLogEntitys.putAll(dieselLogs);
      }
      final salesTargets = await legacy.salesTargetEntitys.where().findAll();
      if (salesTargets.isNotEmpty) {
        await encrypted.salesTargetEntitys.putAll(salesTargets);
      }
      final schemes = await legacy.schemeEntitys.where().findAll();
      if (schemes.isNotEmpty) await encrypted.schemeEntitys.putAll(schemes);
      final payrolls = await legacy.payrollRecordEntitys.where().findAll();
      if (payrolls.isNotEmpty) {
        await encrypted.payrollRecordEntitys.putAll(payrolls);
      }
      final leaveRequests = await legacy.leaveRequestEntitys.where().findAll();
      if (leaveRequests.isNotEmpty) {
        await encrypted.leaveRequestEntitys.putAll(leaveRequests);
      }
      final attendances = await legacy.attendanceEntitys.where().findAll();
      if (attendances.isNotEmpty) {
        await encrypted.attendanceEntitys.putAll(attendances);
      }
      final advances = await legacy.advanceEntitys.where().findAll();
      if (advances.isNotEmpty) await encrypted.advanceEntitys.putAll(advances);
      final reviews = await legacy.performanceReviewEntitys.where().findAll();
      if (reviews.isNotEmpty) {
        await encrypted.performanceReviewEntitys.putAll(reviews);
      }
      final documents = await legacy.employeeDocumentEntitys.where().findAll();
      if (documents.isNotEmpty) {
        await encrypted.employeeDocumentEntitys.putAll(documents);
      }
      final maintenanceLogs = await legacy.maintenanceLogEntitys
          .where()
          .findAll();
      if (maintenanceLogs.isNotEmpty) {
        await encrypted.maintenanceLogEntitys.putAll(maintenanceLogs);
      }
      final tyreLogs = await legacy.tyreLogEntitys.where().findAll();
      if (tyreLogs.isNotEmpty) {
        await encrypted.tyreLogEntitys.putAll(tyreLogs);
      }
      final routes = await legacy.routeEntitys.where().findAll();
      if (routes.isNotEmpty) await encrypted.routeEntitys.putAll(routes);
      final tyreStocks = await legacy.tyreStockEntitys.where().findAll();
      if (tyreStocks.isNotEmpty) {
        await encrypted.tyreStockEntitys.putAll(tyreStocks);
      }
      final units = await legacy.unitEntitys.where().findAll();
      if (units.isNotEmpty) await encrypted.unitEntitys.putAll(units);
      final categories = await legacy.categoryEntitys.where().findAll();
      if (categories.isNotEmpty) {
        await encrypted.categoryEntitys.putAll(categories);
      }
      final productTypes = await legacy.productTypeEntitys.where().findAll();
      if (productTypes.isNotEmpty) {
        await encrypted.productTypeEntitys.putAll(productTypes);
      }
      final syncQueue = await legacy.syncQueueEntitys.where().findAll();
      if (syncQueue.isNotEmpty) {
        await encrypted.syncQueueEntitys.putAll(syncQueue);
      }
      final settingsCache = await legacy.settingsCacheEntitys.where().findAll();
      if (settingsCache.isNotEmpty) {
        await encrypted.settingsCacheEntitys.putAll(settingsCache);
      }
      final customRoles = await legacy.customRoleEntitys.where().findAll();
      if (customRoles.isNotEmpty) {
        await encrypted.customRoleEntitys.putAll(customRoles);
      }
    });

    await legacy.close();
    await _deleteLegacyFiles(path);
    return encrypted;
  }

  Future<void> init({String? directory}) async {
    if (_isInitialized) return;

    final path = directory ?? (await getApplicationDocumentsDirectory()).path;
    final encryptionKey = await _loadOrCreateEncryptionKey();

    final hasEncrypted = await _hasDbFile(path, _dbName);
    if (hasEncrypted) {
      _isar = await _openEncryptedIsar(path, encryptionKey);
    } else {
      final hasLegacy = await _hasDbFile(path, _legacyDbName);
      if (hasLegacy) {
        _isar = await _migrateLegacyToEncrypted(path, encryptionKey);
      } else {
        _isar = await _openEncryptedIsar(path, encryptionKey);
      }
    }

    _isInitialized = true;
  }

  // Accessor for collections
  IsarCollection<UserEntity> get users => _isar.userEntitys;
  IsarCollection<TripEntity> get trips => _isar.tripEntitys;
  IsarCollection<ProductEntity> get products => _isar.productEntitys;
  IsarCollection<SaleEntity> get sales => _isar.saleEntitys;
  IsarCollection<PaymentEntity> get payments => _isar.paymentEntitys;
  IsarCollection<ReturnEntity> get returns => _isar.returnEntitys;
  IsarCollection<BhattiDailyEntryEntity> get bhattiEntries =>
      _isar.bhattiDailyEntryEntitys;
  IsarCollection<ProductionDailyEntryEntity> get productionEntries =>
      _isar.productionDailyEntryEntitys;
  IsarCollection<CustomerEntity> get customers => _isar.customerEntitys;
  IsarCollection<DealerEntity> get dealers => _isar.dealerEntitys;
  IsarCollection<TankEntity> get tanks => _isar.tankEntitys;
  IsarCollection<OpeningStockEntity> get openingStocks =>
      _isar.openingStockEntitys;
  IsarCollection<StockLedgerEntity> get stockLedgers =>
      _isar.stockLedgerEntitys;
  IsarCollection<SyncMetricEntity> get syncMetrics => _isar.syncMetricEntitys;
  IsarCollection<ConflictEntity> get conflicts => _isar.conflictEntitys;

  IsarCollection<TankTransactionEntity> get tankTransactions =>
      _isar.tankTransactionEntitys;
  IsarCollection<TankLotEntity> get tankLots => _isar.tankLotEntitys;
  IsarCollection<DepartmentStockEntity> get departmentStocks =>
      _isar.departmentStockEntitys;
  IsarCollection<DepartmentMasterEntity> get departmentMasters =>
      _isar.departmentMasterEntitys;
  IsarCollection<InventoryCommandEntity> get inventoryCommands =>
      _isar.inventoryCommandEntitys;
  IsarCollection<InventoryLocationEntity> get inventoryLocations =>
      _isar.inventoryLocationEntitys;
  IsarCollection<StockBalanceEntity> get stockBalances =>
      _isar.stockBalanceEntitys;
  IsarCollection<WastageLogEntity> get wastageLogs => _isar.wastageLogEntitys;
  IsarCollection<BhattiBatchEntity> get bhattiBatches =>
      _isar.bhattiBatchEntitys;
  IsarCollection<CuttingBatchEntity> get cuttingBatches =>
      _isar.cuttingBatchEntitys;
  IsarCollection<ProductionTargetEntity> get productionTargets =>
      _isar.productionTargetEntitys;
  IsarCollection<DetailedProductionLogEntity> get detailedProductionLogs =>
      _isar.detailedProductionLogEntitys;
  IsarCollection<DutySessionEntity> get dutySessions =>
      _isar.dutySessionEntitys;
  IsarCollection<EmployeeEntity> get employees => _isar.employeeEntitys;
  IsarCollection<AlertEntity> get alerts => _isar.alertEntitys;
  IsarCollection<AuditLogEntity> get auditLogs => _isar.auditLogEntitys;
  IsarCollection<RouteSessionEntity> get routeSessions =>
      _isar.routeSessionEntitys;
  IsarCollection<CustomerVisitEntity> get customerVisits =>
      _isar.customerVisitEntitys;
  IsarCollection<OpeningStockEntity> get openingStockEntries =>
      _isar.openingStockEntitys;
  IsarCollection<StockLedgerEntity> get stockLedger => _isar.stockLedgerEntitys;

  IsarCollection<VehicleEntity> get vehicles => _isar.vehicleEntitys;
  IsarCollection<DieselLogEntity> get dieselLogs => _isar.dieselLogEntitys;
  IsarCollection<SalesTargetEntity> get salesTargets =>
      _isar.salesTargetEntitys;
  IsarCollection<SchemeEntity> get schemes => _isar.schemeEntitys;
  IsarCollection<PayrollRecordEntity> get payrollRecords =>
      _isar.payrollRecordEntitys;
  IsarCollection<LeaveRequestEntity> get leaveRequests =>
      _isar.leaveRequestEntitys;
  IsarCollection<AttendanceEntity> get attendances => _isar.attendanceEntitys;
  IsarCollection<AdvanceEntity> get advances => _isar.advanceEntitys;
  IsarCollection<HolidayEntity> get holidays => _isar.holidayEntitys;
  IsarCollection<PerformanceReviewEntity> get performanceReviews =>
      _isar.performanceReviewEntitys;
  IsarCollection<EmployeeDocumentEntity> get employeeDocuments =>
      _isar.employeeDocumentEntitys;

  IsarCollection<MaintenanceLogEntity> get maintenanceLogs =>
      _isar.maintenanceLogEntitys;

  IsarCollection<TyreLogEntity> get tyreLogs => _isar.tyreLogEntitys;
  IsarCollection<VehicleIssueEntity> get vehicleIssues =>
      _isar.vehicleIssueEntitys; // Added
  IsarCollection<AccountEntity> get accounts => _isar.accountEntitys;
  IsarCollection<VoucherEntity> get vouchers => _isar.voucherEntitys;
  IsarCollection<VoucherEntryEntity> get voucherEntries =>
      _isar.voucherEntryEntitys;

  IsarCollection<RouteEntity> get routes => _isar.routeEntitys;

  IsarCollection<TyreStockEntity> get tyreStocks => _isar.tyreStockEntitys;

  IsarCollection<UnitEntity> get units => _isar.unitEntitys;
  IsarCollection<CategoryEntity> get categories => _isar.categoryEntitys;
  IsarCollection<ProductTypeEntity> get productTypes =>
      _isar.productTypeEntitys;
  IsarCollection<SyncQueueEntity> get syncQueue => _isar.syncQueueEntitys;
  IsarCollection<SettingsCacheEntity> get settingsCache =>
      _isar.settingsCacheEntitys;
  IsarCollection<CustomRoleEntity> get customRoles => _isar.customRoleEntitys;
  IsarCollection<DispatchEntity> get dispatches => _isar.dispatchEntitys;
  IsarCollection<StockMovementEntity> get stockMovements =>
      _isar.stockMovementEntitys;
  IsarCollection<RouteOrderEntity> get routeOrders => _isar.routeOrderEntitys;
  IsarCollection<TaskEntity> get tasks => _isar.taskEntitys;
}
