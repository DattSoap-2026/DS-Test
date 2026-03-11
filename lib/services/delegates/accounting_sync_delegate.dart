import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/account_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/data/local/entities/voucher_entity.dart';
import 'package:flutter_app/data/local/entities/voucher_entry_entity.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/utils/app_logger.dart';
import 'package:isar/isar.dart';

class AccountingSyncDelegate {
  final DatabaseService _dbService;
  final SyncCommonUtils _utils;
  final Future<void> Function({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  })
  _recordMetric;

  AccountingSyncDelegate({
    required DatabaseService dbService,
    required SyncCommonUtils utils,
    required Future<void> Function({
      required String entityType,
      required SyncOperation operation,
      required int recordCount,
      required int durationMs,
      required bool success,
      String? errorMessage,
    })
    recordMetric,
  }) : _dbService = dbService,
       _utils = utils,
       _recordMetric = recordMetric;

  String _sanitizeAccountingDimensionValue(
    dynamic value, {
    int maxLength = 96,
  }) {
    if (value == null) return '';
    var text = value.toString().trim();
    if (text.isEmpty) return '';

    text = text
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r'[<>&|]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return '';
    if (text.length > maxLength) {
      return text.substring(0, maxLength);
    }
    return text;
  }

  String _firstNonEmptyAccountingDimension(
    List<dynamic> values, {
    int maxLength = 96,
  }) {
    for (final value in values) {
      final sanitized = _sanitizeAccountingDimensionValue(
        value,
        maxLength: maxLength,
      );
      if (sanitized.isNotEmpty) return sanitized;
    }
    return '';
  }

