import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/dealers_service.dart';

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
}
