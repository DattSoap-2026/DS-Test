import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/department_master_service.dart';
import '../services/alert_service.dart';
import '../services/inventory_projection_service.dart';
import '../services/inventory_movement_engine.dart';
import '../services/master_data_service.dart';
import '../services/vehicles_service.dart';
import '../services/tank_service.dart';
import '../data/repositories/tank_repository.dart';
import '../services/suppliers_service.dart';
import '../services/purchase_order_service.dart';
import '../services/inventory_service.dart';
import '../services/sales_service.dart';
import '../services/customers_service.dart';
import '../services/returns_service.dart';
import '../services/dispatch_service.dart';
import '../services/production_service.dart';
import '../services/bhatti_service.dart';
import '../services/cutting_batch_service.dart';
import '../modules/hr/services/payroll_service.dart';
import '../modules/hr/services/hr_service.dart';
import '../modules/hr/services/advance_service.dart';
import '../modules/hr/services/attendance_service.dart';
import '../services/route_order_service.dart';
import '../services/sync_analytics_service.dart';
import '../services/sync_common_utils.dart';
import '../services/sync_manager.dart';
import '../services/tasks_service.dart';
import '../services/users_service.dart';
import '../services/products_service.dart';
import '../data/repositories/bhatti_repository.dart';
import '../data/repositories/production_repository.dart';
import '../services/duty_service.dart';
import '../services/gps_service.dart';
import '../core/firebase/firebase_config.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final departmentMasterServiceProvider = Provider<DepartmentMasterService>((
  ref,
) {
  final db = ref.watch(databaseServiceProvider);
  return DepartmentMasterService(db);
});

final inventoryProjectionServiceProvider = Provider<InventoryProjectionService>(
  (ref) {
    final db = ref.watch(databaseServiceProvider);
    final departmentMasterService = ref.watch(departmentMasterServiceProvider);
    return InventoryProjectionService(
      db,
      departmentMasterService: departmentMasterService,
    );
  },
);

final Provider<InventoryMovementEngine> inventoryMovementEngineProvider =
    Provider<InventoryMovementEngine>((ref) {
      final db = ref.watch(databaseServiceProvider);
      final projectionService = ref.watch(inventoryProjectionServiceProvider);
      return InventoryMovementEngine(
        db,
        projectionService,
      );
    });

final alertServiceProvider = Provider<AlertService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return AlertService(db, firebaseServices);
});

final masterDataServiceProvider = Provider<MasterDataService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return MasterDataService(firebaseServices, db);
});

final vehiclesServiceProvider = Provider<VehiclesService>((ref) {
  return VehiclesService(firebaseServices);
});

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return InventoryService(firebaseServices, db);
});

final tankServiceProvider = Provider<TankService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return TankService(firebaseServices, db);
});

final tankRepositoryProvider = Provider<TankRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return TankRepository(db, firebaseServices);
});

final suppliersServiceProvider = Provider<SuppliersService>((ref) {
  return SuppliersService(firebaseServices);
});

final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  final vehiclesService = ref.watch(vehiclesServiceProvider);
  return PurchaseOrderService(
    firebaseServices,
    inventoryService,
    vehiclesService,
  );
});

final salesServiceProvider = Provider<SalesService>((ref) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return SalesService(firebaseServices, db, inventoryService);
});

final customersServiceProvider = Provider<CustomersService>((ref) {
  return CustomersService(firebaseServices);
});

final usersServiceProvider = Provider<UsersService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return UsersService(firebaseServices, db);
});

final productsServiceProvider = Provider<ProductsService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ProductsService(firebaseServices, db);
});

final returnsServiceProvider = Provider<ReturnsService>((ref) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  final customersService = ref.watch(customersServiceProvider);
  final salesService = ref.watch(salesServiceProvider);
  return ReturnsService(
    firebaseServices,
    db,
    inventoryService,
    customersService,
    salesService,
  );
});

final dispatchServiceProvider = Provider<DispatchService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return DispatchService(firebaseServices, db);
});

final productionServiceProvider = Provider<ProductionService>((ref) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  final inventoryMovementEngine = ref.watch(inventoryMovementEngineProvider);
  final db = ref.watch(databaseServiceProvider);
  return ProductionService(
    firebaseServices,
    inventoryService,
    db,
    inventoryMovementEngine: inventoryMovementEngine,
  );
});

final cuttingBatchServiceProvider = Provider<CuttingBatchService>((ref) {
  final inventoryMovementEngine = ref.watch(inventoryMovementEngineProvider);
  final db = ref.watch(databaseServiceProvider);
  return CuttingBatchService(
    firebaseServices,
    db,
    inventoryMovementEngine,
  );
});

