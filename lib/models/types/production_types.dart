// ============================================
// UNIFIED PRODUCTION CONTROL ROOM TYPES
// ============================================

/// Production Pipeline Stages
/// SEMI → CUTTING → QC → PACKING → READY → DISPATCHED
enum ProductionStage {
  semi, // Semi-finished product created (from Bhatti)
  cutting, // Cutting in progress
  qc, // Quality control inspection
  packing, // Packing in progress
  ready, // Ready for dispatch
  dispatched; // Dispatched to customer

  String get value {
    switch (this) {
      case ProductionStage.semi:
        return 'SEMI';
      case ProductionStage.cutting:
        return 'CUTTING';
      case ProductionStage.qc:
        return 'QC';
      case ProductionStage.packing:
        return 'PACKING';
      case ProductionStage.ready:
        return 'READY';
      case ProductionStage.dispatched:
        return 'DISPATCHED';
    }
  }
}

ProductionStage productionStageFromString(String value) {
  switch (value.toUpperCase()) {
    case 'SEMI':
      return ProductionStage.semi;
    case 'CUTTING':
      return ProductionStage.cutting;
    case 'QC':
      return ProductionStage.qc;
    case 'PACKING':
      return ProductionStage.packing;
    case 'READY':
      return ProductionStage.ready;
    case 'DISPATCHED':
      return ProductionStage.dispatched;
    default:
      throw ArgumentError('Invalid ProductionStage: $value');
  }
}

enum QCStatus {
  pending,
  approved,
  rejected,
  minorIssues;

  String get value {
    switch (this) {
      case QCStatus.pending:
        return 'PENDING';
      case QCStatus.approved:
        return 'APPROVED';
      case QCStatus.rejected:
        return 'REJECTED';
      case QCStatus.minorIssues:
        return 'MINOR_ISSUES';
    }
  }

  static QCStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return QCStatus.pending;
      case 'APPROVED':
        return QCStatus.approved;
      case 'REJECTED':
        return QCStatus.rejected;
      case 'MINOR_ISSUES':
        return QCStatus.minorIssues;
      default:
        throw ArgumentError('Invalid QCStatus: $value');
    }
  }
}

class QCInspection {
  final String inspectedBy;
  final String inspectedByName;
  final String inspectedAt;
  final QCStatus status;
  final int sampleSize;
  final int defectCount;
  final List<String>? defectTypes;
  final String? remarks;
  final List<String>? photos;

  QCInspection({
    required this.inspectedBy,
    required this.inspectedByName,
    required this.inspectedAt,
    required this.status,
    required this.sampleSize,
    required this.defectCount,
    this.defectTypes,
    this.remarks,
    this.photos,
  });

  factory QCInspection.fromJson(Map<String, dynamic> json) {
    return QCInspection(
      inspectedBy: json['inspectedBy'] ?? '',
      inspectedByName: json['inspectedByName'] ?? '',
      inspectedAt: json['inspectedAt'] ?? '',
      status: QCStatus.fromString(json['status'] ?? 'PENDING'),
      sampleSize: json['sampleSize'] ?? 0,
      defectCount: json['defectCount'] ?? 0,
      defectTypes: json['defectTypes'] != null ? List<String>.from(json['defectTypes']) : null,
      remarks: json['remarks'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspectedBy': inspectedBy,
      'inspectedByName': inspectedByName,
      'inspectedAt': inspectedAt,
      'status': status.value,
      'sampleSize': sampleSize,
      'defectCount': defectCount,
      'defectTypes': defectTypes,
      'remarks': remarks,
      'photos': photos,
    };
  }
}

class PackingInfo {
  final String? packingStartedAt;
  final String? packingCompletedAt;
  final String? packedBy;
  final String? packedByName;
  final int boxesPacked;
  final int unitsPerBox;
  final int totalBoxes;

  PackingInfo({
    this.packingStartedAt,
    this.packingCompletedAt,
    this.packedBy,
    this.packedByName,
    required this.boxesPacked,
    required this.unitsPerBox,
    required this.totalBoxes,
  });

  factory PackingInfo.fromJson(Map<String, dynamic> json) {
    return PackingInfo(
      packingStartedAt: json['packingStartedAt'],
      packingCompletedAt: json['packingCompletedAt'],
      packedBy: json['packedBy'],
      packedByName: json['packedByName'],
      boxesPacked: json['boxesPacked'] ?? 0,
      unitsPerBox: json['unitsPerBox'] ?? 0,
      totalBoxes: json['totalBoxes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packingStartedAt': packingStartedAt,
      'packingCompletedAt': packingCompletedAt,
      'packedBy': packedBy,
      'packedByName': packedByName,
      'boxesPacked': boxesPacked,
      'unitsPerBox': unitsPerBox,
      'totalBoxes': totalBoxes,
    };
  }
}

enum ProductionPriority {
  urgent,
  high,
  normal,
  low;

  String get value {
    switch (this) {
      case ProductionPriority.urgent:
        return 'URGENT';
      case ProductionPriority.high:
        return 'HIGH';
      case ProductionPriority.normal:
        return 'NORMAL';
      case ProductionPriority.low:
        return 'LOW';
    }
  }

