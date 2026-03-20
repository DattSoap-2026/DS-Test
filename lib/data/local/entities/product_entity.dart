import 'dart:convert';
import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
import 'package:flutter_app/models/types/product_types.dart';
import '../../../services/field_encryption_service.dart';

part 'product_entity.g.dart';

@Collection()
class ProductEntity extends BaseEntity {
  // ARCHITECTURE LOCK: Formula-Inventory Separation
  // This entity MUST NOT contain any 'recipe' or 'formula' fields.
  // ---------------------------------------------------------------------------

  @Index()
  late String name;

  @Index()
  late String sku;

  DateTime? createdAt;

  late String itemType; // ProductType value
  late String type; // ProductTypeEnum name

  @Index()
  String? category;
  double? stock;

  late String baseUnit;
  String? secondaryUnit;
  double? conversionFactor;

  double? price;

  // Storage for complex objects as JSON strings if needed, or simplied fields
  @Index()
  String? status;
  String? supplierName;

  String? description;
  String? imageUrl; // if any
  String? localImagePath; // Local asset path for bundled images

  // Offline critical fields
  double? minimumSafetyStock;
  double? reorderLevel;

  // Additional Fields
  String? subcategory;
  String? departmentId;
  String? baseSemiId;
  double? secondaryPrice;
  double? mrp;
  double? purchasePrice;
  double? averageCost;
  double? lastCost;
  double? gstRate;
  double? defaultDiscount;
  @Index()
  String? supplierId;
  double? stockAlertLevel;
  double? simpleSchemeBuy;
  double? simpleSchemeGet;

  // Technical Specs
  double? unitWeightGrams;
  double? weightPerUnit;
  double? volumePerUnit;
  double? density;

  String? packagingType;
  // Packaging recipe stored as JSON string or implementation specific - using List<String> for simplicity if just IDs,
  // but Service maps Map<String, dynamic>. Isar doesn't support List<Map>, so we might need a workaround or specific Embedded.
  // Service code tries to assign List<Map>. This won't work with Isar directly unless we use a wrapper or ignore it for now.
  // Actually, let's check Service usage: entity.packagingRecipe = list of maps.
  // Isar cannot persist List<Map>. We should likely ignore persistent of complex packagingRecipe for this step
  // OR change it to a String (JSON). Service treats it as List<Map>.
  // I will define it as generic List<String>? for now to satisfy simple assignment if it was just IDs,
  // BUT the Service tries to assign List<Map>. This is a type mismatch error waiting to happen.
  // I will add [Ignore] or use a setter that converts to JSON.

  /// Persisted JSON string for packaging BOM (works offline)
  String? packagingRecipeJson;

