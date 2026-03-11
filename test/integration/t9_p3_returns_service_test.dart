// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/return_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/customers_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/identity_revalidation_state.dart';
import 'package:flutter_app/services/inventory_movement_engine.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/notification_service.dart';
import 'package:flutter_app/services/returns_service.dart';
import 'package:flutter_app/services/sales_service.dart';
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

class _MockWriteBatch extends Mock implements WriteBatch {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

class _AuthOverrideReturnsService extends ReturnsService {
  // ignore: use_super_parameters
  _AuthOverrideReturnsService(
    FirebaseServices firebase,
    DatabaseService db,
    InventoryService inventoryService,
    CustomersService customersService,
    SalesService salesService,
    this._authOverride, {
    FirebaseFirestore? firestoreOverride,
  }) : _firestoreOverride = firestoreOverride,
       super(firebase, db, inventoryService, customersService, salesService);

  final FirebaseAuth _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  @override
  FirebaseAuth? get auth => _authOverride;

  @override
  FirebaseFirestore? get db => _firestoreOverride;
}

class _BatchRemoteHarness {
  final _MockFirestore firestore = _MockFirestore();
  final _MockWriteBatch batch = _MockWriteBatch();

  final Map<String, Map<String, dynamic>> _docs =
      <String, Map<String, dynamic>>{};
  final Map<String, _MockCollectionReference> _collections =
      <String, _MockCollectionReference>{};
  final Map<String, _MockDocumentReference> _refs =
      <String, _MockDocumentReference>{};
  int _autoId = 0;

  _BatchRemoteHarness() {
    when(() => firestore.batch()).thenReturn(batch);
    when(() => firestore.collection(any())).thenAnswer((invocation) {
      final name = invocation.positionalArguments.first as String;
      return _collection(name);
    });
    when(() => batch.commit()).thenAnswer((_) async {});
    when(() => batch.update(any(), any())).thenAnswer((invocation) {
      final ref =
          invocation.positionalArguments[0]
              as DocumentReference<Map<String, dynamic>>;
      final updates = Map<String, dynamic>.from(
        invocation.positionalArguments[1] as Map,
      );
      final key = _keyForRef(ref);
      final current = Map<String, dynamic>.from(
        _docs[key] ?? <String, dynamic>{},
      );
      current.addAll(updates);
      _docs[key] = current;
    });
    when(() => batch.set<Map<String, dynamic>>(any(), any())).thenAnswer((
      invocation,
    ) {
      final ref =
          invocation.positionalArguments[0]
              as DocumentReference<Map<String, dynamic>>;
      final data = Map<String, dynamic>.from(
        invocation.positionalArguments[1] as Map,
      );
      _writeDoc(ref, data, merge: false);
    });
    when(() => batch.set<Map<String, dynamic>>(any(), any(), any())).thenAnswer(
      (invocation) {
        final ref =
            invocation.positionalArguments[0]
                as DocumentReference<Map<String, dynamic>>;
        final data = Map<String, dynamic>.from(
          invocation.positionalArguments[1] as Map,
        );
        _writeDoc(ref, data, merge: true);
      },
    );
  }

  void seedDoc(String collection, String id, Map<String, dynamic> data) {
    final key = '$collection/$id';
    _docs[key] = Map<String, dynamic>.from(data);
    _doc(collection, id);
  }

  Map<String, dynamic>? readDoc(String collection, String id) {
    final data = _docs['$collection/$id'];
    return data == null ? null : Map<String, dynamic>.from(data);
  }

  _MockCollectionReference _collection(String name) {
    return _collections.putIfAbsent(name, () {
      final collection = _MockCollectionReference();
      when(() => collection.doc(any())).thenAnswer((invocation) {
        final id = invocation.positionalArguments.first as String;
        return _doc(name, id);
      });
      when(() => collection.doc()).thenAnswer((_) {
        _autoId += 1;
        return _doc(name, 'auto-${_autoId.toString().padLeft(4, '0')}');
      });
      return collection;
    });
  }

  _MockDocumentReference _doc(String collection, String id) {
    final key = '$collection/$id';
    return _refs.putIfAbsent(key, () {
      final ref = _MockDocumentReference();
      when(() => ref.id).thenReturn(id);
      when(() => ref.get()).thenAnswer((_) async => _snapshot(key));
      return ref;
    });
  }

