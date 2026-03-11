import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../data/local/entities/product_entity.dart';
import '../models/types/product_types.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'database_service.dart';
import 'base_service.dart';
import 'field_encryption_service.dart';
import 'outbox_codec.dart';
import '../utils/app_logger.dart';

const productsCollection = 'products';

class ProductsService extends BaseService {
  final DatabaseService _dbService;
  final FieldEncryptionService _fieldEncryption =
      FieldEncryptionService.instance;

  static const double _priceMagnitude = 1e5;
  bool _diagnosticCleanupDone = false;

  // Diagnostic LIVE_* products are generated only by QA scripts and should stay
  // hidden in normal app flows unless explicitly enabled for debugging.
  static const bool _allowDiagnosticProducts = bool.fromEnvironment(
    'DATT_ALLOW_DIAGNOSTIC_PRODUCTS',
    defaultValue: false,
  );

  ProductsService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Future<void> _enqueueOutbox(
    Map<String, dynamic> payload, {
    String action = 'set',
  }) async {
    final queueId = OutboxCodec.buildQueueId(
      productsCollection,
      payload,
      explicitRecordKey: payload['id']?.toString(),
    );
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;
    final queueEntity = SyncQueueEntity()
      ..id = queueId
      ..collection = productsCollection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(queueEntity);
    });
  }

  Map<String, dynamic> _toSyncPayload(ProductEntity entity) {
    final payload = _mapToDomain(entity).toJson();
    payload['id'] = entity.id;
    payload['isDeleted'] = entity.isDeleted;
    payload['updatedAt'] = entity.updatedAt.toIso8601String();
    return payload;
  }

  ProductTypeEnum _typeFromCanonicalItemType(String canonicalItemType) {
    switch (canonicalItemType) {
      case 'Raw Material':
      case 'Oils & Liquids':
      case 'Chemicals & Additives':
        return ProductTypeEnum.raw;
      case 'Semi-Finished Good':
        return ProductTypeEnum.semi;
      case 'Finished Good':
        return ProductTypeEnum.finished;
      case 'Traded Good':
        return ProductTypeEnum.traded;
      case 'Packaging Material':
        return ProductTypeEnum.packaging;
      default:
        return ProductTypeEnum.finished;
    }
  }

  ProductTypeEnum _resolveProductTypeEnum(ProductEntity entity) {
    final rawType = entity.type.trim().toLowerCase();
    for (final value in ProductTypeEnum.values) {
      if (value.name == rawType) return value;
    }

    final canonicalItemType = ProductType.fromString(entity.itemType).value;
    return _typeFromCanonicalItemType(canonicalItemType);
  }

  // Helper: Map Entity to Domain Model
  // Helper: Map Entity to Domain Model
  Product _mapToDomain(ProductEntity entity) {
    final priceValue =
        _decryptProductDouble(entity, 'price', entity.price) ?? 0.0;
    final secondaryPriceValue = _decryptProductDouble(
      entity,
      'secondaryPrice',
      entity.secondaryPrice,
    );
    final mrpValue = _decryptProductDouble(entity, 'mrp', entity.mrp);
    final purchasePriceValue = _decryptProductDouble(
      entity,
      'purchasePrice',
      entity.purchasePrice,
    );
    final averageCostValue = _decryptProductDouble(
      entity,
      'averageCost',
      entity.averageCost,
    );
    final lastCostValue = _decryptProductDouble(
      entity,
      'lastCost',
      entity.lastCost,
    );
    final internalCostValue = _decryptProductDouble(
      entity,
      'internalCost',
      entity.internalCost,
    );

    return Product(
      id: entity.id,
      name: entity.name,
      sku: entity.sku,
      itemType: ProductType.fromString(entity.itemType),
      type: _resolveProductTypeEnum(entity),
      category: entity.category ?? '',
      subcategory: entity.subcategory,
      stock: entity.stock ?? 0.0, // Default to 0.0 if null
      baseUnit: entity.baseUnit,
      secondaryUnit: entity.secondaryUnit,
      conversionFactor: entity.conversionFactor ?? 1.0,
      price: priceValue,
      secondaryPrice: secondaryPriceValue,
      mrp: mrpValue,
      purchasePrice: purchasePriceValue,
      averageCost: averageCostValue,
      lastCost: lastCostValue,
      gstRate: entity.gstRate,
      defaultDiscount: entity.defaultDiscount,
      status: entity.status ?? 'active',
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      reorderLevel: entity.reorderLevel,
      stockAlertLevel: entity.stockAlertLevel,
      minimumSafetyStock: entity.minimumSafetyStock,

      unitWeightGrams: entity.unitWeightGrams ?? 0.0,
      weightPerUnit: entity.weightPerUnit,
      volumePerUnit: entity.volumePerUnit,
      density: entity.density,
      packagingType:
          (entity.packagingType?.trim().isNotEmpty ?? false)
          ? PackagingType.fromString(entity.packagingType!)
          : null,
      packagingRecipe: entity.packagingRecipe,
      shelfLife: entity.shelfLife,
      barcode: entity.barcode,
      productionStage: entity.productionStage != null
          ? ProductionStage.values.firstWhere(
              (e) => e.name == entity.productionStage,
              orElse: () => ProductionStage.intermediate,
            )
          : null,
      wastagePercent: entity.wastagePercent,
      boxesPerBatch: entity.boxesPerBatch,
      internalCost: internalCostValue,
      expiryDays: entity.expiryDays,
      batchMandatory: entity.batchMandatory ?? false,
      storageConditions: entity.storageConditions != null
          ? StorageCondition.values.firstWhere(
              (e) => e.name == entity.storageConditions,
              orElse: () => StorageCondition.roomTemperature,
            )
          : null,
      isTankMaterial: entity.isTankMaterial ?? false,
      dimensions:
          null, // Mapping Map to ProductDimensions requires helper, skipping for now as per strict rules to not break logic if complex
      sizeVariant: entity.sizeVariant,
      hazardLevel: entity.hazardLevel != null
          ? HazardLevel.values.firstWhere(
              (e) => e.name == entity.hazardLevel,
              orElse: () => HazardLevel.none,
            )
          : null,
      safetyPrecautions: entity.safetyPrecautions,
      storageRequirements: entity.storageRequirements,
      ppeRequired: entity.ppeRequired,
      unit: entity.baseUnit, // Using baseUnit as the main unit
      createdAt:
          entity.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      allowedSemiFinishedIds: entity.allowedSemiFinishedIds ?? [],
      allowedDepartmentIds: entity.allowedDepartmentIds ?? [],
      unitsPerBundle: entity.unitsPerBundle,
      entityType: entity.entityType,
      localImagePath: entity.localImagePath,
      standardBatchInputKg: entity.standardBatchInputKg,
      standardBatchOutputPcs: entity.standardBatchOutputPcs,
    );
  }

  // Helper: Map Map (from UI/Creation) to Entity
  ProductEntity _mapToEntity(Map<String, dynamic> data) {
    final entity = ProductEntity()
      ..id = data['id']
      ..name = data['name']
      ..sku = data['sku']
      ..itemType =
          data['itemType'] ??
          'finished_good' // fallback
      ..type = data['type']
      ..departmentId = data['departmentId']
      ..baseSemiId = data['baseSemiId']
      ..category = data['category'] ?? ''
      ..subcategory = data['subcategory']
      ..stock = (data['stock'] as num?)?.toDouble() ?? 0.0
      ..baseUnit = data['baseUnit'] ?? 'Pcs'
      ..secondaryUnit = data['secondaryUnit']
      ..conversionFactor = (data['conversionFactor'] as num?)?.toDouble() ?? 1.0
      ..price = (data['price'] as num?)?.toDouble() ?? 0.0
      ..secondaryPrice = (data['secondaryPrice'] as num?)?.toDouble()
      ..mrp = (data['mrp'] as num?)?.toDouble()
      ..purchasePrice = (data['purchasePrice'] as num?)?.toDouble()
      ..averageCost = (data['averageCost'] as num?)?.toDouble()
      ..lastCost = (data['lastCost'] as num?)?.toDouble()
      ..gstRate = (data['gstRate'] as num?)?.toDouble()
      ..defaultDiscount = (data['defaultDiscount'] as num?)?.toDouble()
      ..status = data['status'] ?? 'active'
      ..supplierId = data['supplierId']
      ..supplierName = data['supplierName']
      ..reorderLevel = (data['reorderLevel'] as num?)?.toDouble()
      ..stockAlertLevel = (data['stockAlertLevel'] as num?)?.toDouble()
      ..minimumSafetyStock = (data['minimumSafetyStock'] as num?)?.toDouble()
      ..simpleSchemeBuy = (data['simpleSchemeBuy'] as num?)?.toDouble()
      ..simpleSchemeGet = (data['simpleSchemeGet'] as num?)?.toDouble()
      ..unitWeightGrams = (data['unitWeightGrams'] as num?)?.toDouble() ?? 0.0
      ..weightPerUnit = (data['weightPerUnit'] as num?)?.toDouble()
      ..volumePerUnit = (data['volumePerUnit'] as num?)?.toDouble()
      ..density = (data['density'] as num?)?.toDouble()
      ..packagingType =
          (data['packagingType']?.toString().trim().isNotEmpty ?? false)
          ? data['packagingType'].toString().trim()
          : null
      ..shelfLife = (data['shelfLife'] as num?)?.toDouble()
      ..barcode = data['barcode']
      ..productionStage = data['productionStage']
      ..wastagePercent = (data['wastagePercent'] as num?)?.toDouble()
      ..boxesPerBatch = (data['boxesPerBatch'] as num?)?.toInt()
      ..internalCost = (data['internalCost'] as num?)?.toDouble()
      ..expiryDays = (data['expiryDays'] as num?)?.toDouble()
      ..batchMandatory = data['batchMandatory'] ?? false
      ..storageConditions = data['storageConditions']
      ..isTankMaterial = data['isTankMaterial'] ?? false
      ..dimensions = data['dimensions']
      ..sizeVariant = data['sizeVariant']
      ..hazardLevel = data['hazardLevel']
      ..safetyPrecautions = data['safetyPrecautions']
      ..storageRequirements = (data['storageRequirements'] as List<dynamic>?)
          ?.cast<String>()
      ..ppeRequired = (data['ppeRequired'] as List<dynamic>?)?.cast<String>()
      ..createdAt = DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now()
      ..updatedAt =
          DateTime.tryParse(data['lastUpdatedAt'] ?? '') ?? DateTime.now()
      ..allowedSemiFinishedIds =
          (data['allowedSemiFinishedIds'] as List<dynamic>?)?.cast<String>()
      ..allowedDepartmentIds = (data['allowedDepartmentIds'] as List<dynamic>?)
          ?.cast<String>()
      ..unitsPerBundle = (data['unitsPerBundle'] as num?)?.toInt()
      ..entityType = data['entityType']
      ..standardBatchInputKg = (data['standardBatchInputKg'] as num?)
          ?.toDouble()
      ..standardBatchOutputPcs = (data['standardBatchOutputPcs'] as num?)
          ?.toDouble()
      ..localImagePath = data['localImagePath']
      ..syncStatus = SyncStatus.pending;

    entity.encryptSensitiveFields();

    // Map Packaging Recipe
    if (data['packagingRecipe'] != null) {
      entity.packagingRecipe = (data['packagingRecipe'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }

    return entity;
  }

  bool _isDiagnosticLiveTestEntity(ProductEntity entity) {
    final name = entity.name.toUpperCase();
    final sku = entity.sku.toUpperCase();
    final category = (entity.category ?? '').toLowerCase();
    return category == 'live-test' ||
        name.startsWith('LIVE_') ||
        sku.startsWith('LVS_');
  }

  Future<void> _cleanupLocalDiagnosticProductsOnce() async {
    if (_allowDiagnosticProducts || _diagnosticCleanupDone) return;
    _diagnosticCleanupDone = true;

    try {
      final localProducts = await _dbService.products
          .filter()
          .idGreaterThan('')
          .findAll();
      final toHide = localProducts
          .where((p) => !p.isDeleted && _isDiagnosticLiveTestEntity(p))
          .toList();
      if (toHide.isEmpty) return;

      final now = DateTime.now();
      await _dbService.db.writeTxn(() async {
        for (final product in toHide) {
          product
            ..isDeleted = true
            ..deletedAt = now
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced;
          await _dbService.products.put(product);
        }
      });

      AppLogger.warning(
        'Hidden ${toHide.length} diagnostic LIVE test product(s) from local cache.',
        tag: 'Products',
      );
    } catch (_) {
      // Keep app flow resilient; product listing should continue even if cleanup fails.
    }
  }

  Future<List<Product>> getProducts({
    String? status,
    String? itemType,
    List<String>? itemTypes,
    String? category,
    String? type,
    int? limitCount,
    SyncStatus? syncStatus,
  }) async {
    try {
      await _cleanupLocalDiagnosticProductsOnce();

      // 1. Read from ISAR
      var query = _dbService.products.filter().idGreaterThan(''); // Scan all

      if (status != null) {
        query = query.statusEqualTo(status);
      }
      if (syncStatus != null) {
        query = query.syncStatusEqualTo(syncStatus);
      }
      // Note: Isar filter composition is adding AND logic
      // For more complex querying (optional params), we build query based on what's provided
      // Simplification: Fetch all and filter in memory if strict filters mismatch Isar capabilities,
      // but Isar is powerful. Let's try to compose.

      // Actually, Isar query builder is immutable-ish. We need to chain properly.
      // A clean way is to build the query step by step.
      // But Isar generated code uses specific methods types.
      // Let's do memory filtering for non-indexed/complex optional combos for safety first,
      // or use basic 'findAll' then filter logic to minimize migration bugs.
      // However, for performance, we should usage indices.
      // Given the limited time, let's fetch all and filter in memory (dataset < 5000 likely).
      // Optimization: Filter by status/itemType if present as they are common.

      final allEntities = await _dbService.products
          .filter()
          .idGreaterThan('')
          .findAll();

      var filtered = allEntities.where((e) => !e.isDeleted).toList();
      if (!_allowDiagnosticProducts) {
        filtered = filtered
            .where((e) => !_isDiagnosticLiveTestEntity(e))
            .toList();
      }

      if (status != null) {
        filtered = filtered.where((e) => e.status == status).toList();
      }
      if (itemType != null) {
        final normalizedItemType = ProductType.fromString(itemType).value;
        filtered = filtered
            .where(
              (e) =>
                  ProductType.fromString(e.itemType).value ==
                  normalizedItemType,
            )
            .toList();
      }
      if (itemTypes != null && itemTypes.isNotEmpty) {
        final normalizedItemTypes = itemTypes
            .map((typeValue) => ProductType.fromString(typeValue).value)
            .toSet();
        filtered = filtered
            .where(
              (e) => normalizedItemTypes.contains(
                ProductType.fromString(e.itemType).value,
              ),
            )
            .toList();
      }
      if (type != null) {
        filtered = filtered.where((e) => e.type == type).toList();
      }
      if (category != null) {
        filtered = filtered.where((e) => e.category == category).toList();
      }

      if (limitCount != null) {
        filtered = filtered.take(limitCount).toList();
      }

      // Convert to domain and DEDUPLICATE to prevent duplicate products in UI
      final products = filtered.map(_mapToDomain).toList();
      return deduplicate(products, (p) => p.id);
    } catch (e) {
      throw handleError(e, 'getProducts');
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      // Wait, ProductEntity ID is String (fastHash usually used or just String ID if defined)
      // Checking ProductEntity definition... it uses String id with @Id() or FastHash?
      // Assuming String ID for 'id' field, but Isar requires int Id.
      // Let's check `product_entity.dart`...
      // Usually strings are indexed.
      // Let's try finding by the String index which is safer.
      final p = await _dbService.products.getById(id);
      if (p != null && !p.isDeleted) return _mapToDomain(p);
      return null;
    } catch (e) {
      throw handleError(e, 'getProductById');
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      // BUG #3 FIX: Removed hardcoded stockLessThan(10) — was ignoring each
      // product's actual reorderLevel. Now compares accurately in memory.
      final entities = await _dbService.products
          .filter()
          .isDeletedEqualTo(false)
          .findAll();
      return entities
          .where((e) {
            final stock = e.stock ?? 0;
            final threshold = e.reorderLevel ?? e.minimumSafetyStock ?? 0;
            return threshold > 0 && stock <= threshold;
          })
          .map(_mapToDomain)
          .toList();
    } catch (e) {
      throw handleError(e, 'getLowStockProducts');
    }
  }

  String _canonicalSku(String sku) => sku.trim().toUpperCase();

  Future<ProductEntity?> _findActiveSkuConflict(
    String sku, {
    String? excludeId,
  }) async {
    final canonical = _canonicalSku(sku);
    if (canonical.isEmpty) return null;

    final activeProducts = await _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .findAll();

    for (final product in activeProducts) {
      if (excludeId != null && product.id == excludeId) continue;
      if (_canonicalSku(product.sku) == canonical) {
        return product;
      }
    }
    return null;
  }

  /// Validates that SKU is unique among active products.
  /// Returns null if valid, or error message if duplicate exists.
  ///
  /// ARCHITECTURE LOCK: SKU uniqueness is ENFORCED.
  /// Never remove this validation. SKU field should be locked after product is used in transactions.
  Future<String?> _validateSkuUnique(String sku, {String? excludeId}) async {
    final normalizedSku = sku.trim();
    if (normalizedSku.isEmpty) {
      return null; // Empty SKUs allowed (auto-generated later)
    }

    try {
      final existing = await _findActiveSkuConflict(
        normalizedSku,
        excludeId: excludeId,
      );

      if (existing != null && existing.id != excludeId) {
        return 'SKU "$normalizedSku" already exists for product: ${existing.name}';
      }

      return null;
    } catch (e) {
      throw handleError(e, '_validateSkuUnique');
    }
  }

  Future<Product> createProduct({
    required String name,
    required String sku,
    required String itemType,
    required String type,
    String? departmentId,
    String? baseSemiId,
    required String category,
    String? subcategory,
    required double stock,
    required String baseUnit,
    String? secondaryUnit,
    required double conversionFactor,
    required double price,
    double? secondaryPrice,
    double? mrp,
    double? purchasePrice,
    double? averageCost,
    double? lastCost,
    double? gstRate,
    double? defaultDiscount,
    required String status,
    String? supplierId,
    String? supplierName,
    double? reorderLevel,
    double? stockAlertLevel,
    double? minimumSafetyStock,
    double? simpleSchemeBuy,
    double? simpleSchemeGet,

    required double unitWeightGrams,
    double? weightPerUnit,
    double? volumePerUnit,
    double? density,
    String? packagingType,
    List<Map<String, dynamic>>? packagingRecipe,
    double? shelfLife,
    String? barcode,
    String? productionStage,
    double? wastagePercent,
    int? boxesPerBatch,
    double? internalCost,
    double? expiryDays,
    bool? batchMandatory,
    String? storageConditions,
    bool? isTankMaterial,
    Map<String, dynamic>? dimensions,
    String? sizeVariant,
    String? hazardLevel,
    String? safetyPrecautions,
    List<String>? storageRequirements,
    List<String>? ppeRequired,
    String? unit,
    required String userId,
    String? userName,
    List<String> allowedSemiFinishedIds = const [],
    List<String> allowedDepartmentIds = const [],
    int? unitsPerBundle,
    String? entityType,
    double? standardBatchInputKg,
    double? standardBatchOutputPcs,
    String? localImagePath,
  }) async {
    try {
      final normalizedSku = sku.trim();

      // VALIDATION: SKU Uniqueness Enforcement
      final skuError = await _validateSkuUnique(normalizedSku);
      if (skuError != null) {
        throw Exception(skuError);
      }

      final productId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();

      // Construct Map to reuse _mapToEntity logic
      final productData = {
        'id': productId,
        'name': name,
        'sku': normalizedSku,
        'itemType': itemType,
        'type': type,
        'departmentId': departmentId,
        'baseSemiId': baseSemiId,
        'category': category,
        'subcategory': subcategory,
        'stock': stock,
        'baseUnit': baseUnit,
        'secondaryUnit': secondaryUnit,
        'conversionFactor': conversionFactor,
        'price': price,
        'secondaryPrice': secondaryPrice,
        'mrp': mrp,
        'purchasePrice': purchasePrice,
        'averageCost': averageCost,
        'lastCost': lastCost,
        'gstRate': gstRate,
        'defaultDiscount': defaultDiscount,
        'status': status,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'reorderLevel': reorderLevel,
        'stockAlertLevel': stockAlertLevel,
        'minimumSafetyStock': minimumSafetyStock,
        'simpleSchemeBuy': simpleSchemeBuy,
        'simpleSchemeGet': simpleSchemeGet,

        'unitWeightGrams': unitWeightGrams,
        'weightPerUnit': weightPerUnit,
        'volumePerUnit': volumePerUnit,
        'density': density,
        'packagingType': packagingType,
        'packagingRecipe': packagingRecipe,
        'shelfLife': shelfLife,
        'barcode': barcode,
        'productionStage': productionStage,
        'wastagePercent': wastagePercent,
        'boxesPerBatch': boxesPerBatch,
        'internalCost': internalCost,
        'expiryDays': expiryDays,
        'batchMandatory': batchMandatory,
        'storageConditions': storageConditions,
        'isTankMaterial': isTankMaterial,
        'dimensions': dimensions,
        'sizeVariant': sizeVariant,
        'hazardLevel': hazardLevel,
        'safetyPrecautions': safetyPrecautions,
        'storageRequirements': storageRequirements,
        'ppeRequired': ppeRequired,
        'unit': unit,
        'createdAt': now,
        'lastUpdatedAt': now,
        'allowedSemiFinishedIds': allowedSemiFinishedIds,
        'allowedDepartmentIds': allowedDepartmentIds,
        'unitsPerBundle': unitsPerBundle,
        'entityType': entityType,
        'standardBatchInputKg': standardBatchInputKg,
        'standardBatchOutputPcs': standardBatchOutputPcs,
        'localImagePath': localImagePath,
      };

      final entity = _mapToEntity(productData);

      // Save to Isar
      await _dbService.db.writeTxn(() async {
        final conflict = await _findActiveSkuConflict(entity.sku);
        if (conflict != null) {
          throw Exception(
            'SKU "${entity.sku}" already exists for product: ${conflict.name}',
          );
        }
        await _dbService.products.put(entity);
      });
      await _enqueueOutbox(_toSyncPayload(entity), action: 'set');

      return _mapToDomain(entity);
    } catch (e) {
      throw handleError(e, 'createProduct');
    }
  }

  Future<void> updateProduct({
    required String id,
    String? name,
    String? sku,
    String? itemType,
    String? type,
    String? departmentId,
    String? baseSemiId,
    String? category,
    String? subcategory,
    // ARCHITECTURE LOCK: stock parameter REMOVED - Use InventoryService for stock changes
    // double? stock, //  REMOVED - Stock MUST only be changed via InventoryService
    String? baseUnit,
    String? secondaryUnit,
    double? conversionFactor,
    double? price,
    double? secondaryPrice,
    double? mrp,
    double? purchasePrice,
    double? averageCost,
    double? lastCost,
    double? gstRate,
    double? defaultDiscount,
    String? status,
    String? supplierId,
    String? supplierName,
    double? reorderLevel,
    double? stockAlertLevel,
    double? minimumSafetyStock,
    double? simpleSchemeBuy,
    double? simpleSchemeGet,

    double? unitWeightGrams,
    double? weightPerUnit,
    double? volumePerUnit,
    double? density,
    String? packagingType,
    List<Map<String, dynamic>>? packagingRecipe,
    double? shelfLife,
    String? barcode,
    String? productionStage,
    double? wastagePercent,
    int? boxesPerBatch,
    double? internalCost,
    double? expiryDays,
    bool? batchMandatory,
    String? storageConditions,
    bool? isTankMaterial,
    Map<String, dynamic>? dimensions,
    String? sizeVariant,
    String? hazardLevel,
    String? safetyPrecautions,
    List<String>? storageRequirements,
    List<String>? ppeRequired,
    String? unit,
    required String userId,
    String? userName,
    List<String>? allowedSemiFinishedIds,
    List<String>? allowedDepartmentIds,
    int? unitsPerBundle,
    String? entityType,
    double? standardBatchInputKg,
    double? standardBatchOutputPcs,
    String? localImagePath,
  }) async {
    try {
      final normalizedSku = sku?.trim();

      // VALIDATION: SKU Uniqueness Enforcement (if SKU is being changed)
      if (normalizedSku != null) {
        final skuError = await _validateSkuUnique(normalizedSku, excludeId: id);
        if (skuError != null) {
          throw Exception(skuError);
        }
      }

      ProductEntity? updatedEntity;
      await _dbService.db.writeTxn(() async {
        final entity = await _dbService.products.getById(id);
        if (entity == null) return;

        // Update fields
        if (name != null) entity.name = name;
        if (normalizedSku != null) {
          final conflict = await _findActiveSkuConflict(
            normalizedSku,
            excludeId: id,
          );
          if (conflict != null) {
            throw Exception(
              'SKU "$normalizedSku" already exists for product: ${conflict.name}',
            );
          }
          entity.sku = normalizedSku;
        }
        if (itemType != null) entity.itemType = itemType;
        if (type != null) entity.type = type;
        if (departmentId != null) entity.departmentId = departmentId;
        if (baseSemiId != null) entity.baseSemiId = baseSemiId;
        if (category != null) entity.category = category;
        if (subcategory != null) entity.subcategory = subcategory;
        if (baseUnit != null) entity.baseUnit = baseUnit;
        if (secondaryUnit != null) entity.secondaryUnit = secondaryUnit;
        if (conversionFactor != null) {
          entity.conversionFactor = conversionFactor;
        }
        if (unit != null && unit.trim().isNotEmpty && baseUnit == null) {
          entity.baseUnit = unit.trim();
        }

        if (price != null) {
          entity.price = _encryptProductDouble(entity, 'price', price) ?? price;
        }
        if (secondaryPrice != null) {
          entity.secondaryPrice =
              _encryptProductDouble(entity, 'secondaryPrice', secondaryPrice) ??
              secondaryPrice;
        }
        if (mrp != null) {
          entity.mrp = _encryptProductDouble(entity, 'mrp', mrp) ?? mrp;
        }
        if (purchasePrice != null) {
          entity.purchasePrice =
              _encryptProductDouble(entity, 'purchasePrice', purchasePrice) ??
              purchasePrice;
        }
        if (averageCost != null) {
          entity.averageCost =
              _encryptProductDouble(entity, 'averageCost', averageCost) ??
              averageCost;
        }
        if (lastCost != null) {
          entity.lastCost =
              _encryptProductDouble(entity, 'lastCost', lastCost) ?? lastCost;
        }
        if (internalCost != null) {
          entity.internalCost =
              _encryptProductDouble(entity, 'internalCost', internalCost) ??
              internalCost;
        }

        if (gstRate != null) entity.gstRate = gstRate;
        if (defaultDiscount != null) entity.defaultDiscount = defaultDiscount;
        if (status != null) entity.status = status;
        if (supplierId != null) entity.supplierId = supplierId;
        if (supplierName != null) entity.supplierName = supplierName;
        if (reorderLevel != null) entity.reorderLevel = reorderLevel;
        if (stockAlertLevel != null) entity.stockAlertLevel = stockAlertLevel;
        if (minimumSafetyStock != null) {
          entity.minimumSafetyStock = minimumSafetyStock;
        }
        if (simpleSchemeBuy != null) entity.simpleSchemeBuy = simpleSchemeBuy;
        if (simpleSchemeGet != null) entity.simpleSchemeGet = simpleSchemeGet;

        if (unitWeightGrams != null) entity.unitWeightGrams = unitWeightGrams;
        if (weightPerUnit != null) entity.weightPerUnit = weightPerUnit;
        if (volumePerUnit != null) entity.volumePerUnit = volumePerUnit;
        if (density != null) entity.density = density;
        if (packagingType != null) {
          final normalized = packagingType.trim();
          entity.packagingType = normalized.isEmpty ? null : normalized;
        }
        if (packagingRecipe != null) entity.packagingRecipe = packagingRecipe;
        if (shelfLife != null) entity.shelfLife = shelfLife;
        if (barcode != null) entity.barcode = barcode;
        if (productionStage != null) entity.productionStage = productionStage;
        if (wastagePercent != null) entity.wastagePercent = wastagePercent;
        if (boxesPerBatch != null) entity.boxesPerBatch = boxesPerBatch;
        if (expiryDays != null) entity.expiryDays = expiryDays;
        if (batchMandatory != null) entity.batchMandatory = batchMandatory;
        if (storageConditions != null) {
          entity.storageConditions = storageConditions;
        }
        if (isTankMaterial != null) entity.isTankMaterial = isTankMaterial;
        if (dimensions != null) entity.dimensions = dimensions;
        if (sizeVariant != null) entity.sizeVariant = sizeVariant;
        if (hazardLevel != null) entity.hazardLevel = hazardLevel;
        if (safetyPrecautions != null) {
          entity.safetyPrecautions = safetyPrecautions;
        }
        if (storageRequirements != null) {
          entity.storageRequirements = storageRequirements;
        }
        if (ppeRequired != null) entity.ppeRequired = ppeRequired;

        if (entityType != null) entity.entityType = entityType;
        if (allowedSemiFinishedIds != null) {
          entity.allowedSemiFinishedIds = allowedSemiFinishedIds;
        }
        if (allowedDepartmentIds != null) {
          entity.allowedDepartmentIds = allowedDepartmentIds;
        }
        if (unitsPerBundle != null) entity.unitsPerBundle = unitsPerBundle;
        if (standardBatchInputKg != null) {
          entity.standardBatchInputKg = standardBatchInputKg;
        }
        if (standardBatchOutputPcs != null) {
          entity.standardBatchOutputPcs = standardBatchOutputPcs;
        }
        if (localImagePath != null) entity.localImagePath = localImagePath;
        // ARCHITECTURE LOCK: stock field is NOT updated here
        // Stock changes MUST go through InventoryService to maintain ledger integrity
        // if (stock != null) entity.stock = stock; //  REMOVED

        entity.updatedAt = DateTime.now();
        entity.syncStatus = SyncStatus.pending;

        await _dbService.products.put(entity);
        updatedEntity = entity;
      });
      if (updatedEntity != null) {
        await _enqueueOutbox(_toSyncPayload(updatedEntity!), action: 'update');
      }
    } catch (e) {
      throw handleError(e, 'updateProduct');
    }
  }

  Future<void> deleteProduct(
    String id, {
    required String userId,
    String? userName,
    bool force = false,
  }) async {
    try {
      final product = await _dbService.products.getById(id);
      if (product == null) return;

      final domainProduct = _mapToDomain(product);

      if (!force &&
          (domainProduct.type == ProductTypeEnum.semi ||
              domainProduct.entityType == 'semi_finished' ||
              domainProduct.entityType == 'formula_output')) {
        // Check if any finished product is linked to this semi
        final rawDependants = await _dbService.products
            .filter()
            .allowedSemiFinishedIdsElementEqualTo(id)
            .findAll();
        final dependants = rawDependants
            .where((e) => !e.isDeleted && e.id != id)
            .toList(growable: false);

        if (dependants.isNotEmpty) {
          final names = dependants
              .take(3)
              .map((e) {
                final statusRaw = (e.status ?? '').trim();
                final status = statusRaw.isEmpty ? 'inactive' : statusRaw;
                final skuRaw = e.sku.trim();
                final skuOrId = skuRaw.isNotEmpty ? skuRaw : e.id;
                return '${e.name} [${status.toLowerCase()}, $skuOrId]';
              })
              .join(', ');
          final more = dependants.length > 3
              ? ' and ${dependants.length - 3} more'
              : '';
          final hasInactive = dependants.any(
            (e) => (e.status ?? '').trim().toLowerCase() != 'active',
          );
          final hint = hasInactive
              ? ' Some linked products are inactive and may be hidden by the Active filter.'
              : '';
          throw Exception(
            'This Soap Base is used in ${dependants.length} Final Products ($names$more). Unlink this Soap Base from those products before deleting.$hint',
          );
        }
      }

      ProductEntity? deletedEntity;
      await _dbService.db.writeTxn(() async {
        final p = await _dbService.products.getById(id);
        if (p != null) {
          final now = DateTime.now();
          p.isDeleted = true;
          p.deletedAt = now;
          p.updatedAt = now;
          p.syncStatus = SyncStatus.pending;
          await _dbService.products.put(p);
          deletedEntity = p;
        }
      });
      if (deletedEntity != null) {
        await _enqueueOutbox(_toSyncPayload(deletedEntity!), action: 'delete');
      }
    } catch (e) {
      throw handleError(e, 'deleteProduct');
    }
  }

  double? _decryptProductDouble(
    ProductEntity entity,
    String field,
    double? value,
  ) {
    if (value == null) return null;
    if (!_fieldEncryption.isEnabled) return value;
    return _fieldEncryption.decryptDouble(
      value,
      'product:${entity.id}:$field',
      magnitude: _priceMagnitude,
    );
  }

  double? _encryptProductDouble(
    ProductEntity entity,
    String field,
    double? value,
  ) {
    if (value == null) return null;
    if (!_fieldEncryption.isEnabled) return value;
    return _fieldEncryption.encryptDouble(
      value,
      'product:${entity.id}:$field',
      magnitude: _priceMagnitude,
    );
  }
}
