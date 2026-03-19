import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'supplier_entity.g.dart';

@Collection()
class SupplierEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  String get firebaseId => id;
  set firebaseId(String value) => id = value;

  @Index()
  late String name;

  String? contactPerson;
  String? mobile;
  String? alternateMobile;
  String? email;
  String? address;
  String? addressLine2;
  String? city;
  String? state;
  String? pincode;
  String? gstin;
  String? pan;

  @Index()
  String status = 'active';

  String? paymentTerms;
  String? bankDetails;
  String? notes;
  DateTime? createdAt;
  String? createdBy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'name': name,
      'contactPerson': contactPerson,
      'mobile': mobile,
      'alternateMobile': alternateMobile,
      'email': email,
      'address': address,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'gstin': gstin,
      'pan': pan,
      'status': status,
      'paymentTerms': paymentTerms,
      'bankDetails': bankDetails,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'createdBy': createdBy,
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

  static SupplierEntity fromJson(Map<String, dynamic> json) {
    return SupplierEntity()
      ..id = parseString(json['id'])
      ..name = parseString(json['name'])
      ..contactPerson = json['contactPerson']?.toString()
      ..mobile = json['mobile']?.toString()
      ..alternateMobile = json['alternateMobile']?.toString()
      ..email = json['email']?.toString()
      ..address = json['address']?.toString()
      ..addressLine2 = json['addressLine2']?.toString()
      ..city = json['city']?.toString()
      ..state = json['state']?.toString()
      ..pincode = json['pincode']?.toString()
      ..gstin = json['gstin']?.toString()
      ..pan = json['pan']?.toString()
      ..status = parseString(json['status'], fallback: 'active')
      ..paymentTerms = json['paymentTerms']?.toString()
      ..bankDetails = json['bankDetails']?.toString()
      ..notes = json['notes']?.toString()
      ..createdAt = parseDateOrNull(json['createdAt'])
      ..createdBy = json['createdBy']?.toString()
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
