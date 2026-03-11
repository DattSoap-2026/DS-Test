// ignore_for_file: subtype_of_sealed_class

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/inventory_location_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/department_master_service.dart';
import 'package:flutter_app/services/inventory_movement_engine.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/sync_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
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

class _MockSyncManager extends Mock implements SyncManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const productId = 'prod-t8-1';
  const salesmanUid = 'salesman-uid-1';
  const actorUid = 'actor-uid-1';
  const warehouseLocationId = DepartmentMasterService.warehouseMainLocationId;
  const packingLocationId = 'dept_packing';
  const productionLocationId = 'dept_production';
  const virtualSoldLocationId =
      InventoryProjectionService.virtualSoldLocationId;

  late DatabaseService dbService;
  late Directory tempDir;
  late DepartmentMasterService departmentMasterService;
  late InventoryProjectionService inventoryProjectionService;
  late InventoryMovementEngine engine;
  late _MockSyncManager syncManager;

  Future<void> seedProduct({required double stock}) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = productId
      ..name = 'T8 Test Product'
      ..sku = 'SKU-$productId'
      ..itemType = 'finished_good'
      ..type = 'finished_good'
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = 'Kg'
      ..price = 12
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  Future<void> seedSalesman({required int allocatedStock}) async {
    final now = DateTime.now();
    final user = UserEntity()
      ..id = salesmanUid
      ..name = 'Test Salesman'
      ..email = '$salesmanUid@test.local'
      ..role = 'Salesman'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    if (allocatedStock > 0) {
      user.setAllocatedStock({
        productId: AllocatedStockItem(
          productId: productId,
          name: 'T8 Test Product',
          quantity: allocatedStock,
          price: 12,
          baseUnit: 'Kg',
          conversionFactor: 1,
          freeQuantity: 0,
        ),
      });
    }

    await dbService.db.writeTxn(() async {
      await dbService.users.put(user);
    });
  }

  Future<void> prepareScenario({
    required double warehouseStock,
    bool includeSalesman = false,
    int salesmanStock = 0,
  }) async {
    await seedProduct(stock: warehouseStock);
    if (includeSalesman) {
      await seedSalesman(allocatedStock: salesmanStock);
    }
    await inventoryProjectionService.ensureCanonicalFoundation();
  }

  Future<double> balanceFor(String locationId) async {
    final balance = await inventoryProjectionService.getBalance(
      locationId: locationId,
      productId: productId,
    );
    return balance?.quantity ?? 0.0;
  }

  Future<void> setBalance(String locationId, double quantity) async {
    await inventoryProjectionService.setBalanceQuantity(
      locationId: locationId,
      productId: productId,
      quantity: quantity,
      syncStatus: SyncStatus.synced,
    );
  }

  List<Map<String, dynamic>> decodeQueuePayloads(List<SyncQueueEntity> items) {
    return items
        .map(
          (item) => Map<String, dynamic>.from(jsonDecode(item.dataJson) as Map),
        )
        .toList(growable: false);
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(DateTime.utc(2026, 1, 1));

    tempDir = await Directory.systemTemp.createTemp('t8_inventory_engine_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    departmentMasterService = DepartmentMasterService(dbService);
    inventoryProjectionService = InventoryProjectionService(
      dbService,
      departmentMasterService: departmentMasterService,
    );
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.stockBalances.clear();
      await dbService.inventoryLocations.clear();
      await dbService.departmentMasters.clear();
      await dbService.departmentStocks.clear();
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.inventoryCommands.clear();
      await dbService.stockMovements.clear();
      await dbService.syncQueue.clear();
    });

    syncManager = _MockSyncManager();
    when(
      () => syncManager.buildQueueEntity(
        collection: any(named: 'collection'),
        action: any(named: 'action'),
        data: any(named: 'data'),
        now: any(named: 'now'),
      ),
    ).thenAnswer((invocation) async {
      final collection = invocation.namedArguments[#collection] as String;
      final action = invocation.namedArguments[#action] as String;
      final data = Map<String, dynamic>.from(
        invocation.namedArguments[#data] as Map,
      );
      final now =
          invocation.namedArguments[#now] as DateTime? ?? DateTime.now();

      return SyncQueueEntity()
        ..id = 'queue:${data['commandId']}'
        ..collection = collection
        ..action = action
        ..dataJson = jsonEncode(data)
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
    });
    when(() => syncManager.refreshPendingCount()).thenAnswer((_) async {});

    engine = InventoryMovementEngine(
      dbService,
      inventoryProjectionService,
    );
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

  group('T8 Inventory Movement Engine', () {
    test(
      'department_issue updates balances, movement rows, and outbox',
      () async {
        await prepareScenario(warehouseStock: 100);

        final command = InventoryCommand.departmentIssue(
          departmentLocationId: packingLocationId,
          referenceId: 'issue-1',
          productId: productId,
          quantityBase: 12,
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 10),
        );

        await engine.applyCommand(command);

        expect(await balanceFor(warehouseLocationId), 88);
        expect(await balanceFor(packingLocationId), 12);

        final product = await dbService.products.getById(productId);
        expect(product?.stock, 88);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        expect(movements.single.commandId, command.commandId);
        expect(movements.single.sourceLocationId, warehouseLocationId);
        expect(movements.single.destinationLocationId, packingLocationId);
        expect(movements.single.quantityBase, 12);

        final queueItems = await dbService.syncQueue.where().findAll();
        expect(queueItems, hasLength(1));
        expect(
          queueItems.single.collection,
          CollectionRegistry.inventoryCommands,
        );
        expect(
          decodeQueuePayloads(queueItems).single['commandId'],
          command.commandId,
        );
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'department_return reverses warehouse and department balances',
      () async {
        await prepareScenario(warehouseStock: 90);
        await setBalance(packingLocationId, 10);

        final command = InventoryCommand.departmentReturn(
          departmentLocationId: packingLocationId,
          referenceId: 'return-1',
          productId: productId,
          quantityBase: 4,
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 11),
        );

        await engine.applyCommand(command);

        expect(await balanceFor(warehouseLocationId), 94);
        expect(await balanceFor(packingLocationId), 6);

        final product = await dbService.products.getById(productId);
        expect(product?.stock, 94);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'opening_set_balance is idempotent and creates no duplicate movement',
      () async {
        await prepareScenario(warehouseStock: 25);

        final command = InventoryCommand.openingSetBalance(
          warehouseId: warehouseLocationId,
          productId: productId,
          openingWindowId: 'window-1',
          setQuantityBase: 40,
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 12),
        );

        await engine.applyCommand(command);
        await engine.applyCommand(command);

        expect(await balanceFor(warehouseLocationId), 40);

        final product = await dbService.products.getById(productId);
        expect(product?.stock, 40);

        expect(await dbService.inventoryCommands.count(), 1);
        expect(await dbService.stockMovements.where().findAll(), hasLength(1));
        expect(await dbService.syncQueue.where().findAll(), hasLength(1));
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'dispatch_create moves stock from warehouse to salesman van',
      () async {
        await prepareScenario(
          warehouseStock: 50,
          includeSalesman: true,
          salesmanStock: 0,
        );

        final command = InventoryCommand.dispatchCreate(
          dispatchId: 'dispatch-1',
          salesmanUid: salesmanUid,
          items: const [
            InventoryCommandItem(productId: productId, quantityBase: 7),
          ],
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 13),
        );

        await engine.applyCommand(command);

        expect(await balanceFor(warehouseLocationId), 43);
        expect(
          await balanceFor(
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid),
          ),
          7,
        );
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'sale_complete moves stock from salesman van to virtual sold',
      () async {
        await prepareScenario(
          warehouseStock: 0,
          includeSalesman: true,
          salesmanStock: 9,
        );

        final command = InventoryCommand.saleComplete(
          saleId: 'sale-1',
          salesmanUid: salesmanUid,
          items: const [
            InventoryCommandItem(productId: productId, quantityBase: 3),
          ],
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 14),
        );

        await engine.applyCommand(command);

        final salesmanLocationId =
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid);
        expect(await balanceFor(salesmanLocationId), 6);
        expect(await balanceFor(virtualSoldLocationId), 3);

        final user = await dbService.users.getById(salesmanUid);
        expect(user?.getAllocatedStock()[productId]?.quantity, 6);

        final virtualLocation = await dbService.inventoryLocations.getById(
          virtualSoldLocationId,
        );
        expect(virtualLocation, isNotNull);
        expect(virtualLocation?.type, 'virtual');
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'sale_reversal restores stock and marks reversal movement',
      () async {
        await prepareScenario(
          warehouseStock: 0,
          includeSalesman: true,
          salesmanStock: 5,
        );

        final saleCommand = InventoryCommand.saleComplete(
          saleId: 'sale-2',
          salesmanUid: salesmanUid,
          items: const [
            InventoryCommandItem(productId: productId, quantityBase: 2),
          ],
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 15),
        );
        await engine.applyCommand(saleCommand);

        final reversalCommand = InventoryCommand.saleReversal(
          originalCommandId: saleCommand.commandId,
          salesmanUid: salesmanUid,
          items: const [
            InventoryCommandItem(productId: productId, quantityBase: 2),
          ],
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 16),
        );
        await engine.applyCommand(reversalCommand);

        final salesmanLocationId =
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid);
        expect(await balanceFor(salesmanLocationId), 5);
        expect(await balanceFor(virtualSoldLocationId), 0);

        final movements = await dbService.stockMovements.where().findAll();
        final reversalMovement = movements.singleWhere(
          (movement) => movement.commandId == reversalCommand.commandId,
        );
        expect(reversalMovement.isReversal, isTrue);
        expect(reversalMovement.sourceLocationId, virtualSoldLocationId);
        expect(reversalMovement.destinationLocationId, salesmanLocationId);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'internal_transfer updates balances between any two locations',
      () async {
        await prepareScenario(warehouseStock: 0);
        await setBalance(packingLocationId, 10);
        await setBalance(productionLocationId, 2);

        final command = InventoryCommand.internalTransfer(
          sourceLocationId: packingLocationId,
          destinationLocationId: productionLocationId,
          referenceId: 'transfer-1',
          productId: productId,
          quantityBase: 4,
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 17),
        );

        await engine.applyCommand(command);

        expect(await balanceFor(packingLocationId), 6);
        expect(await balanceFor(productionLocationId), 6);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'idempotency prevents duplicate balance and movement writes',
      () async {
        await prepareScenario(warehouseStock: 20);

        final command = InventoryCommand.departmentIssue(
          departmentLocationId: packingLocationId,
          referenceId: 'idempotent-1',
          productId: productId,
          quantityBase: 5,
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 18),
        );

        await engine.applyCommand(command);
        await engine.applyCommand(command);

        expect(await balanceFor(warehouseLocationId), 15);
        expect(await balanceFor(packingLocationId), 5);

        expect(await dbService.inventoryCommands.count(), 1);
        expect(await dbService.stockMovements.where().findAll(), hasLength(1));
        expect(await dbService.syncQueue.where().findAll(), hasLength(1));

        verify(
          () => syncManager.buildQueueEntity(
            collection: CollectionRegistry.inventoryCommands,
            action: 'set',
            data: any(named: 'data'),
            now: any(named: 'now'),
          ),
        ).called(1);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'products.stock mirror stays in sync after warehouse balance change',
      () async {
        await prepareScenario(warehouseStock: 12);
        await setBalance(packingLocationId, 5);

        final command = InventoryCommand.internalTransfer(
          sourceLocationId: packingLocationId,
          destinationLocationId: warehouseLocationId,
          referenceId: 'mirror-1',
          productId: productId,
          quantityBase: 2,
          actorUid: actorUid,
          createdAt: DateTime.utc(2026, 3, 7, 19),
        );

        await engine.applyCommand(command);

        final product = await dbService.products.getById(productId);
        expect(await balanceFor(warehouseLocationId), 14);
        expect(product?.stock, 14);
      },
      skip: _dbSkipReason ?? false,
    );
  });
}
