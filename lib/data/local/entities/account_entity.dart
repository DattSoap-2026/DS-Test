import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'account_entity.g.dart';

@Collection()
class AccountEntity extends BaseEntity {
  @Index(unique: true)
  late String code;

  @Index(caseSensitive: false)
  late String name;

  @Index()
  late String group; // e.g., 'Assets', 'Liabilities', 'Expenses', 'Income'

  String parentAccount = ''; // For hierarchy if needed

  bool isSystem = false; // System accounts cannot be deleted/renamed
  bool isActive = true;

  double currentBalance = 0.0; // Cached balance for quick display

  @override
  @ignore
  Id get isarId => fastHash(id);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isarId': isarId,
      'code': code,
      'name': name,
      'group': group,
      'parentAccount': parentAccount,
      'isSystem': isSystem,
      'isActive': isActive,
      'currentBalance': currentBalance,
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

  static AccountEntity fromJson(Map<String, dynamic> json) {
    return AccountEntity()
      ..id = parseString(json['id'])
      ..code = parseString(json['code'])
      ..name = parseString(json['name'])
      ..group = parseString(json['group'], fallback: 'Ungrouped')
      ..parentAccount = parseString(json['parentAccount'])
      ..isSystem = json['isSystem'] == true
      ..isActive = json['isActive'] != false
      ..currentBalance = parseDouble(json['currentBalance'])
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
