// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sale_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/identity_revalidation_state.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/sales_service.dart';
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

class _AuthOverrideSalesService extends SalesService {
  _AuthOverrideSalesService(
    super.firebase,
    super.dbService,
    super.inventoryService,
    this._authOverride,
  );

  final FirebaseAuth _authOverride;

  @override
  FirebaseAuth? get auth => _authOverride;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService dbService;
  late Directory tempDir;
  late InventoryService inventoryService;
  late SalesService salesService;
  late _MockFirebaseAuth firebaseAuth;
  late _MockFirebaseUser firebaseUser;

  const localUserId = 'sale3@dattsoap.com';
  const firebaseUid = 'firebase-uid-sale3';

  Future<void> seedProduct({
    required String id,
    required String name,
    required double stock,
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

  Future<void> seedSalesman({int allocatedQuantity = 0}) async {
    final now = DateTime.now();
    final user = UserEntity()
      ..id = localUserId
      ..email = localUserId
      ..name = 'Sale Three'
      ..role = 'Salesman'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    if (allocatedQuantity > 0) {
      user.setAllocatedStock({
        'prod-uid-identity-1': AllocatedStockItem(
          productId: 'prod-uid-identity-1',
          name: 'UID Routed Product',
          quantity: allocatedQuantity,
          price: 25,
          baseUnit: 'pcs',
          conversionFactor: 1,
          freeQuantity: 0,
        ),
      });
    }
    await dbService.db.writeTxn(() async {
      await dbService.users.put(user);
    });
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp(
      't5_salesman_uid_identity_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final firebase = FirebaseServices();
    inventoryService = InventoryService(firebase, dbService);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.sales.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
    });

    firebaseAuth = _MockFirebaseAuth();
    firebaseUser = _MockFirebaseUser();
    when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn(firebaseUid);
    when(() => firebaseUser.email).thenReturn(localUserId);

    salesService = _AuthOverrideSalesService(
      FirebaseServices(),
      dbService,
      inventoryService,
      firebaseAuth,
    );

    await IdentityRevalidationState.clear(reason: 'test_setup');
    await IdentityRevalidationState.markValidated(uid: firebaseUid);
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

  test(
    'sale writes Firebase UID to local sale and queue payload when AppUser.id differs',
    () async {
      await seedSalesman();
      await seedProduct(
        id: 'prod-uid-identity-1',
        name: 'UID Routed Product',
        stock: 100,
      );

      final saleId = await salesService.createSale(
        recipientType: 'dealer',
        recipientId: 'dealer-uid-1',
        recipientName: 'Dealer UID One',
        items: [
          SaleItemForUI(
            productId: 'prod-uid-identity-1',
            name: 'UID Routed Product',
            quantity: 5,
            price: 25,
            baseUnit: 'pcs',
            stock: 100,
          ),
        ],
        discountPercentage: 0,
      );

      final sales = await dbService.sales.where().findAll();
      expect(sales, hasLength(1));
      expect(sales.single.id, saleId);
      expect(sales.single.salesmanId, firebaseUid);
      expect(sales.single.salesmanId, isNot(localUserId));

      final ledgerEntries = await dbService.stockLedger.where().findAll();
      expect(ledgerEntries, hasLength(1));
      expect(ledgerEntries.single.performedBy, firebaseUid);

      final queueItems = await dbService.syncQueue.where().findAll();
      final saleQueue = queueItems.firstWhere(
        (entry) => entry.collection == CollectionRegistry.sales,
      );
      final payload = OutboxCodec.decode(
        saleQueue.dataJson,
        fallbackQueuedAt: saleQueue.createdAt,
      ).payload;

      expect(payload['salesmanId'], firebaseUid);
      expect(payload['salesmanId'], isNot(localUserId));
      expect(
        (payload['accountingDimensions'] as Map<String, dynamic>)['salesmanId'],
        firebaseUid,
      );
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'customer sale and edit reuse legacy local salesman profile via auth email fallback',
    () async {
      await seedSalesman(allocatedQuantity: 20);
      await seedProduct(
        id: 'prod-uid-identity-1',
        name: 'UID Routed Product',
        stock: 100,
      );

      final saleId = await salesService.createSale(
        recipientType: 'customer',
        recipientId: 'customer-uid-1',
        recipientName: 'Customer UID One',
        items: [
          SaleItemForUI(
            productId: 'prod-uid-identity-1',
            name: 'UID Routed Product',
            quantity: 5,
            price: 25,
            baseUnit: 'pcs',
            stock: 100,
          ),
        ],
        discountPercentage: 0,
      );

      final createdUser = await dbService.users
          .filter()
          .idEqualTo(localUserId)
          .findFirst();
      expect(createdUser, isNotNull);
      expect(
        createdUser!.getAllocatedStock()['prod-uid-identity-1']?.quantity,
        15,
      );

      await salesService.editSale(
        saleId: saleId,
        recipientId: 'customer-uid-1',
        recipientName: 'Customer UID One',
        items: [
          SaleItemForUI(
            productId: 'prod-uid-identity-1',
            name: 'UID Routed Product',
            quantity: 3,
            price: 25,
            baseUnit: 'pcs',
            stock: 100,
          ),
        ],
        discountPercentage: 0,
        editedBy: firebaseUid,
      );

      final editedUser = await dbService.users
          .filter()
          .idEqualTo(localUserId)
          .findFirst();
      expect(editedUser, isNotNull);
      expect(
        editedUser!.getAllocatedStock()['prod-uid-identity-1']?.quantity,
        17,
      );

      final sale = await dbService.sales.filter().idEqualTo(saleId).findFirst();
      expect(sale, isNotNull);
      expect(sale!.salesmanId, firebaseUid);
      expect(sale.items, hasLength(1));
      expect(sale.items!.single.quantity, 3);
    },
    skip: _dbSkipReason ?? false,
  );
}
