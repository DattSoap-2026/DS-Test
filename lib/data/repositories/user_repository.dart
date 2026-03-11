import 'package:isar/isar.dart';
import '../local/base_entity.dart';
import '../local/entities/user_entity.dart';
import '../../services/database_service.dart';

class UserRepository {
  final DatabaseService _dbService;

  UserRepository(this._dbService);

  // Fetch all users (for Admin) - Local First
  Future<List<UserEntity>> getAllUsers() async {
    return await _dbService.users.where().findAll();
  }

  // Create new user - Local First
  Future<void> createUser(UserEntity user) async {
    user.updatedAt = DateTime.now();
    user.syncStatus = SyncStatus.pending; // Mark for sync

    await _dbService.db.writeTxn(() async {
      await _dbService.users.put(user);
    });
  }

  // Get specific user - Local First
  Future<UserEntity?> getUserById(String id) async {
    return await _dbService.users.filter().idEqualTo(id).findFirst();
  }

  // Update user - Local Commit
  Future<void> updateUser(UserEntity user) async {
    user.updatedAt = DateTime.now();
    user.syncStatus = SyncStatus.pending; // Mark for sync

    await _dbService.db.writeTxn(() async {
      await _dbService.users.put(user);
    });
  }

  // Soft Delete user
  Future<void> deleteUser(String id) async {
    await _dbService.db.writeTxn(() async {
      final user = await _dbService.users.filter().idEqualTo(id).findFirst();
      if (user != null) {
        user.isDeleted = true;
        user.updatedAt = DateTime.now();
        user.syncStatus = SyncStatus.pending;
        await _dbService.users.put(user);
      }
    });
  }

  // Delete all users locally EXCEPT the current admin
  Future<int> deleteAllUsersExcept(String currentUserId) async {
    return await _dbService.db.writeTxn(() async {
      return await _dbService.users
          .filter()
          .not()
          .idEqualTo(currentUserId)
          .deleteAll();
    });
  }
}
