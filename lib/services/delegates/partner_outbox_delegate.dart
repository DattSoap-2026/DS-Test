import 'package:isar/isar.dart';

import 'package:flutter_app/core/sync/sync_queue_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/advance_entity.dart';
import 'package:flutter_app/data/local/entities/attendance_entity.dart';
import 'package:flutter_app/data/local/entities/category_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/customer_visit_entity.dart';
import 'package:flutter_app/data/local/entities/custom_role_entity.dart';
import 'package:flutter_app/data/local/entities/dealer_entity.dart';
import 'package:flutter_app/data/local/entities/diesel_log_entity.dart';
import 'package:flutter_app/data/local/entities/duty_session_entity.dart';
import 'package:flutter_app/data/local/entities/employee_document_entity.dart';
import 'package:flutter_app/data/local/entities/employee_entity.dart';
import 'package:flutter_app/data/local/entities/leave_request_entity.dart';
import 'package:flutter_app/data/local/entities/opening_stock_entity.dart';
import 'package:flutter_app/data/local/entities/performance_review_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/product_type_entity.dart';
import 'package:flutter_app/data/local/entities/route_entity.dart';
import 'package:flutter_app/data/local/entities/route_session_entity.dart';
import 'package:flutter_app/data/local/entities/sales_target_entity.dart';
import 'package:flutter_app/data/local/entities/stock_ledger_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/entities/unit_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/local/entities/vehicle_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';

typedef BuildCustomerSyncPayload =
    Map<String, dynamic> Function(CustomerEntity customer);
typedef BuildDealerSyncPayload =
    Map<String, dynamic> Function(DealerEntity dealer);

class PartnerOutboxDelegate {
  final DatabaseService _dbService;
  final BuildCustomerSyncPayload _buildCustomerSyncPayload;
  final BuildDealerSyncPayload _buildDealerSyncPayload;

  PartnerOutboxDelegate({
    required DatabaseService dbService,
    required BuildCustomerSyncPayload buildCustomerSyncPayload,
    required BuildDealerSyncPayload buildDealerSyncPayload,
  }) : _dbService = dbService,
       _buildCustomerSyncPayload = buildCustomerSyncPayload,
       _buildDealerSyncPayload = buildDealerSyncPayload;

  String _partnerOutboxId(String collection, String recordId) {
    return 'outbox_${collection}_$recordId';
  }

  Future<void> ensurePartnerOutboxFromPending() async {
    await ensurePartnerOutboxForCollection('customers');
    await ensurePartnerOutboxForCollection('dealers');
  }

  Future<void> ensurePartnerOutboxForCollection(String collection) async {
    if (collection == 'customers') {
      final pendingCustomers = await _dbService.customers
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final items = pendingCustomers
          .map(
            (customer) => _PartnerOutboxItemInput(
              collection: 'customers',
              action: customer.isDeleted ? 'delete' : 'set',
              recordId: customer.id,
              data: _buildCustomerSyncPayload(customer),
            ),
          )
          .toList(growable: false);
      await _upsertPartnerOutboxItems(items);
      return;
    }

    if (collection == 'dealers') {
      final pendingDealers = await _dbService.dealers
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final items = pendingDealers
          .map(
            (dealer) => _PartnerOutboxItemInput(
              collection: 'dealers',
              action: dealer.isDeleted ? 'delete' : 'set',
              recordId: dealer.id,
              data: _buildDealerSyncPayload(dealer),
            ),
          )
          .toList(growable: false);
      await _upsertPartnerOutboxItems(items);
    }
  }

  Future<void> _upsertPartnerOutboxItems(
    List<_PartnerOutboxItemInput> items,
  ) async {
    if (items.isEmpty) {
      return;
    }

    final queueIds = items
        .map((item) => _partnerOutboxId(item.collection, item.recordId))
        .toList(growable: false);
    final existingRecords = await _dbService.syncQueue.getAll(
      queueIds.map(fastHash).toList(growable: false),
    );
    final existingByQueueId = <String, SyncQueueEntity>{};
    for (var i = 0; i < queueIds.length; i++) {
      final existing = existingRecords[i];
      if (existing != null && existing.id == queueIds[i]) {
        existingByQueueId[queueIds[i]] = existing;
      }
    }

    for (final item in items) {
      await SyncQueueService.instance.addToQueue(
        collectionName: item.collection,
        documentId: item.recordId,
        operation: item.action,
        payload: item.data,
      );
    }
  }

