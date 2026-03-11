import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'payment_entity.g.dart';

@collection
class PaymentEntity extends BaseEntity {
  @Index()
  late String customerId;

  String? customerName;

  @Index()
  String? saleId;

  late double amount;

  @Index()
  late String mode; // cash, cheque, transfer, online

  late String date;

  String? reference;

  String? notes;

  @Index()
  late String collectorId;

  String? collectorName;

  String? createdAt;
}
