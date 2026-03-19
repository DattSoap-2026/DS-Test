import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'voucher_entity.g.dart';

@Collection()
class VoucherEntity extends BaseEntity {
  @Index(unique: true)
  late String transactionRefId; // readable ID e.g. VCH-2024-001

  @Index()
  late DateTime date;

  @Index()
  late String type; // 'Inventory', 'Payment', 'Receipt', 'Journal', 'Sales', 'Purchase'

  late String narration;
  late double amount;

  @Index()
  late String? linkedId; // References other entities like SaleId, PurchaseId

  @Index()
  late String? partyName; // Denormalized for display

  @Index()
  late String? voucherNumber;

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
  String status = 'active';
  String? cancelReason;
  DateTime? cancelledAt;
  String? voucherType;
  String? sourceModule;
  String? sourceId;
  String? sourceNumber;
  String? financialYearId;
  String? partyId;
  String? createdBy;
  String? createdByName;
  DateTime? createdAt;
  String? reversalOfVoucherId;
  String? reversalReason;
  double totalDebit = 0;
  double totalCredit = 0;
  bool isBalanced = true;
  int entryCount = 0;

  @override
  @ignore
  Id get isarId => fastHash(id);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isarId': isarId,
      'transactionRefId': transactionRefId,
      'date': date.toIso8601String(),
      'type': type,
      'transactionType': type,
      'narration': narration,
      'amount': amount,
      'linkedId': linkedId,
      'partyName': partyName,
      'voucherNumber': voucherNumber,
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
      'status': status,
      'cancelReason': cancelReason,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'voucherType': voucherType,
      'sourceModule': sourceModule,
      'sourceId': sourceId,
      'sourceNumber': sourceNumber,
      'financialYearId': financialYearId,
      'partyId': partyId,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt?.toIso8601String(),
      'reversalOfVoucherId': reversalOfVoucherId,
      'reversalReason': reversalReason,
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
      'isBalanced': isBalanced,
      'entryCount': entryCount,
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

  static VoucherEntity fromJson(Map<String, dynamic> json) {
    return VoucherEntity()
      ..id = parseString(json['id'])
      ..transactionRefId = parseString(json['transactionRefId'])
      ..date = parseDate(json['date'])
      ..type = parseString(
        json['type'] ?? json['transactionType'],
        fallback: 'journal',
      )
      ..narration = parseString(json['narration'])
      ..amount = parseDouble(json['amount'])
      ..linkedId = json['linkedId']?.toString()
      ..partyName = json['partyName']?.toString()
      ..voucherNumber = json['voucherNumber']?.toString()
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
      ..status = parseString(json['status'], fallback: 'active')
      ..cancelReason = json['cancelReason']?.toString()
      ..cancelledAt = parseDateOrNull(json['cancelledAt'])
      ..voucherType = json['voucherType']?.toString()
      ..sourceModule = json['sourceModule']?.toString()
      ..sourceId = json['sourceId']?.toString()
      ..sourceNumber = json['sourceNumber']?.toString()
      ..financialYearId = json['financialYearId']?.toString()
      ..partyId = json['partyId']?.toString()
      ..createdBy = json['createdBy']?.toString()
      ..createdByName = json['createdByName']?.toString()
      ..createdAt = parseDateOrNull(json['createdAt'])
      ..reversalOfVoucherId = json['reversalOfVoucherId']?.toString()
      ..reversalReason = json['reversalReason']?.toString()
      ..totalDebit = parseDouble(json['totalDebit'])
      ..totalCredit = parseDouble(json['totalCredit'])
      ..isBalanced = json['isBalanced'] != false
      ..entryCount = parseInt(json['entryCount'])
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
