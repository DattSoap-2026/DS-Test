import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/repositories/bhatti_repository.dart';
import 'package:flutter_app/data/repositories/production_repository.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/modules/hr/services/advance_service.dart';
import 'package:flutter_app/modules/hr/services/attendance_service.dart';
import 'package:flutter_app/modules/hr/services/hr_service.dart';
import 'package:flutter_app/modules/hr/services/payroll_service.dart';
import 'package:flutter_app/services/alert_service.dart';
import 'package:flutter_app/services/bhatti_service.dart';
import 'package:flutter_app/services/cutting_batch_service.dart';
import 'package:flutter_app/services/customers_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/dispatch_service.dart';
import 'package:flutter_app/services/route_order_service.dart';
import 'package:flutter_app/services/duty_service.dart';
import 'package:flutter_app/services/field_encryption_service.dart';
import 'package:flutter_app/services/gps_service.dart';
import 'package:flutter_app/services/inventory_movement_engine.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/master_data_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/products_service.dart';
import 'package:flutter_app/services/production_service.dart';
import 'package:flutter_app/services/returns_service.dart';
import 'package:flutter_app/services/sales_service.dart';
import 'package:flutter_app/services/suppliers_service.dart';
import 'package:flutter_app/services/sync_analytics_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/services/sync_manager.dart';
import 'package:flutter_app/services/tank_service.dart';
import 'package:flutter_app/services/users_service.dart';
import 'package:flutter_app/services/vehicles_service.dart';

class _LiveScenarioRunner {
  _LiveScenarioRunner();

  final FirebaseServices _firebase = firebaseServices;
  final DatabaseService _dbService = DatabaseService.instance;
  final List<String> _createdIds = <String>[];
  final List<Map<String, dynamic>> _tests = <Map<String, dynamic>>[];
  final Map<String, dynamic> _meta = <String, dynamic>{};
  bool _createdEphemeralAuthUser = false;
  String? _ephemeralUserEmail;

  late ProductsService _productsService;
  late SyncManager _syncManager;
  late AppUser _appUser;

  Future<int> run() async {
    final startedAt = DateTime.now().toIso8601String();
    _emit('meta', 'start', <String, dynamic>{'startedAt': startedAt});

    try {
      await _bootstrap();
      await _runAllTests();
    } catch (e, st) {
      _emit('meta', 'fatal', <String, dynamic>{
        'error': e.toString(),
        'stackTop': _stackHead(st),
      });
      _meta['fatalError'] = e.toString();
    } finally {
      await _cleanupBestEffort();
      final endedAt = DateTime.now().toIso8601String();
      final passed = _tests.where((t) => t['passed'] == true).length;
      final failed = _tests.length - passed;
      final report = <String, dynamic>{
        'startedAt': startedAt,
        'endedAt': endedAt,
        'meta': _meta,
        'summary': <String, dynamic>{
          'total': _tests.length,
          'passed': passed,
          'failed': failed,
        },
        'tests': _tests,
      };
      final pretty = const JsonEncoder.withIndent('  ').convert(report);
      final outputFile = File('run_live_soft_delete_report.json');
      await outputFile.writeAsString(pretty);
      _emit('meta', 'report_written', <String, dynamic>{
        'path': outputFile.path,
      });
      stdout.writeln('=== LIVE_SCENARIO_REPORT_BEGIN ===');
      stdout.writeln(pretty);
      stdout.writeln('=== LIVE_SCENARIO_REPORT_END ===');
    }

    final hasFatal = _meta.containsKey('fatalError');
    final hasFailures = _tests.any((test) => test['passed'] != true);
    return hasFatal || hasFailures ? 1 : 0;
  }

