import 'dart:convert';

import 'package:isar/isar.dart';

import '../../core/firebase/firebase_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/voucher_entity.dart';
import '../../data/local/entities/voucher_entry_entity.dart';
import '../../services/database_service.dart';
import '../../services/offline_first_service.dart';
import '../../utils/app_logger.dart';

const String vouchersCollection = CollectionRegistry.vouchers;
const String voucherEntriesCollection = CollectionRegistry.voucherEntries;

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
  VoucherRepository(
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
    final nested = _decodeRawDimensions(
      map['accountingDimensions'] ?? map['accountingDimensionsJson'],
    );

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

  Map<String, dynamic> _voucherEntityToMap(VoucherEntity entity) {
    final data = Map<String, dynamic>.from(entity.toJson());
    final dimensions = _decodeAccountingDimensionsJson(
      entity.accountingDimensionsJson,
    );
    if (dimensions.isNotEmpty) {
      data['accountingDimensions'] = dimensions;
    }
    data['transactionType'] = entity.type;
    data['voucherType'] = entity.voucherType ?? entity.type;
    return data;
  }

  Map<String, dynamic> _entryEntityToMap(VoucherEntryEntity entity) {
    final data = Map<String, dynamic>.from(entity.toJson());
    final dimensions = _decodeAccountingDimensionsJson(
      entity.accountingDimensionsJson,
    );
    if (dimensions.isNotEmpty) {
      data['accountingDimensions'] = dimensions;
    }
    data['ledgerId'] = entity.accountCode;
    data['postingDate'] = entity.date?.toIso8601String();
    return data;
  }

  Future<List<Map<String, dynamic>>> getVouchers({
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final vouchers = await getAllVouchers();
      final safeOffset = offset < 0 ? 0 : offset;
      final safeLimit = limit <= 0 ? vouchers.length : limit;
      return vouchers
          .skip(safeOffset)
          .take(safeLimit)
          .map(_voucherEntityToMap)
          .toList(growable: false);
    } catch (error) {
      handleError(error, 'getVouchers');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> getVoucherEntries({
    DateTime? fromDate,
    DateTime? toDate,
    int offset = 0,
    int limit = 100,
  }) async {
    try {
      var query = dbService.voucherEntries.filter().isDeletedEqualTo(false);
      if (fromDate != null && toDate != null) {
        query = query.and().dateBetween(
          fromDate,
          toDate,
          includeLower: true,
          includeUpper: true,
        );
      } else if (fromDate != null) {
        query = query.and().dateGreaterThan(fromDate, include: true);
      } else if (toDate != null) {
        query = query.and().dateLessThan(toDate, include: true);
      }

      final entries = await query
          .sortByDateDesc()
          .offset(offset < 0 ? 0 : offset)
          .limit(limit <= 0 ? 100000 : limit)
          .findAll();
      return entries.map(_entryEntityToMap).toList(growable: false);
    } catch (error) {
      handleError(error, 'getVoucherEntries');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<void> saveVoucher(VoucherEntity voucher) async {
    await _persistVoucherWithEntries(voucher, const <VoucherEntryEntity>[]);
  }

  Future<void> saveVoucherEntries(List<VoucherEntryEntity> entries) async {
    if (entries.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final preparedEntries = <VoucherEntryEntity>[];
    final operations = <Map<String, String>>[];

    for (final entry in entries) {
      final existing = await dbService.voucherEntries.getById(entry.id.trim());
      final prepared = _prepareEntryForSave(
        entry,
        now: now,
        deviceId: deviceId,
        existing: existing,
      );
      preparedEntries.add(prepared);
      operations.add({
        'documentId': prepared.id,
        'operation': existing == null ? 'create' : 'update',
      });
    }

    await dbService.db.writeTxn(() async {
      await dbService.voucherEntries.putAll(preparedEntries);
    });

    for (var i = 0; i < preparedEntries.length; i++) {
      await _syncQueueService.addToQueue(
        collectionName: voucherEntriesCollection,
        documentId: operations[i]['documentId']!,
        operation: operations[i]['operation']!,
        payload: preparedEntries[i].toJson(),
      );
    }

    await _syncIfOnline();
  }

  Future<void> saveVoucherWithEntries(
    VoucherEntity voucher,
    List<VoucherEntryEntity> entries,
  ) async {
    await _persistVoucherWithEntries(voucher, entries);
  }

  Future<VoucherEntity?> getVoucherById(String id) {
    return dbService.vouchers
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<VoucherEntity>> getAllVouchers() {
    return dbService.vouchers
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<VoucherEntity>> getVouchersByType(String type) {
    return dbService.vouchers
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .typeEqualTo(type)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<VoucherEntity>> getVouchersByDate(DateTime from, DateTime to) {
    return dbService.vouchers
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .dateBetween(from, to, includeLower: true, includeUpper: true)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<VoucherEntity>> getVouchersBySalesman(String salesmanId) {
    return dbService.vouchers
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .salesmanIdEqualTo(salesmanId)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<VoucherEntryEntity>> getEntriesByVoucher(String voucherId) {
    return dbService.voucherEntries
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .voucherIdEqualTo(voucherId)
        .sortByDateDesc()
        .findAll();
  }

  Stream<List<VoucherEntity>> watchAllVouchers() {
    return dbService.vouchers
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<VoucherEntryEntity>> watchEntriesByVoucher(String voucherId) {
    return dbService.voucherEntries
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .voucherIdEqualTo(voucherId)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  Future<void> cancelVoucher(String id, String reason) async {
    final voucher = await getVoucherById(id);
    if (voucher == null) {
      return;
    }

    final now = DateTime.now();
    voucher
      ..status = 'cancelled'
      ..cancelReason = reason.trim()
      ..cancelledAt = now;

    await _persistVoucherWithEntries(voucher, const <VoucherEntryEntity>[]);
  }

  Future<void> deleteVoucher(String id) async {
    final voucher = await getVoucherById(id);
    if (voucher == null) {
      return;
    }

    final entries = await getEntriesByVoucher(id);
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();

    voucher
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = deviceId;

    final deletedEntries = <VoucherEntryEntity>[];
    for (final entry in entries) {
      entry
        ..isDeleted = true
        ..deletedAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending
        ..isSynced = false
        ..lastSynced = null
        ..version += 1
        ..deviceId = deviceId;
      deletedEntries.add(entry);
    }

    await dbService.db.writeTxn(() async {
      await dbService.vouchers.put(voucher);
      if (deletedEntries.isNotEmpty) {
        await dbService.voucherEntries.putAll(deletedEntries);
      }
    });

    await _syncQueueService.addToQueue(
      collectionName: vouchersCollection,
      documentId: voucher.id,
      operation: 'delete',
      payload: voucher.toJson(),
    );

    for (final entry in deletedEntries) {
      await _syncQueueService.addToQueue(
        collectionName: voucherEntriesCollection,
        documentId: entry.id,
        operation: 'delete',
        payload: entry.toJson(),
      );
    }

    await _syncIfOnline();
  }

  Future<void> deleteVoucherEntry(String id) async {
    final entry = await dbService.voucherEntries
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (entry == null) {
      return;
    }

    final now = DateTime.now();
    entry
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await dbService.db.writeTxn(() async {
      await dbService.voucherEntries.put(entry);
    });

    await _syncQueueService.addToQueue(
      collectionName: voucherEntriesCollection,
      documentId: entry.id,
      operation: 'delete',
      payload: entry.toJson(),
    );

    await _syncIfOnline();
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
      return existing['id']?.toString() ?? transactionRefId;
    }

    final now = DateTime.now();
    final postingDate =
        DateTime.tryParse((voucher['date'] ?? now.toIso8601String()).toString()) ??
        now;
    final voucherId = transactionRefId;
    final normalizedVoucherType = (voucher['voucherType'] ?? transactionType)
        .toString()
        .trim()
        .toLowerCase();

    final entryEntities = <VoucherEntryEntity>[];
    double totalDebit = 0;
    double totalCredit = 0;

    for (final raw in entries) {
      final debit = _toDouble(raw['debit']);
      final credit = _toDouble(raw['credit']);
      if (debit <= 0 && credit <= 0) {
        continue;
      }

      final accountCode = (raw['ledgerId'] ?? raw['accountCode'])
          .toString()
          .trim();
      if (accountCode.isEmpty) {
        throw ArgumentError('Voucher entry accountCode is required');
      }

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
            .trim()
        ..voucherId = voucherId
        ..accountCode = accountCode
        ..debit = debit
        ..credit = credit
        ..narration = (raw['narration'] ?? '').toString().trim()
        ..date = postingDate
        ..voucherType = normalizedVoucherType
        ..transactionType = transactionType
        ..transactionRefId = transactionRefId
        ..createdAt =
            DateTime.tryParse(
              (raw['createdAt'] ?? now.toIso8601String()).toString(),
            ) ??
            now;
      _applyDimensionsToEntryEntity(
        entryEntity,
        entryDimensions,
        dimensionVersion: entryDimensionVersion,
      );
      entryEntities.add(entryEntity);
    }

    if (entryEntities.isEmpty) {
      throw ArgumentError('At least one debit/credit entry is required');
    }

    if ((totalDebit - totalCredit).abs() > 0.01) {
      throw StateError(
        'Voucher is not balanced. Debit=$totalDebit Credit=$totalCredit',
      );
    }

    final voucherDimensions = _extractAccountingDimensions(voucher);
    final voucherEntity = VoucherEntity()
      ..id = voucherId
      ..transactionRefId = transactionRefId
      ..date = postingDate
      ..type = transactionType
      ..narration = (voucher['narration'] ?? '').toString().trim()
      ..amount = totalDebit
      ..linkedId = voucher['linkedId']?.toString()
      ..partyName = voucher['partyName']?.toString()
      ..voucherNumber = voucher['voucherNumber']?.toString()
      ..status = (voucher['status'] ?? 'active').toString().trim()
      ..cancelReason = voucher['cancelReason']?.toString()
      ..cancelledAt = voucher['cancelledAt'] == null
          ? null
          : DateTime.tryParse(voucher['cancelledAt'].toString())
      ..voucherType = normalizedVoucherType
      ..sourceModule = voucher['sourceModule']?.toString()
      ..sourceId = voucher['sourceId']?.toString()
      ..sourceNumber = voucher['sourceNumber']?.toString()
      ..financialYearId = voucher['financialYearId']?.toString()
      ..partyId = voucher['partyId']?.toString()
      ..createdBy = voucher['createdBy']?.toString()
      ..createdByName = voucher['createdByName']?.toString()
      ..createdAt =
          DateTime.tryParse(
            (voucher['createdAt'] ?? now.toIso8601String()).toString(),
          ) ??
          now
      ..reversalOfVoucherId = voucher['reversalOfVoucherId']?.toString()
      ..reversalReason = voucher['reversalReason']?.toString()
      ..totalDebit = totalDebit
      ..totalCredit = totalCredit
      ..isBalanced = true
      ..entryCount = entryEntities.length;
    _applyDimensionsToVoucherEntity(
      voucherEntity,
      voucherDimensions,
      dimensionVersion: voucher['dimensionVersion'],
    );

    await _persistVoucherWithEntries(
      voucherEntity,
      entryEntities,
      syncAfterSave: false,
    );

    if (strictBusinessWrite != null &&
        strictBusinessWrite.collection.trim().isNotEmpty &&
        strictBusinessWrite.docId.trim().isNotEmpty) {
      await _syncQueueService.addToQueue(
        collectionName: strictBusinessWrite.collection.trim(),
        documentId: strictBusinessWrite.docId.trim(),
        operation: 'update',
        payload: strictBusinessWrite.data,
      );
    }

    await _syncIfOnline();
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
        'date': effectiveDate.toIso8601String(),
        'postingDate': effectiveDate.toIso8601String(),
        'debit': credit,
        'credit': debit,
        'narration': reversalEntryNarration,
        ...entryDimensions,
        if (entryDimensions.isNotEmpty) 'accountingDimensions': entryDimensions,
        'dimensionVersion': entryDimensionVersion,
        'updatedAt': effectiveDate.toIso8601String(),
        'createdAt': effectiveDate.toIso8601String(),
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
        'date': effectiveDate.toIso8601String(),
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
        'createdAt': effectiveDate.toIso8601String(),
        'updatedAt': effectiveDate.toIso8601String(),
      },
      entries: reversedEntries,
      strictMode: strictMode,
    );
  }

  Future<Map<String, dynamic>?> _findExistingVoucher({
    required String transactionRefId,
    required String transactionType,
    required bool strictMode,
  }) async {
    final existing = await dbService.vouchers
        .filter()
        .transactionRefIdEqualTo(transactionRefId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (existing == null) {
      return null;
    }

    final localType = _normalizeType(existing.type);
    final normalizedType = _normalizeType(transactionType);
    if (localType == normalizedType) {
      return _voucherEntityToMap(existing);
    }

    if (existing.id == transactionRefId) {
      throw StateError(
        'Voucher ID collision for transactionRefId=$transactionRefId with conflicting transactionType.',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> _loadVoucherById(
    String voucherId, {
    required bool includeRemote,
  }) async {
    final entity = await dbService.vouchers
        .filter()
        .idEqualTo(voucherId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    return entity == null ? null : _voucherEntityToMap(entity);
  }

  Future<List<Map<String, dynamic>>> _loadEntriesByVoucherId(
    String voucherId, {
    required bool includeRemote,
  }) async {
    final entities = await dbService.voucherEntries
        .filter()
        .voucherIdEqualTo(voucherId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return entities.map(_entryEntityToMap).toList(growable: false);
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
    if (target.isEmpty) {
      return false;
    }
    final existing = await dbService.vouchers
        .filter()
        .voucherNumberEqualTo(target)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    return existing != null;
  }

  Future<Map<String, double>> getDashboardMetrics() async {
    try {
      final cashEntries = await dbService.voucherEntries
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .accountCodeEqualTo('CASH_IN_HAND')
          .findAll();
      final cashBalance = cashEntries.fold<double>(
        0,
        (total, entry) => total + (entry.debit - entry.credit),
      );

      final bankEntries = await dbService.voucherEntries
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .accountCodeStartsWith('BANK')
          .findAll();
      final bankBalance = bankEntries.fold<double>(
        0,
        (total, entry) => total + (entry.debit - entry.credit),
      );

      final debtorEntries = await dbService.voucherEntries
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .accountCodeEqualTo('SUNDRY_DEBTORS')
          .findAll();
      final receivables = debtorEntries.fold<double>(
        0,
        (total, entry) => total + (entry.debit - entry.credit),
      );

      final creditorEntries = await dbService.voucherEntries
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .accountCodeEqualTo('SUNDRY_CREDITORS')
          .findAll();
      final payables = creditorEntries.fold<double>(
        0,
        (total, entry) => total + (entry.credit - entry.debit),
      );

      final outputGstEntries = await dbService.voucherEntries
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .accountCodeStartsWith('OUTPUT_')
          .findAll();
      final outputGst = outputGstEntries.fold<double>(
        0,
        (total, entry) => total + (entry.credit - entry.debit),
      );

      final inputGstEntries = await dbService.voucherEntries
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .accountCodeStartsWith('INPUT_')
          .findAll();
      final inputGst = inputGstEntries.fold<double>(
        0,
        (total, entry) => total + (entry.debit - entry.credit),
      );

      return {
        'cash': cashBalance,
        'bank': bankBalance,
        'receivables': receivables,
        'payables': payables,
        'outputGst': outputGst,
        'inputGst': inputGst,
      };
    } catch (error) {
      handleError(error, 'getDashboardMetrics');
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
          .isDeletedEqualTo(false)
          .and()
          .accountCodeEqualTo(accountCode)
          .sortByDateDesc()
          .offset(offset < 0 ? 0 : offset)
          .limit(limit <= 0 ? 100000 : limit)
          .findAll();
      return entries.map(_entryEntityToMap).toList(growable: false);
    } catch (error) {
      handleError(error, 'getLedgerEntries');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<double> getAccountBalance(String accountCode) async {
    try {
      final entries = await dbService.voucherEntries
          .filter()
          .isDeletedEqualTo(false)
          .and()
          .accountCodeEqualTo(accountCode)
          .findAll();
      return entries.fold<double>(
        0,
        (total, entry) => total + (entry.debit - entry.credit),
      );
    } catch (error) {
      handleError(error, 'getAccountBalance');
      return 0.0;
    }
  }

  Future<void> _persistVoucherWithEntries(
    VoucherEntity voucher,
    List<VoucherEntryEntity> entries, {
    bool syncAfterSave = true,
  }) async {
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final existingVoucher = await dbService.vouchers.getById(voucher.id.trim());
    final preparedVoucher = _prepareVoucherForSave(
      voucher,
      now: now,
      deviceId: deviceId,
      existing: existingVoucher,
    );

    final preparedEntries = <VoucherEntryEntity>[];
    final entryOperations = <Map<String, String>>[];
    for (final entry in entries) {
      final existingEntry = await dbService.voucherEntries.getById(entry.id.trim());
      final preparedEntry = _prepareEntryForSave(
        entry,
        now: now,
        deviceId: deviceId,
        existing: existingEntry,
      );
      preparedEntries.add(preparedEntry);
      entryOperations.add({
        'documentId': preparedEntry.id,
        'operation': existingEntry == null ? 'create' : 'update',
      });
    }

    await dbService.db.writeTxn(() async {
      await dbService.vouchers.put(preparedVoucher);
      if (preparedEntries.isNotEmpty) {
        await dbService.voucherEntries.putAll(preparedEntries);
      }
    });

    await _syncQueueService.addToQueue(
      collectionName: vouchersCollection,
      documentId: preparedVoucher.id,
      operation: existingVoucher == null ? 'create' : 'update',
      payload: preparedVoucher.toJson(),
    );

    for (var i = 0; i < preparedEntries.length; i++) {
      await _syncQueueService.addToQueue(
        collectionName: voucherEntriesCollection,
        documentId: entryOperations[i]['documentId']!,
        operation: entryOperations[i]['operation']!,
        payload: preparedEntries[i].toJson(),
      );
    }

    if (syncAfterSave) {
      await _syncIfOnline();
    }
  }

  VoucherEntity _prepareVoucherForSave(
    VoucherEntity voucher, {
    required DateTime now,
    required String deviceId,
    required VoucherEntity? existing,
  }) {
    final normalizedId = voucher.id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('Voucher id is required');
    }

    final normalizedType = _normalizeType(voucher.type);
    if (normalizedType.isEmpty) {
      throw ArgumentError('Voucher type is required');
    }

    voucher
      ..id = normalizedId
      ..transactionRefId = voucher.transactionRefId.trim().isEmpty
          ? normalizedId
          : voucher.transactionRefId.trim()
      ..type = normalizedType
      ..narration = voucher.narration.trim()
      ..voucherType = (voucher.voucherType ?? normalizedType).trim().isEmpty
          ? normalizedType
          : voucher.voucherType!.trim().toLowerCase()
      ..status = voucher.status.trim().isEmpty ? 'active' : voucher.status.trim()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    voucher.createdAt ??= existing?.createdAt ?? now;
    if (!voucher.isDeleted) {
      voucher.deletedAt = existing?.deletedAt;
    }
    return voucher;
  }

  VoucherEntryEntity _prepareEntryForSave(
    VoucherEntryEntity entry, {
    required DateTime now,
    required String deviceId,
    required VoucherEntryEntity? existing,
  }) {
    final normalizedId = entry.id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('Voucher entry id is required');
    }
    final voucherId = entry.voucherId.trim();
    if (voucherId.isEmpty) {
      throw ArgumentError('Voucher entry voucherId is required');
    }
    final accountCode = entry.accountCode.trim();
    if (accountCode.isEmpty) {
      throw ArgumentError('Voucher entry accountCode is required');
    }

    entry
      ..id = normalizedId
      ..voucherId = voucherId
      ..accountCode = accountCode
      ..voucherType = (entry.voucherType ?? '').trim().isEmpty
          ? null
          : entry.voucherType!.trim().toLowerCase()
      ..transactionType = (entry.transactionType ?? '').trim().isEmpty
          ? null
          : entry.transactionType!.trim().toLowerCase()
      ..transactionRefId = (entry.transactionRefId ?? '').trim().isEmpty
          ? null
          : entry.transactionRefId!.trim()
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    entry.date ??= now;
    entry.createdAt ??= existing?.createdAt ?? now;
    if (!entry.isDeleted) {
      entry.deletedAt = existing?.deletedAt;
    }
    return entry;
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
