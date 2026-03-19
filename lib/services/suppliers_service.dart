import '../data/local/entities/supplier_entity.dart';
import '../data/repositories/procurement_repository.dart';
import 'database_service.dart';
import 'offline_first_service.dart';

class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String mobile;
  final String? email;
  final String address;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstin;
  final String? pan;
  final String? paymentTerms;
  final String status;
  final String type;
  final String createdAt;
  final String? updatedAt;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.mobile,
    this.email,
    required this.address,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.gstin,
    this.pan,
    this.paymentTerms,
    required this.status,
    this.type = 'supplier',
    required this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      contactPerson: json['contactPerson'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      gstin: json['gstin'] as String?,
      pan: json['pan'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      status: json['status'] as String? ?? 'active',
      type: json['type'] as String? ?? 'supplier',
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'mobile': mobile,
      if (email != null) 'email': email,
      'address': address,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      if (paymentTerms != null) 'paymentTerms': paymentTerms,
      'status': status,
      'type': type,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}

class SuppliersService extends OfflineFirstService {
  SuppliersService(super.firebase)
    : _procurementRepository = ProcurementRepository(DatabaseService.instance);

  final ProcurementRepository _procurementRepository;

  @override
  String get localStorageKey => 'local_suppliers';

  Future<List<Supplier>> getSuppliers({
    String? status,
    String? type,
    int? limitCount,
  }) async {
    try {
      var suppliers = (await _procurementRepository.getAllSuppliers())
          .map(_toDomain)
          .toList(growable: false);

      if (status != null && status.trim().isNotEmpty) {
        suppliers = suppliers
            .where((supplier) => supplier.status == status)
            .toList(growable: false);
      }

      if (type != null && type.trim().isNotEmpty && type != 'supplier') {
        suppliers = const <Supplier>[];
      }

      if (limitCount != null && suppliers.length > limitCount) {
        suppliers = suppliers.take(limitCount).toList(growable: false);
      }

      return suppliers;
    } catch (e) {
      handleError(e, 'getSuppliers');
      rethrow;
    }
  }

  Future<Supplier?> getSupplierById(String id) async {
    try {
      final entity = await _procurementRepository.getSupplierById(id);
      return entity == null ? null : _toDomain(entity);
    } catch (e) {
      handleError(e, 'getSupplierById');
      rethrow;
    }
  }

  Future<bool> addSupplier({
    required String name,
    required String contactPerson,
    required String mobile,
    String? email,
    required String address,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? pan,
    String? paymentTerms,
    String status = 'active',
    String type = 'supplier',
  }) async {
    try {
      final now = DateTime.now();
      final supplier = SupplierEntity()
        ..id = generateId()
        ..name = name
        ..contactPerson = contactPerson
        ..mobile = mobile
        ..email = email
        ..address = address
        ..addressLine2 = addressLine2
        ..city = city
        ..state = state
        ..pincode = pincode
        ..gstin = gstin
        ..pan = pan
        ..status = status
        ..paymentTerms = paymentTerms
        ..createdAt = now;

      await _procurementRepository.saveSupplier(supplier);
      return true;
    } catch (e) {
      handleError(e, 'addSupplier');
      rethrow;
    }
  }

  Future<bool> updateSupplier({
    required String id,
    String? name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? pan,
    String? paymentTerms,
    String? status,
    String? type,
  }) async {
    try {
      final existing = await _procurementRepository.getSupplierById(id);
      if (existing == null) {
        return false;
      }

      existing
        ..name = name ?? existing.name
        ..contactPerson = contactPerson ?? existing.contactPerson
        ..mobile = mobile ?? existing.mobile
        ..email = email ?? existing.email
        ..address = address ?? existing.address
        ..addressLine2 = addressLine2 ?? existing.addressLine2
        ..city = city ?? existing.city
        ..state = state ?? existing.state
        ..pincode = pincode ?? existing.pincode
        ..gstin = gstin ?? existing.gstin
        ..pan = pan ?? existing.pan
        ..paymentTerms = paymentTerms ?? existing.paymentTerms
        ..status = status ?? existing.status;

      await _procurementRepository.saveSupplier(existing);
      return true;
    } catch (e) {
      handleError(e, 'updateSupplier');
      rethrow;
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      await _procurementRepository.deleteSupplier(id);
      return true;
    } catch (e) {
      handleError(e, 'deleteSupplier');
      rethrow;
    }
  }

  Supplier _toDomain(SupplierEntity entity) {
    return Supplier(
      id: entity.id,
      name: entity.name,
      contactPerson: entity.contactPerson ?? '',
      mobile: entity.mobile ?? '',
      email: entity.email,
      address: entity.address ?? '',
      addressLine2: entity.addressLine2,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      gstin: entity.gstin,
      pan: entity.pan,
      paymentTerms: entity.paymentTerms,
      status: entity.status,
      type: 'supplier',
      createdAt:
          entity.createdAt?.toIso8601String() ?? entity.updatedAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