  _MockDocumentSnapshot _snapshot(String key) {
    final snapshot = _MockDocumentSnapshot();
    final data = _docs[key];
    when(() => snapshot.exists).thenReturn(data != null);
    when(
      () => snapshot.data(),
    ).thenReturn(data == null ? null : Map<String, dynamic>.from(data));
    return snapshot;
  }

  String _keyForRef(DocumentReference<Map<String, dynamic>> ref) {
    return _refs.entries.firstWhere((entry) => identical(entry.value, ref)).key;
  }

  void _writeDoc(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data, {
    required bool merge,
  }) {
    final key = _keyForRef(ref);
    final next = merge
        ? {...?_docs[key], ...data}
        : Map<String, dynamic>.from(data);
    _docs[key] = next;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const actorUid = 'actor-t9-p3';
  const actorEmail = 'actor-t9-p3@test.local';
  const salesmanUid = 'salesman-t9-p3';
  const productId = 'prod-t9-p3-1';
  const warehouseLocationId =
      InventoryProjectionService.warehouseMainLocationId;
  const salesmanLocationId = 'salesman_van_$salesmanUid';
  const virtualSoldLocationId =
      InventoryProjectionService.virtualSoldLocationId;

  late Directory tempDir;
  late DatabaseService dbService;
  late InventoryProjectionService projectionService;
  late InventoryMovementEngine inventoryEngine;
  late InventoryService inventoryService;
  late CustomersService customersService;
  late SalesService salesService;
  late _MockFirebaseAuth firebaseAuth;
  late _MockFirebaseUser firebaseUser;
  late _AuthOverrideReturnsService localReturnsService;

  Future<void> seedProduct({required double stock}) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = productId
      ..name = 'T9 P3 Product'
      ..sku = 'SKU-$productId'
      ..itemType = 'finished_good'
      ..type = 'finished_good'
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = 'pcs'
      ..price = 30
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  Future<void> seedAdminActor() async {
    final now = DateTime.now();
    final actor = UserEntity()
      ..id = actorUid
      ..email = actorEmail
      ..name = 'T9 P3 Admin'
      ..role = 'Admin'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.users.put(actor);
    });
  }

