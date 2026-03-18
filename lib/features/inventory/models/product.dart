import 'package:isar/isar.dart';

part 'product.g.dart';

/// Offline-first inventory product persisted in Isar.
@Collection()
class Product {
  Product();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String firebaseId = '';

  @Index()
  late String name;

  @Index(unique: true, replace: false)
  late String sku;

  late double price;
  late int stockQuantity;
  late String category;
  bool isSynced = false;
  bool isDeleted = false;
  DateTime lastModified = DateTime.now();
  DateTime? lastSynced;
  int version = 1;
  String deviceId = '';

  /// Returns a copy with updated values.
  Product copyWith({
    Id? id,
    String? firebaseId,
    String? name,
    String? sku,
    double? price,
    int? stockQuantity,
    String? category,
    bool? isSynced,
    bool? isDeleted,
    DateTime? lastModified,
    DateTime? lastSynced,
    int? version,
    String? deviceId,
  }) {
    return Product()
      ..id = id ?? this.id
      ..firebaseId = firebaseId ?? this.firebaseId
      ..name = name ?? this.name
      ..sku = sku ?? this.sku
      ..price = price ?? this.price
      ..stockQuantity = stockQuantity ?? this.stockQuantity
      ..category = category ?? this.category
      ..isSynced = isSynced ?? this.isSynced
      ..isDeleted = isDeleted ?? this.isDeleted
      ..lastModified = lastModified ?? this.lastModified
      ..lastSynced = lastSynced ?? this.lastSynced
      ..version = version ?? this.version
      ..deviceId = deviceId ?? this.deviceId;
  }

  /// Converts the product to a Firestore-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firebaseId': firebaseId,
      'name': name,
      'sku': sku,
      'price': price,
      'stockQuantity': stockQuantity,
      'category': category,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastModified': lastModified.toIso8601String(),
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  /// Creates a product from a json map.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product()
      ..firebaseId = json['firebaseId']?.toString() ?? ''
      ..name = json['name']?.toString() ?? ''
      ..sku = json['sku']?.toString() ?? ''
      ..price = (json['price'] as num? ?? 0).toDouble()
      ..stockQuantity = (json['stockQuantity'] as num? ?? 0).toInt()
      ..category = json['category']?.toString() ?? ''
      ..isSynced = json['isSynced'] == true
      ..isDeleted = json['isDeleted'] == true
      ..lastModified =
          DateTime.tryParse(json['lastModified']?.toString() ?? '') ??
          DateTime.now()
      ..lastSynced = DateTime.tryParse(json['lastSynced']?.toString() ?? '')
      ..version = (json['version'] as num? ?? 1).toInt()
      ..deviceId = json['deviceId']?.toString() ?? '';
  }
}
