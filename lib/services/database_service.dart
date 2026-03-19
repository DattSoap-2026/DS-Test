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
import '../data/local/entities/department_entity.dart';
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
import '../data/local/entities/fuel_purchase_entity.dart';
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
import '../data/local/entities/config_cache_entity.dart';
import '../data/local/entities/custom_role_entity.dart';
import '../data/local/entities/inventory_location_entity.dart';
import '../data/local/entities/stock_balance_entity.dart';
import '../data/local/entities/chat_message.dart';
import '../data/local/entities/supplier_entity.dart';
import '../data/local/entities/purchase_order_entity.dart';
import '../data/local/entities/warehouse_entity.dart';
import '../models/ai_brain_models.dart';
import '../data/local/entities/dispatch_entity.dart';
import '../data/local/entities/stock_movement_entity.dart';
import '../data/local/entities/route_order_entity.dart'; // Added
import '../data/local/entities/task_entity.dart';
import '../features/inventory/models/sync_queue.dart' as inventory_sync_queue;

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
      DepartmentEntitySchema,
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
      FuelPurchaseEntitySchema,
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
      ConfigCacheEntitySchema,
      CustomRoleEntitySchema,
      ChatMessageSchema,
      SupplierEntitySchema,
      PurchaseOrderEntitySchema,
      WarehouseEntitySchema,
      // AI Brain
      AIChatMessageSchema,
      AILearningItemSchema,
      AIInsightCacheSchema,
      AIBrainSettingsSchema,
      inventory_sync_queue.SyncQueueSchema,
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
        DepartmentEntitySchema,
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
        FuelPurchaseEntitySchema,
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
        ConfigCacheEntitySchema,
        CustomRoleEntitySchema,
        ChatMessageSchema,
        SupplierEntitySchema,
        PurchaseOrderEntitySchema,
        WarehouseEntitySchema,
        // AI Brain
        AIChatMessageSchema,
        AILearningItemSchema,
        AIInsightCacheSchema,
        AIBrainSettingsSchema,
        inventory_sync_queue.SyncQueueSchema,
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

    Future<void> copyAll<T>(
      IsarCollection<T> source,
      IsarCollection<T> target,
    ) async {
      final items = await source.where().findAll();
      if (items.isNotEmpty) {
        await target.putAll(items);
      }
    }

    await encrypted.writeTxn(() async {
      await copyAll(legacy.userEntitys, encrypted.userEntitys);
      await copyAll(legacy.tripEntitys, encrypted.tripEntitys);
      await copyAll(legacy.productEntitys, encrypted.productEntitys);
      await copyAll(legacy.saleEntitys, encrypted.saleEntitys);
      await copyAll(legacy.paymentEntitys, encrypted.paymentEntitys);
      await copyAll(legacy.returnEntitys, encrypted.returnEntitys);
      await copyAll(
        legacy.bhattiDailyEntryEntitys,
        encrypted.bhattiDailyEntryEntitys,
      );
      await copyAll(
        legacy.productionDailyEntryEntitys,
        encrypted.productionDailyEntryEntitys,
      );
      await copyAll(legacy.customerEntitys, encrypted.customerEntitys);
      await copyAll(legacy.dealerEntitys, encrypted.dealerEntitys);
      await copyAll(legacy.tankEntitys, encrypted.tankEntitys);
      await copyAll(
        legacy.tankTransactionEntitys,
        encrypted.tankTransactionEntitys,
      );
      await copyAll(legacy.tankLotEntitys, encrypted.tankLotEntitys);
      await copyAll(
        legacy.departmentStockEntitys,
        encrypted.departmentStockEntitys,
      );
      await copyAll(
        legacy.departmentMasterEntitys,
        encrypted.departmentMasterEntitys,
      );
      await copyAll(legacy.departmentEntitys, encrypted.departmentEntitys);
      await copyAll(
        legacy.inventoryCommandEntitys,
        encrypted.inventoryCommandEntitys,
      );
      await copyAll(
        legacy.inventoryLocationEntitys,
        encrypted.inventoryLocationEntitys,
      );
      await copyAll(legacy.stockBalanceEntitys, encrypted.stockBalanceEntitys);
      await copyAll(legacy.wastageLogEntitys, encrypted.wastageLogEntitys);
      await copyAll(legacy.bhattiBatchEntitys, encrypted.bhattiBatchEntitys);
      await copyAll(legacy.cuttingBatchEntitys, encrypted.cuttingBatchEntitys);
      await copyAll(
        legacy.productionTargetEntitys,
        encrypted.productionTargetEntitys,
      );
      await copyAll(
        legacy.detailedProductionLogEntitys,
        encrypted.detailedProductionLogEntitys,
      );
      await copyAll(legacy.dispatchEntitys, encrypted.dispatchEntitys);
      await copyAll(
        legacy.stockMovementEntitys,
        encrypted.stockMovementEntitys,
      );
      await copyAll(legacy.routeOrderEntitys, encrypted.routeOrderEntitys);
      await copyAll(legacy.taskEntitys, encrypted.taskEntitys);
      await copyAll(legacy.dutySessionEntitys, encrypted.dutySessionEntitys);
      await copyAll(legacy.employeeEntitys, encrypted.employeeEntitys);
      await copyAll(legacy.alertEntitys, encrypted.alertEntitys);
      await copyAll(legacy.auditLogEntitys, encrypted.auditLogEntitys);
      await copyAll(legacy.routeSessionEntitys, encrypted.routeSessionEntitys);
      await copyAll(
        legacy.customerVisitEntitys,
        encrypted.customerVisitEntitys,
      );
      await copyAll(legacy.openingStockEntitys, encrypted.openingStockEntitys);
      await copyAll(legacy.stockLedgerEntitys, encrypted.stockLedgerEntitys);
      await copyAll(legacy.syncMetricEntitys, encrypted.syncMetricEntitys);
      await copyAll(legacy.conflictEntitys, encrypted.conflictEntitys);
      await copyAll(legacy.vehicleEntitys, encrypted.vehicleEntitys);
      await copyAll(legacy.dieselLogEntitys, encrypted.dieselLogEntitys);
      await copyAll(legacy.fuelPurchaseEntitys, encrypted.fuelPurchaseEntitys);
      await copyAll(legacy.salesTargetEntitys, encrypted.salesTargetEntitys);
      await copyAll(legacy.schemeEntitys, encrypted.schemeEntitys);
      await copyAll(
        legacy.payrollRecordEntitys,
        encrypted.payrollRecordEntitys,
      );
      await copyAll(legacy.leaveRequestEntitys, encrypted.leaveRequestEntitys);
      await copyAll(legacy.attendanceEntitys, encrypted.attendanceEntitys);
      await copyAll(legacy.advanceEntitys, encrypted.advanceEntitys);
      await copyAll(legacy.performanceReviewEntitys, encrypted.performanceReviewEntitys);
      await copyAll(legacy.holidayEntitys, encrypted.holidayEntitys);
      await copyAll(
        legacy.employeeDocumentEntitys,
        encrypted.employeeDocumentEntitys,
      );
      await copyAll(
        legacy.maintenanceLogEntitys,
        encrypted.maintenanceLogEntitys,
      );
      await copyAll(legacy.tyreLogEntitys, encrypted.tyreLogEntitys);
      await copyAll(legacy.vehicleIssueEntitys, encrypted.vehicleIssueEntitys);
      await copyAll(legacy.accountEntitys, encrypted.accountEntitys);
      await copyAll(legacy.voucherEntitys, encrypted.voucherEntitys);
      await copyAll(
        legacy.voucherEntryEntitys,
        encrypted.voucherEntryEntitys,
      );
      await copyAll(legacy.routeEntitys, encrypted.routeEntitys);
      await copyAll(legacy.tyreStockEntitys, encrypted.tyreStockEntitys);
      await copyAll(legacy.unitEntitys, encrypted.unitEntitys);
      await copyAll(legacy.categoryEntitys, encrypted.categoryEntitys);
      await copyAll(legacy.productTypeEntitys, encrypted.productTypeEntitys);
      await copyAll(legacy.syncQueueEntitys, encrypted.syncQueueEntitys);
      await copyAll(
        legacy.settingsCacheEntitys,
        encrypted.settingsCacheEntitys,
      );
      await copyAll(legacy.configCacheEntitys, encrypted.configCacheEntitys);
      await copyAll(legacy.customRoleEntitys, encrypted.customRoleEntitys);
      await copyAll(legacy.chatMessages, encrypted.chatMessages);
      await copyAll(legacy.supplierEntitys, encrypted.supplierEntitys);
      await copyAll(
        legacy.purchaseOrderEntitys,
        encrypted.purchaseOrderEntitys,
      );
      await copyAll(legacy.warehouseEntitys, encrypted.warehouseEntitys);
      await copyAll(legacy.aIChatMessages, encrypted.aIChatMessages);
      await copyAll(legacy.aILearningItems, encrypted.aILearningItems);
      await copyAll(legacy.aIInsightCaches, encrypted.aIInsightCaches);
      await copyAll(legacy.aIBrainSettings, encrypted.aIBrainSettings);
      await copyAll(legacy.syncQueues, encrypted.syncQueues);
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
  IsarCollection<DepartmentEntity> get departments => _isar.departmentEntitys;
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
  IsarCollection<FuelPurchaseEntity> get fuelPurchases =>
      _isar.fuelPurchaseEntitys;
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
  IsarCollection<ConfigCacheEntity> get configCache => _isar.configCacheEntitys;
  IsarCollection<CustomRoleEntity> get customRoles => _isar.customRoleEntitys;
  IsarCollection<ChatMessage> get chatMessages => _isar.chatMessages;
  IsarCollection<SupplierEntity> get suppliers => _isar.supplierEntitys;
  IsarCollection<PurchaseOrderEntity> get purchaseOrders =>
      _isar.purchaseOrderEntitys;
  IsarCollection<WarehouseEntity> get warehouses => _isar.warehouseEntitys;
  IsarCollection<DispatchEntity> get dispatches => _isar.dispatchEntitys;
  IsarCollection<StockMovementEntity> get stockMovements =>
      _isar.stockMovementEntitys;
  IsarCollection<RouteOrderEntity> get routeOrders => _isar.routeOrderEntitys;
  IsarCollection<TaskEntity> get tasks => _isar.taskEntitys;
  IsarCollection<inventory_sync_queue.SyncQueue> get inventorySyncQueues =>
      _isar.syncQueues;
}
