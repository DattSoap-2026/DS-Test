import 'package:isar/isar.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/sale_entity.dart';
import '../../data/local/entities/sync_queue_entity.dart';
import '../../services/database_service.dart';
import '../../services/outbox_codec.dart';

class SalesLocalProvider {
  final DatabaseService _dbService;
  static const String salesCollection = 'sales';
  static const int _salesPageSize = 500;

  SalesLocalProvider(this._dbService);

  Future<List<SaleEntity>> fetchAllSalesPaged() async {
    final allSales = <SaleEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.sales
          .where()
          .offset(offset)
          .limit(_salesPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      allSales.addAll(chunk);
      if (chunk.length < _salesPageSize) {
        break;
      }
      offset += _salesPageSize;
    }
    return allSales;
  }

  Future<SaleEntity?> getSaleById(String id) async {
    return _dbService.sales.filter().idEqualTo(id).findFirst();
  }

  Future<void> saveSale(SaleEntity entity) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.sales.put(entity);
    });
  }

  Future<void> saveSales(List<SaleEntity> entities) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.sales.putAll(entities);
    });
  }

  Future<void> deleteSale(int isarId) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.sales.delete(isarId);
    });
  }

  Future<String> enqueueSaleForSync(
    Map<String, dynamic> saleData, {
    String action = 'add',
  }) async {
    final saleId = saleData['id']?.toString();
    if (saleId == null || saleId.isEmpty) return '';

    final queueId = 'sales_$saleId';
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = salesCollection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: saleData,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(entity);
    });
    return queueId;
  }

  Future<void> dequeueSaleForSync(String queueId) async {
    if (queueId.isEmpty) return;
    final existing = await _dbService.syncQueue.getById(queueId);
    if (existing == null) return;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.delete(existing.isarId);
    });
  }

  Future<List<SyncQueueEntity>> getPendingSalesSyncQueue() async {
    return _dbService.syncQueue
        .filter()
        .collectionEqualTo(salesCollection)
        .findAll();
  }
}
