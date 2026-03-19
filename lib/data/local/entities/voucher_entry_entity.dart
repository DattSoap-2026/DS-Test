import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'voucher_entry_entity.g.dart';

@Collection()
class VoucherEntryEntity extends BaseEntity {
  @Index()
  late String voucherId;

  @Index()
  late String accountCode;

  double debit = 0;
  double credit = 0;

  String? narration;

  @Index()
  DateTime? date;
  // Line-level narration

  @Index()
  String? route;

  @Index()
  String? district;

  @Index()
  String? division;

  @Index()
  String? salesmanId;

  String? salesmanName;
  String? saleDate;

  @Index()
  String? dealerId;

  String? dealerName;

  String? accountingDimensionsJson;
  int? dimensionVersion;
  String? voucherType;
  String? transactionType;
  String? transactionRefId;
  DateTime? createdAt;

  @override
  @ignore
  Id get isarId => fastHash(id);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isarId': isarId,
      'voucherId': voucherId,
      'accountCode': accountCode,
      'debit': debit,
      'credit': credit,
      'narration': narration,
      'date': date?.toIso8601String(),
      'route': route,
      'district': district,
      'division': division,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'saleDate': saleDate,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'accountingDimensionsJson': accountingDimensionsJson,
      'dimensionVersion': dimensionVersion,
      'voucherType': voucherType,
      'transactionType': transactionType,
      'transactionRefId': transactionRefId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
      'syncStatus': syncStatus.name,
    };
  }

  static VoucherEntryEntity fromJson(Map<String, dynamic> json) {
    return VoucherEntryEntity()
      ..id = parseString(json['id'])
      ..voucherId = parseString(json['voucherId'])
      ..accountCode = parseString(json['accountCode'] ?? json['ledgerId'])
      ..debit = parseDouble(json['debit'])
      ..credit = parseDouble(json['credit'])
      ..narration = json['narration']?.toString()
      ..date = parseDateOrNull(json['date'])
      ..route = json['route']?.toString()
      ..district = json['district']?.toString()
      ..division = json['division']?.toString()
      ..salesmanId = json['salesmanId']?.toString()
      ..salesmanName = json['salesmanName']?.toString()
      ..saleDate = json['saleDate']?.toString()
      ..dealerId = json['dealerId']?.toString()
      ..dealerName = json['dealerName']?.toString()
      ..accountingDimensionsJson = json['accountingDimensionsJson']?.toString()
      ..dimensionVersion = (json['dimensionVersion'] as num?)?.toInt()
      ..voucherType = json['voucherType']?.toString()
      ..transactionType = json['transactionType']?.toString()
      ..transactionRefId = json['transactionRefId']?.toString()
      ..createdAt = parseDateOrNull(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..isDeleted = json['isDeleted'] == true
      ..isSynced = json['isSynced'] == true
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'])
      ..syncStatus = parseSyncStatus(json['syncStatus']);
  }
}
