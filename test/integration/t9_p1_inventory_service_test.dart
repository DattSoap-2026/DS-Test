// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/department_master_service.dart';
import 'package:flutter_app/services/identity_revalidation_state.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
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

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockFirebaseUser extends Mock implements User {}

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockTransaction extends Mock implements Transaction {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

class _AuthOverrideInventoryService extends InventoryService {
  _AuthOverrideInventoryService(
    super.firebase,
    super.dbService,
    this._authOverride,
    this._dbOverride,
  );

  final FirebaseAuth _authOverride;
  final FirebaseFirestore _dbOverride;

  @override
  FirebaseAuth? get auth => _authOverride;

  @override
  FirebaseFirestore? get db => _dbOverride;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const actorUid = 'actor-t9-p1';
  const actorEmail = 'actor-t9-p1@test.local';
  const salesmanUid = 'salesman-t9-p1';
  const productId = 'prod-t9-p1-1';
  const packingDepartment = 'Packing';
  const packingLocationId = 'dept_packing';
  const warehouseLocationId = DepartmentMasterService.warehouseMainLocationId;
  const virtualSoldLocationId =
      InventoryProjectionService.virtualSoldLocationId;

  late DatabaseService dbService;
  late Directory tempDir;
  late DepartmentMasterService departmentMasterService;
  late InventoryProjectionService projectionService;
  late _MockFirebaseAuth firebaseAuth;
  late _MockFirebaseUser firebaseUser;
  late _MockFirestore firestore;
  late InventoryService inventoryService;

  Future<void> seedProduct({required double stock}) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = productId
      ..name = 'T9 P1 Product'
      ..sku = 'SKU-$productId'
      ..itemType = 'finished_good'
      ..type = 'finished_good'
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = 'pcs'
      ..price = 18
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  Future<void> seedActor() async {
    final now = DateTime.now();
    final actor = UserEntity()
      ..id = actorUid
      ..email = actorEmail
      ..name = 'T9 Actor'
      ..role = 'Dispatch Manager'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.users.put(actor);
    });
  }

  Future<void> seedSalesman({int allocatedQuantity = 0}) async {
    final now = DateTime.now();
    final salesman = UserEntity()
      ..id = salesmanUid
      ..email = '$salesmanUid@test.local'
      ..name = 'T9 Salesman'
      ..role = 'Salesman'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    if (allocatedQuantity > 0) {
      salesman.setAllocatedStock({
        productId: AllocatedStockItem(
          productId: productId,
          name: 'T9 P1 Product',
          quantity: allocatedQuantity,
          price: 18,
          baseUnit: 'pcs',
          conversionFactor: 1,
          freeQuantity: 0,
        ),
      });
    }
    await dbService.db.writeTxn(() async {
      await dbService.users.put(salesman);
    });
  }

  Future<void> prepareFoundation({
    required double warehouseStock,
    int salesmanStock = 0,
  }) async {
    await seedActor();
    await seedProduct(stock: warehouseStock);
    await seedSalesman(allocatedQuantity: salesmanStock);
    await projectionService.ensureCanonicalFoundation();
  }

  Future<double> balanceFor(String locationId) async {
    final balance = await projectionService.getBalance(
      locationId: locationId,
      productId: productId,
    );
    return balance?.quantity ?? 0.0;
  }

  Future<void> stubReceiveDispatch({
    required String dispatchId,
    required Map<String, dynamic> dispatchPayload,
  }) async {
    final transaction = _MockTransaction();
    final dispatchCollection = _MockCollectionReference();
    final auditCollection = _MockCollectionReference();
    final dispatchDoc = _MockDocumentReference();
    final auditDoc = _MockDocumentReference();
    final dispatchSnapshot = _MockDocumentSnapshot();

    when(
      () => firestore.collection(dispatchesCollection),
    ).thenReturn(dispatchCollection);
    when(() => firestore.collection('audit_logs')).thenReturn(auditCollection);
    when(() => dispatchCollection.doc(dispatchId)).thenReturn(dispatchDoc);
    when(() => auditCollection.doc()).thenReturn(auditDoc);
    when(
      () => transaction.get<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => dispatchSnapshot);
    when(() => dispatchSnapshot.exists).thenReturn(true);
    when(
      () => dispatchSnapshot.data(),
    ).thenAnswer((_) => Map<String, dynamic>.from(dispatchPayload));
    when(() => transaction.update(dispatchDoc, any())).thenAnswer((invocation) {
      final updates = Map<String, dynamic>.from(
        invocation.positionalArguments[1] as Map,
      );
      dispatchPayload.addAll(updates);
      return transaction;
    });
    when(() => transaction.update(any(), any())).thenAnswer((invocation) {
      final updates = Map<String, dynamic>.from(
        invocation.positionalArguments[1] as Map,
      );
      dispatchPayload.addAll(updates);
      return transaction;
    });
    when(
      () => transaction.set<Map<String, dynamic>>(auditDoc, any()),
    ).thenAnswer((_) => transaction);
    when(() => transaction.set(any(), any())).thenAnswer((_) => transaction);
    when(() => firestore.runTransaction<void>(any())).thenAnswer((
      invocation,
    ) async {
      final handler =
          invocation.positionalArguments.first
              as Future<void> Function(Transaction);
      await handler(transaction);
    });
    when(() => firestore.runTransaction<Null>(any())).thenAnswer((
      invocation,
    ) async {
      final handler =
          invocation.positionalArguments.first
              as Future<Null> Function(Transaction);
      return await handler(transaction);
    });
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(_FakeDocumentReference());

    tempDir = await Directory.systemTemp.createTemp('t9_p1_inventory_service_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    departmentMasterService = DepartmentMasterService(dbService);
    projectionService = InventoryProjectionService(
      dbService,
      departmentMasterService: departmentMasterService,
    );
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await IdentityRevalidationState.clear(reason: 't9_p1_setup');
    await dbService.db.writeTxn(() async {
      await dbService.stockBalances.clear();
      await dbService.inventoryLocations.clear();
      await dbService.departmentMasters.clear();
      await dbService.departmentStocks.clear();
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.inventoryCommands.clear();
      await dbService.stockMovements.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
    });

    firebaseAuth = _MockFirebaseAuth();
    firebaseUser = _MockFirebaseUser();
    firestore = _MockFirestore();

    when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn(actorUid);
    when(() => firebaseUser.email).thenReturn(actorEmail);

    inventoryService = _AuthOverrideInventoryService(
      FirebaseServices(),
      dbService,
      firebaseAuth,
      firestore,
    );

    await IdentityRevalidationState.markValidated(uid: actorUid);
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

  group('T9-P1 inventory_service migration', () {
    test(
      'applyProductStockChangeInTxn updates balance, creates movement, and keeps product mirror in sync',
      () async {
        await prepareFoundation(warehouseStock: 100, salesmanStock: 0);

        await dbService.db.writeTxn(() async {
          await inventoryService.applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: -20,
            updatedAt: DateTime.utc(2026, 3, 8, 9),
            markSyncPending: true,
            referenceId: 'prod-adjust-1',
          );
        });

        expect(await balanceFor(warehouseLocationId), 80);
        final product = await dbService.products.getById(productId);
        expect(product?.stock, 80);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        expect(movements.single.productId, productId);
        expect(movements.single.sourceLocationId, warehouseLocationId);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'applyDepartmentStockChangeInTxn moves stock from warehouse to department',
      () async {
        await prepareFoundation(warehouseStock: 100, salesmanStock: 0);

        await dbService.db.writeTxn(() async {
          await inventoryService.applyDepartmentStockChangeInTxn(
            departmentName: packingDepartment,
            productId: productId,
            quantityChange: 12,
            productName: 'T9 P1 Product',
            unit: 'pcs',
            updatedAt: DateTime.utc(2026, 3, 8, 10),
          );
        });

        expect(await balanceFor(warehouseLocationId), 88);
        expect(await balanceFor(packingLocationId), 12);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        expect(movements.single.destinationLocationId, packingLocationId);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'adjustSalesmanStock updates salesman balance, creates movement, and syncs allocatedStock mirror',
      () async {
        await prepareFoundation(warehouseStock: 40, salesmanStock: 15);

        await inventoryService.adjustSalesmanStock(
          salesmanId: salesmanUid,
          productId: productId,
          quantity: -4,
          reason: 'Customer sale',
          referenceId: 'sale-direct-1',
          referenceType: 'sale',
        );

        expect(
          await balanceFor(
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid),
          ),
          11,
        );
        expect(await balanceFor(virtualSoldLocationId), 4);

        final salesman = await dbService.users.getById(salesmanUid);
        expect(salesman?.getAllocatedStock()[productId]?.quantity, 11);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        expect(movements.single.movementType, 'sale_complete');
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'receiveDispatch applies dispatch command once and skips replay by commandId',
      () async {
        await prepareFoundation(warehouseStock: 50, salesmanStock: 0);

        final dispatchPayload = <String, dynamic>{
          'id': 'dispatch-doc-1',
          'dispatchId': 'DSP-T9-1',
          'salesmanId': salesmanUid,
          'status': 'created',
          'items': [
            {
              'productId': productId,
              'productName': 'T9 P1 Product',
              'quantity': 7,
              'unit': 'pcs',
              'rate': 18,
              'amount': 126,
            },
          ],
        };
        await stubReceiveDispatch(
          dispatchId: 'dispatch-doc-1',
          dispatchPayload: dispatchPayload,
        );

        await inventoryService.receiveDispatch('dispatch-doc-1');
        expect(dispatchPayload['status'], 'received');
        expect(await balanceFor(warehouseLocationId), 43);
        expect(
          await balanceFor(
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid),
          ),
          7,
        );

        await inventoryService.receiveDispatch('dispatch-doc-1');
        expect(await balanceFor(warehouseLocationId), 43);
        expect(
          await balanceFor(
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid),
          ),
          7,
        );

        final commands = await dbService.inventoryCommands.where().findAll();
        expect(commands.map((command) => command.commandId).toList(), [
          'dispatch:dispatch-doc-1',
        ]);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'existing inventory_service callers still work end to end',
      () async {
        await prepareFoundation(warehouseStock: 40, salesmanStock: 0);

        final transferred = await inventoryService.transferToDepartment(
          departmentName: packingDepartment,
          items: [
            {
              'productId': productId,
              'productName': 'T9 P1 Product',
              'quantity': 10,
              'unit': 'pcs',
            },
          ],
          issuedByUserId: actorUid,
          issuedByUserName: 'T9 Actor',
          referenceId: 'issue-e2e-1',
        );
        expect(transferred, isTrue);
        expect(await balanceFor(warehouseLocationId), 30);
        expect(await balanceFor(packingLocationId), 10);

        final returned = await inventoryService.returnFromDepartment(
          departmentName: packingDepartment,
          items: [
            {
              'productId': productId,
              'productName': 'T9 P1 Product',
              'quantity': 4,
              'unit': 'pcs',
            },
          ],
          returnedByUserId: actorUid,
          returnedByUserName: 'T9 Actor',
          referenceId: 'return-e2e-1',
        );
        expect(returned, isTrue);
        expect(await balanceFor(warehouseLocationId), 34);
        expect(await balanceFor(packingLocationId), 6);

        await inventoryService.revertSaleStock(
          saleId: 'sale-cancel-1',
          recipientType: 'customer',
          salesmanId: salesmanUid,
          performedBy: actorUid,
          items: [
            {'productId': productId, 'quantity': 3, 'baseUnit': 'pcs'},
          ],
        );

        expect(
          await balanceFor(
            InventoryProjectionService.salesmanLocationIdForUid(salesmanUid),
          ),
          3,
        );
        final salesman = await dbService.users.getById(salesmanUid);
        expect(salesman?.getAllocatedStock()[productId]?.quantity, 3);
      },
      skip: _dbSkipReason ?? false,
    );
  });
}
