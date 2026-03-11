import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'tyre_log_entity.g.dart';

@Collection()
class TyreLogEntity extends BaseEntity {
  @Index()
  late String vehicleId;
  late String vehicleNumber;
  late DateTime installationDate;
  late String reason;

  double totalCost = 0;

  List<TyreLogItemEntity>? items;

  late String createdAt;
}

@Embedded()
class TyreLogItemEntity {
  String? tyrePosition;
  String? newTyreType; // New, Remolded
  String? tyreItemId;
  String? tyreBrand;
  String? tyreModel;
  String? tyreNumber;
  double cost = 0;

  String? oldTyreDisposition;
  String? oldTyreBrand;
  String? oldTyreNumber;
}
