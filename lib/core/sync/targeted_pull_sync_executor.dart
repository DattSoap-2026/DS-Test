import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/core/sync/sync_request.dart';
import 'package:flutter_app/core/sync/sync_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/dealer_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/delegates/customers_sync_delegate.dart';
import 'package:flutter_app/services/delegates/dealers_sync_delegate.dart';
import 'package:flutter_app/services/delegates/hr_sync_delegate.dart';
import 'package:flutter_app/services/delegates/master_data_sync_delegate.dart';
import 'package:flutter_app/services/delegates/sales_sync_delegate.dart';
import 'package:flutter_app/services/delegates/users_sync_delegate.dart';
import 'package:flutter_app/services/field_encryption_service.dart';
import 'package:flutter_app/services/sync_analytics_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/utils/app_logger.dart';

import '../database/isar_service.dart';

/// Executes pull-capable sync delegates for specific modules.
class TargetedPullSyncExecutor {
  TargetedPullSyncExecutor({
    required DatabaseService dbService,
    required SyncCommonUtils utils,
    FirebaseServices? firebase,
  }) : _dbService = dbService,
       _utils = utils,
       _firebase = firebase ?? firebaseServices;

  final DatabaseService _dbService;
  final SyncCommonUtils _utils;
  final FirebaseServices _firebase;

