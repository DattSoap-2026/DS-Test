class ProductType {
  final String value;
  const ProductType(this.value);

  static const finishedGood = ProductType('Finished Good');
  static const rawMaterial = ProductType('Raw Material');
  static const tradedGood = ProductType('Traded Good');
  static const semiFinishedGood = ProductType('Semi-Finished Good');
  static const oilsLiquids = ProductType('Oils & Liquids');
  static const packagingMaterial = ProductType('Packaging Material');
  static const chemicalsAdditives = ProductType('Chemicals & Additives');

  static List<ProductType> get values => [
    finishedGood,
    rawMaterial,
    tradedGood,
    semiFinishedGood,
    oilsLiquids,
    packagingMaterial,
    chemicalsAdditives,
  ];

  static ProductType fromString(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return rawMaterial;

    // Return standard instance if it matches directly (case-insensitive)
    for (final type in values) {
      if (type.value.toLowerCase() == raw.toLowerCase()) return type;
    }

    // Canonicalize common legacy/variant labels across devices.
    final normalized = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    bool has(String token) => normalized.contains(token);

    final isSemiLike = has('semi') && (has('finish') || has('finis'));
    if (isSemiLike) return semiFinishedGood;
    if (has('finished good') || has('finished goods') || has('finish good')) {
      return finishedGood;
    }
    if (has('raw')) return rawMaterial;
    if (has('traded')) return tradedGood;
    if (has('packag')) return packagingMaterial;
    if (has('oil') || has('liquid')) return oilsLiquids;
    if (has('chemical') || has('additive')) return chemicalsAdditives;

    return ProductType(raw);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductType &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

enum ProductTypeEnum { raw, semi, finished, traded, packaging }

enum StorageCondition {
  roomTemperature('Room Temperature'),
  cool('Cool'),
  dry('Dry'),
  ventilated('Ventilated'),
  dark('Dark'),
  refrigerated('Refrigerated');

  final String value;
  const StorageCondition(this.value);

  static StorageCondition fromString(String value) {
    return StorageCondition.values.firstWhere(
      (condition) => condition.value == value,
      orElse: () => throw ArgumentError('Invalid StorageCondition: $value'),
    );
  }
}

enum HazardLevel { none, low, medium, high }

enum PackagingType {
  box('Box'),
  carton('Carton'),
  bag('Bag'),
  wrapper('Wrapper'),
  pouch('Pouch'),
  bottle('Bottle'),
  label('Label'),
  shrinkFilm('Shrink Film'),
  tape('Tape'),
  innerLiner('Inner Liner');

  final String value;
  const PackagingType(this.value);

  static PackagingType fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return PackagingType.values.firstWhere(
      (type) =>
          type.value.toLowerCase() == normalized ||
          type.name.toLowerCase() == normalized,
      orElse: () => PackagingType.box,
    );
  }
}

enum ProductionStage {
  bhattiOutput('Bhatti Output'),
  mixing('Mixing'),
  cutting('Cutting'),
  drying('Drying'),
  intermediate('Intermediate');

  final String value;
  const ProductionStage(this.value);

  static ProductionStage fromString(String value) {
    return ProductionStage.values.firstWhere(
      (stage) => stage.value == value,
      orElse: () => throw ArgumentError('Invalid ProductionStage: $value'),
    );
  }
}

class ProductDimensions {
  final double length;
  final double width;
  final double height;
  final String unit;

  ProductDimensions({
    required this.length,
    required this.width,
    required this.height,
    required this.unit,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      length: json['length'].toDouble(),
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'length': length, 'width': width, 'height': height, 'unit': unit};
  }
}

class Product {
  // ARCHITECTURE LOCK: Formula-Inventory Separation
  // This model MUST NOT contain any 'recipe' or 'formula' fields.
  // Formulas are managed exclusively by FormulasService and stored in the 'formulas' collection.
  // Inventory stock is derived from transactions, NEVER from formula calculations.
  // ---------------------------------------------------------------------------

  final String id;
  final String name;
  final String sku;
  final ProductType itemType;
  final ProductTypeEnum type;
  final String? departmentId;
  final String? baseSemiId;
  final String category;
  final String? subcategory;
  final double stock;
  final String baseUnit;
  final String? secondaryUnit;
  final double conversionFactor;
  final double price;
  final double? secondaryPrice;
  final double? mrp;
  final double? purchasePrice;
  final double? averageCost;
  final double? lastCost;
  final double? gstRate;
  final double? defaultDiscount;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final String? supplierId;
  final String? supplierName;
  final double? reorderLevel;
  final double? stockAlertLevel;
  final double? minimumSafetyStock;
  final double? simpleSchemeBuy;
  final double? simpleSchemeGet;

  final double unitWeightGrams;
  final double? maxWeightGrams;
  final double? weightPerUnit;
  final double? volumePerUnit;
  final double? density;
  final PackagingType? packagingType;
  final List<Map<String, dynamic>>? packagingRecipe;
  final double? shelfLife;
  final String? barcode;
  final ProductionStage? productionStage;
  final double? wastagePercent;
  final int? boxesPerBatch;
  final double? internalCost;
  final double? expiryDays;
  final bool? batchMandatory;
  final StorageCondition? storageConditions;
  final bool? isTankMaterial;
  final ProductDimensions? dimensions;
  final String? sizeVariant;
  final HazardLevel? hazardLevel;
  final String? safetyPrecautions;
  final List<String>? storageRequirements;
  final List<String>? ppeRequired;

  final String? unit;
  final String? entityType; // formula_output | semi_finished | finished
  final String? localImagePath; // Local asset path for bundled images

  // New Critical Fields for Production Logic
  final List<String> allowedSemiFinishedIds;
  final List<String> allowedDepartmentIds;
  final int? unitsPerBundle;
  // Standard Production Recipe (Definition)
  final double? standardBatchInputKg;
  final double? standardBatchOutputPcs;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.itemType,
    required this.type,
    this.departmentId,
    this.baseSemiId,
    required this.category,
    this.subcategory,
    required this.stock,
    required this.baseUnit,
    this.secondaryUnit,
    required this.conversionFactor,
    required this.price,
    this.secondaryPrice,
    this.mrp,
    this.purchasePrice,
    this.averageCost,
    this.lastCost,
    this.gstRate,
    this.defaultDiscount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.supplierId,
    this.supplierName,
    this.reorderLevel,
    this.stockAlertLevel,
    this.minimumSafetyStock,
    this.simpleSchemeBuy,
    this.simpleSchemeGet,

    required this.unitWeightGrams,
    this.maxWeightGrams,
    this.weightPerUnit,
    this.volumePerUnit,
    this.density,
    this.packagingType,
    this.packagingRecipe,
    this.shelfLife,
    this.barcode,
    this.productionStage,
    this.wastagePercent,
    this.boxesPerBatch,
    this.internalCost,
    this.expiryDays,
    this.batchMandatory,
    this.storageConditions,
    this.isTankMaterial,
    this.dimensions,
    this.sizeVariant,
    this.hazardLevel,
    this.safetyPrecautions,
    this.storageRequirements,
    this.ppeRequired,
    this.unit,
    this.allowedSemiFinishedIds = const [],
    this.allowedDepartmentIds = const [],
    this.unitsPerBundle,
    this.entityType,
    this.localImagePath,
    this.standardBatchInputKg,
    this.standardBatchOutputPcs,
  });

  factory Product.empty() {
    return Product(
      id: '',
      name: 'Unknown',
      sku: '',
      itemType: ProductType.rawMaterial,
      type: ProductTypeEnum.raw,
      category: 'Uncategorized',
      stock: 0,
      baseUnit: 'unit',
      conversionFactor: 1,
      price: 0,
      status: 'active',
      createdAt: DateTime.now().toIso8601String(),
      unitWeightGrams: 0,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    ProductDimensions? dims;
    if (json['dimensions'] != null) {
      dims = ProductDimensions.fromJson(json['dimensions']);
    }
    final rawLocalImagePath =
        (json['localImagePath'] ?? json['local_image_path'])?.toString();
    final localImagePath = (rawLocalImagePath == null ||
            rawLocalImagePath.trim().isEmpty)
        ? null
        : rawLocalImagePath.trim();

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      itemType: ProductType.fromString(json['itemType'] ?? 'Raw Material'),
      type: ProductTypeEnum.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] ?? 'RAW'),
        orElse: () => ProductTypeEnum.raw,
      ),
      departmentId: json['departmentId'],
      baseSemiId: json['baseSemiId'],
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      stock: (json['stock'] ?? 0).toDouble(),
      baseUnit: json['baseUnit'] ?? '',
      secondaryUnit: json['secondaryUnit'],
      conversionFactor: (json['conversionFactor'] ?? 1).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      secondaryPrice: json['secondaryPrice']?.toDouble(),
      mrp: json['mrp']?.toDouble(),
      purchasePrice: json['purchasePrice']?.toDouble(),
      averageCost: json['averageCost']?.toDouble(),
      lastCost: json['lastCost']?.toDouble(),
      gstRate: json['gstRate']?.toDouble(),
      defaultDiscount: json['defaultDiscount']?.toDouble(),
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      reorderLevel: json['reorderLevel']?.toDouble(),
      stockAlertLevel: json['stockAlertLevel']?.toDouble(),
      minimumSafetyStock: json['minimumSafetyStock']?.toDouble(),
      simpleSchemeBuy: json['simpleSchemeBuy']?.toDouble(),
      simpleSchemeGet: json['simpleSchemeGet']?.toDouble(),

      unitWeightGrams: (json['unitWeightGrams'] ?? 0).toDouble(),
      maxWeightGrams: json['maxWeightGrams']?.toDouble(),
      weightPerUnit: json['weightPerUnit']?.toDouble(),
      volumePerUnit: json['volumePerUnit']?.toDouble(),
      density: json['density']?.toDouble(),
      packagingType:
          (json['packagingType']?.toString().trim().isNotEmpty ?? false)
          ? PackagingType.fromString(json['packagingType'].toString())
          : null,
      packagingRecipe: json['packagingRecipe'] != null
          ? List<Map<String, dynamic>>.from(json['packagingRecipe'])
          : null,
      shelfLife: json['shelfLife']?.toDouble(),
      barcode: json['barcode'],
      productionStage: json['productionStage'] != null
          ? ProductionStage.fromString(json['productionStage'])
          : null,
      wastagePercent: json['wastagePercent']?.toDouble(),
      boxesPerBatch: json['boxesPerBatch'] as int?,
      internalCost: json['internalCost']?.toDouble(),
      expiryDays: json['expiryDays']?.toDouble(),
      batchMandatory: json['batchMandatory'] as bool?,
      storageConditions: json['storageConditions'] != null
          ? StorageCondition.fromString(json['storageConditions'])
          : null,
      isTankMaterial: json['isTankMaterial'] as bool?,
      dimensions: dims,
      sizeVariant: json['sizeVariant'],
      hazardLevel: json['hazardLevel'] != null
          ? HazardLevel.values.firstWhere(
              (e) => e.name == json['hazardLevel'],
              orElse: () => HazardLevel.none,
            )
          : null,
      safetyPrecautions: json['safetyPrecautions'],
      storageRequirements: json['storageRequirements'] != null
          ? List<String>.from(json['storageRequirements'])
          : null,
      ppeRequired: json['ppeRequired'] != null
          ? List<String>.from(json['ppeRequired'])
          : null,
      unit: json['unit'],
      allowedSemiFinishedIds: json['allowedSemiFinishedIds'] != null
          ? List<String>.from(json['allowedSemiFinishedIds'])
          : [],
      allowedDepartmentIds: json['allowedDepartmentIds'] != null
          ? List<String>.from(json['allowedDepartmentIds'])
          : [],
      unitsPerBundle: json['unitsPerBundle'] as int?,
      entityType: json['entityType'] as String?,
      localImagePath: localImagePath,
      standardBatchInputKg: json['standardBatchInputKg']?.toDouble(),
      standardBatchOutputPcs: json['standardBatchOutputPcs']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'itemType': itemType.value,
      'type': type.name.toUpperCase(),
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'reorderLevel': reorderLevel,
      'stockAlertLevel': stockAlertLevel,
      'minimumSafetyStock': minimumSafetyStock,
      'simpleSchemeBuy': simpleSchemeBuy,
      'simpleSchemeGet': simpleSchemeGet,

      'unitWeightGrams': unitWeightGrams,
      'maxWeightGrams': maxWeightGrams,
      'weightPerUnit': weightPerUnit,
      'volumePerUnit': volumePerUnit,
      'density': density,
      'packagingType': packagingType?.value,
      'packagingRecipe': packagingRecipe,
      'shelfLife': shelfLife,
      'barcode': barcode,
      'productionStage': productionStage?.value,
      'wastagePercent': wastagePercent,
      'boxesPerBatch': boxesPerBatch,
      'internalCost': internalCost,
      'expiryDays': expiryDays,
      'batchMandatory': batchMandatory,
      'storageConditions': storageConditions?.value,
      'isTankMaterial': isTankMaterial,
      'dimensions': dimensions?.toJson(),
      'sizeVariant': sizeVariant,
      'hazardLevel': hazardLevel?.name,
      'safetyPrecautions': safetyPrecautions,
      'storageRequirements': storageRequirements,
      'ppeRequired': ppeRequired,
      'unit': unit,
      'allowedSemiFinishedIds': allowedSemiFinishedIds,
      'allowedDepartmentIds': allowedDepartmentIds,
      'unitsPerBundle': unitsPerBundle,
      'entityType': entityType,
      'localImagePath': localImagePath,
      'standardBatchInputKg': standardBatchInputKg,
      'standardBatchOutputPcs': standardBatchOutputPcs,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    ProductType? itemType,
    ProductTypeEnum? type,
    String? departmentId,
    String? baseSemiId,
    String? category,
    String? subcategory,
    double? stock,
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
    String? createdAt,
    String? updatedAt,
    String? supplierId,
    String? supplierName,
    double? reorderLevel,
    double? stockAlertLevel,
    double? minimumSafetyStock,
    double? simpleSchemeBuy,
    double? simpleSchemeGet,

    double? unitWeightGrams,
    double? maxWeightGrams,
    double? weightPerUnit,
    double? volumePerUnit,
    double? density,
    PackagingType? packagingType,
    List<Map<String, dynamic>>? packagingRecipe,
    double? shelfLife,
    String? barcode,
    ProductionStage? productionStage,
    double? wastagePercent,
    int? boxesPerBatch,
    double? internalCost,
    double? expiryDays,
    bool? batchMandatory,
    StorageCondition? storageConditions,
    bool? isTankMaterial,
    ProductDimensions? dimensions,
    String? sizeVariant,
    HazardLevel? hazardLevel,
    String? safetyPrecautions,
    List<String>? storageRequirements,
    List<String>? ppeRequired,
    String? unit,
    List<String>? allowedSemiFinishedIds,
    List<String>? allowedDepartmentIds,
    int? unitsPerBundle,
    String? entityType,
    String? localImagePath,
    double? standardBatchInputKg,
    double? standardBatchOutputPcs,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      itemType: itemType ?? this.itemType,
      type: type ?? this.type,
      departmentId: departmentId ?? this.departmentId,
      baseSemiId: baseSemiId ?? this.baseSemiId,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      stock: stock ?? this.stock,
      baseUnit: baseUnit ?? this.baseUnit,
      secondaryUnit: secondaryUnit ?? this.secondaryUnit,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      price: price ?? this.price,
      secondaryPrice: secondaryPrice ?? this.secondaryPrice,
      mrp: mrp ?? this.mrp,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      averageCost: averageCost ?? this.averageCost,
      lastCost: lastCost ?? this.lastCost,
      gstRate: gstRate ?? this.gstRate,
      defaultDiscount: defaultDiscount ?? this.defaultDiscount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      stockAlertLevel: stockAlertLevel ?? this.stockAlertLevel,
      minimumSafetyStock: minimumSafetyStock ?? this.minimumSafetyStock,
      simpleSchemeBuy: simpleSchemeBuy ?? this.simpleSchemeBuy,
      simpleSchemeGet: simpleSchemeGet ?? this.simpleSchemeGet,

      unitWeightGrams: unitWeightGrams ?? this.unitWeightGrams,
      maxWeightGrams: maxWeightGrams ?? this.maxWeightGrams,
      weightPerUnit: weightPerUnit ?? this.weightPerUnit,
      volumePerUnit: volumePerUnit ?? this.volumePerUnit,
      density: density ?? this.density,
      packagingType: packagingType ?? this.packagingType,
      packagingRecipe: packagingRecipe ?? this.packagingRecipe,
      shelfLife: shelfLife ?? this.shelfLife,
      barcode: barcode ?? this.barcode,
      productionStage: productionStage ?? this.productionStage,
      wastagePercent: wastagePercent ?? this.wastagePercent,
      boxesPerBatch: boxesPerBatch ?? this.boxesPerBatch,
      internalCost: internalCost ?? this.internalCost,
      expiryDays: expiryDays ?? this.expiryDays,
      batchMandatory: batchMandatory ?? this.batchMandatory,
      storageConditions: storageConditions ?? this.storageConditions,
      isTankMaterial: isTankMaterial ?? this.isTankMaterial,
      dimensions: dimensions ?? this.dimensions,
      sizeVariant: sizeVariant ?? this.sizeVariant,
      hazardLevel: hazardLevel ?? this.hazardLevel,
      safetyPrecautions: safetyPrecautions ?? this.safetyPrecautions,
      storageRequirements: storageRequirements ?? this.storageRequirements,
      ppeRequired: ppeRequired ?? this.ppeRequired,
      unit: unit ?? this.unit,
      allowedSemiFinishedIds:
          allowedSemiFinishedIds ?? this.allowedSemiFinishedIds,
      allowedDepartmentIds: allowedDepartmentIds ?? this.allowedDepartmentIds,
      unitsPerBundle: unitsPerBundle ?? this.unitsPerBundle,
      entityType: entityType ?? this.entityType,
      localImagePath: localImagePath ?? this.localImagePath,
      standardBatchInputKg: standardBatchInputKg ?? this.standardBatchInputKg,
      standardBatchOutputPcs:
          standardBatchOutputPcs ?? this.standardBatchOutputPcs,
    );
  }
}
