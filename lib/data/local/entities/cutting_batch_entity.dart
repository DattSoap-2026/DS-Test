import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../../models/types/cutting_types.dart';

part 'cutting_batch_entity.g.dart';

@Collection()
class CuttingBatchEntity extends BaseEntity {
  @Index()
  late String batchNumber;

  @Index()
  late String batchGeneId;

  @Index()
  late DateTime date; // Business date

  late String shift;

  late String departmentId;
  late String departmentName;

  late String operatorId;
  late String operatorName;

  @Index()
  late String semiFinishedProductId;
  late String semiFinishedProductName;
  late double totalBatchWeightKg;
  late int boxesCount;
  double? avgBoxWeightKg;

  @Index()
  late String finishedGoodId;
  late String finishedGoodName;
  late double standardWeightGm;
  late double actualAvgWeightGm;
  late double tolerancePercent;

  late int unitsProduced;
  late double totalFinishedWeightKg;
  late bool weightValidationPassed;
  String? weightValidationMessage;

  late double cuttingWasteKg;
  late String wasteType;
  String? wasteRemark;

  late double inputWeightKg;
  late double outputWeightKg;
  late double wasteWeightKg;
  late double weightDifferenceKg;
  late double weightDifferencePercent;
  late bool weightBalanceValid;

  @Index()
  late String stage;

  late bool semiFinishedStockAdjusted;
  late bool finishedGoodsStockAdjusted;
  late bool wasteStockAdjusted;

  late String supervisorId;
  late String supervisorName;

  @ignore
  List<Map<String, dynamic>> packagingConsumptions = [];

  late DateTime createdAt;
  DateTime? completedAt;
  String? rejectionReason;

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'batchGeneId': batchGeneId,
      'date': date.toIso8601String().split('T')[0],
      'shift': shift,
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
      'wasteType': wasteType,
      'wasteRemark': wasteRemark,
      'inputWeightKg': inputWeightKg,
      'outputWeightKg': outputWeightKg,
      'wasteWeightKg': wasteWeightKg,
      'weightDifferenceKg': weightDifferenceKg,
      'weightDifferencePercent': weightDifferencePercent,
      'weightBalanceValid': weightBalanceValid,
      'stage': stage,
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