  Future<void> execute(
    Set<SyncModule> modules, {
    AppUser? currentUser,
    bool forceRefresh = false,
    String source = 'unknown',
  }) async {
    final firestore = _firebase.db;
    if (firestore == null) {
      AppLogger.warning(
        'Targeted pull skipped for $source: Firestore unavailable',
        tag: 'Sync',
      );
      return;
    }

    final resolvedUser = currentUser ?? await resolveCurrentUser();
    _utils.bindCursorUser(
      resolvedUser?.id ?? fb_auth.FirebaseAuth.instance.currentUser?.uid,
    );
    final expandedModules = modules.contains(SyncModule.all)
        ? const <SyncModule>{
            SyncModule.users,
            SyncModule.masterData,
            SyncModule.customers,
            SyncModule.dealers,
            SyncModule.sales,
            SyncModule.attendance,
          }
        : Set<SyncModule>.from(modules);

    Future<void> recordMetric({
      required String entityType,
      required SyncOperation operation,
      required int recordCount,
      required int durationMs,
      required bool success,
      String? errorMessage,
    }) {
      return _utils.recordMetric(
        userId: resolvedUser?.id,
        entityType: entityType,
        operation: operation,
        recordCount: recordCount,
        durationMs: durationMs,
        success: success,
        errorMessage: errorMessage,
      );
    }

    void markSyncIssue(String step, Object error) {
      AppLogger.warning(
        'Targeted pull issue during $step: $error',
        tag: 'Sync',
      );
    }

    final usersDelegate = UsersSyncDelegate(
      dbService: _dbService,
      utils: _utils,
      recordMetric: recordMetric,
    );
    final masterDataDelegate = MasterDataSyncDelegate(
      _dbService,
      deleteQueueItem: _utils.deleteQueueItem,
      detectAndFlagConflict: ({
        required String entityId,
        required String entityType,
        required Map<String, dynamic> serverData,
        required BaseEntity? localEntity,
        required Map<String, dynamic> Function(BaseEntity) localToJson,
      }) => _utils.detectAndFlagConflict(
        entityId: entityId,
        entityType: entityType,
        serverData: serverData,
        localEntity: localEntity,
        localToJson: localToJson,
      ),
      setLastSyncTimestamp: _utils.setLastSyncTimestamp,
      getLastSyncTimestamp: _utils.getLastSyncTimestamp,
      recordMetric: recordMetric,
      markSyncIssue: markSyncIssue,
      parseRemoteDate: _utils.parseRemoteDate,
      normalizeProductItemTypeLabel: _normalizeProductItemTypeLabel,
      chunkList: _utils.chunkList,
    );
    final customersDelegate = CustomersSyncDelegate(
      dbService: _dbService,
      utils: _utils,
      recordMetric: recordMetric,
      markSyncIssue: markSyncIssue,
    );
    final dealersDelegate = DealersSyncDelegate(
      dbService: _dbService,
      utils: _utils,
      recordMetric: recordMetric,
      markSyncIssue: markSyncIssue,
    );
    final salesDelegate = SalesSyncDelegate(
      dbService: _dbService,
      deleteQueueItem: _utils.deleteQueueItem,
      recordMetric: recordMetric,
      markSyncIssue: markSyncIssue,
      getLastSyncTimestamp: _utils.getLastSyncTimestamp,
      setLastSyncTimestamp: _utils.setLastSyncTimestamp,
      detectAndFlagConflict: ({
        required BaseEntity? localEntity,
        required Map<String, dynamic> serverData,
        required String entityType,
        required String entityId,
        required Map<String, dynamic> Function(BaseEntity) localToJson,
      }) => _utils.detectAndFlagConflict(
        entityId: entityId,
        entityType: entityType,
        serverData: serverData,
        localEntity: localEntity,
        localToJson: localToJson,
      ),
      parseRemoteDate: _utils.parseRemoteDate,
      chunkList: _utils.chunkList,
    );
    final hrDelegate = HrSyncDelegate(
      dbService: _dbService,
      utils: _utils,
      recordMetric: recordMetric,
      markSyncIssue: markSyncIssue,
    );

    if (expandedModules.contains(SyncModule.users)) {
      await usersDelegate.syncUsers(
        firestore,
        currentUser: resolvedUser,
        forceRefresh: forceRefresh,
      );
    }

    if (expandedModules.contains(SyncModule.masterData)) {
      await masterDataDelegate.syncMasterData(
        firestore,
        forceRefresh: forceRefresh,
      );
    }

    if (expandedModules.contains(SyncModule.dealers) && resolvedUser != null) {
      await dealersDelegate.syncDealers(
        firestore,
        resolvedUser,
        forceRefresh: forceRefresh,
        buildDealerSyncPayload: _buildDealerSyncPayload,
        deletePartnerOutboxItem: _utils.deletePartnerOutboxItem,
        upsertPartnerOutboxItem: _utils.upsertPartnerOutboxItem,
      );
    }

    if (expandedModules.contains(SyncModule.customers) && resolvedUser != null) {
      await customersDelegate.syncCustomers(
        firestore,
        resolvedUser,
        forceRefresh: forceRefresh,
        resolveSalesmanRouteScope: _resolveSalesmanRouteScope,
        buildCustomerSyncPayload: _buildCustomerSyncPayload,
        deletePartnerOutboxItem: _utils.deletePartnerOutboxItem,
        upsertPartnerOutboxItem: _utils.upsertPartnerOutboxItem,
      );
    }

    if (expandedModules.contains(SyncModule.sales) && resolvedUser != null) {
      await salesDelegate.syncSalesData(
        firestore,
        resolvedUser,
        forceRefresh: forceRefresh,
      );
    }

    if (expandedModules.contains(SyncModule.attendance)) {
      await hrDelegate.syncAttendances(
        firestore,
        firebaseUid: fb_auth.FirebaseAuth.instance.currentUser?.uid,
        isManagerOrAdmin: _isManagerOrAdmin(resolvedUser),
        forceRefresh: forceRefresh,
      );
    }
  }

  Future<AppUser?> resolveCurrentUser() async {
    final authUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      final byUid = await _dbService.users
          .filter()
          .idEqualTo(authUser.uid)
          .findFirst();
      if (byUid != null) {
        return byUid.toDomain();
      }

      final email = authUser.email?.trim().toLowerCase();
      if (email != null && email.isNotEmpty) {
        final byEmail = await _dbService.users
            .filter()
            .emailEqualTo(email)
            .findFirst();
        if (byEmail != null) {
          return byEmail.toDomain();
        }
      }
    }

    final preferences = await SharedPreferences.getInstance();
    final persistedUserId = preferences.getString(SyncService.currentUserKey);
    if (persistedUserId == null || persistedUserId.trim().isEmpty) {
      return null;
    }

