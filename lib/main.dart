import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'providers/service_providers.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'core/firebase/firebase_config.dart';
import 'services/database_service.dart';
import 'services/aging_service.dart';
import 'services/audit_logs_service.dart';
import 'services/backup_service.dart';
import 'services/bhatti_service.dart';
import 'services/inventory_movement_engine.dart';
import 'services/csv_service.dart';
import 'services/data_management_service.dart';
import 'services/diesel_service.dart';
import 'services/field_encryption_service.dart';
import 'services/formulas_service.dart';
import 'services/incentives_service.dart';
import 'services/payments_service.dart';
import 'services/production_batch_service.dart';
import 'services/production_stats_service.dart';
import 'services/reports_service.dart';
import 'services/roles_service.dart';
import 'services/sales_targets_service.dart';
import 'services/tally_export_service.dart';
import 'services/tank_service.dart';
import 'services/task_history_service.dart';
import 'services/tasks_service.dart';
import 'services/users_service.dart';
import 'services/warehouse_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/trips_repository.dart';
import 'data/repositories/inventory_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/sales_repository.dart';
import 'data/repositories/returns_repository.dart';
import 'data/repositories/bhatti_repository.dart';
import 'data/repositories/production_repository.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/dealer_repository.dart';
import 'data/repositories/tank_repository.dart';
import 'services/cutting_batch_service.dart';
import 'services/gps_service.dart';
import 'services/duty_service.dart';
import 'services/visit_service.dart';
import 'services/sync_manager.dart';
import 'services/sync_common_utils.dart'; // Added
import 'services/sync_analytics_service.dart';
import 'services/conflict_service.dart';
import 'services/inventory_service.dart';
import 'services/notification_service.dart';
import 'routers/app_router.dart';
import 'providers/auth/auth_provider.dart';
import 'providers/theme_settings_provider.dart';
import 'services/alert_service.dart';
import 'services/reporting_service.dart';
import 'services/audit_log_service.dart';
import 'services/suppliers_service.dart';
import 'services/products_service.dart';
import 'services/purchase_order_service.dart';
import 'services/route_order_service.dart';
import 'services/opening_stock_service.dart';
import 'services/returns_service.dart'; // Import
import 'services/sales_service.dart';
import 'services/dealers_service.dart'; // Added Import
import 'services/department_master_service.dart';
import 'services/dispatch_service.dart';
import 'services/inventory_projection_service.dart';
import 'services/production_service.dart'; // Added Import
import 'services/schemes_service.dart';
import 'services/settings_service.dart';
import 'services/customers_service.dart';
import 'services/vehicles_service.dart';
import 'services/dealer_import_service.dart';
import 'services/sales_import_export_service.dart';
import 'services/whatsapp_invoice_pipeline_service.dart';
import 'modules/hr/services/hr_service.dart';
import 'modules/hr/services/payroll_service.dart';
import 'core/shortcuts/shortcuts_core.dart';
import 'widgets/dialogs/command_palette_dialog.dart';
import 'widgets/dialogs/shortcuts_help_dialog.dart';
import 'utils/ui_notifier.dart';
import 'utils/app_logger.dart';
import 'utils/mobile_header_typography.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_builder.dart';
import 'services/version_check_service.dart';
import 'config/changelog.dart';
import 'widgets/dialogs/whats_new_dialog.dart';
import 'screens/auth/erp_startup_splash.dart';
import 'modules/hr/services/leave_service.dart';
import 'modules/hr/services/attendance_service.dart';
import 'modules/hr/services/advance_service.dart';
import 'modules/hr/services/holiday_service.dart';
import 'modules/hr/services/performance_review_service.dart';
import 'modules/hr/services/document_service.dart';
import 'services/master_data_service.dart'; // Added Import
import 'services/accounting_migration_service.dart'; // Added
import 'services/ai_brain_service.dart'; // AI Brain for persistent chat

