import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'account_entity.g.dart';

@Collection()
class AccountEntity extends BaseEntity {
  @Index(unique: true)
  late String code;

  @Index(caseSensitive: false)
  late String name;

  @Index()
  late String group; // e.g., 'Assets', 'Liabilities', 'Expenses', 'Income'

  String parentAccount = ''; // For hierarchy if needed

  bool isSystem = false; // System accounts cannot be deleted/renamed
  bool isActive = true;

  double currentBalance = 0.0; // Cached balance for quick display

  @override
  @ignore
  Id get isarId => fastHash(id);
}
