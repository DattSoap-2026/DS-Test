import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../services/offline_first_service.dart';
import '../../utils/app_logger.dart';
import '../../data/local/entities/account_entity.dart';
import '../../data/local/base_entity.dart';

const String accountsCollection = 'accounts';

class AccountsRepository extends OfflineFirstService {
  AccountsRepository(super.firebase, [super.dbService]);

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
      if (count > 0) return;

      final entities = _defaultChart.map((e) => _mapToEntity(e)).toList();

      await dbService.db.writeTxn(() async {
        await dbService.accounts.putAll(entities);
      });
      AppLogger.info('Initialized default accounts chart', tag: 'Accounting');
    } catch (e) {
      handleError(e, 'ensureDefaultAccounts');
    }
  }

  Future<List<Map<String, dynamic>>> getAccounts({
    bool includeInactive = false,
  }) async {
    try {
      List<AccountEntity> entities;
      if (includeInactive) {
        entities = await dbService.accounts.where().findAll();
      } else {
        entities = await dbService.accounts
            .filter()
            .isActiveEqualTo(true)
            .findAll();
      }

      // On Windows, bootstrap if empty (consistency with legacy logic)
      final isWindows =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
      if (entities.isEmpty && !isWindows) {
        final remote = await bootstrapFromFirebase(
          collectionName: accountsCollection,
        );
        // Bootstrap returns List<Map>, we need to save them
        if (remote.isNotEmpty) {
          final newEntities = remote.map((e) => _mapToEntity(e)).toList();
          await dbService.db.writeTxn(() async {
            await dbService.accounts.putAll(newEntities);
          });
          entities = newEntities;
        }
      }

      final filtered = entities.map((e) => _entityToMap(e)).toList();

      filtered.sort(
        (a, b) => (a['name'] ?? '').toString().compareTo(
          (b['name'] ?? '').toString(),
        ),
      );
      return filtered;
    } catch (e) {
      handleError(e, 'getAccounts');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAccountByCode(String accountCode) async {
    final target = accountCode.trim().toUpperCase();
    if (target.isEmpty) return null;

    try {
      final entity = await dbService.accounts
          .filter()
          .codeEqualTo(target)
          .findFirst();
      if (entity != null) {
        return _entityToMap(entity);
      }
      return null;
    } catch (e) {
      handleError(e, 'getAccountByCode');
      return null;
    }
  }

  Future<void> upsertAccount(
    Map<String, dynamic> accountData, {
    bool syncImmediately = false,
  }) async {
    final code = (accountData['code'] ?? '').toString().trim().toUpperCase();
    if (code.isEmpty) {
      throw ArgumentError('Account code is required');
    }

    final id = (accountData['id'] ?? code).toString();
    final now = DateTime.now().toIso8601String();

    final entity = _mapToEntity(accountData);
    entity.id = id;
    entity.code = code;
    entity.updatedAt = DateTime.parse(now);
    entity.syncStatus = SyncStatus.pending;
    // createdAt handling removed as AccountEntity does not support it currently

    await dbService.db.writeTxn(() async {
      await dbService.accounts.put(entity);
    });

    final payload = _entityToMap(entity);
    await syncToFirebase(
      'set',
      payload,
      collectionName: accountsCollection,
      syncImmediately: syncImmediately,
    );
  }

  Future<void> ensureAccountForParty({
    required String accountCode,
    required String accountName,
    required String group,
  }) async {
    final existing = await getAccountByCode(accountCode);
    if (existing != null) return;

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

  // --- Helpers ---

  AccountEntity _mapToEntity(Map<String, dynamic> map) {
    final e = AccountEntity();
    e.id = map['id']?.toString() ?? '';
    e.code = map['code']?.toString() ?? '';
    e.name = map['name']?.toString() ?? '';
    e.group = map['group']?.toString() ?? 'Ungrouped';
    e.parentAccount = map['parentAccount']?.toString() ?? '';
    e.isSystem = map['isSystem'] == true;
    e.isActive = map['isActive'] != false;
    e.currentBalance =
        double.tryParse(map['currentBalance']?.toString() ?? '0') ?? 0.0;

    if (map['updatedAt'] != null) {
      e.updatedAt =
          DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now();
    } else {
      e.updatedAt = DateTime.now();
    }
    return e;
  }

  Map<String, dynamic> _entityToMap(AccountEntity e) {
    return {
      'id': e.id,
      'code': e.code,
      'name': e.name,
      'group': e.group,
      'parentAccount': e.parentAccount,
      'isSystem': e.isSystem,
      'isActive': e.isActive,
      'currentBalance': e.currentBalance,
      'updatedAt': e.updatedAt.toIso8601String(),
    };
  }
}