import 'models/types/user_types.dart';
import 'widgets/ui/app_error_boundary.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  var appMounted = false;
  var startupCompleted = false;
  var suppressedAssetManifestError = false;

  bool isGoogleFontsAssetManifestError(Object error, StackTrace stack) {
    final message = error.toString();
    if (!message.contains('AssetManifest.bin')) {
      return false;
    }
    final stackText = stack.toString();
    return stackText.contains('google_fonts') ||
        message.contains('google_fonts');
  }

  void reportUncaught(String source, Object error, StackTrace stack) {
    if (isGoogleFontsAssetManifestError(error, stack)) {
      if (!suppressedAssetManifestError) {
        suppressedAssetManifestError = true;
        AppLogger.warning(
          'Google Fonts asset manifest load failed. Falling back to default fonts for this session.',
          tag: 'App',
        );
      }
      return;
    }
    AppLogger.error(source, error: error, stackTrace: stack, tag: 'Uncaught');
  }

  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        // Allow Google Fonts to fetch from network — prevents AssetManifest.bin errors
        GoogleFonts.config.allowRuntimeFetching = true;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          reportUncaught(
            'Uncaught Flutter Framework Error',
            details.exception,
            details.stack ?? StackTrace.current,
          );
          if (originalOnError != null) {
            originalOnError(details);
          }
        };
        ui
            .PlatformDispatcher
            .instance
            .onError = (Object error, StackTrace stack) {
          reportUncaught('Uncaught Platform Dispatcher Error', error, stack);
          return true;
        };
        ErrorWidget.builder = (FlutterErrorDetails details) {
          reportUncaught(
            'Uncaught UI Build Error',
            details.exception,
            details.stack ?? StackTrace.current,
          );
          return AppErrorFallbackUi(errorDetails: details);
        };

        AppLogger.info('App Starting...', tag: 'App');

        // 1. Initialize Firebase
        await firebaseServices.initialize();

        // 2. Initialize Database
        final databaseService = DatabaseService();
        await databaseService.init();
        final fieldEncryptionService = FieldEncryptionService.instance;
        await fieldEncryptionService.initialize();

        // 2a. Prepare Accounting Migration (SharedPrefs -> Isar)
        final accountingMigration = AccountingMigrationService(databaseService);

        // 3. Initialize Repositories and Services
        final authRepo = AuthRepository(
          databaseService,
          firebaseServices.auth,
          firebaseServices.db,
        );
        final tripsRepo = TripsRepository(databaseService);
        final inventoryRepo = InventoryRepository(databaseService);
        final userRepo = UserRepository(databaseService);
        final salesRepo = SalesRepository(databaseService);
        final returnsRepo = ReturnsRepository(databaseService);
        final bhattiRepo = BhattiRepository(databaseService, firebaseServices);

        final customerRepo = CustomerRepository(databaseService);
        final dealerRepo = DealerRepository(databaseService);
        final tankRepo = TankRepository(databaseService, firebaseServices);
        final gpsService = GpsService(firebaseServices);
        final dutyService = DutyService(
          firebaseServices,
          gpsService,
          databaseService,
        );
        final visitService = VisitService(firebaseServices, databaseService);
        final alertService = AlertService(databaseService);
        final notificationService = NotificationService();
        final reportingService = ReportingService();
        final auditLogService = AuditLogService(databaseService);

        final inventoryService = InventoryService(
          firebaseServices,
          databaseService,
        );
        final suppliersService = SuppliersService(firebaseServices);

        final salesService = SalesService(
          firebaseServices,
          databaseService,
          inventoryService,
        );

        final customersService = CustomersService(firebaseServices);
        final dealersService = DealersService(
          firebaseServices,
          databaseService,
        ); // Added DealersService

        final returnsService = ReturnsService(
          firebaseServices,
          databaseService,
          inventoryService,
          customersService,
          salesService,
        );

        final productionRepo = ProductionRepository(
          databaseService,
          firebaseServices,
          inventoryService,
        );
        final dispatchService = DispatchService(
          firebaseServices,
          databaseService,
        );

        final vehiclesService = VehiclesService(firebaseServices);
        final syncAnalyticsService = SyncAnalyticsService(databaseService);
        final conflictService = ConflictService(databaseService);

        final hrService = HrService(firebaseServices, databaseService);
        final leaveService = LeaveService(databaseService, hrService);
        final attendanceService = AttendanceService(
          firebaseServices,
          databaseService,
        );
        final advanceService = AdvanceService(databaseService, hrService);
        final performanceReviewService = PerformanceReviewService(
          databaseService,
        );
        final holidayService = HolidayService(
          firebaseServices,
          databaseService,
        );
        final documentService = DocumentService(databaseService);
        final payrollService = PayrollService(
          firebaseServices,
          dutyService,
          hrService,
          databaseService,
          advanceService,
        );

        final masterDataService = MasterDataService(
          firebaseServices,
          databaseService,
        );
        final departmentMasterService = DepartmentMasterService(
          databaseService,
        );
        final inventoryProjectionService = InventoryProjectionService(
          databaseService,
          departmentMasterService: departmentMasterService,
        );

        final tankService = TankService(firebaseServices, databaseService);

        final inventoryMovementEngine = InventoryMovementEngine(
          databaseService,
          inventoryProjectionService,
        );

        final productionService = ProductionService(
          firebaseServices,
          inventoryService,
          databaseService,
          inventoryMovementEngine: inventoryMovementEngine,
        );

        final cuttingService = CuttingBatchService(
          firebaseServices,
          databaseService,
          inventoryMovementEngine,
        );

        final bhattiService = BhattiService(
          firebaseServices,
          databaseService,
          tankService,
          inventoryService,
          inventoryMovementEngine,
        );
        final dieselService = DieselService(firebaseServices);
        final usersService = UsersService(firebaseServices, databaseService);
        final productsService = ProductsService(
          firebaseServices,
          databaseService,
        );
        final paymentsService = PaymentsService(firebaseServices);
        final reportsService = ReportsService(firebaseServices);
        final productionBatchService = ProductionBatchService(firebaseServices);
        final productionStatsService = ProductionStatsService();
        final salesTargetsService = SalesTargetsService(firebaseServices);
        final incentivesService = IncentivesService(firebaseServices);
        final formulasService = FormulasService(firebaseServices);
        final rolesService = RolesService(firebaseServices);
        final auditLogsService = AuditLogsService(firebaseServices);
        final backupService = BackupService(firebaseServices);
        final dataManagementService = DataManagementService(firebaseServices);
        final tallyExportService = TallyExportService(firebaseServices);
        final tasksService = TasksService(firebaseServices);
        final taskHistoryService = TaskHistoryService(firebaseServices);
        final agingService = AgingService(firebaseServices);
        final csvService = CsvService();
        final warehouseService = WarehouseService();
        final routeOrderService = RouteOrderService(
          firebaseServices,
          inventoryService,
          usersService,
          productsService,
          alertService,
        );

        final syncUtils = SyncCommonUtils(
          dbService: databaseService,
          analyticsService: syncAnalyticsService,
        );

        final syncManager = SyncManager(
          databaseService,
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
          cuttingService,
          payrollService, // Added
          attendanceService, // Injected
          masterDataService, // Injected
          routeOrderService,
          bhattiRepo,
          productionRepo,
          syncUtils,
        );

        // Legacy service entry points are routed via SyncManager delegates/queue.
        usersService.bindCentralUsersSync(
          () => syncManager.syncUsersViaDelegate(forceRefresh: true),
        );
        salesTargetsService.bindCentralQueueSync(syncManager.processSyncQueue);
        salesService.bindCentralQueueSync(syncManager.processSyncQueue);
        productionService.bindCentralQueueSync(syncManager.processSyncQueue);
        bhattiService.bindCentralQueueSync(syncManager.processSyncQueue);
        cuttingService.bindCentralQueueSync(syncManager.processSyncQueue);

        final authProvider = AuthProvider(firebaseServices, authRepo);
        fieldEncryptionService.scheduleMigration(databaseService);

        // Initialize Settings Service
        // LOCKED: Added SettingsService to MultiProvider - 2026-02-02
        final settingsService = SettingsService(firebaseServices);
        final dealerImportService = DealerImportService(dealerRepo);
        final salesImportExportService = SalesImportExportService(
          customersService,
          usersService,
          productsService,
          salesService,
        );
        // Moved above SyncManager instantiation
        // final hrService = HrService(databaseService);
        // final payrollService = PayrollService(...);

        runApp(
          rp.ProviderScope(
            overrides: [
              authProviderProvider.overrideWith((ref) => authProvider),
              syncManagerProvider.overrideWith((ref) => syncManager),
              tasksServiceProvider.overrideWith((ref) => tasksService),
              databaseServiceProvider.overrideWith((ref) => databaseService),
              alertServiceProvider.overrideWith((ref) => alertService),
              inventoryServiceProvider.overrideWith((ref) => inventoryService),
              salesServiceProvider.overrideWith((ref) => salesService),
              returnsServiceProvider.overrideWith((ref) => returnsService),
              dispatchServiceProvider.overrideWith((ref) => dispatchService),
              productionServiceProvider.overrideWith(
                (ref) => productionService,
              ),
              payrollServiceProvider.overrideWith(
                (ref) => payrollService,
              ), // Wait, payrollService variable exists
              attendanceServiceProvider.overrideWith(
                (ref) => attendanceService,
              ),
              masterDataServiceProvider.overrideWith(
                (ref) => masterDataService,
              ),
              vehiclesServiceProvider.overrideWith((ref) => vehiclesService),
              suppliersServiceProvider.overrideWith((ref) => suppliersService),
              customersServiceProvider.overrideWith((ref) => customersService),
              usersServiceProvider.overrideWith((ref) => usersService),
              productsServiceProvider.overrideWith((ref) => productsService),
              routeOrderServiceProvider.overrideWith(
                (ref) => routeOrderService,
              ),
            ],
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: authProvider),
                ChangeNotifierProvider(create: (_) => syncManager),
                Provider.value(value: databaseService),
                Provider.value(value: tripsRepo),
                Provider.value(value: inventoryRepo),
                Provider.value(value: inventoryService),
                Provider.value(value: customersService),
                Provider.value(value: dealersService), // Added Provider
                Provider.value(value: usersService),
                Provider.value(value: dieselService),
                ChangeNotifierProvider.value(value: vehiclesService),
                Provider.value(value: dispatchService),
                Provider.value(value: tankService),
                Provider.value(value: bhattiService),
                Provider.value(value: paymentsService),
                Provider.value(value: reportsService),
                Provider.value(value: productionBatchService),
                Provider.value(value: productionStatsService),
                Provider.value(value: salesTargetsService),
                Provider.value(value: incentivesService),
                Provider.value(value: formulasService),
                Provider.value(value: rolesService),
                Provider.value(value: auditLogsService),
                Provider.value(value: backupService),
                Provider.value(value: dataManagementService),
                Provider.value(value: tallyExportService),
                Provider.value(value: tasksService),
                Provider.value(value: taskHistoryService),
                Provider.value(value: agingService),
                Provider.value(value: csvService),
                Provider.value(value: warehouseService),
                Provider.value(value: routeOrderService),
                Provider.value(value: returnsService), // Provide
                Provider.value(value: userRepo),
                Provider.value(value: salesRepo),
                Provider.value(value: salesService), // Added Provider
                Provider.value(value: returnsRepo),
                Provider.value(value: bhattiRepo),
                Provider.value(value: productionRepo),
                Provider.value(value: customerRepo),
                Provider.value(value: dealerRepo),
                Provider.value(value: tankRepo),
                Provider.value(value: cuttingService),
                Provider.value(value: dutyService),
                Provider.value(value: gpsService), // Added Missing Provider
                Provider.value(value: visitService),
                ChangeNotifierProvider.value(value: alertService),
                Provider.value(value: reportingService),
                Provider.value(value: auditLogService),
                Provider.value(value: settingsService), // Added Provider
                // Procurement Services
                Provider.value(value: suppliersService),
                Provider.value(value: productsService),
                Provider(
                  create: (_) => PurchaseOrderService(
                    firebaseServices,
                    inventoryService,
                    vehiclesService,
                  ),
                ),
                // LOCKED: Added SchemesService Provider - 2026-02-02
                Provider(
                  create: (_) =>
                      SchemesService(firebaseServices, databaseService),
                ),
                Provider.value(value: syncAnalyticsService),
                Provider.value(value: syncUtils), // Added
                Provider.value(value: conflictService),
                Provider.value(
                  value: OpeningStockService(
                    databaseService,
                    inventoryMovementEngine,
                  ),
                ),
                Provider.value(value: dealerImportService),
                Provider.value(value: salesImportExportService),
                ChangeNotifierProvider.value(value: hrService),
                ChangeNotifierProvider.value(value: leaveService),
                ChangeNotifierProvider.value(value: attendanceService),
                ChangeNotifierProvider.value(value: holidayService),
                ChangeNotifierProvider.value(value: advanceService),
                ChangeNotifierProvider.value(value: performanceReviewService),
                ChangeNotifierProvider.value(value: documentService),
                ChangeNotifierProvider.value(value: payrollService),
                Provider<MasterDataService>.value(value: masterDataService),
                Provider.value(value: productionService),
                // AI Brain Service
                ChangeNotifierProvider(
                  create: (_) => AIBrainService(databaseService.db),
                ),
              ],
              child: DattSoapApp(authProvider: authProvider),
            ),
          ),
        );
        appMounted = true;
        startupCompleted = true;

        // Do not block startup/dashboard routing on migration.
        unawaited(accountingMigration.migrate());
        unawaited(_bootstrapCanonicalInventory(inventoryProjectionService));
        unawaited(
          Future<void>.delayed(
            const Duration(seconds: 8),
            () => _bootstrapCanonicalInventory(inventoryProjectionService),
          ),
        );

        unawaited(
          _postRunBootstrap(
            authProvider: authProvider,
            syncManager: syncManager,
            gpsService: gpsService,
            usersService: usersService,
            notificationService: notificationService,
          ),
        );
      } catch (e, stack) {
        AppLogger.error('Initialization Error', error: e, stackTrace: stack);
        runApp(ErrorApp(error: e, stackTrace: stack));
        appMounted = true;
        startupCompleted = false;
      }
    },
    (error, stack) {
      reportUncaught('Uncaught Error in Zone', error, stack);

      // Do not re-run the app tree after startup; it causes zone mismatch and
      // can destabilize the current session.
      if (!appMounted && !startupCompleted) {
        runApp(ErrorApp(error: error, stackTrace: stack));
      }
    },
  );
}

