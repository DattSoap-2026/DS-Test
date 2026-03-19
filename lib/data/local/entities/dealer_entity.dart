import 'package:isar/isar.dart';
import '../../../services/dealers_service.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'dealer_entity.g.dart';

@Collection()
class DealerEntity extends BaseEntity {
  // Core identification
  @Index()
  late String name;

  late String contactPerson;

  @Index()
  late String mobile;

  String? alternateMobile;
  String? email;

  // Address information
  late String address;
  String? addressLine2;
  String? city;
  String? state;
  String? pincode;

  // Tax information
  String? gstin;
  String? pan;

  // Business information
  @Index()
  String? status; // 'active' or 'inactive'

  double? commissionPercentage;
  String? paymentTerms;
  String? territory;
  @Index(type: IndexType.hash)
  String? assignedRouteId;
  @Index()
  String? assignedRouteName;

  // Geolocation
  double? latitude;
  double? longitude;

  // Audit fields
  late String createdAt;

  // Convert to domain model (Dealer from DealersService)
  Dealer toDomain() {
    return Dealer(
      id: id,
      name: name,
      contactPerson: contactPerson,
      mobile: mobile,
      alternateMobile: alternateMobile,
      email: email,
      address: address,
      addressLine2: addressLine2,
      city: city,
      state: state,
      pincode: pincode,
      gstin: gstin,
      pan: pan,
      status: status,
      commissionPercentage: commissionPercentage,
      paymentTerms: paymentTerms,
      territory: territory,
      assignedRouteId: assignedRouteId,
      assignedRouteName: assignedRouteName,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      updatedAt: updatedAt.toIso8601String(),
    );
  }

  // Create from domain model
  static DealerEntity fromDomain(Dealer dealer) {
    return DealerEntity()
      ..id = dealer.id
      ..name = dealer.name
      ..contactPerson = dealer.contactPerson
      ..mobile = dealer.mobile
      ..alternateMobile = dealer.alternateMobile
      ..email = dealer.email
      ..address = dealer.address
      ..addressLine2 = dealer.addressLine2
      ..city = dealer.city
      ..state = dealer.state
      ..pincode = dealer.pincode
      ..gstin = dealer.gstin
      ..pan = dealer.pan
      ..status = dealer.status
      ..commissionPercentage = dealer.commissionPercentage
      ..paymentTerms = dealer.paymentTerms
      ..territory = dealer.territory
      ..assignedRouteId = dealer.assignedRouteId
      ..assignedRouteName = dealer.assignedRouteName
      ..latitude = dealer.latitude
      ..longitude = dealer.longitude
      ..createdAt = dealer.createdAt
      ..updatedAt = dealer.updatedAt != null
          ? DateTime.parse(dealer.updatedAt!)
          : DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
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
      'commissionPercentage': commissionPercentage,
      'paymentTerms': paymentTerms,
      'territory': territory,
      'assignedRouteId': assignedRouteId,
      'assignedRouteName': assignedRouteName,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
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

  /// Builds an entity from a sync-safe json map.
  static DealerEntity fromJson(Map<String, dynamic> json) {
    return DealerEntity()
      ..id = parseString(json['id'])
      ..name = parseString(json['name'])
      ..contactPerson = parseString(json['contactPerson'])
      ..mobile = parseString(json['mobile'])
      ..alternateMobile = json['alternateMobile']?.toString()
      ..email = json['email']?.toString()
      ..address = parseString(json['address'])
      ..addressLine2 = json['addressLine2']?.toString()
      ..city = json['city']?.toString()
      ..state = json['state']?.toString()
      ..pincode = json['pincode']?.toString()
      ..gstin = json['gstin']?.toString()
      ..pan = json['pan']?.toString()
      ..status = json['status']?.toString()
      ..commissionPercentage = json['commissionPercentage'] == null
          ? null
          : parseDouble(json['commissionPercentage'])
      ..paymentTerms = json['paymentTerms']?.toString()
      ..territory = json['territory']?.toString()
      ..assignedRouteId = json['assignedRouteId']?.toString()
      ..assignedRouteName = json['assignedRouteName']?.toString()
      ..latitude =
          json['latitude'] == null ? null : parseDouble(json['latitude'])
      ..longitude =
          json['longitude'] == null ? null : parseDouble(json['longitude'])
      ..createdAt = parseString(
        json['createdAt'],
        fallback: DateTime.now().toIso8601String(),
      )
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');
  }
}
