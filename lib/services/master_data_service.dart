import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';
import '../core/sync/collection_registry.dart';
import '../core/sync/sync_queue_service.dart';
import '../core/sync/sync_service.dart';
import 'database_service.dart';
import '../data/local/entities/unit_entity.dart';
import '../data/local/entities/category_entity.dart';
import '../data/local/entities/product_type_entity.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/product_entity.dart';
import 'offline_first_service.dart';
import '../core/firebase/firebase_config.dart';
import 'delegates/firestore_query_delegate.dart';
import 'delegates/master_data_remote_write_delegate.dart';

// Cache structure
class _CacheEntry<T> {
  final T data;
  final int timestamp;
  _CacheEntry(this.data, this.timestamp);
}

class ProductCategory {
  final String id;
  final String name;
  final String itemType;
  final String? createdAt;

  ProductCategory({
    required this.id,
    required this.name,
    required this.itemType,
    this.createdAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      itemType: json['itemType'] as String,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class DynamicProductType {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color;
  final List<String> tabs;
  final String defaultUom;
  final double defaultGst;
  final String skuPrefix;
  final String? displayUnit;
  final String? createdAt;

  DynamicProductType({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    required this.tabs,
    required this.defaultUom,
    required this.defaultGst,
    required this.skuPrefix,
    this.displayUnit,
    this.createdAt,
  });

  factory DynamicProductType.fromJson(Map<String, dynamic> json) {
    return DynamicProductType(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'Package',
      color: json['color'] as String? ?? 'indigo-500',
      tabs: (json['tabs'] as List?)?.map((e) => e as String).toList() ?? [],
      defaultUom: json['defaultUom'] as String? ?? 'Pcs',
      defaultGst: (json['defaultGst'] as num?)?.toDouble() ?? 18.0,
      skuPrefix: json['skuPrefix'] as String? ?? 'PRD',
      displayUnit: json['displayUnit'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class MasterDataService extends OfflineFirstService {
  MasterDataService(FirebaseServices firebase, [DatabaseService? dbService])
    : super(firebase, dbService ?? DatabaseService.instance);

  @override
  String get localStorageKey => 'local_master_data';

  @override
  bool get useIsar => true;

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final documentId = collection == 'units'
        ? data['name']?.toString().trim() ?? ''
        : data['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) return;

    final payload = action == 'delete'
        ? <String, dynamic>{
            ...data,
            'id': data['id'] ?? documentId,
            if (collection == 'units') 'name': data['name'],
            'isDeleted': true,
            'updatedAt': data['updatedAt'] ?? DateTime.now().toIso8601String(),
          }
        : data;

    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
    await SyncService.instance.trySync();
  }

  // Cache storage
  final Map<String, _CacheEntry> _cache = {};
  static const int cacheTtl = 10 * 60 * 1000; // 10 minutes

  T? _getCached<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().millisecondsSinceEpoch - entry.timestamp > cacheTtl) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  void _setCache(String key, dynamic data) {
    _cache[key] = _CacheEntry(data, DateTime.now().millisecondsSinceEpoch);
  }

  void invalidateCache() {
    _cache.clear();
  }

  // Units of Measure
  Future<List<String>> getUnits() async {
    const key = 'units_all';
    final cached = _getCached<List<String>>(key);
    if (cached != null) return cached;

    try {
      // 1. Try ISAR first
      final entities = await dbService.units.where().sortByName().findAll();
      final activeEntities = entities.where((e) => !e.isDeleted).toList();
      if (activeEntities.isNotEmpty) {
        final result = activeEntities.map((e) => e.name).toList();
        _setCache(key, result);
        return result;
      }

      // 2. Local fallback & Firebase bootstrap
      List<String> remoteItems = [];
      final firestore = db;
      if (firestore != null) {
        try {
          final snapshot = await FirestoreQueryDelegate(firestore).getCollection(
            collection: 'units',
            orderBy: 'name',
          );
          remoteItems = snapshot.docs
              .where((doc) => doc.data()['isDeleted'] != true)
              .map((doc) => doc['name'] as String)
              .toList();

          // Save to ISAR
          if (remoteItems.isNotEmpty) {
            await dbService.db.writeTxn(() async {
              for (final name in remoteItems) {
                final entity = UnitEntity()
                  ..id =
                      name // Using name as ID for units as they are simple strings
                  ..name = name
                  ..createdAt = DateTime.now().toIso8601String()
                  ..isDeleted = false
                  ..syncStatus = SyncStatus.synced;
                await dbService.units.put(entity);
              }
            });
          }
        } catch (e) {
          developer.log(
            'Error bootstrapping units: $e',
            name: 'MasterDataService',
          );
        }
      }

      final Set<String> merged = {};
      merged.addAll(['Pcs', 'Kg', 'Ltr', 'Box', 'Ton', 'Bag', 'Batch']);
      merged.addAll(remoteItems);

      final resultList = merged.toList();
      resultList.sort();

      _setCache(key, resultList);
      return resultList;
    } catch (e) {
      handleError(e, 'getUnits');
      return ['Pcs', 'Kg', 'Ltr', 'Box', 'Ton', 'Bag', 'Batch'];
    }
  }

  Future<bool> addUnit(String name) async {
    try {
      developer.log('Adding unit: $name', name: 'MasterDataService.addUnit');

      // BUG #1 FIX: Duplicate name guard — prevent duplicate units
      final normalizedName = name.trim();
      if (normalizedName.isEmpty) throw Exception('Unit name cannot be empty');
      final existing = await dbService.units
          .filter()
          .nameEqualTo(normalizedName)
          .isDeletedEqualTo(false)
          .findFirst();
      if (existing != null) {
        throw Exception('Unit "$normalizedName" already exists');
      }

      // 1. Save to ISAR first
      final entity = UnitEntity()
        ..id = normalizedName
        ..name = normalizedName
        ..createdAt = DateTime.now().toIso8601String()
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.pending;

      await dbService.db.writeTxn(() async {
        await dbService.units.put(entity);
      });
      developer.log(
        'Unit saved to ISAR: $name',
        name: 'MasterDataService.addUnit',
      );

      // 2. Sync to Firebase
      // 2. Queue Sync
      await syncToFirebase('set', {
        'id': entity.id,
        'name': name,
        'createdAt': entity.createdAt,
        'isDeleted': false,
        'updatedAt': entity.updatedAt.toIso8601String(),
      }, collectionName: 'units');
      developer.log(
        'Unit queued for Firebase sync: $name',
        name: 'MasterDataService.addUnit',
      );

      invalidateCache();
      developer.log(
        'Unit added successfully: $name',
        name: 'MasterDataService.addUnit',
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Error adding unit: $name',
        name: 'MasterDataService.addUnit',
        error: e,
        stackTrace: stackTrace,
      );
      handleError(e, 'addUnit');
      return false;
    }
  }

  Future<bool> deleteUnit(String name) async {
    try {
      final now = DateTime.now();
      UnitEntity? entity;

      // BUG #2 FIX: In-use protection — cannot delete a unit used by products
      final inUseCount = await dbService.products
          .filter()
          .baseUnitEqualTo(name)
          .isDeletedEqualTo(false)
          .count();
      if (inUseCount > 0) {
        throw Exception(
          'Cannot delete unit "$name" — it is used by $inUseCount product(s). '
          'Update those products first.',
        );
      }

      // 1. Soft-delete in ISAR
      await dbService.db.writeTxn(() async {
        entity = await dbService.units.filter().nameEqualTo(name).findFirst();
        if (entity == null) return;
        entity!
          ..isDeleted = true
          ..syncStatus = SyncStatus.pending
          ..updatedAt = now;
        await dbService.units.put(entity!);
      });

      if (entity == null) {
        return true;
      }

      // 2. Queue Sync
      await syncToFirebase('delete', {
        'id': entity!.id,
        'name': name,
        'isDeleted': true,
        'updatedAt': now.toIso8601String(),
      }, collectionName: 'units');

      invalidateCache();
      return true;
    } catch (e) {
      handleError(e, 'deleteUnit');
      return false;
    }
  }

  // Categories
  Future<List<ProductCategory>> getCategories() async {
    const key = 'product_categories_all';
    final cached = _getCached<List<ProductCategory>>(key);
    if (cached != null) return cached;

    try {
      // 1. Try ISAR
      final entities = await dbService.categories
          .where()
          .sortByName()
          .findAll();
      final activeEntities = entities.where((e) => !e.isDeleted).toList();
      if (activeEntities.isNotEmpty) {
        final result = activeEntities
            .map(
              (e) => ProductCategory(
                id: e.id,
                name: e.name,
                itemType: e.itemType,
                createdAt: e.createdAt,
              ),
            )
            .toList();
        _setCache(key, result);
        return result;
      }

      // 2. Firebase Bootstrap
      List<ProductCategory> remoteItems = [];
      final firestore = db;
      if (firestore != null) {
        final snapshot = await FirestoreQueryDelegate(firestore).getCollection(
          collection: 'product_categories',
          orderBy: 'name',
        );
        remoteItems = snapshot.docs
            .where((doc) => doc.data()['isDeleted'] != true)
            .map(
              (doc) => ProductCategory.fromJson({'id': doc.id, ...doc.data()}),
            )
            .toList();

        await dbService.db.writeTxn(() async {
          for (final item in remoteItems) {
            final entity = CategoryEntity()
              ..id = item.id
              ..name = item.name
              ..itemType = item.itemType
              ..createdAt = item.createdAt ?? DateTime.now().toIso8601String()
              ..updatedAt = DateTime.now()
              ..isDeleted = false
              ..syncStatus = SyncStatus.synced;
            await dbService.categories.put(entity);
          }
        });
      }

      _setCache(key, remoteItems);
      return remoteItems;
    } catch (e) {
      handleError(e, 'getCategories');
      return [];
    }
  }

  Future<String?> addCategory(String name, String itemType) async {
    try {
      // BUG #4 FIX: Use UUID instead of millisecond timestamp (prevents ID collision)
      // BUG #1 FIX: Duplicate (name + itemType) check before insert
      final normalizedName = name.trim();
      final normalizedType = itemType.trim();
      if (normalizedName.isEmpty) {
        throw Exception('Category name cannot be empty');
      }

      final existing = await dbService.categories
          .filter()
          .nameEqualTo(normalizedName)
          .itemTypeEqualTo(normalizedType)
          .isDeletedEqualTo(false)
          .findFirst();
      if (existing != null) {
        throw Exception(
          'Category "$normalizedName" already exists for type "$normalizedType"',
        );
      }

      final id = const Uuid().v4();
      final entity = CategoryEntity()
        ..id = id
        ..name = normalizedName
        ..itemType = normalizedType
        ..createdAt = DateTime.now().toIso8601String()
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.pending;

      // 1. ISAR first
      await dbService.db.writeTxn(() async {
        await dbService.categories.put(entity);
      });

      // 2. Queue Sync
      await syncToFirebase('set', {
        'id': id,
        'name': name,
        'itemType': itemType,
        'createdAt': entity.createdAt,
        'isDeleted': false,
        'updatedAt': entity.updatedAt.toIso8601String(),
      }, collectionName: 'product_categories');

      invalidateCache();
      return id;
    } catch (e) {
      handleError(e, 'addCategory');
      return null;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final now = DateTime.now();
      final entity = await dbService.categories
          .filter()
          .idEqualTo(id)
          .findFirst();

      if (entity != null) {
        // BUG #2 FIX: In-use protection — cannot delete category used by products
        final inUseCount = await dbService.products
            .filter()
            .categoryEqualTo(entity.name)
            .isDeletedEqualTo(false)
            .count();
        if (inUseCount > 0) {
          throw Exception(
            'Cannot delete category "${entity.name}" — '
            'it is used by $inUseCount product(s). Reassign those products first.',
          );
        }

        await dbService.db.writeTxn(() async {
          entity
            ..isDeleted = true
            ..syncStatus = SyncStatus.pending
            ..updatedAt = now;
          await dbService.categories.put(entity);
        });

        // Queue Sync
        await syncToFirebase('delete', {
          'id': id,
          'isDeleted': true,
          'updatedAt': now.toIso8601String(),
        }, collectionName: 'product_categories');
      }

      invalidateCache();
      return true;
    } catch (e) {
      handleError(e, 'deleteCategory');
      return false;
    }
  }

  // Product Types
  Future<List<DynamicProductType>> getProductTypes() async {
    const key = 'product_types_all';
    final cached = _getCached<List<DynamicProductType>>(key);
    if (cached != null) return cached;

    try {
      // 1. ISAR
      final entities = await dbService.productTypes
          .where()
          .sortByName()
          .findAll();
      final activeEntities = entities.where((e) => !e.isDeleted).toList();
      final localItems = activeEntities
          .map(
            (e) => DynamicProductType(
              id: e.id,
              name: e.name,
              description: e.description ?? '',
              iconName: e.iconName ?? '',
              color: e.color ?? '',
              tabs: e.tabs ?? [],
              defaultUom: e.defaultUom ?? '',
              defaultGst: e.defaultGst ?? 18.0,
              skuPrefix: e.skuPrefix ?? '',
              displayUnit: e.displayUnit,
              createdAt: e.createdAt,
            ),
          )
          .toList();
      if (activeEntities.isNotEmpty) {
        // If stale display-unit is detected, prefer remote refresh when possible.
        // If remote is unavailable, local data is still returned for offline safety.
        final hasStaleDisplayUnit = activeEntities.any(
          (e) =>
              e.name.toLowerCase().contains('semi') &&
              (e.displayUnit == null || e.displayUnit!.isEmpty),
        );
        if (!hasStaleDisplayUnit) {
          _setCache(key, localItems);
          return localItems;
        }
        // Stale Isar data detected; fall through to Firebase fetch below.
      }

      // 2. Firebase Bootstrap
      List<DynamicProductType> remoteItems = [];
      final firestore = db;
      if (firestore != null) {
        final snapshot = await FirestoreQueryDelegate(firestore).getCollection(
          collection: 'product_types',
          orderBy: 'name',
        );
        remoteItems = snapshot.docs
            .where((doc) => doc.data()['isDeleted'] != true)
            .map(
              (doc) =>
                  DynamicProductType.fromJson({'id': doc.id, ...doc.data()}),
            )
            .toList();

        await dbService.db.writeTxn(() async {
          for (final item in remoteItems) {
            final entity = ProductTypeEntity()
              ..id = item.id
              ..name = item.name
              ..description = item.description
              ..iconName = item.iconName
              ..color = item.color
              ..tabs = item.tabs
              ..defaultUom = item.defaultUom
              ..defaultGst = item.defaultGst
              ..skuPrefix = item.skuPrefix
              ..displayUnit = item.displayUnit
              ..createdAt = item.createdAt ?? DateTime.now().toIso8601String()
              ..updatedAt = DateTime.now()
              ..isDeleted = false
                ..syncStatus = SyncStatus.synced;
            await dbService.productTypes.put(entity);
          }
        });
      }

      if (remoteItems.isEmpty && localItems.isNotEmpty) {
        _setCache(key, localItems);
        return localItems;
      }

      _setCache(key, remoteItems);
      return remoteItems;
    } catch (e) {
      handleError(e, 'getProductTypes');
      try {
        final fallbackEntities = await dbService.productTypes
            .where()
            .sortByName()
            .findAll();
        final fallbackItems = fallbackEntities
            .where((e) => !e.isDeleted)
            .map(
              (e) => DynamicProductType(
                id: e.id,
                name: e.name,
                description: e.description ?? '',
                iconName: e.iconName ?? '',
                color: e.color ?? '',
                tabs: e.tabs ?? [],
                defaultUom: e.defaultUom ?? '',
                defaultGst: e.defaultGst ?? 18.0,
                skuPrefix: e.skuPrefix ?? '',
                displayUnit: e.displayUnit,
                createdAt: e.createdAt,
              ),
            )
            .toList();
        if (fallbackItems.isNotEmpty) {
          _setCache(key, fallbackItems);
          return fallbackItems;
        }
      } catch (_) {
        // Ignore fallback lookup failures and return empty as last resort.
      }
      return [];
    }
  }

  Future<String?> addProductType(Map<String, dynamic> data) async {
    try {
      final normalizedName = (data['name'] as String? ?? '').trim();
      if (normalizedName.isEmpty) {
        throw Exception('Product type name cannot be empty');
      }

      final existing = await dbService.productTypes
          .filter()
          .nameEqualTo(normalizedName)
          .isDeletedEqualTo(false)
          .findFirst();
      if (existing != null) {
        throw Exception('Product type "$normalizedName" already exists');
      }

      final id = const Uuid().v4();
      final type = DynamicProductType.fromJson({
        ...data,
        'name': normalizedName,
        'id': id,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final entity = ProductTypeEntity()
        ..id = id
        ..name = type.name
        ..description = type.description
        ..iconName = type.iconName
        ..color = type.color
        ..tabs = type.tabs
        ..defaultUom = type.defaultUom
        ..defaultGst = type.defaultGst
        ..skuPrefix = type.skuPrefix
        ..displayUnit = type.displayUnit
        ..createdAt = type.createdAt!
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.pending;

      await dbService.db.writeTxn(() async {
        await dbService.productTypes.put(entity);
      });

      // Queue Sync
      await syncToFirebase('set', {
        ...data,
        'name': normalizedName,
        'id': id,
        'createdAt': entity.createdAt,
        'isDeleted': false,
        'updatedAt': entity.updatedAt.toIso8601String(),
      }, collectionName: 'product_types');

      invalidateCache();
      return id;
    } catch (e) {
      handleError(e, 'addProductType');
      return null;
    }
  }

  Future<bool> updateProductType(String id, Map<String, dynamic> data) async {
    try {
      final existing = await dbService.productTypes
          .filter()
          .idEqualTo(id)
          .findFirst();
      if (existing == null) throw Exception('Type not found');

      final oldName = existing.name;

      if (data.containsKey('name')) existing.name = data['name'];
      if (data.containsKey('description')) {
        existing.description = data['description'];
      }
      if (data.containsKey('iconName')) existing.iconName = data['iconName'];
      if (data.containsKey('color')) existing.color = data['color'];
      if (data.containsKey('tabs')) {
        existing.tabs = (data['tabs'] as List?)?.cast<String>();
      }
      if (data.containsKey('defaultUom')) {
        existing.defaultUom = data['defaultUom'];
      }
      if (data.containsKey('defaultGst')) {
        existing.defaultGst = (data['defaultGst'] as num).toDouble();
      }
      if (data.containsKey('skuPrefix')) existing.skuPrefix = data['skuPrefix'];
      if (data.containsKey('displayUnit')) {
        existing.displayUnit = data['displayUnit'];
      }

      existing.updatedAt = DateTime.now();
      existing.syncStatus = SyncStatus.pending;

      await dbService.db.writeTxn(() async {
        await dbService.productTypes.put(existing);
      });

      // Queue Sync
      await syncToFirebase('update', {
        'id': id,
        ...data,
        'isDeleted': false,
        'updatedAt': existing.updatedAt.toIso8601String(),
      }, collectionName: 'product_types');

      // Propagate to Products if name changed
      final newName = data['name'] as String?;
      if (newName != null && oldName != newName) {
        await _propagateTypeChangeToProducts(oldName, newName);
      }

      invalidateCache();
      return true;
    } catch (e) {
      handleError(e, 'updateProductType');
      return false;
    }
  }

  Future<void> _propagateTypeChangeToProducts(
    String oldName,
    String newName,
  ) async {
    // 1. Update Local ISAR
    final now = DateTime.now();
    final queuedProducts = <ProductEntity>[];
    final queuedCategories = <CategoryEntity>[];
    try {
      await dbService.db.writeTxn(() async {
        final localProducts = await dbService.products
            .filter()
            .itemTypeEqualTo(oldName)
            .findAll();
        for (final p in localProducts) {
          p.itemType = newName;
          p.updatedAt = now;
          if (p.syncStatus != SyncStatus.conflict) {
            p.syncStatus = SyncStatus.pending;
          }
          await dbService.products.put(p);
          queuedProducts.add(p);
        }

        final localCategories = await dbService.categories
            .filter()
            .itemTypeEqualTo(oldName)
            .isDeletedEqualTo(false)
            .findAll();
        for (final c in localCategories) {
          c.itemType = newName;
          c.updatedAt = now;
          if (c.syncStatus != SyncStatus.conflict) {
            c.syncStatus = SyncStatus.pending;
          }
          await dbService.categories.put(c);
          queuedCategories.add(c);
        }
      });
    } catch (e) {
      developer.log('Isar propagation failed: $e');
    }

    try {
      for (final product in queuedProducts) {
        await SyncQueueService.instance.addToQueue(
          collectionName: CollectionRegistry.products,
          documentId: product.id,
          operation: 'update',
          payload: product.toJson(),
        );
      }
      for (final category in queuedCategories) {
        await SyncQueueService.instance.addToQueue(
          collectionName: CollectionRegistry.productCategories,
          documentId: category.id,
          operation: 'update',
          payload: category.toJson(),
        );
      }
      if (queuedProducts.isNotEmpty || queuedCategories.isNotEmpty) {
        await SyncService.instance.trySync();
      }
    } catch (e) {
      developer.log('Queue propagation failed: $e');
    }
  }

  Future<bool> deleteProductType(String id) async {
    try {
      final now = DateTime.now();
      // 1. In-use protection
      final entity = await dbService.productTypes
          .filter()
          .idEqualTo(id)
          .findFirst();
      if (entity != null) {
        final inUseCount = await dbService.products
            .filter()
            .itemTypeEqualTo(entity.name)
            .isDeletedEqualTo(false)
            .count();
        if (inUseCount > 0) {
          throw Exception(
            'Cannot delete product type "${entity.name}" — '
            'it is used by $inUseCount product(s). Reassign those products first.',
          );
        }

        // 2. Soft-delete in ISAR
        await dbService.db.writeTxn(() async {
          entity
            ..isDeleted = true
            ..syncStatus = SyncStatus.pending
            ..updatedAt = now;
          await dbService.productTypes.put(entity);
        });
      }

      // 3. Queue Sync
      await syncToFirebase('delete', {
        'id': id,
        'isDeleted': true,
        'updatedAt': now.toIso8601String(),
      }, collectionName: 'product_types');

      // BUG #7 FIX: Removed dead SharedPreferences write — local_product_types
      // was never read; only Isar is the source of truth for product types.

      invalidateCache();
      return true;
    } catch (e) {
      handleError(e, 'deleteProductType');
      return false;
    }
  }

  Future<bool> updateCategory(String id, String name, String itemType) async {
    try {
      final existing = await dbService.categories
          .filter()
          .idEqualTo(id)
          .findFirst();
      if (existing == null) {
        throw Exception('Category not found');
      }
      final oldName = existing.name;
      final oldType = existing.itemType;
      final now = DateTime.now();

      final data = {
        'name': name,
        'itemType': itemType,
        'isDeleted': false,
        'updatedAt': now.toIso8601String(),
      };

      await dbService.db.writeTxn(() async {
        existing
          ..name = name
          ..itemType = itemType
          ..isDeleted = false
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;
        await dbService.categories.put(existing);
      });

      // Queue update sync
      await syncToFirebase('update', {
        'id': id,
        ...data,
      }, collectionName: 'product_categories');

      // 2. Propagate to Products if name or type changed
      if (oldName != name || oldType != itemType) {
        await _propagateCategoryChangeToProducts(
          oldName,
          name,
          oldType,
          itemType,
        );
      }

      // BUG #7 FIX: Removed dead SharedPreferences write — local_product_categories
      // was never read; Isar + Firestore queue is the only source of truth.

      invalidateCache();
      return true;
    } catch (e) {
      handleError(e, 'updateCategory');
      return false;
    }
  }

  Future<void> _propagateCategoryChangeToProducts(
    String oldName,
    String newName,
    String oldType,
    String newType,
  ) async {
    final now = DateTime.now();
    final queuedProducts = <ProductEntity>[];
    try {
      await dbService.db.writeTxn(() async {
        final localProducts = await dbService.products
            .filter()
            .categoryEqualTo(oldName)
            .itemTypeEqualTo(oldType)
            .isDeletedEqualTo(false)
            .findAll();
        for (final p in localProducts) {
          p
            ..category = newName
            ..itemType = newType
            ..updatedAt = now;
          if (p.syncStatus != SyncStatus.conflict) {
            p.syncStatus = SyncStatus.pending;
          }
          await dbService.products.put(p);
          queuedProducts.add(p);
        }
      });
    } catch (e) {
      developer.log('Local category propagation failed: $e');
    }

    try {
      for (final product in queuedProducts) {
        await SyncQueueService.instance.addToQueue(
          collectionName: CollectionRegistry.products,
          documentId: product.id,
          operation: 'update',
          payload: product.toJson(),
        );
      }
      if (queuedProducts.isNotEmpty) {
        await SyncService.instance.trySync();
      }
    } catch (e) {
      developer.log('Category queue propagation failed: $e');
    }
  }

  // SYNC DEFAULT DATA
  Future<Map<String, int>> syncDefaultData() async {
    const defaultUoms = {
      "Raw Material": "KG",
      "Oils & Liquids": "Liter",
      "Semi-Finished Good": "Batch",
      "Finished Good": "Pcs",
      "Traded Good": "Pcs",
      "Packaging Material": "Pcs",
      "Chemicals & Additives": "KG",
    };

    const defaultGst = {
      "Raw Material": 18.0,
      "Oils & Liquids": 5.0,
      "Semi-Finished Good": 0.0,
      "Finished Good": 18.0,
      "Traded Good": 18.0,
      "Packaging Material": 12.0,
      "Chemicals & Additives": 18.0,
    };

    const skuPrefixes = {
      "Raw Material": "RM",
      "Oils & Liquids": "OIL",
      "Semi-Finished Good": "SFG",
      "Finished Good": "FG",
      "Traded Good": "TG",
      "Packaging Material": "PKG",
      "Chemicals & Additives": "CHM",
    };

    const productCategories = {
      "Raw Material": [
        "Chemicals",
        "Fillers",
        "Minerals",
        "Alkalis",
        "General",
      ],
      "Oils & Liquids": ["Oils", "Fragrance", "Essences", "Solvents"],
      "Semi-Finished Good": [
        "Sona Base",
        "Gita Base",
        "Soap Base",
        "Detergent Base",
        "Reprocessed Base",
      ],
      "Finished Good": [
        "Sona",
        "Gita",
        "Sunlight",
        "Green",
        "Malai",
        "Bazaar",
        "Reprocessed",
        "Laundry Soaps", // Keep generic for fallback
        "Bath Soaps",
      ],
      "Traded Good": [
        "Soaps",
        "Detergents",
        "Dish Wash",
        "Cleaners",
        "Personal Care",
      ],
      "Packaging Material": [
        "Wrappers",
        "Boxes",
        "Cartons",
        "Labels",
        "Bags",
        "Bottles",
      ],
      "Chemicals & Additives": [
        "Colors",
        "Acids",
        "Preservatives",
        "Catalysts",
        "Surfactants",
      ],
    };

    int typesAdded = 0;
    int catsAdded = 0;

    try {
      // 0. FIX TYPO: Check for legacy typo "Semi-Finised Good"
      final currentTypes = await getProductTypes();
      final typoName = 'Semi-Finised Good';
      final correctName = 'Semi-Finished Good';

      final typoType = currentTypes
          .where((t) => t.name == typoName)
          .firstOrNull;
      final correctType = currentTypes
          .where((t) => t.name == correctName)
          .firstOrNull;

      if (typoType != null) {
        if (correctType != null) {
          // Both exist: Migrate products from Typo -> Correct, then delete Typo
          developer.log(
            'Found both Typo and Correct types. Migrating...',
            name: 'MasterData',
          );
          await _propagateTypeChangeToProducts(typoName, correctName);
          await deleteProductType(typoType.id);
        } else {
          // Only Typo exists: Rename it
          developer.log('Found Typo type. Renaming...', name: 'MasterData');
          await updateProductType(typoType.id, {'name': correctName});
        }
        // Refresh list
        invalidateCache();
      }

      // 1. Sync Product Types
      final existingTypes = await getProductTypes();
      for (final name in productCategories.keys) {
        if (!existingTypes.any(
          (t) => t.name.trim().toLowerCase() == name.trim().toLowerCase(),
        )) {
          await addProductType({
            'name': name,
            'description': 'Manage $name inventory and production workflows.',
            'iconName': _getIconNameForType(name),
            'color': _getColorForType(name),
            'tabs': _getTabsForType(name),
            'defaultUom': defaultUoms[name] ?? 'Pcs',
            'defaultGst': defaultGst[name] ?? 18.0,
            'skuPrefix': skuPrefixes[name] ?? 'PRD',
          });
          typesAdded++;
        }
      }

      // 2. Sync Categories
      final existingCats = await getCategories();
      for (final entry in productCategories.entries) {
        final typeName = entry.key;
        for (final catName in entry.value) {
          if (!existingCats.any(
            (c) =>
                c.name.trim().toLowerCase() == catName.trim().toLowerCase() &&
                c.itemType.trim().toLowerCase() ==
                    typeName.trim().toLowerCase(),
          )) {
            await addCategory(catName, typeName);
            catsAdded++;
          }
        }
      }

      // 3. Sync Units
      final existingUnits = await getUnits();
      const defaultUnits = ['Pcs', 'Kg', 'Ltr', 'Box', 'Ton', 'Bag', 'Batch'];
      for (final unit in defaultUnits) {
        if (!existingUnits.any((u) => u.toLowerCase() == unit.toLowerCase())) {
          await addUnit(unit);
        }
      }

      return {'typesAdded': typesAdded, 'catsAdded': catsAdded};
    } catch (e) {
      handleError(e, 'syncDefaultData');
      return {'typesAdded': 0, 'catsAdded': 0};
    }
  }

  String _getIconNameForType(String type) {
    if (type.contains('Raw')) return 'Package';
    if (type.contains('Oil')) return 'Droplets';
    if (type.contains('Semi')) return 'Factory';
    if (type.contains('Chemical')) return 'Beaker';
    if (type.contains('Traded')) return 'Store';
    return 'Package';
  }

  String _getColorForType(String type) {
    if (type.contains('Raw')) return 'bg-slate-500';
    if (type.contains('Oil')) return 'bg-blue-500';
    if (type.contains('Semi')) return 'bg-purple-500';
    if (type.contains('Finished')) return 'bg-green-500';
    if (type.contains('Traded')) return 'bg-orange-500';
    return 'bg-indigo-500';
  }

  List<String> _getTabsForType(String type) {
    return ["Basic", "Inventory"];
  }

  // MIGRATION UTILITIES
  Future<Map<String, int>> fixAllSemiFinishedToSoapBase() async {
    int productsUpdated = 0;
    int formulasUpdated = 0;

    try {
      final firestore = db;
      if (firestore == null) return {'products': 0, 'formulas': 0};
      final remote = FirestoreQueryDelegate(firestore);

      // 1. Update Products
      final productSnap = await remote.getCollection(
        collection: 'products',
        filters: <FirestoreQueryFilter>[
          FirestoreQueryFilter(
            field: 'itemType',
            operator: FirestoreQueryOperator.isEqualTo,
            value: 'Semi-Finished Good',
          ),
          FirestoreQueryFilter(
            field: 'category',
            operator: FirestoreQueryOperator.isEqualTo,
            value: 'Semi-Finished Good',
          ),
        ],
      );

      for (final doc in productSnap.docs) {
        await const MasterDataRemoteWriteDelegate().updateDocument(
          doc.reference,
          {'category': 'Soap Base'},
        );
        productsUpdated++;
      }

      // 2. Update Formulas
      final formulaSnap = await remote.getCollection(
        collection: 'formulas',
        filters: <FirestoreQueryFilter>[
          FirestoreQueryFilter(
            field: 'category',
            operator: FirestoreQueryOperator.isEqualTo,
            value: 'Semi-Finished Good',
          ),
        ],
      );

      for (final doc in formulaSnap.docs) {
        await const MasterDataRemoteWriteDelegate().updateDocument(
          doc.reference,
          {'category': 'Soap Base'},
        );
        formulasUpdated++;
      }

      return {'products': productsUpdated, 'formulas': formulasUpdated};
    } catch (e) {
      handleError(e, 'fixAllSemiFinishedToSoapBase');
      return {'products': 0, 'formulas': 0};
    }
  }

  Future<int> migrateGeetaToGita() async {
    int total = 0;
    try {
      final firestore = db;
      if (firestore == null) return 0;
      final remote = FirestoreQueryDelegate(firestore);

      // 1. Update Users
      final userSnap = await remote.getCollection(collection: 'users');
      for (final doc in userSnap.docs) {
        final data = doc.data();
        bool changed = false;

        if (data['assignedBhatti'] == 'Geeta Bhatti') {
          data['assignedBhatti'] = 'Gita Bhatti';
          changed = true;
        }

        if (data['departments'] != null) {
          final depts = (data['departments'] as List);
          for (var i = 0; i < depts.length; i++) {
            if (depts[i]['team'] == 'geeta') {
              depts[i]['team'] = 'gita';
              changed = true;
            }
          }
        }

        if (changed) {
          await const MasterDataRemoteWriteDelegate().updateDocument(
            doc.reference,
            data,
          );
          total++;
        }
      }

      // 2. Update Bhatti Batches
      final bhattiSnap = await remote.getCollection(
        collection: 'bhatti_batches',
        filters: <FirestoreQueryFilter>[
          FirestoreQueryFilter(
            field: 'bhattiName',
            operator: FirestoreQueryOperator.isEqualTo,
            value: 'Geeta Bhatti',
          ),
        ],
      );
      for (final doc in bhattiSnap.docs) {
        await const MasterDataRemoteWriteDelegate().updateDocument(
          doc.reference,
          {'bhattiName': 'Gita Bhatti'},
        );
        total++;
      }

      return total;
    } catch (e) {
      handleError(e, 'migrateGeetaToGita');
      return 0;
    }
  }

  Future<Map<String, int>> deduplicateMasters() async {
    int catsDeleted = 0;
    int typesDeleted = 0;

    try {
      // 1. Deduplicate Categories
      final cats = await getCategories();
      final seenCats = <String, ProductCategory>{};
      final toDeleteCats = <String>[];

      for (final cat in cats) {
        final key =
            "${cat.name.trim().toLowerCase()}_${cat.itemType.trim().toLowerCase()}";
        if (seenCats.containsKey(key)) {
          toDeleteCats.add(cat.id);
        } else {
          seenCats[key] = cat;
        }
      }

      for (final id in toDeleteCats) {
        await deleteCategory(id);
        catsDeleted++;
      }

      // 2. Deduplicate Product Types
      final types = await getProductTypes();
      final seenTypes = <String, DynamicProductType>{};
      final toDeleteTypes = <String>[];

      for (final type in types) {
        final key = type.name.trim().toLowerCase();
        if (seenTypes.containsKey(key)) {
          toDeleteTypes.add(type.id);
        } else {
          seenTypes[key] = type;
        }
      }

      for (final id in toDeleteTypes) {
        await deleteProductType(id);
        typesDeleted++;
      }

      invalidateCache();
      return {'categories': catsDeleted, 'types': typesDeleted};
    } catch (e) {
      handleError(e, 'deduplicateMasters');
      return {'categories': 0, 'types': 0};
    }
  }

  Future<Map<String, int>> deepAuditAndSyncProducts() async {
    int fixed = 0;
    try {
      final firestore = db;
      if (firestore == null) return {'fixed': 0};
      final remote = FirestoreQueryDelegate(firestore);

      final types = await getProductTypes();
      final cats = await getCategories();
      final typeNames = types.map((e) => e.name).toList();

      final productSnap = await remote.getCollection(collection: 'products');

      for (final doc in productSnap.docs) {
        final data = doc.data();
        final currentType = data['itemType'] as String?;
        final currentCat = data['category'] as String?;

        bool needsFix = false;
        Map<String, dynamic> updates = {};

        // 1. Audit Type
        if (currentType != null) {
          // Check for case-insensitive match or slight mismatch
          final match = typeNames.firstWhere(
            (t) => t.toLowerCase() == currentType.toLowerCase(),
            orElse: () => '',
          );
          if (match.isNotEmpty && match != currentType) {
            updates['itemType'] = match;
            needsFix = true;
          }
        }

        // 2. Audit Category (relative to type)
        if (currentCat != null) {
          final typeToSearch = updates['itemType'] ?? currentType ?? '';
          final matchCat = cats.firstWhere(
            (c) =>
                c.name.toLowerCase() == currentCat.toLowerCase() &&
                c.itemType.toLowerCase() == typeToSearch.toLowerCase(),
            orElse: () => ProductCategory(id: '', name: '', itemType: ''),
          );

          if (matchCat.name.isNotEmpty && matchCat.name != currentCat) {
            updates['category'] = matchCat.name;
            needsFix = true;
          }
        }

        if (needsFix) {
          await const MasterDataRemoteWriteDelegate().updateDocument(
            doc.reference,
            updates,
          );
          fixed++;
        }
      }

      return {'fixed': fixed};
    } catch (e) {
      handleError(e, 'deepAuditAndSyncProducts');
      return {'fixed': 0};
    }
  }

  // Route Management
  Future<List<String>> getGlobalRoutes() async {
    const key = 'global_routes';
    final cached = _getCached<List<String>>(key);
    if (cached != null) return cached;

    try {
      final firestore = db;
      if (firestore != null) {
        final doc = await FirestoreQueryDelegate(firestore).getDocument(
          collection: 'public_settings',
          documentId: 'routes',
        );
        if (doc.exists && doc.data()?['list'] != null) {
          final routes = List<String>.from(doc.data()!['list']);
          _setCache(key, routes);

          // Legacy/Fallback storage sync
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('local_routes', jsonEncode(routes));

          return routes;
        }
      }

      // Local fallback
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('local_routes');
      if (localJson != null) {
        final routes = List<String>.from(jsonDecode(localJson));
        _setCache(key, routes);
        return routes;
      }

      return [];
    } catch (e) {
      handleError(e, 'getGlobalRoutes');
      return [];
    }
  }

  Future<bool> addRoute(String routeName, List<String> existingRoutes) async {
    try {
      final updatedRoutes = [...existingRoutes, routeName]..sort();
      await syncToFirebase(
        'set',
        {
          'id': 'routes',
          'list': updatedRoutes,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        collectionName: 'public_settings',
        syncImmediately: false,
      );

      // Update local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_routes', jsonEncode(updatedRoutes));

      invalidateCache();
      return true;
    } catch (e) {
      handleError(e, 'addRoute');
      return false;
    }
  }
}
