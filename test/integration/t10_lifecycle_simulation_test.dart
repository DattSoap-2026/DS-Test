// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/department_master_service.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/reconciliation_service.dart';
import 'package:flutter_app/services/inventory_movement_engine.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/stock_balance_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:isar/isar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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
bool get _shouldSkipDbTests => _dbSkipReason != null;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const actorUid = 'actor-t10';
  const salesmanUid = 'salesman-t10';
  const productRawId = 'prod-raw-t10';
  const productSemiId = 'prod-semi-t10';
  const productFinishedId = 'prod-finished-t10';
  const warehouseLocationId = DepartmentMasterService.warehouseMainLocationId;
  const bhattiLocationId = 'dept_sona_bhatti';
  const virtualSoldLocationId =
      InventoryProjectionService.virtualSoldLocationId;

  late DatabaseService dbService;
  late Directory tempDir;
  late DepartmentMasterService departmentMasterService;
  late InventoryProjectionService projectionService;
  late ReconciliationService reconciliationService;
  late InventoryMovementEngine movementEngine;

  Future<void> seedProducts() async {
    final now = DateTime.now();
    await dbService.db.writeTxn(() async {
      await dbService.products.putAll([
        ProductEntity()
          ..id = productRawId
          ..name = 'Raw Material'
          ..sku = 'RAW-001'
          ..itemType = 'raw_material'
          ..type = 'raw_material'
          ..category = 'Raw'
          ..stock = 0
          ..baseUnit = 'kg'
          ..price = 10
          ..status = 'active'
          ..createdAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced
          ..isDeleted = false,
        ProductEntity()
          ..id = productSemiId
          ..name = 'Semi-Finished'
          ..sku = 'SEMI-001'
          ..itemType = 'semi_finished_good'
          ..type = 'semi_finished_good'
          ..category = 'Semi'
          ..stock = 0
          ..baseUnit = 'kg'
          ..price = 20
          ..status = 'active'
          ..createdAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced
          ..isDeleted = false,
        ProductEntity()
          ..id = productFinishedId
          ..name = 'Finished Soap'
          ..sku = 'FIN-001'
          ..itemType = 'finished_good'
          ..type = 'finished_good'
          ..category = 'Soap'
          ..stock = 0
          ..baseUnit = 'pcs'
          ..price = 50
          ..status = 'active'
          ..createdAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced
          ..isDeleted = false,
      ]);
    });
  }

  Future<void> seedUsers() async {
    final now = DateTime.now();
    await dbService.db.writeTxn(() async {
      await dbService.users.putAll([
        UserEntity()
          ..id = actorUid
          ..email = '$actorUid@test.local'
          ..name = 'T10 Actor'
          ..role = 'Dispatch Manager'
          ..isActive = true
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced
          ..isDeleted = false,
        UserEntity()
          ..id = salesmanUid
          ..email = '$salesmanUid@test.local'
          ..name = 'T10 Salesman'
          ..role = 'Salesman'
          ..isActive = true
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced
          ..isDeleted = false,
      ]);
    });
  }

  Future<double> balanceFor(String locationId, String productId) async {
    final balanceId = '${locationId}_$productId';
    final balance = await dbService.stockBalances.getById(balanceId);
    return balance?.quantity ?? 0.0;
  }

  Future<void> verifyReconciliationClean(String step) async {
    final report = await reconciliationService.generateReport();
    expect(
      report.isClean,
      isTrue,
      reason: 'Reconciliation failed at step: $step',
    );
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp('t10_lifecycle_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    departmentMasterService = DepartmentMasterService(dbService);
    projectionService = InventoryProjectionService(
      dbService,
      departmentMasterService: departmentMasterService,
    );
    reconciliationService = ReconciliationService(
      dbService,
      departmentMasterService: departmentMasterService,
    );
    movementEngine = InventoryMovementEngine(dbService, projectionService);

    await projectionService.ensureCanonicalFoundation();
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    await dbService.db.writeTxn(() async {
      await dbService.stockBalances.clear();
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.inventoryCommands.clear();
      await dbService.stockMovements.clear();
      await dbService.departmentStocks.clear();
    });

    await seedProducts();
    await seedUsers();
    await projectionService.ensureInventoryLocations();
  });

  tearDownAll(() async {
    if (_shouldSkipDbTests) return;
    await dbService.db.close();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('T10 Lifecycle Simulation', () {
    test(
      'Full lifecycle: 9 steps with reconciliation verification',
      () async {
        // Step 1: Opening Stock
        await movementEngine.applyCommand(
          InventoryCommand.openingSetBalance(
            warehouseId: warehouseLocationId,
            productId: productRawId,
            openingWindowId: 'window-t10-1',
            setQuantityBase: 100.0,
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(warehouseLocationId, productRawId), 100.0);
        await verifyReconciliationClean('Step 1: Opening Stock');

        // Step 2: Department Issue
        await movementEngine.applyCommand(
          InventoryCommand.departmentIssue(
            departmentLocationId: bhattiLocationId,
            referenceId: 'issue-1',
            productId: productRawId,
            quantityBase: 50.0,
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(warehouseLocationId, productRawId), 50.0);
        expect(await balanceFor(bhattiLocationId, productRawId), 50.0);
        await verifyReconciliationClean('Step 2: Department Issue');

        // Step 3: Bhatti Production (consume raw, output semi)
        await movementEngine.applyCommand(
          InventoryCommand.bhattiProductionComplete(
            batchId: 'batch-1',
            consumptionLocationId: bhattiLocationId,
            outputLocationId: bhattiLocationId,
            consumptions: [
              InventoryCommandItem(productId: productRawId, quantityBase: 30.0),
            ],
            outputs: [
              InventoryCommandItem(
                productId: productSemiId,
                quantityBase: 25.0,
              ),
            ],
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(bhattiLocationId, productRawId), 20.0);
        expect(await balanceFor(bhattiLocationId, productSemiId), 25.0);
        await verifyReconciliationClean('Step 3: Bhatti Production');

        // Step 4: Cutting Production (consume semi, output finished)
        await movementEngine.applyCommand(
          InventoryCommand.cuttingProductionComplete(
            batchId: 'batch-1',
            consumptionLocationId: bhattiLocationId,
            outputLocationId: bhattiLocationId,
            consumptions: [
              InventoryCommandItem(
                productId: productSemiId,
                quantityBase: 20.0,
              ),
            ],
            outputs: [
              InventoryCommandItem(
                productId: productFinishedId,
                quantityBase: 100.0,
              ),
            ],
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(bhattiLocationId, productSemiId), 5.0);
        expect(await balanceFor(bhattiLocationId, productFinishedId), 100.0);
        await verifyReconciliationClean('Step 4: Cutting Production');

        // Step 5: Finished Goods Return to Warehouse
        await movementEngine.applyCommand(
          InventoryCommand.departmentReturn(
            departmentLocationId: bhattiLocationId,
            referenceId: 'return-1',
            productId: productFinishedId,
            quantityBase: 80.0,
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(bhattiLocationId, productFinishedId), 20.0);
        expect(await balanceFor(warehouseLocationId, productFinishedId), 80.0);
        await verifyReconciliationClean('Step 5: Finished Goods Return');

        // Step 6: Dispatch to Salesman
        final salesmanLocationId =
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid);
        await movementEngine.applyCommand(
          InventoryCommand.dispatchCreate(
            dispatchId: 'dispatch-1',
            salesmanUid: salesmanUid,
            items: [
              InventoryCommandItem(
                productId: productFinishedId,
                quantityBase: 50.0,
              ),
            ],
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(warehouseLocationId, productFinishedId), 30.0);
        expect(await balanceFor(salesmanLocationId, productFinishedId), 50.0);
        await verifyReconciliationClean('Step 6: Dispatch');

        // Step 7: Customer Sale
        await movementEngine.applyCommand(
          InventoryCommand.saleComplete(
            saleId: 'sale-1',
            salesmanUid: salesmanUid,
            items: [
              InventoryCommandItem(
                productId: productFinishedId,
                quantityBase: 20.0,
              ),
            ],
            actorUid: salesmanUid,
          ),
        );
        expect(await balanceFor(salesmanLocationId, productFinishedId), 30.0);
        expect(
          await balanceFor(virtualSoldLocationId, productFinishedId),
          20.0,
        );
        await verifyReconciliationClean('Step 7: Customer Sale');

        // Step 8: Sale Cancellation
        await movementEngine.applyCommand(
          InventoryCommand.saleReversal(
            originalCommandId: 'sale:sale-1',
            salesmanUid: salesmanUid,
            items: [
              InventoryCommandItem(
                productId: productFinishedId,
                quantityBase: 20.0,
              ),
            ],
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(salesmanLocationId, productFinishedId), 50.0);
        expect(await balanceFor(virtualSoldLocationId, productFinishedId), 0.0);
        await verifyReconciliationClean('Step 8: Sale Cancellation');

        // Step 9: Department Return (remaining raw material)
        await movementEngine.applyCommand(
          InventoryCommand.departmentReturn(
            departmentLocationId: bhattiLocationId,
            referenceId: 'return-2',
            productId: productRawId,
            quantityBase: 20.0,
            actorUid: actorUid,
          ),
        );
        expect(await balanceFor(bhattiLocationId, productRawId), 0.0);
        expect(await balanceFor(warehouseLocationId, productRawId), 70.0);
        await verifyReconciliationClean('Step 9: Department Return');

        // Final verification
        final commands = await dbService.inventoryCommands.where().findAll();
        expect(commands.length, 9);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements.isNotEmpty, isTrue);

        final finalReport = await reconciliationService.generateReport();
        expect(finalReport.isClean, isTrue);
      },
      skip: _dbSkipReason ?? false,
    );

    test('Offline simulation: outbox queue and sync', () async {
      // Apply 4 commands offline
      await movementEngine.applyCommand(
        InventoryCommand.openingSetBalance(
          warehouseId: warehouseLocationId,
          productId: productRawId,
          openingWindowId: 'window-offline-1',
          setQuantityBase: 100.0,
          actorUid: actorUid,
        ),
      );

      await movementEngine.applyCommand(
        InventoryCommand.departmentIssue(
          departmentLocationId: bhattiLocationId,
          referenceId: 'issue-offline-1',
          productId: productRawId,
          quantityBase: 50.0,
          actorUid: actorUid,
        ),
      );

      await movementEngine.applyCommand(
        InventoryCommand.bhattiProductionComplete(
          batchId: 'batch-offline-1',
          consumptionLocationId: bhattiLocationId,
          outputLocationId: bhattiLocationId,
          consumptions: [
            InventoryCommandItem(productId: productRawId, quantityBase: 30.0),
          ],
          outputs: [
            InventoryCommandItem(productId: productSemiId, quantityBase: 25.0),
          ],
          actorUid: actorUid,
        ),
      );

      await movementEngine.applyCommand(
        InventoryCommand.cuttingProductionComplete(
          batchId: 'batch-offline-2',
          consumptionLocationId: bhattiLocationId,
          outputLocationId: bhattiLocationId,
          consumptions: [
            InventoryCommandItem(productId: productSemiId, quantityBase: 20.0),
          ],
          outputs: [
            InventoryCommandItem(
              productId: productFinishedId,
              quantityBase: 100.0,
            ),
          ],
          actorUid: actorUid,
        ),
      );

      // Verify local balances
      expect(await balanceFor(warehouseLocationId, productRawId), 50.0);
      expect(await balanceFor(bhattiLocationId, productRawId), 20.0);
      expect(await balanceFor(bhattiLocationId, productSemiId), 5.0);
      expect(await balanceFor(bhattiLocationId, productFinishedId), 100.0);

      // Verify outbox queue
      final commands = await dbService.inventoryCommands.where().findAll();
      expect(commands.length, 4);
      expect(commands.every((c) => c.appliedLocally), isTrue);

      // Simulate sync (mark as applied remotely)
      await dbService.db.writeTxn(() async {
        for (final command in commands) {
          command.appliedRemotely = true;
          await dbService.inventoryCommands.put(command);
        }
      });

      final syncedCommands = await dbService.inventoryCommands
          .where()
          .findAll();
      expect(syncedCommands.every((c) => c.appliedRemotely), isTrue);

      final report = await reconciliationService.generateReport();
      expect(report.isClean, isTrue);
    }, skip: _dbSkipReason ?? false);

    test('Replay test: idempotency verification', () async {
      // Apply command first time
      await movementEngine.applyCommand(
        InventoryCommand.openingSetBalance(
          warehouseId: warehouseLocationId,
          productId: productRawId,
          openingWindowId: 'window-replay-1',
          setQuantityBase: 100.0,
          actorUid: actorUid,
        ),
      );

      final balanceAfterFirst = await balanceFor(
        warehouseLocationId,
        productRawId,
      );
      final movementsAfterFirst = await dbService.stockMovements
          .where()
          .findAll();
      final movementCountAfterFirst = movementsAfterFirst.length;

      // Replay same command (same commandId will be generated)
      await movementEngine.applyCommand(
        InventoryCommand.openingSetBalance(
          warehouseId: warehouseLocationId,
          productId: productRawId,
          openingWindowId: 'window-replay-1',
          setQuantityBase: 100.0,
          actorUid: actorUid,
        ),
      );

      final balanceAfterReplay = await balanceFor(
        warehouseLocationId,
        productRawId,
      );
      final movementsAfterReplay = await dbService.stockMovements
          .where()
          .findAll();
      final movementCountAfterReplay = movementsAfterReplay.length;

      // Verify no changes
      expect(balanceAfterReplay, balanceAfterFirst);
      expect(movementCountAfterReplay, movementCountAfterFirst);

      final report = await reconciliationService.generateReport();
      expect(report.duplicateMovements.isEmpty, isTrue);
      expect(report.isClean, isTrue);
    }, skip: _dbSkipReason ?? false);
  });
}
