import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'tyre_stock_entity.g.dart';

@Collection()
class TyreStockEntity extends BaseEntity {
  @Index(type: IndexType.value)
  late String brand;

  late String size;

  @Index()
  late String serialNumber;

  late String type; // New, Remold

  @Index()
  late String status; // In Stock, Mounted, Scrapped

  String? vehicleNumber;
  String? position;
  String? notes;
  double cost = 0.0;

  DateTime? purchaseDate;

  @Index()
  late String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'size': size,
      'serialNumber': serialNumber,
      'type': type,
      'status': status,
      'vehicleNumber': vehicleNumber,
      'position': position,
      'notes': notes,
      'cost': cost,
      'purchaseDate': purchaseDate?.toIso8601String(),
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

  static TyreStockEntity fromJson(Map<String, dynamic> json) {
    return TyreStockEntity()
      ..id = parseString(json['id'])
      ..brand = parseString(json['brand'])
      ..size = parseString(json['size'])
      ..serialNumber = parseString(json['serialNumber'])
      ..type = parseString(json['type'])
      ..status = parseString(json['status'])
      ..vehicleNumber = json['vehicleNumber']?.toString()
      ..position = json['position']?.toString()
      ..notes = json['notes']?.toString()
      ..cost = parseDouble(json['cost'])
      ..purchaseDate = parseDateOrNull(json['purchaseDate'])
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
      ..deviceId = parseString(json['deviceId']);
  }
}