    final persistedUser = await _dbService.users
        .filter()
        .idEqualTo(persistedUserId.trim())
        .findFirst();
    return persistedUser?.toDomain();
  }

  static Future<void> bootstrapStoredRequests() async {
    try {
      await firebaseServices.initialize();
      await IsarService.instance.initialize();
      final dbService = DatabaseService.instance;
      final utils = SyncCommonUtils(
        dbService: dbService,
        analyticsService: SyncAnalyticsService(dbService),
      );
      final executor = TargetedPullSyncExecutor(
        dbService: dbService,
        utils: utils,
      );
      final syncService = SyncService.instance;
      await syncService.initialize();
      syncService.registerPullExecutor(
        (
          modules, {
          bool forceRefresh = false,
          String source = 'unknown',
        }) => executor.execute(
          modules,
          currentUser: syncService.currentUser,
          forceRefresh: forceRefresh,
          source: source,
        ),
      );
      final currentUser = await executor.resolveCurrentUser();
      if (currentUser != null) {
        syncService.setCurrentUser(currentUser);
      }
      await syncService.processStoredPullRequests(source: 'fcm_background');
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Background sync bootstrap skipped: $error',
        tag: 'Sync',
      );
      AppLogger.debug(stackTrace.toString(), tag: 'Sync');
    }
  }

  bool _isManagerOrAdmin(AppUser? user) {
    final role = user?.role;
    return role == UserRole.admin ||
        role == UserRole.owner ||
        role == UserRole.salesManager ||
        role == UserRole.productionManager ||
        role == UserRole.dispatchManager ||
        role == UserRole.dealerManager;
  }

  Future<List<String>> _resolveSalesmanRouteScope(
    firestore.FirebaseFirestore _,
    AppUser user,
  ) async {
    final routes = <String>{};

    void addRoute(String? value) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        routes.add(normalized);
      }
    }

    for (final route in user.assignedRoutes ?? const <String>[]) {
      addRoute(route);
    }
    addRoute(user.assignedSalesRoute);
    addRoute(user.assignedDeliveryRoute);

    final resolved = routes.toList(growable: false)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return resolved;
  }

  Map<String, dynamic> _buildCustomerSyncPayload(CustomerEntity customer) {
    final fieldEncryption = FieldEncryptionService.instance;
    final contextPrefix = 'customer:${customer.id}:';
    final mobile = fieldEncryption.isEnabled
        ? fieldEncryption.decryptString(customer.mobile, '${contextPrefix}mobile')
        : customer.mobile;
    final alternateMobile =
        fieldEncryption.isEnabled && customer.alternateMobile != null
        ? fieldEncryption.decryptString(
            customer.alternateMobile!,
            '${contextPrefix}altMobile',
          )
        : customer.alternateMobile;
    final email = fieldEncryption.isEnabled && customer.email != null
        ? fieldEncryption.decryptString(customer.email!, '${contextPrefix}email')
        : customer.email;
    final address = fieldEncryption.isEnabled
        ? fieldEncryption.decryptString(
            customer.address,
            '${contextPrefix}address',
          )
        : customer.address;
    final addressLine2 =
        fieldEncryption.isEnabled && customer.addressLine2 != null
        ? fieldEncryption.decryptString(
            customer.addressLine2!,
            '${contextPrefix}address2',
          )
        : customer.addressLine2;
    final city = fieldEncryption.isEnabled && customer.city != null
        ? fieldEncryption.decryptString(customer.city!, '${contextPrefix}city')
        : customer.city;
    final state = fieldEncryption.isEnabled && customer.state != null
        ? fieldEncryption.decryptString(customer.state!, '${contextPrefix}state')
        : customer.state;
    final pincode = fieldEncryption.isEnabled && customer.pincode != null
        ? fieldEncryption.decryptString(
            customer.pincode!,
            '${contextPrefix}pincode',
          )
        : customer.pincode;
    final gstin = fieldEncryption.isEnabled && customer.gstin != null
        ? fieldEncryption.decryptString(customer.gstin!, '${contextPrefix}gstin')
        : customer.gstin;
    final pan = fieldEncryption.isEnabled && customer.pan != null
        ? fieldEncryption.decryptString(customer.pan!, '${contextPrefix}pan')
        : customer.pan;

    return <String, dynamic>{
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
    return <String, dynamic>{
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

  String _normalizeProductItemTypeLabel(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return 'Raw Material';
    }

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
