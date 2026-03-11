// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase/firebase_config.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/attendance_entity.dart';
import '../data/local/entities/bhatti_entry_entity.dart';
import '../data/local/entities/category_entity.dart';
import '../data/local/entities/conflict_entity.dart';
import '../data/local/entities/customer_entity.dart';
import '../data/local/entities/customer_visit_entity.dart';
import '../data/local/entities/dealer_entity.dart';
import '../data/local/entities/diesel_log_entity.dart';
import '../data/local/entities/duty_session_entity.dart';
import '../data/local/entities/opening_stock_entity.dart';
import '../data/local/entities/payroll_record_entity.dart';
import '../data/local/entities/product_entity.dart';
import '../data/local/entities/product_type_entity.dart';
import '../data/local/entities/production_entry_entity.dart';
import '../data/local/entities/return_entity.dart';
import '../data/local/entities/route_entity.dart';
import '../data/local/entities/route_session_entity.dart';
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/sales_target_entity.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../data/local/entities/sync_metric_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import '../data/local/entities/tank_entity.dart';
import '../data/local/entities/tank_transaction_entity.dart';
import '../data/local/entities/trip_entity.dart';
import '../data/local/entities/unit_entity.dart';
import '../data/local/entities/user_entity.dart';
import '../data/local/entities/vehicle_entity.dart';
import '../services/database_service.dart';
import '../services/outbox_codec.dart';

class ForensicFailureEntry {
  final DateTime timestamp;
  final String entityType;
  final String operation;
  final String message;

  const ForensicFailureEntry({
    required this.timestamp,
    required this.entityType,
    required this.operation,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'entityType': entityType,
      'operation': operation,
      'message': message,
    };
  }
}

class PartnerSyncBreakdown {
  final int total;
  final int notDeleted;
  final int pending;
  final int synced;
  final int conflict;

  const PartnerSyncBreakdown({
    required this.total,
    required this.notDeleted,
    required this.pending,
    required this.synced,
    required this.conflict,
  });

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'notDeleted': notDeleted,
      'pending': pending,
      'synced': synced,
      'conflict': conflict,
    };
  }
}

class ModuleAuditEntry {
  final String moduleKey;
  final String collection;
  final String syncModel;
  final PartnerSyncBreakdown local;
  final int firebaseCount;
  final int outboxCount;
  final String? lastSyncAt;
  final List<String> warnings;

  const ModuleAuditEntry({
    required this.moduleKey,
    required this.collection,
    required this.syncModel,
    required this.local,
    required this.firebaseCount,
    required this.outboxCount,
    required this.lastSyncAt,
    required this.warnings,
  });

  Map<String, dynamic> toJson() {
    return {
      'moduleKey': moduleKey,
      'collection': collection,
      'syncModel': syncModel,
      'local': local.toJson(),
      'firebaseCount': firebaseCount,
      'outboxCount': outboxCount,
      'lastSyncAt': lastSyncAt,
      'warnings': warnings,
    };
  }
}

class LastSyncAttempt {
  final DateTime timestamp;
  final bool success;
  final String entityType;
  final String operation;
  final String? errorMessage;

  const LastSyncAttempt({
    required this.timestamp,
    required this.success,
    required this.entityType,
    required this.operation,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'entityType': entityType,
      'operation': operation,
      'errorMessage': errorMessage,
    };
  }
}

class ForensicAuditSnapshot {
  final DateTime generatedAt;
  final PartnerSyncBreakdown localCustomers;
  final PartnerSyncBreakdown localDealers;
  final int firebaseCustomers;
  final int firebaseDealers;
  final int unresolvedConflicts;
  final int outboxTotal;
  final int outboxCustomers;
  final int outboxDealers;
  final int outboxPermanentFailures;
  final Map<String, String> lastSyncTimestamps;
  final List<ForensicFailureEntry> recentFailures;
  final bool customers100ExistsLocally;
  final List<ModuleAuditEntry> moduleAudits;
  final List<String> riskFlags;
  final LastSyncAttempt? lastSyncAttempt;