  static CuttingBatchEntity fromFirebaseJson(Map<String, dynamic> json) {
    final entity = CuttingBatchEntity()
      ..id = json['id'] as String
      ..batchNumber = json['batchNumber'] as String? ?? ''
      ..batchGeneId = json['batchGeneId'] as String? ?? ''
      ..date = json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now()
      ..shift = json['shift'] as String? ?? 'DAY'
      ..departmentId = json['departmentId'] as String? ?? ''
      ..departmentName = json['departmentName'] as String? ?? ''
      ..operatorId = json['operatorId'] as String? ?? ''
      ..operatorName = json['operatorName'] as String? ?? ''
      ..semiFinishedProductId = json['semiFinishedProductId'] as String? ?? ''
      ..semiFinishedProductName =
          json['semiFinishedProductName'] as String? ?? ''
      ..totalBatchWeightKg =
          (json['totalBatchWeightKg'] as num?)?.toDouble() ?? 0.0
      ..boxesCount = (json['boxesCount'] as num?)?.toInt() ?? 0
      ..avgBoxWeightKg = (json['avgBoxWeightKg'] as num?)?.toDouble()
      ..finishedGoodId = json['finishedGoodId'] as String? ?? ''
      ..finishedGoodName = json['finishedGoodName'] as String? ?? ''
      ..standardWeightGm = (json['standardWeightGm'] as num?)?.toDouble() ?? 0.0
      ..actualAvgWeightGm =
          (json['actualAvgWeightGm'] as num?)?.toDouble() ?? 0.0
      ..tolerancePercent = (json['tolerancePercent'] as num?)?.toDouble() ?? 0.0
      ..unitsProduced = (json['unitsProduced'] as num?)?.toInt() ?? 0
      ..totalFinishedWeightKg =
          (json['totalFinishedWeightKg'] as num?)?.toDouble() ?? 0.0
      ..weightValidationPassed =
          json['weightValidationPassed'] as bool? ?? false
      ..weightValidationMessage = json['weightValidationMessage'] as String?
      ..cuttingWasteKg = (json['cuttingWasteKg'] as num?)?.toDouble() ?? 0.0
      ..wasteType = json['wasteType'] as String? ?? 'SCRAP'
      ..wasteRemark = json['wasteRemark'] as String?
      ..inputWeightKg = (json['inputWeightKg'] as num?)?.toDouble() ?? 0.0
      ..outputWeightKg = (json['outputWeightKg'] as num?)?.toDouble() ?? 0.0
      ..wasteWeightKg = (json['wasteWeightKg'] as num?)?.toDouble() ?? 0.0
      ..weightDifferenceKg =
          (json['weightDifferenceKg'] as num?)?.toDouble() ?? 0.0
      ..weightDifferencePercent =
          (json['weightDifferencePercent'] as num?)?.toDouble() ?? 0.0
      ..weightBalanceValid = json['weightBalanceValid'] as bool? ?? false
      ..stage = json['stage'] as String? ?? 'COMPLETED'
      ..semiFinishedStockAdjusted =
          json['semiFinishedStockAdjusted'] as bool? ?? false
      ..finishedGoodsStockAdjusted =
          json['finishedGoodsStockAdjusted'] as bool? ?? false
      ..wasteStockAdjusted = json['wasteStockAdjusted'] as bool? ?? false
      ..supervisorId = json['supervisorId'] as String? ?? ''
      ..supervisorName = json['supervisorName'] as String? ?? ''
      ..packagingConsumptions = (json['packagingConsumptions'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ?? []
      ..createdAt = DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      )
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ??
            json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      )
      ..completedAt = json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null
      ..rejectionReason = json['rejectionReason'] as String?;

    return entity;
  }

  CuttingBatch toDomain() {
    // Note: We need to import the enum and converter if they are not accessible.
    // Assuming they are in lib/models/types/cutting_types.dart which is usually imported.
    return CuttingBatch(
      id: id,
      batchNumber: batchNumber,
      batchGeneId: batchGeneId,
      date: date,
      shift: ShiftType.day, // Simplified as per types.dart
      departmentId: departmentId,
      departmentName: departmentName,
      operatorId: operatorId,
      operatorName: operatorName,
      semiFinishedProductId: semiFinishedProductId,
      semiFinishedProductName: semiFinishedProductName,
      totalBatchWeightKg: totalBatchWeightKg,
      boxesCount: boxesCount,
      avgBoxWeightKg: avgBoxWeightKg,
      finishedGoodId: finishedGoodId,
      finishedGoodName: finishedGoodName,
      standardWeightGm: standardWeightGm,
      actualAvgWeightGm: actualAvgWeightGm,
      tolerancePercent: tolerancePercent,
      unitsProduced: unitsProduced,
      totalFinishedWeightKg: totalFinishedWeightKg,
      weightValidationPassed: weightValidationPassed,
      weightValidationMessage: weightValidationMessage,
      cuttingWasteKg: cuttingWasteKg,
      wasteType: wasteType == 'SCRAP' ? WasteType.scrap : WasteType.reprocess,
      wasteRemark: wasteRemark,
      inputWeightKg: inputWeightKg,
      outputWeightKg: outputWeightKg,
      wasteWeightKg: wasteWeightKg,
      weightDifferenceKg: weightDifferenceKg,
      weightDifferencePercent: weightDifferencePercent,
      weightBalanceValid: weightBalanceValid,
      stage: CuttingStage
          .completed, // Usually recorded as completed in this context
      semiFinishedStockAdjusted: semiFinishedStockAdjusted,
      finishedGoodsStockAdjusted: finishedGoodsStockAdjusted,
      wasteStockAdjusted: wasteStockAdjusted,
      supervisorId: supervisorId,
      supervisorName: supervisorName,
      packagingConsumptions: packagingConsumptions,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      rejectionReason: rejectionReason,
    );
  }
}
