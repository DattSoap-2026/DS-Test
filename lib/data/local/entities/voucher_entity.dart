import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'voucher_entity.g.dart';

@Collection()
class VoucherEntity extends BaseEntity {
  @Index(unique: true)
  late String transactionRefId; // readable ID e.g. VCH-2024-001

  @Index()
  late DateTime date;

  @Index()
  late String type; // 'Inventory', 'Payment', 'Receipt', 'Journal', 'Sales', 'Purchase'

  late String narration;
  late double amount;

  @Index()
  late String? linkedId; // References other entities like SaleId, PurchaseId

  @Index()
  late String? partyName; // Denormalized for display

  @Index()
  late String? voucherNumber;

  @Index()
  String? route;

  @Index()
  String? district;

  @Index()
  String? division;

  @Index()
  String? salesmanId;

  String? salesmanName;
  String? saleDate;

  @Index()
  String? dealerId;

  String? dealerName;

  String? accountingDimensionsJson;
  int? dimensionVersion;

  @override
  @ignore
  Id get isarId => fastHash(id);
}