  const ForensicAuditSnapshot({
    required this.generatedAt,
    required this.localCustomers,
    required this.localDealers,
    required this.firebaseCustomers,
    required this.firebaseDealers,
    required this.unresolvedConflicts,
    required this.outboxTotal,
    required this.outboxCustomers,
    required this.outboxDealers,
    required this.outboxPermanentFailures,
    required this.lastSyncTimestamps,
    required this.recentFailures,
    required this.customers100ExistsLocally,
    required this.moduleAudits,
    required this.riskFlags,
    required this.lastSyncAttempt,
  });

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'local': {
        'customers': localCustomers.toJson(),
        'dealers': localDealers.toJson(),
      },
      'firebase': {'customers': firebaseCustomers, 'dealers': firebaseDealers},
      'syncState': {
        'unresolvedConflicts': unresolvedConflicts,
        'outbox': {
          'total': outboxTotal,
          'customers': outboxCustomers,
          'dealers': outboxDealers,
          'permanentFailures': outboxPermanentFailures,
        },
        'lastSyncTimestamps': lastSyncTimestamps,
        'lastSyncAttempt': lastSyncAttempt?.toJson(),
      },
      'recentFailures': recentFailures.map((e) => e.toJson()).toList(),
      'checks': {
        'customers100ExistsLocally': customers100ExistsLocally,
        'localCustomerPhysicalCount': localCustomers.total,
      },
      'moduleAudits': moduleAudits.map((e) => e.toJson()).toList(),
      'riskFlags': riskFlags,
    };
  }
}

class ForensicAuditService {
  static const int _salesPageSize = 500;
  static const int _stockLedgerPageSize = 500;
  final DatabaseService _dbService;
  final FirebaseServices _firebase;

  static const String _lastSyncPrefix = 'last_sync_';

  ForensicAuditService(this._dbService, this._firebase);

  Future<List<BaseEntity>> _fetchAllSalesBaseEntitiesPaged() async {
    final entities = <BaseEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.sales
          .where()
          .offset(offset)
          .limit(_salesPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      entities.addAll(chunk);
      if (chunk.length < _salesPageSize) {
        break;
      }
      offset += _salesPageSize;
    }
    return entities;
  }

  Future<List<BaseEntity>> _fetchAllStockLedgerBaseEntitiesPaged() async {
    final entities = <BaseEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.stockLedger
          .where()
          .offset(offset)
          .limit(_stockLedgerPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      entities.addAll(chunk);
      if (chunk.length < _stockLedgerPageSize) {
        break;
      }
      offset += _stockLedgerPageSize;
    }
    return entities;
  }

  Future<ForensicAuditSnapshot> collectSnapshot() async {
    final localCustomers = await _buildCustomersBreakdown();
    final localDealers = await _buildDealersBreakdown();
    final firebaseCustomers = await _remoteCount('customers');
    final firebaseDealers = await _remoteCount('dealers');
    final unresolvedConflicts = await _dbService.conflicts
        .filter()
        .resolvedEqualTo(false)
        .count();

    final outboxTotal = await _dbService.syncQueue.count();
    final outboxCustomers = await _countOutboxByCollection('customers');
    final outboxDealers = await _countOutboxByCollection('dealers');
    final outboxPermanentFailures = await _countPermanentOutboxFailures();
    final lastSyncTimestamps = await _readLastSyncTimestamps();
    final failures = await _readRecentFailures(limit: 25);
    final lastSyncAttempt = await _readLastSyncAttempt();
    final moduleAudits = await _collectModuleAudits(lastSyncTimestamps);
    final riskFlags = _deriveRiskFlags(moduleAudits);

    return ForensicAuditSnapshot(
      generatedAt: DateTime.now(),
      localCustomers: localCustomers,
      localDealers: localDealers,
      firebaseCustomers: firebaseCustomers,
      firebaseDealers: firebaseDealers,
      unresolvedConflicts: unresolvedConflicts,
      outboxTotal: outboxTotal,
      outboxCustomers: outboxCustomers,
      outboxDealers: outboxDealers,
      outboxPermanentFailures: outboxPermanentFailures,
      lastSyncTimestamps: lastSyncTimestamps,
      recentFailures: failures,
      customers100ExistsLocally: localCustomers.total >= 100,
      moduleAudits: moduleAudits,
      riskFlags: riskFlags,
      lastSyncAttempt: lastSyncAttempt,
    );
  }

