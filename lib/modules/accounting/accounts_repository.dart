import 'package:isar/isar.dart';

import '../../core/firebase/firebase_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/account_entity.dart';
import '../../services/database_service.dart';
import '../../services/offline_first_service.dart';
import '../../utils/app_logger.dart';

const String accountsCollection = CollectionRegistry.accounts;

class AccountsRepository extends OfflineFirstService {
  AccountsRepository(
    FirebaseServices firebase, {
    DatabaseService? dbService,
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance,
       super(firebase, dbService);

  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  @override
  String get localStorageKey => 'local_accounts';

  @override
  bool get useIsar => true;

  static const List<Map<String, dynamic>> _defaultChart = [
    {
      'id': 'SALES',
      'code': 'SALES',
      'name': 'Sales Account',
      'group': 'Revenue',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'PURCHASES',
      'code': 'PURCHASES',
      'name': 'Purchase Account',
      'group': 'Expenses',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'SUNDRY_DEBTORS',
      'code': 'SUNDRY_DEBTORS',
      'name': 'Sundry Debtors',
      'group': 'Assets',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'SUNDRY_CREDITORS',
      'code': 'SUNDRY_CREDITORS',
      'name': 'Sundry Creditors',
      'group': 'Liabilities',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'CASH_IN_HAND',
      'code': 'CASH_IN_HAND',
      'name': 'Cash In Hand',
      'group': 'Assets',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'OUTPUT_CGST',
      'code': 'OUTPUT_CGST',
      'name': 'Output CGST',
      'group': 'Liabilities',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'OUTPUT_SGST',
      'code': 'OUTPUT_SGST',
      'name': 'Output SGST',
      'group': 'Liabilities',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'OUTPUT_IGST',
      'code': 'OUTPUT_IGST',
      'name': 'Output IGST',
      'group': 'Liabilities',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'INPUT_CGST',
      'code': 'INPUT_CGST',
      'name': 'Input CGST',
      'group': 'Assets',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'INPUT_SGST',
      'code': 'INPUT_SGST',
      'name': 'Input SGST',
      'group': 'Assets',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'INPUT_IGST',
      'code': 'INPUT_IGST',
      'name': 'Input IGST',
      'group': 'Assets',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'ROUND_OFF',
      'code': 'ROUND_OFF',
      'name': 'Round Off',
      'group': 'Indirect Expenses',
      'isSystem': true,
      'isActive': true,
    },
    {
      'id': 'OPENING_BALANCE',
      'code': 'OPENING_BALANCE',
      'name': 'Opening Balance',
      'group': 'Capital',
      'isSystem': true,
      'isActive': true,
    },
  ];

  Future<void> ensureDefaultAccounts() async {
    try {
      final count = await dbService.accounts.count();
      if (count > 0) {
        return;
      }

      for (final entry in _defaultChart) {
        await upsertAccount(entry);
      }
      AppLogger.info('Initialized default accounts chart', tag: 'Accounting');
    } catch (error) {
      handleError(error, 'ensureDefaultAccounts');
    }
  }

  Future<List<Map<String, dynamic>>> getAccounts({
    bool includeInactive = false,
  }) async {
    try {
      final entities = includeInactive
          ? await dbService.accounts
                .filter()
                .isDeletedEqualTo(false)
                .sortByName()
                .findAll()
          : await dbService.accounts
                .filter()
                .isDeletedEqualTo(false)
                .and()
                .isActiveEqualTo(true)
                .sortByName()
                .findAll();
      return entities.map(_entityToMap).toList(growable: false);
    } catch (error) {
      handleError(error, 'getAccounts');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<AccountEntity?> getAccountById(String id) {
    return dbService.accounts.filter().idEqualTo(id).and().isDeletedEqualTo(false).findFirst();
  }

  Future<Map<String, dynamic>?> getAccountByCode(String accountCode) async {
    final target = accountCode.trim().toUpperCase();
    if (target.isEmpty) {
      return null;
    }
    try {
      final entity = await dbService.accounts
          .filter()
          .codeEqualTo(target)
          .and()
          .isDeletedEqualTo(false)
          .findFirst();
      return entity == null ? null : _entityToMap(entity);
    } catch (error) {
      handleError(error, 'getAccountByCode');
      return null;
    }
  }

  Future<List<AccountEntity>> getAllAccounts() {
    return dbService.accounts
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<List<AccountEntity>> getAccountsByGroup(String group) {
    return dbService.accounts
        .filter()
        .groupEqualTo(group)
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<List<AccountEntity>> searchAccounts(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return getAllAccounts();
    }
    return dbService.accounts
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group(
          (builder) => builder
              .nameContains(normalized, caseSensitive: false)
              .or()
              .codeContains(normalized, caseSensitive: false),
        )
        .sortByName()
        .findAll();
  }

  Stream<List<AccountEntity>> watchAllAccounts() {
    return dbService.accounts
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Future<void> saveAccount(AccountEntity account) async {
    final entity = await _prepareAccountForSave(account);
    final existing = await dbService.accounts.getById(entity.id);

    await dbService.db.writeTxn(() async {
      await dbService.accounts.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: accountsCollection,
      documentId: entity.id,
      operation: existing == null ? 'create' : 'update',
      payload: entity.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> upsertAccount(
    Map<String, dynamic> accountData, {
    bool syncImmediately = false,
  }) async {
    final code = (accountData['code'] ?? '').toString().trim().toUpperCase();
    if (code.isEmpty) {
      throw ArgumentError('Account code is required');
    }

    final entity = _mapToEntity(accountData)
      ..id = (accountData['id'] ?? code).toString().trim()
      ..code = code;

    await saveAccount(entity);
    if (syncImmediately && _connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  Future<void> ensureAccountForParty({
    required String accountCode,
    required String accountName,
    required String group,
  }) async {
    final existing = await getAccountByCode(accountCode);
    if (existing != null) {
      return;
    }

    await upsertAccount({
      'id': accountCode,
      'code': accountCode,
      'name': accountName,
      'group': group,
      'isSystem': false,
      'isActive': true,
    });
    AppLogger.info('Created party account $accountCode', tag: 'Accounting');
  }

  Future<void> deleteAccount(String id) async {
    final entity = await getAccountById(id);
    if (entity == null) {
      return;
    }
    if (entity.isSystem) {
      throw ArgumentError('System accounts cannot be deleted');
    }

    final now = DateTime.now();
    entity
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await dbService.db.writeTxn(() async {
      await dbService.accounts.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: accountsCollection,
      documentId: entity.id,
      operation: 'delete',
      payload: entity.toJson(),
    );

    await _syncIfOnline();
  }

  Future<AccountEntity> _prepareAccountForSave(AccountEntity account) async {
    final now = DateTime.now();
    final normalizedId = account.id.trim().isEmpty
        ? (account.code.trim().isEmpty
              ? now.microsecondsSinceEpoch.toString()
              : account.code.trim().toUpperCase())
        : account.id.trim();
    final normalizedCode = account.code.trim().isEmpty
        ? normalizedId.toUpperCase()
        : account.code.trim().toUpperCase();
    final existing = await dbService.accounts.getById(normalizedId);

    account
      ..id = normalizedId
      ..code = normalizedCode
      ..name = account.name.trim().isEmpty ? normalizedCode : account.name.trim()
      ..group = account.group.trim().isEmpty ? 'Ungrouped' : account.group.trim()
      ..parentAccount = account.parentAccount.trim()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    if (existing != null) {
      account.deletedAt = existing.deletedAt;
    }

    return account;
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  AccountEntity _mapToEntity(Map<String, dynamic> map) {
    final entity = AccountEntity.fromJson(map);
    entity
      ..id = (map['id'] ?? map['code'] ?? '').toString().trim()
      ..code = (map['code'] ?? map['id'] ?? '').toString().trim().toUpperCase()
      ..name = (map['name'] ?? '').toString().trim()
      ..group = (map['group'] ?? 'Ungrouped').toString().trim()
      ..parentAccount = (map['parentAccount'] ?? '').toString().trim()
      ..isSystem = map['isSystem'] == true
      ..isActive = map['isActive'] != false
      ..currentBalance = _toDouble(map['currentBalance']);

    if (entity.updatedAt == DateTime.fromMillisecondsSinceEpoch(0)) {
      entity.updatedAt = DateTime.now();
    }
    return entity;
  }

  Map<String, dynamic> _entityToMap(AccountEntity entity) {
    return entity.toJson();
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
