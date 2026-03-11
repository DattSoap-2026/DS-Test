/// Product Formula for BOM validation
class ProductFormula {
  final String id;
  final String productId;
  final String productName;
  final String departmentId;
  final List<FormulaInput> inputs;
  final List<FormulaOutput> outputs;
  final double expectedYieldPercent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductFormula({
    required this.id,
    required this.productId,
    required this.productName,
    required this.departmentId,
    required this.inputs,
    required this.outputs,
    required this.expectedYieldPercent,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'departmentId': departmentId,
        'inputs': inputs.map((i) => i.toJson()).toList(),
        'outputs': outputs.map((o) => o.toJson()).toList(),
        'expectedYieldPercent': expectedYieldPercent,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ProductFormula.fromJson(Map<String, dynamic> json) => ProductFormula(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        departmentId: json['departmentId'] as String,
        inputs: (json['inputs'] as List)
            .map((i) => FormulaInput.fromJson(i as Map<String, dynamic>))
            .toList(),
        outputs: (json['outputs'] as List)
            .map((o) => FormulaOutput.fromJson(o as Map<String, dynamic>))
            .toList(),
        expectedYieldPercent: (json['expectedYieldPercent'] as num).toDouble(),
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}

class FormulaInput {
  final String materialId;
  final String materialName;
  final double quantityPerBatch;
  final String unit;
  final double tolerancePercent;
  final bool isVolatile;
  final double expectedLossPercent;
  final double lossTolerancePercent;

  FormulaInput({
    required this.materialId,
    required this.materialName,
    required this.quantityPerBatch,
    required this.unit,
    this.tolerancePercent = 5.0,
    this.isVolatile = false,
    this.expectedLossPercent = 0.0,
    this.lossTolerancePercent = 10.0,
  });

  double get expectedRemainingQuantity {
    if (!isVolatile) return quantityPerBatch;
    final loss = quantityPerBatch * (expectedLossPercent / 100);
    return quantityPerBatch - loss;
  }

  Map<String, dynamic> toJson() => {
        'materialId': materialId,
        'materialName': materialName,
        'quantityPerBatch': quantityPerBatch,
        'unit': unit,
        'tolerancePercent': tolerancePercent,
        'isVolatile': isVolatile,
        'expectedLossPercent': expectedLossPercent,
        'lossTolerancePercent': lossTolerancePercent,
      };

  factory FormulaInput.fromJson(Map<String, dynamic> json) => FormulaInput(
        materialId: json['materialId'] as String,
        materialName: json['materialName'] as String,
        quantityPerBatch: (json['quantityPerBatch'] as num).toDouble(),
        unit: json['unit'] as String,
        tolerancePercent:
            (json['tolerancePercent'] as num?)?.toDouble() ?? 5.0,
        isVolatile: json['isVolatile'] as bool? ?? false,
        expectedLossPercent:
            (json['expectedLossPercent'] as num?)?.toDouble() ?? 0.0,
        lossTolerancePercent:
            (json['lossTolerancePercent'] as num?)?.toDouble() ?? 10.0,
      );
}

class FormulaOutput {
  final String productId;
  final String productName;
  final double quantityPerBatch;
  final String unit;

  FormulaOutput({
    required this.productId,
    required this.productName,
    required this.quantityPerBatch,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantityPerBatch': quantityPerBatch,
        'unit': unit,
      };

  factory FormulaOutput.fromJson(Map<String, dynamic> json) => FormulaOutput(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantityPerBatch: (json['quantityPerBatch'] as num).toDouble(),
        unit: json['unit'] as String,
      );
}

class MaterialConsumption {
  final String materialId;
  final String materialName;
  final double plannedQuantity;
  final double actualQuantity;
  final double effectiveQuantity;
  final double lossQuantity;
  final double lossPercent;

  MaterialConsumption({
    required this.materialId,
    required this.materialName,
    required this.plannedQuantity,
    required this.actualQuantity,
    required this.effectiveQuantity,
    required this.lossQuantity,
    required this.lossPercent,
  });
}
