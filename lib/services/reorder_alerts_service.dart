import 'package:isar/isar.dart';

import 'base_service.dart';
import 'database_service.dart';

class ReorderAlertsService extends BaseService {
  final DatabaseService _dbService;

  ReorderAlertsService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Future<int> getReorderAlertsCount() async {
    try {
      final products = await _dbService.products.where().findAll();
      if (products.isEmpty) return 0;

      int count = 0;
      for (final product in products) {
        if (product.status != null && product.status != 'active') continue;
        final reorderLevel = (product.reorderLevel ?? 0).toDouble();
        if (reorderLevel <= 0) continue;
        final currentStock = (product.stock ?? 0).toDouble();
        if (currentStock <= reorderLevel) {
          count++;
        }
      }
      return count;
    } catch (e) {
      handleError(e, 'getReorderAlertsCount');
      return 0;
    }
  }
}
