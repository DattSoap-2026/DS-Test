import 'package:isar/isar.dart';

import '../base_entity.dart';

part 'stock_balance_entity.g.dart';

@Collection()
class StockBalanceEntity extends BaseEntity {
  static String composeId(String locationId, String productId) {
    return '${locationId.trim()}_${productId.trim()}';
  }

  @Index()
  late String locationId;

  @Index()
  late String productId;

  double quantity = 0.0;
}