  Future<void> _bootstrap() async {
    _emit('bootstrap', 'firebase_init_start', const <String, dynamic>{});
    await _firebase.initialize();

    await _dbService.init();
    await FieldEncryptionService.instance.initialize();

    var firebaseUser = await _waitForFirebaseUser();
    var authMode = 'existing_session';
    if (firebaseUser == null) {
      final envEmail = Platform.environment['DATT_TEST_EMAIL']?.trim();
      final envPassword = Platform.environment['DATT_TEST_PASSWORD']?.trim();
      if (envEmail != null &&
          envEmail.isNotEmpty &&
          envPassword != null &&
          envPassword.isNotEmpty) {
        _emit('bootstrap', 'auth_fallback_attempt', <String, dynamic>{
          'mode': 'env_email_password',
          'email': envEmail,
        });
        try {
          final credential = await _firebase.auth?.signInWithEmailAndPassword(
            email: envEmail,
            password: envPassword,
          );
          firebaseUser = credential?.user;
          if (firebaseUser != null) {
            authMode = 'env_email_password';
          }
        } catch (e) {
          _emit('bootstrap', 'auth_fallback_failed', <String, dynamic>{
            'mode': 'env_email_password',
            'error': e.toString(),
          });
        }
      }
    }

    final allowCliGoogleFallback =
        Platform.environment['DATT_ENABLE_CLI_GOOGLE_FALLBACK'] == 'true';

    if (firebaseUser == null && allowCliGoogleFallback) {
      final cliAccessToken = _readFirebaseCliAccessToken();
      if (cliAccessToken != null) {
        _emit('bootstrap', 'auth_fallback_attempt', <String, dynamic>{
          'mode': 'firebase_cli_google_token',
        });
        try {
          final credential = auth.GoogleAuthProvider.credential(
            accessToken: cliAccessToken,
          );
          final signed = await _firebase.auth?.signInWithCredential(credential);
          firebaseUser = signed?.user;
          if (firebaseUser != null) {
            authMode = 'firebase_cli_google_token';
          }
        } catch (e) {
          _emit('bootstrap', 'auth_fallback_failed', <String, dynamic>{
            'mode': 'firebase_cli_google_token',
            'error': e.toString(),
          });
        }
      }
    }

    if (firebaseUser == null) {
      _emit('bootstrap', 'auth_fallback_attempt', <String, dynamic>{
        'mode': 'anonymous_sign_in',
      });
      try {
        final credential = await _firebase.auth?.signInAnonymously();
        firebaseUser = credential?.user;
        if (firebaseUser != null) {
          authMode = 'anonymous_sign_in';
        }
      } catch (e) {
        _emit('bootstrap', 'auth_fallback_failed', <String, dynamic>{
          'error': e.toString(),
        });
      }
    }

    if (firebaseUser == null) {
      _emit('bootstrap', 'auth_fallback_attempt', <String, dynamic>{
        'mode': 'auto_bootstrap_test_user',
      });
      final bootstrappedUser = await _bootstrapTestAuthUser();
      if (bootstrappedUser != null) {
        firebaseUser = bootstrappedUser;
        authMode = 'auto_bootstrap_test_user';
      }
    }

    if (firebaseUser == null) {
      throw StateError(
        'No authenticated Firebase user available. '
        'Please login in app once, then re-run this scenario.',
      );
    }

    await _ensureCurrentUserProfile(firebaseUser);

    _appUser = await _resolveAppUser(firebaseUser);
    _meta['firebaseUser'] = <String, dynamic>{
      'uid': firebaseUser.uid,
      'email': firebaseUser.email,
      'appRole': _appUser.role.value,
      'appUserId': _appUser.id,
      'authMode': authMode,
    };
    if (_createdEphemeralAuthUser) {
      _meta['ephemeralAuthUser'] = <String, dynamic>{
        'email': _ephemeralUserEmail,
      };
    }

    _emit('bootstrap', 'auth_context', <String, dynamic>{
      'uid': firebaseUser.uid,
      'email': firebaseUser.email,
      'role': _appUser.role.value,
    });

    final inventoryService = InventoryService(_firebase, _dbService);
    final customersService = CustomersService(_firebase, _dbService);
    final salesService = SalesService(_firebase, _dbService, inventoryService);
    final returnsService = ReturnsService(
      _firebase,
      _dbService,
      inventoryService,
      customersService,
      salesService,
    );
    final dispatchService = DispatchService(_firebase, _dbService);
    final gpsService = GpsService(_firebase);
    final dutyService = DutyService(_firebase, gpsService, _dbService);
    final hrService = HrService(_firebase, _dbService);
    final advanceService = AdvanceService(_dbService, hrService);
    final payrollService = PayrollService(
      _firebase,
      dutyService,
      hrService,
      _dbService,
      advanceService,
    );
    final attendanceService = AttendanceService(_firebase, _dbService);
    final masterDataService = MasterDataService(_firebase, _dbService);

    final suppliersService = SuppliersService(_firebase);
    final alertService = AlertService(_dbService);
    final vehiclesService = VehiclesService(_firebase);
    final syncAnalyticsService = SyncAnalyticsService(_dbService);
    final productionService = ProductionService(
      _firebase,
      inventoryService,
      _dbService,
    );
    final tankService = TankService(_firebase, _dbService);
    final inventoryProjectionService = InventoryProjectionService(_dbService);
    final inventoryMovementEngine = InventoryMovementEngine(
      _dbService,
      inventoryProjectionService,
    );
    final bhattiService = BhattiService(
      _firebase,
      _dbService,
      tankService,
      inventoryService,
      inventoryMovementEngine,
    );
    final cuttingBatchService = CuttingBatchService(
      _firebase,
      _dbService,
      inventoryMovementEngine,
    );
    final bhattiRepo = BhattiRepository(
      _dbService,
      firebaseServices: _firebase,
    );
    final productionRepo = ProductionRepository(
      _dbService,
      firebaseServices: _firebase,
      inventoryService: inventoryService,
    );
    final usersService = UsersService(_firebase, _dbService);
    final productsService = ProductsService(_firebase, _dbService);
    final routeOrderService = RouteOrderService(
      _firebase,
      inventoryService,
      usersService,
      productsService,
      alertService,
    );

    final syncUtils = SyncCommonUtils(
      dbService: _dbService,
      analyticsService: syncAnalyticsService,
    );

    _syncManager = SyncManager(
      _dbService,
      _firebase,
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
    _syncManager.setCurrentUser(_appUser, triggerBootstrap: false);
    _productsService = ProductsService(_firebase, _dbService);

    final queueState = await _queueSummary();
    _meta['initialQueueState'] = queueState;
    _emit('bootstrap', 'initial_queue_state', queueState);
  }

  Future<void> _runAllTests() async {
    await _runTest('TEST 1 - Soft Delete Flow', _test1SoftDeleteFlow);
    await _runTest('TEST 2 - Offline Delete', _test2OfflineDelete);
    await _runTest(
      'TEST 3 - Hard Delete + Tombstone',
      _test3HardDeleteWithTombstone,
    );
    await _runTest('TEST 4 - Multi-Device Scenario', _test4MultiDeviceScenario);
    await _runTest(
      'TEST 5 - Critical Collection Reconcile',
      _test5CriticalReconcile,
    );
  }

  Future<void> _runTest(
    String name,
    Future<Map<String, dynamic>> Function() body,
  ) async {
    final started = DateTime.now();
    _emit(name, 'start', <String, dynamic>{'at': started.toIso8601String()});
    try {
      final payload = await body();
      final assertions =
          (payload['assertions'] as Map<String, dynamic>? ??
          const <String, dynamic>{});
      final passed =
          assertions.isNotEmpty && assertions.values.every((v) => v == true);
      _tests.add(<String, dynamic>{
        'name': name,
        'startedAt': started.toIso8601String(),
        'endedAt': DateTime.now().toIso8601String(),
        'passed': passed,
        ...payload,
      });
      _emit(name, 'end', <String, dynamic>{
        'passed': passed,
        'assertions': assertions,
      });
    } catch (e, st) {
      _tests.add(<String, dynamic>{
        'name': name,
        'startedAt': started.toIso8601String(),
        'endedAt': DateTime.now().toIso8601String(),
        'passed': false,
        'error': e.toString(),
        'stackTop': _stackHead(st),
      });
      _emit(name, 'error', <String, dynamic>{
        'error': e.toString(),
        'stackTop': _stackHead(st),
      });
    }
  }

  Future<Map<String, dynamic>> _test1SoftDeleteFlow() async {
    final id = await _createAndSyncProduct(testTag: 't1');

    final serverBeforeDelete = await _serverProductState(id);
    final localBeforeDelete = await _localProductState(id);
    _emit('TEST 1 - Soft Delete Flow', 'before_delete_state', <String, dynamic>{
      'id': id,
      'server': serverBeforeDelete,
      'local': localBeforeDelete,
    });

    await _productsService.deleteProduct(
      id,
      userId: _appUser.id,
      userName: _appUser.name,
    );

    final localAfterDelete = await _localProductState(id);
    final queueAfterDelete = await _queueEntriesForId(id);

    await _syncManager.processSyncQueue();
    final localAfterSync = await _localProductState(id);
    final serverAfterSync = await _serverProductState(id);

    final beforeUpdatedAt = _parseDate(serverBeforeDelete['updatedAt']);
    final afterUpdatedAt = _parseDate(serverAfterSync['updatedAt']);

    final assertions = <String, bool>{
      'server_isDeleted_true': serverAfterSync['isDeleted'] == true,
      'server_deletedAt_set': serverAfterSync['deletedAt'] != null,
      'server_updatedAt_changed':
          beforeUpdatedAt != null &&
          afterUpdatedAt != null &&
          afterUpdatedAt.isAfter(beforeUpdatedAt),
      'local_hidden_after_sync': localAfterSync['visibleInActiveList'] == false,
      'no_ghost_record': localAfterSync['visibleInActiveList'] == false,
      'delete_event_was_queued': queueAfterDelete.any(
        (e) => e['action'] == 'delete',
      ),
    };

    return <String, dynamic>{
      'recordId': id,
      'before': <String, dynamic>{
        'server': serverBeforeDelete,
        'local': localBeforeDelete,
      },
      'after': <String, dynamic>{
        'localAfterDelete': localAfterDelete,
        'localAfterSync': localAfterSync,
        'serverAfterSync': serverAfterSync,
      },
      'syncTimestamps': <String, dynamic>{
        'queueProcessAt': DateTime.now().toIso8601String(),
      },
      'queueAfterDelete': queueAfterDelete,
      'assertions': assertions,
      'conflicts': <String, dynamic>{'detected': false},
    };
  }

  Future<Map<String, dynamic>> _test2OfflineDelete() async {
    final id = await _createAndSyncProduct(testTag: 't2');

    final beforeOffline = await _stateSnapshot(id);

    await _firebase.db!.disableNetwork();
    _emit('TEST 2 - Offline Delete', 'network_disabled', <String, dynamic>{
      'at': DateTime.now().toIso8601String(),
    });

    await _productsService.deleteProduct(
      id,
      userId: _appUser.id,
      userName: _appUser.name,
    );

    final localAfterOfflineDelete = await _localProductState(id);
    final queueAfterOfflineDelete = await _queueEntriesForId(id);
    final serverWhileOffline = await _serverProductState(id);

    await _firebase.db!.enableNetwork();
    await Future<void>.delayed(const Duration(seconds: 2));
    _emit('TEST 2 - Offline Delete', 'network_enabled', <String, dynamic>{
      'at': DateTime.now().toIso8601String(),
    });

    await _syncManager.processSyncQueue();
    final serverAfterReconnect = await _serverProductState(id);
    final localAfterReconnect = await _localProductState(id);

    final syncResult = await _syncManager.syncAll(
      _appUser,
      forceRefresh: false,
    );
    final postRefreshLocal = await _localProductState(id);

    final assertions = <String, bool>{
      'record_marked_deleted_locally':
          localAfterOfflineDelete['isDeleted'] == true,
      'sync_event_queued': queueAfterOfflineDelete.any(
        (e) => e['action'] == 'delete',
      ),
      'server_soft_deleted_after_reconnect':
          serverAfterReconnect['isDeleted'] == true,
      'record_hidden_after_refresh':
          postRefreshLocal['visibleInActiveList'] == false,
    };

    final hasConflict =
        syncResult.unresolvedConflictCount > 0 ||
        syncResult.criticalErrors.any(
          (e) => e.toLowerCase().contains('conflict'),
        );

    return <String, dynamic>{
      'recordId': id,
      'before': beforeOffline,
      'after': <String, dynamic>{
        'localAfterOfflineDelete': localAfterOfflineDelete,
        'serverWhileOffline': serverWhileOffline,
        'serverAfterReconnect': serverAfterReconnect,
        'localAfterReconnect': localAfterReconnect,
        'localAfterRefresh': postRefreshLocal,
      },
      'syncTimestamps': <String, dynamic>{
        'syncAllCompletedAt': syncResult.completedAt.toIso8601String(),
        'lastSyncAllTime': _syncManager.lastSyncAllTime?.toIso8601String(),
      },
      'queueAfterOfflineDelete': queueAfterOfflineDelete,
      'syncResult': _syncResultMap(syncResult),
      'assertions': assertions,
      'conflicts': <String, dynamic>{
        'detected': hasConflict,
        'unresolvedConflictCount': syncResult.unresolvedConflictCount,
      },
    };
  }

  Future<Map<String, dynamic>> _test3HardDeleteWithTombstone() async {
    final id = await _createAndSyncProduct(testTag: 't3');
    final beforeHardDelete = await _stateSnapshot(id);

    await _firebase.db!.collection('products').doc(id).delete();
    final hardDeleteAt = DateTime.now();

    final tombstoneId =
        'manual_tombstone_${id}_${hardDeleteAt.millisecondsSinceEpoch}';
    await _firebase.db!
        .collection('deleted_records')
        .doc(tombstoneId)
        .set(<String, dynamic>{
          'entityType': 'products',
          'docId': id,
          'deletedAt': hardDeleteAt.toIso8601String(),
          'createdAt': hardDeleteAt.toIso8601String(),
        });

    final localBeforeRefresh = await _localProductState(id);
    final syncResult = await _syncManager.syncAll(
      _appUser,
      forceRefresh: false,
    );
    final localAfterRefresh = await _localProductState(id);
    final serverAfterRefresh = await _serverProductState(id);
    final tombstoneProcessing = await _processedTombstonesState(tombstoneId);

    final assertions = <String, bool>{
      'tombstone_pulled': tombstoneProcessing['containsTombstone'] == true,
      'local_record_pruned': localAfterRefresh['isDeleted'] == true,
      'no_ghost_data': localAfterRefresh['visibleInActiveList'] == false,
      'server_doc_absent': serverAfterRefresh['exists'] == false,
    };

    final hasConflict =
        syncResult.unresolvedConflictCount > 0 ||
        syncResult.criticalErrors.any(
          (e) => e.toLowerCase().contains('conflict'),
        );

    return <String, dynamic>{
      'recordId': id,
      'tombstoneId': tombstoneId,
      'before': beforeHardDelete,
      'after': <String, dynamic>{
        'localBeforeRefresh': localBeforeRefresh,
        'localAfterRefresh': localAfterRefresh,
        'serverAfterRefresh': serverAfterRefresh,
        'tombstoneProcessing': tombstoneProcessing,
      },
      'syncTimestamps': <String, dynamic>{
        'hardDeleteAt': hardDeleteAt.toIso8601String(),
        'syncAllCompletedAt': syncResult.completedAt.toIso8601String(),
      },
      'syncResult': _syncResultMap(syncResult),
      'assertions': assertions,
      'conflicts': <String, dynamic>{
        'detected': hasConflict,
        'unresolvedConflictCount': syncResult.unresolvedConflictCount,
      },
    };
  }

  Future<Map<String, dynamic>> _test4MultiDeviceScenario() async {
    final id = await _createAndSyncProduct(testTag: 't4');
    final deviceBBeforeDelete = await _localProductState(id);

    final softDeleteAt = DateTime.now();
    await _firebase.db!.collection('products').doc(id).set(<String, dynamic>{
      'isDeleted': true,
      'deletedAt': softDeleteAt.toIso8601String(),
      'updatedAt': softDeleteAt.toIso8601String(),
    }, firestore.SetOptions(merge: true));

    final syncResult = await _syncManager.syncAll(
      _appUser,
      forceRefresh: false,
    );
    final deviceBAfterRefresh = await _localProductState(id);
    final serverAfterDelete = await _serverProductState(id);

    final hasConflict =
        syncResult.unresolvedConflictCount > 0 ||
        syncResult.criticalErrors.any(
          (e) => e.toLowerCase().contains('conflict'),
        );

    final assertions = <String, bool>{
      'record_disappears_on_device_b':
          deviceBAfterRefresh['visibleInActiveList'] == false,
      'server_marked_deleted': serverAfterDelete['isDeleted'] == true,
      'no_conflict_errors': !hasConflict,
    };

    return <String, dynamic>{
      'recordId': id,
      'before': <String, dynamic>{'deviceB': deviceBBeforeDelete},
      'after': <String, dynamic>{
        'deviceB': deviceBAfterRefresh,
        'server': serverAfterDelete,
      },
      'syncTimestamps': <String, dynamic>{
        'deviceADeleteAt': softDeleteAt.toIso8601String(),
        'deviceBRefreshAt': syncResult.completedAt.toIso8601String(),
      },
      'syncResult': _syncResultMap(syncResult),
      'assertions': assertions,
      'conflicts': <String, dynamic>{
        'detected': hasConflict,
        'unresolvedConflictCount': syncResult.unresolvedConflictCount,
      },
    };
  }

  Future<Map<String, dynamic>> _test5CriticalReconcile() async {
    final id = await _createAndSyncProduct(testTag: 't5');
    final beforeHardDelete = await _stateSnapshot(id);

    await _firebase.db!.collection('products').doc(id).delete();
    final serverDeletedAt = DateTime.now();

    final localBeforeReconcile = await _localProductState(id);
    final syncResult = await _syncManager.syncAll(_appUser, forceRefresh: true);
    final localAfterReconcile = await _localProductState(id);
    final serverAfterReconcile = await _serverProductState(id);

    final hasConflict =
        syncResult.unresolvedConflictCount > 0 ||
        syncResult.criticalErrors.any(
          (e) => e.toLowerCase().contains('conflict'),
        );

    final assertions = <String, bool>{
      'local_orphan_pruned': localAfterReconcile['isDeleted'] == true,
      'local_hidden_after_reconcile':
          localAfterReconcile['visibleInActiveList'] == false,
      'server_doc_absent': serverAfterReconcile['exists'] == false,
    };

    return <String, dynamic>{
      'recordId': id,
      'before': beforeHardDelete,
      'after': <String, dynamic>{
        'localBeforeReconcile': localBeforeReconcile,
        'localAfterReconcile': localAfterReconcile,
        'serverAfterReconcile': serverAfterReconcile,
      },
      'syncTimestamps': <String, dynamic>{
        'serverHardDeleteAt': serverDeletedAt.toIso8601String(),
        'forceRefreshCompletedAt': syncResult.completedAt.toIso8601String(),
      },
      'syncResult': _syncResultMap(syncResult),
      'assertions': assertions,
      'conflicts': <String, dynamic>{
        'detected': hasConflict,
        'unresolvedConflictCount': syncResult.unresolvedConflictCount,
      },
    };
  }

  Future<String> _createAndSyncProduct({required String testTag}) async {
    final seed = DateTime.now().microsecondsSinceEpoch;
    final sku = 'LVS_${testTag.toUpperCase()}_$seed';
    final name = 'LIVE_${testTag}_$seed';

    final product = await _productsService.createProduct(
      name: name,
      sku: sku,
      itemType: 'finished_good',
      type: 'finished',
      category: 'live-test',
      stock: 5,
      baseUnit: 'Pcs',
      conversionFactor: 1,
      price: 10,
      status: 'active',
      unitWeightGrams: 100,
      userId: _appUser.id,
      userName: _appUser.name,
    );

    _createdIds.add(product.id);

    await _syncManager.processSyncQueue();

    final server = await _serverProductState(product.id);
    if (server['exists'] != true) {
      throw StateError('Product ${product.id} did not sync to server.');
    }

    return product.id;
  }

  Future<Map<String, dynamic>> _stateSnapshot(String id) async {
    return <String, dynamic>{
      'local': await _localProductState(id),
      'server': await _serverProductState(id),
      'queue': await _queueEntriesForId(id),
    };
  }

  Future<Map<String, dynamic>> _localProductState(String id) async {
    final entity = await _dbService.products.getById(id);
    final visible = (await _productsService.getProducts()).any(
      (p) => p.id == id,
    );

    return <String, dynamic>{
      'exists': entity != null,
      'isDeleted': entity?.isDeleted,
      'deletedAt': entity?.deletedAt?.toIso8601String(),
      'updatedAt': entity?.updatedAt.toIso8601String(),
      'syncStatus': entity?.syncStatus.name,
      'visibleInActiveList': visible,
    };
  }

  Future<Map<String, dynamic>> _serverProductState(String id) async {
    final snap = await _firebase.db!.collection('products').doc(id).get();
    if (!snap.exists) {
      return <String, dynamic>{
        'exists': false,
        'isDeleted': null,
        'deletedAt': null,
        'updatedAt': null,
      };
    }

    final data = snap.data() ?? <String, dynamic>{};
    return <String, dynamic>{
      'exists': true,
      'isDeleted': data['isDeleted'] == true,
      'deletedAt': _dateToIso(data['deletedAt']),
      'updatedAt': _dateToIso(data['updatedAt']),
    };
  }

  Future<List<Map<String, dynamic>>> _queueEntriesForId(String id) async {
    final all = await _dbService.syncQueue.where().sortByTimestamp().findAll();
    final rows = <Map<String, dynamic>>[];
    for (final item in all) {
      final decoded = OutboxCodec.decode(
        item.dataJson,
        fallbackQueuedAt: item.createdAt,
      );
      if (decoded.payload['id']?.toString() != id) continue;
      rows.add(<String, dynamic>{
        'queueId': item.id,
        'collection': item.collection,
        'action': item.action,
        'syncStatus': item.syncStatus.name,
        'attemptCount': decoded.meta['attemptCount'],
        'nextRetryAt': decoded.meta['nextRetryAt'],
      });
    }
    return rows;
  }

  Future<Map<String, dynamic>> _queueSummary() async {
    final all = await _dbService.syncQueue.where().sortByTimestamp().findAll();
    return <String, dynamic>{
      'count': all.length,
      'sample': all
          .take(10)
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'collection': item.collection,
              'action': item.action,
              'status': item.syncStatus.name,
            },
          )
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _processedTombstonesState(
    String tombstoneId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = prefs.getStringList('processed_tombstones') ?? <String>[];
    return <String, dynamic>{
      'processedCount': rows.length,
      'containsTombstone': rows.contains(tombstoneId),
    };
  }

  Future<void> _cleanupBestEffort() async {
    for (final id in _createdIds) {
      try {
        final server = await _serverProductState(id);
        if (server['exists'] == true && server['isDeleted'] != true) {
          final now = DateTime.now().toIso8601String();
          await _firebase.db!.collection('products').doc(id).set(
            <String, dynamic>{
              'isDeleted': true,
              'deletedAt': now,
              'updatedAt': now,
            },
            firestore.SetOptions(merge: true),
          );
        }
      } catch (_) {}

      try {
        await _dbService.db.writeTxn(() async {
          final local = await _dbService.products.getById(id);
          if (local == null) return;
          local
            ..isDeleted = true
            ..deletedAt = DateTime.now()
            ..updatedAt = DateTime.now()
            ..syncStatus = SyncStatus.synced;
          await _dbService.products.put(local);
        });
      } catch (_) {}
    }

    if (_createdEphemeralAuthUser) {
      try {
        final uid = _firebase.auth?.currentUser?.uid;
        if (uid != null && uid.isNotEmpty) {
          await _firebase.db!.collection('users').doc(uid).delete();
        }
      } catch (_) {}

      try {
        final user = _firebase.auth?.currentUser;
        if (user != null) {
          await user.delete();
        }
      } catch (_) {}

      try {
        await _firebase.auth?.signOut();
      } catch (_) {}
    }
  }

  String? _readFirebaseCliAccessToken() {
    try {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null || userProfile.trim().isEmpty) return null;
      final file = File(
        '$userProfile\\.config\\configstore\\firebase-tools.json',
      );
      if (!file.existsSync()) return null;
      final raw = file.readAsStringSync();
      final match = RegExp(r'"access_token"\s*:\s*"([^"]+)"').firstMatch(raw);
      if (match == null) return null;
      final token = match.group(1)?.trim();
      if (token == null || token.isEmpty) return null;
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<auth.User?> _bootstrapTestAuthUser() async {
    try {
      final authClient = _firebase.auth;
      if (authClient == null) return null;

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'live.scenario.$stamp@erp.local';
      const password = 'LiveScenario#123';

      final credential = await authClient.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;

      final now = DateTime.now().toIso8601String();
      await _firebase.db!.collection('users').doc(user.uid).set(
        <String, dynamic>{
          'id': user.uid,
          'uid': user.uid,
          'name': 'Live Scenario Bot',
          'email': email.toLowerCase(),
          'role': 'Admin',
          'department': 'admin',
          'departments': <Map<String, dynamic>>[
            <String, dynamic>{'main': 'admin'},
          ],
          'status': 'active',
          'isActive': true,
          'createdAt': now,
          'updatedAt': now,
        },
      );

      _createdEphemeralAuthUser = true;
      _ephemeralUserEmail = email;
      return user;
    } catch (e) {
      _emit('bootstrap', 'auth_fallback_failed', <String, dynamic>{
        'mode': 'auto_bootstrap_test_user',
        'error': e.toString(),
      });
      return null;
    }
  }

  Future<void> _ensureCurrentUserProfile(auth.User firebaseUser) async {
    final usersRef = _firebase.db!.collection('users').doc(firebaseUser.uid);
    final existing = await usersRef.get();
    final now = DateTime.now().toIso8601String();

    if (existing.exists) {
      final data = existing.data() ?? <String, dynamic>{};
      final patch = <String, dynamic>{
        'id': firebaseUser.uid,
        'uid': firebaseUser.uid,
        'email': (data['email']?.toString() ?? firebaseUser.email ?? '')
            .toLowerCase(),
        'name':
            data['name']?.toString() ??
            firebaseUser.displayName ??
            'Live Test User',
        'status': data['status']?.toString() ?? 'active',
        'isActive': data['isActive'] == false ? false : true,
        'updatedAt': now,
      };
      if (data['role'] == null || data['role'].toString().trim().isEmpty) {
        patch['role'] = 'Admin';
      }
      await usersRef.set(patch, firestore.SetOptions(merge: true));
      _emit('bootstrap', 'user_profile_verified', <String, dynamic>{
        'uid': firebaseUser.uid,
        'created': false,
      });
      return;
    }

    await usersRef.set(<String, dynamic>{
      'id': firebaseUser.uid,
      'uid': firebaseUser.uid,
      'name': firebaseUser.displayName ?? 'Live Test User',
      'email': (firebaseUser.email ?? '').toLowerCase(),
      'role': 'Admin',
      'department': 'admin',
      'departments': <Map<String, dynamic>>[
        <String, dynamic>{'main': 'admin'},
      ],
      'status': 'active',
      'isActive': true,
      'createdAt': now,
      'updatedAt': now,
    }, firestore.SetOptions(merge: true));
    _emit('bootstrap', 'user_profile_verified', <String, dynamic>{
      'uid': firebaseUser.uid,
      'created': true,
    });
  }

  Future<AppUser> _resolveAppUser(auth.User firebaseUser) async {
    try {
      final users = _firebase.db!.collection('users');
      firestore.DocumentSnapshot<Map<String, dynamic>>? profile;

      profile = await users.doc(firebaseUser.uid).get();

      if (!profile.exists && firebaseUser.email != null) {
        final lowerEmail = firebaseUser.email!.toLowerCase();
        final byDocId = await users.doc(lowerEmail).get();
        if (byDocId.exists) {
          profile = byDocId;
        }
      }

      if (!profile.exists && firebaseUser.email != null) {
        final q = await users
            .where('email', isEqualTo: firebaseUser.email!.toLowerCase())
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          profile = q.docs.first;
        }
      }

      if (profile.exists) {
        final data = Map<String, dynamic>.from(
          profile.data() ?? <String, dynamic>{},
        );
        data['id'] = profile.id;
        if (data['createdAt'] == null) {
          data['createdAt'] = DateTime.now().toIso8601String();
        }
        if (data['departments'] == null) {
          data['departments'] = <Map<String, dynamic>>[];
        }
        return AppUser.fromJson(data);
      }
    } catch (_) {
      // Fallback below
    }

    return AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Live Scenario User',
      email: firebaseUser.email ?? 'unknown@example.com',
      role: UserRole.bhattiSupervisor,
      departments: const <UserDepartment>[],
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  Future<auth.User?> _waitForFirebaseUser() async {
    final authClient = _firebase.auth;
    if (authClient == null) return null;

    final deadline = DateTime.now().add(const Duration(seconds: 10));
    var user = authClient.currentUser;
    while (user == null && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      user = authClient.currentUser;
    }
    return user;
  }

  Map<String, dynamic> _syncResultMap(SyncRunResult result) {
    return <String, dynamic>{
      'executed': result.executed,
      'skipped': result.skipped,
      'criticalErrors': result.criticalErrors,
      'outboxPendingCount': result.outboxPendingCount,
      'outboxPermanentFailureCount': result.outboxPermanentFailureCount,
      'unresolvedConflictCount': result.unresolvedConflictCount,
      'completedAt': result.completedAt.toIso8601String(),
      'message': result.message,
      'pendingByModule': result.pendingByModule,
    };
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is firestore.Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  String? _dateToIso(dynamic raw) {
    final parsed = _parseDate(raw);
    return parsed?.toIso8601String();
  }

  String _stackHead(StackTrace stack) {
    final lines = stack.toString().split('\n');
    return lines.isEmpty ? '' : lines.first.trim();
  }

  void _emit(String test, String step, Map<String, dynamic> data) {
    final line = <String, dynamic>{
      'ts': DateTime.now().toIso8601String(),
      'test': test,
      'step': step,
      ...data,
    };
    stdout.writeln('[LIVE-TEST] ${jsonEncode(line)}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final runner = _LiveScenarioRunner();
  final code = await runner.run();
  exit(code);
}
