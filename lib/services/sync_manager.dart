import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/dealer_entity.dart';

import 'package:flutter_app/data/local/entities/alert_entity.dart';
import 'package:flutter_app/data/local/entities/duty_session_entity.dart';
import 'package:flutter_app/data/local/entities/route_session_entity.dart';
import 'package:flutter_app/data/local/entities/customer_visit_entity.dart';
import 'package:flutter_app/data/local/entities/dispatch_entity.dart';
import 'package:flutter_app/data/local/entities/opening_stock_entity.dart';
import 'package:flutter_app/data/local/entities/stock_ledger_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';

import 'package:flutter_app/data/local/entities/conflict_entity.dart';
import 'package:flutter_app/data/local/entities/vehicle_entity.dart';
import 'package:flutter_app/data/local/entities/route_entity.dart';
import 'package:flutter_app/data/local/entities/diesel_log_entity.dart';
import 'package:flutter_app/data/local/entities/sales_target_entity.dart';
import 'package:flutter_app/data/local/entities/unit_entity.dart';
import 'package:flutter_app/data/local/entities/category_entity.dart';
import 'package:flutter_app/data/local/entities/product_type_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/models/types/alert_types.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/core/sync/targeted_pull_sync_executor.dart';
import 'package:flutter_app/core/sync/sync_service.dart';
import 'package:flutter_app/core/sync/sync_queue_service.dart';

import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/repositories/bhatti_repository.dart';
import 'package:flutter_app/data/repositories/production_repository.dart';
import 'package:flutter_app/services/suppliers_service.dart';
import 'package:flutter_app/services/vehicles_service.dart';
import 'package:flutter_app/services/alert_service.dart';
import 'package:flutter_app/services/sync_analytics_service.dart';

import 'package:flutter_app/services/field_encryption_service.dart';
import 'package:flutter_app/utils/app_logger.dart';
import 'package:flutter_app/services/sales_service.dart';
import 'package:flutter_app/services/returns_service.dart';
import 'package:flutter_app/services/dispatch_service.dart';
import 'package:flutter_app/services/route_order_service.dart';
import 'package:flutter_app/services/bhatti_service.dart';
import 'package:flutter_app/services/cutting_batch_service.dart';
import 'package:flutter_app/services/production_service.dart'; // Added
import 'package:flutter_app/services/payments_service.dart';
import 'package:flutter_app/modules/hr/services/payroll_service.dart';
import 'package:flutter_app/modules/hr/services/attendance_service.dart';
import 'package:flutter_app/data/local/entities/attendance_entity.dart';
import 'package:flutter_app/data/local/entities/leave_request_entity.dart';
import 'package:flutter_app/data/local/entities/advance_entity.dart';
import 'package:flutter_app/data/local/entities/performance_review_entity.dart';
import 'package:flutter_app/data/local/entities/employee_document_entity.dart';
import 'package:flutter_app/data/local/entities/employee_entity.dart';
import 'package:flutter_app/data/local/entities/custom_role_entity.dart';

import 'package:flutter_app/services/master_data_service.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/services/outbox_codec.dart';

import 'package:flutter_app/services/delegates/master_data_sync_delegate.dart';
import 'package:flutter_app/services/delegates/sales_sync_delegate.dart';
import 'package:flutter_app/services/delegates/inventory_sync_delegate.dart';
import 'package:flutter_app/services/delegates/hr_sync_delegate.dart';
import 'package:flutter_app/services/delegates/accounting_sync_delegate.dart';
import 'package:flutter_app/services/delegates/customers_sync_delegate.dart';
import 'package:flutter_app/services/delegates/dealers_sync_delegate.dart';
import 'package:flutter_app/services/delegates/duty_sessions_sync_delegate.dart';
import 'package:flutter_app/services/delegates/partner_outbox_delegate.dart';
import 'package:flutter_app/services/delegates/queue_modules_sync_delegate.dart';
import 'package:flutter_app/services/delegates/sync_queue_processor_delegate.dart';
import 'package:flutter_app/services/delegates/users_sync_delegate.dart';
import 'package:flutter_app/services/sync_common_utils.dart'; // Added

class SyncRunResult {
  final bool executed;
  final bool skipped;
  final List<String> criticalErrors;
  final int outboxPendingCount;
  final int outboxPermanentFailureCount;
  final int unresolvedConflictCount;
  final DateTime completedAt;
  final String? message;
  final Map<String, int> pendingByModule;

  const SyncRunResult({
    required this.executed,
    required this.skipped,
    required this.criticalErrors,
    required this.outboxPendingCount,
    required this.outboxPermanentFailureCount,
    required this.unresolvedConflictCount,
    required this.completedAt,
    this.pendingByModule = const <String, int>{},
    this.message,
  });

  factory SyncRunResult.skipped(String reason) {
    return SyncRunResult(
      executed: false,
      skipped: true,
      criticalErrors: [reason],
      outboxPendingCount: 0,
      outboxPermanentFailureCount: 0,
      unresolvedConflictCount: 0,
      completedAt: DateTime.now(),
      message: reason,
    );
  }

  bool get hasCriticalErrors => criticalErrors.isNotEmpty;

  bool get isStrictSuccess =>
      !hasCriticalErrors &&
      outboxPendingCount == 0 &&
      outboxPermanentFailureCount == 0 &&
      unresolvedConflictCount == 0;
}

/// Compatibility facade over [SyncService].
///
/// All outward sync entry points route through [SyncService]. The deprecated
/// [SyncManager] implementation remains in this file only for legacy reference
/// and should not be used by new callers.
class AppSyncCoordinator extends ChangeNotifier {
  AppSyncCoordinator(this._syncService);

  final SyncService _syncService;

  StreamSubscription<SyncStatusSnapshot>? _statusSubscription;
  Timer? _debouncedSyncTimer;
  AppUser? _currentUser;

  bool get isSyncing => _syncService.currentStatus.isSyncing;
  int get pendingCount => _syncService.currentStatus.pendingCount;
  DateTime? get lastSyncTime => _syncService.currentStatus.lastSyncTime;
  AppUser? get currentUser => _currentUser;
  String get currentSyncStep => isSyncing ? 'syncing' : '';
  double get syncStepProgress => isSyncing ? 0.5 : 0.0;
  Stream<bool> get syncStream =>
      _syncService.statusStream.map((status) => status.isSyncing).asBroadcastStream();

  void initialize() {
    _statusSubscription?.cancel();
    _statusSubscription = _syncService.statusStream.listen((_) {
      notifyListeners();
    });
    notifyListeners();
  }

  void setCurrentUser(AppUser user, {bool triggerBootstrap = true}) {
    _currentUser = user;
    _syncService.setCurrentUser(user);
    unawaited(_syncService.processStoredPullRequests(source: 'user_context'));
    if (triggerBootstrap) {
      scheduleDebouncedSync(
        forceRefresh: true,
        debounce: const Duration(seconds: 2),
      );
    }
  }

  void scheduleDebouncedSync({
    bool forceRefresh = false,
    Duration debounce = const Duration(milliseconds: 500),
  }) {
    _debouncedSyncTimer?.cancel();
    _debouncedSyncTimer = Timer(debounce, () {
      unawaited(syncAll(_currentUser, forceRefresh: forceRefresh));
    });
  }