  Future<File> exportSnapshotJson(ForensicAuditSnapshot snapshot) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final outDir = Directory(p.join(docsDir.path, 'forensic_audit'));
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filePath = p.join(outDir.path, 'forensic_sync_snapshot_$ts.json');
    final file = File(filePath);
    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(snapshot.toJson()));
    return file;
  }

  Future<PartnerSyncBreakdown> _buildCustomersBreakdown() async {
    return _buildBreakdownFromBaseEntities(() async {
      return (await _dbService.customers.where().findAll()).cast<BaseEntity>();
    });
  }

  Future<PartnerSyncBreakdown> _buildDealersBreakdown() async {
    return _buildBreakdownFromBaseEntities(() async {
      return (await _dbService.dealers.where().findAll()).cast<BaseEntity>();
    });
  }

  Future<List<ModuleAuditEntry>> _collectModuleAudits(
    Map<String, String> lastSyncTimestamps,
  ) async {
    final modules = <ModuleAuditEntry>[
      await _buildModuleAudit(
        moduleKey: 'users',
        collection: 'users',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.users.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'trips',
        collection: 'delivery_trips',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.trips.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'products',
        collection: 'products',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.products.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'sales',
        collection: 'sales',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return _fetchAllSalesBaseEntitiesPaged();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'dispatches',
        collection: 'dispatches',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.dispatches.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'returns',
        collection: 'returns',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.returns.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'customers',
        collection: 'customers',
        syncModel: 'pending_scan',
        breakdown: _buildCustomersBreakdown(),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'dealers',
        collection: 'dealers',
        syncModel: 'pending_scan',
        breakdown: _buildDealersBreakdown(),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'tanks',
        collection: 'tanks',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.tanks.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'tank_transactions',
        collection: 'tank_transactions',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.tankTransactions.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'duty_sessions',
        collection: 'duty_sessions',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.dutySessions.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'route_sessions',
        collection: 'route_sessions',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.routeSessions.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'customer_visits',
        collection: 'customer_visits',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.customerVisits.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'opening_stock',
        collection: 'opening_stock_entries',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.openingStockEntries.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'stock_ledger',
        collection: 'stock_ledger',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return _fetchAllStockLedgerBaseEntitiesPaged();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'bhatti_entries',
        collection: 'bhatti_entries',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.bhattiEntries.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'production_entries',
        collection: 'production_entries',
        syncModel: 'pending_scan',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.productionEntries.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'routes',
        collection: 'routes',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.routes.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'vehicles',
        collection: 'vehicles',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.vehicles.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'diesel_logs',
        collection: 'diesel_logs',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.dieselLogs.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'sales_targets',
        collection: 'sales_targets',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.salesTargets.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'payroll_records',
        collection: 'payroll_records',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.payrollRecords.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'attendances',
        collection: 'attendances',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.attendances.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'units',
        collection: 'units',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.units.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'product_categories',
        collection: 'product_categories',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.categories.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'product_types',
        collection: 'product_types',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.productTypes.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'employees',
        collection: 'employees',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.employees.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'leave_requests',
        collection: 'leave_requests',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.leaveRequests.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'advances',
        collection: 'advances',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.advances.where().findAll()).cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'performance_reviews',
        collection: 'performance_reviews',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.performanceReviews.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
      await _buildModuleAudit(
        moduleKey: 'employee_documents',
        collection: 'employee_documents',
        syncModel: 'queue_required',
        breakdown: _buildBreakdownFromBaseEntities(() async {
          return (await _dbService.employeeDocuments.where().findAll())
              .cast<BaseEntity>();
        }),
        lastSyncTimestamps: lastSyncTimestamps,
      ),
    ];

    modules.sort((a, b) {
      final pendingCmp = b.local.pending.compareTo(a.local.pending);
      if (pendingCmp != 0) return pendingCmp;
      return a.moduleKey.compareTo(b.moduleKey);
    });
    return modules;
  }

  Future<ModuleAuditEntry> _buildModuleAudit({
    required String moduleKey,
    required String collection,
    required String syncModel,
    required Future<PartnerSyncBreakdown> breakdown,
    required Map<String, String> lastSyncTimestamps,
  }) async {
    final local = await breakdown;
    final firebaseCount = await _remoteCount(collection);
    final outboxCount = await _countOutboxByCollection(collection);
    final lastSyncAt = lastSyncTimestamps[collection];
    final warnings = <String>[];

    if (local.pending > 0 && lastSyncAt == null) {
      warnings.add('Pending records exist but no last sync timestamp found');
    }
    if (local.conflict > 0) {
      warnings.add('${local.conflict} conflict record(s) unresolved');
    }
    if (firebaseCount >= 0 &&
        local.notDeleted > firebaseCount &&
        local.pending == 0 &&
        outboxCount == 0) {
      warnings.add('Local active count is greater than Firebase without queue');
    }

    return ModuleAuditEntry(
      moduleKey: moduleKey,
      collection: collection,
      syncModel: syncModel,
      local: local,
      firebaseCount: firebaseCount,
      outboxCount: outboxCount,
      lastSyncAt: lastSyncAt,
      warnings: warnings,
    );
  }

  List<String> _deriveRiskFlags(List<ModuleAuditEntry> modules) {
    final flags = <String>[];

    for (final module in modules) {
      if (module.syncModel == 'missing_outbox' &&
          module.local.pending > 0 &&
          module.outboxCount == 0) {
        flags.add(
          '[CRITICAL] ${module.moduleKey}: pending=${module.local.pending}, '
          'outbox=0, syncModel=${module.syncModel}',
        );
      }

      if (module.syncModel == 'local_retry_only' && module.local.pending > 0) {
        flags.add(
          '[HIGH] ${module.moduleKey}: pending=${module.local.pending}, '
          'no guaranteed background retry path',
        );
      }

      if (module.syncModel == 'queue_required' &&
          module.local.pending > 0 &&
          module.outboxCount == 0) {
        flags.add(
          '[HIGH] ${module.moduleKey}: pending=${module.local.pending}, '
          'queue required but outbox empty',
        );
      }

      if (module.syncModel == 'pending_scan' &&
          module.local.pending > 0 &&
          module.outboxCount == 0) {
        flags.add(
          '[MEDIUM] ${module.moduleKey}: pending=${module.local.pending}, '
          'still on pending-scan model without durable outbox',
        );
      }
    }

    return flags;
  }

  Future<PartnerSyncBreakdown> _buildBreakdownFromBaseEntities(
    Future<List<BaseEntity>> Function() loadEntities,
  ) async {
    final entities = await loadEntities();
    int notDeleted = 0;
    int pending = 0;
    int synced = 0;
    int conflict = 0;

    for (final entity in entities) {
      if (!entity.isDeleted) {
        notDeleted++;
      }
      switch (entity.syncStatus) {
        case SyncStatus.pending:
          pending++;
          break;
        case SyncStatus.synced:
          synced++;
          break;
        case SyncStatus.conflict:
          conflict++;
          break;
      }
    }

    return PartnerSyncBreakdown(
      total: entities.length,
      notDeleted: notDeleted,
      pending: pending,
      synced: synced,
      conflict: conflict,
    );
  }

  Future<int> _remoteCount(String collection) async {
    final db = _firebase.db;
    if (db == null) return -1;
    try {
      final snapshot = await db.collection(collection).count().get();
      return snapshot.count ?? -1;
    } catch (_) {
      return -1;
    }
  }

  Future<int> _countOutboxByCollection(String collection) async {
    return _dbService.syncQueue.filter().collectionEqualTo(collection).count();
  }

  Future<Map<String, String>> _readLastSyncTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final out = <String, String>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_lastSyncPrefix)) continue;
      final value = prefs.getString(key);
      if (value == null || value.trim().isEmpty) continue;
      out[key.replaceFirst(_lastSyncPrefix, '')] = value;
    }
    return out;
  }

  Future<int> _countPermanentOutboxFailures() async {
    final queueItems = await _dbService.syncQueue.where().findAll();
    var permanent = 0;
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

  Future<LastSyncAttempt?> _readLastSyncAttempt() async {
    final metrics = await _loadSyncMetricsForCurrentUser();
    if (metrics.isEmpty) return null;
    final latest = metrics.first;
    return LastSyncAttempt(
      timestamp: latest.timestamp,
      success: latest.success,
      entityType: latest.entityType,
      operation: latest.operation.name,
      errorMessage: latest.errorMessage,
    );
  }

  Future<List<ForensicFailureEntry>> _readRecentFailures({int limit = 25}) async {
    final metrics = await _loadSyncMetricsForCurrentUser();
    final latestByScope = <String, SyncMetricEntity>{};
    for (final metric in metrics) {
      final scope = _metricScopeKey(metric);
      if (!latestByScope.containsKey(scope)) {
        latestByScope[scope] = metric;
      }
    }

    return latestByScope.values
        .where((metric) => !metric.success)
        .take(limit)
        .map(
          (metric) => ForensicFailureEntry(
            timestamp: metric.timestamp,
            entityType: metric.entityType,
            operation: metric.operation.name,
            message: (metric.errorMessage ?? 'Unknown failure').trim(),
          ),
        )
        .toList();
  }

  Future<List<SyncMetricEntity>> _loadSyncMetricsForCurrentUser() async {
    final metrics = await _dbService.syncMetrics
        .where()
        .sortByTimestampDesc()
        .findAll();
    final currentMetricUserId = await _resolveCurrentMetricUserId();
    if (currentMetricUserId == null) {
      return metrics;
    }

    return metrics
        .where(
          (metric) => metric.userId.trim().toLowerCase() == currentMetricUserId,
        )
        .toList(growable: false);
  }

  Future<String?> _resolveCurrentMetricUserId() async {
    final email = _firebase.auth?.currentUser?.email?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return null;
  }

  String _metricScopeKey(SyncMetricEntity metric) {
    return '${metric.entityType}/${metric.operation.name}';
  }
}
