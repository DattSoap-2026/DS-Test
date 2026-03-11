// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_movement_engine.dart';
import 'package:flutter_app/services/opening_stock_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
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

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockInventoryMovementEngine extends Mock implements InventoryMovementEngine {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService dbService;
  late Directory tempDir;
  late _MockInventoryMovementEngine inventoryMovementEngine;
  late OpeningStockService openingStockService;
  late _MockFirestore firestore;
  late _MockCollectionReference settingsCollection;
  late _MockDocumentReference settingsDoc;
  late _MockDocumentSnapshot settingsSnapshot;

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
      ..itemType = 'raw_material'
      ..type = 'raw_material'
      ..category = 'Raw Material'
      ..stock = stock
      ..baseUnit = 'KG'
      ..price = 10
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  void stubUnlockedSettings() {
    when(
      () => firestore.collection(CollectionRegistry.settings),
    ).thenReturn(settingsCollection);
    when(() => settingsCollection.doc('general')).thenReturn(settingsDoc);
    when(() => settingsDoc.get()).thenAnswer((_) async => settingsSnapshot);
    when(() => settingsSnapshot.exists).thenReturn(false);
    when(() => settingsSnapshot.data()).thenReturn(null);
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp(
      't4_opening_stock_set_balance_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.openingStockEntries.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
    });

    firestore = _MockFirestore();
    inventoryMovementEngine = _MockInventoryMovementEngine();
    settingsCollection = _MockCollectionReference();
    settingsDoc = _MockDocumentReference();
    settingsSnapshot = _MockDocumentSnapshot();
    stubUnlockedSettings();
    openingStockService = OpeningStockService(
      dbService,
      inventoryMovementEngine,
      firestore,
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

  test(
    'opening stock overwrite keeps a single record and final balance equals latest quantity',
    () async {
      await seedProduct(id: 'prod-opening-1', name: 'Acid Oil', stock: 0);

      await openingStockService.createOpeningStock(
        productId: 'prod-opening-1',
        productType: 'Raw Material',
        warehouseId: 'Main',
        quantity: 100,
        unit: 'KG',
        userId: 'admin-1',
      );

      await openingStockService.createOpeningStock(
        productId: 'prod-opening-1',
        productType: 'Raw Material',
        warehouseId: 'Main',
        quantity: 150,
        unit: 'KG',
        userId: 'admin-1',
      );

      final product = await dbService.products.getById('prod-opening-1');
      expect(product, isNotNull);
      expect(product!.stock, 150);

      final entries = await dbService.openingStockEntries.where().findAll();
      expect(entries, hasLength(1));
      expect(entries.first.quantity, 150);
      expect(entries.first.warehouseId, 'Main');

      final openingLedgers = (await dbService.stockLedger.where().findAll())
          .where(
            (entry) =>
                entry.productId == 'prod-opening-1' &&
                entry.transactionType == 'OPENING',
          )
          .toList();
      expect(openingLedgers, hasLength(1));
      expect(openingLedgers.first.quantityChange, 150);
      expect(openingLedgers.first.runningBalance, 150);
      expect(openingLedgers.first.referenceId, entries.first.id);

      final queueItems = await dbService.syncQueue.where().findAll();
      expect(
        queueItems
            .where(
              (entry) =>
                  entry.collection == CollectionRegistry.openingStockEntries,
            )
            .length,
        1,
      );
      expect(
        queueItems
            .where(
              (entry) => entry.collection == CollectionRegistry.stockLedger,
            )
            .length,
        1,
      );
      expect(
        queueItems
            .where(
              (entry) =>
                  entry.collection == CollectionRegistry.inventoryCommands,
            )
            .length,
        2,
      );

      final openingQueue = queueItems.firstWhere(
        (entry) => entry.collection == CollectionRegistry.openingStockEntries,
      );
      final ledgerQueue = queueItems.firstWhere(
        (entry) => entry.collection == CollectionRegistry.stockLedger,
      );

      final openingPayload = OutboxCodec.decode(
        openingQueue.dataJson,
        fallbackQueuedAt: openingQueue.createdAt,
      ).payload;
      final ledgerPayload = OutboxCodec.decode(
        ledgerQueue.dataJson,
        fallbackQueuedAt: ledgerQueue.createdAt,
      ).payload;

      expect(openingPayload['quantity'], 150.0);
      expect(ledgerPayload['quantityChange'], 150.0);
      expect(ledgerPayload['referenceId'], entries.first.id);
    },
    skip: _dbSkipReason ?? false,
  );
}
