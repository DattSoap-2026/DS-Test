// ============================================
// CUTTING & FINISHED GOODS TYPES
// ============================================

/// Cutting workflow stages
enum CuttingStage {
  pending, // Entry created, not yet started
  inProgress, // Cutting in progress
  completed, // Cutting completed
  rejected; // Rejected for quality issues

  String get value {
    switch (this) {
      case CuttingStage.pending:
        return 'PENDING';
      case CuttingStage.inProgress:
        return 'IN_PROGRESS';
      case CuttingStage.completed:
        return 'COMPLETED';
      case CuttingStage.rejected:
        return 'REJECTED';
    }
  }
}

CuttingStage cuttingStageFromString(String value) {
  switch (value.toUpperCase()) {
    case 'PENDING':
      return CuttingStage.pending;
    case 'IN_PROGRESS':
      return CuttingStage.inProgress;
    case 'COMPLETED':
      return CuttingStage.completed;
    case 'REJECTED':
      return CuttingStage.rejected;
    default:
      return CuttingStage.pending;
  }
}

/// Waste type classification
enum WasteType {
  scrap, // Non-reusable waste
  reprocess; // Can be reprocessed

  String get value {
    switch (this) {
      case WasteType.scrap:
        return 'SCRAP';
      case WasteType.reprocess:
        return 'REPROCESS';
    }
  }
}

WasteType wasteTypeFromString(String value) {
  switch (value.toUpperCase()) {
    case 'SCRAP':
      return WasteType.scrap;
    case 'REPROCESS':
      return WasteType.reprocess;
    default:
      return WasteType.scrap;
  }
}

/// Shift type - Simplified to single day shift
enum ShiftType {
  day; // Standard Day Shift

  String get value {
    return 'DAY';
  }

  String get displayName {
    return 'Day Shift';
  }
}

ShiftType shiftTypeFromString(String value) {
  // Map legacy values to day
  return ShiftType.day;
}

/// Cutting Batch Weight Validation Result
class WeightValidation {
  final bool isValid;
  final String message;
  final double actualWeight;
  final double standardWeight;
  final double tolerance;
  final double difference;

  WeightValidation({
    required this.isValid,
    required this.message,
    required this.actualWeight,
    required this.standardWeight,
    required this.tolerance,
    required this.difference,
  });
}

/// Cutting Batch Record
/// Core entity for the cutting & finished goods workflow
class CuttingBatch {
  final String id;
  final String batchNumber; // Auto-generated
  final String batchGeneId; // SHA256 for genealogy tracking

  // Date & Shift Info
  final DateTime date;
  final ShiftType shift;
  final String departmentId;
  final String departmentName; // "Bhatti" or "Gita Shed"
  final String operatorId;
  final String operatorName;

  // Semi-Finished Input
  final String semiFinishedProductId;
  final String semiFinishedProductName;
  final double totalBatchWeightKg; // Total input weight (source of truth)
  final int boxesCount;
  final double? avgBoxWeightKg; // Auto-calculated

  // Finished Goods Configuration
  final String finishedGoodId;
  final String finishedGoodName;
  final double standardWeightGm; // From product master
  final double actualAvgWeightGm; // Manually entered
  final double tolerancePercent; // From product master

  // Production Output
  final int unitsProduced;
  final double totalFinishedWeightKg; // Auto: (Units × Avg Weight) / 1000
  final bool weightValidationPassed;
  final String? weightValidationMessage;

  // Cutting Waste Tracking
  final double cuttingWasteKg;
  final WasteType wasteType;
  final String? wasteRemark;

  // Weight Balance (Auto-calculated)
  final double inputWeightKg;
  final double outputWeightKg;
  final double wasteWeightKg;
  final double weightDifferenceKg;
  final double weightDifferencePercent;
  final bool weightBalanceValid; // ≤ 0.5%

  // Status
  final CuttingStage stage;

  // Inventory Impact (Auto-recorded)
  final bool semiFinishedStockAdjusted;
  final bool finishedGoodsStockAdjusted;
  final bool wasteStockAdjusted;

  // Audit
  final String supervisorId;
  final String supervisorName;
  final List<Map<String, dynamic>>? packagingConsumptions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? rejectionReason;

