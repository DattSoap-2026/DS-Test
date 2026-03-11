class Customer {
  final String id;
  final String shopName;
  final String ownerName;
  final String mobile;
  final String? alternateMobile;
  final String? email;
  final String address;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstin;
  final String? pan;
  final String route;
  final String? salesRoute; // Decoupled Sales Route
  final int? routeSequence;
  final String status; // 'active' or 'inactive'
  final double balance;
  final double? creditLimit;
  final String? paymentTerms;
  final String createdAt;
  final String? createdBy;
  final String? createdByName;
  final String? updatedAt;
  final double? latitude;
  final double? longitude;

  Customer({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.mobile,
    this.alternateMobile,
    this.email,
    required this.address,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.gstin,
    this.pan,
    required this.route,
    this.salesRoute,
    this.routeSequence,
    required this.status,
    required this.balance,
    this.creditLimit,
    this.paymentTerms,
    required this.createdAt,
    this.createdBy,
    this.createdByName,
    this.updatedAt,
    this.latitude,
    this.longitude,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      shopName: json['shopName'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      alternateMobile: json['alternateMobile'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      gstin: json['gstin'] as String?,
      pan: json['pan'] as String?,
      route: json['route'] as String? ?? '',
      salesRoute:
          json['salesRoute'] as String? ?? json['route'] as String? ?? '',
      routeSequence: json['routeSequence'] as int?,
      status: json['status'] as String? ?? 'active',
      balance: (json['balance'] ?? 0).toDouble(),
      creditLimit: json['creditLimit'] != null
          ? (json['creditLimit'] as num).toDouble()
          : null,
      paymentTerms: json['paymentTerms'] as String?,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      updatedAt: json['updatedAt'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'ownerName': ownerName,
      'mobile': mobile,
      if (alternateMobile != null) 'alternateMobile': alternateMobile,
      if (email != null) 'email': email,
      'address': address,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      'route': route,
      'salesRoute': salesRoute ?? route,
      if (routeSequence != null) 'routeSequence': routeSequence,
      'status': status,
      'balance': balance,
      if (creditLimit != null) 'creditLimit': creditLimit,
      if (paymentTerms != null) 'paymentTerms': paymentTerms,
      'createdAt': createdAt,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdByName != null) 'createdByName': createdByName,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
