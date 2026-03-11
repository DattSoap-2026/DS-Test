import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'voucher_entry_entity.g.dart';

@Collection()
class VoucherEntryEntity extends BaseEntity {
  @Index()
  late String voucherId;

  @Index()
  late String accountCode;

  double debit = 0;
  double credit = 0;

  String? narration;

  @Index()
  DateTime? date;
  // Line-level narration

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
