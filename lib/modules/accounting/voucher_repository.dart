import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../services/offline_first_service.dart';
import '../../utils/app_logger.dart';
import '../../data/local/entities/voucher_entity.dart';
import '../../data/local/entities/voucher_entry_entity.dart';
import '../../data/local/base_entity.dart';

const String vouchersCollection = 'vouchers';
const String voucherEntriesCollection = 'voucher_entries';

class StrictBusinessWrite {
  final String collection;
  final String docId;
  final Map<String, dynamic> data;
  final bool merge;

  const StrictBusinessWrite({
    required this.collection,
    required this.docId,
    required this.data,
    this.merge = true,
  });
}

class VoucherRepository extends OfflineFirstService {
  VoucherRepository(super.firebase, [super.dbService]);
  static const String _fallbackEntriesKey = '_entries';

  @override
  String get localStorageKey => 'local_vouchers';

  @override
  bool get useIsar => true;

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String _sanitizeDimensionValue(dynamic value, {int maxLength = 96}) {
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

  String _firstNonEmpty(List<dynamic> values, {int maxLength = 96}) {
    for (final value in values) {
      final sanitized = _sanitizeDimensionValue(value, maxLength: maxLength);
      if (sanitized.isNotEmpty) return sanitized;
    }
    return '';
  }

  Map<String, dynamic> _decodeRawDimensions(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map) {
          return parsed.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return const <String, dynamic>{};
      }
    }
    return const <String, dynamic>{};
  }

  Map<String, dynamic> _extractAccountingDimensions(Map<String, dynamic> map) {
    final nested = _decodeRawDimensions(map['accountingDimensions']);

    final route = _firstNonEmpty([map['route'], nested['route']]);
    final district = _firstNonEmpty([map['district'], nested['district']]);
    final division = _firstNonEmpty([map['division'], nested['division']]);
    final salesmanId = _firstNonEmpty([
      map['salesmanId'],
      nested['salesmanId'],
    ]);
    final salesmanName = _firstNonEmpty([
      map['salesmanName'],
      nested['salesmanName'],
    ]);
    final saleDate = _firstNonEmpty([map['saleDate'], nested['saleDate']]);
    final dealerId = _firstNonEmpty([map['dealerId'], nested['dealerId']]);
    final dealerName = _firstNonEmpty([
      map['dealerName'],
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

  void _applyDimensionsToVoucherEntity(
    VoucherEntity entity,
    Map<String, dynamic> dimensions, {
    dynamic dimensionVersion,
  }) {
    entity.route = _sanitizeDimensionValue(dimensions['route']);
    entity.district = _sanitizeDimensionValue(dimensions['district']);
    entity.division = _sanitizeDimensionValue(dimensions['division']);
    entity.salesmanId = _sanitizeDimensionValue(dimensions['salesmanId']);
    entity.salesmanName = _sanitizeDimensionValue(dimensions['salesmanName']);
    entity.saleDate = _sanitizeDimensionValue(dimensions['saleDate']);
    entity.dealerId = _sanitizeDimensionValue(dimensions['dealerId']);
    entity.dealerName = _sanitizeDimensionValue(dimensions['dealerName']);
    entity.accountingDimensionsJson = _encodeAccountingDimensionsJson(
      dimensions,
    );
    entity.dimensionVersion = _toIntOrNull(dimensionVersion) ?? 1;
  }

  void _applyDimensionsToEntryEntity(
    VoucherEntryEntity entity,
    Map<String, dynamic> dimensions, {
    dynamic dimensionVersion,
  }) {
    entity.route = _sanitizeDimensionValue(dimensions['route']);
    entity.district = _sanitizeDimensionValue(dimensions['district']);
    entity.division = _sanitizeDimensionValue(dimensions['division']);
    entity.salesmanId = _sanitizeDimensionValue(dimensions['salesmanId']);
    entity.salesmanName = _sanitizeDimensionValue(dimensions['salesmanName']);
    entity.saleDate = _sanitizeDimensionValue(dimensions['saleDate']);
    entity.dealerId = _sanitizeDimensionValue(dimensions['dealerId']);
    entity.dealerName = _sanitizeDimensionValue(dimensions['dealerName']);
    entity.accountingDimensionsJson = _encodeAccountingDimensionsJson(
      dimensions,
    );
    entity.dimensionVersion = _toIntOrNull(dimensionVersion) ?? 1;
  }

  // --- Mappers ---

  VoucherEntity _mapToVoucherEntity(Map<String, dynamic> map) {
    final entity = VoucherEntity()
      ..id = map['id']?.toString() ?? ''
      ..transactionRefId = map['transactionRefId']?.toString() ?? ''
      ..date =
          DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now()
      ..type = map['transactionType']?.toString() ?? 'Journal'
      ..amount = _toDouble(map['amount'] ?? map['totalDebit'])
      ..narration = map['narration']?.toString() ?? ''
      ..partyName = map['partyName']?.toString()
      ..linkedId = map['linkedId']?.toString()
      ..syncStatus = (map['isSynced'] == true)
          ? SyncStatus.synced
          : SyncStatus.pending
      ..voucherNumber = map['voucherNumber']?.toString()
      ..updatedAt =
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now();

    final dimensions = _extractAccountingDimensions(map);
    _applyDimensionsToVoucherEntity(
      entity,
      dimensions,
      dimensionVersion: map['dimensionVersion'],
    );
    return entity;
  }

  VoucherEntryEntity _mapToEntryEntity(Map<String, dynamic> map) {
    final entity = VoucherEntryEntity()
      ..id = map['id']?.toString() ?? ''
      ..voucherId = map['voucherId']?.toString() ?? ''
      ..accountCode = (map['accountCode'] ?? map['ledgerId'])?.toString() ?? ''
      ..debit = _toDouble(map['debit'])
      ..credit = _toDouble(map['credit'])
      ..narration = map['narration']?.toString()
      ..date = DateTime.tryParse(map['date']?.toString() ?? '')
      ..updatedAt =
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now();

    final dimensions = _extractAccountingDimensions(map);
    _applyDimensionsToEntryEntity(
      entity,
      dimensions,
      dimensionVersion: map['dimensionVersion'],
    );
    return entity;
  }

  Map<String, dynamic> _voucherEntityToMap(VoucherEntity e) {
    final decoded = _decodeAccountingDimensionsJson(e.accountingDimensionsJson);
    final dimensions = _extractAccountingDimensions({
      'route': e.route,
      'district': e.district,
      'division': e.division,
      'salesmanId': e.salesmanId,
      'salesmanName': e.salesmanName,
      'saleDate': e.saleDate,
      'dealerId': e.dealerId,
      'dealerName': e.dealerName,
      'accountingDimensions': decoded,
    });

    return {
      'id': e.id,
      'transactionRefId': e.transactionRefId,
      'date': e.date.toIso8601String(),
      'transactionType': e.type,
      'amount': e.amount,
      'narration': e.narration,
      'partyName': e.partyName,
      'linkedId': e.linkedId,
      'isSynced': e.syncStatus == SyncStatus.synced,
      'voucherNumber': e.voucherNumber,
      ...dimensions,
      if (dimensions.isNotEmpty) 'accountingDimensions': dimensions,
      'dimensionVersion': e.dimensionVersion ?? 1,
      'updatedAt': e.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _entryEntityToMap(VoucherEntryEntity e) {
    final decoded = _decodeAccountingDimensionsJson(e.accountingDimensionsJson);
    final dimensions = _extractAccountingDimensions({
      'route': e.route,
      'district': e.district,
      'division': e.division,
      'salesmanId': e.salesmanId,
      'salesmanName': e.salesmanName,
      'saleDate': e.saleDate,
      'dealerId': e.dealerId,
      'dealerName': e.dealerName,
      'accountingDimensions': decoded,
    });

    return {
      'id': e.id,
      'voucherId': e.voucherId,
      'accountCode': e.accountCode,
      'debit': e.debit,
      'credit': e.credit,
      'narration': e.narration ?? '',
      ...dimensions,
      if (dimensions.isNotEmpty) 'accountingDimensions': dimensions,
      'dimensionVersion': e.dimensionVersion ?? 1,
      'date': e.date?.toIso8601String(),
      'updatedAt': e.updatedAt.toIso8601String(),
    };
  }

  bool _isIsarReady() {
    try {
      dbService.db;
      return true;
    } catch (_) {
      return false;
    }
  }

  DateTime _parseIsoDate(dynamic raw) {
    return DateTime.tryParse(raw?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Map<String, dynamic> _stripFallbackVoucher(Map<String, dynamic> voucher) {
    final copy = Map<String, dynamic>.from(voucher);
    copy.remove(_fallbackEntriesKey);
    return copy;
  }

  List<Map<String, dynamic>> _fallbackEntriesFromVoucher(
    Map<String, dynamic> voucher,
  ) {
    final raw = voucher[_fallbackEntriesKey];
    if (raw is! List) return const <Map<String, dynamic>>[];

    final result = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        result.add(
          item.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _loadFallbackVouchers() async {
    final local = await loadFromLocal();
    return local
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: true);
  }

  Future<void> _saveFallbackVouchers(List<Map<String, dynamic>> vouchers) async {
    await saveToLocal(
      vouchers
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false),
    );
  }

  // --- Methods ---

  Future<List<Map<String, dynamic>>> getVouchers({
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      if (!_isIsarReady()) {
        final vouchers = await _loadFallbackVouchers();
        vouchers.sort(
          (a, b) => _parseIsoDate(
            b['date'],
          ).compareTo(_parseIsoDate(a['date'])),
        );

        final normalizedOffset = offset < 0 ? 0 : offset;
        final normalizedLimit = limit <= 0 ? vouchers.length : limit;
        return vouchers
            .skip(normalizedOffset)
            .take(normalizedLimit)
            .map(_stripFallbackVoucher)
            .toList(growable: false);
      }

      // Use index for sorting
      final vouchers = await dbService.vouchers
          .where()
          .sortByDateDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      // Bootstrap logic for Windows if empty
      final isWindows =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
      if (vouchers.isEmpty && offset == 0 && !isWindows) {
        final remote = await bootstrapFromFirebase(
          collectionName: vouchersCollection,
        );
        if (remote.isNotEmpty) {
          final newEntities = remote
              .map((e) => _mapToVoucherEntity(e))
              .toList();
          await dbService.db.writeTxn(() async {
            await dbService.vouchers.putAll(newEntities);
          });
          return (await dbService.vouchers
                  .where()
                  .sortByDateDesc()
                  .offset(offset)
                  .limit(limit)
                  .findAll())
              .map((e) => _voucherEntityToMap(e))
              .toList();
        }
      }

      return vouchers.map((e) => _voucherEntityToMap(e)).toList();
    } catch (e) {
      handleError(e, 'getVouchers');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVoucherEntries({
    DateTime? fromDate,
    DateTime? toDate,
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      if (!_isIsarReady()) {
        var entries = (await _loadFallbackVouchers())
            .expand(_fallbackEntriesFromVoucher)
            .toList(growable: true);

        if (fromDate != null) {
          entries = entries
              .where(
                (entry) => !_parseIsoDate(
                      entry['date'] ?? entry['postingDate'],
                    ).isBefore(fromDate),
              )
              .toList(growable: true);
        }
        if (toDate != null) {
          entries = entries
              .where(
                (entry) => !_parseIsoDate(
                      entry['date'] ?? entry['postingDate'],
                    ).isAfter(toDate),
              )
              .toList(growable: true);
        }

        entries.sort(
          (a, b) => _parseIsoDate(
            b['date'] ?? b['postingDate'],
          ).compareTo(_parseIsoDate(a['date'] ?? a['postingDate'])),
        );

        final normalizedOffset = offset < 0 ? 0 : offset;
        final normalizedLimit = limit <= 0 ? entries.length : limit;
        return entries
            .skip(normalizedOffset)
            .take(normalizedLimit)
            .map((entry) => Map<String, dynamic>.from(entry))
            .toList(growable: false);
      }

      List<VoucherEntryEntity> entries = [];

      // Use efficient separate queries to avoid type issues with QueryBuilder
      if (fromDate != null && toDate != null) {
        entries = await dbService.voucherEntries
            .filter()
            .dateBetween(
              fromDate,
              toDate,
              includeLower: true,
              includeUpper: true,
            )
            .offset(offset)
            .limit(limit)
            .findAll();
      } else if (fromDate != null) {
        entries = await dbService.voucherEntries
            .filter()
            .dateGreaterThan(fromDate, include: true)
            .offset(offset)
            .limit(limit)
            .findAll();
      } else if (toDate != null) {
        entries = await dbService.voucherEntries
            .filter()
            .dateLessThan(toDate, include: true)
            .offset(offset)
            .limit(limit)
            .findAll();
      } else {
        entries = await dbService.voucherEntries
            .where()
            .offset(offset)
            .limit(limit)
            .findAll();
      }

      // Windows bootstrap logic for entries
      final isWindows =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
      if (entries.isEmpty && offset == 0 && !isWindows) {
        final remote = await bootstrapFromFirebase(
          collectionName: voucherEntriesCollection,
        );
        if (remote.isNotEmpty) {
          final newEntities = remote.map((e) => _mapToEntryEntity(e)).toList();
          await dbService.db.writeTxn(() async {
            await dbService.voucherEntries.putAll(newEntities);
          });
          // Re-fetch logic
          if (fromDate != null && toDate != null) {
            entries = await dbService.voucherEntries
                .filter()
                .dateBetween(
                  fromDate,
                  toDate,
                  includeLower: true,
                  includeUpper: true,
                )
                .offset(offset)
                .limit(limit)
                .findAll();
          } else if (fromDate != null) {
            entries = await dbService.voucherEntries
                .filter()
                .dateGreaterThan(fromDate, include: true)
                .offset(offset)
                .limit(limit)
                .findAll();
          } else if (toDate != null) {
            entries = await dbService.voucherEntries
                .filter()
                .dateLessThan(toDate, include: true)
                .offset(offset)
                .limit(limit)
                .findAll();
          } else {
            entries = await dbService.voucherEntries
                .where()
                .offset(offset)
                .limit(limit)
                .findAll();
          }
        }
      }

      return entries.map((e) => _entryEntityToMap(e)).toList();
    } catch (e) {
      handleError(e, 'getVoucherEntries');
      return [];
    }
  }

  Future<String> createVoucherBundle({
    required Map<String, dynamic> voucher,
    required List<Map<String, dynamic>> entries,
    required bool strictMode,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    if (entries.isEmpty) {
      throw ArgumentError('Voucher entries are required');
    }

    final transactionRefId = (voucher['transactionRefId'] ?? '')
        .toString()
        .trim();
    final transactionType = _normalizeType(voucher['transactionType']);
    if (transactionRefId.isEmpty || transactionType.isEmpty) {
      throw ArgumentError(
        'transactionRefId and transactionType are mandatory.',
      );
    }

    final voucherId = transactionRefId;

    // Check for duplicates
    final existing = await _findExistingVoucher(
      transactionRefId: transactionRefId,
      transactionType: transactionType,
      strictMode: strictMode,
    );

    if (existing != null) {
      AppLogger.warning(
        'Duplicate voucher skipped: $transactionType/$transactionRefId',
        tag: 'Accounting',
      );
      return existing['id'];
    }

    final now = getCurrentTimestamp();
    final postingDate = (voucher['date'] ?? now).toString();

    final normalizedEntries = <Map<String, dynamic>>[];
    final entryEntities = <VoucherEntryEntity>[];

    double totalDebit = 0;
    double totalCredit = 0;

    for (final raw in entries) {
      final debit = _toDouble(raw['debit']);
      final credit = _toDouble(raw['credit']);
      if (debit <= 0 && credit <= 0) continue;

      totalDebit += debit;
      totalCredit += credit;
      final entryDimensions = _extractAccountingDimensions(raw);
      final entryDimensionVersion =
          _toIntOrNull(raw['dimensionVersion']) ??
          _toIntOrNull(voucher['dimensionVersion']) ??
          1;

      final entryEntity = VoucherEntryEntity()
        ..id = (raw['id'] ?? '${voucherId}_${entryEntities.length + 1}')
            .toString()
        ..voucherId = voucherId
        ..accountCode = (raw['ledgerId'] ?? raw['accountCode']).toString()
        ..debit = debit
        ..credit = credit
        ..narration = (raw['narration'] ?? '').toString()
        ..date = DateTime.tryParse(postingDate)
        ..updatedAt = DateTime.tryParse(now) ?? DateTime.now();
      _applyDimensionsToEntryEntity(
        entryEntity,
        entryDimensions,
        dimensionVersion: entryDimensionVersion,
      );

      entryEntities.add(entryEntity);

      normalizedEntries.add({
        ...raw,
        'id': entryEntity.id,
        'voucherId': voucherId,
        'voucherType': voucher['voucherType'] ?? transactionType,
        'transactionRefId': transactionRefId,
        'transactionType': transactionType,
        'ledgerId': entryEntity.accountCode,
        'date': postingDate,
        'postingDate': postingDate,
        'debit': debit,
        'credit': credit,
        ...entryDimensions,
        if (entryDimensions.isNotEmpty) 'accountingDimensions': entryDimensions,
        'dimensionVersion': entryDimensionVersion,
        'updatedAt': now,
        'createdAt': raw['createdAt'] ?? now,
      });
    }

    if (entryEntities.isEmpty) {
      throw ArgumentError('At least one debit/credit entry is required');
    }

    final difference = (totalDebit - totalCredit).abs();
    if (difference > 0.01) {
      throw StateError(
        'Voucher is not balanced. Debit=$totalDebit Credit=$totalCredit',
      );
    }

    final voucherEntity = _mapToVoucherEntity({
      ...voucher,
      'id': voucherId,
      'transactionRefId': transactionRefId,
      'transactionType': transactionType,
      'date': postingDate,
      'amount': totalDebit,
      'updatedAt': now,
      'isSynced': strictMode,
    });

    final voucherData = <String, dynamic>{
      ...voucher,
      'id': voucherId,
      'transactionRefId': transactionRefId,
      'transactionType': transactionType,
      'date': postingDate,
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
      'isBalanced': true,
      'entryCount': entryEntities.length,
      'updatedAt': now,
      'createdAt': voucher['createdAt'] ?? now,
      'isSynced': strictMode,
    };

    if (_isIsarReady()) {
      // Atomic Write to Isar
      await dbService.db.writeTxn(() async {
        await dbService.vouchers.put(voucherEntity);
        await dbService.voucherEntries.putAll(entryEntities);
      });
    } else {
      final local = await _loadFallbackVouchers();
      local.removeWhere((item) => item['id']?.toString() == voucherId);
      local.add({
        ...voucherData,
        'amount': totalDebit,
        _fallbackEntriesKey: normalizedEntries
            .map((entry) => Map<String, dynamic>.from(entry))
            .toList(growable: false),
      });
      await _saveFallbackVouchers(local);
    }

    if (strictMode) {
      await _commitStrictBatch(
        voucherId: voucherId,
        voucherData: voucherData,
        entries: normalizedEntries,
        strictBusinessWrite: strictBusinessWrite,
      );
      return voucherId;
    }

    // Sync Queue
    await syncToFirebase(
      'set',
      voucherData,
      collectionName: vouchersCollection,
      syncImmediately: false,
    );
    for (final entry in normalizedEntries) {
      await syncToFirebase(
        'set',
        entry,
        collectionName: voucherEntriesCollection,
        syncImmediately: false,
      );
    }
    return voucherId;
  }

  Future<String> createReversalVoucherBundle({
    required String originalVoucherId,
    required String reason,
    required String postedByUserId,
    String? postedByName,
    DateTime? reversalDate,
    bool strictMode = false,
    String? voucherNumber,
    String? financialYearId,
  }) async {
    final targetVoucherId = originalVoucherId.trim();
    if (targetVoucherId.isEmpty) {
      throw ArgumentError('originalVoucherId is required');
    }
    final reasonText = reason.trim();
    if (reasonText.isEmpty) {
      throw ArgumentError('reason is required');
    }

    final effectiveDate = reversalDate ?? DateTime.now();
    final postingDate = effectiveDate.toIso8601String();
    final now = getCurrentTimestamp();

    final originalVoucher = await _loadVoucherById(
      targetVoucherId,
      includeRemote: strictMode,
    );
    if (originalVoucher == null) {
      throw StateError('Original voucher not found: $targetVoucherId');
    }

    final originalEntries = await _loadEntriesByVoucherId(
      targetVoucherId,
      includeRemote: strictMode,
    );
    if (originalEntries.isEmpty) {
      throw StateError(
        'Cannot create reversal without voucher entries: $targetVoucherId',
      );
    }

    final reversalId =
        'reversal_${targetVoucherId}_${effectiveDate.microsecondsSinceEpoch}';
    final originalType = _normalizeType(originalVoucher['transactionType']);
    final originalVoucherType = _normalizeType(originalVoucher['voucherType']);
    final reversalVoucherType = originalVoucherType.isNotEmpty
        ? originalVoucherType
        : (originalType.isNotEmpty ? originalType : 'journal');
    final voucherDimensions = _extractAccountingDimensions(originalVoucher);
    final originalNarration = (originalVoucher['narration'] ?? '')
        .toString()
        .trim();
    final reversalNarration = originalNarration.isEmpty
        ? 'Reversal for voucher $targetVoucherId: $reasonText'
        : 'Reversal for voucher $targetVoucherId ($originalNarration): $reasonText';

    final reversedEntries = <Map<String, dynamic>>[];
    for (final originalEntry in originalEntries) {
      final debit = _toDouble(originalEntry['debit']);
      final credit = _toDouble(originalEntry['credit']);
      if (debit <= 0 && credit <= 0) {
        continue;
      }

      final entryDimensions = _extractAccountingDimensions(originalEntry);
      final entryNarration = (originalEntry['narration'] ?? '')
          .toString()
          .trim();
      final reversalEntryNarration = entryNarration.isEmpty
          ? 'Reversal entry for voucher $targetVoucherId'
          : 'Reversal of $entryNarration';
      final entryDimensionVersion =
          _toIntOrNull(originalEntry['dimensionVersion']) ??
          _toIntOrNull(originalVoucher['dimensionVersion']) ??
          1;

      reversedEntries.add({
        ...originalEntry,
        'id': '${reversalId}_${reversedEntries.length + 1}',
        'voucherId': reversalId,
        'transactionRefId': reversalId,
        'transactionType': 'reversal',
        'voucherType': reversalVoucherType,
        'date': postingDate,
        'postingDate': postingDate,
        'debit': credit,
        'credit': debit,
        'narration': reversalEntryNarration,
        ...entryDimensions,
        if (entryDimensions.isNotEmpty) 'accountingDimensions': entryDimensions,
        'dimensionVersion': entryDimensionVersion,
        'updatedAt': now,
        'createdAt': now,
      });
    }

    if (reversedEntries.isEmpty) {
      throw StateError(
        'Cannot create reversal because original entries are empty/zeroed: $targetVoucherId',
      );
    }

    final resolvedFinancialYearId = financialYearId?.trim().isNotEmpty == true
        ? financialYearId!.trim()
        : (originalVoucher['financialYearId'] ?? '').toString().trim();
    final sourceId = (originalVoucher['sourceId'] ?? targetVoucherId)
        .toString()
        .trim();

    return createVoucherBundle(
      voucher: {
        'transactionRefId': reversalId,
        'transactionType': 'reversal',
        'voucherType': reversalVoucherType,
        if (voucherNumber != null && voucherNumber.trim().isNotEmpty)
          'voucherNumber': voucherNumber.trim(),
        'sourceModule': 'accounting_reversal',
        'sourceId': sourceId,
        'linkedId': targetVoucherId,
        'reversalOfVoucherId': targetVoucherId,
        'reversalReason': reasonText,
        if (resolvedFinancialYearId.isNotEmpty)
          'financialYearId': resolvedFinancialYearId,
        'date': postingDate,
        'partyId': originalVoucher['partyId'],
        'partyName': originalVoucher['partyName'],
        'narration': reversalNarration,
        ...voucherDimensions,
        if (voucherDimensions.isNotEmpty)
          'accountingDimensions': voucherDimensions,
        'dimensionVersion': _toIntOrNull(originalVoucher['dimensionVersion']) ?? 1,
        'createdBy': postedByUserId,
        if (postedByName != null && postedByName.trim().isNotEmpty)
          'createdByName': postedByName.trim(),
        'createdAt': now,
        'updatedAt': now,
      },
      entries: reversedEntries,
      strictMode: strictMode,
    );
  }

  Future<void> _commitStrictBatch({
    required String voucherId,
    required Map<String, dynamic> voucherData,
    required List<Map<String, dynamic>> entries,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    final firestore = db;
    if (firestore == null) {
      throw StateError(
        'Strict accounting mode requires online Firestore connection',
      );
    }

    final batch = firestore.batch();

    if (strictBusinessWrite != null) {
      final businessRef = firestore
          .collection(strictBusinessWrite.collection)
          .doc(strictBusinessWrite.docId);
      batch.set(
        businessRef,
        strictBusinessWrite.data,
        SetOptions(merge: strictBusinessWrite.merge),
      );
    }

    final voucherRef = firestore.collection(vouchersCollection).doc(voucherId);
    batch.set(voucherRef, voucherData, SetOptions(merge: true));

    for (final entry in entries) {
      final entryId = entry['id'].toString();
      final entryRef = firestore
          .collection(voucherEntriesCollection)
          .doc(entryId);
      batch.set(entryRef, entry, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<Map<String, dynamic>?> _findExistingVoucher({
    required String transactionRefId,
    required String transactionType,
    required bool strictMode,
  }) async {
    if (_isIsarReady()) {
      // Check Isar first
      final existing = await dbService.vouchers
          .filter()
          .transactionRefIdEqualTo(transactionRefId)
          .findFirst();

      if (existing != null) {
        final vType = _normalizeType(existing.type);
        final txTypeNormalized = _normalizeType(transactionType);
        if (vType == txTypeNormalized) {
          return _voucherEntityToMap(existing);
        }
        if (existing.id == transactionRefId) {
          throw StateError(
            'Voucher ID collision for transactionRefId=$transactionRefId with conflicting transactionType.',
          );
        }
      }
    } else {
      final local = await _loadFallbackVouchers();
      Map<String, dynamic>? existingLocal;
      for (final voucher in local) {
        final refId = voucher['transactionRefId']?.toString().trim() ?? '';
        if (refId == transactionRefId) {
          existingLocal = voucher;
          break;
        }
      }

      if (existingLocal != null) {
        final localType = _normalizeType(
          existingLocal['transactionType'] ?? existingLocal['type'],
        );
        final txTypeNormalized = _normalizeType(transactionType);
        if (localType == txTypeNormalized) {
          return _stripFallbackVoucher(existingLocal);
        }
        if (existingLocal['id']?.toString() == transactionRefId) {
          throw StateError(
            'Voucher ID collision for transactionRefId=$transactionRefId with conflicting transactionType.',
          );
        }
      }
    }

    if (!strictMode) {
      return null;
    }

    final firestore = db;
    if (firestore == null) return null;

    final snapshot = await firestore
        .collection(vouchersCollection)
        .doc(transactionRefId)
        .get();
    if (!snapshot.exists) return null;

    final remote = snapshot.data() ?? <String, dynamic>{};
    final txTypeNormalized = _normalizeType(transactionType);
    final remoteType = _normalizeType(remote['transactionType']);
    if (remoteType.isNotEmpty && remoteType != txTypeNormalized) {
      throw StateError(
        'Remote voucher collision for transactionRefId=$transactionRefId with conflicting transactionType.',
      );
    }
    final resolved = <String, dynamic>{...remote, 'id': snapshot.id};

    if (_isIsarReady()) {
      // Cache to Isar logic can be inline
      final entity = _mapToVoucherEntity(resolved);
      await dbService.db.writeTxn(() async {
        await dbService.vouchers.put(entity);
      });
    } else {
      final local = await _loadFallbackVouchers();
      local.removeWhere((item) => item['id']?.toString() == snapshot.id);
      local.add(resolved);
      await _saveFallbackVouchers(local);
    }

    return resolved;
  }

  Future<Map<String, dynamic>?> _loadVoucherById(
    String voucherId, {
    required bool includeRemote,
  }) async {
    final targetId = voucherId.trim();
    if (targetId.isEmpty) return null;

    if (_isIsarReady()) {
      final entity = await dbService.vouchers.filter().idEqualTo(targetId).findFirst();
      if (entity != null) {
        return _voucherEntityToMap(entity);
      }
    } else {
      final local = await _loadFallbackVouchers();
      for (final item in local) {
        if (item['id']?.toString() == targetId) {
          return _stripFallbackVoucher(item);
        }
      }
    }

    if (!includeRemote) return null;

    final firestore = db;
    if (firestore == null) return null;
    final snapshot = await firestore.collection(vouchersCollection).doc(targetId).get();
    if (!snapshot.exists) return null;
    final resolved = <String, dynamic>{
      ...(snapshot.data() ?? const <String, dynamic>{}),
      'id': snapshot.id,
    };
    if (_isIsarReady()) {
      await dbService.db.writeTxn(() async {
        await dbService.vouchers.put(_mapToVoucherEntity(resolved));
      });
    }
    return resolved;
  }

  Future<List<Map<String, dynamic>>> _loadEntriesByVoucherId(
    String voucherId, {
    required bool includeRemote,
  }) async {
    final targetId = voucherId.trim();
    if (targetId.isEmpty) return const <Map<String, dynamic>>[];

    if (_isIsarReady()) {
      final entities = await dbService.voucherEntries
          .filter()
          .voucherIdEqualTo(targetId)
          .findAll();
      if (entities.isNotEmpty) {
        return entities.map(_entryEntityToMap).toList(growable: false);
      }
    } else {
      final localEntries = (await _loadFallbackVouchers())
          .expand(_fallbackEntriesFromVoucher)
          .where((entry) => entry['voucherId']?.toString() == targetId)
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(growable: false);
      if (localEntries.isNotEmpty) {
        return localEntries;
      }
    }

    if (!includeRemote) return const <Map<String, dynamic>>[];

    final firestore = db;
    if (firestore == null) return const <Map<String, dynamic>>[];
    final snapshot = await firestore
        .collection(voucherEntriesCollection)
        .where('voucherId', isEqualTo: targetId)
        .get();
    if (snapshot.docs.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final remoteEntries = snapshot.docs
        .map(
          (doc) => <String, dynamic>{
            ...(doc.data()),
            'id': doc.id,
          },
        )
        .toList(growable: false);

    if (_isIsarReady()) {
      final entities = remoteEntries.map(_mapToEntryEntity).toList(growable: false);
      await dbService.db.writeTxn(() async {
        await dbService.voucherEntries.putAll(entities);
      });
    }

    return remoteEntries;
  }

  String _normalizeType(dynamic value) {
    if (value == null) return '';
    return value.toString().trim().toLowerCase();
  }

  Future<void> updateVoucherEntry({
    required String entryId,
    required Map<String, dynamic> updates,
    required bool strictMode,
  }) async {
    final blockedEntryId = entryId.trim();
    if (blockedEntryId.isEmpty) {
      throw ArgumentError('entryId is required');
    }
    throw UnsupportedError(
      'Voucher entries are financially immutable. Use PostingService.createVoucherReversal(...) instead of updateVoucherEntry '
      '(entryId=$blockedEntryId, strictMode=$strictMode, fields=${updates.keys.join(',')}).',
    );
  }

  Future<bool> voucherNumberExists(
    String voucherNumber, {
    bool includeRemote = true,
  }) async {
    final target = voucherNumber.trim();
    if (target.isEmpty) return false;

    // Isar check (Assuming voucherNumber is indexed now)
    final existing = await dbService.vouchers
        .filter()
        .voucherNumberEqualTo(target)
        .findFirst();
    if (existing != null) return true;

    if (!includeRemote) return false;
    final firestore = db;
    if (firestore == null) return false;
    final snapshot = await firestore
        .collection(vouchersCollection)
        .where('voucherNumber', isEqualTo: target)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<Map<String, double>> getDashboardMetrics() async {
    try {
      // Cash
      final cashEntries = await dbService.voucherEntries
          .filter()
          .accountCodeEqualTo('CASH_IN_HAND')
          .findAll();
      final cashBalance = cashEntries.fold<double>(
        0,
        (total, e) => total + (e.debit - e.credit),
      );

      // Bank (Starts with BANK)
      final bankEntries = await dbService.voucherEntries
          .filter()
          .accountCodeStartsWith('BANK')
          .findAll();
      final bankBalance = bankEntries.fold<double>(
        0,
        (total, e) => total + (e.debit - e.credit),
      );

      // Debtors
      final debtorEntries = await dbService.voucherEntries
          .filter()
          .accountCodeEqualTo('SUNDRY_DEBTORS')
          .findAll();
      final receivables = debtorEntries.fold<double>(
        0,
        (total, e) => total + (e.debit - e.credit),
      );

      // Creditors
      final creditorEntries = await dbService.voucherEntries
          .filter()
          .accountCodeEqualTo('SUNDRY_CREDITORS')
          .findAll();
      final payables = creditorEntries.fold<double>(
        0,
        (total, e) =>
            total +
            (e.credit - e.debit), // Credit balance is positive for liability
      );

      // Output GST
      final outputGstEntries = await dbService.voucherEntries
          .filter()
          .accountCodeStartsWith('OUTPUT_')
          .findAll();
      final outputGst = outputGstEntries.fold<double>(
        0,
        (total, e) => total + (e.credit - e.debit),
      );

      // Input GST
      final inputGstEntries = await dbService.voucherEntries
          .filter()
          .accountCodeStartsWith('INPUT_')
          .findAll();
      final inputGst = inputGstEntries.fold<double>(
        0,
        (total, e) => total + (e.debit - e.credit),
      );

      return {
        'cash': cashBalance,
        'bank': bankBalance,
        'receivables': receivables,
        'payables': payables,
        'outputGst': outputGst,
        'inputGst': inputGst,
      };
    } catch (e) {
      handleError(e, 'getDashboardMetrics');
      return {
        'cash': 0,
        'bank': 0,
        'receivables': 0,
        'payables': 0,
        'outputGst': 0,
        'inputGst': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getLedgerEntries({
    required String accountCode,
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final entries = await dbService.voucherEntries
          .filter()
          .accountCodeEqualTo(accountCode)
          .sortByDateDesc()
          .offset(offset)
          .limit(limit)
          .findAll();
      return entries.map((e) => _entryEntityToMap(e)).toList();
    } catch (e) {
      handleError(e, 'getLedgerEntries');
      return [];
    }
  }

  Future<double> getAccountBalance(String accountCode) async {
    try {
      final entries = await dbService.voucherEntries
          .filter()
          .accountCodeEqualTo(accountCode)
          .findAll();
      return entries.fold<double>(
        0,
        (total, e) => total + (e.debit - e.credit),
      );
    } catch (e) {
      handleError(e, 'getAccountBalance');
      return 0.0;
    }
  }
}