final Provider<BhattiService> bhattiServiceProvider = Provider<BhattiService>((
  ref,
) {
  final db = ref.watch(databaseServiceProvider);
  final tankService = ref.watch(tankServiceProvider);
  final inventoryService = ref.watch(inventoryServiceProvider);
  final engine = ref.watch(inventoryMovementEngineProvider);
  return BhattiService(
    firebaseServices,
    db,
    tankService,
    inventoryService,
    engine,
  );
});

final hrServiceProvider = Provider<HrService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return HrService(firebaseServices, db);
});

final gpsServiceProvider = Provider<GpsService>((ref) {
  return GpsService(firebaseServices);
});

final dutyServiceProvider = Provider<DutyService>((ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return DutyService(firebaseServices, gpsService, db);
});

final advanceServiceProvider = Provider<AdvanceService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final hrService = ref.watch(hrServiceProvider);
  return AdvanceService(db, hrService);
});

final payrollServiceProvider = Provider<PayrollService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final hrService = ref.watch(hrServiceProvider);
  final dutyService = ref.watch(dutyServiceProvider);
  final advanceService = ref.watch(advanceServiceProvider);
  return PayrollService(
    firebaseServices,
    dutyService,
    hrService,
    db,
    advanceService,
  );
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return AttendanceService(firebaseServices, db);
});

final routeOrderServiceProvider = Provider<RouteOrderService>((ref) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  final usersService = ref.watch(usersServiceProvider);
  final productsService = ref.watch(productsServiceProvider);
  final alertService = ref.watch(alertServiceProvider);
  return RouteOrderService(
    firebaseServices,
    inventoryService,
    usersService,
    productsService,
    alertService,
  );
});

final syncAnalyticsServiceProvider = Provider<SyncAnalyticsService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SyncAnalyticsService(db);
});

final bhattiRepositoryProvider = Provider<BhattiRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return BhattiRepository(db, firebaseServices);
});

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final inventoryService = ref.watch(inventoryServiceProvider);
  return ProductionRepository(db, firebaseServices, inventoryService);
});

final syncCommonUtilsProvider = Provider<SyncCommonUtils>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final analyticsService = ref.watch(syncAnalyticsServiceProvider);
  return SyncCommonUtils(dbService: db, analyticsService: analyticsService);
});

final ChangeNotifierProvider<SyncManager> syncManagerProvider =
    ChangeNotifierProvider<SyncManager>((ref) {
      final db = ref.watch(databaseServiceProvider);
      final suppliersService = ref.watch(suppliersServiceProvider);
      final alertService = ref.watch(alertServiceProvider);
      final vehiclesService = ref.watch(vehiclesServiceProvider);
      final syncAnalyticsService = ref.watch(syncAnalyticsServiceProvider);
      final salesService = ref.watch(salesServiceProvider);
      final inventoryService = ref.watch(inventoryServiceProvider);
      final returnsService = ref.watch(returnsServiceProvider);
      final dispatchService = ref.watch(dispatchServiceProvider);
      final productionService = ref.watch(productionServiceProvider);
      final bhattiService = ref.watch(bhattiServiceProvider);
      final cuttingBatchService = ref.watch(cuttingBatchServiceProvider);
      final payrollService = ref.watch(payrollServiceProvider);
      final attendanceService = ref.watch(attendanceServiceProvider);
      final masterDataService = ref.watch(masterDataServiceProvider);
      final routeOrderService = ref.watch(routeOrderServiceProvider);
      final bhattiRepo = ref.watch(bhattiRepositoryProvider);
      final productionRepo = ref.watch(productionRepositoryProvider);
      final syncUtils = ref.watch(syncCommonUtilsProvider);

      final syncManager = SyncManager(
        db,
        firebaseServices,
        suppliersService,
        alertService,
        vehiclesService,
        syncAnalyticsService,
        salesService,
        inventoryService,
        returnsService,
        dispatchService,
        productionService,
        bhattiService,
        cuttingBatchService,
        payrollService,
        attendanceService,
        masterDataService,
        routeOrderService,
        bhattiRepo,
        productionRepo,
        syncUtils,
      );
      salesService.bindCentralQueueSync(syncManager.processSyncQueue);
      productionService.bindCentralQueueSync(syncManager.processSyncQueue);
      bhattiService.bindCentralQueueSync(syncManager.processSyncQueue);
      cuttingBatchService.bindCentralQueueSync(syncManager.processSyncQueue);
      return syncManager;
    });

final tasksServiceProvider = Provider<TasksService>((ref) {
  return TasksService(firebaseServices);
});
