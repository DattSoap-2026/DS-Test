// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/providers/sales_remote_provider.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/identity_revalidation_state.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
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

class _AuthOverrideSalesService extends SalesService {
  _AuthOverrideSalesService(
    super.firebase,
    super.dbService,
    super.inventoryService,
    this._authOverride, {
    FirebaseFirestore? firestoreOverride,
  }) : _firestoreOverride = firestoreOverride;

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

  final Map<String, Map<String, dynamic>> _docs = <String, Map<String, dynamic>>{};
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
      final current = Map<String, dynamic>.from(_docs[key] ?? <String, dynamic>{});
      current.addAll(updates);
      _docs[key] = current;
    });
    when(
      () => batch.set<Map<String, dynamic>>(any(), any()),
    ).thenAnswer((invocation) {
      final ref =
          invocation.positionalArguments[0]
              as DocumentReference<Map<String, dynamic>>;
      final data = Map<String, dynamic>.from(
        invocation.positionalArguments[1] as Map,
      );
      _writeDoc(ref, data, merge: false);
    });
    when(
      () => batch.set<Map<String, dynamic>>(any(), any(), any()),
    ).thenAnswer((invocation) {
      final ref =
          invocation.positionalArguments[0]
              as DocumentReference<Map<String, dynamic>>;
      final data = Map<String, dynamic>.from(
        invocation.positionalArguments[1] as Map,
      );
      _writeDoc(ref, data, merge: true);
    });
  }

  void seedDoc(String collection, String id, Map<String, dynamic> data) {
    final key = '$collection/$id';
    _docs[key] = Map<String, dynamic>.from(data);
    _doc(collection, id);
  }

  _MockDocumentReference doc(String collection, String id) => _doc(collection, id);

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
    when(() => snapshot.data()).thenReturn(
      data == null ? null : Map<String, dynamic>.from(data),
    );
    return snapshot;
  }

  String _keyForRef(DocumentReference<Map<String, dynamic>> ref) {
    return _refs.entries
        .firstWhere((entry) => identical(entry.value, ref))
        .key;
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

  const actorUid = 'actor-t9-p2';
  const actorEmail = 'actor-t9-p2@test.local';
  const productId = 'prod-t9-p2-1';
  const warehouseLocationId = InventoryProjectionService.warehouseMainLocationId;
  const virtualSoldLocationId = InventoryProjectionService.virtualSoldLocationId;

  late DatabaseService dbService;
  late Directory tempDir;
  late InventoryService inventoryService;
  late InventoryProjectionService projectionService;
  late _MockFirebaseAuth firebaseAuth;
  late _MockFirebaseUser firebaseUser;
  late SalesService localSalesService;

  Future<void> seedProduct({required double stock}) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = productId
      ..name = 'T9 P2 Product'
      ..sku = 'SKU-$productId'
      ..itemType = 'finished_good'
      ..type = 'finished_good'
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = 'pcs'
      ..price = 25
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  Future<void> seedActor({
    required String role,
    int allocatedQuantity = 0,
  }) async {
    final now = DateTime.now();
    final actor = UserEntity()
      ..id = actorUid
      ..email = actorEmail
      ..name = 'T9 P2 Actor'
      ..role = role
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    if (allocatedQuantity > 0) {
      actor.setAllocatedStock({
        productId: AllocatedStockItem(
          productId: productId,
          name: 'T9 P2 Product',
          quantity: allocatedQuantity,
          price: 25,
          baseUnit: 'pcs',
          conversionFactor: 1,
          freeQuantity: 0,
        ),
      });
    }
    await dbService.db.writeTxn(() async {
      await dbService.users.put(actor);
    });
  }

  Future<double> balanceFor(String locationId) async {
    final balance = await projectionService.getBalance(
      locationId: locationId,
      productId: productId,
    );
    return balance?.quantity ?? 0.0;
  }

  Future<void> prepareLocalService({
    required String role,
    required double warehouseStock,
    int allocatedQuantity = 0,
  }) async {
    await seedProduct(stock: warehouseStock);
    await seedActor(role: role, allocatedQuantity: allocatedQuantity);
    await IdentityRevalidationState.markValidated(uid: actorUid);
    localSalesService = _AuthOverrideSalesService(
      FirebaseServices(),
      dbService,
      inventoryService,
      firebaseAuth,
    );
  }

  Map<String, dynamic> salePayload({
    required String saleId,
    required String recipientType,
    required int quantity,
    String salesmanId = actorUid,
    String recipientId = 'cust-1',
    String recipientName = 'Customer One',
    double totalAmount = 100,
  }) {
    return <String, dynamic>{
      'id': saleId,
      'recipientType': recipientType,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'salesmanId': salesmanId,
      'salesmanName': 'Remote Salesman',
      'discountPercentage': 0.0,
      'additionalDiscountPercentage': 0.0,
      'gstType': 'None',
      'gstPercentage': 0.0,
      'status': 'completed',
      'totalAmount': totalAmount,
      'items': [
        <String, dynamic>{
          'productId': productId,
          'name': 'T9 P2 Product',
          'quantity': quantity,
          'finalBaseQuantity': quantity,
          'price': 25.0,
          'baseUnit': 'pcs',
          'discount': 0.0,
          'isFree': false,
        },
      ],
    };
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(_FakeDocumentReference());

    tempDir = await Directory.systemTemp.createTemp('t9_p2_sales_service_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);
    projectionService = InventoryProjectionService(dbService);
    inventoryService = InventoryService(FirebaseServices(), dbService);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await IdentityRevalidationState.clear(reason: 't9_p2_setup');
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.sales.clear();
      await dbService.stockBalances.clear();
      await dbService.inventoryLocations.clear();
      await dbService.inventoryCommands.clear();
      await dbService.stockMovements.clear();
      await dbService.syncQueue.clear();
      await dbService.stockLedger.clear();
      await dbService.customers.clear();
    });

    firebaseAuth = _MockFirebaseAuth();
    firebaseUser = _MockFirebaseUser();
    when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn(actorUid);
    when(() => firebaseUser.email).thenReturn(actorEmail);
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

  group('T9-P2 sales migration', () {
    test(
      'sale_complete from salesman van updates balance, movement, and allocatedStock mirror',
      () async {
        await prepareLocalService(
          role: 'Dispatch Manager',
          warehouseStock: 100,
          allocatedQuantity: 20,
        );

        final saleId = await localSalesService.createSale(
          recipientType: 'customer',
          recipientId: 'cust-local-1',
          recipientName: 'Customer Local',
          items: [
            SaleItemForUI(
              productId: productId,
              name: 'T9 P2 Product',
              quantity: 5,
              price: 25,
              baseUnit: 'pcs',
              stock: 100,
            ),
          ],
          discountPercentage: 0,
        );

        expect(
          await balanceFor(InventoryProjectionService.salesmanLocationIdForUid(actorUid)),
          15,
        );
        expect(await balanceFor(virtualSoldLocationId), 5);

        final actor = await dbService.users.getById(actorUid);
        expect(actor?.getAllocatedStock()[productId]?.quantity, 15);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        expect(movements.single.commandId, 'sale:$saleId');
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'sale_complete for dealer decrements warehouse and keeps product mirror in sync',
      () async {
        await prepareLocalService(
          role: 'Dispatch Manager',
          warehouseStock: 100,
        );

        final saleId = await localSalesService.createSale(
          recipientType: 'dealer',
          recipientId: 'dealer-local-1',
          recipientName: 'Dealer Local',
          items: [
            SaleItemForUI(
              productId: productId,
              name: 'T9 P2 Product',
              quantity: 7,
              price: 25,
              baseUnit: 'pcs',
              stock: 100,
            ),
          ],
          discountPercentage: 0,
        );

        expect(await balanceFor(warehouseLocationId), 93);
        final product = await dbService.products.getById(productId);
        expect(product?.stock, 93);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        expect(movements.single.commandId, 'sale:$saleId');

        final ledgers = await dbService.stockLedger.where().findAll();
        expect(ledgers, hasLength(1));
        expect(ledgers.single.transactionType, 'SALE_OUT');
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'provider customer sale falls back to warehouse and creates movement rows',
      () async {
        await seedProduct(stock: 100);
        final harness = _BatchRemoteHarness()
          ..seedDoc('users', 'remote-salesman-1', <String, dynamic>{
            'role': 'salesman',
            'allocatedStock': <String, dynamic>{},
          })
          ..seedDoc('customers', 'cust-1', <String, dynamic>{'balance': 0});
        final provider = SalesRemoteProvider(
          harness.firestore,
          dbService: dbService,
        );

        await provider.performSyncAdd(
          salePayload(
            saleId: 'remote-customer-sale-1',
            recipientType: 'customer',
            quantity: 4,
            salesmanId: 'remote-salesman-1',
          ),
        );

        expect(await balanceFor(warehouseLocationId), 96);
        final product = await dbService.products.getById(productId);
        expect(product?.stock, 96);

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        expect(movements.single.commandId, 'sale:remote-customer-sale-1');
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'sale edit applies reversal first and then new sale_complete with correct net balance',
      () async {
        await prepareLocalService(
          role: 'Dispatch Manager',
          warehouseStock: 100,
        );

        final saleId = await localSalesService.createSale(
          recipientType: 'dealer',
          recipientId: 'dealer-edit-1',
          recipientName: 'Dealer Edit',
          items: [
            SaleItemForUI(
              productId: productId,
              name: 'T9 P2 Product',
              quantity: 6,
              price: 25,
              baseUnit: 'pcs',
              stock: 100,
            ),
          ],
          discountPercentage: 0,
        );

        await localSalesService.editSale(
          saleId: saleId,
          items: [
            SaleItemForUI(
              productId: productId,
              name: 'T9 P2 Product',
              quantity: 3,
              price: 25,
              baseUnit: 'pcs',
              stock: 100,
            ),
          ],
          discountPercentage: 0,
          editedBy: actorUid,
        );

        expect(await balanceFor(warehouseLocationId), 97);
        final commands = await dbService.inventoryCommands.where().findAll();
        expect(
          commands.map((command) => command.commandId).toList(),
          containsAll(<String>[
            'sale:$saleId',
            'reversal:sale:$saleId',
            'sale:$saleId:edit:1',
          ]),
        );

        final reversalMovements = (await dbService.stockMovements.where().findAll())
            .where((movement) => movement.commandId == 'reversal:sale:$saleId')
            .toList(growable: false);
        expect(reversalMovements, hasLength(1));
        expect(reversalMovements.single.isReversal, isTrue);
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'replay same saleId through provider is idempotent',
      () async {
        await seedProduct(stock: 100);
        final harness = _BatchRemoteHarness()
          ..seedDoc('users', 'remote-salesman-2', <String, dynamic>{
            'role': 'salesman',
            'allocatedStock': <String, dynamic>{},
          })
          ..seedDoc('customers', 'cust-1', <String, dynamic>{'balance': 0});
        final provider = SalesRemoteProvider(
          harness.firestore,
          dbService: dbService,
        );
        final payload = salePayload(
          saleId: 'remote-sale-idempotent-1',
          recipientType: 'customer',
          quantity: 5,
          salesmanId: 'remote-salesman-2',
        );

        await provider.performSyncAdd(payload);
        await provider.performSyncAdd(payload);

        expect(await balanceFor(warehouseLocationId), 95);
        final commands = await dbService.inventoryCommands.where().findAll();
        expect(commands, hasLength(1));
        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'performSyncAdd in sales_remote_provider delegates to engine without direct stock write batch updates',
      () async {
        await seedProduct(stock: 100);
        final harness = _BatchRemoteHarness()
          ..seedDoc('users', 'remote-salesman-3', <String, dynamic>{
            'role': 'salesman',
            'allocatedStock': <String, dynamic>{},
          })
          ..seedDoc('customers', 'cust-1', <String, dynamic>{'balance': 0});
        final provider = SalesRemoteProvider(
          harness.firestore,
          dbService: dbService,
        );
        final salesmanRef = harness.doc('users', 'remote-salesman-3');
        final productRef = harness.doc('products', productId);

        await provider.performSyncAdd(
          salePayload(
            saleId: 'remote-sale-no-stock-write-1',
            recipientType: 'customer',
            quantity: 2,
            salesmanId: 'remote-salesman-3',
          ),
        );

        final movements = await dbService.stockMovements.where().findAll();
        expect(movements, hasLength(1));
        verifyNever(() => harness.batch.update(salesmanRef, any()));
        verifyNever(() => harness.batch.update(productRef, any()));
      },
      skip: _dbSkipReason ?? false,
    );

    test(
      'performSyncEdit in sales_remote_provider applies reversal and reapply correctly',
      () async {
        await seedProduct(stock: 100);
        final harness = _BatchRemoteHarness()
          ..seedDoc('users', 'remote-salesman-4', <String, dynamic>{
            'role': 'salesman',
            'allocatedStock': <String, dynamic>{},
          })
          ..seedDoc('customers', 'cust-1', <String, dynamic>{'balance': 0});
        final provider = SalesRemoteProvider(
          harness.firestore,
          dbService: dbService,
        );

        await provider.performSyncAdd(
          salePayload(
            saleId: 'remote-edit-sale-1',
            recipientType: 'customer',
            quantity: 5,
            salesmanId: 'remote-salesman-4',
          ),
        );

        final editPayload = salePayload(
          saleId: 'remote-edit-sale-1',
          recipientType: 'customer',
          quantity: 2,
          salesmanId: 'remote-salesman-4',
          totalAmount: 50,
        )
          ..['oldTotalAmount'] = 100.0
          ..['totalDelta'] = -50.0
          ..['previousRecipientType'] = 'customer'
          ..['previousRecipientId'] = 'cust-1'
          ..['editedBy'] = actorUid
          ..['editedAt'] = '2026-03-08T10:00:00.000Z';

        await provider.performSyncEdit(editPayload);

        expect(await balanceFor(warehouseLocationId), 98);
        final commands = await dbService.inventoryCommands.where().findAll();
        expect(
          commands.map((command) => command.commandId).toList(),
          containsAll(<String>[
            'sale:remote-edit-sale-1',
            'reversal:sale:remote-edit-sale-1',
            'sale:remote-edit-sale-1:edit:1',
          ]),
        );
      },
      skip: _dbSkipReason ?? false,
    );
  });
}