  Future<void> deletePartnerOutboxItem(String collection, String recordId) async {
    final queueId = _partnerOutboxId(collection, recordId);
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.deleteById(queueId);
    });
  }

  Future<void> upsertPartnerOutboxItem({
    required String collection,
    required String action,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    await _upsertPartnerOutboxItems([
      _PartnerOutboxItemInput(
        collection: collection,
        action: action,
        recordId: recordId,
        data: data,
      ),
    ]);
  }

  Future<int> computeStrictOutboxPendingCount() async {
    final counts = await computeOutboxCounts();
    return counts.pending;
  }

  Future<int> computePermanentOutboxFailureCount() async {
    final queueItems = await _dbService.syncQueue.where().findAll();
    return _countPermanentFailures(queueItems);
  }

  Future<OutboxCounts> computeOutboxCounts() async {
    final queueItems = await _dbService.syncQueue.where().findAll();
    final queueIds = <String>{};
    int queuedRetryable = 0;
    int permanent = 0;
    for (final item in queueItems) {
      queueIds.add(item.id);
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      if (OutboxCodec.isPermanentFailure(decoded.meta)) {
        permanent++;
      } else {
        queuedRetryable++;
      }
    }

    final pendingWithoutQueue = await _countPendingWithoutOutbox(queueIds);
    return OutboxCounts(
      pending: queuedRetryable + pendingWithoutQueue,
      permanentFailures: permanent,
    );
  }

  int _countPermanentFailures(List<SyncQueueEntity> queueItems) {
    int permanent = 0;
    for (final item in queueItems) {
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      if (OutboxCodec.isPermanentFailure(decoded.meta)) {
        permanent++;
      }
    }
    return permanent;
  }

  Future<int> _countPendingWithoutOutbox(Set<String> queueIds) async {
    int missing = 0;

    bool isQueued(String collection, Map<String, dynamic> payload, String key) {
      final queueId = OutboxCodec.buildQueueId(
        collection,
        payload,
        explicitRecordKey: key,
      );
      return queueIds.contains(queueId);
    }

    final pendingCustomersFuture = _dbService.customers
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingDealersFuture = _dbService.dealers
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingAttendancesFuture = _dbService.attendances
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingUnitsFuture = _dbService.units
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingCategoriesFuture = _dbService.categories
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingProductTypesFuture = _dbService.productTypes
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingLeavesFuture = _dbService.leaveRequests
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingAdvancesFuture = _dbService.advances
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingReviewsFuture = _dbService.performanceReviews
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingDocsFuture = _dbService.employeeDocuments
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingEmployeesFuture = _dbService.employees
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingTargetsFuture = _dbService.salesTargets
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingUsersFuture = _dbService.users
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingCustomRolesFuture = _dbService.customRoles
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingProductsFuture = _dbService.products
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingDutySessionsFuture = _dbService.dutySessions
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingRouteSessionsFuture = _dbService.routeSessions
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingCustomerVisitsFuture = _dbService.customerVisits
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingOpeningStockFuture = _dbService.openingStockEntries
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingLedgerEntriesFuture = _dbService.stockLedger
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingRoutesFuture = _dbService.routes
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingVehiclesFuture = _dbService.vehicles
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    final pendingDieselLogsFuture = _dbService.dieselLogs
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();

    final pendingCustomers = await pendingCustomersFuture;
    for (final customer in pendingCustomers) {
      if (!isQueued(
        'customers',
        _buildCustomerSyncPayload(customer),
        customer.id,
      )) {
        missing++;
      }
    }

    final pendingDealers = await pendingDealersFuture;
    for (final dealer in pendingDealers) {
      if (!isQueued('dealers', _buildDealerSyncPayload(dealer), dealer.id)) {
        missing++;
      }
    }

    final pendingAttendances = await pendingAttendancesFuture;
    for (final attendance in pendingAttendances) {
      if (!isQueued('attendances', {'id': attendance.id}, attendance.id)) {
        missing++;
      }
    }

    final pendingUnits = await pendingUnitsFuture;
    for (final unit in pendingUnits) {
      if (!isQueued('units', {'id': unit.id}, unit.id)) {
        missing++;
      }
    }

    final pendingCategories = await pendingCategoriesFuture;
    for (final category in pendingCategories) {
      if (!isQueued(
        'product_categories',
        {'id': category.id},
        category.id,
      )) {
        missing++;
      }
    }

    final pendingProductTypes = await pendingProductTypesFuture;
    for (final productType in pendingProductTypes) {
      if (!isQueued('product_types', {'id': productType.id}, productType.id)) {
        missing++;
      }
    }

    final pendingLeaves = await pendingLeavesFuture;
    for (final leave in pendingLeaves) {
      if (!isQueued('leave_requests', {'id': leave.id}, leave.id)) {
        missing++;
      }
    }

    final pendingAdvances = await pendingAdvancesFuture;
    for (final advance in pendingAdvances) {
      if (!isQueued('advances', {'id': advance.id}, advance.id)) {
        missing++;
      }
    }

    final pendingReviews = await pendingReviewsFuture;
    for (final review in pendingReviews) {
      if (!isQueued('performance_reviews', {'id': review.id}, review.id)) {
        missing++;
      }
    }

    final pendingDocs = await pendingDocsFuture;
    for (final doc in pendingDocs) {
      if (!isQueued('employee_documents', {'id': doc.id}, doc.id)) {
        missing++;
      }
    }

    final pendingEmployees = await pendingEmployeesFuture;
    for (final employee in pendingEmployees) {
      if (!isQueued('employees', {'id': employee.id}, employee.id)) {
        missing++;
      }
    }

    final pendingTargets = await pendingTargetsFuture;
    for (final target in pendingTargets) {
      if (!isQueued('sales_targets', {'id': target.id}, target.id)) {
        missing++;
      }
    }

    final pendingUsers = await pendingUsersFuture;
    for (final user in pendingUsers) {
      if (!isQueued('users', {'id': user.id}, user.id)) {
        missing++;
      }
    }

    final pendingCustomRoles = await pendingCustomRolesFuture;
    for (final role in pendingCustomRoles) {
      if (!isQueued('custom_roles', {'id': role.id}, role.id)) {
        missing++;
      }
    }

    final pendingProducts = await pendingProductsFuture;
    for (final product in pendingProducts) {
      if (!isQueued('products', {'id': product.id}, product.id)) {
        missing++;
      }
    }

    final pendingDutySessions = await pendingDutySessionsFuture;
    for (final duty in pendingDutySessions) {
      if (!isQueued('duty_sessions', {'id': duty.id}, duty.id)) {
        missing++;
      }
    }

    final pendingRouteSessions = await pendingRouteSessionsFuture;
    for (final route in pendingRouteSessions) {
      if (!isQueued('route_sessions', {'id': route.id}, route.id)) {
        missing++;
      }
    }

    final pendingCustomerVisits = await pendingCustomerVisitsFuture;
    for (final visit in pendingCustomerVisits) {
      if (!isQueued('customer_visits', {'id': visit.id}, visit.id)) {
        missing++;
      }
    }

    final pendingOpeningStock = await pendingOpeningStockFuture;
    for (final entry in pendingOpeningStock) {
      if (!isQueued('opening_stock_entries', {'id': entry.id}, entry.id)) {
        missing++;
      }
    }

    final pendingLedgerEntries = await pendingLedgerEntriesFuture;
    for (final entry in pendingLedgerEntries) {
      if (!isQueued('stock_ledger', {'id': entry.id}, entry.id)) {
        missing++;
      }
    }

    final pendingRoutes = await pendingRoutesFuture;
    for (final route in pendingRoutes) {
      if (!isQueued('routes', {'id': route.id}, route.id)) {
        missing++;
      }
    }

    final pendingVehicles = await pendingVehiclesFuture;
    for (final vehicle in pendingVehicles) {
      if (!isQueued('vehicles', {'id': vehicle.id}, vehicle.id)) {
        missing++;
      }
    }

    final pendingDieselLogs = await pendingDieselLogsFuture;
    for (final log in pendingDieselLogs) {
      if (!isQueued('diesel_logs', {'id': log.id}, log.id)) {
        missing++;
      }
    }

    return missing;
  }
}

class OutboxCounts {
  final int pending;
  final int permanentFailures;

  const OutboxCounts({
    required this.pending,
    required this.permanentFailures,
  });
}

class _PartnerOutboxItemInput {
  final String collection;
  final String action;
  final String recordId;
  final Map<String, dynamic> data;

  const _PartnerOutboxItemInput({
    required this.collection,
    required this.action,
    required this.recordId,
    required this.data,
  });
}