  static ProductionPriority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'URGENT':
        return ProductionPriority.urgent;
      case 'HIGH':
        return ProductionPriority.high;
      case 'NORMAL':
        return ProductionPriority.normal;
      case 'LOW':
        return ProductionPriority.low;
      default:
        throw ArgumentError('Invalid ProductionPriority: $value');
    }
  }
}

enum ProductionAlertType {
  qcHold,
  batchDelayed,
  stockLow,
  rejectionSpike,
  semiShortage,
  packagingShortage;

  String get value {
    switch (this) {
      case ProductionAlertType.qcHold:
        return 'QC_HOLD';
      case ProductionAlertType.batchDelayed:
        return 'BATCH_DELAYED';
      case ProductionAlertType.stockLow:
        return 'STOCK_LOW';
      case ProductionAlertType.rejectionSpike:
        return 'REJECTION_SPIKE';
      case ProductionAlertType.semiShortage:
        return 'SEMI_SHORTAGE';
      case ProductionAlertType.packagingShortage:
        return 'PACKAGING_SHORTAGE';
    }
  }
}

enum ProductionAlertSeverity {
  info,
  warning,
  critical;

  String get value {
    switch (this) {
      case ProductionAlertSeverity.info:
        return 'INFO';
      case ProductionAlertSeverity.warning:
        return 'WARNING';
      case ProductionAlertSeverity.critical:
        return 'CRITICAL';
    }
  }
}

class ProductionAlert {
  final String id;
  final ProductionAlertType type;
  final ProductionAlertSeverity severity;
  final String message;
  final String createdAt;
  final String? acknowledgedBy;
  final String? acknowledgedAt;

  ProductionAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  factory ProductionAlert.fromJson(Map<String, dynamic> json) {
    return ProductionAlert(
      id: json['id'] ?? '',
      type: _parseAlertType(json['type']),
      severity: _parseAlertSeverity(json['severity']),
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? '',
      acknowledgedBy: json['acknowledgedBy'],
      acknowledgedAt: json['acknowledgedAt'],
    );
  }

  static ProductionAlertType _parseAlertType(String? value) {
    switch (value?.toUpperCase()) {
      case 'QC_HOLD':
        return ProductionAlertType.qcHold;
      case 'BATCH_DELAYED':
        return ProductionAlertType.batchDelayed;
      case 'STOCK_LOW':
        return ProductionAlertType.stockLow;
      case 'REJECTION_SPIKE':
        return ProductionAlertType.rejectionSpike;
      case 'SEMI_SHORTAGE':
        return ProductionAlertType.semiShortage;
      case 'PACKAGING_SHORTAGE':
        return ProductionAlertType.packagingShortage;
      default:
        return ProductionAlertType.qcHold;
    }
  }

  static ProductionAlertSeverity _parseAlertSeverity(String? value) {
    switch (value?.toUpperCase()) {
      case 'INFO':
        return ProductionAlertSeverity.info;
      case 'WARNING':
        return ProductionAlertSeverity.warning;
      case 'CRITICAL':
        return ProductionAlertSeverity.critical;
      default:
        return ProductionAlertSeverity.info;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'severity': severity.value,
      'message': message,
      'createdAt': createdAt,
      'acknowledgedBy': acknowledgedBy,
      'acknowledgedAt': acknowledgedAt,
    };
  }
}

/// Unified Production Batch
/// Replaces: CuttingProductionBatch + ProductionLog
class ProductionBatch {
  final String id;
  final String batchNumber;
  final String batchGeneId; // SHA256 for traceability

  // Source
  final String semiFinishedProductId;
  final String semiFinishedProductName;
  final String departmentId;
  final String departmentName;

  // Output
  final String finishedGoodId;
  final String finishedGoodName;

  // Quantities
  final int plannedQty; // Initial plan
  final int cuttingQty; // Units cut
  final int physicalFinishedQty; // Actually produced
  final int weightPerUnitGrams;

  // Wastage
  final int cuttingWastageDrums;
  final double cuttingWastageKg;

  // Mass Balance
  final double batchTotalKg;
  final double expectedOutputKg;
  final double actualOutputKg;
  final double lossKg;
  final double efficiencyPercent;

  // Production Pipeline
  final ProductionStage stage;
  final QCInspection? qc;
  final PackingInfo? packing;

  // Timestamps
  final String cuttingStartedAt;
  final String? cuttingCompletedAt;
  final String? qcStartedAt;
  final String? qcCompletedAt;
  final String? packingStartedAt;
  final String? packingCompletedAt;
  final String? readyAt;
  final String? dispatchedAt;

  // Priority (from Sales Signal)
  final ProductionPriority? priority;
  final double? salesVelocity; // Units sold per day (last 7 days)
  final int? stockDays; // Days until stock-out

  // Alerts
  final List<ProductionAlert>? alerts;

  // Audit
  final String supervisorId;
  final String supervisorName;
  final String createdAt;
  final String updatedAt;