Future<void> _awaitAuthReady(AuthProvider authProvider) async {
  if (!authProvider.state.loading) {
    return;
  }

  final completer = Completer<void>();

  void listener() {
    if (!authProvider.state.loading) {
      authProvider.removeListener(listener);
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  authProvider.addListener(listener);

  if (!authProvider.state.loading) {
    authProvider.removeListener(listener);
    return;
  }

  await completer.future;
}

Future<void> _postRunBootstrap({
  required AuthProvider authProvider,
  required SyncManager syncManager,
  required GpsService gpsService,
  required UsersService usersService,
  required NotificationService notificationService,
}) async {
  // [CLEANUP] Wire logout cleanup early
  authProvider.setOnSignOut(() async {
    syncManager.cleanup();
    gpsService.stopTracking();
    unawaited(() async {
      try {
        await notificationService.unbindUser().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            AppLogger.warning(
              'Notification unbind timed out during sign-out',
              tag: 'App',
            );
          },
        );
      } catch (e) {
        AppLogger.warning(
          'Notification cleanup during sign-out failed: $e',
          tag: 'App',
        );
      }
    }());
    AppLogger.info('Global cleanup executed on sign-out', tag: 'App');
  });

  AppLogger.info('AuthProvider: Initializing...', tag: 'App');
  await authProvider.initialize();
  await _awaitAuthReady(authProvider);
  AppLogger.success('AuthProvider: Initialized', tag: 'App');
  await notificationService.initialize();
  unawaited(WhatsAppInvoicePipelineService.instance.processPendingJobs());

  final currentUser = authProvider.state.user;
  final canBootstrapAccountant =
      currentUser != null &&
      (currentUser.role == UserRole.admin ||
          currentUser.role == UserRole.owner);
  if (canBootstrapAccountant) {
    final created = await usersService.ensureAccountantBootstrapUser(
      bootstrapByUserId: currentUser.id,
    );
    if (created) {
      AppLogger.success('Bootstrap accountant user created', tag: 'App');
    } else {
      AppLogger.info('Bootstrap accountant user already exists', tag: 'App');
    }
  }

  AppLogger.info('SyncManager: Initializing...', tag: 'App');
  syncManager.initialize();
  String? lastBootstrappedUserId;
  Timer? deferredSyncBootstrapTimer;

  void scheduleDeferredBootstrap(AppUser user) {
    deferredSyncBootstrapTimer?.cancel();
    deferredSyncBootstrapTimer = Timer(const Duration(seconds: 4), () {
      final latestUser = authProvider.state.user;
      if (latestUser == null || latestUser.id != user.id) return;
      syncManager.setCurrentUser(latestUser, triggerBootstrap: true);
    });
  }

  void wireSyncUserContext() {
    final user = authProvider.state.user;
    if (user == null) {
      lastBootstrappedUserId = null;
      deferredSyncBootstrapTimer?.cancel();
      syncManager.cleanup(notify: false);
      return;
    }

    // Update role context immediately, but don't kick heavy bootstrap yet.
    syncManager.setCurrentUser(user, triggerBootstrap: false);

    // CRITICAL FIX: Always bootstrap if user changed, even if same ID
    // (handles logout -> login with same user scenario)
    if (lastBootstrappedUserId == user.id) {
      // User already bootstrapped, skip
      return;
    }
    lastBootstrappedUserId = user.id;
    scheduleDeferredBootstrap(user);
  }

  authProvider.addListener(wireSyncUserContext);
  wireSyncUserContext();

  void wireNotificationUserContext() {
    final authState = authProvider.state;
    final user = authState.user;
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (authState.status != AuthStatus.authenticated ||
        user == null ||
        firebaseUser == null) {
      unawaited(notificationService.unbindUser());
      return;
    }
    unawaited(notificationService.bindUser(user));
  }

  authProvider.addListener(wireNotificationUserContext);
  wireNotificationUserContext();
  AppLogger.success('SyncManager: Initialized', tag: 'App');
}

