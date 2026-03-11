import 'package:isar/isar.dart';
import '../services/database_service.dart';
import '../data/local/entities/cutting_batch_entity.dart';
import '../data/local/entities/production_target_entity.dart';
import '../data/local/base_entity.dart';
import '../utils/app_logger.dart';
import '../utils/unit_scope_utils.dart';

class ProductionStatsService {
  // Use Singleton DatabaseService
  final DatabaseService _dbService = DatabaseService.instance;

  bool _matchesBatchScope(CuttingBatchEntity batch, UserUnitScope? unitScope) {
    if (unitScope == null) return true;
    return matchesUnitScope(
      scope: unitScope,
      tokens: [
        batch.departmentId,
        batch.departmentName,
        batch.semiFinishedProductName,
        batch.finishedGoodName,
      ],
      defaultIfNoScopeTokens: false,
    );
  }

  Future<bool> _matchesTargetScope(
    ProductionTargetEntity target,
    UserUnitScope? unitScope,
  ) async {
    if (unitScope == null) return true;
    final product = await _dbService.products.get(fastHash(target.productId));
    return matchesUnitScope(
      scope: unitScope,
      tokens: [
        product?.departmentId,
        ...(product?.allowedDepartmentIds ?? const <String>[]),
      ],
      defaultIfNoScopeTokens: false,
    );
  }

  // Get specific date range trend data (Offline-First via Isar)
  Future<List<CuttingBatchEntity>> getBatchesForDateRange({
    required DateTime start,
    required DateTime end,
    UserUnitScope? unitScope,
  }) async {
    try {
      final batches = await _dbService.cuttingBatches
          .filter()
          .createdAtBetween(start, end, includeUpper: true)
          .findAll();

      final scopedBatches =
          batches
              .where((batch) => _matchesBatchScope(batch, unitScope))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return scopedBatches;
    } catch (e) {
      AppLogger.error(
        'Failed to get batches for date range',
        error: e,
        tag: 'Stats',
      );
      return [];
    }
  }

  // Get 7-day trend data (Offline-First via Isar)
  Future<List<Map<String, dynamic>>> get7DayTrend({
    UserUnitScope? unitScope,
  }) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Query Isar
      final batches = await _dbService.cuttingBatches
          .filter()
          .createdAtGreaterThan(sevenDaysAgo)
          .findAll();
      final scopedBatches = batches
          .where((batch) => _matchesBatchScope(batch, unitScope))
          .toList();

      // Process data
      final trendMap = <String, Map<String, dynamic>>{};

      for (final batch in scopedBatches) {
        final date = batch.createdAt;
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        if (!trendMap.containsKey(dateKey)) {
          trendMap[dateKey] = {'batches': 0, 'units': 0, 'yield': 0.0};
        }

        final current = trendMap[dateKey]!;
        trendMap[dateKey] = {
          'batches': (current['batches'] as int) + 1,
          'units': (current['units'] as int) + batch.unitsProduced,
          'yield': current['yield'],
        };
      }

      return trendMap.entries
          .map(
            (e) => {
              'date': e.key,
              'batches': e.value['batches'],
              'units': e.value['units'],
              'yield': e.value['yield'],
            },
          )
          .toList()
        ..sort((a, b) => a['date'].compareTo(b['date']));
    } catch (e) {
      AppLogger.error('Failed to get 7-day trend', error: e, tag: 'Stats');
      return [];
    }
  }

  // Get today's production mix
  Future<Map<String, dynamic>> getTodaysMix({UserUnitScope? unitScope}) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final batches = await _dbService.cuttingBatches
          .filter()
          .createdAtBetween(startOfDay, endOfDay, includeUpper: false)
          .findAll();
      final scopedBatches = batches
          .where((batch) => _matchesBatchScope(batch, unitScope))
          .toList();

      int totalUnits = 0;
      final productMix = <String, int>{};

      for (final batch in scopedBatches) {
        final product = batch.finishedGoodName;
        final units = batch.unitsProduced;

        totalUnits += units;
        productMix[product] = (productMix[product] ?? 0) + units;
      }

      return {
        'totalUnits': totalUnits,
        'productMix': productMix,
        'date': dateStr,
      };
    } catch (e) {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return {'totalUnits': 0, 'productMix': <String, int>{}, 'date': dateStr};
    }
  }

  // Get production targets for today
  Future<Map<String, dynamic>> getProductionTargets({
    UserUnitScope? unitScope,
  }) async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Get Target from Isar (ProductionTargetEntity)
      final targetEntities = await _dbService.productionTargets
          .filter()
          .targetDateEqualTo(dateStr)
          .findAll();

      // Calculate Actuals from Batches
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final batches = await _dbService.cuttingBatches
          .filter()
          .createdAtBetween(startOfDay, endOfDay, includeUpper: false)
          .findAll();
      final scopedBatches = batches
          .where((batch) => _matchesBatchScope(batch, unitScope))
          .toList();

      int actualUnits = 0;
      int actualBatches = scopedBatches.length;
      for (final batch in scopedBatches) {
        actualUnits += batch.unitsProduced;
      }

      int targetUnits = 0;
      for (final target in targetEntities) {
        if (await _matchesTargetScope(target, unitScope)) {
          targetUnits += target.targetQuantity;
        }
      }
      // In ProductionTargetEntity, we don't have targetBatches,
      // it seems targetQuantity is the units target.
      // We'll keep targetBatches as 0 or handled elsewhere.
      int targetBatches = 0;

      return {
        'targetUnits': targetUnits,
        'actualUnits': actualUnits,
        'targetBatches': targetBatches,
        'actualBatches': actualBatches,
        'achievementPercent': targetUnits > 0
            ? ((actualUnits / targetUnits) * 100).toInt()
            : 0,
      };
    } catch (e) {
      return {
        'targetUnits': 0,
        'actualUnits': 0,
        'targetBatches': 0,
        'actualBatches': 0,
        'achievementPercent': 0,
      };
    }
  }

  // Get recent production logs
  Future<List<Map<String, dynamic>>> getRecentLogs({
    int limit = 5,
    UserUnitScope? unitScope,
  }) async {
    try {
      final batches = await _dbService.cuttingBatches
          .where()
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
      final scopedBatches = batches
          .where((batch) => _matchesBatchScope(batch, unitScope))
          .toList();

      return scopedBatches
          .map(
            (batch) => {
              'batchNumber': batch.batchNumber,
              'productName': batch.finishedGoodName,
              'unitsProduced': batch.unitsProduced,
              'status': batch.stage, // e.g. 'completed'
              'id': batch.id,
            },
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