  Map<String, dynamic> _decodeAccountingDimensionsRaw(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return const <String, dynamic>{};
      }
    }
    return const <String, dynamic>{};
  }

  Map<String, dynamic> _extractAccountingDimensions(Map<String, dynamic> data) {
    final nested = _decodeAccountingDimensionsRaw(data['accountingDimensions']);

    final route = _firstNonEmptyAccountingDimension([
      data['route'],
      nested['route'],
    ]);
    final district = _firstNonEmptyAccountingDimension([
      data['district'],
      nested['district'],
    ]);
    final division = _firstNonEmptyAccountingDimension([
      data['division'],
      nested['division'],
      data['zone'],
      nested['zone'],
    ]);
    final salesmanId = _firstNonEmptyAccountingDimension([
      data['salesmanId'],
      nested['salesmanId'],
    ]);
    final salesmanName = _firstNonEmptyAccountingDimension([
      data['salesmanName'],
      nested['salesmanName'],
    ]);
    final saleDate = _firstNonEmptyAccountingDimension([
      data['saleDate'],
      nested['saleDate'],
    ]);
    final dealerId = _firstNonEmptyAccountingDimension([
      data['dealerId'],
      nested['dealerId'],
    ]);
    final dealerName = _firstNonEmptyAccountingDimension([
      data['dealerName'],
      nested['dealerName'],
    ]);

    return {
      if (route.isNotEmpty) 'route': route,
      if (district.isNotEmpty) 'district': district,
      if (division.isNotEmpty) 'division': division,
      if (salesmanId.isNotEmpty) 'salesmanId': salesmanId,
      if (salesmanName.isNotEmpty) 'salesmanName': salesmanName,
      if (saleDate.isNotEmpty) 'saleDate': saleDate,
      if (dealerId.isNotEmpty) 'dealerId': dealerId,
      if (dealerName.isNotEmpty) 'dealerName': dealerName,
    };
  }

  String? _encodeAccountingDimensionsJson(Map<String, dynamic> dimensions) {
    if (dimensions.isEmpty) return null;
    try {
      return jsonEncode(dimensions);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _decodeAccountingDimensionsJson(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return const <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return const <String, dynamic>{};
    }
    return const <String, dynamic>{};
  }

  int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<void> syncAccounts(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH
      final pendingAccounts = await _dbService.accounts
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pendingAccounts.isNotEmpty) {
        final chunks = _utils.chunkList(pendingAccounts, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final acc in chunk) {
            final data = {
              'id': acc.id,
              'code': acc.code,
              'name': acc.name,
              'group': acc.group,
              'parentAccount': acc.parentAccount,
              'isSystem': acc.isSystem,
              'isActive': acc.isActive,
              'updatedAt': acc.updatedAt.toIso8601String(),
            };
            final docRef = db.collection(CollectionRegistry.accounts).doc(acc.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();
          await _dbService.db.writeTxn(() async {
            final updatedAccounts = <AccountEntity>[];
            for (final acc in chunk) {
              acc.syncStatus = SyncStatus.synced;
              updatedAccounts.add(acc);
            }
            if (updatedAccounts.isNotEmpty) {
              await _dbService.accounts.putAll(updatedAccounts);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing accounts', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _recordMetric(
        entityType: 'accounts',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('accounts');
      firestore.Query query = db.collection(CollectionRegistry.accounts);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final accountsToPut = <AccountEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final entity = AccountEntity()
            ..id = doc.id
            ..code = data['code']?.toString() ?? ''
            ..name = data['name']?.toString() ?? ''
            ..group = data['group']?.toString() ?? ''
            ..parentAccount = data['parentAccount']?.toString() ?? ''
            ..isSystem = data['isSystem'] == true
            ..isActive = data['isActive'] != false
            ..updatedAt = updatedAt
            ..syncStatus = SyncStatus.synced;

          accountsToPut.add(entity);
        }

        if (accountsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.accounts.putAll(accountsToPut);
          });
        }
        await _utils.setLastSyncTimestamp('accounts', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling accounts', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _recordMetric(
        entityType: 'accounts',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncVouchers(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH
      final pendingVouchers = await _dbService.vouchers
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pendingVouchers.isNotEmpty) {
        final chunks = _utils.chunkList(pendingVouchers, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final v in chunk) {
            final decodedDimensions = _decodeAccountingDimensionsJson(
              v.accountingDimensionsJson,
            );
            final dimensions = _extractAccountingDimensions({
              'route': v.route,
              'district': v.district,
              'division': v.division,
              'salesmanId': v.salesmanId,
              'salesmanName': v.salesmanName,
              'saleDate': v.saleDate,
              'dealerId': v.dealerId,
              'dealerName': v.dealerName,
              'accountingDimensions': decodedDimensions,
            });
            final data = {
              'id': v.id,
              'transactionRefId': v.transactionRefId,
              'date': v.date.toIso8601String(),
              'transactionType': v.type,
              'amount': v.amount,
              'narration': v.narration,
              'partyName': v.partyName,
              'linkedId': v.linkedId,
              'voucherNumber': v.voucherNumber,
              ...dimensions,
              if (dimensions.isNotEmpty) 'accountingDimensions': dimensions,
              'dimensionVersion': v.dimensionVersion ?? 1,
              'updatedAt': v.updatedAt.toIso8601String(),
              'isSynced': true, // For legacy compatibility
            };
            final docRef = db.collection(CollectionRegistry.vouchers).doc(v.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();
          await _dbService.db.writeTxn(() async {
            final updatedVouchers = <VoucherEntity>[];
            for (final v in chunk) {
              v.syncStatus = SyncStatus.synced;
              updatedVouchers.add(v);
            }
            if (updatedVouchers.isNotEmpty) {
              await _dbService.vouchers.putAll(updatedVouchers);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing vouchers', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _recordMetric(
        entityType: 'vouchers',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('vouchers');
      firestore.Query query = db.collection(CollectionRegistry.vouchers);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);

        final ids = snapshot.docs.map((doc) => doc.id).toList();
        final existingRecords = await _dbService.vouchers
            .filter()
            .anyOf(ids, (q, String id) => q.idEqualTo(id))
            .findAll();
        final existingMap = {for (final v in existingRecords) v.id: v};

        final vouchersToPut = <VoucherEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          // Conflict check
          final existing = existingMap[doc.id];
          if (existing != null && existing.syncStatus == SyncStatus.pending) {
            // Basic conflict resolution: Server wins for accounting usually, BUT vouchers are immutable mostly.
            // If local edit exists, we might overwrite.
            // NOTE: Advanced merge strategy can be added later if voucher mutability rules expand.
          }
          final dimensions = _extractAccountingDimensions(data);

          final entity = VoucherEntity()
            ..id = doc.id
            ..transactionRefId = data['transactionRefId']?.toString() ?? ''
            ..date =
                DateTime.tryParse(data['date']?.toString() ?? '') ??
                DateTime.now()
            ..type = data['transactionType']?.toString() ?? ''
            ..amount = (data['amount'] as num?)?.toDouble() ?? 0.0
            ..narration = data['narration']?.toString() ?? ''
            ..partyName = data['partyName']?.toString()
            ..linkedId = data['linkedId']?.toString()
            ..voucherNumber = data['voucherNumber']?.toString()
            ..route = dimensions['route']?.toString()
            ..district = dimensions['district']?.toString()
            ..division = dimensions['division']?.toString()
            ..salesmanId = dimensions['salesmanId']?.toString()
            ..salesmanName = dimensions['salesmanName']?.toString()
            ..saleDate = dimensions['saleDate']?.toString()
            ..dealerId = dimensions['dealerId']?.toString()
            ..dealerName = dimensions['dealerName']?.toString()
            ..accountingDimensionsJson = _encodeAccountingDimensionsJson(
              dimensions,
            )
            ..dimensionVersion = _toIntOrNull(data['dimensionVersion']) ?? 1
            ..updatedAt = updatedAt
            ..syncStatus = SyncStatus.synced;

          vouchersToPut.add(entity);
        }

        if (vouchersToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.vouchers.putAll(vouchersToPut);
          });
        }
        await _utils.setLastSyncTimestamp('vouchers', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling vouchers', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _recordMetric(
        entityType: 'vouchers',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncVoucherEntries(
    firestore.FirebaseFirestore db, {
    required String? firebaseUid,
    bool isManagerOrAdmin = false,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH
      final pendingEntries = await _dbService.voucherEntries
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pendingEntries.isNotEmpty) {
        final chunks = _utils.chunkList(pendingEntries, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final e in chunk) {
            final decodedDimensions = _decodeAccountingDimensionsJson(
              e.accountingDimensionsJson,
            );
            final dimensions = _extractAccountingDimensions({
              'route': e.route,
              'district': e.district,
              'division': e.division,
              'salesmanId': e.salesmanId,
              'salesmanName': e.salesmanName,
              'saleDate': e.saleDate,
              'dealerId': e.dealerId,
              'dealerName': e.dealerName,
              'accountingDimensions': decodedDimensions,
            });
            final data = {
              'id': e.id,
              'voucherId': e.voucherId,
              'accountCode': e.accountCode, // assuming matching ledgerId
              'debit': e.debit,
              'credit': e.credit,
              'narration': e.narration,
              ...dimensions,
              if (dimensions.isNotEmpty) 'accountingDimensions': dimensions,
              'dimensionVersion': e.dimensionVersion ?? 1,
              'date': e.date?.toIso8601String(),
              'updatedAt': e.updatedAt.toIso8601String(),
            };
            final docRef = db.collection(CollectionRegistry.voucherEntries).doc(
              e.id,
            );
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();
          await _dbService.db.writeTxn(() async {
            final updatedEntries = <VoucherEntryEntity>[];
            for (final e in chunk) {
              e.syncStatus = SyncStatus.synced;
              updatedEntries.add(e);
            }
            if (updatedEntries.isNotEmpty) {
              await _dbService.voucherEntries.putAll(updatedEntries);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing voucher entries', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _recordMetric(
        entityType: 'voucher_entries',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('voucher_entries');
      firestore.Query query = db.collection(CollectionRegistry.voucherEntries);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final entriesToPut = <VoucherEntryEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;
          final dimensions = _extractAccountingDimensions(data);

          final entity = VoucherEntryEntity()
            ..id = doc.id
            ..voucherId = data['voucherId']?.toString() ?? ''
            ..accountCode =
                (data['accountCode'] ?? data['ledgerId'])?.toString() ?? ''
            ..debit = (data['debit'] as num?)?.toDouble() ?? 0.0
            ..credit = (data['credit'] as num?)?.toDouble() ?? 0.0
            ..narration = data['narration']?.toString()
            ..route = dimensions['route']?.toString()
            ..district = dimensions['district']?.toString()
            ..division = dimensions['division']?.toString()
            ..salesmanId = dimensions['salesmanId']?.toString()
            ..salesmanName = dimensions['salesmanName']?.toString()
            ..saleDate = dimensions['saleDate']?.toString()
            ..dealerId = dimensions['dealerId']?.toString()
            ..dealerName = dimensions['dealerName']?.toString()
            ..accountingDimensionsJson = _encodeAccountingDimensionsJson(
              dimensions,
            )
            ..dimensionVersion = _toIntOrNull(data['dimensionVersion']) ?? 1
            ..date = DateTime.tryParse(data['date']?.toString() ?? '')
            ..updatedAt = updatedAt
            ..syncStatus = SyncStatus.synced;

          entriesToPut.add(entity);
        }

        if (entriesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.voucherEntries.putAll(entriesToPut);
          });
        }
        await _utils.setLastSyncTimestamp('voucher_entries', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling voucher entries', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _recordMetric(
        entityType: 'voucher_entries',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