  CuttingBatch({
    required this.id,
    required this.batchNumber,
    required this.batchGeneId,
    required this.date,
    required this.shift,
    required this.departmentId,
    required this.departmentName,
    required this.operatorId,
    required this.operatorName,
    required this.semiFinishedProductId,
    required this.semiFinishedProductName,
    required this.totalBatchWeightKg,
    required this.boxesCount,
    this.avgBoxWeightKg,
    required this.finishedGoodId,
    required this.finishedGoodName,
    required this.standardWeightGm,
    required this.actualAvgWeightGm,
    required this.tolerancePercent,
    required this.unitsProduced,
    required this.totalFinishedWeightKg,
    required this.weightValidationPassed,
    this.weightValidationMessage,
    required this.cuttingWasteKg,
    required this.wasteType,
    this.wasteRemark,
    required this.inputWeightKg,
    required this.outputWeightKg,
    required this.wasteWeightKg,
    required this.weightDifferenceKg,
    required this.weightDifferencePercent,
    required this.weightBalanceValid,
    required this.stage,
    required this.semiFinishedStockAdjusted,
    required this.finishedGoodsStockAdjusted,
    required this.wasteStockAdjusted,
    required this.supervisorId,
    required this.supervisorName,
    this.packagingConsumptions,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.rejectionReason,
  });

