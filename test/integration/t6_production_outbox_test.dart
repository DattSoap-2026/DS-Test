// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/department_stock_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/models/types/cutting_types.dart';
import 'package:flutter_app/services/bhatti_service.dart';
import 'package:flutter_app/services/cutting_batch_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/department_master_service.dart';
import 'package:flutter_app/services/inventory_movement_engine.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/production_service.dart';
import 'package:flutter_app/services/tank_service.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool _runDbTests = bool.fromEnvironment(
  'RUN_DB_TESTS',
  defaultValue: false,
);

String? _detectDbSkipReason() {
  if (!_runDbTests) {
    return 'Requires Isar native library. Run with --dart-define=RUN_DB_TESTS=true';
  }

  if (Platform.isWindows) {
    final dllPath =
        '${Directory.current.path}${Platform.pathSeparator}isar.dll';
    try {
      DynamicLibrary.open(dllPath);
    } catch (e) {
      return 'RUN_DB_TESTS=true but Isar native library is unavailable: $e';
    }
  }

  return null;
}

final String? _dbSkipReason = _detectDbSkipReason();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService dbService;
  late Directory tempDir;
  late InventoryService inventoryService;
  late ProductionService productionService;
  late BhattiService bhattiService;
  late CuttingBatchService cuttingBatchService;
  late int queueTriggerCount;

  Future<void> seedProduct({
    required String id,
    required String name,
    required double stock,
    String baseUnit = 'Kg',
    double price = 10,
    double? unitWeightGrams,
  }) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = id
      ..name = name
      ..sku = 'SKU-$id'
      ..itemType = 'finished_good'
      ..type = 'finished_good'
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = baseUnit
      ..price = price
      ..unitWeightGrams = unitWeightGrams
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  Future<void> seedDepartmentStock({
    required String departmentName,
    required String productId,
    required String productName,
    required double stock,
    String unit = 'Kg',
  }) async {
    final now = DateTime.now();
    final entity = DepartmentStockEntity()
      ..id = '${departmentName}_$productId'
      ..departmentName = departmentName
      ..productId = productId
      ..productName = productName
      ..stock = stock
      ..unit = unit
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.departmentStocks.put(entity);
    });
  }

  setUpAll(() async {
    if (_dbSkipReason != null) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp('t6_production_outbox_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final firebase = FirebaseServices();
    inventoryService = InventoryService(firebase, dbService);
    productionService = ProductionService(
      firebase,
      inventoryService,
      dbService,
    );
    final departmentMasterService = DepartmentMasterService(dbService);
    final projectionService = InventoryProjectionService(
      dbService,
      departmentMasterService: departmentMasterService,
    );
    final engine = InventoryMovementEngine(dbService, projectionService);

    bhattiService = BhattiService(
      firebase,
      dbService,
      TankService(firebase, dbService),
      inventoryService,
      engine,
    );
    cuttingBatchService = CuttingBatchService(
      firebase,
      dbService,
      engine,
    );
  });

  setUp(() async {
    if (_dbSkipReason != null) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    queueTriggerCount = 0;

    Future<void> incrementQueueCount() async {
      queueTriggerCount++;
    }

    productionService.bindCentralQueueSync(incrementQueueCount);
    bhattiService.bindCentralQueueSync(incrementQueueCount);
    cuttingBatchService.bindCentralQueueSync(incrementQueueCount);

    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.departmentStocks.clear();
      await dbService.productionTargets.clear();
      await dbService.detailedProductionLogs.clear();
      await dbService.bhattiBatches.clear();
      await dbService.wastageLogs.clear();
      await dbService.cuttingBatches.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
      await dbService.tanks.clear();
      await dbService.tankTransactions.clear();
      await dbService.tankLots.clear();
    });
  });

  tearDownAll(() async {
    if (_dbSkipReason != null) return;
    await dbService.db.close();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('T6 Production Outbox', () {
    test(
      'addDetailedProductionLog enqueues a durable production outbox command',
      () async {
        await seedProduct(id: 'raw-1', name: 'Raw Oil', stock: 50, price: 12);
        await seedProduct(
          id: 'fg-1',
          name: 'Finished Soap',
          stock: 5,
          price: 25,
        );

        final created = await productionService.addDetailedProductionLog(
          AddDetailedProductionLogPayload(
            batchNumber: 'PB-001',
            productId: 'fg-1',
            productName: 'Finished Soap',
            totalBatchQuantity: 5,
            unit: 'Kg',
            supervisorId: 'sup-1',
            supervisorName: 'Supervisor',
            semiFinishedGoodsUsed: const [
              {
                'productId': 'raw-1',
                'productName': 'Raw Oil',
                'quantity': 2.0,
                'unit': 'Kg',
              },
            ],
          ),
        );

        expect(created, isTrue);
        expect(queueTriggerCount, 1);

        final queueItems = await dbService.syncQueue.where().findAll();
        expect(queueItems, hasLength(1));
        final queueItem = queueItems.single;
        expect(queueItem.collection, detailedProductionLogsCollection);
        expect(queueItem.action, 'add');
        expect(queueItem.id, startsWith('production_log_'));

        final payload = OutboxCodec.decode(
          queueItem.dataJson,
          fallbackQueuedAt: queueItem.createdAt,
        ).payload;
        expect(payload['id'], isNotEmpty);
        expect(payload[OutboxCodec.idempotencyKeyField], isNotEmpty);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'createBhattiBatch enqueues a durable bhatti batch command',
      () async {
        await seedProduct(id: 'raw-1', name: 'Raw Oil', stock: 100, price: 5);
        await seedProduct(
          id: 'semi-1',
          name: 'Semi Soap',
          stock: 0,
          price: 0,
          unitWeightGrams: 1000,
        );
        await seedDepartmentStock(
          departmentName: 'sona bhatti',
          productId: 'raw-1',
          productName: 'Raw Oil',
          stock: 20,
        );

        final created = await bhattiService.createBhattiBatch(
          bhattiName: 'Sona Bhatti',
          targetProductId: 'semi-1',
          targetProductName: 'Semi Soap',
          batchCount: 1,
          outputBoxes: 6,
          supervisorId: 'sup-1',
          supervisorName: 'Supervisor',
          rawMaterialsConsumed: const [
            {
              'materialId': 'raw-1',
              'materialName': 'Raw Oil',
              'quantity': 2.0,
              'unit': 'Kg',
            },
          ],
        );

        expect(created, isTrue);
        expect(queueTriggerCount, 1);

        final queueItems = await dbService.syncQueue.where().findAll();
        final queueItem = queueItems.singleWhere(
          (entry) => entry.collection == bhattiBatchesCollection,
        );
        expect(queueItem.action, 'add');
        expect(queueItem.id, startsWith('bhatti_batch_create_'));

        final payload = OutboxCodec.decode(
          queueItem.dataJson,
          fallbackQueuedAt: queueItem.createdAt,
        ).payload;
        expect(payload['id'], isNotEmpty);
        expect(payload[OutboxCodec.idempotencyKeyField], isNotEmpty);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'createCuttingBatch enqueues a durable cutting batch command',
      () async {
        await seedProduct(
          id: 'semi-1',
          name: 'Semi Soap',
          stock: 20,
          baseUnit: 'Kg',
          price: 8,
        );
        await seedProduct(
          id: 'fg-1',
          name: 'Finished Soap',
          stock: 0,
          baseUnit: 'Pcs',
          price: 20,
        );

        final created = await cuttingBatchService.createCuttingBatch(
          semiFinishedProductId: 'semi-1',
          semiFinishedProductName: 'Semi Soap',
          finishedGoodId: 'fg-1',
          finishedGoodName: 'Finished Soap',
          departmentId: 'cutting-1',
          departmentName: 'Cutting',
          operatorId: 'op-1',
          operatorName: 'Operator',
          supervisorId: 'sup-1',
          supervisorName: 'Supervisor',
          shift: ShiftType.day,
          totalBatchWeightKg: 10,
          standardWeightGm: 1000,
          actualAvgWeightGm: 1000,
          tolerancePercent: 5,
          batchCount: 1,
          unitsProduced: 10,
          cuttingWasteKg: 0,
          wasteType: WasteType.scrap,
        );

        expect(created, isTrue);
        expect(queueTriggerCount, 1);

        final queueItems = await dbService.syncQueue.where().findAll();
        final queueItem = queueItems.singleWhere(
          (entry) => entry.collection == cuttingBatchesCollection,
        );
        expect(queueItem.action, 'add');
        expect(queueItem.id, startsWith('cutting_batch_create_'));

        final payload = OutboxCodec.decode(
          queueItem.dataJson,
          fallbackQueuedAt: queueItem.createdAt,
        ).payload;
        expect(payload['id'], isNotEmpty);
        expect(payload[OutboxCodec.idempotencyKeyField], isNotEmpty);
      },
      skip: _dbSkipReason ?? false,
    );
  });
}
