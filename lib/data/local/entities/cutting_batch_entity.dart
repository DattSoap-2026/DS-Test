import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../../models/types/cutting_types.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'cutting_batch_entity.g.dart';

@Collection()
class CuttingBatchEntity extends BaseEntity {
  @Index()
  late String batchNumber;

  @Index()
  late String batchGeneId;

  @Index()
  late DateTime date;

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
  List<Map<String, dynamic>> packagingConsumptions = <Map<String, dynamic>>[];

  late DateTime createdAt;
  DateTime? completedAt;
  String? rejectionReason;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'batchNumber': batchNumber,
      'batchGeneId': batchGeneId,
      'date': date.toIso8601String(),
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
      'packagingConsumptions': jsonEncode(packagingConsumptions),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
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

  Map<String, dynamic> toFirebaseJson() {
    return <String, dynamic>{
      ...toJson(),
      'packagingConsumptions': packagingConsumptions,
    };
  }

  static CuttingBatchEntity fromJson(Map<String, dynamic> json) {
    return CuttingBatchEntity()
      ..id = parseString(json['id'])
      ..batchNumber = parseString(json['batchNumber'])
      ..batchGeneId = parseString(json['batchGeneId'])
      ..date = parseDate(json['date'])
      ..shift = parseString(json['shift'], fallback: 'DAY')
      ..departmentId = parseString(json['departmentId'])
      ..departmentName = parseString(json['departmentName'])
      ..operatorId = parseString(json['operatorId'])
      ..operatorName = parseString(json['operatorName'])
      ..semiFinishedProductId = parseString(json['semiFinishedProductId'])
      ..semiFinishedProductName = parseString(json['semiFinishedProductName'])
      ..totalBatchWeightKg = parseDouble(json['totalBatchWeightKg'])
      ..boxesCount = parseInt(json['boxesCount'])
      ..avgBoxWeightKg = json['avgBoxWeightKg'] == null
          ? null
          : parseDouble(json['avgBoxWeightKg'])
      ..finishedGoodId = parseString(json['finishedGoodId'])
      ..finishedGoodName = parseString(json['finishedGoodName'])
      ..standardWeightGm = parseDouble(json['standardWeightGm'])
      ..actualAvgWeightGm = parseDouble(json['actualAvgWeightGm'])
      ..tolerancePercent = parseDouble(json['tolerancePercent'])
      ..unitsProduced = parseInt(json['unitsProduced'])
      ..totalFinishedWeightKg = parseDouble(json['totalFinishedWeightKg'])
      ..weightValidationPassed = parseBool(json['weightValidationPassed'])
      ..weightValidationMessage = parseString(
        json['weightValidationMessage'],
        fallback: '',
      )
      ..cuttingWasteKg = parseDouble(json['cuttingWasteKg'])
      ..wasteType = parseString(json['wasteType'], fallback: 'SCRAP')
      ..wasteRemark = parseString(json['wasteRemark'], fallback: '')
      ..inputWeightKg = parseDouble(json['inputWeightKg'])
      ..outputWeightKg = parseDouble(json['outputWeightKg'])
      ..wasteWeightKg = parseDouble(json['wasteWeightKg'])
      ..weightDifferenceKg = parseDouble(json['weightDifferenceKg'])
      ..weightDifferencePercent = parseDouble(json['weightDifferencePercent'])
      ..weightBalanceValid = parseBool(json['weightBalanceValid'])
      ..stage = parseString(json['stage'], fallback: 'COMPLETED')
      ..semiFinishedStockAdjusted = parseBool(json['semiFinishedStockAdjusted'])
      ..finishedGoodsStockAdjusted = parseBool(json['finishedGoodsStockAdjusted'])
      ..wasteStockAdjusted = parseBool(json['wasteStockAdjusted'])
      ..supervisorId = parseString(json['supervisorId'])
      ..supervisorName = parseString(json['supervisorName'])
      ..packagingConsumptions = parseMapList(json['packagingConsumptions'])
      ..createdAt = parseDate(json['createdAt'])
      ..completedAt = parseDateOrNull(json['completedAt'])
      ..rejectionReason = parseString(json['rejectionReason'], fallback: '')
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static CuttingBatchEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(<String, dynamic>{
      ...json,
      'packagingConsumptions': json['packagingConsumptions'] is String
          ? json['packagingConsumptions']
          : jsonEncode((json['packagingConsumptions'] as List?) ?? const <dynamic>[]),
      'syncStatus': SyncStatus.synced.name,
      'isSynced': true,
      'lastSynced': DateTime.now().toIso8601String(),
    });
  }

  CuttingBatch toDomain() {
    return CuttingBatch(
      id: id,
      batchNumber: batchNumber,
      batchGeneId: batchGeneId,
      date: date,
      shift: ShiftType.day,
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
      stage: CuttingStage.completed,
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
