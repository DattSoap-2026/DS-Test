import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/customers_service.dart';
import '../../../services/field_encryption_service.dart';

part 'customer_entity.g.dart';

@Collection()
class CustomerEntity extends BaseEntity {
  // Core identification
  @Index()
  late String shopName;

  late String ownerName;

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
  late String route;

  int? routeSequence;

  @Index()
  late String status; // 'active' or 'inactive'

  double balance = 0.0;
  double? creditLimit;
  String? paymentTerms;

  // Geolocation
  double? latitude;
  double? longitude;

  // Audit fields
  late String createdAt;
  String? createdBy;
  String? createdByName;

  // Convert to domain model (Customer from CustomersService)
  Customer toDomain() {
    final fieldEncryption = FieldEncryptionService.instance;
    final mobile = fieldEncryption.decryptString(
      this.mobile,
      _ctx(id, 'mobile'),
    );
    final alternateMobile = this.alternateMobile == null
        ? null
        : fieldEncryption.decryptString(
            this.alternateMobile!,
            _ctx(id, 'altMobile'),
          );
    final email = this.email == null
        ? null
        : fieldEncryption.decryptString(
            this.email!,
            _ctx(id, 'email'),
          );
    final address = fieldEncryption.decryptString(
      this.address,
      _ctx(id, 'address'),
    );
    final addressLine2 = this.addressLine2 == null
        ? null
        : fieldEncryption.decryptString(
            this.addressLine2!,
            _ctx(id, 'address2'),
          );
    final city = this.city == null
        ? null
        : fieldEncryption.decryptString(
            this.city!,
            _ctx(id, 'city'),
          );
    final state = this.state == null
        ? null
        : fieldEncryption.decryptString(
            this.state!,
            _ctx(id, 'state'),
          );
    final pincode = this.pincode == null
        ? null
        : fieldEncryption.decryptString(
            this.pincode!,
            _ctx(id, 'pincode'),
          );
    final gstin = this.gstin == null
        ? null
        : fieldEncryption.decryptString(
            this.gstin!,
            _ctx(id, 'gstin'),
          );
    final pan = this.pan == null
        ? null
        : fieldEncryption.decryptString(
            this.pan!,
            _ctx(id, 'pan'),
          );

    return Customer(
      id: id,
      shopName: shopName,
      ownerName: ownerName,
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
      route: route,
      routeSequence: routeSequence,
      status: status,
      balance: balance,
      creditLimit: creditLimit,
      paymentTerms: paymentTerms,
      createdAt: createdAt,
      createdBy: createdBy,
      createdByName: createdByName,
      updatedAt: updatedAt.toIso8601String(),
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Create from domain model
  static CustomerEntity fromDomain(Customer customer) {
    final fieldEncryption = FieldEncryptionService.instance;
    return CustomerEntity()
      ..id = customer.id
      ..shopName = customer.shopName
      ..ownerName = customer.ownerName
      ..mobile = fieldEncryption.encryptString(
        customer.mobile,
        _ctx(customer.id, 'mobile'),
      )
      ..alternateMobile = customer.alternateMobile == null
          ? null
          : fieldEncryption.encryptString(
              customer.alternateMobile!,
              _ctx(customer.id, 'altMobile'),
            )
      ..email = customer.email == null
          ? null
          : fieldEncryption.encryptString(
              customer.email!,
              _ctx(customer.id, 'email'),
            )
      ..address = fieldEncryption.encryptString(
        customer.address,
        _ctx(customer.id, 'address'),
      )
      ..addressLine2 = customer.addressLine2 == null
          ? null
          : fieldEncryption.encryptString(
              customer.addressLine2!,
              _ctx(customer.id, 'address2'),
            )
      ..city = customer.city == null
          ? null
          : fieldEncryption.encryptString(
              customer.city!,
              _ctx(customer.id, 'city'),
            )
      ..state = customer.state == null
          ? null
          : fieldEncryption.encryptString(
              customer.state!,
              _ctx(customer.id, 'state'),
            )
      ..pincode = customer.pincode == null
          ? null
          : fieldEncryption.encryptString(
              customer.pincode!,
              _ctx(customer.id, 'pincode'),
            )
      ..gstin = customer.gstin == null
          ? null
          : fieldEncryption.encryptString(
              customer.gstin!,
              _ctx(customer.id, 'gstin'),
            )
      ..pan = customer.pan == null
          ? null
          : fieldEncryption.encryptString(
              customer.pan!,
              _ctx(customer.id, 'pan'),
            )
      ..route = customer.route
      ..routeSequence = customer.routeSequence
      ..status = customer.status
      ..balance = customer.balance
      ..creditLimit = customer.creditLimit
      ..paymentTerms = customer.paymentTerms
      ..createdAt = customer.createdAt
      ..createdBy = customer.createdBy
      ..createdByName = customer.createdByName
      ..updatedAt = customer.updatedAt != null
          ? DateTime.parse(customer.updatedAt!)
          : DateTime.now()
      ..latitude = customer.latitude
      ..longitude = customer.longitude
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }

  void encryptSensitiveFields() {
    final fieldEncryption = FieldEncryptionService.instance;
    if (!fieldEncryption.isEnabled) return;

    mobile = fieldEncryption.encryptString(mobile, _ctx(id, 'mobile'));
    if (alternateMobile != null) {
      alternateMobile = fieldEncryption.encryptString(
        alternateMobile!,
        _ctx(id, 'altMobile'),
      );
    }
    if (email != null) {
      email = fieldEncryption.encryptString(email!, _ctx(id, 'email'));
    }
    address = fieldEncryption.encryptString(address, _ctx(id, 'address'));
    if (addressLine2 != null) {
      addressLine2 = fieldEncryption.encryptString(
        addressLine2!,
        _ctx(id, 'address2'),
      );
    }
    if (city != null) {
      city = fieldEncryption.encryptString(city!, _ctx(id, 'city'));
    }
    if (state != null) {
      state = fieldEncryption.encryptString(state!, _ctx(id, 'state'));
    }
    if (pincode != null) {
      pincode = fieldEncryption.encryptString(pincode!, _ctx(id, 'pincode'));
    }
    if (gstin != null) {
      gstin = fieldEncryption.encryptString(gstin!, _ctx(id, 'gstin'));
    }
    if (pan != null) {
      pan = fieldEncryption.encryptString(pan!, _ctx(id, 'pan'));
    }
  }

  static String _ctx(String id, String field) => 'customer:$id:$field';
}
