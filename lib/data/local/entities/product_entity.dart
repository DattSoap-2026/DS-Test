import 'dart:convert';
import 'package:isar/isar.dart';
import '../base_entity.dart';
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

  // Getters for Service compatibility if needed

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