  factory CuttingBatch.fromJson(Map<String, dynamic> json) {
    return CuttingBatch(
      id: json['id'] ?? '',
      batchNumber: json['batchNumber'] ?? '',
      batchGeneId: json['batchGeneId'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      shift: shiftTypeFromString(json['shift'] ?? 'MORNING'),
      departmentId: json['departmentId'] ?? '',
      departmentName: json['departmentName'] ?? '',
      operatorId: json['operatorId'] ?? '',
      operatorName: json['operatorName'] ?? '',
      semiFinishedProductId: json['semiFinishedProductId'] ?? '',
      semiFinishedProductName: json['semiFinishedProductName'] ?? '',
      totalBatchWeightKg:
          (json['totalBatchWeightKg'] as num?)?.toDouble() ?? 0.0,
      boxesCount: json['boxesCount'] as int? ?? 0,
      avgBoxWeightKg: (json['avgBoxWeightKg'] as num?)?.toDouble(),
      finishedGoodId: json['finishedGoodId'] ?? '',
      finishedGoodName: json['finishedGoodName'] ?? '',
      standardWeightGm: (json['standardWeightGm'] as num?)?.toDouble() ?? 0.0,
      actualAvgWeightGm: (json['actualAvgWeightGm'] as num?)?.toDouble() ?? 0.0,
      tolerancePercent: (json['tolerancePercent'] as num?)?.toDouble() ?? 0.0,
      unitsProduced: json['unitsProduced'] as int? ?? 0,
      totalFinishedWeightKg:
          (json['totalFinishedWeightKg'] as num?)?.toDouble() ?? 0.0,
      weightValidationPassed: json['weightValidationPassed'] as bool? ?? false,
      weightValidationMessage: json['weightValidationMessage'],
      cuttingWasteKg: (json['cuttingWasteKg'] as num?)?.toDouble() ?? 0.0,
      wasteType: wasteTypeFromString(json['wasteType'] ?? 'SCRAP'),
      wasteRemark: json['wasteRemark'],
      inputWeightKg: (json['inputWeightKg'] as num?)?.toDouble() ?? 0.0,
      outputWeightKg: (json['outputWeightKg'] as num?)?.toDouble() ?? 0.0,
      wasteWeightKg: (json['wasteWeightKg'] as num?)?.toDouble() ?? 0.0,
      weightDifferenceKg:
          (json['weightDifferenceKg'] as num?)?.toDouble() ?? 0.0,
      weightDifferencePercent:
          (json['weightDifferencePercent'] as num?)?.toDouble() ?? 0.0,
      weightBalanceValid: json['weightBalanceValid'] as bool? ?? false,
      stage: cuttingStageFromString(json['stage'] ?? 'PENDING'),
      semiFinishedStockAdjusted:
          json['semiFinishedStockAdjusted'] as bool? ?? false,
      finishedGoodsStockAdjusted:
          json['finishedGoodsStockAdjusted'] as bool? ?? false,
      wasteStockAdjusted: json['wasteStockAdjusted'] as bool? ?? false,
      supervisorId: json['supervisorId'] ?? '',
      supervisorName: json['supervisorName'] ?? '',
      packagingConsumptions: (json['packagingConsumptions'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'batchGeneId': batchGeneId,
      'date': date,
      'shift': shift.value,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'semiFinishedProductId': semiFinishedProductId,
      'semiFinishedProductName': semiFinishedProductName,
      'totalBatchWeightKg': totalBatchWeightKg,
      'boxesCount': boxesCount,
      'avgBoxWeightKg': avgBoxWeightKg,
      'finishedGoodId': finishedGoodId,
      'finishedGoodName': finishedGoodName,
      'standardWeightGm': standardWeightGm,
      'actualAvgWeightGm': actualAvgWeightGm,
      'tolerancePercent': tolerancePercent,
      'unitsProduced': unitsProduced,
      'totalFinishedWeightKg': totalFinishedWeightKg,
      'weightValidationPassed': weightValidationPassed,
      'weightValidationMessage': weightValidationMessage,
      'cuttingWasteKg': cuttingWasteKg,
      'wasteType': wasteType.value,
      'wasteRemark': wasteRemark,
      'inputWeightKg': inputWeightKg,
      'outputWeightKg': outputWeightKg,
      'wasteWeightKg': wasteWeightKg,
      'weightDifferenceKg': weightDifferenceKg,
      'weightDifferencePercent': weightDifferencePercent,
      'weightBalanceValid': weightBalanceValid,
      'stage': stage.value,
      'semiFinishedStockAdjusted': semiFinishedStockAdjusted,
      'finishedGoodsStockAdjusted': finishedGoodsStockAdjusted,
      'wasteStockAdjusted': wasteStockAdjusted,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'packagingConsumptions': packagingConsumptions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  /// Get weight validation status
  WeightValidation getWeightValidation() {
    final minWeight =
        standardWeightGm - (standardWeightGm * tolerancePercent / 100);
    final isValid = actualAvgWeightGm >= minWeight;
    final difference = actualAvgWeightGm - standardWeightGm;

    return WeightValidation(
      isValid: isValid,
      message: isValid
          ? 'Weight validation passed'
          : 'Actual weight (${actualAvgWeightGm.toStringAsFixed(1)} gm) is below minimum (${minWeight.toStringAsFixed(1)} gm)',
      actualWeight: actualAvgWeightGm,
      standardWeight: standardWeightGm,
      tolerance: tolerancePercent,
      difference: difference,
    );
  }

  /// Get weight balance validation (≤ 0.5%)
  bool isWeightBalanceValid() {
    return weightDifferencePercent <= 0.5;
  }
}

/// Daily Production Summary (for reports)
class DailyProductionSummary {
  final String date;
  final ShiftType shift;
  final int totalBatches;
  final double totalInputKg;
  final int totalFinishedUnits;
  final double totalWasteKg;
  final double yieldPercent;
  final double avgEfficiency;

  DailyProductionSummary({
    required this.date,
    required this.shift,
    required this.totalBatches,
    required this.totalInputKg,
    required this.totalFinishedUnits,
    required this.totalWasteKg,
    required this.yieldPercent,
    required this.avgEfficiency,
  });
}

/// Cutting Yield Report Data
class CuttingYieldReport {
  final String productName;
  final String productId;
  final int batchCount;
  final double totalInputKg;
  final int totalUnitsProduced;
  final double totalWasteKg;
  final double yieldPercent;
  final double avgWeightDifference;
  final List<CuttingBatch> batches;

  CuttingYieldReport({
    required this.productName,
    required this.productId,
    required this.batchCount,
    required this.totalInputKg,
    required this.totalUnitsProduced,
    required this.totalWasteKg,
    required this.yieldPercent,
    required this.avgWeightDifference,
    required this.batches,
  });
}

/// Waste Analysis Report Data
class WasteAnalysisReport {
  final String productName;
  final String productId;
  final double totalWasteKg;
  final double wastePercentage;
  final double scrapKg;
  final double reprocessKg;
  final List<CuttingBatch> batches;

  WasteAnalysisReport({
    required this.productName,
    required this.productId,
    required this.totalWasteKg,
    required this.wastePercentage,
    required this.scrapKg,
    required this.reprocessKg,
    required this.batches,
  });
}

/// Operator Performance Data
class OperatorPerformance {
  final String operatorId;
  final String operatorName;
  final int batchesCompleted;
  final double totalInputKg;
  final int totalUnitsProduced;
  final double avgYieldPercent;
  final double avgWeightAccuracy;
  final double avgWastePercent;

  OperatorPerformance({
    required this.operatorId,
    required this.operatorName,
    required this.batchesCompleted,
    required this.totalInputKg,
    required this.totalUnitsProduced,
    required this.avgYieldPercent,
    required this.avgWeightAccuracy,
    required this.avgWastePercent,
  });
}
