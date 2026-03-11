import 'offline_first_service.dart';

const suppliersCollection = 'suppliers';

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
  final String status; // 'active' or 'inactive'
  final String type; // 'supplier' or 'vendor'
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
  SuppliersService(super.firebase);

  @override
  String get localStorageKey => 'local_suppliers';

  Future<List<Supplier>> getSuppliers({
    String? status,
    String? type,
    int? limitCount,
  }) async {
    try {
      // 1. ALWAYS read from local storage first
      var items = await loadFromLocal();

      // 2. If local is empty, try to bootstrap from Firebase ONCE
      if (items.isEmpty) {
        final firestore = db;
        if (firestore != null) {
          try {
            final snapshot = await firestore
                .collection(suppliersCollection)
                .orderBy('name')
                .get()
                .timeout(const Duration(seconds: 3));
            items = snapshot.docs
                .map((doc) => {...doc.data(), 'id': doc.id})
                .toList();

            if (items.isNotEmpty) {
              await saveToLocal(items);
            }
          } catch (_) {
            // Firebase failed, but that's okay
          }
        }
      }

      // 3. Apply filters in memory
      var filteredItems = items;

      if (status != null) {
        filteredItems = filteredItems
            .where((item) => item['status'] == status)
            .toList();
      }

      if (type != null) {
        filteredItems = filteredItems
            .where(
              (item) => (item['type'] ?? 'supplier') == type,
            ) // Handle legacy data
            .toList();
      }

      // 4. Apply limit
      if (limitCount != null && filteredItems.length > limitCount) {
        filteredItems = filteredItems.take(limitCount).toList();
      }

      // 5. Convert to Supplier objects
      return filteredItems.map((item) => Supplier.fromJson(item)).toList();
    } catch (e) {
      handleError(e, 'getSuppliers');
      rethrow;
    }
  }

  Future<Supplier?> getSupplierById(String id) async {
    try {
      final firestore = db;
      if (firestore == null) return null;

      final docRef = firestore.collection(suppliersCollection).doc(id);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = Map<String, dynamic>.from(docSnap.data() as Map);
        data['id'] = docSnap.id;
        return Supplier.fromJson(data);
      }
      return null;
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
      // 1. Generate ID and prepare data
      final supplierId = generateId();
      final now = getCurrentTimestamp();

      final supplierData = {
        'id': supplierId,
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
        'createdAt': now,
        'lastUpdatedAt': now,
      };

      // 2. MANDATORY: Save to local storage FIRST
      await addToLocal(supplierData);

      // 3. Queue for durable Firebase sync
      await syncToFirebase(
        'set',
        supplierData,
        collectionName: suppliersCollection,
        syncImmediately: false,
      );

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
      final now = getCurrentTimestamp();
      final updates = <String, dynamic>{
        'id': id,
        'lastUpdatedAt': now,
        'updatedAt': now,
      };

      if (name != null) updates['name'] = name;
      if (contactPerson != null) updates['contactPerson'] = contactPerson;
      if (mobile != null) updates['mobile'] = mobile;
      if (email != null) updates['email'] = email;
      if (address != null) updates['address'] = address;
      if (addressLine2 != null) updates['addressLine2'] = addressLine2;
      if (city != null) updates['city'] = city;
      if (state != null) updates['state'] = state;
      if (pincode != null) updates['pincode'] = pincode;
      if (gstin != null) updates['gstin'] = gstin;
      if (pan != null) updates['pan'] = pan;
      if (paymentTerms != null) updates['paymentTerms'] = paymentTerms;
      if (status != null) updates['status'] = status;
      if (type != null) updates['type'] = type;

      await updateInLocal(id, updates);
      await syncToFirebase(
        'update',
        updates,
        collectionName: suppliersCollection,
        syncImmediately: false,
      );
      return true;
    } catch (e) {
      handleError(e, 'updateSupplier');
      rethrow;
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      // Soft delete by setting status to inactive
      final updates = <String, dynamic>{
        'id': id,
        'status': 'inactive',
        'lastUpdatedAt': getCurrentTimestamp(),
        'updatedAt': getCurrentTimestamp(),
      };
      await updateInLocal(id, updates);
      await syncToFirebase(
        'update',
        updates,
        collectionName: suppliersCollection,
        syncImmediately: false,
      );
      return true;
    } catch (e) {
      handleError(e, 'deleteSupplier');
      rethrow;
    }
  }
}