  Future<void> seedSalesman({required int allocatedQuantity}) async {
    final now = DateTime.now();
    final salesman = UserEntity()
      ..id = salesmanUid
      ..email = '$salesmanUid@test.local'
      ..name = 'T9 P3 Salesman'
      ..role = 'Salesman'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    if (allocatedQuantity > 0) {
      salesman.setAllocatedStock({
        productId: AllocatedStockItem(
          productId: productId,
          name: 'T9 P3 Product',
          quantity: allocatedQuantity,
          price: 30,
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

  Future<void> seedReturnEntity({
    required String returnId,
    required String returnType,
    required double quantity,
    String? disposition,
    String? originalSaleId,
  }) async {
    final now = DateTime.now();
    final entity = ReturnEntity()
      ..id = returnId
      ..returnType = returnType
      ..salesmanId = salesmanUid
      ..salesmanName = 'T9 P3 Salesman'
      ..items = [
        ReturnItemEntity()
          ..productId = productId
          ..name = 'T9 P3 Product'
          ..quantity = quantity
          ..unit = 'pcs'
          ..price = 30,
      ]
      ..reason = 'test'
      ..status = 'pending'
      ..disposition = disposition
      ..createdAt = now
      ..updatedAt = now
      ..originalSaleId = originalSaleId
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.returns.put(entity);
    });
  }

  Future<void> seedOriginalSaleCommand({
    required String saleId,
    required int quantity,
  }) async {
    await inventoryEngine.applyCommand(
      InventoryCommand.saleComplete(
        saleId: saleId,
        salesmanUid: salesmanUid,
        items: [
          InventoryCommandItem(
            productId: productId,
            quantityBase: quantity.toDouble(),
          ),
        ],
        actorUid: salesmanUid,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> prepareFoundation({
    required double warehouseStock,
    required int salesmanAllocated,
  }) async {
    await seedProduct(stock: warehouseStock);
    await seedAdminActor();
    await seedSalesman(allocatedQuantity: salesmanAllocated);
    await projectionService.ensureCanonicalFoundation();
    await IdentityRevalidationState.markValidated(uid: actorUid);
  }

  Future<double> balanceFor(String locationId) async {
    final balance = await projectionService.getBalance(
      locationId: locationId,
      productId: productId,
    );
    return balance?.quantity ?? 0.0;
  }

  Future<int> movementCountForCommand(String commandId) {
    return dbService.stockMovements.where().findAll().then(
      (items) => items.where((item) => item.commandId == commandId).length,
    );
  }

  Future<int> salesmanAllocatedQuantity() async {
    final user = await dbService.users.getById(salesmanUid);
    return user?.getAllocatedStock()[productId]?.quantity ?? 0;
  }

  Map<String, dynamic> remoteReturnPayload({
    required String returnId,
    required String returnType,
    required double quantity,
    String? disposition,
    String? originalSaleId,
    String status = 'pending',
  }) {
    final nowIso = DateTime.now().toIso8601String();
    return <String, dynamic>{
      'id': returnId,
      'returnType': returnType,
      'salesmanId': salesmanUid,
      'salesmanName': 'T9 P3 Salesman',
      'items': [
        <String, dynamic>{
          'productId': productId,
          'name': 'T9 P3 Product',
          'quantity': quantity,
          'unit': 'pcs',
          'price': 30.0,
        },
      ],
      'reason': 'test',
      'status': status,
      'createdAt': nowIso,
      'updatedAt': nowIso,
      if (disposition != null) 'disposition': disposition,
      if (originalSaleId != null) 'originalSaleId': originalSaleId,
    };
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(_FakeDocumentReference());

    tempDir = await Directory.systemTemp.createTemp('t9_p3_returns_service_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);
    projectionService = InventoryProjectionService(dbService);
    inventoryEngine = InventoryMovementEngine(dbService, projectionService);
    inventoryService = InventoryService(FirebaseServices(), dbService);
    customersService = CustomersService(FirebaseServices(), dbService);
    salesService = SalesService(
      FirebaseServices(),
      dbService,
      inventoryService,
    );
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    await NotificationService().dispose();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await IdentityRevalidationState.clear(reason: 't9_p3_setup');
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.returns.clear();
      await dbService.sales.clear();
      await dbService.customers.clear();
      await dbService.stockBalances.clear();
      await dbService.inventoryLocations.clear();
      await dbService.inventoryCommands.clear();
      await dbService.stockMovements.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
      await dbService.departmentMasters.clear();
      await dbService.departmentStocks.clear();
    });

    firebaseAuth = _MockFirebaseAuth();
    firebaseUser = _MockFirebaseUser();
    when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn(actorUid);
    when(() => firebaseUser.email).thenReturn(actorEmail);

    localReturnsService = _AuthOverrideReturnsService(
      FirebaseServices(),
      dbService,
      inventoryService,
      customersService,
      salesService,
      firebaseAuth,
    );
  });

  tearDown(() async {
    if (_shouldSkipDbTests) return;
    await NotificationService().dispose();
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

  group('T9-P3 returns_service migration', () {
    test(
      'applySalesmanStockAdjustmentForTest restores salesman van balance for returned good stock and syncs allocatedStock mirror',
      () async {
        const saleId = 'sale-t9-p3-good';
        const returnId = 'return-t9-p3-good';

        await prepareFoundation(warehouseStock: 10, salesmanAllocated: 5);
        await seedOriginalSaleCommand(saleId: saleId, quantity: 2);
        await seedReturnEntity(
          returnId: returnId,
          returnType: 'sales_return',
          quantity: 2,
          disposition: 'Good Stock',
          originalSaleId: saleId,
        );

        expect(await balanceFor(salesmanLocationId), 3);
        expect(await balanceFor(virtualSoldLocationId), 2);

        await localReturnsService.applySalesmanStockAdjustmentForTest(
          salesmanId: salesmanUid,
          productId: productId,
          quantity: 2,
          reason: 'Customer Return: Good Stock',
          referenceId: returnId,
          referenceType: 'sales_return',
        );

        expect(await balanceFor(salesmanLocationId), 5);
        expect(await balanceFor(virtualSoldLocationId), 0);
        expect(await salesmanAllocatedQuantity(), 5);
        expect(await movementCountForCommand('reversal:sale:$saleId'), 1);

        final reversalMovements =
            (await dbService.stockMovements.where().findAll())
                .where(
                  (movement) => movement.commandId == 'reversal:sale:$saleId',
                )
                .toList(growable: false);
        final reversalMovement = reversalMovements.isEmpty
            ? null
            : reversalMovements.first;
        expect(reversalMovement?.isReversal, isTrue);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'performSync approval restores warehouse stock for stock return and creates movement row',
      () async {
        const returnId = 'return-t9-p3-stock-remote';
        final harness = _BatchRemoteHarness();
        final returnsService = _AuthOverrideReturnsService(
          FirebaseServices(),
          dbService,
          inventoryService,
          customersService,
          salesService,
          firebaseAuth,
          firestoreOverride: harness.firestore,
        );
        final payload = remoteReturnPayload(
          returnId: returnId,
          returnType: 'stock_return',
          quantity: 2,
        );

        await prepareFoundation(warehouseStock: 10, salesmanAllocated: 4);
        harness.seedDoc(returnsCollection, returnId, payload);

        await returnsService.performSync('approve', returnsCollection, {
          'id': returnId,
          'approverId': actorUid,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        expect(await balanceFor(warehouseLocationId), 12);
        expect(await balanceFor(salesmanLocationId), 2);
        expect(
          await movementCountForCommand(
            'transfer:$salesmanLocationId:$warehouseLocationId:$returnId:$productId',
          ),
          1,
        );
        expect(
          harness.readDoc(returnsCollection, returnId)?['status'],
          'approved',
        );
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'performSync approval restores salesman van balance for good-stock sales return',
      () async {
        const saleId = 'sale-t9-p3-remote-good';
        const returnId = 'return-t9-p3-remote-good';
        final harness = _BatchRemoteHarness();
        final returnsService = _AuthOverrideReturnsService(
          FirebaseServices(),
          dbService,
          inventoryService,
          customersService,
          salesService,
          firebaseAuth,
          firestoreOverride: harness.firestore,
        );

        await prepareFoundation(warehouseStock: 10, salesmanAllocated: 5);
        await seedOriginalSaleCommand(saleId: saleId, quantity: 2);

        harness.seedDoc(
          returnsCollection,
          returnId,
          remoteReturnPayload(
            returnId: returnId,
            returnType: 'sales_return',
            quantity: 2,
            disposition: 'Good Stock',
            originalSaleId: saleId,
          ),
        );
        harness.seedDoc('sales', saleId, <String, dynamic>{
          'id': saleId,
          'items': [
            <String, dynamic>{'productId': productId, 'returnedQuantity': 0},
          ],
        });

        expect(await balanceFor(salesmanLocationId), 3);

        await returnsService.performSync('approve', returnsCollection, {
          'id': returnId,
          'approverId': actorUid,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        expect(await balanceFor(salesmanLocationId), 5);
        expect(await salesmanAllocatedQuantity(), 5);
        expect(await movementCountForCommand('reversal:sale:$saleId'), 1);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'replay same returnId applies zero extra stock change',
      () async {
        const returnId = 'return-t9-p3-replay';
        final harness = _BatchRemoteHarness();
        final returnsService = _AuthOverrideReturnsService(
          FirebaseServices(),
          dbService,
          inventoryService,
          customersService,
          salesService,
          firebaseAuth,
          firestoreOverride: harness.firestore,
        );

        await prepareFoundation(warehouseStock: 10, salesmanAllocated: 4);
        harness.seedDoc(
          returnsCollection,
          returnId,
          remoteReturnPayload(
            returnId: returnId,
            returnType: 'stock_return',
            quantity: 2,
          ),
        );

        final syncPayload = <String, dynamic>{
          'id': returnId,
          'approverId': actorUid,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        await returnsService.performSync(
          'approve',
          returnsCollection,
          syncPayload,
        );
        final firstWarehouse = await balanceFor(warehouseLocationId);
        final firstSalesman = await balanceFor(salesmanLocationId);
        final firstMovementCount = await movementCountForCommand(
          'transfer:$salesmanLocationId:$warehouseLocationId:$returnId:$productId',
        );

        await returnsService.performSync(
          'approve',
          returnsCollection,
          syncPayload,
        );

        expect(await balanceFor(warehouseLocationId), firstWarehouse);
        expect(await balanceFor(salesmanLocationId), firstSalesman);
        expect(
          await movementCountForCommand(
            'transfer:$salesmanLocationId:$warehouseLocationId:$returnId:$productId',
          ),
          firstMovementCount,
        );
      },
      skip: _dbSkipReason ?? false,
    );
  });
}
