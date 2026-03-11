import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/category_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/product_type_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/master_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService dbService;
  late MasterDataService service;
  late Directory tempDir;

  setUpAll(() async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp(
      'master_data_hardening_test_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);
    service = MasterDataService(FirebaseServices(), dbService);
  });

  tearDown(() async {
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.categories.clear();
      await dbService.productTypes.clear();
      await dbService.units.clear();
      await dbService.syncQueue.clear();
    });
    service.invalidateCache();
  });

  tearDownAll(() async {
    await dbService.db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('offline fallback returns local product types when remote is unavailable', () async {
    final entity = ProductTypeEntity()
      ..id = 'ptype_1'
      ..name = 'Semi-Finished Good'
      ..description = 'semi'
      ..iconName = 'Package'
      ..color = '#4F46E5'
      ..tabs = <String>['Basic', 'Inventory']
      ..defaultUom = 'Pcs'
      ..defaultGst = 18
      ..skuPrefix = 'SFG'
      ..displayUnit = null
      ..createdAt = DateTime(2026, 1, 1).toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.productTypes.put(entity);
    });

    final items = await service.getProductTypes();
    expect(items, isNotEmpty);
    expect(items.first.name, 'Semi-Finished Good');
  });

  test('deleteProductType prevents delete when products reference the type', () async {
    final type = ProductTypeEntity()
      ..id = 'ptype_2'
      ..name = 'Raw Material'
      ..description = 'raw'
      ..iconName = 'Package'
      ..color = '#10B981'
      ..tabs = <String>['Basic']
      ..defaultUom = 'Kg'
      ..defaultGst = 18
      ..skuPrefix = 'RM'
      ..createdAt = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    final product = ProductEntity()
      ..id = 'prod_1'
      ..name = 'Soda Ash'
      ..sku = 'SKU-RAW-1'
      ..itemType = 'Raw Material'
      ..type = 'raw'
      ..category = 'Chemicals'
      ..baseUnit = 'Kg'
      ..status = 'active'
      ..updatedAt = DateTime.now()
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.productTypes.put(type);
      await dbService.products.put(product);
    });

    final deleted = await service.deleteProductType(type.id);
    expect(deleted, isFalse);

    final persisted = await dbService.productTypes
        .filter()
        .idEqualTo(type.id)
        .findFirst();
    expect(persisted, isNotNull);
    expect(persisted!.isDeleted, isFalse);
  });

  test('rename propagation keeps local products consistent for category rename', () async {
    final category = CategoryEntity()
      ..id = 'cat_1'
      ..name = 'Old Category'
      ..itemType = 'Old Type'
      ..createdAt = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    final product = ProductEntity()
      ..id = 'prod_2'
      ..name = 'Base Item'
      ..sku = 'SKU-CAT-1'
      ..itemType = 'Old Type'
      ..type = 'raw'
      ..category = 'Old Category'
      ..baseUnit = 'Pcs'
      ..status = 'active'
      ..updatedAt = DateTime.now()
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.categories.put(category);
      await dbService.products.put(product);
    });

    final updated = await service.updateCategory(
      'cat_1',
      'New Category',
      'New Type',
    );
    expect(updated, isTrue);

    final localProduct = await dbService.products
        .filter()
        .idEqualTo('prod_2')
        .findFirst();
    expect(localProduct, isNotNull);
    expect(localProduct!.category, 'New Category');
    expect(localProduct.itemType, 'New Type');
    expect(localProduct.syncStatus, SyncStatus.pending);
  });

  test('rename propagation keeps local products and categories consistent for product type rename', () async {
    final type = ProductTypeEntity()
      ..id = 'ptype_rename'
      ..name = 'Old Type'
      ..description = 'legacy'
      ..iconName = 'Package'
      ..color = '#14B8A6'
      ..tabs = <String>['Basic']
      ..defaultUom = 'Pcs'
      ..defaultGst = 18
      ..skuPrefix = 'OLD'
      ..createdAt = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    final category = CategoryEntity()
      ..id = 'cat_rename'
      ..name = 'Category A'
      ..itemType = 'Old Type'
      ..createdAt = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    final product = ProductEntity()
      ..id = 'prod_rename'
      ..name = 'Rename Item'
      ..sku = 'SKU-RENAME-1'
      ..itemType = 'Old Type'
      ..type = 'raw'
      ..category = 'Category A'
      ..baseUnit = 'Pcs'
      ..status = 'active'
      ..updatedAt = DateTime.now()
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.productTypes.put(type);
      await dbService.categories.put(category);
      await dbService.products.put(product);
    });

    final updated = await service.updateProductType(type.id, {'name': 'New Type'});
    expect(updated, isTrue);

    final localProduct = await dbService.products
        .filter()
        .idEqualTo('prod_rename')
        .findFirst();
    final localCategory = await dbService.categories
        .filter()
        .idEqualTo('cat_rename')
        .findFirst();

    expect(localProduct, isNotNull);
    expect(localProduct!.itemType, 'New Type');
    expect(localProduct.syncStatus, SyncStatus.pending);

    expect(localCategory, isNotNull);
    expect(localCategory!.itemType, 'New Type');
    expect(localCategory.syncStatus, SyncStatus.pending);
  });

  test('addProductType rejects duplicate active type names', () async {
    final firstId = await service.addProductType(<String, dynamic>{
      'name': 'Finished Good',
      'description': 'Finished product',
      'iconName': 'Package',
      'color': '#6366F1',
      'tabs': <String>['Basic'],
      'defaultUom': 'Pcs',
      'defaultGst': 18.0,
      'skuPrefix': 'FG',
    });
    expect(firstId, isNotNull);

    final secondId = await service.addProductType(<String, dynamic>{
      'name': 'Finished Good',
      'description': 'Duplicate',
    });
    expect(secondId, isNull);

    final count = await dbService.productTypes
        .filter()
        .nameEqualTo('Finished Good')
        .isDeletedEqualTo(false)
        .count();
    expect(count, 1);
  });

  test('read-only UI guards are present for mutating master data actions', () async {
    final systemMastersSource = await File(
      'lib/screens/management/system_masters_screen.dart',
    ).readAsString();
    expect(
      systemMastersSource.contains(
        "onPressed: widget.isReadOnly ? null : _showAddUnitDialog",
      ),
      isTrue,
    );
    expect(
      systemMastersSource.contains("if (widget.isReadOnly) {"),
      isTrue,
    );
    expect(
      systemMastersSource.contains("_showReadOnlyWarning();"),
      isTrue,
    );

    final masterDataSource = await File(
      'lib/screens/management/master_data_screen.dart',
    ).readAsString();
    expect(
      masterDataSource.contains("isReadOnly: isReadOnly('system')"),
      isTrue,
    );
  });
}