Future<void> _bootstrapCanonicalInventory(
  InventoryProjectionService inventoryProjectionService,
) async {
  try {
    await inventoryProjectionService.ensureCanonicalFoundation();
  } catch (e, stack) {
    AppLogger.warning(
      'Canonical inventory bootstrap skipped: $e',
      tag: 'InventoryProjection',
    );
    AppLogger.debug(stack.toString(), tag: 'InventoryProjection');
  }
}

class DattSoapApp extends rp.ConsumerStatefulWidget {
  final AuthProvider authProvider;
  const DattSoapApp({super.key, required this.authProvider});

  @override
  rp.ConsumerState<DattSoapApp> createState() => _DattSoapAppState();
}

class _DattSoapAppState extends rp.ConsumerState<DattSoapApp>
    with WidgetsBindingObserver {
  bool _shutdownStarted = false;
  bool _showStartupSplash = true;
  bool _startupMinimumElapsed = false;
  bool _startupAuthReady = false;
  bool _startupRouterFrameReady = false;
  bool _userInitiatedLogin = false;
  Timer? _startupSplashTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startupAuthReady = !widget.authProvider.state.loading;
    widget.authProvider.addListener(_handleStartupAuthState);
    _startStartupSplashGate();

    // Check for updates and show What's New
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    final syncManager = context.read<SyncManager>();
    syncManager.handleAppLifecycle(state);
    if (state == AppLifecycleState.detached) {
      unawaited(_shutdownAppServices());
    }
  }

  @override
  void dispose() {
    _startupSplashTimer?.cancel();
    widget.authProvider.removeListener(_handleStartupAuthState);
    unawaited(_shutdownAppServices());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleStartupAuthState() {
    final authReady = !widget.authProvider.state.loading;
    if (_startupAuthReady == authReady) return;
    _startupAuthReady = authReady;
    _tryHideStartupSplash();
  }

  void _startStartupSplashGate() {
    _startupSplashTimer?.cancel();
    _startupMinimumElapsed = false;
    _startupSplashTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || _startupMinimumElapsed) return;
      _startupMinimumElapsed = true;
      _tryHideStartupSplash();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_precacheStartupAssets());
    });
  }

  void _markRouterFrameReady() {
    if (_startupRouterFrameReady) return;
    _startupRouterFrameReady = true;
    _tryHideStartupSplash();
  }

  void _tryHideStartupSplash() {
    if (!mounted || !_showStartupSplash) return;
    final isAuthenticated = widget.authProvider.isAuthenticated;
    final canHide =
        _startupMinimumElapsed &&
        _startupAuthReady &&
        _startupRouterFrameReady &&
        (isAuthenticated || _userInitiatedLogin);

    if (!canHide) return;
    setState(() => _showStartupSplash = false);
  }

  Future<void> _precacheStartupAssets() async {
    Future<void> warm(String assetPath) async {
      try {
        await precacheImage(AssetImage(assetPath), context);
      } catch (_) {
        // Silent: warm-up is best-effort.
      }
    }

    await warm('assets/images/company-logo.png');
    await warm('assets/images/loginpage.png');
  }

  Future<void> _shutdownAppServices() async {
    if (_shutdownStarted) return;
    _shutdownStarted = true;

    try {
      context.read<SyncManager>().cleanup(notify: false);
    } catch (e) {
      AppLogger.warning(
        'Sync cleanup during app shutdown failed: $e',
        tag: 'App',
      );
    }

    try {
      context.read<GpsService>().stopTracking();
    } catch (e) {
      AppLogger.warning(
        'GPS cleanup during app shutdown failed: $e',
        tag: 'App',
      );
    }

    try {
      final notificationService = context.read<NotificationService>();
      await notificationService.unbindUser();
      await notificationService.dispose();
    } catch (e) {
      AppLogger.warning(
        'Notification cleanup during app shutdown failed: $e',
        tag: 'App',
      );
    }
  }

  Future<void> _checkUpdate() async {
    try {
      // Give the router/navigator time to fully initialize
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final versionService = VersionCheckService();
      final check = await versionService.checkNewVersion();

      if (check && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const WhatsNewDialog(
            version: AppChangelog.currentVersion,
            changes: AppChangelog.changes,
          ),
        );
      }
    } catch (e) {
      // Silently ignore version check errors on startup
      debugPrint('Version check skipped: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeSettingsProvider);
    final settings = themeState.settings;
    final isWindowsDesktop =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final lightTheme = ThemeBuilder.build(
      AppTheme.lightTheme,
      settings,
      Brightness.light,
    );
    final darkTheme = ThemeBuilder.build(
      AppTheme.darkTheme,
      settings,
      Brightness.dark,
    );

    return MaterialApp.router(
      title: 'DattSoap ERP',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: UINotifier.scaffoldMessengerKey,
      // Windows engine currently logs noisy accessibility announce errors for
      // route notifications (`viewId` mismatch). Handle navigation notification
      // explicitly on Windows to prevent repeated noisy engine errors.
      onNavigationNotification: isWindowsDesktop ? (_) => true : null,
      builder: (context, child) {
        if (!_startupRouterFrameReady && child != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _startupRouterFrameReady) return;
            _markRouterFrameReady();
          });
        }
        final width = MediaQuery.sizeOf(context).width;
        final themed = applyMobileHeaderTheme(Theme.of(context), width);
        return Theme(
          data: themed,
          child: GlobalShortcutsWrapper(
            // Ctrl + K: Open Command Palette
            onSearch: (ctx) {
              final navContext = UINotifier.navigatorKey.currentContext;
              if (navContext != null) {
                showDialog(
                  context: navContext,
                  builder: (_) => const CommandPaletteDialog(),
                );
              }
            },
            // Ctrl + R: Manual Sync
            onSync: (ctx) {
              final syncManager = ctx.read<SyncManager>();
              final authProvider = ctx.read<AuthProvider>();
              syncManager.syncAll(authProvider.currentUser);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Sync started...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            // Ctrl + /: Show Shortcuts Help
            onHelp: (ctx) {
              final navContext = UINotifier.navigatorKey.currentContext;
              if (navContext != null) {
                showDialog(
                  context: navContext,
                  builder: (_) => const ShortcutsHelpDialog(),
                );
              }
            },
            // Ctrl + N: Open Command Palette for New Item
            onNewItem: (ctx) {
              final navContext = UINotifier.navigatorKey.currentContext;
              if (navContext != null) {
                showDialog(
                  context: navContext,
                  builder: (_) => const CommandPaletteDialog(),
                );
              }
            },
            // Ctrl + T: New Tab (handled by MainScaffold)
            onNewTab: (ctx) {
              final state = UINotifier.mainScaffoldKey.currentState;
              if (state != null) {
                // Dynamic dispatch to avoid import cycle/coupling
                (state as dynamic).openNewTab('/dashboard');
              }
            },
            // Ctrl + W: Close Tab (handled by MainScaffold)
            onCloseTab: (ctx) {
              final state = UINotifier.mainScaffoldKey.currentState;
              if (state != null) {
                // Dynamic dispatch to avoid import cycle/coupling
                (state as dynamic).closeActiveTab();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                child!,
                if (_showStartupSplash)
                  Positioned.fill(
                    child: ErpStartupSplash(
                      onLoginAction: () {
                        setState(() => _userInitiatedLogin = true);
                        _tryHideStartupSplash();
                      },
                      onBiometricAction: () {
                        setState(() => _userInitiatedLogin = true);
                        _tryHideStartupSplash();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorApp({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Critical Initialization Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (stackTrace != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black26,
                      child: Text(
                        stackTrace.toString(),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