  ProductionBatch({
    required this.id,
    required this.batchNumber,
    required this.batchGeneId,
    required this.semiFinishedProductId,
    required this.semiFinishedProductName,
    required this.departmentId,
    required this.departmentName,
    required this.finishedGoodId,
    required this.finishedGoodName,
    required this.plannedQty,
    required this.cuttingQty,
    required this.physicalFinishedQty,
    required this.weightPerUnitGrams,
    required this.cuttingWastageDrums,
    required this.cuttingWastageKg,
    required this.batchTotalKg,
    required this.expectedOutputKg,
    required this.actualOutputKg,
    required this.lossKg,
    required this.efficiencyPercent,
    required this.stage,
    this.qc,
    this.packing,
    required this.cuttingStartedAt,
    this.cuttingCompletedAt,
    this.qcStartedAt,
    this.qcCompletedAt,
    this.packingStartedAt,
    this.packingCompletedAt,
    this.readyAt,
    this.dispatchedAt,
    this.priority,
    this.salesVelocity,
    this.stockDays,
    this.alerts,
    required this.supervisorId,
    required this.supervisorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductionBatch.fromJson(Map<String, dynamic> json) {
    return ProductionBatch(
      id: json['id'] ?? '',
      batchNumber: json['batchNumber'] ?? '',
      batchGeneId: json['batchGeneId'] ?? '',
      semiFinishedProductId: json['semiFinishedProductId'] ?? '',
      semiFinishedProductName: json['semiFinishedProductName'] ?? '',
      departmentId: json['departmentId'] ?? '',
      departmentName: json['departmentName'] ?? '',
      finishedGoodId: json['finishedGoodId'] ?? '',
      finishedGoodName: json['finishedGoodName'] ?? '',
      plannedQty: json['plannedQty'] ?? 0,
      cuttingQty: json['cuttingQty'] ?? 0,
      physicalFinishedQty: json['physicalFinishedQty'] ?? 0,
      weightPerUnitGrams: json['weightPerUnitGrams'] ?? 0,
      cuttingWastageDrums: json['cuttingWastageDrums'] ?? 0,
      cuttingWastageKg: (json['cuttingWastageKg'] ?? 0).toDouble(),
      batchTotalKg: (json['batchTotalKg'] ?? 0).toDouble(),
      expectedOutputKg: (json['expectedOutputKg'] ?? 0).toDouble(),
      actualOutputKg: (json['actualOutputKg'] ?? 0).toDouble(),
      lossKg: (json['lossKg'] ?? 0).toDouble(),
      efficiencyPercent: (json['efficiencyPercent'] ?? 0).toDouble(),
      stage: productionStageFromString(json['stage'] ?? 'CUTTING'),
      qc: json['qc'] != null ? QCInspection.fromJson(json['qc']) : null,
      packing: json['packing'] != null ? PackingInfo.fromJson(json['packing']) : null,
      cuttingStartedAt: json['cuttingStartedAt'] ?? '',
      cuttingCompletedAt: json['cuttingCompletedAt'],
      qcStartedAt: json['qcStartedAt'],
      qcCompletedAt: json['qcCompletedAt'],
      packingStartedAt: json['packingStartedAt'],
      packingCompletedAt: json['packingCompletedAt'],
      readyAt: json['readyAt'],
      dispatchedAt: json['dispatchedAt'],
      priority: json['priority'] != null ? ProductionPriority.fromString(json['priority']) : null,
      salesVelocity: json['salesVelocity']?.toDouble(),
      stockDays: json['stockDays'] as int?,
      alerts: json['alerts'] != null
          ? (json['alerts'] as List).map((a) => ProductionAlert.fromJson(a)).toList()
          : null,
      supervisorId: json['supervisorId'] ?? '',
      supervisorName: json['supervisorName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'batchGeneId': batchGeneId,
      'semiFinishedProductId': semiFinishedProductId,
      'semiFinishedProductName': semiFinishedProductName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'finishedGoodId': finishedGoodId,
      'finishedGoodName': finishedGoodName,
      'plannedQty': plannedQty,
      'cuttingQty': cuttingQty,
      'physicalFinishedQty': physicalFinishedQty,
      'weightPerUnitGrams': weightPerUnitGrams,
      'cuttingWastageDrums': cuttingWastageDrums,
      'cuttingWastageKg': cuttingWastageKg,
      'batchTotalKg': batchTotalKg,
      'expectedOutputKg': expectedOutputKg,
      'actualOutputKg': actualOutputKg,
      'lossKg': lossKg,
      'efficiencyPercent': efficiencyPercent,
      'stage': stage.value,
      'qc': qc?.toJson(),
      'packing': packing?.toJson(),
      'cuttingStartedAt': cuttingStartedAt,
      'cuttingCompletedAt': cuttingCompletedAt,
      'qcStartedAt': qcStartedAt,
      'qcCompletedAt': qcCompletedAt,
      'packingStartedAt': packingStartedAt,
      'packingCompletedAt': packingCompletedAt,
      'readyAt': readyAt,
      'dispatchedAt': dispatchedAt,
      'priority': priority?.value,
      'salesVelocity': salesVelocity,
      'stockDays': stockDays,
      'alerts': alerts?.map((a) => a.toJson()).toList(),
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
