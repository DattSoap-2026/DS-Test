abstract final class CollectionRegistry {
  // Core
  static const String users = 'users';
  static const String products = 'products';
  static const String sales = 'sales';
  static const String returns = 'returns';
  static const String customers = 'customers';
  static const String dealers = 'dealers';
  static const String payments = 'payments';
  static const String paymentLinks = 'payment_links';

  // Dispatch
  static const String deliveryTrips = 'delivery_trips';
  static const String dispatches = 'dispatches';
  static const String routeOrders = 'route_orders';
  static const String routeSessions = 'route_sessions';
  static const String customerVisits = 'customer_visits';
  static const String routes = 'routes';
  static const String vehicles = 'vehicles';

  // Inventory / Production
  static const String openingStockEntries = 'opening_stock_entries';
  static const String stockLedger = 'stock_ledger';
  static const String stockMovements = 'stock_movements';
  static const String productionEntries = 'production_entries';
  static const String productionLogs = 'production_logs';
  static const String detailedProductionLogs = 'detailed_production_logs';
  static const String bhattiEntries = 'bhatti_entries';
  static const String bhattiBatches = 'bhatti_batches';
  static const String bhattiDailyEntries = 'bhatti_daily_entries';
  static const String wastageLogs = 'wastage_logs';
  static const String departmentStocks = 'department_stocks';
  static const String inventoryCommands = 'inventory_commands';
  static const String cuttingBatches = 'cutting_batches';
  static const String productionTargets = 'production_targets';
  static const String departmentMaster = 'department_master';
  static const String inventoryLocations = 'inventory_locations';
  static const String stockBalances = 'stock_balances';
  static const String tanks = 'tanks';
  static const String tankTransactions = 'tank_transactions';
  static const String tankLots = 'tank_lots';
  static const String tankTransfers = 'tank_transfers';
  static const String tankRefills = 'tank_refills';

  // HR
  static const String payrollRecords = 'payroll_records';
  static const String attendances = 'attendances';
  static const String employees = 'employees';
  static const String advances = 'advances';
  static const String leaveRequests = 'leave_requests';
  static const String performanceReviews = 'performance_reviews';
  static const String employeeDocuments = 'employee_documents';
  static const String holidays = 'holidays';
  static const String dutySessions = 'duty_sessions';
  static const String salesTargets = 'sales_targets';

  // Config / Master Data
  static const String settings = 'settings';
  static const String publicSettings = 'public_settings';
  static const String userDepartments = 'user_departments';
  static const String transactionSeries = 'transaction_series';
  static const String currencies = 'currencies';
  static const String schemes = 'schemes';
  static const String customRoles = 'custom_roles';
  static const String pdfTemplates = 'pdf_templates';
  static const String units = 'units';
  static const String productTypes = 'product_types';
  static const String productCategories = 'product_categories';
  static const String warehouses = 'warehouses';
  static const String suppliers = 'suppliers';
  static const String purchaseOrders = 'purchase_orders';
  static const String locations = 'locations';
  static const String gpsLocations = locations;
  static const String formulas = 'formulas';

  // Accounting / Audit
  static const String accounts = 'accounts';
  static const String vouchers = 'vouchers';
  static const String voucherEntries = 'voucher_entries';
  static const String financialYears = 'financial_years';
  static const String accountingCompensationLog = 'accounting_compensation_log';
  static const String taxConfig = 'tax_config';
  static const String deletedRecords = 'deleted_records';
  static const String auditLogs = 'audit_logs';
  static const String alerts = 'alerts';
  static const String notificationEvents = 'notification_events';
  static const String syncMetrics = 'sync_metrics';
  static const String tasks = 'tasks';

  // Fleet
  static const String tyreItems = 'tyre_items';
  static const String tyreLogs = 'tyre_logs';
  static const String tyreBrands = 'tyre_brands';
  static const String vehicleMaintenanceLogs = 'vehicle_maintenance_logs';
  static const String dieselLogs = 'diesel_logs';
  static const String fuelPurchases = 'fuel_purchases';
  static const String vehicleIssues = 'vehicle_issues';

  /// Collections allowed to bypass Isar-first writes due to ephemeral volume.
  static const List<String> directFirestoreCollections = <String>[
    gpsLocations,
  ];

  /// Collections written by server-side systems only and pulled to the client.
  static const List<String> pullOnlyCollections = <String>[
    auditLogs,
    notificationEvents,
  ];

  // Legacy aliases retained for controlled migration.
  static const String legacyOpeningStock = 'opening_stock';
  static const String legacyTrips = 'trips';
  static const String legacyProductionDailyEntries = 'production_daily_entries';

  static const Map<String, String> legacyToCanonical = <String, String>{
    legacyOpeningStock: openingStockEntries,
    legacyTrips: deliveryTrips,
    legacyProductionDailyEntries: productionEntries,
  };

  /// Entity type -> Firestore collection mapping.
  static const Map<String, String?> firestoreMap = <String, String?>{
    'AccountEntity': accounts,
    'AdvanceEntity': advances,
    'AlertEntity': alerts,
    'AttendanceEntity': attendances,
    'BhattiBatchEntity': bhattiBatches,
    'BhattiDailyEntryEntity': bhattiDailyEntries,
    'CategoryEntity': productCategories,
    'ChatMessage': null,
    'ConflictEntity': null,
    'ConfigCacheEntity': null,
    'CustomerEntity': customers,
    'CustomerVisitEntity': customerVisits,
    'CustomRoleEntity': customRoles,
    'CuttingBatchEntity': cuttingBatches,
    'DealerEntity': dealers,
    'DepartmentEntity': userDepartments,
    'DepartmentMasterEntity': departmentMaster,
    'DepartmentStockEntity': departmentStocks,
    'DetailedProductionLogEntity': detailedProductionLogs,
    'DieselLogEntity': dieselLogs,
    'DispatchEntity': dispatches,
    'DutySessionEntity': dutySessions,
    'EmployeeDocumentEntity': employeeDocuments,
    'EmployeeEntity': employees,
    'FuelPurchaseEntity': fuelPurchases,
    'HolidayEntity': holidays,
    'InventoryCommandEntity': inventoryCommands,
    'InventoryLocationEntity': inventoryLocations,
    'LeaveRequestEntity': leaveRequests,
    'MaintenanceLogEntity': vehicleMaintenanceLogs,
    'OpeningStockEntity': openingStockEntries,
    'PaymentEntity': payments,
    'PayrollRecordEntity': payrollRecords,
    'PerformanceReviewEntity': performanceReviews,
    'ProductEntity': products,
    'ProductTypeEntity': productTypes,
    'ProductionDailyEntryEntity': productionEntries,
    'ProductionTargetEntity': productionTargets,
    'PurchaseOrderEntity': purchaseOrders,
    'ReturnEntity': returns,
    'RouteEntity': routes,
    'RouteOrderEntity': routeOrders,
    'RouteSessionEntity': routeSessions,
    'SaleEntity': sales,
    'SalesTargetEntity': salesTargets,
    'SchemeEntity': schemes,
    'SettingsCacheEntity': null,
    'StockBalanceEntity': stockBalances,
    'StockLedgerEntity': stockLedger,
    'StockMovementEntity': stockMovements,
    'SupplierEntity': suppliers,
    'SyncMetricEntity': syncMetrics,
    'SyncQueue': null,
    'SyncQueueEntity': null,
    'TankEntity': tanks,
    'TankLotEntity': tankLots,
    'TankTransactionEntity': tankTransactions,
    'TaskEntity': tasks,
    'TripEntity': deliveryTrips,
    'TyreLogEntity': tyreLogs,
    'TyreStockEntity': tyreItems,
    'UnitEntity': units,
    'UserEntity': users,
    'VehicleEntity': vehicles,
    'VehicleIssueEntity': vehicleIssues,
    'VoucherEntity': vouchers,
    'VoucherEntryEntity': voucherEntries,
    'WarehouseEntity': warehouses,
    'WastageLogEntity': wastageLogs,
    'AIChatMessage': null,
    'AILearningItem': null,
    'AIInsightCache': null,
    'AIBrainSettings': null,
  };

  /// Collections that require manual conflict resolution.
  static const List<String> financialCollections = <String>[
    sales,
    returns,
    payments,
    vouchers,
    voucherEntries,
  ];

  /// Master data where Firebase remains the source of truth.
  static const Set<String> firebaseWinsCollections = <String>{
    'AccountEntity',
    'UnitEntity',
    'CategoryEntity',
    'ProductTypeEntity',
    accounts,
    units,
    productCategories,
    productTypes,
  };

  /// Collections intentionally local-only.
  static const Set<String> localOnlyCollections = <String>{
    'ChatMessage',
    'AIChatMessage',
    'AILearningItem',
    'AIInsightCache',
    'AIBrainSettings',
    'SyncQueue',
    'SyncQueueEntity',
    'SettingsCacheEntity',
    'ConfigCacheEntity',
    'ConflictEntity',
  };

  /// Inventory-core collections grouped for provider and sync status summaries.
  static const Set<String> inventoryCoreCollections = <String>{
    products,
    stockMovements,
    openingStockEntries,
    stockLedger,
    departmentStocks,
    departmentMaster,
    inventoryCommands,
    inventoryLocations,
    stockBalances,
  };

  /// Returns the canonical collection name for a legacy alias.
  static String canonical(String value) => legacyToCanonical[value] ?? value;

  /// Resolves the Firestore collection for an entity type name.
  static String? firestoreCollectionForType(String typeName) {
    return firestoreMap[typeName];
  }

  /// Returns whether the entity/collection should stay local-only.
  static bool isLocalOnly(String typeNameOrCollection) {
    return localOnlyCollections.contains(typeNameOrCollection) ||
        (firestoreMap.containsKey(typeNameOrCollection) &&
            firestoreMap[typeNameOrCollection] == null);
  }

  /// Returns whether the collection should only be pulled from Firebase.
  static bool isPullOnly(String typeNameOrCollection) {
    final normalized = canonical(typeNameOrCollection);
    final mapped = firestoreCollectionForType(typeNameOrCollection);
    return pullOnlyCollections.contains(normalized) ||
        (mapped != null && pullOnlyCollections.contains(mapped));
  }

  /// Returns whether the entity/collection uses conflict logs for collisions.
  static bool isFinancial(String typeNameOrCollection) {
    final normalized = canonical(typeNameOrCollection);
    final mapped = firestoreCollectionForType(typeNameOrCollection);
    return financialCollections.contains(normalized) ||
        (mapped != null && financialCollections.contains(mapped));
  }

  /// Returns whether Firebase should always win during pull conflicts.
  static bool firebaseWins(String typeNameOrCollection) {
    return firebaseWinsCollections.contains(typeNameOrCollection);
  }
}
