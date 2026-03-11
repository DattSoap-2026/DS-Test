import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/entities/account_entity.dart';
import '../data/local/entities/voucher_entity.dart';
import '../data/local/entities/voucher_entry_entity.dart';
import '../data/local/base_entity.dart';
import 'database_service.dart';
import '../utils/app_logger.dart';

class AccountingMigrationService {
  final DatabaseService _dbService;

  AccountingMigrationService(this._dbService);

  static const String _migrationFlag = 'accounting_isar_migration_completed_v1';
  static const String _keyAccounts = 'local_accounts';
  static const String _keyVouchers = 'local_vouchers';
  static const String _keyEntries = 'local_voucher_entries';

  Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationFlag) == true) {
      return;
    }

    AppLogger.info(
      'Starting Accounting Migration to Isar...',
      tag: 'Migration',
    );

    try {
      await _migrateAccounts(prefs);
      await _migrateVouchers(prefs);

      await prefs.setBool(_migrationFlag, true);
      AppLogger.success(
        'Accounting Migration Completed Successfully',
        tag: 'Migration',
      );

      // Cleanup / Rename old keys to backup
      await _backupOldData(prefs);
    } catch (e, stack) {
      AppLogger.error(
        'Accounting Migration Failed',
        error: e,
        stackTrace: stack,
        tag: 'Migration',
      );
      // Do not set flag, so it retries next time.
    }
  }

  Future<void> _migrateAccounts(SharedPreferences prefs) async {
    final raw = prefs.getString(_keyAccounts);
    if (raw == null || raw.isEmpty) return;

    final List<dynamic> jsonList = jsonDecode(raw);
    final entities = <AccountEntity>[];

    for (final item in jsonList) {
      if (item is! Map<String, dynamic>) continue;
      try {
        final entity = AccountEntity()
          ..id = item['id']?.toString() ?? ''
          ..code = item['code']?.toString() ?? ''
          ..name = item['name']?.toString() ?? ''
          ..group = item['group']?.toString() ?? 'Ungrouped'
          ..parentAccount =
              item['parentAccount']?.toString() ??
              item['parent']?.toString() ??
              ''
          ..isSystem = item['isSystem'] == true
          ..isActive = item['isActive'] != false
          ..currentBalance =
              double.tryParse(item['currentBalance']?.toString() ?? '0') ?? 0.0
          ..updatedAt =
              DateTime.tryParse(item['updatedAt']?.toString() ?? '') ??
              DateTime.now();

        if (entity.id.isNotEmpty && entity.code.isNotEmpty) {
          entities.add(entity);
        }
      } catch (e) {
        AppLogger.warning(
          'Skipping invalid account during migration: $item',
          tag: 'Migration',
        );
      }
    }

    if (entities.isNotEmpty) {
      await _dbService.db.writeTxn(() async {
        await _dbService.accounts.putAll(entities);
      });
      AppLogger.info('Migrated ${entities.length} accounts', tag: 'Migration');
    }
  }

  Future<void> _migrateVouchers(SharedPreferences prefs) async {
    // Vouchers
    final rawVouchers = prefs.getString(_keyVouchers);
    if (rawVouchers != null && rawVouchers.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(rawVouchers);
      final entities = <VoucherEntity>[];

      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;
        try {
          final entity = VoucherEntity()
            ..id = item['id']?.toString() ?? ''
            ..transactionRefId = item['transactionRefId']?.toString() ?? ''
            ..date =
                DateTime.tryParse(item['date']?.toString() ?? '') ??
                DateTime.now()
            ..type = item['transactionType']?.toString() ?? 'Journal'
            ..amount = double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0
            ..narration = item['narration']?.toString() ?? ''
            ..partyName = item['partyName']?.toString()
            ..linkedId = item['linkedId']?.toString()
            ..syncStatus = SyncStatus.synced
            ..updatedAt =
                DateTime.tryParse(item['updatedAt']?.toString() ?? '') ??
                DateTime.now();

          // Fix for totalAmount if amount is 0/missing
          if (entity.amount == 0 && item['totalDebit'] != null) {
            entity.amount =
                double.tryParse(item['totalDebit'].toString()) ?? 0.0;
          }

          if (entity.id.isNotEmpty && entity.transactionRefId.isNotEmpty) {
            entities.add(entity);
          }
        } catch (e) {
          AppLogger.warning(
            'Skipping invalid voucher: $item',
            tag: 'Migration',
          );
        }
      }

      if (entities.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          await _dbService.vouchers.putAll(entities);
        });
        AppLogger.info(
          'Migrated ${entities.length} vouchers',
          tag: 'Migration',
        );
      }
    }

    // Entries
    final rawEntries = prefs.getString(_keyEntries);
    if (rawEntries != null && rawEntries.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(rawEntries);
      final entities = <VoucherEntryEntity>[];

      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;
        try {
          final entity = VoucherEntryEntity()
            ..id = item['id']?.toString() ?? ''
            ..voucherId = item['voucherId']?.toString() ?? ''
            ..accountCode =
                (item['accountCode'] ?? item['ledgerId'])?.toString() ?? ''
            ..debit = double.tryParse(item['debit']?.toString() ?? '0') ?? 0.0
            ..credit = double.tryParse(item['credit']?.toString() ?? '0') ?? 0.0
            ..narration = item['narration']?.toString() ?? ''
            ..updatedAt =
                DateTime.tryParse(item['updatedAt']?.toString() ?? '') ??
                DateTime.now();

          if (entity.id.isNotEmpty && entity.voucherId.isNotEmpty) {
            entities.add(entity);
          }
        } catch (e) {
          AppLogger.warning('Skipping invalid entry: $item', tag: 'Migration');
        }
      }

      if (entities.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          await _dbService.voucherEntries.putAll(entities);
        });
        AppLogger.info(
          'Migrated ${entities.length} voucher entries',
          tag: 'Migration',
        );
      }
    }
  }

  Future<void> _backupOldData(SharedPreferences prefs) async {
    // Rename keys to backup_...
    final keys = [_keyAccounts, _keyVouchers, _keyEntries];
    for (final key in keys) {
      final val = prefs.getString(key);
      if (val != null) {
        await prefs.setString('backup_$key', val);
        await prefs.remove(key);
      }
    }
  }
}
