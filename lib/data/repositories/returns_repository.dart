import 'package:isar/isar.dart';
import '../local/entities/return_entity.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';

class ReturnsRepository {
  final DatabaseService _dbService;

  ReturnsRepository(this._dbService);

  // Save (Create/Update) Return Request
  Future<void> saveReturnRequest(ReturnEntity request) async {
    request.updatedAt = DateTime.now();
    request.syncStatus = SyncStatus.pending; // Mark for sync

    await _dbService.db.writeTxn(() async {
      await _dbService.returns.put(request);
    });
  }

  // Get Pending Returns (for Sync)
  Future<List<ReturnEntity>> getPendingReturns() async {
    return await _dbService.returns
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  // Get All Returns (for UI - Salesman History)
  Future<List<ReturnEntity>> getReturns({String? salesmanId}) async {
    // For now, simple fetch all or filtered by salesman
    if (salesmanId != null) {
      return await _dbService.returns
          .filter()
          .salesmanIdEqualTo(salesmanId)
          .findAll();
    }
    return await _dbService.returns.where().findAll();
  }
}
