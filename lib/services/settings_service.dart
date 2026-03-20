import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Restored
import 'package:flutter_app/core/sync/sync_queue_service.dart';
import 'package:flutter_app/core/sync/sync_service.dart';
import 'database_service.dart';
import '../data/local/entities/route_entity.dart';
import '../data/local/entities/settings_cache_entity.dart';
import '../models/settings_audit_log.dart';
import 'base_service.dart';
import 'settings_audit_service.dart';
import 'settings_registry.dart';
import 'delegates/firestore_query_delegate.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DeptTeam {
  final String code;
  final String name;

  DeptTeam({required this.code, required this.name});

  factory DeptTeam.fromJson(Map<String, dynamic> json) {
    return DeptTeam(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'code': code, 'name': name};
}

class OrgDepartment {
  final String id;
  final String code;
  final String name;
  final String? description;
  final List<DeptTeam> teams;
  final bool isActive;
  final int order;
  final String createdAt;
  final String updatedAt;

  OrgDepartment({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.teams = const [],
    this.isActive = true,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrgDepartment.fromJson(String id, Map<String, dynamic> json) {
    return OrgDepartment(
      id: id,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      teams:
          (json['teams'] as List<dynamic>?)
              ?.map((e) => DeptTeam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'teams': teams.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class AppCurrency {
  final String id;
  final String name;
  final String code;
  final String symbol;
  final double exchangeRate;
  final bool isBaseCurrency;

  AppCurrency({
    required this.id,
    required this.name,
    required this.code,
    required this.symbol,
    required this.exchangeRate,
    this.isBaseCurrency = false,
  });

  factory AppCurrency.fromJson(String id, Map<String, dynamic> json) {
    return AppCurrency(
      id: id,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      exchangeRate: (json['exchangeRate'] as num? ?? 1.0).toDouble(),
      isBaseCurrency: json['isBaseCurrency'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'symbol': symbol,
      'exchangeRate': exchangeRate,
      'isBaseCurrency': isBaseCurrency,
    };
  }
}

class TransactionSeries {
  final String id;
  final String type;
  final String prefix;
  final String? suffix;
  final int nextNumber;
  final int padding;
  final String format;
  final String resetOn; // 'never', 'year', 'month'
  final String? lastResetDate;

  TransactionSeries({
    required this.id,
    required this.type,
    required this.prefix,
    this.suffix,
    required this.nextNumber,
    required this.padding,
    required this.format,
    required this.resetOn,
    this.lastResetDate,
  });

  factory TransactionSeries.fromJson(String id, Map<String, dynamic> json) {
    return TransactionSeries(
      id: id,
      type: json['type'] as String? ?? id,
      prefix: json['prefix'] as String? ?? '',
      suffix: json['suffix'] as String?,
      nextNumber: (json['nextNumber'] as num? ?? 1).toInt(),
      padding: (json['padding'] as num? ?? 4).toInt(),
      format: json['format'] as String? ?? '{PREFIX}-{YEAR}-{MONTH}-{NUMBER}',
      resetOn: json['resetOn'] as String? ?? 'never',
      lastResetDate: json['lastResetDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'prefix': prefix,
      'suffix': suffix,
      'nextNumber': nextNumber,
      'padding': padding,
      'format': format,
      'resetOn': resetOn,
      'lastResetDate': lastResetDate,
    };
  }
}

class FuelSettings {
  final double globalMinMileage;
  final double globalPenaltyRate;
  final Map<String, VehicleFuelOverride> vehicleOverrides;

  FuelSettings({
    required this.globalMinMileage,
    required this.globalPenaltyRate,
    required this.vehicleOverrides,
  });

  factory FuelSettings.fromJson(Map<String, dynamic> json) {
    final overridesMap =
        json['vehicleOverrides'] as Map<String, dynamic>? ?? {};
    final overrides = overridesMap.map(
      (key, value) => MapEntry(
        key,
        VehicleFuelOverride.fromJson(value as Map<String, dynamic>),
      ),
    );

    return FuelSettings(
      globalMinMileage: (json['globalMinMileage'] as num? ?? 10.0).toDouble(),
      globalPenaltyRate: (json['globalPenaltyRate'] as num? ?? 5.0).toDouble(),
      vehicleOverrides: overrides,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'globalMinMileage': globalMinMileage,
      'globalPenaltyRate': globalPenaltyRate,
      'vehicleOverrides': vehicleOverrides.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

class VehicleFuelOverride {
  final double minMileage;
  final double penaltyRate;

  VehicleFuelOverride({required this.minMileage, required this.penaltyRate});

  factory VehicleFuelOverride.fromJson(Map<String, dynamic> json) {
    return VehicleFuelOverride(
      minMileage: (json['minMileage'] as num? ?? 0.0).toDouble(),
      penaltyRate: (json['penaltyRate'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'minMileage': minMileage, 'penaltyRate': penaltyRate};
  }
}

class GstSettings {
  final bool isEnabled;
  final String defaultGstType;
  final double defaultGstPercentage;
  final String gstin;

  GstSettings({
    required this.isEnabled,
    required this.defaultGstType,
    required this.defaultGstPercentage,
    required this.gstin,
  });

  factory GstSettings.fromJson(Map<String, dynamic> json) {
    return GstSettings(
      isEnabled: json['isEnabled'] as bool? ?? false,
      defaultGstType: json['defaultGstType'] as String? ?? 'none',
      defaultGstPercentage: (json['defaultGstPercentage'] as num? ?? 0)
          .toDouble(),
      gstin: json['gstin'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'defaultGstType': defaultGstType,
      'defaultGstPercentage': defaultGstPercentage,
      'gstin': gstin,
    };
  }
}

class PdfTemplate {
  final String id;
  final String name;
  final String type;
  final String htmlContent;
  final String? updatedAt;

  PdfTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.htmlContent,
    this.updatedAt,
  });

  factory PdfTemplate.fromJson(String id, Map<String, dynamic> json) {
    return PdfTemplate(
      id: id,
      name: json['name'] as String? ?? 'Untitled',
      type: json['type'] as String? ?? 'general',
      htmlContent: json['htmlContent'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'htmlContent': htmlContent,
      'updatedAt': updatedAt,
    };
  }
}

class DutySettings {
  final DutyGlobalSettings globalSettings;
  final DutyAdvancedTracking advancedTracking;
  final Map<String, DutyRoleSetting> roleSettings;
  final List<SundayOverride> sundayOverrides;
  final String? updatedAt;
  final String? updatedBy;

  DutySettings({
    required this.globalSettings,
    required this.advancedTracking,
    required this.roleSettings,
    required this.sundayOverrides,
    this.updatedAt,
    this.updatedBy,
  });

  factory DutySettings.fromJson(Map<String, dynamic> json) {
    return DutySettings(
      globalSettings: DutyGlobalSettings.fromJson(json['globalSettings'] ?? {}),
      advancedTracking: DutyAdvancedTracking.fromJson(
        json['advancedTracking'] ?? {},
      ),
      roleSettings: (json['roleSettings'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, DutyRoleSetting.fromJson(value)),
      ),
      sundayOverrides: (json['sundayOverrides'] as List<dynamic>? ?? [])
          .map((e) => SundayOverride.fromJson(e))
          .toList(),
      updatedAt: json['updatedAt'],
      updatedBy: json['updatedBy'],
    );
  }

  DutySettings copyWith({
    DutyGlobalSettings? globalSettings,
    DutyAdvancedTracking? advancedTracking,
    Map<String, DutyRoleSetting>? roleSettings,
    List<SundayOverride>? sundayOverrides,
    String? updatedAt,
    String? updatedBy,
  }) {
    return DutySettings(
      globalSettings: globalSettings ?? this.globalSettings,
      advancedTracking: advancedTracking ?? this.advancedTracking,
      roleSettings: roleSettings ?? this.roleSettings,
      sundayOverrides: sundayOverrides ?? this.sundayOverrides,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'globalSettings': globalSettings.toJson(),
      'advancedTracking': advancedTracking.toJson(),
      'roleSettings': roleSettings.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'sundayOverrides': sundayOverrides.map((e) => e.toJson()).toList(),
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
}

class DutyGlobalSettings {
  final String defaultStartTime;
  final String defaultEndTime;
  final List<int> workingDays;
  final bool autoGpsOff;
  final int gpsPollingIntervalMs;
  final int idleThresholdMinutes;
  final int staleLocationMinutes;

  DutyGlobalSettings({
    required this.defaultStartTime,
    required this.defaultEndTime,
    required this.workingDays,
    required this.autoGpsOff,
    required this.gpsPollingIntervalMs,
    required this.idleThresholdMinutes,
    required this.staleLocationMinutes,
  });

  factory DutyGlobalSettings.fromJson(Map<String, dynamic> json) {
    return DutyGlobalSettings(
      defaultStartTime: json['defaultStartTime'] ?? '08:00',
      defaultEndTime: json['defaultEndTime'] ?? '20:00',
      workingDays: List<int>.from(json['workingDays'] ?? [1, 2, 3, 4, 5, 6]),
      autoGpsOff: json['autoGpsOff'] ?? false,
      gpsPollingIntervalMs: json['gpsPollingIntervalMs'] ?? 30000,
      idleThresholdMinutes: json['idleThresholdMinutes'] ?? 5,
      staleLocationMinutes: json['staleLocationMinutes'] ?? 10,
    );
  }

  DutyGlobalSettings copyWith({
    String? defaultStartTime,
    String? defaultEndTime,
    List<int>? workingDays,
    bool? autoGpsOff,
    int? gpsPollingIntervalMs,
    int? idleThresholdMinutes,
    int? staleLocationMinutes,
  }) {
    return DutyGlobalSettings(
      defaultStartTime: defaultStartTime ?? this.defaultStartTime,
      defaultEndTime: defaultEndTime ?? this.defaultEndTime,
      workingDays: workingDays ?? this.workingDays,
      autoGpsOff: autoGpsOff ?? this.autoGpsOff,
      gpsPollingIntervalMs: gpsPollingIntervalMs ?? this.gpsPollingIntervalMs,
      idleThresholdMinutes: idleThresholdMinutes ?? this.idleThresholdMinutes,
      staleLocationMinutes: staleLocationMinutes ?? this.staleLocationMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultStartTime': defaultStartTime,
      'defaultEndTime': defaultEndTime,
      'workingDays': workingDays,
      'autoGpsOff': autoGpsOff,
      'gpsPollingIntervalMs': gpsPollingIntervalMs,
      'idleThresholdMinutes': idleThresholdMinutes,
      'staleLocationMinutes': staleLocationMinutes,
    };
  }
}

class DutyAdvancedTracking {
  final int baseReturnRadiusMeters;
  final double baseReturnSpeedKmh;
  final int stationaryMinutesRequired;
  final String maxTrackingCutoffTime;
  final bool overtimeAlertEnabled;
  final int maxOvertimeMinutes;
  final bool enableSmartAutoStop;
  final bool continueTrackingAfterDutyEnd;

  DutyAdvancedTracking({
    required this.baseReturnRadiusMeters,
    required this.baseReturnSpeedKmh,
    required this.stationaryMinutesRequired,
    required this.maxTrackingCutoffTime,
    required this.overtimeAlertEnabled,
    required this.maxOvertimeMinutes,
    required this.enableSmartAutoStop,
    required this.continueTrackingAfterDutyEnd,
  });

  factory DutyAdvancedTracking.fromJson(Map<String, dynamic> json) {
    return DutyAdvancedTracking(
      baseReturnRadiusMeters: json['baseReturnRadiusMeters'] ?? 300,
      baseReturnSpeedKmh: (json['baseReturnSpeedKmh'] as num? ?? 5.0)
          .toDouble(),
      stationaryMinutesRequired: json['stationaryMinutesRequired'] ?? 10,
      maxTrackingCutoffTime: json['maxTrackingCutoffTime'] ?? '23:00',
      overtimeAlertEnabled: json['overtimeAlertEnabled'] ?? true,
      maxOvertimeMinutes: json['maxOvertimeMinutes'] ?? 300,
      enableSmartAutoStop: json['enableSmartAutoStop'] ?? true,
      continueTrackingAfterDutyEnd:
          json['continueTrackingAfterDutyEnd'] ?? true,
    );
  }

  DutyAdvancedTracking copyWith({
    int? baseReturnRadiusMeters,
    double? baseReturnSpeedKmh,
    int? stationaryMinutesRequired,
    String? maxTrackingCutoffTime,
    bool? overtimeAlertEnabled,
    int? maxOvertimeMinutes,
    bool? enableSmartAutoStop,
    bool? continueTrackingAfterDutyEnd,
  }) {
    return DutyAdvancedTracking(
      baseReturnRadiusMeters:
          baseReturnRadiusMeters ?? this.baseReturnRadiusMeters,
      baseReturnSpeedKmh: baseReturnSpeedKmh ?? this.baseReturnSpeedKmh,
      stationaryMinutesRequired:
          stationaryMinutesRequired ?? this.stationaryMinutesRequired,
      maxTrackingCutoffTime:
          maxTrackingCutoffTime ?? this.maxTrackingCutoffTime,
      overtimeAlertEnabled: overtimeAlertEnabled ?? this.overtimeAlertEnabled,
      maxOvertimeMinutes: maxOvertimeMinutes ?? this.maxOvertimeMinutes,
      enableSmartAutoStop: enableSmartAutoStop ?? this.enableSmartAutoStop,
      continueTrackingAfterDutyEnd:
          continueTrackingAfterDutyEnd ?? this.continueTrackingAfterDutyEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseReturnRadiusMeters': baseReturnRadiusMeters,
      'baseReturnSpeedKmh': baseReturnSpeedKmh,
      'stationaryMinutesRequired': stationaryMinutesRequired,
      'maxTrackingCutoffTime': maxTrackingCutoffTime,
      'overtimeAlertEnabled': overtimeAlertEnabled,
      'maxOvertimeMinutes': maxOvertimeMinutes,
      'enableSmartAutoStop': enableSmartAutoStop,
      'continueTrackingAfterDutyEnd': continueTrackingAfterDutyEnd,
    };
  }
}

class DutyRoleSetting {
  final String startTime;
  final String endTime;
  final bool? requireVehicle;
  final bool? requireRoute;

  DutyRoleSetting({
    required this.startTime,
    required this.endTime,
    this.requireVehicle,
    this.requireRoute,
  });

  factory DutyRoleSetting.fromJson(Map<String, dynamic> json) {
    return DutyRoleSetting(
      startTime: json['startTime'] ?? '08:00',
      endTime: json['endTime'] ?? '20:00',
      requireVehicle: json['requireVehicle'],
      requireRoute: json['requireRoute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'requireVehicle': requireVehicle,
      'requireRoute': requireRoute,
    };
  }
}

class SundayOverride {
  final String date;
  final List<String> allowedUserIds;
  final String reason;
  final String approvedBy;
  final String approvedAt;

  SundayOverride({
    required this.date,
    required this.allowedUserIds,
    required this.reason,
    required this.approvedBy,
    required this.approvedAt,
  });

  factory SundayOverride.fromJson(Map<String, dynamic> json) {
    return SundayOverride(
      date: json['date'] ?? '',
      allowedUserIds: List<String>.from(json['allowedUserIds'] ?? []),
      reason: json['reason'] ?? '',
      approvedBy: json['approvedBy'] ?? '',
      approvedAt: json['approvedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'allowedUserIds': allowedUserIds,
      'reason': reason,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
    };
  }
}

class BankDetails {
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final String? accountHolderName;

  BankDetails({
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.accountHolderName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      branchName: json['branchName'],
      accountHolderName: json['accountHolderName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bankName != null) 'bankName': bankName,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (ifscCode != null) 'ifscCode': ifscCode,
      if (branchName != null) 'branchName': branchName,
      if (accountHolderName != null) 'accountHolderName': accountHolderName,
    };
  }
}

class CompanyProfileData {
  final String? name;
  final String? tagline;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? gstin;
  final String? pan;
  final BankDetails? bankDetails;

  CompanyProfileData({
    this.name,
    this.tagline,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.gstin,
    this.pan,
    this.bankDetails,
  });

  factory CompanyProfileData.fromJson(Map<String, dynamic> json) {
    return CompanyProfileData(
      name: json['name'],
      tagline: json['tagline'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      gstin: json['gstin'],
      pan: json['pan'],
      bankDetails: json['bankDetails'] != null
          ? BankDetails.fromJson(json['bankDetails'])
          : null,
    );
  }
}

class GeneralSettingsData {
  String? businessStartTime;
  String? businessEndTime;
  List<int>? workingDays;
  bool? emailNotifications;
  bool? smsNotifications;
  bool? pushNotifications;
  bool? lowStockAlert;
  bool? salesTargetReminder;
  String? theme;
  String? language;
  String? dateFormat;
  String? currency;
  int? retentionDays;
  bool? autoBackup;
  String? backupFrequency;
  bool? allowNegativeStock;
  bool? enforceCreditLimit;
  double? maxDiscountPercentage;
  int? orderEditWindowMinutes;
  int? trackingIntervalMinutes;
  bool? trackOnlyWorkHours;
  int? staleLocationThresholdMinutes;
  int? sessionTimeoutMinutes;
  int? maxLoginAttempts;
  bool? goLiveCompleted;
  bool? strictAccountingMode;
  List<double>? salesmanSpecialDiscountOptions;
  double? salesmanCustomerSpecialDiscount;
  double? salesmanDealerSpecialDiscount;
  List<double>? salesmanAdditionalDiscountOptions;
  double? salesmanCustomerAdditionalDiscount;
  double? salesmanDealerAdditionalDiscount;
  bool? allowSalesmanGstToggle;
  bool? allowSalesmanAdditionalDiscountToggle;
  bool? allowSalesmanSpecialDiscountToggle;
  bool? allowDealerGstToggle;
  bool? allowDealerAdditionalDiscountToggle;
  bool? allowDealerSpecialDiscountToggle;
  List<double>? dealerAdditionalDiscountOptions;
  double? dealerAdditionalDiscountDefault;
  List<double>? dealerSpecialDiscountOptions;
  double? dealerSpecialDiscountDefault;

  GeneralSettingsData({
    this.businessStartTime,
    this.businessEndTime,
    this.workingDays,
    this.emailNotifications,
    this.smsNotifications,
    this.pushNotifications,
    this.lowStockAlert,
    this.salesTargetReminder,
    this.theme,
    this.language,
    this.dateFormat,
    this.currency,
    this.retentionDays,
    this.autoBackup,
    this.backupFrequency,
    this.allowNegativeStock,
    this.enforceCreditLimit,
    this.maxDiscountPercentage,
    this.orderEditWindowMinutes,
    this.trackingIntervalMinutes,
    this.trackOnlyWorkHours,
    this.staleLocationThresholdMinutes,
    this.sessionTimeoutMinutes,
    this.maxLoginAttempts,
    this.goLiveCompleted,
    this.strictAccountingMode,
    this.salesmanSpecialDiscountOptions,
    this.salesmanCustomerSpecialDiscount,
    this.salesmanDealerSpecialDiscount,
    this.salesmanAdditionalDiscountOptions,
    this.salesmanCustomerAdditionalDiscount,
    this.salesmanDealerAdditionalDiscount,
    this.allowSalesmanGstToggle,
    this.allowSalesmanAdditionalDiscountToggle,
    this.allowSalesmanSpecialDiscountToggle,
    this.allowDealerGstToggle,
    this.allowDealerAdditionalDiscountToggle,
    this.allowDealerSpecialDiscountToggle,
    this.dealerAdditionalDiscountOptions,
    this.dealerAdditionalDiscountDefault,
    this.dealerSpecialDiscountOptions,
    this.dealerSpecialDiscountDefault,
  });

  factory GeneralSettingsData.fromJson(Map<String, dynamic> json) {
    return GeneralSettingsData(
      businessStartTime: json['businessStartTime'],
      businessEndTime: json['businessEndTime'],
      workingDays: (json['workingDays'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      emailNotifications: json['emailNotifications'],
      smsNotifications: json['smsNotifications'],
      pushNotifications: json['pushNotifications'],
      lowStockAlert: json['lowStockAlert'],
      salesTargetReminder: json['salesTargetReminder'],
      theme: json['theme'],
      language: json['language'],
      dateFormat: json['dateFormat'],
      currency: json['currency'],
      retentionDays: json['retentionDays'],
      autoBackup: json['autoBackup'],
      backupFrequency: json['backupFrequency'],
      allowNegativeStock: json['allowNegativeStock'],
      enforceCreditLimit: json['enforceCreditLimit'],
      maxDiscountPercentage: (json['maxDiscountPercentage'] as num?)
          ?.toDouble(),
      orderEditWindowMinutes: json['orderEditWindowMinutes'],
      trackingIntervalMinutes: json['trackingIntervalMinutes'],
      trackOnlyWorkHours: json['trackOnlyWorkHours'],
      staleLocationThresholdMinutes: json['staleLocationThresholdMinutes'],
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'],
      maxLoginAttempts: json['maxLoginAttempts'],
      goLiveCompleted: json['goLiveCompleted'],
      strictAccountingMode: json['strictAccountingMode'] as bool? ?? false,
      salesmanSpecialDiscountOptions:
          (json['salesmanSpecialDiscountOptions'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [1, 2, 3, 5],
      salesmanCustomerSpecialDiscount:
          (json['salesmanCustomerSpecialDiscount'] as num?)?.toDouble() ?? 5.0,
      salesmanDealerSpecialDiscount:
          (json['salesmanDealerSpecialDiscount'] as num?)?.toDouble() ?? 5.0,
      salesmanAdditionalDiscountOptions:
          (json['salesmanAdditionalDiscountOptions'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [5, 8, 13],
      salesmanCustomerAdditionalDiscount:
          (json['salesmanCustomerAdditionalDiscount'] as num?)?.toDouble() ??
          5.0,
      salesmanDealerAdditionalDiscount:
          (json['salesmanDealerAdditionalDiscount'] as num?)?.toDouble() ?? 5.0,
      allowSalesmanGstToggle: json['allowSalesmanGstToggle'] as bool? ?? true,
      allowSalesmanAdditionalDiscountToggle:
          json['allowSalesmanAdditionalDiscountToggle'] as bool? ?? true,
      allowSalesmanSpecialDiscountToggle:
          json['allowSalesmanSpecialDiscountToggle'] as bool? ?? true,
      allowDealerGstToggle: json['allowDealerGstToggle'] as bool? ?? true,
      allowDealerAdditionalDiscountToggle:
          json['allowDealerAdditionalDiscountToggle'] as bool? ?? true,
      allowDealerSpecialDiscountToggle:
          json['allowDealerSpecialDiscountToggle'] as bool? ?? true,
      dealerAdditionalDiscountOptions:
          (json['dealerAdditionalDiscountOptions'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [2, 5, 10, 15],
      dealerAdditionalDiscountDefault:
          (json['dealerAdditionalDiscountDefault'] as num?)?.toDouble() ?? 5.0,
      dealerSpecialDiscountOptions:
          (json['dealerSpecialDiscountOptions'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [1, 2, 3, 5],
      dealerSpecialDiscountDefault:
          (json['dealerSpecialDiscountDefault'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessStartTime': businessStartTime,
      'businessEndTime': businessEndTime,
      'workingDays': workingDays,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'lowStockAlert': lowStockAlert,
      'salesTargetReminder': salesTargetReminder,
      'theme': theme,
      'language': language,
      'dateFormat': dateFormat,
      'currency': currency,
      'retentionDays': retentionDays,
      'autoBackup': autoBackup,
      'backupFrequency': backupFrequency,
      'allowNegativeStock': allowNegativeStock,
      'enforceCreditLimit': enforceCreditLimit,
      'maxDiscountPercentage': maxDiscountPercentage,
      'orderEditWindowMinutes': orderEditWindowMinutes,
      'trackingIntervalMinutes': trackingIntervalMinutes,
      'trackOnlyWorkHours': trackOnlyWorkHours,
      'staleLocationThresholdMinutes': staleLocationThresholdMinutes,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'maxLoginAttempts': maxLoginAttempts,
      'goLiveCompleted': goLiveCompleted,
      'strictAccountingMode': strictAccountingMode,
      'salesmanSpecialDiscountOptions': salesmanSpecialDiscountOptions,
      'salesmanCustomerSpecialDiscount': salesmanCustomerSpecialDiscount,
      'salesmanDealerSpecialDiscount': salesmanDealerSpecialDiscount,
      'salesmanAdditionalDiscountOptions': salesmanAdditionalDiscountOptions,
      'salesmanCustomerAdditionalDiscount': salesmanCustomerAdditionalDiscount,
      'salesmanDealerAdditionalDiscount': salesmanDealerAdditionalDiscount,
      'allowSalesmanGstToggle': allowSalesmanGstToggle,
      'allowSalesmanAdditionalDiscountToggle':
          allowSalesmanAdditionalDiscountToggle,
      'allowSalesmanSpecialDiscountToggle': allowSalesmanSpecialDiscountToggle,
      'allowDealerGstToggle': allowDealerGstToggle,
      'allowDealerAdditionalDiscountToggle':
          allowDealerAdditionalDiscountToggle,
      'allowDealerSpecialDiscountToggle': allowDealerSpecialDiscountToggle,
      'dealerAdditionalDiscountOptions': dealerAdditionalDiscountOptions,
      'dealerAdditionalDiscountDefault': dealerAdditionalDiscountDefault,
      'dealerSpecialDiscountOptions': dealerSpecialDiscountOptions,
      'dealerSpecialDiscountDefault': dealerSpecialDiscountDefault,
    };
  }
}

class CommissionSlab {
  final double minAmount;
  final double maxAmount;
  final double percentage;

  CommissionSlab({
    required this.minAmount,
    required this.maxAmount,
    required this.percentage,
  });

  factory CommissionSlab.fromJson(Map<String, dynamic> json) {
    return CommissionSlab(
      minAmount: (json['minAmount'] as num? ?? 0).toDouble(),
      maxAmount: (json['maxAmount'] as num? ?? 0).toDouble(),
      percentage: (json['percentage'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'minAmount': minAmount,
    'maxAmount': maxAmount,
    'percentage': percentage,
  };
}

class ReportsPreferences {
  final bool isAiEnabled;
  final int defaultDateRange;
  final String defaultSalesReportGrouping;
  final int lowStockThreshold;
  final List<int> workingDays;
  final int requiredMonthlyWorkDays;
  final int dailyCounterTarget;
  final double dailyIncentiveAmount;
  final double newCustomerIncentive;
  final double monthlyTargetIncentivePercentage;
  final double monthlyTargetIncentiveThreshold;
  final double miscellaneousBonus;
  final double mileagePenaltyAmount;
  final String financialYearStart;
  final List<String> defaultDashboardKPIs;

  // Commission specific fields
  final String commissionType; // 'percentage', 'slab', 'target_based'
  final double baseCommissionPercentage;
  final List<CommissionSlab> commissionSlabs;
  final double targetBonusPercentage;

  ReportsPreferences({
    this.isAiEnabled = true,
    this.defaultDateRange = 30,
    this.defaultSalesReportGrouping = 'day',
    this.lowStockThreshold = 10,
    this.workingDays = const [1, 2, 3, 4, 5, 6],
    this.requiredMonthlyWorkDays = 26,
    this.dailyCounterTarget = 15,
    this.dailyIncentiveAmount = 100.0,
    this.newCustomerIncentive = 50.0,
    this.monthlyTargetIncentivePercentage = 2.0,
    this.monthlyTargetIncentiveThreshold = 100000.0,
    this.miscellaneousBonus = 0.0,
    this.mileagePenaltyAmount = 5.0,
    this.financialYearStart = '04-01',
    this.defaultDashboardKPIs = const [
      'teamSales',
      'newCustomers',
      'returnRequests',
      'stockValue',
    ],
    this.commissionType = 'percentage',
    this.baseCommissionPercentage = 2.0,
    this.commissionSlabs = const [],
    this.targetBonusPercentage = 1.0,
  });

  factory ReportsPreferences.fromJson(Map<String, dynamic> json) {
    return ReportsPreferences(
      isAiEnabled: json['isAiEnabled'] ?? true,
      defaultDateRange: json['defaultDateRange'] ?? 30,
      defaultSalesReportGrouping: json['defaultSalesReportGrouping'] ?? 'day',
      lowStockThreshold: json['lowStockThreshold'] ?? 10,
      workingDays: List<int>.from(json['workingDays'] ?? [1, 2, 3, 4, 5, 6]),
      requiredMonthlyWorkDays: json['requiredMonthlyWorkDays'] ?? 26,
      dailyCounterTarget: json['dailyCounterTarget'] ?? 15,
      dailyIncentiveAmount:
          (json['dailyIncentiveAmount'] as num?)?.toDouble() ?? 100.0,
      newCustomerIncentive:
          (json['newCustomerIncentive'] as num?)?.toDouble() ?? 50.0,
      monthlyTargetIncentivePercentage:
          (json['monthlyTargetIncentivePercentage'] as num?)?.toDouble() ?? 2.0,
      monthlyTargetIncentiveThreshold:
          (json['monthlyTargetIncentiveThreshold'] as num?)?.toDouble() ??
          100000.0,
      miscellaneousBonus:
          (json['miscellaneousBonus'] as num?)?.toDouble() ?? 0.0,
      mileagePenaltyAmount:
          (json['mileagePenaltyAmount'] as num?)?.toDouble() ?? 5.0,
      financialYearStart: json['financialYearStart'] ?? '04-01',
      defaultDashboardKPIs: List<String>.from(
        json['defaultDashboardKPIs'] ??
            ['teamSales', 'newCustomers', 'returnRequests', 'stockValue'],
      ),
      commissionType: json['commissionType'] ?? 'percentage',
      baseCommissionPercentage:
          (json['baseCommissionPercentage'] as num?)?.toDouble() ?? 2.0,
      commissionSlabs:
          (json['commissionSlabs'] as List<dynamic>?)
              ?.map((e) => CommissionSlab.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      targetBonusPercentage:
          (json['targetBonusPercentage'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAiEnabled': isAiEnabled,
      'defaultDateRange': defaultDateRange,
      'defaultSalesReportGrouping': defaultSalesReportGrouping,
      'lowStockThreshold': lowStockThreshold,
      'workingDays': workingDays,
      'requiredMonthlyWorkDays': requiredMonthlyWorkDays,
      'dailyCounterTarget': dailyCounterTarget,
      'dailyIncentiveAmount': dailyIncentiveAmount,
      'newCustomerIncentive': newCustomerIncentive,
      'monthlyTargetIncentivePercentage': monthlyTargetIncentivePercentage,
      'monthlyTargetIncentiveThreshold': monthlyTargetIncentiveThreshold,
      'miscellaneousBonus': miscellaneousBonus,
      'mileagePenaltyAmount': mileagePenaltyAmount,
      'financialYearStart': financialYearStart,
      'defaultDashboardKPIs': defaultDashboardKPIs,
      'commissionType': commissionType,
      'baseCommissionPercentage': baseCommissionPercentage,
      'commissionSlabs': commissionSlabs.map((e) => e.toJson()).toList(),
      'targetBonusPercentage': targetBonusPercentage,
    };
  }
}

class SettingsService extends BaseService {
  final DatabaseService _dbService;
  final SettingsAuditService _settingsAuditService;

  SettingsService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance,
      _settingsAuditService = SettingsAuditService(
        firebase,
        dbService ?? DatabaseService.instance,
      );

  static const String publicSettingsCollection = 'public_settings';
  static const String departmentsCollection = 'user_departments';
  static const String currenciesCollection = 'currencies';
  static const String seriesCollection = 'transaction_series';

  static const String companyProfileDocId = 'company_profile';
  static const String fuelSettingsDocId = 'fuel_settings';
  static const String gstSettingsDocId = 'gst';
  static const String reportsPrefsDocId = 'reports_preferences';
  static const String dutySettingsDocId = 'duty_settings';
  static const String generalSettingsDocId = 'general_settings';
  static const String settingsMetadataDocId = 'settings_metadata';
  static const int currentSettingsSchemaVersion = 1;
  static const String pdfTemplatesCollection = 'pdf_templates';
  static const Set<String> _cacheKeys = {
    companyProfileDocId,
    generalSettingsDocId,
    gstSettingsDocId,
    settingsMetadataDocId,
    reportsPrefsDocId,
    dutySettingsDocId,
    fuelSettingsDocId,
    departmentsCollection,
    currenciesCollection,
    seriesCollection,
    pdfTemplatesCollection,
  };

  Future<void> _enqueueOutbox({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
    String? explicitRecordKey,
  }) async {
    final documentId = explicitRecordKey?.trim().isNotEmpty == true
        ? explicitRecordKey!.trim()
        : payload['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) return;
    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
  }

  Future<void> _performImmediateDocWrite({
    required FirebaseFirestore firestore,
    required String collection,
    required String docId,
    required String action,
    required Map<String, dynamic> payload,
    bool merge = true,
  }) async {
    await SyncService.instance.trySync();
  }

  Future<void> _queueDocWrite({
    required String collection,
    required String docId,
    required String action,
    required Map<String, dynamic> payload,
    bool merge = true,
    String? explicitRecordKey,
  }) async {
    final queuedPayload = <String, dynamic>{...payload, 'id': docId};
    await _enqueueOutbox(
      collection: collection,
      action: action,
      payload: queuedPayload,
      explicitRecordKey: explicitRecordKey ?? docId,
    );

    final firestore = db;
    if (firestore == null) return;

    try {
      await _performImmediateDocWrite(
        firestore: firestore,
        collection: collection,
        docId: docId,
        action: action,
        payload: queuedPayload,
        merge: merge,
      );
    } catch (_) {
      // Keep durable outbox entry for sync coordinator retry.
    }
  }

  Future<SettingsCacheEntity?> _getCacheEntry(String key) async {
    if (!_cacheKeys.contains(key)) return null;
    try {
      return _dbService.settingsCache.filter().keyEqualTo(key).findFirst();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _readCachedMap(String key) async {
    final entry = await _getCacheEntry(key);
    if (entry == null) return null;
    try {
      final decoded = jsonDecode(entry.payloadJson);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      debugPrint('Error reading cached map $key: $e');
    }
    return null;
  }

  Future<List<dynamic>?> _readCachedList(String key) async {
    final entry = await _getCacheEntry(key);
    if (entry == null) return null;
    try {
      final decoded = jsonDecode(entry.payloadJson);
      if (decoded is List) {
        return decoded;
      }
    } catch (e) {
      debugPrint('Error reading cached list $key: $e');
    }
    return null;
  }

  Future<void> _writeCache(String key, Object payload) async {
    if (!_cacheKeys.contains(key)) return;
    try {
      final entry = SettingsCacheEntity()
        ..key = key
        ..payloadJson = jsonEncode(payload);
      await _dbService.db.writeTxn(() async {
        await _dbService.settingsCache.put(entry);
      });
    } catch (e) {
      debugPrint('Error writing cache for $key: $e');
    }
  }

  List<Map<String, dynamic>> _normalizeMapList(List<dynamic> items) {
    final output = <Map<String, dynamic>>[];
    for (final item in items) {
      if (item is Map) {
        output.add(Map<String, dynamic>.from(item));
      }
    }
    return output;
  }

  Future<List<Map<String, dynamic>>> _readCachedMapList(String key) async {
    final cached = await _readCachedList(key);
    if (cached == null || cached.isEmpty) return [];
    return _normalizeMapList(cached);
  }

  Map<String, dynamic> _defaultSettingsMetadata() {
    return {
      'schema_version': currentSettingsSchemaVersion,
      'last_migration': null,
    };
  }

  Future<Map<String, dynamic>?> _readSettingsDocumentRaw({
    required String collection,
    required String docId,
    String? cacheKey,
  }) async {
    if (cacheKey != null) {
      final cached = await _readCachedMap(cacheKey);
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final firestore = db;
    if (firestore == null) {
      if (cacheKey != null) return _readCachedMap(cacheKey);
      return null;
    }

    try {
      final snapshot = await firestore.collection(collection).doc(docId).get();
      if (!snapshot.exists) {
        if (cacheKey != null) return _readCachedMap(cacheKey);
        return null;
      }
      final raw = snapshot.data();
      if (raw == null || raw.isEmpty) {
        if (cacheKey != null) return _readCachedMap(cacheKey);
        return null;
      }
      final data = Map<String, dynamic>.from(raw);
      if (cacheKey != null) {
        await _writeCache(cacheKey, data);
      }
      return data;
    } catch (e) {
      handleError(e, 'readSettingsDocumentRaw($collection/$docId)');
      if (cacheKey != null) return _readCachedMap(cacheKey);
      return null;
    }
  }

  Future<void> _writeSettingsMetadata({
    required int schemaVersion,
    String? lastMigration,
  }) async {
    final payload = {
      'schema_version': schemaVersion,
      'last_migration': lastMigration ?? DateTime.now().toIso8601String(),
    };
    await _queueDocWrite(
      collection: publicSettingsCollection,
      docId: settingsMetadataDocId,
      action: 'set',
      payload: payload,
      merge: true,
    );
    await _writeCache(settingsMetadataDocId, payload);
  }

  Future<List<Map<String, dynamic>>> _readSharedPrefsMapList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return _normalizeMapList(decoded);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadSchemesForBackup() async {
    final local = await _readSharedPrefsMapList('local_schemes');
    if (local.isNotEmpty) return local;

    final firestore = db;
    if (firestore == null) return [];

    try {
      final snapshot = await FirestoreQueryDelegate(firestore).getCollection(
        collection: 'schemes',
      );
      final fetched = snapshot.docs.map((doc) {
        final row = Map<String, dynamic>.from(doc.data());
        row['id'] = doc.id;
        return row;
      }).toList();
      if (fetched.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_schemes', jsonEncode(fetched));
      }
      return fetched;
    } catch (e) {
      handleError(e, 'loadSchemesForBackup');
      return local;
    }
  }

  Map<String, dynamic> _validateSettingsBackupPayload(
    Map<String, dynamic> payload,
  ) {
    final errors = <String>[];

    if (payload['backup_type'] != 'settings_backup') {
      errors.add('backup_type must be settings_backup');
    }
    if (payload['company_settings'] != null &&
        payload['company_settings'] is! Map) {
      errors.add('company_settings must be an object');
    }
    if (payload['tax_settings'] != null && payload['tax_settings'] is! Map) {
      errors.add('tax_settings must be an object');
    }
    if (payload['series'] != null && payload['series'] is! List) {
      errors.add('series must be an array');
    }
    if (payload['schemes'] != null && payload['schemes'] is! List) {
      errors.add('schemes must be an array');
    }
    if (payload['fuel_settings'] != null && payload['fuel_settings'] is! Map) {
      errors.add('fuel_settings must be an object');
    }
    if (payload['preferences'] != null && payload['preferences'] is! Map) {
      errors.add('preferences must be an object');
    }
    if (payload['pdf_templates'] != null && payload['pdf_templates'] is! List) {
      errors.add('pdf_templates must be an array');
    }

    return {'is_valid': errors.isEmpty, 'errors': errors};
  }

  String _resolveAuditUserId(String? userId) {
    final candidate = (userId ?? '').trim();
    if (candidate.isNotEmpty) return candidate;
    final authUserId = auth?.currentUser?.uid ?? '';
    if (authUserId.isNotEmpty) return authUserId;
    return 'system';
  }

  String _resolveAuditUserName(String? userName) {
    final candidate = (userName ?? '').trim();
    if (candidate.isNotEmpty) return candidate;
    final authName = (auth?.currentUser?.displayName ?? '').trim();
    if (authName.isNotEmpty) return authName;
    return 'System';
  }

  Future<void> _logSettingsAudit({
    required String module,
    required String settingKey,
    required dynamic oldValue,
    required dynamic newValue,
    required String source,
    String? userId,
    String? userName,
  }) async {
    try {
      await _settingsAuditService.logSettingsChange(
        userId: _resolveAuditUserId(userId),
        userName: _resolveAuditUserName(userName),
        module: module,
        settingKey: settingKey,
        oldValue: oldValue,
        newValue: newValue,
        source: source,
      );
    } catch (_) {
      // Settings updates must stay non-blocking if audit logging fails.
    }
  }

  Future<List<Map<String, dynamic>>> _loadDepartmentsCache() async {
    final cached = await _readCachedMapList(departmentsCollection);
    if (cached.isNotEmpty) return cached;

    try {
      final prefs = await SharedPreferences.getInstance();
      final deptsJson = prefs.getString('local_departments');
      if (deptsJson == null) return [];
      final List<dynamic> deptsList = jsonDecode(deptsJson);
      final normalized = _normalizeMapList(deptsList);
      if (normalized.isNotEmpty) {
        await _writeCache(departmentsCollection, normalized);
      }
      return normalized;
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistDepartmentsCache(
    List<Map<String, dynamic>> departments,
  ) async {
    await _writeCache(departmentsCollection, departments);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_departments', jsonEncode(departments));
    } catch (e) {
      debugPrint('Error persisting local departments: $e');
    }
  }

  Future<List<String>> getRoutes() async {
    final routeNames = <String>{}; // Use Set to auto-deduplicate

    // 1. Try Local DB (Offline First)
    try {
      final entities = await _dbService.routes
          .filter()
          .isDeletedEqualTo(false)
          .sortByIsActiveDesc()
          .thenByCreatedAtDesc()
          .findAll();

      for (final entity in entities) {
        if (entity.name.trim().isNotEmpty) {
          routeNames.add(entity.name.trim());
        }
      }
    } catch (e) {
      debugPrint('SettingsService.getRoutes local error: $e');
    }

    // 2. Fallback to Firestore if local is empty
    if (routeNames.isEmpty) {
      try {
        final firestore = db;
        if (firestore != null) {
          final snapshot = await FirestoreQueryDelegate(firestore).getCollection(
            collection: 'routes',
            orderBy: 'name',
          );

          for (final doc in snapshot.docs) {
            final name = (doc.data()['name'] as String? ?? '').trim();
            if (name.isNotEmpty) {
              routeNames.add(name);
            }
          }
        }
      } catch (e) {
        debugPrint('SettingsService.getRoutes firestore error: $e');
      }
    }

    // Return sorted unique list
    final sortedList = routeNames.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sortedList;
  }

  Future<GstSettings?> getGstSettings() async {
    try {
      final cached = await _readCachedMap(gstSettingsDocId);
      if (cached != null) {
        return GstSettings.fromJson(cached);
      }

      final firestore = db;
      if (firestore == null) return null;

      final snapshot = await FirestoreQueryDelegate(firestore).getDocument(
        collection: 'settings',
        documentId: gstSettingsDocId,
      );
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        await _writeCache(gstSettingsDocId, data);
        return GstSettings.fromJson(data);
      }
      return null;
    } catch (e) {
      handleError(e, 'getGstSettings');
      return null;
    }
  }

  Future<bool> updateGstSettings(
    GstSettings settings,
    String userId,
    String? userName,
  ) async {
    try {
      final previous =
          await _readSettingsDocumentRaw(
            collection: 'settings',
            docId: gstSettingsDocId,
            cacheKey: gstSettingsDocId,
          ) ??
          <String, dynamic>{};
      final data = settings.toJson();
      await _queueDocWrite(
        collection: 'settings',
        docId: gstSettingsDocId,
        action: 'set',
        payload: data,
        merge: true,
      );

      await createAuditLog(
        collectionName: 'settings',
        docId: gstSettingsDocId,
        action: 'update',
        changes: data,
        userId: userId,
        userName: userName,
      );

      await _writeCache(gstSettingsDocId, data);
      await _logSettingsAudit(
        module: 'tax_settings',
        settingKey: gstSettingsDocId,
        oldValue: previous,
        newValue: data,
        source: 'ui',
        userId: userId,
        userName: userName,
      );
      return true;
    } catch (e) {
      handleError(e, 'updateGstSettings');
      return false;
    }
  }

  Future<String?> uploadCompanyLogo(File file) async {
    try {
      final storageRef = storage;
      if (storageRef == null) return null;

      final ref = storageRef
          .ref()
          .child('company_logos')
          .child('logo_${DateTime.now().millisecondsSinceEpoch}.png');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      handleError(e, 'uploadCompanyLogo');
      return null;
    }
  }

  Future<bool> updateCompanyProfileLogo(String logoUrl) async {
    try {
      final now = DateTime.now().toIso8601String();
      final dataToUpdate = {'logoUrl': logoUrl, 'updatedAt': now};
      final existing = await _readCachedMap(companyProfileDocId) ?? {};
      final previous = Map<String, dynamic>.from(existing);

      await _queueDocWrite(
        collection: publicSettingsCollection,
        docId: companyProfileDocId,
        action: 'update',
        payload: dataToUpdate,
        merge: true,
      );

      final merged = <String, dynamic>{...existing, ...dataToUpdate};
      await _writeCache(companyProfileDocId, merged);
      await _logSettingsAudit(
        module: 'company_settings',
        settingKey: companyProfileDocId,
        oldValue: previous,
        newValue: merged,
        source: 'ui',
      );
      return true;
    } catch (e) {
      handleError(e, 'updateCompanyProfileLogo');
      return false;
    }
  }

  Future<CompanyProfileData?> getCompanyProfileClient() async {
    try {
      final cached = await _readCachedMap(companyProfileDocId);
      if (cached != null) {
        return CompanyProfileData.fromJson(cached);
      }

      final firestore = db;
      if (firestore == null) return null;

      final docRef = firestore
          .collection(publicSettingsCollection)
          .doc(companyProfileDocId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        await _writeCache(companyProfileDocId, data);
        return CompanyProfileData.fromJson(data);
      }
      return null;
    } catch (e) {
      handleError(e, 'getCompanyProfileClient');
      return null;
    }
  }

  Future<bool> updateCompanyProfileClient({
    String? name,
    String? tagline,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    String? gstin,
    String? pan,
    BankDetails? bankDetails,
    String? userId,
    String? userName,
  }) async {
    try {
      final dataToUpdate = <String, dynamic>{};
      if (name != null) dataToUpdate['name'] = name;
      if (tagline != null) dataToUpdate['tagline'] = tagline;
      if (address != null) dataToUpdate['address'] = address;
      if (phone != null) dataToUpdate['phone'] = phone;
      if (email != null) dataToUpdate['email'] = email;
      if (website != null) dataToUpdate['website'] = website;
      if (logoUrl != null) dataToUpdate['logoUrl'] = logoUrl;
      if (gstin != null) dataToUpdate['gstin'] = gstin;
      if (pan != null) dataToUpdate['pan'] = pan;
      if (bankDetails != null) {
        dataToUpdate['bankDetails'] = bankDetails.toJson();
      }

      if (dataToUpdate.isNotEmpty) {
        final existing = await _readCachedMap(companyProfileDocId) ?? {};
        final previous = Map<String, dynamic>.from(existing);
        await _queueDocWrite(
          collection: publicSettingsCollection,
          docId: companyProfileDocId,
          action: 'update',
          payload: dataToUpdate,
          merge: true,
        );

        await createAuditLog(
          collectionName: publicSettingsCollection,
          docId: companyProfileDocId,
          action: 'update',
          changes: dataToUpdate,
          userId: userId ?? '',
          userName: userName,
        );

        final merged = <String, dynamic>{...existing, ...dataToUpdate};
        await _writeCache(companyProfileDocId, merged);
        await _logSettingsAudit(
          module: 'company_settings',
          settingKey: companyProfileDocId,
          oldValue: previous,
          newValue: merged,
          source: 'ui',
          userId: userId,
          userName: userName,
        );

        return true;
      }
      return false;
    } catch (e) {
      handleError(e, 'updateCompanyProfileClient');
      return false;
    }
  }

  Future<GeneralSettingsData?> getGeneralSettings({
    bool forceRefresh = false,
  }) async {
    try {
      final cached = await _readCachedMap(generalSettingsDocId);
      if (!forceRefresh && cached != null) {
        return GeneralSettingsData.fromJson(cached);
      }

      final firestore = db;
      if (firestore == null) {
        return cached != null ? GeneralSettingsData.fromJson(cached) : null;
      }

      final docRef = firestore
          .collection(publicSettingsCollection)
          .doc(generalSettingsDocId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        await _writeCache(generalSettingsDocId, data);
        return GeneralSettingsData.fromJson(data);
      }
      if (cached != null) {
        return GeneralSettingsData.fromJson(cached);
      }
      return null;
    } catch (e) {
      handleError(e, 'getGeneralSettings');
      final cached = await _readCachedMap(generalSettingsDocId);
      if (cached != null) {
        return GeneralSettingsData.fromJson(cached);
      }
      return null;
    }
  }

  Future<bool> updateGeneralSettings(
    GeneralSettingsData settings,
    String userId,
    String? userName,
  ) async {
    try {
      final previous =
          await _readSettingsDocumentRaw(
            collection: publicSettingsCollection,
            docId: generalSettingsDocId,
            cacheKey: generalSettingsDocId,
          ) ??
          <String, dynamic>{};
      final data = settings.toJson();

      await _queueDocWrite(
        collection: publicSettingsCollection,
        docId: generalSettingsDocId,
        action: 'set',
        payload: data,
        merge: true,
      );

      await createAuditLog(
        collectionName: publicSettingsCollection,
        docId: generalSettingsDocId,
        action: 'update',
        changes: data,
        userId: userId,
        userName: userName,
      );

      await _writeCache(generalSettingsDocId, data);
      await _logSettingsAudit(
        module: 'company_settings',
        settingKey: generalSettingsDocId,
        oldValue: previous,
        newValue: data,
        source: 'ui',
        userId: userId,
        userName: userName,
      );
      return true;
    } catch (e) {
      handleError(e, 'updateGeneralSettings');
      return false;
    }
  }

  Future<bool> isStrictAccountingModeEnabled() async {
    final settings = await getGeneralSettings();
    return settings?.strictAccountingMode ?? false;
  }

  Future<bool> updateStrictAccountingMode({
    required bool enabled,
    required String userId,
    String? userName,
  }) async {
    final current = await getGeneralSettings() ?? GeneralSettingsData();
    current.strictAccountingMode = enabled;
    return updateGeneralSettings(current, userId, userName);
  }

  Future<List<OrgDepartment>> getDepartments() async {
    try {
      final cached = await _loadDepartmentsCache();
      if (cached.isNotEmpty) {
        cached.sort(
          (a, b) =>
              (a['order'] as num? ?? 0).compareTo(b['order'] as num? ?? 0),
        );
        return cached
            .map(
              (dept) => OrgDepartment.fromJson(
                (dept['id'] as String?) ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                dept,
              ),
            )
            .toList();
      }

      final firestore = db;
      if (firestore != null) {
        try {
          final snapshot = await firestore
              .collection(departmentsCollection)
              .orderBy('order')
              .get();
          final fetched = snapshot.docs
              .map((doc) {
                final data = Map<String, dynamic>.from(doc.data());
                data['id'] = doc.id;
                return data;
              })
              .where((dept) => dept['isDeleted'] != true)
              .toList();

          if (fetched.isNotEmpty) {
            await _persistDepartmentsCache(fetched);
          }

          return fetched
              .map((dept) => OrgDepartment.fromJson(dept['id'], dept))
              .toList();
        } catch (_) {
          // Firebase failed, fallback to local
        }
      }

      return [];
    } catch (e) {
      handleError(e, 'getDepartments');
      return [];
    }
  }

  Future<bool> addDepartment(
    Map<String, dynamic> data,
    String userId,
    String? userName,
  ) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      final now = DateTime.now().toIso8601String();
      final deptId = DateTime.now().millisecondsSinceEpoch.toString();
      payload['id'] = deptId;
      payload['createdAt'] = now;
      payload['updatedAt'] = now;
      if (payload['teams'] == null) payload['teams'] = [];
      if (payload['order'] == null) payload['order'] = 0;

      await _queueDocWrite(
        collection: departmentsCollection,
        docId: deptId,
        action: 'set',
        payload: payload,
        merge: true,
      );
      await createAuditLog(
        collectionName: departmentsCollection,
        docId: deptId,
        action: 'create',
        changes: payload,
        userId: userId,
        userName: userName,
      );

      final departments = await _loadDepartmentsCache();
      departments.removeWhere((d) => d['id'] == deptId);
      departments.add(payload);
      await _persistDepartmentsCache(departments);
      return true;
    } catch (e) {
      handleError(e, 'addDepartment');
      return false;
    }
  }

  Future<bool> updateDepartment(
    String id,
    Map<String, dynamic> data,
    String userId,
    String? userName,
  ) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      payload['id'] = id;
      payload['updatedAt'] = DateTime.now().toIso8601String();

      await _queueDocWrite(
        collection: departmentsCollection,
        docId: id,
        action: 'update',
        payload: payload,
        merge: true,
      );
      await createAuditLog(
        collectionName: departmentsCollection,
        docId: id,
        action: 'update',
        changes: payload,
        userId: userId,
        userName: userName,
      );

      final departments = await _loadDepartmentsCache();
      final index = departments.indexWhere((d) => d['id'] == id);
      if (index != -1) {
        departments[index] = {...departments[index], ...payload};
      } else {
        departments.add(payload);
      }
      await _persistDepartmentsCache(departments);
      return true;
    } catch (e) {
      handleError(e, 'updateDepartment');
      return false;
    }
  }

  Future<bool> deleteDepartment(
    String id,
    String userId,
    String? userName,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _queueDocWrite(
        collection: departmentsCollection,
        docId: id,
        action: 'delete',
        payload: {'isDeleted': true, 'updatedAt': now},
        merge: true,
      );
      await createAuditLog(
        collectionName: departmentsCollection,
        docId: id,
        action: 'delete',
        changes: {'deleted': true},
        userId: userId,
        userName: userName,
      );

      final departments = await _loadDepartmentsCache();
      departments.removeWhere((d) => d['id'] == id);
      await _persistDepartmentsCache(departments);
      return true;
    } catch (e) {
      handleError(e, 'deleteDepartment');
      return false;
    }
  }

  Future<bool> addTeamToDepartment(
    String deptId,
    DeptTeam team,
    String userId,
    String? userName,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final departments = await _loadDepartmentsCache();
      final index = departments.indexWhere((d) => d['id'] == deptId);
      if (index != -1) {
        final deptMap = Map<String, dynamic>.from(departments[index]);
        final teams = List<Map<String, dynamic>>.from(
          (deptMap['teams'] as List<dynamic>? ?? []).map(
            (teamData) => Map<String, dynamic>.from(teamData as Map),
          ),
        );
        if (!teams.any((t) => t['code'] == team.code)) {
          teams.add(team.toJson());
        }
        deptMap['teams'] = teams;
        deptMap['updatedAt'] = now;
        departments[index] = deptMap;
        await _persistDepartmentsCache(departments);

        await _queueDocWrite(
          collection: departmentsCollection,
          docId: deptId,
          action: 'update',
          payload: {'teams': teams, 'updatedAt': now},
          merge: true,
        );
      }

      return true;
    } catch (e) {
      handleError(e, 'addTeamToDepartment');
      return false;
    }
  }

  Future<bool> removeTeamFromDepartment(
    String deptId,
    DeptTeam team,
    String userId,
    String? userName,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final departments = await _loadDepartmentsCache();
      final index = departments.indexWhere((d) => d['id'] == deptId);
      if (index != -1) {
        final deptMap = Map<String, dynamic>.from(departments[index]);
        final teams = List<Map<String, dynamic>>.from(
          (deptMap['teams'] as List<dynamic>? ?? []).map(
            (teamData) => Map<String, dynamic>.from(teamData as Map),
          ),
        );
        teams.removeWhere((t) => t['code'] == team.code);
        deptMap['teams'] = teams;
        deptMap['updatedAt'] = now;
        departments[index] = deptMap;
        await _persistDepartmentsCache(departments);

        await _queueDocWrite(
          collection: departmentsCollection,
          docId: deptId,
          action: 'update',
          payload: {'teams': teams, 'updatedAt': now},
          merge: true,
        );
      }

      return true;
    } catch (e) {
      handleError(e, 'removeTeamFromDepartment');
      return false;
    }
  }

  Future<Map<String, int>> syncDefaultDepartments(
    List<OrgDepartment> currentDepts,
    String userId,
    String? userName,
  ) async {
    final defaults = [
      {
        'code': 'vehicle_maintenance',
        'name': 'Vehicle Maintenance',
        'description':
            'Handles maintenance, servicing, repairs, and operational upkeep of company vehicles.',
        'teams': [
          {
            'code': 'vehicle_maintenance_log',
            'name': 'Vehicle Maintenance Log',
          },
          {'code': 'diesel_tracking_log', 'name': 'Diesel Tracking Log'},
        ],
        'order': 0,
      },
      {
        'code': 'bhatti',
        'name': 'Bhatti',
        'description':
            'Processes raw materials to produce semi-finished goods.',
        'teams': [
          {'code': 'gita_bhatti', 'name': 'Gita Bhatti'},
          {'code': 'sona_bhatti', 'name': 'Sona Bhatti'},
        ],
        'order': 1,
      },
      {
        'code': 'sales',
        'name': 'Sales',
        'description':
            'Handles direct local and city-level sales without dealer routing.',
        'teams': [
          {'code': 'retail_sales', 'name': 'Retail Sales'},
          {'code': 'dealer_sales', 'name': 'Dealer Sales'},
          {'code': 'local_sales', 'name': 'Local Sales'},
        ],
        'order': 2,
      },
      {
        'code': 'administration',
        'name': 'Administration',
        'description':
            'Handles system administration, user management, and overall governance.',
        'teams': [
          {'code': 'system_management', 'name': 'System Management'},
        ],
        'order': 3,
      },
    ];

    int added = 0;
    int updated = 0;

    for (final def in defaults) {
      final existingIndex = currentDepts.indexWhere(
        (d) => d.code == def['code'],
      );
      if (existingIndex != -1) {
        final existing = currentDepts[existingIndex];
        final currentTeams = existing.teams.map((t) => t.code).toSet();
        final defTeams = (def['teams'] as List).cast<Map<String, dynamic>>();
        final teamsToAdd = defTeams
            .where((t) => !currentTeams.contains(t['code']))
            .toList();

        if (teamsToAdd.isNotEmpty) {
          final updatedTeams = [
            ...existing.teams.map((t) => t.toJson()),
            ...teamsToAdd,
          ];
          await updateDepartment(
            existing.id,
            {'teams': updatedTeams},
            userId,
            userName,
          );
          updated++;
        }
      } else {
        await addDepartment({...def, 'isActive': true}, userId, userName);
        added++;
      }
    }
    return {'added': added, 'updated': updated};
  }

  Future<List<AppCurrency>> getCurrencies() async {
    try {
      final cached = await _readCachedMapList(currenciesCollection);
      if (cached.isNotEmpty) {
        return cached
            .map(
              (data) => AppCurrency.fromJson(data['id'] as String? ?? '', data),
            )
            .toList();
      }

      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore.collection(currenciesCollection).get();
      final fetched = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();

      if (fetched.isNotEmpty) {
        await _writeCache(currenciesCollection, fetched);
      }

      return fetched
          .map((data) => AppCurrency.fromJson(data['id'], data))
          .toList();
    } catch (e) {
      handleError(e, 'getCurrencies');
      return [];
    }
  }

  Future<bool> addCurrency(
    Map<String, dynamic> data,
    String userId,
    String? userName,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final currencyId = 'currency_${DateTime.now().microsecondsSinceEpoch}';
      final payload = <String, dynamic>{
        ...data,
        'id': currencyId,
        'updatedAt': now,
      };
      await _queueDocWrite(
        collection: currenciesCollection,
        docId: currencyId,
        action: 'set',
        payload: payload,
        merge: true,
      );
      await createAuditLog(
        collectionName: currenciesCollection,
        docId: currencyId,
        action: 'create',
        changes: payload,
        userId: userId,
        userName: userName,
      );

      final cached = await _readCachedMapList(currenciesCollection);
      cached.removeWhere((c) => c['id'] == currencyId);
      cached.add(payload);
      await _writeCache(currenciesCollection, cached);
      return true;
    } catch (e) {
      handleError(e, 'addCurrency');
      return false;
    }
  }

  Future<bool> updateCurrency(
    String id,
    Map<String, dynamic> data,
    String userId,
    String? userName,
  ) async {
    try {
      final payload = <String, dynamic>{
        ...data,
        'id': id,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _queueDocWrite(
        collection: currenciesCollection,
        docId: id,
        action: 'update',
        payload: payload,
        merge: true,
      );
      await createAuditLog(
        collectionName: currenciesCollection,
        docId: id,
        action: 'update',
        changes: payload,
        userId: userId,
        userName: userName,
      );

      final cached = await _readCachedMapList(currenciesCollection);
      final index = cached.indexWhere((c) => c['id'] == id);
      final updated = payload;
      if (index != -1) {
        cached[index] = {...cached[index], ...updated};
      } else {
        cached.add(updated);
      }
      await _writeCache(currenciesCollection, cached);
      return true;
    } catch (e) {
      handleError(e, 'updateCurrency');
      return false;
    }
  }

  Future<bool> deleteCurrency(
    String id,
    String userId,
    String? userName,
  ) async {
    try {
      await _queueDocWrite(
        collection: currenciesCollection,
        docId: id,
        action: 'delete',
        payload: {
          'isDeleted': true,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        merge: true,
      );
      await createAuditLog(
        collectionName: currenciesCollection,
        docId: id,
        action: 'delete',
        changes: {'deleted': true},
        userId: userId,
        userName: userName,
      );

      final cached = await _readCachedMapList(currenciesCollection);
      cached.removeWhere((c) => c['id'] == id);
      await _writeCache(currenciesCollection, cached);
      return true;
    } catch (e) {
      handleError(e, 'deleteCurrency');
      return false;
    }
  }

  Future<bool> setBaseCurrency(
    String currencyId,
    List<AppCurrency> allCurrencies,
    String userId,
    String? userName,
  ) async {
    try {
      for (final curr in allCurrencies) {
        final payload = <String, dynamic>{};
        if (curr.id == currencyId) {
          payload['isBaseCurrency'] = true;
          payload['exchangeRate'] = 1.0;
        } else {
          payload['isBaseCurrency'] = false;
        }
        payload['updatedAt'] = DateTime.now().toIso8601String();
        await _queueDocWrite(
          collection: currenciesCollection,
          docId: curr.id,
          action: 'update',
          payload: payload,
          merge: true,
        );
      }

      await createAuditLog(
        collectionName: currenciesCollection,
        docId: currencyId,
        action: 'set_base',
        changes: {'isBaseCurrency': true},
        userId: userId,
        userName: userName,
      );

      final cached = await _readCachedMapList(currenciesCollection);
      if (cached.isNotEmpty) {
        for (final curr in cached) {
          if (curr['id'] == currencyId) {
            curr['isBaseCurrency'] = true;
            curr['exchangeRate'] = 1.0;
          } else {
            curr['isBaseCurrency'] = false;
          }
        }
        await _writeCache(currenciesCollection, cached);
      }

      return true;
    } catch (e) {
      handleError(e, 'setBaseCurrency');
      return false;
    }
  }

  Future<List<TransactionSeries>> getTransactionSeries() async {
    try {
      final cached = await _readCachedMapList(seriesCollection);
      if (cached.isNotEmpty) {
        cached.sort(
          (a, b) => (a['type'] as String? ?? '').compareTo(
            b['type'] as String? ?? '',
          ),
        );
        return cached
            .map(
              (data) =>
                  TransactionSeries.fromJson(data['id'] as String? ?? '', data),
            )
            .toList();
      }

      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(seriesCollection)
          .orderBy('type')
          .get();
      final fetched = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();

      if (fetched.isNotEmpty) {
        await _writeCache(seriesCollection, fetched);
      }

      return fetched
          .map((data) => TransactionSeries.fromJson(data['id'], data))
          .toList();
    } catch (e) {
      handleError(e, 'getTransactionSeries');
      return [];
    }
  }

  Future<bool> updateTransactionSeries(
    TransactionSeries series,
    bool isNew,
    String userId,
    String? userName,
  ) async {
    try {
      final cachedBefore = await _readCachedMapList(seriesCollection);
      final previous = cachedBefore.firstWhere(
        (s) => s['id'] == series.id,
        orElse: () => <String, dynamic>{},
      );
      final data = series.toJson();
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _queueDocWrite(
        collection: seriesCollection,
        docId: series.id,
        action: isNew ? 'set' : 'update',
        payload: data,
        merge: true,
      );

      await createAuditLog(
        collectionName: seriesCollection,
        docId: series.id,
        action: isNew ? 'create' : 'update',
        changes: data,
        userId: userId,
        userName: userName,
      );

      final cached = List<Map<String, dynamic>>.from(cachedBefore);
      final index = cached.indexWhere((s) => s['id'] == series.id);
      final updated = <String, dynamic>{...data, 'id': series.id};
      if (index != -1) {
        cached[index] = {...cached[index], ...updated};
      } else {
        cached.add(updated);
      }
      await _writeCache(seriesCollection, cached);
      await _logSettingsAudit(
        module: 'series',
        settingKey: '$seriesCollection.${series.id}',
        oldValue: previous.isEmpty ? null : previous,
        newValue: updated,
        source: 'ui',
        userId: userId,
        userName: userName,
      );
      return true;
    } catch (e) {
      handleError(e, 'updateTransactionSeries');
      return false;
    }
  }

  Future<FuelSettings?> getFuelSettings() async {
    try {
      final cached = await _readCachedMap(fuelSettingsDocId);
      if (cached != null) {
        return FuelSettings.fromJson(cached);
      }

      final firestore = db;
      if (firestore == null) return null;

      final docRef = firestore
          .collection(publicSettingsCollection)
          .doc(fuelSettingsDocId);
      final snapshot = await docRef.get().timeout(const Duration(seconds: 3));
      if (snapshot.exists) {
        final data = snapshot.data()!;
        await _writeCache(fuelSettingsDocId, data);
        return FuelSettings.fromJson(data);
      }
      return null;
    } catch (e) {
      handleError(e, 'getFuelSettings');
      return null;
    }
  }

  Future<bool> updateFuelSettings(
    FuelSettings settings,
    String userId,
    String? userName,
  ) async {
    try {
      final previous =
          await _readSettingsDocumentRaw(
            collection: publicSettingsCollection,
            docId: fuelSettingsDocId,
            cacheKey: fuelSettingsDocId,
          ) ??
          <String, dynamic>{};
      final data = settings.toJson();
      await _queueDocWrite(
        collection: publicSettingsCollection,
        docId: fuelSettingsDocId,
        action: 'set',
        payload: data,
        merge: true,
      );

      await createAuditLog(
        collectionName: publicSettingsCollection,
        docId: fuelSettingsDocId,
        action: 'update',
        changes: data,
        userId: userId,
        userName: userName,
      );

      await _writeCache(fuelSettingsDocId, data);
      await _logSettingsAudit(
        module: 'fuel_settings',
        settingKey: fuelSettingsDocId,
        oldValue: previous,
        newValue: data,
        source: 'ui',
        userId: userId,
        userName: userName,
      );
      return true;
    } catch (e) {
      handleError(e, 'updateFuelSettings');
      return false;
    }
  }

  Future<DutySettings?> getDutySettings() async {
    try {
      final cached = await _readCachedMap(dutySettingsDocId);
      if (cached != null) {
        return DutySettings.fromJson(cached);
      }

      final firestore = db;
      if (firestore == null) return null;

      final docRef = firestore
          .collection(publicSettingsCollection)
          .doc(dutySettingsDocId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        await _writeCache(dutySettingsDocId, data);
        return DutySettings.fromJson(data);
      }
      return null;
    } catch (e) {
      handleError(e, 'getDutySettings');
      return null;
    }
  }

  Future<bool> updateDutySettings(
    DutySettings settings,
    String userId,
    String? userName,
  ) async {
    try {
      final data = settings.toJson();
      await _queueDocWrite(
        collection: publicSettingsCollection,
        docId: dutySettingsDocId,
        action: 'set',
        payload: data,
        merge: true,
      );

      await createAuditLog(
        collectionName: publicSettingsCollection,
        docId: dutySettingsDocId,
        action: 'update',
        changes: data,
        userId: userId,
        userName: userName,
      );

      await _writeCache(dutySettingsDocId, data);
      return true;
    } catch (e) {
      handleError(e, 'updateDutySettings');
      return false;
    }
  }

  Future<ReportsPreferences> getReportsPreferences() async {
    try {
      final cached = await _readCachedMap(reportsPrefsDocId);
      if (cached != null) {
        return ReportsPreferences.fromJson(cached);
      }

      final firestore = db;
      if (firestore == null) return ReportsPreferences();

      final doc = await firestore
          .collection(publicSettingsCollection)
          .doc(reportsPrefsDocId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        await _writeCache(reportsPrefsDocId, data);
        return ReportsPreferences.fromJson(data);
      }
      return ReportsPreferences();
    } catch (e) {
      return ReportsPreferences();
    }
  }

  Future<bool> updateReportsPreferences(
    ReportsPreferences prefs,
    String userId,
    String? userName,
  ) async {
    try {
      final previous =
          await _readSettingsDocumentRaw(
            collection: publicSettingsCollection,
            docId: reportsPrefsDocId,
            cacheKey: reportsPrefsDocId,
          ) ??
          <String, dynamic>{};
      final data = prefs.toJson();
      await _queueDocWrite(
        collection: publicSettingsCollection,
        docId: reportsPrefsDocId,
        action: 'set',
        payload: data,
        merge: true,
      );
      await createAuditLog(
        collectionName: publicSettingsCollection,
        docId: reportsPrefsDocId,
        action: 'update',
        changes: data,
        userId: userId,
        userName: userName,
      );

      await _writeCache(reportsPrefsDocId, data);
      await _logSettingsAudit(
        module: 'preferences',
        settingKey: reportsPrefsDocId,
        oldValue: previous,
        newValue: data,
        source: 'ui',
        userId: userId,
        userName: userName,
      );
      return true;
    } catch (e) {
      handleError(e, 'updateReportsPreferences');
      return false;
    }
  }

  Map<String, PdfTemplate> _mapPdfTemplatesFromRows(
    List<Map<String, dynamic>> rows,
  ) {
    final templates = <String, PdfTemplate>{};
    for (final row in rows) {
      final id = (row['id'] as String?) ?? '';
      if (id.isEmpty) continue;
      templates[id] = PdfTemplate.fromJson(id, row);
    }
    return templates;
  }

  Future<Map<String, PdfTemplate>> getPdfTemplates() async {
    try {
      final cachedRows = await _readCachedMapList(pdfTemplatesCollection);
      if (cachedRows.isNotEmpty) {
        return _mapPdfTemplatesFromRows(cachedRows);
      }

      final firestore = db;
      if (firestore == null) return {};

      final snapshot = await firestore.collection(pdfTemplatesCollection).get();
      final fetched = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        fetched.add({'id': doc.id, ...doc.data()});
      }

      if (fetched.isNotEmpty) {
        await _writeCache(pdfTemplatesCollection, fetched);
      }

      return _mapPdfTemplatesFromRows(fetched);
    } catch (e) {
      handleError(e, 'getPdfTemplates');
      final cachedRows = await _readCachedMapList(pdfTemplatesCollection);
      if (cachedRows.isNotEmpty) {
        return _mapPdfTemplatesFromRows(cachedRows);
      }
      return {};
    }
  }

  Future<bool> savePdfTemplate(
    PdfTemplate template,
    String userId,
    String? userName,
  ) async {
    try {
      final cachedBefore = await _readCachedMapList(pdfTemplatesCollection);
      final previous = cachedBefore.firstWhere(
        (t) => t['id'] == template.type,
        orElse: () => <String, dynamic>{},
      );
      final data = {
        ...template.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _queueDocWrite(
        collection: pdfTemplatesCollection,
        docId: template.type,
        action: 'set',
        payload: data,
        merge: true,
      );

      await createAuditLog(
        collectionName: pdfTemplatesCollection,
        docId: template.type,
        action: 'save_template',
        changes: data,
        userId: userId,
        userName: userName,
      );

      final cached = List<Map<String, dynamic>>.from(cachedBefore);
      final updatedTemplate = <String, dynamic>{...data, 'id': template.type};
      final index = cached.indexWhere((t) => t['id'] == template.type);
      if (index != -1) {
        cached[index] = {...cached[index], ...updatedTemplate};
      } else {
        cached.add(updatedTemplate);
      }
      await _writeCache(pdfTemplatesCollection, cached);
      await _logSettingsAudit(
        module: 'pdf_templates',
        settingKey: '$pdfTemplatesCollection.${template.type}',
        oldValue: previous.isEmpty ? null : previous,
        newValue: updatedTemplate,
        source: 'ui',
        userId: userId,
        userName: userName,
      );

      return true;
    } catch (e) {
      handleError(e, 'savePdfTemplate');
      return false;
    }
  }

  Future<Map<String, dynamic>> getSettingsMetadata({
    bool ensureExists = false,
  }) async {
    try {
      final existing = await _readSettingsDocumentRaw(
        collection: publicSettingsCollection,
        docId: settingsMetadataDocId,
        cacheKey: settingsMetadataDocId,
      );
      if (existing != null && existing.isNotEmpty) {
        final merged = {..._defaultSettingsMetadata(), ...existing};
        await _writeCache(settingsMetadataDocId, merged);
        return merged;
      }
    } catch (e) {
      handleError(e, 'getSettingsMetadata');
    }

    final fallback = {
      ..._defaultSettingsMetadata(),
      if (ensureExists) 'last_migration': DateTime.now().toIso8601String(),
    };

    if (ensureExists) {
      await _writeSettingsMetadata(
        schemaVersion: currentSettingsSchemaVersion,
        lastMigration: fallback['last_migration'] as String?,
      );
    }
    return fallback;
  }

  Future<String> exportSettings() async {
    try {
      final metadata = await getSettingsMetadata(ensureExists: true);
      final companyProfile =
          await _readSettingsDocumentRaw(
            collection: publicSettingsCollection,
            docId: companyProfileDocId,
            cacheKey: companyProfileDocId,
          ) ??
          <String, dynamic>{};
      final generalSettings =
          await _readSettingsDocumentRaw(
            collection: publicSettingsCollection,
            docId: generalSettingsDocId,
            cacheKey: generalSettingsDocId,
          ) ??
          <String, dynamic>{};
      final gstSettings =
          await _readSettingsDocumentRaw(
            collection: 'settings',
            docId: gstSettingsDocId,
            cacheKey: gstSettingsDocId,
          ) ??
          <String, dynamic>{};
      final fuelSettings =
          await _readSettingsDocumentRaw(
            collection: publicSettingsCollection,
            docId: fuelSettingsDocId,
            cacheKey: fuelSettingsDocId,
          ) ??
          <String, dynamic>{};
      final reportsPreferences =
          await _readSettingsDocumentRaw(
            collection: publicSettingsCollection,
            docId: reportsPrefsDocId,
            cacheKey: reportsPrefsDocId,
          ) ??
          <String, dynamic>{};
      final series = await getTransactionSeries();
      final schemes = await _loadSchemesForBackup();
      final templatesMap = await getPdfTemplates();
      final templates = templatesMap.values
          .map((template) => {'id': template.id, ...template.toJson()})
          .toList();

      final payload = <String, dynamic>{
        'backup_type': 'settings_backup',
        'exported_at': DateTime.now().toIso8601String(),
        'schema_version':
            (metadata['schema_version'] as num?)?.toInt() ??
            currentSettingsSchemaVersion,
        'settings_metadata': metadata,
        'company_settings': {
          'company_profile': companyProfile,
          'general_settings': generalSettings,
        },
        'tax_settings': {'gst': gstSettings},
        'series': series.map((s) => {'id': s.id, ...s.toJson()}).toList(),
        'schemes': schemes,
        'fuel_settings': fuelSettings,
        'preferences': {'reports_preferences': reportsPreferences},
        'pdf_templates': templates,
      };

      return const JsonEncoder.withIndent('  ').convert(payload);
    } catch (e) {
      handleError(e, 'exportSettings');
      return const JsonEncoder.withIndent('  ').convert({
        'backup_type': 'settings_backup',
        'exported_at': null,
        'schema_version': currentSettingsSchemaVersion,
        'error': 'export_failed',
      });
    }
  }

  Future<Map<String, dynamic>> importSettings(String jsonString) async {
    final importedModules = <String>[];
    final warnings = <String>[];
    final errors = <String>[];
    final importActorId = _resolveAuditUserId(null);
    final importActorName = _resolveAuditUserName(null);

    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return {
          'success': false,
          'imported_modules': importedModules,
          'warnings': warnings,
          'errors': ['Invalid JSON root. Expected object.'],
        };
      }
      payload = Map<String, dynamic>.from(decoded);
    } catch (_) {
      return {
        'success': false,
        'imported_modules': importedModules,
        'warnings': warnings,
        'errors': ['Invalid JSON format.'],
      };
    }

    final structure = _validateSettingsBackupPayload(payload);
    if (structure['is_valid'] != true) {
      return {
        'success': false,
        'imported_modules': importedModules,
        'warnings': warnings,
        'errors': List<String>.from(structure['errors'] as List<dynamic>),
      };
    }

    try {
      final metadata = payload['settings_metadata'];
      int importedSchemaVersion = currentSettingsSchemaVersion;
      if (metadata is Map) {
        importedSchemaVersion =
            (metadata['schema_version'] as num?)?.toInt() ??
            currentSettingsSchemaVersion;
      }
      await _writeSettingsMetadata(
        schemaVersion: importedSchemaVersion,
        lastMigration: DateTime.now().toIso8601String(),
      );
      importedModules.add('settings_metadata');
      await _logSettingsAudit(
        module: 'settings_metadata',
        settingKey: settingsMetadataDocId,
        oldValue: null,
        newValue: {'schema_version': importedSchemaVersion, 'source': 'import'},
        source: 'import',
        userId: importActorId,
        userName: importActorName,
      );

      final companySettings = payload['company_settings'];
      if (companySettings is Map) {
        final moduleChange = <String, dynamic>{};
        final companyProfile = companySettings['company_profile'];
        if (companyProfile is Map) {
          final profileMap = Map<String, dynamic>.from(companyProfile);
          await _queueDocWrite(
            collection: publicSettingsCollection,
            docId: companyProfileDocId,
            action: 'set',
            payload: profileMap,
            merge: true,
          );
          await _writeCache(companyProfileDocId, profileMap);
          importedModules.add('company_profile');
          moduleChange['company_profile'] = profileMap;
        }

        final generalSettings = companySettings['general_settings'];
        if (generalSettings is Map) {
          final generalMap = Map<String, dynamic>.from(generalSettings);
          await _queueDocWrite(
            collection: publicSettingsCollection,
            docId: generalSettingsDocId,
            action: 'set',
            payload: generalMap,
            merge: true,
          );
          await _writeCache(generalSettingsDocId, generalMap);
          importedModules.add('general_settings');
          moduleChange['general_settings'] = generalMap;
        }

        if (moduleChange.isNotEmpty) {
          await _logSettingsAudit(
            module: 'company_settings',
            settingKey: 'company_settings',
            oldValue: null,
            newValue: moduleChange,
            source: 'import',
            userId: importActorId,
            userName: importActorName,
          );
        }
      }

      final taxSettings = payload['tax_settings'];
      if (taxSettings is Map) {
        final gstSettings = taxSettings['gst'];
        if (gstSettings is Map) {
          final gstMap = Map<String, dynamic>.from(gstSettings);
          await _queueDocWrite(
            collection: 'settings',
            docId: gstSettingsDocId,
            action: 'set',
            payload: gstMap,
            merge: true,
          );
          await _writeCache(gstSettingsDocId, gstMap);
          importedModules.add('gst_settings');
          await _logSettingsAudit(
            module: 'tax_settings',
            settingKey: gstSettingsDocId,
            oldValue: null,
            newValue: gstMap,
            source: 'import',
            userId: importActorId,
            userName: importActorName,
          );
        }
      }

      final fuelSettings = payload['fuel_settings'];
      if (fuelSettings is Map) {
        final fuelMap = Map<String, dynamic>.from(fuelSettings);
        await _queueDocWrite(
          collection: publicSettingsCollection,
          docId: fuelSettingsDocId,
          action: 'set',
          payload: fuelMap,
          merge: true,
        );
        await _writeCache(fuelSettingsDocId, fuelMap);
        importedModules.add('fuel_settings');
        await _logSettingsAudit(
          module: 'fuel_settings',
          settingKey: fuelSettingsDocId,
          oldValue: null,
          newValue: fuelMap,
          source: 'import',
          userId: importActorId,
          userName: importActorName,
        );
      }

      final preferences = payload['preferences'];
      if (preferences is Map) {
        final reportsPrefs = preferences['reports_preferences'];
        if (reportsPrefs is Map) {
          final prefsMap = Map<String, dynamic>.from(reportsPrefs);
          await _queueDocWrite(
            collection: publicSettingsCollection,
            docId: reportsPrefsDocId,
            action: 'set',
            payload: prefsMap,
            merge: true,
          );
          await _writeCache(reportsPrefsDocId, prefsMap);
          importedModules.add('reports_preferences');
          await _logSettingsAudit(
            module: 'preferences',
            settingKey: reportsPrefsDocId,
            oldValue: null,
            newValue: prefsMap,
            source: 'import',
            userId: importActorId,
            userName: importActorName,
          );
        }
      }

      final seriesRows = payload['series'];
      if (seriesRows is List) {
        final importedSeries = <Map<String, dynamic>>[];
        for (final row in _normalizeMapList(seriesRows)) {
          final id = (row['id'] as String?)?.trim() ?? '';
          if (id.isEmpty) {
            warnings.add('Skipped transaction_series row without id.');
            continue;
          }
          final data = Map<String, dynamic>.from(row)..remove('id');
          await _queueDocWrite(
            collection: seriesCollection,
            docId: id,
            action: 'set',
            payload: data,
            merge: true,
          );
          importedSeries.add({'id': id, ...data});
        }
        if (importedSeries.isNotEmpty) {
          await _writeCache(seriesCollection, importedSeries);
          importedModules.add('transaction_series');
          await _logSettingsAudit(
            module: 'series',
            settingKey: seriesCollection,
            oldValue: null,
            newValue: {
              'count': importedSeries.length,
              'ids': importedSeries.map((e) => e['id']).toList(),
            },
            source: 'import',
            userId: importActorId,
            userName: importActorName,
          );
        }
      }

      final schemesRows = payload['schemes'];
      if (schemesRows is List) {
        final importedSchemes = <Map<String, dynamic>>[];
        for (final row in _normalizeMapList(schemesRows)) {
          final id = (row['id'] as String?)?.trim() ?? '';
          if (id.isEmpty) {
            warnings.add('Skipped schemes row without id.');
            continue;
          }
          final data = Map<String, dynamic>.from(row)..remove('id');
          await _queueDocWrite(
            collection: 'schemes',
            docId: id,
            action: 'set',
            payload: data,
            merge: true,
          );
          importedSchemes.add({'id': id, ...data});
        }
        if (importedSchemes.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('local_schemes', jsonEncode(importedSchemes));
          importedModules.add('schemes');
          await _logSettingsAudit(
            module: 'schemes',
            settingKey: 'schemes',
            oldValue: null,
            newValue: {
              'count': importedSchemes.length,
              'ids': importedSchemes.map((e) => e['id']).toList(),
            },
            source: 'import',
            userId: importActorId,
            userName: importActorName,
          );
        }
      }

      final templateRows = payload['pdf_templates'];
      if (templateRows is List) {
        final importedTemplates = <Map<String, dynamic>>[];
        for (final row in _normalizeMapList(templateRows)) {
          final id = (row['id'] as String?)?.trim() ?? '';
          if (id.isEmpty) {
            warnings.add('Skipped pdf_templates row without id.');
            continue;
          }
          final data = Map<String, dynamic>.from(row)..remove('id');
          await _queueDocWrite(
            collection: pdfTemplatesCollection,
            docId: id,
            action: 'set',
            payload: data,
            merge: true,
          );
          importedTemplates.add({'id': id, ...data});
        }
        if (importedTemplates.isNotEmpty) {
          await _writeCache(pdfTemplatesCollection, importedTemplates);
          importedModules.add('pdf_templates');
          await _logSettingsAudit(
            module: 'pdf_templates',
            settingKey: pdfTemplatesCollection,
            oldValue: null,
            newValue: {
              'count': importedTemplates.length,
              'ids': importedTemplates.map((e) => e['id']).toList(),
            },
            source: 'import',
            userId: importActorId,
            userName: importActorName,
          );
        }
      }
    } catch (e) {
      handleError(e, 'importSettings');
      errors.add('Import failed: $e');
    }

    return {
      'success': errors.isEmpty,
      'imported_modules': importedModules,
      'warnings': warnings,
      'errors': errors,
    };
  }

  Future<Map<String, dynamic>> validateSettingsIntegrity() async {
    final issues = <Map<String, dynamic>>[];
    final warnings = <Map<String, dynamic>>[];

    final metadata = await getSettingsMetadata(ensureExists: false);
    final detectedSchemaVersion = (metadata['schema_version'] as num?)?.toInt();

    if (detectedSchemaVersion == null) {
      issues.add({
        'code': 'missing_schema_version',
        'message': 'settings_metadata.schema_version is missing.',
      });
    } else if (detectedSchemaVersion != currentSettingsSchemaVersion) {
      issues.add({
        'code': 'schema_mismatch',
        'message':
            'Expected schema $currentSettingsSchemaVersion, found $detectedSchemaVersion.',
      });
    }

    final companyProfile = await _readSettingsDocumentRaw(
      collection: publicSettingsCollection,
      docId: companyProfileDocId,
      cacheKey: companyProfileDocId,
    );
    if (companyProfile == null || companyProfile.isEmpty) {
      issues.add({
        'code': 'missing_company_profile',
        'message': 'company_profile settings are missing.',
      });
    } else {
      final companyName = (companyProfile['name'] as String?)?.trim() ?? '';
      if (companyName.isEmpty) {
        warnings.add({
          'code': 'invalid_company_name',
          'message': 'company_profile.name is empty.',
        });
      }
    }

    final gstSettings = await _readSettingsDocumentRaw(
      collection: 'settings',
      docId: gstSettingsDocId,
      cacheKey: gstSettingsDocId,
    );
    if (gstSettings == null || gstSettings.isEmpty) {
      issues.add({
        'code': 'missing_gst_settings',
        'message': 'GST settings document is missing.',
      });
    } else {
      final gstType = (gstSettings['defaultGstType'] as String?) ?? 'none';
      if (!const {'none', 'cgstSgst', 'igst'}.contains(gstType)) {
        warnings.add({
          'code': 'invalid_gst_type',
          'message': 'defaultGstType "$gstType" is invalid.',
        });
      }
      final gstPercent = (gstSettings['defaultGstPercentage'] as num? ?? 0)
          .toDouble();
      if (gstPercent < 0 || gstPercent > 100) {
        warnings.add({
          'code': 'invalid_gst_percentage',
          'message': 'defaultGstPercentage "$gstPercent" is out of range.',
        });
      }
    }

    final fuelSettings = await _readSettingsDocumentRaw(
      collection: publicSettingsCollection,
      docId: fuelSettingsDocId,
      cacheKey: fuelSettingsDocId,
    );
    if (fuelSettings == null || fuelSettings.isEmpty) {
      issues.add({
        'code': 'missing_fuel_settings',
        'message': 'fuel_settings document is missing.',
      });
    } else {
      final minMileage = (fuelSettings['globalMinMileage'] as num? ?? 0)
          .toDouble();
      final penalty = (fuelSettings['globalPenaltyRate'] as num? ?? 0)
          .toDouble();
      if (minMileage < 0 || penalty < 0) {
        warnings.add({
          'code': 'invalid_fuel_values',
          'message': 'Fuel settings contain negative values.',
        });
      }
    }

    final reportsPrefs = await _readSettingsDocumentRaw(
      collection: publicSettingsCollection,
      docId: reportsPrefsDocId,
      cacheKey: reportsPrefsDocId,
    );
    if (reportsPrefs == null || reportsPrefs.isEmpty) {
      issues.add({
        'code': 'missing_reports_preferences',
        'message': 'reports_preferences document is missing.',
      });
    } else {
      final workDays = (reportsPrefs['requiredMonthlyWorkDays'] as num? ?? 0)
          .toInt();
      if (workDays <= 0) {
        warnings.add({
          'code': 'invalid_required_work_days',
          'message': 'requiredMonthlyWorkDays should be greater than 0.',
        });
      }
    }

    final series = await getTransactionSeries();
    if (series.isEmpty) {
      warnings.add({
        'code': 'missing_transaction_series',
        'message': 'No transaction series entries found.',
      });
    }
    final invalidSeries = series
        .where((s) => s.nextNumber <= 0 || s.padding <= 0)
        .map((s) => s.id)
        .toList();
    if (invalidSeries.isNotEmpty) {
      warnings.add({
        'code': 'invalid_series_values',
        'message':
            'Series entries have invalid counters: ${invalidSeries.join(", ")}',
      });
    }

    final pdfTemplates = await getPdfTemplates();
    final invalidTemplateIds = pdfTemplates.values
        .where((t) => t.htmlContent.trim().isEmpty)
        .map((t) => t.id)
        .toList();
    if (invalidTemplateIds.isNotEmpty) {
      warnings.add({
        'code': 'invalid_pdf_templates',
        'message':
            'PDF templates with empty htmlContent: ${invalidTemplateIds.join(", ")}',
      });
    }

    final status = issues.isEmpty
        ? (warnings.isEmpty ? 'healthy' : 'warning')
        : 'degraded';

    return {
      'status': status,
      'checked_at': DateTime.now().toIso8601String(),
      'expected_schema_version': currentSettingsSchemaVersion,
      'detected_schema_version': detectedSchemaVersion,
      'registered_modules': settingsRegistry.keys.toList(),
      'issues': issues,
      'warnings': warnings,
    };
  }

  Future<List<SettingsAuditLog>> getSettingsAuditLogs({
    DateTime? fromDate,
    DateTime? toDate,
    String? module,
    String? userId,
    int limit = 300,
  }) {
    return _settingsAuditService.getSettingsAuditLogs(
      fromDate: fromDate,
      toDate: toDate,
      module: module,
      userId: userId,
      limit: limit,
    );
  }

  Future<List<String>> getSettingsAuditModules() {
    return _settingsAuditService.getKnownModules();
  }

  Future<List<String>> getSettingsAuditUsers() {
    return _settingsAuditService.getKnownUsers();
  }
}