  /// In-memory list, backed by [packagingRecipeJson] — use this in code
  @Ignore()
  List<Map<String, dynamic>>? get packagingRecipe {
    if (packagingRecipeJson == null || packagingRecipeJson!.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(packagingRecipeJson!) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  set packagingRecipe(List<Map<String, dynamic>>? value) {
    packagingRecipeJson = value == null ? null : jsonEncode(value);
  }

  double? shelfLife;
  String? barcode;
  String? productionStage;
  double? wastagePercent;
  int? boxesPerBatch;
  double? internalCost;
  double? expiryDays;
  bool? batchMandatory;
  String? storageConditions;
  bool? isTankMaterial;

  // Dimensions handled as string or ignored for now if Map
  @Ignore()
  Map<String, dynamic>? dimensions;

  String? sizeVariant;
  String? hazardLevel;
  String? safetyPrecautions;
  List<String>? storageRequirements;
  List<String>? ppeRequired;

  List<String>? allowedSemiFinishedIds;
  List<String>? allowedDepartmentIds;
  int? unitsPerBundle;
  String? entityType;
  double? standardBatchInputKg;
  double? standardBatchOutputPcs;

  // Semi-Finished Production Formula (JSON: [{"rmId": "...", "qty": 5, "unit": "Kg"}])
  String? productionFormula;
  double? expectedOutputQty;
  double? productionLossPercent;
  bool? batchTrackingEnabled;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'sku': sku,
      'createdAt': createdAt?.toIso8601String(),
      'itemType': itemType,
      'type': type,
      'category': category,
      'stock': stock,
      'baseUnit': baseUnit,
      'secondaryUnit': secondaryUnit,
      'conversionFactor': conversionFactor,
      'price': price,
      'status': status,
      'supplierName': supplierName,
      'description': description,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'minimumSafetyStock': minimumSafetyStock,
      'reorderLevel': reorderLevel,
      'subcategory': subcategory,
      'departmentId': departmentId,
      'baseSemiId': baseSemiId,
      'secondaryPrice': secondaryPrice,
      'mrp': mrp,
      'purchasePrice': purchasePrice,
      'averageCost': averageCost,
      'lastCost': lastCost,
      'gstRate': gstRate,
      'defaultDiscount': defaultDiscount,
      'supplierId': supplierId,
      'stockAlertLevel': stockAlertLevel,
      'simpleSchemeBuy': simpleSchemeBuy,
      'simpleSchemeGet': simpleSchemeGet,
      'unitWeightGrams': unitWeightGrams,
      'weightPerUnit': weightPerUnit,
      'volumePerUnit': volumePerUnit,
      'density': density,
      'packagingType': packagingType,
      'packagingRecipeJson': packagingRecipeJson,
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
      'allowedSemiFinishedIds': allowedSemiFinishedIds,
      'allowedDepartmentIds': allowedDepartmentIds,
      'unitsPerBundle': unitsPerBundle,
      'entityType': entityType,
      'standardBatchInputKg': standardBatchInputKg,
      'standardBatchOutputPcs': standardBatchOutputPcs,
      'productionFormula': productionFormula,
      'expectedOutputQty': expectedOutputQty,
      'productionLossPercent': productionLossPercent,
      'batchTrackingEnabled': batchTrackingEnabled,
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  /// Builds an entity from a sync-safe json map.
  static ProductEntity fromJson(Map<String, dynamic> json) {
    final entity = ProductEntity()
      ..id = parseString(
        json['id'] ?? json['firebaseId'],
        fallback: '',
      )
      ..name = parseString(json['name'])
      ..sku = parseString(json['sku'])
      ..createdAt = parseDateOrNull(json['createdAt'])
      ..itemType = parseString(json['itemType'])
      ..type = parseString(json['type'])
      ..category = parseString(json['category'], fallback: '')
      ..stock = json['stock'] == null ? 0.0 : parseDouble(json['stock'])
      ..baseUnit = parseString(json['baseUnit'])
      ..secondaryUnit = parseString(json['secondaryUnit'], fallback: '')
      ..conversionFactor = json['conversionFactor'] == null
          ? 1.0
          : parseDouble(json['conversionFactor'])
      ..price = json['price'] == null ? 0.0 : parseDouble(json['price'])
      ..status = parseString(json['status'], fallback: '')
      ..supplierName = parseString(json['supplierName'], fallback: '')
      ..description = parseString(json['description'], fallback: '')
      ..imageUrl = parseString(json['imageUrl'], fallback: '')
      ..localImagePath = parseString(json['localImagePath'], fallback: '')
      ..minimumSafetyStock = json['minimumSafetyStock'] == null
          ? null
          : parseDouble(json['minimumSafetyStock'])
      ..reorderLevel = json['reorderLevel'] == null
          ? null
          : parseDouble(json['reorderLevel'])
      ..subcategory = parseString(json['subcategory'], fallback: '')
      ..departmentId = parseString(json['departmentId'], fallback: '')
      ..baseSemiId = parseString(json['baseSemiId'], fallback: '')
      ..secondaryPrice = json['secondaryPrice'] == null
          ? null
          : parseDouble(json['secondaryPrice'])
      ..mrp = json['mrp'] == null ? null : parseDouble(json['mrp'])
      ..purchasePrice = json['purchasePrice'] == null
          ? null
          : parseDouble(json['purchasePrice'])
      ..averageCost = json['averageCost'] == null
          ? null
          : parseDouble(json['averageCost'])
      ..lastCost = json['lastCost'] == null
          ? null
          : parseDouble(json['lastCost'])
      ..gstRate = json['gstRate'] == null
          ? null
          : parseDouble(json['gstRate'])
      ..defaultDiscount = json['defaultDiscount'] == null
          ? null
          : parseDouble(json['defaultDiscount'])
      ..supplierId = parseString(json['supplierId'], fallback: '')
      ..stockAlertLevel = json['stockAlertLevel'] == null
          ? null
          : parseDouble(json['stockAlertLevel'])
      ..simpleSchemeBuy = json['simpleSchemeBuy'] == null
          ? null
          : parseDouble(json['simpleSchemeBuy'])
      ..simpleSchemeGet = json['simpleSchemeGet'] == null
          ? null
          : parseDouble(json['simpleSchemeGet'])
      ..unitWeightGrams = json['unitWeightGrams'] == null
          ? null
          : parseDouble(json['unitWeightGrams'])
      ..weightPerUnit = json['weightPerUnit'] == null
          ? null
          : parseDouble(json['weightPerUnit'])
      ..volumePerUnit = json['volumePerUnit'] == null
          ? null
          : parseDouble(json['volumePerUnit'])
      ..density = json['density'] == null ? null : parseDouble(json['density'])
      ..packagingType = parseString(json['packagingType'], fallback: '')
      ..packagingRecipeJson = parseString(
        json['packagingRecipeJson'],
        fallback: '',
      )
      ..shelfLife = json['shelfLife'] == null
          ? null
          : parseDouble(json['shelfLife'])
      ..barcode = parseString(json['barcode'], fallback: '')
      ..productionStage = parseString(json['productionStage'], fallback: '')
      ..wastagePercent = json['wastagePercent'] == null
          ? null
          : parseDouble(json['wastagePercent'])
      ..boxesPerBatch = json['boxesPerBatch'] == null
          ? null
          : parseInt(json['boxesPerBatch'])
      ..internalCost = json['internalCost'] == null
          ? null
          : parseDouble(json['internalCost'])
      ..expiryDays = json['expiryDays'] == null
          ? null
          : parseDouble(json['expiryDays'])
      ..batchMandatory = json['batchMandatory'] == null
          ? null
          : parseBool(json['batchMandatory'])
      ..storageConditions = parseString(json['storageConditions'], fallback: '')
      ..isTankMaterial = json['isTankMaterial'] == null
          ? null
          : parseBool(json['isTankMaterial'])
      ..sizeVariant = parseString(json['sizeVariant'], fallback: '')
      ..hazardLevel = parseString(json['hazardLevel'], fallback: '')
      ..safetyPrecautions = parseString(
        json['safetyPrecautions'],
        fallback: '',
      )
      ..storageRequirements = parseStringList(json['storageRequirements'])
      ..ppeRequired = parseStringList(json['ppeRequired'])
      ..allowedSemiFinishedIds = parseStringList(
        json['allowedSemiFinishedIds'],
      )
      ..allowedDepartmentIds = parseStringList(json['allowedDepartmentIds'])
      ..unitsPerBundle = json['unitsPerBundle'] == null
          ? null
          : parseInt(json['unitsPerBundle'])
      ..entityType = parseString(json['entityType'], fallback: '')
      ..standardBatchInputKg = json['standardBatchInputKg'] == null
          ? null
          : parseDouble(json['standardBatchInputKg'])
      ..standardBatchOutputPcs = json['standardBatchOutputPcs'] == null
          ? null
          : parseDouble(json['standardBatchOutputPcs'])
      ..productionFormula = parseString(json['productionFormula'], fallback: '')
      ..expectedOutputQty = json['expectedOutputQty'] == null
          ? null
          : parseDouble(json['expectedOutputQty'])
      ..productionLossPercent = json['productionLossPercent'] == null
          ? null
          : parseDouble(json['productionLossPercent'])
      ..batchTrackingEnabled = json['batchTrackingEnabled'] == null
          ? null
          : parseBool(json['batchTrackingEnabled'])
      ..updatedAt = parseDate(
        json['updatedAt'] ?? json['lastModified'],
      )
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');

    final rawDimensions = json['dimensions'];
    if (rawDimensions is Map) {
      entity.dimensions = Map<String, dynamic>.from(rawDimensions);
    }

    return entity;
  }

  Product toDomain() {
    final priceValue = _decryptDouble(price, 'price') ?? 0.0;
    final secondaryPriceValue = _decryptDouble(
      secondaryPrice,
      'secondaryPrice',
    );
    final mrpValue = _decryptDouble(mrp, 'mrp');
    final purchasePriceValue = _decryptDouble(purchasePrice, 'purchasePrice');
    final averageCostValue = _decryptDouble(averageCost, 'averageCost');
    final lastCostValue = _decryptDouble(lastCost, 'lastCost');
    final internalCostValue = _decryptDouble(internalCost, 'internalCost');

    return Product(
      id: id,
      name: name,
      sku: sku,
      itemType: ProductType.fromString(itemType),
      type: ProductTypeEnum.values.firstWhere(
        (e) => e.name.toLowerCase() == type.toLowerCase(),
        orElse: () => ProductTypeEnum.raw,
      ),
      departmentId: departmentId,
      baseSemiId: baseSemiId,
      category: category ?? '',
      stock: stock ?? 0.0,
      baseUnit: baseUnit,
      secondaryUnit: secondaryUnit,
      conversionFactor: conversionFactor ?? 1.0,
      price: priceValue,
      secondaryPrice: secondaryPriceValue,
      mrp: mrpValue,
      purchasePrice: purchasePriceValue,
      averageCost: averageCostValue,
      lastCost: lastCostValue,
      gstRate: gstRate,
      defaultDiscount: defaultDiscount,
      internalCost: internalCostValue,
      status: status ?? 'active',
      createdAt:
          createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(), // Fallback
      updatedAt: updatedAt.toIso8601String(),
      supplierId: supplierId,
      supplierName: supplierName,
      stockAlertLevel: stockAlertLevel,
      simpleSchemeBuy: simpleSchemeBuy,
      simpleSchemeGet: simpleSchemeGet,
      unitWeightGrams: unitWeightGrams ?? 0.0,
      weightPerUnit: weightPerUnit,
      volumePerUnit: volumePerUnit,
      density: density,
      shelfLife: shelfLife,
      barcode: barcode,
      wastagePercent: wastagePercent,
      boxesPerBatch: boxesPerBatch,
      expiryDays: expiryDays,
      batchMandatory: batchMandatory,
      isTankMaterial: isTankMaterial,
      sizeVariant: sizeVariant,
      safetyPrecautions: safetyPrecautions,
      storageRequirements: storageRequirements,
      ppeRequired: ppeRequired,
      minimumSafetyStock: minimumSafetyStock,
      reorderLevel: reorderLevel,
      allowedSemiFinishedIds: allowedSemiFinishedIds ?? const <String>[],
      allowedDepartmentIds: allowedDepartmentIds ?? const <String>[],
      unitsPerBundle: unitsPerBundle,
      entityType: entityType,
      localImagePath: localImagePath,
      standardBatchInputKg: standardBatchInputKg,
      standardBatchOutputPcs: standardBatchOutputPcs,
    );
  }

  void encryptSensitiveFields() {
    final fieldEncryption = FieldEncryptionService.instance;
    if (!fieldEncryption.isEnabled) return;

    price = _encryptDouble(price, 'price');
    secondaryPrice = _encryptDouble(secondaryPrice, 'secondaryPrice');
    mrp = _encryptDouble(mrp, 'mrp');
    purchasePrice = _encryptDouble(purchasePrice, 'purchasePrice');
    averageCost = _encryptDouble(averageCost, 'averageCost');
    lastCost = _encryptDouble(lastCost, 'lastCost');
    internalCost = _encryptDouble(internalCost, 'internalCost');
  }

  double? _decryptDouble(double? value, String field) {
    if (value == null) return null;
    final fieldEncryption = FieldEncryptionService.instance;
    if (!fieldEncryption.isEnabled) return value;
    return fieldEncryption.decryptDouble(value, _ctx(field), magnitude: 1e5);
  }

  double? _encryptDouble(double? value, String field) {
    if (value == null) return null;
    final fieldEncryption = FieldEncryptionService.instance;
    if (!fieldEncryption.isEnabled) return value;
    return fieldEncryption.encryptDouble(value, _ctx(field), magnitude: 1e5);
  }

  String _ctx(String field) => 'product:$id:$field';
}
