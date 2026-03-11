import 'package:isar/isar.dart';
import '../base_entity.dart';

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
}