  void handleAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncService.processStoredPullRequests(source: 'app_resume'));
      unawaited(_syncService.syncAllPending(source: 'app_resume'));
    }
  }

  Future<SyncRunResult> syncAll(
    AppUser? user, {
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (isSyncing) {
      return SyncRunResult.skipped('Sync already in progress');
    }

    if (user == null && _currentUser == null) {
      return SyncRunResult.skipped('No authenticated app user context');
    }

    if (user != null) {
      _currentUser = user;
    }

    try {
      await _syncService.syncAllPending(
        source: forceRefresh ? 'force_refresh' : 'coordinator',
      );
      final status = _syncService.currentStatus;
      return SyncRunResult(
        executed: true,
        skipped: false,
        criticalErrors: const <String>[],
        outboxPendingCount: status.pendingCount,
        outboxPermanentFailureCount: 0,
        unresolvedConflictCount: 0,
        completedAt: status.lastSyncTime ?? now,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'AppSyncCoordinator.syncAll failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'Sync',
      );
      return SyncRunResult(
        executed: false,
        skipped: false,
        criticalErrors: <String>[error.toString()],
        outboxPendingCount: pendingCount,
        outboxPermanentFailureCount: 0,
        unresolvedConflictCount: 0,
        completedAt: DateTime.now(),
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> push() => _syncService.trySync();

  Future<void> pull() => _syncService.pullAllChanges();

  Future<void> processSyncQueue() async {
    await _syncService.trySync();
    notifyListeners();
  }

  Future<void> syncOfflineSalesViaService() => _syncService.trySync();

  Future<void> syncUsersViaDelegate({bool forceRefresh = true}) =>
      _syncService.trySync();

  Future<int> resetStuckOpeningStockRetry() async => 0;

  Future<void> fetchUserLiveUpdates(String userId) => _syncService.pullAllChanges();

  void stopUserListener() {}

  void cleanup({bool notify = true}) {
    _debouncedSyncTimer?.cancel();
    _debouncedSyncTimer = null;
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _currentUser = null;
    _syncService.clearCurrentUser();
    if (notify) {
      notifyListeners();
    }
  }
}

AppSyncCoordinator createAppSyncCoordinator(
  DatabaseService dbService,
  FirebaseServices firebase,
  SuppliersService suppliersService,
  AlertService alertService,
  VehiclesService vehiclesService,
  SyncAnalyticsService analyticsService,
  SalesService salesService,
  InventoryService inventoryService,
  ReturnsService returnsService,
  DispatchService dispatchService,
  ProductionService productionService,
  BhattiService bhattiService,
  CuttingBatchService cuttingBatchService,
  PayrollService payrollService,
  AttendanceService attendanceService,
  MasterDataService masterDataService,
  RouteOrderService routeOrderService,
  BhattiRepository bhattiRepo,
  ProductionRepository productionRepo,
  SyncCommonUtils utils,
) {
  final syncService = SyncService.instance;
  final coordinator = AppSyncCoordinator(syncService);
  final executor = TargetedPullSyncExecutor(
    dbService: dbService,
    utils: utils,
    firebase: firebase,
  );
  syncService.registerPullExecutor((
    modules, {
    bool forceRefresh = false,
    String source = 'unknown',
  }) {
    return executor.execute(
      modules,
      currentUser: coordinator.currentUser,
      forceRefresh: forceRefresh,
      source: source,
    );
  });
  return coordinator;
}

/// [SyncManager] is the central orchestrator for data synchronization in the DattSoap ERP.
///
/// It follows an offline-first strategy:
/// 1. All writes are first committed to the local database (Isar).
/// 2. Critical updates are immediately queued for Firestore synchronization.
/// 3. Bi-directional delta-based sync occurs for metadata (Users, Products, Customers).
/// 4. Automatic bulk sync reconciliation happens daily after 8:00 PM.

class SyncManager extends ChangeNotifier {
  // Sync policy: WhatsApp-like automatic background sync enabled.
  // All changes sync automatically without user intervention.
  static const bool _enableConnectivityAutoSync = true;
  static const bool _enablePartnerOutboxAutoSync = true;
  static const bool _enableQueueAutoSync = true;
  static const String _windowsKnownBadQueueItemKey =
      'windows_known_bad_sync_queue_item_id';

  final DatabaseService _dbService;
  final FirebaseServices _firebase;
  final SuppliersService _suppliersService;
  // ignore: unused_field
  final AlertService _alertService;
  // ignore: unused_field
  final VehiclesService _vehiclesService;
  final SyncAnalyticsService _analyticsService;

  // Injected Services for Queue Delegation
  final SalesService _salesService;
  final InventoryService _inventoryService;
  final ReturnsService _returnsService;
  final DispatchService _dispatchService;
  final ProductionService _productionService;
  final BhattiService _bhattiService;
  final CuttingBatchService _cuttingBatchService;
  final PayrollService _payrollService;
  final AttendanceService _attendanceService;
  final MasterDataService _masterDataService;
  // Kept for constructor compatibility and future delegated sync flows.
  // ignore: unused_field
  final RouteOrderService _routeOrderService;
  final BhattiRepository _bhattiRepo;
  final ProductionRepository _productionRepo;
  final SyncCommonUtils _utils;
  PaymentsService? _paymentsService;

  PaymentsService get _payments =>
      _paymentsService ??= PaymentsService(_firebase);

  MasterDataSyncDelegate? _masterDataDelegateInstance;

  MasterDataSyncDelegate get _masterDataDelegate =>
      _masterDataDelegateInstance ??= MasterDataSyncDelegate(
        _dbService,
        deleteQueueItem: _utils.deleteQueueItem,
        detectAndFlagConflict: _utils.detectAndFlagConflict,
        setLastSyncTimestamp: _utils.setLastSyncTimestamp,
        getLastSyncTimestamp: _utils.getLastSyncTimestamp,
        recordMetric: _recordMetric,
        markSyncIssue: _markSyncIssue,
        parseRemoteDate: _utils.parseRemoteDate,
        normalizeProductItemTypeLabel: _normalizeProductItemTypeLabel,
        chunkList: _utils.chunkList,
      );

  SalesSyncDelegate? _salesSyncDelegateInstance;

  SalesSyncDelegate get _salesSyncDelegate =>
      _salesSyncDelegateInstance ??= SalesSyncDelegate(
        dbService: _dbService,
        deleteQueueItem: _utils.deleteQueueItem,
        recordMetric: _recordMetric,
        markSyncIssue: _markSyncIssue,
        getLastSyncTimestamp: _utils.getLastSyncTimestamp,
        setLastSyncTimestamp: _utils.setLastSyncTimestamp,
        detectAndFlagConflict: _utils.detectAndFlagConflict,
        parseRemoteDate: _utils.parseRemoteDate,
        chunkList: _utils.chunkList,
      );

  InventorySyncDelegate? _inventorySyncDelegateInstance;

  InventorySyncDelegate get _inventorySyncDelegate =>
      _inventorySyncDelegateInstance ??= InventorySyncDelegate(
        dbService: _dbService,
        utils: _utils,
        suppliersService: _suppliersService,
        markSyncIssue: _markSyncIssue,
        normalizeProductItemTypeLabel: _normalizeProductItemTypeLabel,
      );

  HrSyncDelegate? _hrSyncDelegateInstance;

  HrSyncDelegate get _hrSyncDelegate =>
      _hrSyncDelegateInstance ??= HrSyncDelegate(
        dbService: _dbService,
        utils: _utils,
        recordMetric: _recordMetric,
        markSyncIssue: _markSyncIssue,
      );

  AccountingSyncDelegate? _accountingSyncDelegateInstance;

  AccountingSyncDelegate get _accountingSyncDelegate =>
      _accountingSyncDelegateInstance ??= AccountingSyncDelegate(
        dbService: _dbService,
        utils: _utils,
        recordMetric: _recordMetric,
      );

  UsersSyncDelegate? _usersSyncDelegateInstance;

  UsersSyncDelegate get _usersSyncDelegate =>
      _usersSyncDelegateInstance ??= UsersSyncDelegate(
        dbService: _dbService,
        utils: _utils,
        recordMetric: _recordMetric,
      );

  CustomersSyncDelegate? _customersSyncDelegateInstance;

  CustomersSyncDelegate get _customersSyncDelegate =>
      _customersSyncDelegateInstance ??= CustomersSyncDelegate(
        dbService: _dbService,
        utils: _utils,
        recordMetric: _recordMetric,
        markSyncIssue: _markSyncIssue,
      );

  DealersSyncDelegate? _dealersSyncDelegateInstance;

  DealersSyncDelegate get _dealersSyncDelegate =>
      _dealersSyncDelegateInstance ??= DealersSyncDelegate(
        dbService: _dbService,
        utils: _utils,
        recordMetric: _recordMetric,
        markSyncIssue: _markSyncIssue,
      );

  DutySessionsSyncDelegate? _dutySessionsSyncDelegateInstance;

  DutySessionsSyncDelegate get _dutySessionsSyncDelegate =>
      _dutySessionsSyncDelegateInstance ??= DutySessionsSyncDelegate(
        dbService: _dbService,
        utils: _utils,
        recordMetric: _recordMetric,
      );

  SyncQueueProcessorDelegate? _syncQueueProcessorDelegateInstance;

  SyncQueueProcessorDelegate get _syncQueueProcessorDelegate =>
      _syncQueueProcessorDelegateInstance ??= SyncQueueProcessorDelegate(
        dbService: _dbService,
        firebase: _firebase,
        salesService: _salesService,
        inventoryService: _inventoryService,
        returnsService: _returnsService,
        dispatchService: _dispatchService,
        productionService: _productionService,
        bhattiService: _bhattiService,
        cuttingBatchService: _cuttingBatchService,
        payrollService: _payrollService,
        attendanceService: _attendanceService,
        masterDataService: _masterDataService,
        resolvePaymentsService: () => _payments,
        migrateLegacyQueue: _migrateLegacyQueue,
        markSyncIssue: _markSyncIssue,
        updatePendingCount: _updatePendingCount,
        recordMetric: _recordMetric,
      );

  PartnerOutboxDelegate? _partnerOutboxDelegateInstance;

  PartnerOutboxDelegate get _partnerOutboxDelegate =>
      _partnerOutboxDelegateInstance ??= PartnerOutboxDelegate(
        dbService: _dbService,
        buildCustomerSyncPayload: _buildCustomerSyncPayload,
        buildDealerSyncPayload: _buildDealerSyncPayload,
      );

  QueueModulesSyncDelegate? _queueModulesSyncDelegateInstance;

  QueueModulesSyncDelegate get _queueModulesSyncDelegate =>
      _queueModulesSyncDelegateInstance ??= QueueModulesSyncDelegate(
        dbService: _dbService,
      );

  /// Indicates if a synchronization process is currently active.
  bool _isSyncing = false;

  /// The currently authenticated user context for role-based synchronization.
  AppUser? _currentUser;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _lifecyclePaused = false;
  Timer? _debouncedSyncTimer;
  StreamSubscription<fb_auth.User?>? _authStateSubscription;
  String? _bootstrappedUserId;
  StreamSubscription<void>? _customerOutboxWatchSubscription;
  StreamSubscription<void>? _dealerOutboxWatchSubscription;
  StreamSubscription<void>? _syncQueueWatchSubscription;
  StreamSubscription<firestore.DocumentSnapshot<Map<String, dynamic>>>?
  _userDocumentWatchSubscription;
  String? _liveUserDocId;

  SyncManager(
    this._dbService,
    this._firebase,
    this._suppliersService,
    this._alertService,
    this._vehiclesService,
    this._analyticsService,

    this._salesService,
    this._inventoryService,
    this._returnsService,
    this._dispatchService,
    this._productionService,
    this._bhattiService,
    this._cuttingBatchService,
    this._payrollService,
    this._attendanceService,
    this._masterDataService,
    this._routeOrderService,
    this._bhattiRepo,
    this._productionRepo,
    this._utils,
  );

  bool get isSyncing => _isSyncing;
  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  /// Current sync step label (e.g. 'users', 'sales', 'stock_ledger').
  /// Empty when not syncing.
  String _currentSyncStep = '';
  String get currentSyncStep => _currentSyncStep;

  /// Sync progress as a fraction 0.0 – 1.0.
  double _syncStepProgress = 0.0;
  double get syncStepProgress => _syncStepProgress;

  DateTime? _lastSyncAllTime;
  DateTime? get lastSyncAllTime => _lastSyncAllTime;
  final List<String> _syncIssues = [];

  static const String openingStockCollection =
      CollectionRegistry.openingStockEntries;
  static const String stockLedgerCollection = CollectionRegistry.stockLedger;
  static const String dispatchesCollection = CollectionRegistry.dispatches;

  // --- HELPER: LAST SYNC TIMESTAMPS ---

  Future<void> _recordMetric({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  }) async {
    if (_currentUser == null) return;
    await _analyticsService.recordSyncMetric(
      userId: _currentUser!.id,
      entityType: entityType,
      operation: operation,
      recordCount: recordCount,
      durationMs: durationMs,
      success: success,
      errorMessage: errorMessage,
    );
  }

  String? _encodeAllocatedStockJson(
    dynamic allocatedStock,
    dynamic allocatedStockJson,
  ) {
    if (allocatedStock is Map) {
      try {
        return jsonEncode(allocatedStock);
      } catch (_) {
        return null;
      }
    }
    if (allocatedStockJson is String && allocatedStockJson.isNotEmpty) {
      return allocatedStockJson;
    }
    return null;
  }

  void _clearSyncIssues() {
    _syncIssues.clear();
  }

  void _markSyncIssue(String step, Object error) {
    _syncIssues.add('$step: $error');
  }

  bool _isAdminLikeRole(UserRole role) {
    return role == UserRole.admin || role == UserRole.owner;
  }

  bool _isManagerLikeRole(UserRole role) {
    return role == UserRole.salesManager ||
        role == UserRole.productionManager ||
        role == UserRole.dealerManager ||
        role == UserRole.dispatchManager;
  }

  bool _isSalesTeamRole(UserRole role) {
    return _isAdminLikeRole(role) ||
        role == UserRole.salesManager ||
        role == UserRole.salesman ||
        role == UserRole.dealerManager;
  }

  bool _canSyncSales(UserRole role) {
    return _isAdminLikeRole(role) ||
        _isManagerLikeRole(role) ||
        role == UserRole.salesman;
  }

  bool _canSyncDispatches(UserRole role) {
    return _isAdminLikeRole(role) ||
        _isManagerLikeRole(role) ||
        role == UserRole.storeIncharge ||
        role == UserRole.salesman;
  }

  bool _canSyncReturns(UserRole role) {
    return _isAdminLikeRole(role) ||
        _isManagerLikeRole(role) ||
        role == UserRole.salesman ||
        role == UserRole.dealerManager;
  }

  bool _canSyncCustomers(UserRole role) {
    return _isSalesTeamRole(role);
  }

  bool _canSyncDealers(UserRole role) {
    return _isAdminLikeRole(role) || _isManagerLikeRole(role);
  }

  bool _canSyncStockLedger(UserRole role) {
    return _isAdminLikeRole(role) ||
        _isManagerLikeRole(role);
  }

  bool _canSyncWarehouseReferenceData(UserRole role) {
    return _isAdminLikeRole(role) ||
        _isManagerLikeRole(role) ||
        role == UserRole.storeIncharge;
  }

  bool _canSyncProductionInventory(UserRole role) {
    return _isAdminLikeRole(role) || 
        role == UserRole.productionManager ||
        role == UserRole.bhattiSupervisor ||
        role == UserRole.storeIncharge;
  }

  bool _canSyncFleetData(UserRole role) {
    return _isAdminLikeRole(role) ||
        role == UserRole.dispatchManager ||
        role == UserRole.storeIncharge ||
        role == UserRole.fuelIncharge ||
        role == UserRole.vehicleMaintenanceManager;
  }

  bool _canSyncPayroll(UserRole role) {
    return _isAdminLikeRole(role) || 
        role == UserRole.salesManager ||
        role == UserRole.productionManager ||
        role == UserRole.dispatchManager;
  }

  bool _canSyncHr(UserRole role) {
    return _isAdminLikeRole(role);
  }

  bool _canSyncAccounting(UserRole role) {
    return _isAdminLikeRole(role) || role == UserRole.accountant;
  }

  Future<AppUser?> _getLatestUserContext(String userId) async {
    try {
      final localUser = await _dbService.users
          .filter()
          .idEqualTo(userId)
          .findFirst();
      return localUser?.toDomain();
    } catch (e) {
      AppLogger.warning(
        'Unable to refresh local user context for sync: $e',
        tag: 'Sync',
      );
      return null;
    }
  }

  List<String> _resolveSalesmanRoutes(AppUser user) {
    final routeSet = <String>{};

    void addRoute(String? value) {
      final route = value?.trim();
      if (route != null && route.isNotEmpty) {
        routeSet.add(route);
      }
    }

    if (user.assignedRoutes != null) {
      for (final route in user.assignedRoutes!) {
        addRoute(route);
      }
    }

    addRoute(user.assignedSalesRoute);
    addRoute(user.assignedDeliveryRoute);
    return routeSet.toList();
  }

  String? _normalizeRouteScopeToken(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return normalized.isEmpty ? null : normalized;
  }

  Future<List<String>> _resolveSalesmanRouteScope(
    firestore.FirebaseFirestore db,
    AppUser user,
  ) async {
    final scopeValues = <String>{};
    final routeLookup = <String, Map<String, String>>{};
    final routeRows = <Map<String, String>>[];
    final userIdentityTokens = <String>{
      _normalizeRouteScopeToken(user.id) ?? '',
      _normalizeRouteScopeToken(user.name) ?? '',
      _normalizeRouteScopeToken(user.email) ?? '',
    }..removeWhere((value) => value.isEmpty);

    void registerRoute(Map<String, String> route) {
      final routeIdToken = _normalizeRouteScopeToken(route['id']);
      final routeNameToken = _normalizeRouteScopeToken(route['name']);
      if (routeIdToken != null) routeLookup[routeIdToken] = route;
      if (routeNameToken != null) routeLookup[routeNameToken] = route;
    }

    void addRouteScopeValue(String? rawValue) {
      final normalized = _normalizeRouteScopeToken(rawValue);
      if (normalized == null) return;
      final rawTrimmed = rawValue?.trim();
      if (rawTrimmed != null && rawTrimmed.isNotEmpty) {
        scopeValues.add(rawTrimmed);
      }
      final mapped = routeLookup[normalized];
      if (mapped == null) return;
      final mappedId = mapped['id']?.trim() ?? '';
      final mappedName = mapped['name']?.trim() ?? '';
      if (mappedId.isNotEmpty) scopeValues.add(mappedId);
      if (mappedName.isNotEmpty) scopeValues.add(mappedName);
    }

    for (final route in _resolveSalesmanRoutes(user)) {
      addRouteScopeValue(route);
    }

    try {
      final snapshot = await db.collection(CollectionRegistry.routes).get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['isDeleted'] == true) continue;
        final routeId = (data['id'] ?? data['routeId'] ?? doc.id)
            .toString()
            .trim();
        final routeName = (data['name'] ?? data['routeName'] ?? '')
            .toString()
            .trim();
        if (routeId.isEmpty && routeName.isEmpty) continue;

        final row = <String, String>{
          'id': routeId,
          'name': routeName,
          'salesmanId': (data['salesmanId'] ?? '').toString().trim(),
          'salesmanName': (data['salesmanName'] ?? '').toString().trim(),
        };
        routeRows.add(row);
        registerRoute(row);
      }
    } catch (e) {
      AppLogger.warning(
        'Unable to read master routes for salesman scope: $e',
        tag: 'Sync',
      );
    }

    // Re-apply user routes so id<->name mapping from master routes is included.
    for (final route in _resolveSalesmanRoutes(user)) {
      addRouteScopeValue(route);
    }

    for (final row in routeRows) {
      final assigneeTokens = <String>{
        _normalizeRouteScopeToken(row['salesmanId']) ?? '',
        _normalizeRouteScopeToken(row['salesmanName']) ?? '',
      }..removeWhere((value) => value.isEmpty);
      if (assigneeTokens.isEmpty) continue;
      final matchesUser = assigneeTokens.any(userIdentityTokens.contains);
      if (!matchesUser) continue;
      addRouteScopeValue(row['id']);
      addRouteScopeValue(row['name']);
    }

    final resolved = scopeValues.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return resolved;
  }

  void setCurrentUser(AppUser user, {bool triggerBootstrap = true}) {
    _currentUser = user;

    if (!triggerBootstrap) return;
    if (_bootstrappedUserId == user.id) return;
    _scheduleInitialBootstrapWhenAuthReady(user);
  }

  void _runInitialBootstrapSync(AppUser user) {
    _bootstrappedUserId = user.id;
    scheduleDebouncedSync(
      // First sync per-login must be force refresh to guarantee cross-device
      // visibility after fresh setup or git/app updates.
      forceRefresh: true,
      debounce: const Duration(seconds: 2),
    );
  }

  void _scheduleInitialBootstrapWhenAuthReady(AppUser user) {
    _clearAuthBootstrapSubscription();

    if (_firebase.auth?.currentUser != null) {
      _runInitialBootstrapSync(user);
      return;
    }

    AppLogger.info(
      'Deferring initial sync bootstrap until Firebase auth is ready.',
      tag: 'Sync',
    );
    _authStateSubscription = _firebase.auth?.authStateChanges().listen(
      (firebaseUser) {
        final activeUser = _currentUser;
        if (activeUser == null || activeUser.id != user.id) {
          _clearAuthBootstrapSubscription();
          return;
        }
        if (firebaseUser != null) {
          _clearAuthBootstrapSubscription();
          _runInitialBootstrapSync(user);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.warning(
          'Initial sync bootstrap auth listener failed: $error',
          tag: 'Sync',
        );
        _clearAuthBootstrapSubscription();
      },
    );
  }

  void _clearAuthBootstrapSubscription() {
    final subscription = _authStateSubscription;
    _authStateSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  void scheduleDebouncedSync({
    bool forceRefresh = false,
    Duration debounce = const Duration(milliseconds: 500),
  }) {
    final user = _currentUser;
    if (user == null) return;

    _debouncedSyncTimer?.cancel();
    _debouncedSyncTimer = Timer(debounce, () async {
      if (_isSyncing) return;
      try {
        await syncAll(user, forceRefresh: forceRefresh);
      } catch (e, stackTrace) {
        AppLogger.error(
          'Debounced sync failed',
          error: e,
          stackTrace: stackTrace,
          tag: 'Sync',
        );
      }
    });
  }

  /// Initializes the synchronization manager.
  ///
  /// Sets up:
  /// - Connectivity listeners to trigger sync on network restoration.
  /// - Periodic timers for bulk synchronization and expiration checks.
  /// - Initial processing of the local sync queue.
  void initialize() {
    // Prevent duplicate listeners
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    if (_enableConnectivityAutoSync) {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (result) {
          if (result != ConnectivityResult.none) {
            AppLogger.info('Network restored: Triggering sync...', tag: 'Sync');
            if (_currentUser != null) {
              syncAll(_currentUser);
              // Retry fetch if needed
              if (_currentUser != null) {
                fetchUserLiveUpdates(_currentUser!.id);
              }
            }
          }
        },
        onError: (e) {
          AppLogger.error('Connectivity listener error', error: e, tag: 'Sync');
        },
      );
    }

    _updatePendingCount();
    if (_enablePartnerOutboxAutoSync) {
      _startPartnerOutboxWatchers();
    } else {
      _customerOutboxWatchSubscription?.cancel();
      _customerOutboxWatchSubscription = null;
      _dealerOutboxWatchSubscription?.cancel();
      _dealerOutboxWatchSubscription = null;
    }
    if (_enableQueueAutoSync) {
      _startSyncQueueWatcher();
    } else {
      _syncQueueWatchSubscription?.cancel();
      _syncQueueWatchSubscription = null;
    }

    // Startup sync is now gated by app-level user bootstrap to avoid
    // triggering queue work while Firebase auth is still settling.
  }

  void handleAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resumeBackgroundServices();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _pauseBackgroundServices();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // No-op: keep current state to avoid thrashing on transient changes.
        break;
    }
  }

  void _pauseBackgroundServices() {
    if (_lifecyclePaused) return;
    _lifecyclePaused = true;
    if (_enableConnectivityAutoSync) {
      _connectivitySubscription?.pause();
    }
  }

  void _resumeBackgroundServices() {
    if (!_lifecyclePaused) return;
    _lifecyclePaused = false;

    if (_firebase.auth?.currentUser == null && _currentUser == null) {
      return;
    }

    if (_enableConnectivityAutoSync && _connectivitySubscription == null) {
      initialize();
      return;
    }

    if (_enableConnectivityAutoSync) {
      _connectivitySubscription?.resume();
    }
  }

  void _startPartnerOutboxWatchers() {
    _customerOutboxWatchSubscription?.cancel();
    _dealerOutboxWatchSubscription?.cancel();

    _customerOutboxWatchSubscription = _dbService.customers
        .watchLazy(fireImmediately: false)
        .listen(
          (_) => _handlePartnerWriteDetected('customers'),
          onError: (e) => AppLogger.warning(
            'Customer outbox watcher error: $e',
            tag: 'Sync',
          ),
        );

    _dealerOutboxWatchSubscription = _dbService.dealers
        .watchLazy(fireImmediately: false)
        .listen(
          (_) => _handlePartnerWriteDetected('dealers'),
          onError: (e) =>
              AppLogger.warning('Dealer outbox watcher error: $e', tag: 'Sync'),
        );
  }

  void _startSyncQueueWatcher() {
    _syncQueueWatchSubscription?.cancel();
    _syncQueueWatchSubscription = _dbService.syncQueue
        .watchLazy(fireImmediately: false)
        .listen(
          (_) async {
            if (_isSyncing || _currentUser == null) return;
            final pending = await _countVisibleQueueItems();
            if (pending <= 0) return;
            await _updatePendingCount();
            scheduleDebouncedSync(debounce: const Duration(seconds: 2));
          },
          onError: (e) =>
              AppLogger.warning('Sync queue watcher error: $e', tag: 'Sync'),
        );
  }

  Future<void> _handlePartnerWriteDetected(String collection) async {
    if (_isSyncing || _currentUser == null) return;

    final pendingCount = collection == 'customers'
        ? await _dbService.customers
              .filter()
              .syncStatusEqualTo(SyncStatus.pending)
              .count()
        : await _dbService.dealers
              .filter()
              .syncStatusEqualTo(SyncStatus.pending)
              .count();

    if (pendingCount <= 0) return;

    await _ensurePartnerOutboxForCollection(collection);
    await _updatePendingCount();
    scheduleDebouncedSync(debounce: const Duration(seconds: 3));
  }

  Future<void> _updatePendingCount() async {
    final nextPendingCount = await _countVisibleQueueItems();
    if (nextPendingCount == _pendingCount) return;
    _pendingCount = nextPendingCount;
    notifyListeners();
  }

  // --- LIVE LISTENERS ---

  String? _normalizeActorKey(dynamic raw) {
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value.toLowerCase();
  }

  Set<String> _currentSessionActorKeys() {
    final keys = <String>{};

    void addKey(dynamic raw) {
      final normalized = _normalizeActorKey(raw);
      if (normalized != null) {
        keys.add(normalized);
      }
    }

    addKey(_currentUser?.id);
    addKey(_currentUser?.email);
    addKey(_firebase.auth?.currentUser?.uid);
    addKey(_firebase.auth?.currentUser?.email);
    return keys;
  }

  Set<String> _extractQueueOwnerKeys(
    SyncQueueEntity item,
    OutboxDecodedPayload decoded,
  ) {
    final ownerKeys = <String>{};

    void addKey(dynamic raw) {
      final normalized = _normalizeActorKey(raw);
      if (normalized != null) {
        ownerKeys.add(normalized);
      }
    }

    addKey(decoded.meta[OutboxCodec.actorIdMetaField]);
    addKey(decoded.meta[OutboxCodec.actorUidMetaField]);
    addKey(decoded.meta[OutboxCodec.actorEmailMetaField]);
    if (ownerKeys.isNotEmpty) {
      return ownerKeys;
    }

    if (item.collection == dispatchesCollection && item.action == 'add') {
      addKey(decoded.payload['createdBy']);
      addKey(decoded.payload['createdByEmail']);
    }
    return ownerKeys;
  }

  /// Collections that must only be pushed by their creator (admin/manager).
  /// If a queue item in these collections has NO actor metadata (old pre-fix
  /// items), a salesman or non-admin user must NOT see it — to prevent
  /// Firestore permission-denied errors from pushing admin-owned records.
  static const Set<String> _adminStrictCollections = {
    CollectionRegistry.openingStockEntries,
    CollectionRegistry.inventoryCommands,
  };

  bool _isQueueVisibleToCurrentSession(SyncQueueEntity item) {
    final sessionKeys = _currentSessionActorKeys();
    if (sessionKeys.isEmpty) return true;
    final decoded = OutboxCodec.decode(
      item.dataJson,
      fallbackQueuedAt: item.createdAt,
    );
    final ownerKeys = _extractQueueOwnerKeys(item, decoded);
    if (ownerKeys.isEmpty) {
      // For admin-strict collections, items without owner metadata must only
      // be processed by admin/owner roles. Salesman / restricted roles skip them.
      if (_adminStrictCollections.contains(item.collection)) {
        final role = _currentUser?.role;
        if (role == null) return false;
        return _isAdminLikeRole(role) || _isManagerLikeRole(role);
      }
      return true;
    }
    return ownerKeys.any(sessionKeys.contains);
  }

  Future<List<SyncQueueEntity>> _loadVisibleQueueItems() async {
    final queueItems = await _dbService.syncQueue.where().findAll();
    return queueItems
        .where(_isQueueVisibleToCurrentSession)
        .toList(growable: false);
  }

  Future<int> _countVisibleQueueItems() async {
    final queueItems = await _loadVisibleQueueItems();
    return queueItems.length;
  }

  Future<bool> _hasVisiblePendingDispatchForSalesman(String userId) async {
    final normalizedUserId = _normalizeActorKey(userId);
    if (normalizedUserId == null) return false;

    final queueItems = await _loadVisibleQueueItems();
    for (final item in queueItems) {
      if (item.collection != dispatchesCollection ||
          item.action != 'add' ||
          item.syncStatus != SyncStatus.pending) {
        continue;
      }
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      final payloadSalesmanId = _normalizeActorKey(
        decoded.payload['salesmanId'],
      );
      if (payloadSalesmanId == normalizedUserId) {
        return true;
      }
    }
    return false;
  }

  bool _currentSessionOwnsUserDoc(String userId) {
    final normalizedUserId = _normalizeActorKey(userId);
    if (normalizedUserId == null) return false;
    return _currentSessionActorKeys().contains(normalizedUserId);
  }

  bool get _supportsLiveUserSnapshots {
    return !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
  }

  Future<void> _applyRemoteUserSnapshot({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final hasPendingDispatch = await _hasVisiblePendingDispatchForSalesman(
      userId,
    );
    if (hasPendingDispatch) {
      AppLogger.info(
        'fetchUserLiveUpdates: Skipping allocatedStock overwrite for $userId because a visible pending dispatch exists.',
        tag: 'Sync',
      );
    }

    await _dbService.db.writeTxn(() async {
      final localUser = await _dbService.users
          .filter()
          .idEqualTo(userId)
          .findFirst();

      if (localUser != null) {
        localUser.name = data['name'] ?? localUser.name;
        localUser.email = data['email'] ?? localUser.email;
        localUser.role = data['role'] ?? localUser.role;

        // T9-P5 REMOVED: Direct allocatedStock local mirror overwrite
        if (!hasPendingDispatch) {
          final allocatedStockJson = _encodeAllocatedStockJson(
            data['allocatedStock'],
            data['allocatedStockJson'],
          );
          if (allocatedStockJson != null) {
            localUser.allocatedStockJson = allocatedStockJson;
          }
        }
        localUser.assignedRoutes =
            (data['assignedRoutes'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            localUser.assignedRoutes;

        localUser.phone = data['phone'] ?? data['mobile'] ?? localUser.phone;
        localUser.status = data['status'] ?? localUser.status;
        localUser.assignedBhatti =
            data['assignedBhatti'] ?? localUser.assignedBhatti;
        localUser.assignedBaseProductId =
            data['assignedBaseProductId'] ?? localUser.assignedBaseProductId;
        localUser.assignedBaseProductName =
            data['assignedBaseProductName'] ??
            localUser.assignedBaseProductName;
        localUser.assignedVehicleId =
            data['assignedVehicleId'] ?? localUser.assignedVehicleId;
        localUser.assignedVehicleName =
            data['assignedVehicleName'] ?? localUser.assignedVehicleName;
        localUser.assignedVehicleNumber =
            data['assignedVehicleNumber'] ?? localUser.assignedVehicleNumber;
        localUser.assignedDeliveryRoute =
            data['assignedDeliveryRoute'] ?? localUser.assignedDeliveryRoute;
        localUser.assignedSalesRoute =
            data['assignedSalesRoute'] ?? localUser.assignedSalesRoute;

        localUser.department = data['department'] ?? localUser.department;
        localUser.designation = data['designation'] ?? localUser.designation;
        if (data['departments'] != null) {
          localUser.departmentsJson = jsonEncode(data['departments']);
        }

        localUser.syncStatus = SyncStatus.synced;
        localUser.updatedAt = DateTime.now();
        await _dbService.users.put(localUser);
      }
    });

    notifyListeners();
  }

  /// Fetches the user's document in Firestore once per session to get metadata.
  ///
  /// This replaces the real-time listener to comply with offline-first rules.
  Future<void> fetchUserLiveUpdates(String userId) async {
    // Cannot start fetch if DB is not available
    final db = _firebase.db;
    if (db == null) {
      AppLogger.warning('Offline/Mock mode. Skipping user fetch.', tag: 'Sync');
      return;
    }

    // Strict Auth Check
    final currentUser = _firebase.auth?.currentUser;
    if (currentUser == null) {
      AppLogger.warning(
        'User not authenticated. User fetch blocked.',
        tag: 'Sync',
      );
      return;
    }

    AppLogger.info(
      'Fetching live updates for user: $userId (Auth UID: ${currentUser.uid})',
      tag: 'Sync',
    );

    if (!_currentSessionOwnsUserDoc(userId)) {
      AppLogger.warning(
        'User fetch blocked for $userId: current session does not own this document.',
        tag: 'Sync',
      );
      return;
    }

    if (_supportsLiveUserSnapshots &&
        (_liveUserDocId != userId || _userDocumentWatchSubscription == null)) {
      stopUserListener();
      _liveUserDocId = userId;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _userDocumentWatchSubscription = db
            .collection(CollectionRegistry.users)
            .doc(userId)
            .snapshots()
            .listen(
              (doc) async {
                if (!_currentSessionOwnsUserDoc(userId)) {
                  return;
                }
                if (!doc.exists || doc.data() == null) {
                  return;
                }
                AppLogger.info(
                  'Live update received for user: $userId',
                  tag: 'Sync',
                );
                try {
                  await _applyRemoteUserSnapshot(
                    userId: userId,
                    data: doc.data()!,
                  );
                } catch (e) {
                  AppLogger.error(
                    'Failed to apply live user update',
                    error: e,
                    tag: 'Sync',
                  );
                }
              },
              onError: (e) {
                AppLogger.error(
                  'Failed to fetch user updates',
                  error: e,
                  tag: 'Sync',
                );
              },
            );
      });
    }

    try {
      final doc = await db
          .collection(CollectionRegistry.users)
          .doc(userId)
          .get();

      final authUser = _firebase.auth?.currentUser;
      if (authUser == null || !_currentSessionOwnsUserDoc(userId)) {
        return;
      }
      if (_currentUser != null && !_currentSessionOwnsUserDoc(userId)) {
        return;
      }

      if (doc.exists) {
        AppLogger.info('Live update received for user: $userId', tag: 'Sync');

        final data = doc.data();

        // Guard: If there is a pending dispatch for this salesman in the sync
        // queue, the local allocatedStockJson is AHEAD of Firestore (dispatch
        // not yet pushed). Overwriting it would silently revert salesman stock.
        // Check BEFORE writeTxn to avoid nested Isar read issues.
        final hasPendingDispatch = await _hasVisiblePendingDispatchForSalesman(
          userId,
        );

        if (hasPendingDispatch) {
          AppLogger.info(
            'fetchUserLiveUpdates: Skipping allocatedStock overwrite for $userId — pending dispatch in queue.',
            tag: 'Sync',
          );
        }

        await _dbService.db.writeTxn(() async {
          final localUser = await _dbService.users
              .filter()
              .idEqualTo(userId)
              .findFirst();

          if (localUser != null && data != null) {
            localUser.name = data['name'] ?? localUser.name;
            localUser.email = data['email'] ?? localUser.email;
            localUser.role = data['role'] ?? localUser.role;

            // T9-P5 REMOVED: Direct allocatedStock local mirror overwrite
            if (!hasPendingDispatch) {
              final allocatedStockJson = _encodeAllocatedStockJson(
                data['allocatedStock'],
                data['allocatedStockJson'],
              );
              if (allocatedStockJson != null) {
                localUser.allocatedStockJson = allocatedStockJson;
              }
            }
            localUser.assignedRoutes =
                (data['assignedRoutes'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                localUser.assignedRoutes;

            // Extra fields
            localUser.phone =
                data['phone'] ?? data['mobile'] ?? localUser.phone;
            localUser.status = data['status'] ?? localUser.status;
            localUser.assignedBhatti =
                data['assignedBhatti'] ?? localUser.assignedBhatti;
            localUser.assignedBaseProductId =
                data['assignedBaseProductId'] ??
                localUser.assignedBaseProductId;
            localUser.assignedBaseProductName =
                data['assignedBaseProductName'] ??
                localUser.assignedBaseProductName;
            localUser.assignedVehicleId =
                data['assignedVehicleId'] ?? localUser.assignedVehicleId;
            localUser.assignedVehicleName =
                data['assignedVehicleName'] ?? localUser.assignedVehicleName;
            localUser.assignedVehicleNumber =
                data['assignedVehicleNumber'] ??
                localUser.assignedVehicleNumber;
            localUser.assignedDeliveryRoute =
                data['assignedDeliveryRoute'] ??
                localUser.assignedDeliveryRoute;
            localUser.assignedSalesRoute =
                data['assignedSalesRoute'] ?? localUser.assignedSalesRoute;

            localUser.department = data['department'] ?? localUser.department;
            localUser.designation =
                data['designation'] ?? localUser.designation;
            if (data['departments'] != null) {
              localUser.departmentsJson = jsonEncode(data['departments']);
            }

            localUser.syncStatus = SyncStatus.synced;
            localUser.updatedAt = DateTime.now(); // Update local timestamp
            await _dbService.users.put(localUser);
          }
        });

        notifyListeners(); // Update UI
      }
    } catch (e) {
      AppLogger.error('Failed to fetch user updates', error: e, tag: 'Sync');
    }
  }

  void stopUserListener() {
    _userDocumentWatchSubscription?.cancel();
    _userDocumentWatchSubscription = null;
    _liveUserDocId = null;
  }

  void cleanup({bool notify = true}) {
    stopUserListener();
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _customerOutboxWatchSubscription?.cancel();
    _customerOutboxWatchSubscription = null;
    _dealerOutboxWatchSubscription?.cancel();
    _dealerOutboxWatchSubscription = null;
    _syncQueueWatchSubscription?.cancel();
    _syncQueueWatchSubscription = null;
    _debouncedSyncTimer?.cancel();
    _debouncedSyncTimer = null;
    _clearAuthBootstrapSubscription();
    _lifecyclePaused = false;
    _isSyncing = false;
    _bootstrappedUserId = null;
    _currentUser = null;
    _currentSyncStep = '';
    _syncStepProgress = 0.0;
    if (notify) {
      notifyListeners();
    }
  }

  bool get _isWindowsSafeMode {
    return InventoryService.safeMode &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows;
  }

  /// Performs a full synchronization for the specified [user].
  ///
  /// The process involves:
  // IMPORTANT:
  // Firestore rules compare against request.auth.uid.
  // Never use AppUser.id for permission-based filters in Firestore queries.
  // AppUser.id is the email-based document ID, which does NOT match the Firebase UID.

  /// 1. Verifying authentication and network connectivity.
  /// 2. Processing the local sync queue (pushing pending local changes).
  /// 3. Performing a daily bulk sync check if it's past 8:00 PM.
  /// 4. Synchronizing all relevant collections (Products, Sales, etc.) with delta updates.
  Future<SyncRunResult> syncAll(
    AppUser? user, {
    bool forceRefresh = false,
  }) async {
    if (_isSyncing) {
      return SyncRunResult.skipped('Sync already in progress');
    }
    if (user == null) {
      return SyncRunResult.skipped('No authenticated app user context');
    }
    _currentUser = user;

    // Check if Firebase is available
    final db = _firebase.db;
    if (db == null) {
      return SyncRunResult.skipped('Firebase database unavailable');
    }

    // Strict Auth Check
    final firebaseUser = _firebase.auth?.currentUser;
    if (firebaseUser == null) {
      AppLogger.warning('User not authenticated. Sync blocked.', tag: 'Sync');
      return SyncRunResult.skipped('Firebase auth user missing');
    }

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return SyncRunResult.skipped('No internet connectivity');
    }

    _isSyncing = true;
    notifyListeners();
    // Listener logic removed

    try {
      AppLogger.info(
        'Starting ${forceRefresh ? "FORCE" : "Delta"} Sync for ${user.role.value} (${user.name})...',
        tag: 'Sync',
      );
      _clearSyncIssues();
      _currentSyncStep = 'initializing';
      _syncStepProgress = 0.0;

      // Safeguard: Centralized Identity Access
      final firebaseUid = _firebase.auth?.currentUser?.uid;
      assert(
        firebaseUid != null && firebaseUid.isNotEmpty,
        'Firebase UID must be present for sync operations',
      );

      // Log Identity Type During Sync (Dev only/Log always for visibility)
      AppLogger.info(
        'Sync Identity → UID: $firebaseUid | AppUser.id: ${user.id}',
        tag: 'Sync',
      );

      // Total sync steps for progress calculation.
      const totalSteps = 25;
      var completedSteps = 0;

      Future<void> runStep(String step, Future<void> Function() action) async {
        _currentSyncStep = step;
        _syncStepProgress = completedSteps / totalSteps;
        notifyListeners();
        try {
          await action();
        } catch (e, stackTrace) {
          _markSyncIssue(step, e);
          AppLogger.error(
            'Sync step failed: $step',
            error: e,
            stackTrace: stackTrace,
            tag: 'Sync',
          );
        }
        completedSteps++;
      }

      var effectiveUser = user;
      bool canSyncSales() => _canSyncSales(effectiveUser.role);
      bool canSyncDispatches() => _canSyncDispatches(effectiveUser.role);
      bool canSyncReturns() => _canSyncReturns(effectiveUser.role);
      bool canSyncCustomers() => _canSyncCustomers(effectiveUser.role);
      bool canSyncDealers() => _canSyncDealers(effectiveUser.role);
      bool canSyncStockLedger() => _canSyncStockLedger(effectiveUser.role);
      bool canSyncWarehouseReferenceData() =>
          _canSyncWarehouseReferenceData(effectiveUser.role);
      bool canSyncProductionInventory() =>
          _canSyncProductionInventory(effectiveUser.role);
      bool canSyncFleetData() => _canSyncFleetData(effectiveUser.role);
      bool canSyncAccounting() => _canSyncAccounting(effectiveUser.role);

      // 1. Ensure durable outbox exists for all pending partner writes.
      await runStep('partner_outbox_backfill', _ensurePartnerOutboxFromPending);

      // 2. Process Queue (Push pending local changes)
      await runStep('sync_queue', processSyncQueue);

      // 2.1 Explicit queue-only module orchestration (non-mutating health pass).
      await runStep(
        'queue_only_modules_orchestration',
        _queueModulesSyncDelegate.orchestrateQueueOnlyModules,
      );

      if (_isWindowsSafeMode) {
        AppLogger.warning(
          'Windows safe sync mode active. Using safe sync paths for inventory transactions.',
          tag: 'Sync',
        );
      }

      // 3. Scheduled Bulk Sync Check (8:00 PM)
      await runStep('bulk_sync_check', () => _checkAndPerformBulkSync(user));

      // 4. Fetch/Sync (Pull latest data with Role Isolation & Delta)
      await runStep(
        'users',
        () => _usersSyncDelegate.syncUsers(
          db,
          currentUser: _currentUser,
          forceRefresh: forceRefresh,
        ),
      );
      final refreshedUser = await _getLatestUserContext(user.id);
      if (refreshedUser != null) {
        effectiveUser = refreshedUser;
        _currentUser = refreshedUser;
      }
      // Production Supervisor: Only sync production-related data
      if (effectiveUser.role == UserRole.productionSupervisor) {
        AppLogger.info(
          'Production Supervisor sync: Only syncing production department data',
          tag: 'Sync',
        );
      }

      await runStep(
        'trips',
        () => _inventorySyncDelegate.syncDispatches(
          db,
          effectiveUser,
          forceRefresh: forceRefresh,
        ),
      );
      if (_isAdminLikeRole(effectiveUser.role) || 
          effectiveUser.role == UserRole.productionSupervisor ||
          effectiveUser.role == UserRole.storeIncharge) {
        await runStep(
          'route_orders',
          () => _inventorySyncDelegate.syncRouteOrders(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      }
      await runStep(
        'inventory',
        () => _inventorySyncDelegate.syncInventory(
          db,
          effectiveUser,
          forceRefresh: forceRefresh,
        ),
      );
      if (canSyncSales()) {
        await runStep(
          'sales',
          () => _salesSyncDelegate.syncSales(
            db,
            effectiveUser,
            firebaseUid: firebaseUid,
            forceRefresh: forceRefresh,
          ),
        );
        // Payments sync only for Admin and Managers, NOT for Salesman or Dealer Manager
        if (_isAdminLikeRole(effectiveUser.role) || _isManagerLikeRole(effectiveUser.role)) {
          if (effectiveUser.role != UserRole.dealerManager) {
            await runStep(
              'payments',
              () => _salesSyncDelegate.syncPayments(
                db,
                effectiveUser,
                firebaseUid: firebaseUid,
                forceRefresh: forceRefresh,
              ),
            );
          } else {
            AppLogger.info(
              'Skipping payments sync for Dealer Manager - not authorized',
              tag: 'Sync',
            );
          }
        } else {
          AppLogger.info(
            'Skipping payments sync for ${effectiveUser.role.value} - not authorized',
            tag: 'Sync',
          );
        }
      }
      if (canSyncDispatches()) {
        // Dispatches are now synced via _inventorySyncDelegate.syncDispatches above
      }
      if (canSyncReturns()) {
        await runStep(
          'returns',
          () => _salesSyncDelegate.syncReturns(
            db,
            effectiveUser,
            firebaseUid: firebaseUid,
            forceRefresh: forceRefresh,
          ),
        );
      }
      if (canSyncCustomers()) {
        await runStep(
          'customers',
          () => _customersSyncDelegate.syncCustomers(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
            resolveSalesmanRouteScope: _resolveSalesmanRouteScope,
            buildCustomerSyncPayload: _buildCustomerSyncPayload,
            deletePartnerOutboxItem: _deletePartnerOutboxItem,
            upsertPartnerOutboxItem: _upsertPartnerOutboxItem,
          ),
        );
      }
      if (canSyncDealers()) {
        await runStep(
          'dealers',
          () => _dealersSyncDelegate.syncDealers(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
            buildDealerSyncPayload: _buildDealerSyncPayload,
            deletePartnerOutboxItem: _deletePartnerOutboxItem,
            upsertPartnerOutboxItem: _upsertPartnerOutboxItem,
          ),
        );
      }
      if (canSyncWarehouseReferenceData()) {
        await runStep(
          'suppliers',
          () => _inventorySyncDelegate.syncSuppliers(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      }
      if (canSyncProductionInventory()) {
        await runStep(
          'tanks',
          () => _inventorySyncDelegate.syncTanks(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
        await runStep(
          'tank_transactions',
          () => _inventorySyncDelegate.syncTankTransactions(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
        await runStep(
          'bhatti_entries',
          () => _inventorySyncDelegate.syncBhattiEntries(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      } else if (effectiveUser.role == UserRole.productionSupervisor) {
        await runStep(
          'bhatti_entries',
          () => _inventorySyncDelegate.syncBhattiEntries(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      } else {
        AppLogger.info(
          'Skipping tank sync for ${effectiveUser.role.value} - not authorized',
          tag: 'Sync',
        );
      }
      if (_isAdminLikeRole(effectiveUser.role)) {
        await runStep(
          'duty_sessions',
          () => _dutySessionsSyncDelegate.syncDutySessions(
            db,
            effectiveUser,
            firebaseUid: firebaseUid,
            forceRefresh: forceRefresh,
          ),
        );
      }
      await runStep(
        'route_sessions',
        () => _salesSyncDelegate.syncRouteSessions(
          db,
          effectiveUser,
          firebaseUid: firebaseUid,
          forceRefresh: forceRefresh,
        ),
      );
      await runStep(
        'customer_visits',
        () => _salesSyncDelegate.syncCustomerVisits(
          db,
          effectiveUser,
          firebaseUid: firebaseUid,
          forceRefresh: forceRefresh,
        ),
      );
      if (canSyncWarehouseReferenceData()) {
        if (effectiveUser.role != UserRole.dealerManager) {
          await runStep(
            'opening_stock',
            () => _inventorySyncDelegate.syncOpeningStock(
              db,
              effectiveUser,
              forceRefresh: forceRefresh,
            ),
          );
        } else {
          AppLogger.info(
            'Skipping opening stock for Dealer Manager - not authorized',
            tag: 'Sync',
          );
        }
      }
      if (canSyncStockLedger()) {
        if (effectiveUser.role != UserRole.dealerManager) {
          await runStep(
            'stock_ledger',
            () => _inventorySyncDelegate.syncStockLedger(
              db,
              effectiveUser,
              firebaseUid: firebaseUid,
              forceRefresh: forceRefresh,
            ),
          );
        } else {
          AppLogger.info(
            'Skipping stock ledger for Dealer Manager - not authorized',
            tag: 'Sync',
          );
        }
      }
      // Production entries sync for Production Supervisor and Production Manager
      if (canSyncProductionInventory() || effectiveUser.role == UserRole.productionSupervisor) {
        await runStep(
          'production_entries',
          () => _inventorySyncDelegate.syncProductionEntries(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      }
      if (canSyncWarehouseReferenceData()) {
        await runStep(
          'routes',
          () => _inventorySyncDelegate.syncRoutes(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      }
      if (canSyncFleetData()) {
        await runStep(
          'vehicles',
          () => _inventorySyncDelegate.syncVehicles(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
        await runStep(
          'diesel_logs',
          () => _inventorySyncDelegate.syncDieselLogs(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      } else {
        AppLogger.info(
          'Skipping vehicle sync for ${effectiveUser.role.value} - not authorized',
          tag: 'Sync',
        );
      }
      final isManagerOrAdmin =
          _isAdminLikeRole(effectiveUser.role) ||
          _isManagerLikeRole(effectiveUser.role);

      if (_canSyncHr(effectiveUser.role)) {
        AppLogger.debug('Executing HR sync operations...', tag: 'Sync');
        await runStep('sync_hr_modules', () async {
          await _hrSyncDelegate.syncAllHr(
            db,
            firebaseUid: firebaseUid,
            isManagerOrAdmin: isManagerOrAdmin,
            forceRefresh: forceRefresh,
          );
        });
      }
      await runStep(
        'master_data',
        () =>
            _masterDataDelegate.syncMasterData(db, forceRefresh: forceRefresh),
      );
      if (_isAdminLikeRole(effectiveUser.role)) {
        await runStep(
          'sales_targets',
          () => _salesSyncDelegate.syncSalesTargets(
            db,
            effectiveUser,
            forceRefresh: forceRefresh,
          ),
        );
      }
      if (_canSyncPayroll(effectiveUser.role)) {
        AppLogger.debug('Executing Payroll sync operations...', tag: 'Sync');
        await runStep('sync_payrolls', () async {
          await _hrSyncDelegate.syncPayrolls(
            db,
            firebaseUid: firebaseUid,
            isManagerOrAdmin: isManagerOrAdmin,
            forceRefresh: forceRefresh,
          );
        });
      }
      if (canSyncAccounting()) {
        await runStep(
          'accounts',
          () => _accountingSyncDelegate.syncAccounts(
            db,
            firebaseUid: firebaseUid,
            isManagerOrAdmin: isManagerOrAdmin,
            forceRefresh: forceRefresh,
          ),
        );
        await runStep(
          'vouchers',
          () => _accountingSyncDelegate.syncVouchers(
            db,
            firebaseUid: firebaseUid,
            isManagerOrAdmin: isManagerOrAdmin,
            forceRefresh: forceRefresh,
          ),
        );
        await runStep(
          'voucher_entries',
          () => _accountingSyncDelegate.syncVoucherEntries(
            db,
            firebaseUid: firebaseUid,
            isManagerOrAdmin: isManagerOrAdmin,
            forceRefresh: forceRefresh,
          ),
        );
      }

      _currentSyncStep = 'complete';
      _syncStepProgress = 1.0;
      notifyListeners();

      if (_syncIssues.isEmpty) {
        _masterDataService.invalidateCache();
        AppLogger.success('Sync Completed Successfully.', tag: 'Sync');
      } else {
        final preview = _syncIssues.take(3).join(' | ');
        AppLogger.warning(
          'Sync completed with ${_syncIssues.length} issue(s). $preview',
          tag: 'Sync',
        );
      }
      _lastSyncAllTime = DateTime.now();
      await _updatePendingCount();

      final unresolvedConflicts = await _dbService.conflicts
          .filter()
          .resolvedEqualTo(false)
          .count();
      final outboxCounts = await _computeOutboxCounts();
      final pendingByModule = await _computePendingByModuleSummary();
      return SyncRunResult(
        executed: true,
        skipped: false,
        criticalErrors: List<String>.from(_syncIssues),
        outboxPendingCount: outboxCounts.pending,
        outboxPermanentFailureCount: outboxCounts.permanentFailures,
        unresolvedConflictCount: unresolvedConflicts,
        completedAt: DateTime.now(),
        pendingByModule: pendingByModule,
      );
    } catch (e) {
      AppLogger.error('Sync Error', error: e, tag: 'Sync');
      _markSyncIssue('sync_all', e);
      final unresolvedConflicts = await _dbService.conflicts
          .filter()
          .resolvedEqualTo(false)
          .count();
      final outboxCounts = await _computeOutboxCounts();
      final pendingByModule = await _computePendingByModuleSummary();
      return SyncRunResult(
        executed: true,
        skipped: false,
        criticalErrors: List<String>.from(_syncIssues),
        outboxPendingCount: outboxCounts.pending,
        outboxPermanentFailureCount: outboxCounts.permanentFailures,
        unresolvedConflictCount: unresolvedConflicts,
        completedAt: DateTime.now(),
        pendingByModule: pendingByModule,
        message: e.toString(),
      );
    } finally {
      // Always reset syncing flag
      _isSyncing = false;
      _currentSyncStep = '';
      _syncStepProgress = 0.0;
      // Listener logic removed
      notifyListeners();
    }
  }

  /// Provides health and status insights for the offline-first synchronization.
  ///
  /// This is primarily used by the AI Assistant and Dashboard to give the user
  /// a clear picture of their sync state, pending updates, and data health.
  Future<Map<String, dynamic>> getOfflineInsights() async {
    final curPendingCount = pendingCount;
    // Check low stock count from local Isar database
    final lowStockCount = await _dbService.products
        .filter()
        .stockLessThan(10)
        .count();

    return {
      'pendingSyncs': curPendingCount,
      'lowStockItems': lowStockCount,
      'lastSync': lastSyncAllTime,
      'isHealthy': curPendingCount < 50,
      'statusMessage': curPendingCount == 0
          ? "Your local data is perfectly in sync with the cloud."
          : "You have $curPendingCount updates queued for upload.",
    };
  }

  /// Checks if the daily bulk sync condition is met (After 8:00 PM once per day).
  ///
  /// Bulk sync performs full data reconciliation and stock mismatch checks.
  Future<void> _checkAndPerformBulkSync(AppUser user) async {
    final now = DateTime.now();
    if (now.hour >= 20) {
      final prefs = await SharedPreferences.getInstance();
      final lastBulkDate = prefs.getString('last_bulk_sync_date');
      final todayStr = "${now.year}-${now.month}-${now.day}";

      if (lastBulkDate != todayStr) {
        AppLogger.info('8:00 PM Bulk Sync Triggered...', tag: 'Sync');

        // 1. Force sync all data
        await syncAll(user);

        // 2. Perform Stock Reconciliation (Check for Mismatches)
        await _reconcileStockAllocations(user);

        await prefs.setString('last_bulk_sync_date', todayStr);
      }
    }
  }

  Future<void> _reconcileStockAllocations(AppUser user) async {
    final db = _firebase.db;
    if (db == null) return;

    try {
      // T9-P5 REMOVED: Direct allocatedStock local reconcile overwrite
      final doc = await db
          .collection(CollectionRegistry.users)
          .doc(user.id)
          .get();
      if (!doc.exists) return;

      final serverData = doc.data();
      if (serverData == null) return;

      final serverAllocJson = _encodeAllocatedStockJson(
        serverData['allocatedStock'],
        serverData['allocatedStockJson'],
      );
      final localUser = await _dbService.users
          .filter()
          .idEqualTo(user.id)
          .findFirst();

      if (localUser != null && serverAllocJson != null) {
        if (localUser.allocatedStockJson != serverAllocJson) {
          // MISMATCH DETECTED
          // If local is NOT pending, then server is definitely authoritative, but we still flag.
          // If local IS pending, then we have a conflict.

          final isConflict = localUser.syncStatus == SyncStatus.pending;

          final reconcileAlertId =
              'reconcile_${fastHash('${user.id}|$serverAllocJson|${isConflict ? 'conflict' : 'drift'}')}';
          await _dbService.db.writeTxn(() async {
            await _dbService.alerts.put(
              AlertEntity()
                ..id = reconcileAlertId
                ..alertId = reconcileAlertId
                ..title = isConflict
                    ? 'Stock Sync Conflict'
                    : 'Stock Discrepancy'
                ..message = isConflict
                    ? 'Local stock changes conflict with server updates. Review required.'
                    : 'Local stock has been reconciled with server authority.'
                ..severity = isConflict
                    ? AlertSeverity.critical
                    : AlertSeverity.warning
                ..type = AlertType.criticalStock
                ..createdAt = DateTime.now()
                ..updatedAt = DateTime.now()
                ..isRead = false,
            );
          });

          // Even if conflict, user rule says "stock totals are server-authoritative"
          // So we update Isar, but only if it's NOT a conflict?
          // No, rule says "flagged for review rather than silently overwritten".
          // I will FLAG it and let the user decide, OR if it's NOT a conflict, I apply it.

          if (!isConflict) {
            await _dbService.db.writeTxn(() async {
              localUser.allocatedStockJson = serverAllocJson;
              localUser.syncStatus = SyncStatus.synced;
              await _dbService.users.put(localUser);
            });
          }
        }
      }
    } catch (e) {
      AppLogger.error('Reconciliation check failed', error: e, tag: 'Sync');
    }
  }

  // --- SYNC QUEUE PROCESSING ---

  /// Processes the local synchronization queue by pushing pending changes to Firestore.
  ///
  /// This method:
  /// 1. Reads the local queue from SharedPreferences.
  /// 2. Iterates through pending actions (add, set, update, delete).
  /// 3. Executes the corresponding Firestore operation.
  /// 4. Removes successfully synced items from the queue.
  /// 5. Automatically handles stock movements and status updates during the push.
  Future<void> processSyncQueue() async {
    await _isolateKnownBadWindowsQueueItemOnStartup();
    await _syncQueueProcessorDelegate.processSyncQueue();
  }

  Future<void> _isolateKnownBadWindowsQueueItemOnStartup() async {
    if (!_isWindowsSafeMode) return;

    final prefs = await SharedPreferences.getInstance();
    final queueId = prefs.getString(_windowsKnownBadQueueItemKey)?.trim();
    if (queueId == null || queueId.isEmpty) return;

    try {
      final entity = await _dbService.syncQueue.getById(queueId);
      if (entity == null) return;
      if (entity.collection != CollectionRegistry.sales ||
          entity.action != 'add') {
        return;
      }

      final decoded = OutboxCodec.decode(
        entity.dataJson,
        fallbackQueuedAt: entity.createdAt,
      );
      final now = DateTime.now();
      final updatedMeta = <String, dynamic>{
        ...decoded.meta,
        'nextRetryAt': now.add(const Duration(hours: 12)).toIso8601String(),
      };

      await _dbService.db.writeTxn(() async {
        entity
          ..dataJson = OutboxCodec.encodeEnvelope(
            payload: decoded.payload,
            existingMeta: updatedMeta,
            now: now,
            resetRetryState: false,
          )
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;
        await _dbService.syncQueue.put(entity);
      });

      AppLogger.warning(
        'Windows startup guard deferred known bad queue item: $queueId',
        tag: 'Sync',
      );
    } finally {
      await prefs.remove(_windowsKnownBadQueueItemKey);
    }
  }

  // Backward-compatible service bridge: offline sales sync routed via SyncManager.
  Future<void> syncOfflineSalesViaService() async {
    await _salesService.syncOfflineSales();
  }

  // Backward-compatible service bridge: users sync routed through delegate.
  Future<void> syncUsersViaDelegate({bool forceRefresh = true}) async {
    final db = _firebase.db;
    final currentUser = _currentUser;
    if (db == null || currentUser == null) return;
    await _usersSyncDelegate.syncUsers(
      db,
      currentUser: currentUser,
      forceRefresh: forceRefresh,
    );
  }

  // Backward-compatible service bridge: sales targets sync routed through delegate.
  Future<void> syncSalesTargetsViaDelegate({bool forceRefresh = true}) async {
    final db = _firebase.db;
    final currentUser = _currentUser;
    if (db == null || currentUser == null) return;
    await _salesSyncDelegate.syncSalesTargets(
      db,
      currentUser,
      forceRefresh: forceRefresh,
    );
  }

  /// Migrates legacy SharedPreferences queue to Isar. Run once on first boot.
  Future<void> _migrateLegacyQueue() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'local_sync_queue';
    final jsonStr = prefs.getString(key);

    if (jsonStr == null || jsonStr.isEmpty) return;

    final List<dynamic> legacyQueue = jsonDecode(jsonStr);
    if (legacyQueue.isEmpty) return;

    AppLogger.info(
      'Migrating ${legacyQueue.length} items from legacy queue...',
      tag: 'Sync',
    );

    await _dbService.db.writeTxn(() async {
      for (final item in legacyQueue) {
        final payload = Map<String, dynamic>.from(
          item['data'] as Map? ?? const <String, dynamic>{},
        );
        final collection = item['collection']?.toString().trim() ?? '';
        final documentId = payload['id']?.toString().trim() ?? '';
        if (collection.isEmpty || documentId.isEmpty) {
          continue;
        }
        await SyncQueueService.instance.addToQueue(
          collectionName: collection,
          documentId: documentId,
          operation: item['action'] as String,
          payload: payload,
        );
      }
    });

    // Clear legacy queue after successful migration
    await prefs.remove(key);
    AppLogger.success('Legacy queue migration complete.', tag: 'Sync');
  }

  Future<void> _ensurePartnerOutboxFromPending() async {
    await _partnerOutboxDelegate.ensurePartnerOutboxFromPending();
  }

  Future<void> _ensurePartnerOutboxForCollection(String collection) async {
    await _partnerOutboxDelegate.ensurePartnerOutboxForCollection(collection);
  }

  Future<void> _deletePartnerOutboxItem(
    String collection,
    String recordId,
  ) async {
    await _partnerOutboxDelegate.deletePartnerOutboxItem(collection, recordId);
  }

  Future<void> _upsertPartnerOutboxItem({
    required String collection,
    required String action,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    await _partnerOutboxDelegate.upsertPartnerOutboxItem(
      collection: collection,
      action: action,
      recordId: recordId,
      data: data,
    );
  }

  Future<OutboxCounts> _computeOutboxCounts() async {
    final allCounts = await _partnerOutboxDelegate.computeOutboxCounts();
    final queueItems = await _dbService.syncQueue.where().findAll();
    if (queueItems.isEmpty) {
      return allCounts;
    }

    int hiddenRetryable = 0;
    int hiddenPermanent = 0;
    for (final item in queueItems) {
      if (_isQueueVisibleToCurrentSession(item)) {
        continue;
      }
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      if (OutboxCodec.isPermanentFailure(decoded.meta)) {
        hiddenPermanent++;
      } else {
        hiddenRetryable++;
      }
    }

    final visiblePending = allCounts.pending - hiddenRetryable;
    final visiblePermanent = allCounts.permanentFailures - hiddenPermanent;
    return OutboxCounts(
      pending: visiblePending < 0 ? 0 : visiblePending,
      permanentFailures: visiblePermanent < 0 ? 0 : visiblePermanent,
    );
  }

  Future<Map<String, int>> _computePendingByModuleSummary() async {
    final countFutures = <String, Future<int>>{
      'customers': _dbService.customers
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'dealers': _dbService.dealers
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'users': _dbService.users
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'custom_roles': _dbService.customRoles
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'products': _dbService.products
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'attendances': _dbService.attendances
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'duty_sessions': _dbService.dutySessions
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'route_sessions': _dbService.routeSessions
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'customer_visits': _dbService.customerVisits
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'opening_stock_entries': _dbService.openingStockEntries
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'stock_ledger': _dbService.stockLedger
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'dispatches': _dbService.dispatches
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'routes': _dbService.routes
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'vehicles': _dbService.vehicles
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'diesel_logs': _dbService.dieselLogs
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'units': _dbService.units
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'product_categories': _dbService.categories
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'product_types': _dbService.productTypes
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'leave_requests': _dbService.leaveRequests
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'advances': _dbService.advances
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'performance_reviews': _dbService.performanceReviews
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'employee_documents': _dbService.employeeDocuments
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'employees': _dbService.employees
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
      'sales_targets': _dbService.salesTargets
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .count(),
    };

    final counts = await Future.wait(countFutures.values);
    final summary = <String, int>{};
    var index = 0;
    for (final key in countFutures.keys) {
      summary[key] = counts[index++];
    }
    return summary;
  }

  Map<String, dynamic> _buildCustomerSyncPayload(CustomerEntity customer) {
    final fieldEncryption = FieldEncryptionService.instance;
    final ctxPrefix = 'customer:${customer.id}:';
    final mobile = fieldEncryption.isEnabled
        ? fieldEncryption.decryptString(customer.mobile, '${ctxPrefix}mobile')
        : customer.mobile;
    final alternateMobile =
        fieldEncryption.isEnabled && customer.alternateMobile != null
        ? fieldEncryption.decryptString(
            customer.alternateMobile!,
            '${ctxPrefix}altMobile',
          )
        : customer.alternateMobile;
    final email = fieldEncryption.isEnabled && customer.email != null
        ? fieldEncryption.decryptString(customer.email!, '${ctxPrefix}email')
        : customer.email;
    final address = fieldEncryption.isEnabled
        ? fieldEncryption.decryptString(customer.address, '${ctxPrefix}address')
        : customer.address;
    final addressLine2 =
        fieldEncryption.isEnabled && customer.addressLine2 != null
        ? fieldEncryption.decryptString(
            customer.addressLine2!,
            '${ctxPrefix}address2',
          )
        : customer.addressLine2;
    final city = fieldEncryption.isEnabled && customer.city != null
        ? fieldEncryption.decryptString(customer.city!, '${ctxPrefix}city')
        : customer.city;
    final state = fieldEncryption.isEnabled && customer.state != null
        ? fieldEncryption.decryptString(customer.state!, '${ctxPrefix}state')
        : customer.state;
    final pincode = fieldEncryption.isEnabled && customer.pincode != null
        ? fieldEncryption.decryptString(
            customer.pincode!,
            '${ctxPrefix}pincode',
          )
        : customer.pincode;
    final gstin = fieldEncryption.isEnabled && customer.gstin != null
        ? fieldEncryption.decryptString(customer.gstin!, '${ctxPrefix}gstin')
        : customer.gstin;
    final pan = fieldEncryption.isEnabled && customer.pan != null
        ? fieldEncryption.decryptString(customer.pan!, '${ctxPrefix}pan')
        : customer.pan;

    return {
      'id': customer.id,
      'shopName': customer.shopName,
      'ownerName': customer.ownerName,
      'mobile': mobile,
      'alternateMobile': alternateMobile,
      'email': email,
      'address': address,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'gstin': gstin,
      'pan': pan,
      'route': customer.route,
      'routeSequence': customer.routeSequence,
      'status': customer.status,
      'balance': customer.balance,
      'creditLimit': customer.creditLimit,
      'paymentTerms': customer.paymentTerms,
      'latitude': customer.latitude,
      'longitude': customer.longitude,
      'createdAt': customer.createdAt,
      'createdBy': customer.createdBy,
      'createdByName': customer.createdByName,
      'isDeleted': customer.isDeleted,
      'updatedAt': customer.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _buildDealerSyncPayload(DealerEntity dealer) {
    return {
      'id': dealer.id,
      'name': dealer.name,
      'contactPerson': dealer.contactPerson,
      'mobile': dealer.mobile,
      'contactNumber': dealer.mobile,
      'alternateMobile': dealer.alternateMobile,
      'email': dealer.email,
      'address': dealer.address,
      'addressLine2': dealer.addressLine2,
      'city': dealer.city,
      'state': dealer.state,
      'pincode': dealer.pincode,
      'gstin': dealer.gstin,
      'pan': dealer.pan,
      'status': dealer.status,
      'commissionPercentage': dealer.commissionPercentage,
      'paymentTerms': dealer.paymentTerms,
      'territory': dealer.territory,
      'assignedRouteId': dealer.assignedRouteId,
      'assignedRouteName': dealer.assignedRouteName,
      'latitude': dealer.latitude,
      'longitude': dealer.longitude,
      'createdAt': dealer.createdAt,
      'isDeleted': dealer.isDeleted,
      'updatedAt': dealer.updatedAt.toIso8601String(),
    };
  }

  /// Public method for services to enqueue items to the robust Isar queue.
  Future<Object?> buildQueueEntity({
    required String collection,
    required String action,
    required Map<String, dynamic> data,
    DateTime? now,
  }) async {
    final documentId = data['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) {
      return null;
    }
    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: documentId,
      operation: action,
      payload: data,
    );
    return null;
  }

  Future<void> enqueueItem({
    required String collection,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    await buildQueueEntity(
      collection: collection,
      action: action,
      data: data,
    );
    await _updatePendingCount();
  }

  Future<void> refreshPendingCount() => _updatePendingCount();

  /// Clears stuck opening stock queue items for the current user session.
  /// This is useful when opening stock entries are stuck due to ownership issues.
  Future<int> clearStuckOpeningStockQueue() async {
    int clearedCount = 0;
    try {
      final queueItems = await _dbService.syncQueue.where().findAll();
      final itemsToDelete = <Id>[];
      
      for (final item in queueItems) {
        if (item.collection == CollectionRegistry.openingStockEntries ||
            (item.collection == CollectionRegistry.inventoryCommands && 
             item.id.contains('opening'))) {
          itemsToDelete.add(item.isarId);
        }
      }
      
      if (itemsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          for (final id in itemsToDelete) {
            await _dbService.syncQueue.delete(id);
          }
        });
        clearedCount = itemsToDelete.length;
        await _updatePendingCount();
        AppLogger.success(
          'Cleared $clearedCount stuck opening stock queue items',
          tag: 'Sync',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Failed to clear stuck opening stock queue',
        error: e,
        tag: 'Sync',
      );
    }
    return clearedCount;
  }

  /// Resets retry state for stuck opening stock queue items.
  /// This forces immediate retry by clearing backoff timers.
  Future<int> resetStuckOpeningStockRetry() async {
    int resetCount = 0;
    try {
      final queueItems = await _dbService.syncQueue.where().findAll();
      final itemsToReset = <SyncQueueEntity>[];
      
      for (final item in queueItems) {
        if (item.collection == CollectionRegistry.openingStockEntries ||
            (item.collection == CollectionRegistry.inventoryCommands && 
             item.id.contains('opening'))) {
          itemsToReset.add(item);
        }
      }
      
      if (itemsToReset.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          final now = DateTime.now();
          for (final item in itemsToReset) {
            final decoded = OutboxCodec.decode(
              item.dataJson,
              fallbackQueuedAt: item.createdAt,
            );
            
            // Reset retry state to force immediate processing
            item.dataJson = OutboxCodec.encodeEnvelope(
              payload: decoded.payload,
              existingMeta: decoded.meta,
              now: now,
              resetRetryState: true,
            );
            item.updatedAt = now;
            item.syncStatus = SyncStatus.pending;
            await _dbService.syncQueue.put(item);
          }
        });
        resetCount = itemsToReset.length;
        await _updatePendingCount();
        AppLogger.success(
          'Reset retry state for $resetCount opening stock queue items',
          tag: 'Sync',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Failed to reset opening stock queue retry state',
        error: e,
        tag: 'Sync',
      );
    }
    return resetCount;
  }

  /// Auto-fetch daily production logs (Bhatti & Production)
  /// Called on app start and network restore
  Future<void> autoFetchDailyProductionData() async {
    final db = _firebase.db;
    if (db == null || _firebase.auth?.currentUser == null) return;

    // Fetch last 7 days to cover missed entries
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));

    AppLogger.info('Auto-fetching daily production data...', tag: 'Sync');

    try {
      await Future.wait([
        _bhattiRepo.fetchAndCacheBhattiEntries(
          startDate: startDate,
          endDate: endDate,
        ),
        _productionRepo.fetchAndCacheProductionEntries(
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      AppLogger.success(
        'Daily production data auto-fetched & cached.',
        tag: 'Sync',
      );
    } catch (e) {
      AppLogger.error('Auto-fetch failed', error: e, tag: 'Sync');
    }
  }

  // --- GENERIC SYNC METHODS ---

  @override
  void dispose() {
    cleanup(notify: false);
    super.dispose();
  }

  String _normalizeProductItemTypeLabel(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return 'Raw Material';

    final normalized = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    bool has(String token) => normalized.contains(token);
    final isSemiLike = has('semi') && (has('finish') || has('finis'));
    if (isSemiLike) return 'Semi-Finished Good';
    if (has('finished good') || has('finished goods') || has('finish good')) {
      return 'Finished Good';
    }
    if (has('raw')) return 'Raw Material';
    if (has('traded')) return 'Traded Good';
    if (has('packag')) return 'Packaging Material';
    if (has('oil') || has('liquid')) return 'Oils & Liquids';
    if (has('chemical') || has('additive')) return 'Chemicals & Additives';
    return raw;
  }
}
