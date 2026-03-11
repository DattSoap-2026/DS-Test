import 'package:isar/isar.dart' hide Query;

import '../../constants/maharashtra_zones.dart';
import '../../data/local/entities/sale_entity.dart';
import '../../data/local/entities/voucher_entity.dart';
import '../../data/local/entities/voucher_entry_entity.dart';
import '../../data/local/entities/customer_entity.dart';
import '../../data/local/entities/dealer_entity.dart';
import '../../data/local/entities/route_entity.dart';
import '../../data/local/base_entity.dart';
import '../../utils/app_logger.dart';
import '../database_service.dart';

class RouteAccountingContext {
  final String route;
  final String district;
  final String division;

  const RouteAccountingContext({
    required this.route,
    required this.district,
    required this.division,
  });
}

typedef SyncToFirebaseCallback =
    Future<void> Function(
      String action,
      Map<String, dynamic> payload, {
      String? collectionName,
      bool syncImmediately,
    });

typedef BulkSyncToFirebaseCallback =
    Future<void> Function(
      String action,
      List<Map<String, dynamic>> payloads, {
      String? collectionName,
    });

class SalesAccountingDelegate {
  static const int _salesPageSize = 500;
  static const int _isarAnyOfChunkSize = 400;
  final DatabaseService _dbService;
  final SyncToFirebaseCallback _syncToFirebase;
  final BulkSyncToFirebaseCallback _bulkSyncToFirebase;

  SalesAccountingDelegate(
    this._dbService,
    this._syncToFirebase,
    this._bulkSyncToFirebase,
  );

  Future<List<SaleEntity>> _fetchAllSalesPaged() async {
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

  String sanitizeDimensionValue(dynamic value, {int maxLength = 96}) {
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

  String formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String firstNonEmpty(List<dynamic> values, {int maxLength = 96}) {
    for (final value in values) {
      final sanitized = sanitizeDimensionValue(value, maxLength: maxLength);
      if (sanitized.isNotEmpty) {
        return sanitized;
      }
    }
    return '';
  }

  String extractDistrictFromText(String source) {
    final cleaned = sanitizeDimensionValue(source);
    if (cleaned.isEmpty) return '';

    if (MaharashtraZones.getZoneForDistrict(cleaned) != null) {
      return cleaned;
    }

    final parts = cleaned.split(',');
    for (final part in parts) {
      final trimmed = sanitizeDimensionValue(part);
      if (trimmed.isEmpty) continue;
      if (MaharashtraZones.getZoneForDistrict(trimmed) != null) {
        return trimmed;
      }
    }
    return cleaned;
  }

  Future<RouteAccountingContext> resolveRouteAccountingContext(
    String routeHint, [
    Map<String, RouteEntity>? routeLookup,
  ]) async {
    final cleanRouteHint = sanitizeDimensionValue(routeHint);
    if (cleanRouteHint.isEmpty) {
      return const RouteAccountingContext(
        route: '',
        district: '',
        division: '',
      );
    }

    RouteEntity? routeEntity;
    if (routeLookup == null) {
      routeEntity = await _dbService.routes
              .filter()
              .nameEqualTo(cleanRouteHint)
              .findFirst() ??
          await _dbService.routes
              .filter()
              .idEqualTo(cleanRouteHint)
              .findFirst();
    } else {
      routeEntity = routeLookup[cleanRouteHint];
    }

    if (routeEntity == null) {
      return RouteAccountingContext(
        route: cleanRouteHint,
        district: '',
        division: '',
      );
    }

    final routeName = sanitizeDimensionValue(routeEntity.name);
    final district = extractDistrictFromText(routeEntity.description ?? '');
    final zone = district.isEmpty
        ? null
        : MaharashtraZones.getZoneForDistrict(district);
    final division = zone == null ? '' : sanitizeDimensionValue(zone);

    return RouteAccountingContext(
      route: routeName.isNotEmpty ? routeName : cleanRouteHint,
      district: district,
      division: division,
    );
  }

  Future<Map<String, dynamic>> resolveAccountingDimensions({
    required String recipientType,
    required String recipientId,
    required String recipientName,
    required String salesmanId,
    required String salesmanName,
    required DateTime saleDate,
    String? explicitRoute,
    Map<String, DealerEntity>? dealersById,
    Map<String, CustomerEntity>? customersById,
    Map<String, RouteEntity>? routeLookup,
  }) async {
    final normalizedRecipientType = recipientType.trim().toLowerCase();
    final normalizedRecipientId = sanitizeDimensionValue(recipientId);
    final normalizedRecipientName = sanitizeDimensionValue(recipientName);
    final normalizedSalesmanId = sanitizeDimensionValue(salesmanId);
    final normalizedSalesmanName = sanitizeDimensionValue(salesmanName);

    var route = sanitizeDimensionValue(explicitRoute);
    var district = '';
    var division = '';
    var dealerId = '';
    var dealerName = '';

    if (normalizedRecipientType == 'dealer') {
      dealerId = normalizedRecipientId;
      dealerName = normalizedRecipientName;

      final dealer =
          dealersById == null
          ? await _dbService.dealers
                .filter()
                .idEqualTo(normalizedRecipientId)
                .findFirst()
          : dealersById[normalizedRecipientId];
      if (dealer != null) {
        if (route.isEmpty) {
          route = sanitizeDimensionValue(dealer.assignedRouteName);
        }
        district = sanitizeDimensionValue(dealer.territory);
        if (district.isEmpty) {
          district = sanitizeDimensionValue(dealer.city);
        }
      }
    } else if (normalizedRecipientType == 'customer') {
      final customer =
          customersById == null
          ? await _dbService.customers
                .filter()
                .idEqualTo(normalizedRecipientId)
                .findFirst()
          : customersById[normalizedRecipientId];
      if (customer != null) {
        if (route.isEmpty) {
          route = sanitizeDimensionValue(customer.route);
        }
        try {
          final customerCity = customer.toDomain().city;
          if (district.isEmpty) {
            district = sanitizeDimensionValue(customerCity);
          }
        } catch (_) {
          // Best-effort dimensions should not block sale creation.
        }
      }
    }

    final routeContext = await resolveRouteAccountingContext(route, routeLookup);
    if (route.isEmpty) route = routeContext.route;
    if (district.isEmpty) district = routeContext.district;
    if (division.isEmpty) division = routeContext.division;

    if (division.isEmpty && district.isNotEmpty) {
      division = sanitizeDimensionValue(
        MaharashtraZones.getZoneForDistrict(district),
      );
    }

    return <String, dynamic>{
      'saleDate': formatDateOnly(saleDate),
      if (normalizedSalesmanId.isNotEmpty) 'salesmanId': normalizedSalesmanId,
      if (normalizedSalesmanName.isNotEmpty)
        'salesmanName': normalizedSalesmanName,
      if (route.isNotEmpty) 'route': route,
      if (district.isNotEmpty) 'district': district,
      if (division.isNotEmpty) 'division': division,
      if (dealerId.isNotEmpty) 'dealerId': dealerId,
      if (dealerName.isNotEmpty) 'dealerName': dealerName,
    };
  }

  Map<String, dynamic> flattenAccountingDimensions(
    Map<String, dynamic> dimensions,
  ) {
    final route = sanitizeDimensionValue(dimensions['route']);
    final district = sanitizeDimensionValue(dimensions['district']);
    final division = sanitizeDimensionValue(dimensions['division']);
    final salesmanId = sanitizeDimensionValue(dimensions['salesmanId']);
    final salesmanName = sanitizeDimensionValue(dimensions['salesmanName']);
    final saleDate = sanitizeDimensionValue(dimensions['saleDate']);
    final dealerId = sanitizeDimensionValue(dimensions['dealerId']);
    final dealerName = sanitizeDimensionValue(dimensions['dealerName']);

    return <String, dynamic>{
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

  String dimensionNarrationTag(Map<String, dynamic> dimensions) {
    final flat = flattenAccountingDimensions(dimensions);
    final tags = <String>[];

    void append(String key, String label) {
      final value = sanitizeDimensionValue(flat[key], maxLength: 64);
      if (value.isNotEmpty) {
        tags.add('$label:$value');
      }
    }

    append('route', 'Route');
    append('district', 'District');
    append('division', 'Division');
    append('salesmanName', 'Salesman');
    append('saleDate', 'Date');
    append('dealerName', 'Dealer');

    return tags.join(' | ');
  }

  String buildBackfillVoucherNarration({
    required String recipientName,
    required Map<String, dynamic> dimensions,
  }) {
    final safeRecipient = sanitizeDimensionValue(recipientName, maxLength: 80);
    final base = safeRecipient.isEmpty
        ? 'Auto-posted sale voucher'
        : 'Auto-posted sale voucher for $safeRecipient';
    final tag = dimensionNarrationTag(dimensions);
    if (tag.isEmpty) return base;
    return '$base [$tag]';
  }

  String buildBackfillEntryNarration({
    required String accountCode,
    required String recipientName,
    required Map<String, dynamic> dimensions,
  }) {
    final safeCode = sanitizeDimensionValue(accountCode, maxLength: 48);
    final safeRecipient = sanitizeDimensionValue(recipientName, maxLength: 80);
    final base = safeRecipient.isEmpty
        ? 'Auto Sales Entry - $safeCode'
        : 'Auto Sales Entry - $safeCode for $safeRecipient';
    final tag = dimensionNarrationTag(dimensions);
    if (tag.isEmpty) return base;
    return '$base [$tag]';
  }

  Future<void> syncBackfillPayloads({
    required String collection,
    required List<Map<String, dynamic>> payloads,
    required bool syncImmediately,
  }) async {
    if (payloads.isEmpty) return;

    if (syncImmediately) {
      for (final payload in payloads) {
        await _syncToFirebase(
          'update',
          payload,
          collectionName: collection,
          syncImmediately: true,
        );
      }
      return;
    }

    await _bulkSyncToFirebase('update', payloads, collectionName: collection);
  }

  Future<Map<String, int>> backfillHistoricalAccountingDimensions({
    bool dryRun = false,
    bool syncImmediately = false,
    int? limit,
    bool includeCancelled = false,
  }) async {
    final summary = <String, int>{
      'scannedSales': 0,
      'patchedSales': 0,
      'patchedVouchers': 0,
      'patchedEntries': 0,
      'updatedLocalSales': 0,
      'updatedLocalVouchers': 0,
      'updatedLocalEntries': 0,
      'queuedSales': 0,
      'queuedVouchers': 0,
      'queuedEntries': 0,
      'skippedSales': 0,
      'errors': 0,
    };

    final allSales = await _fetchAllSalesPaged();
    final orderedSales = [...allSales]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final selectedSales =
        (limit != null && limit > 0 && orderedSales.length > limit)
        ? orderedSales.take(limit).toList(growable: false)
        : orderedSales;

    final dealerIds = selectedSales
        .where((sale) => sale.recipientType.trim().toLowerCase() == 'dealer')
        .map((sale) => sanitizeDimensionValue(sale.recipientId))
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final customerIds = selectedSales
        .where((sale) => sale.recipientType.trim().toLowerCase() == 'customer')
        .map((sale) => sanitizeDimensionValue(sale.recipientId))
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final dealersById = await _loadDealersByIds(dealerIds);
    final customersById = await _loadCustomersByIds(customerIds);
    final routeHints = <String>{
      for (final sale in selectedSales) sanitizeDimensionValue(sale.route),
      for (final dealer in dealersById.values)
        sanitizeDimensionValue(dealer.assignedRouteName),
      for (final customer in customersById.values)
        sanitizeDimensionValue(customer.route),
    }..removeWhere((value) => value.isEmpty);
    final routeLookup = await _buildRouteLookup(routeHints);
    final vouchersBySaleId = await _loadVouchersBySaleIds(
      selectedSales.map((sale) => sale.id).toList(growable: false),
    );
    final entriesByVoucherId = await _loadVoucherEntriesByVoucherIds(
      vouchersBySaleId.values.map((v) => v.id).toList(growable: false),
    );

    final salesToUpdate = <SaleEntity>[];
    final vouchersToUpdate = <VoucherEntity>[];
    final entriesToUpdate = <VoucherEntryEntity>[];
    final salePatches = <Map<String, dynamic>>[];
    final voucherPatches = <Map<String, dynamic>>[];
    final entryPatches = <Map<String, dynamic>>[];

    for (final sale in selectedSales) {
      summary['scannedSales'] = (summary['scannedSales'] ?? 0) + 1;

      try {
        final saleStatus = (sale.status ?? '').trim().toLowerCase();
        if (!includeCancelled && saleStatus == 'cancelled') {
          summary['skippedSales'] = (summary['skippedSales'] ?? 0) + 1;
          continue;
        }

        final saleDate = DateTime.tryParse(sale.createdAt) ?? sale.updatedAt;
        final dimensions = await resolveAccountingDimensions(
          recipientType: sale.recipientType,
          recipientId: sale.recipientId,
          recipientName: sale.recipientName,
          salesmanId: sale.salesmanId,
          salesmanName: sale.salesmanName,
          saleDate: saleDate,
          explicitRoute: sale.route,
          dealersById: dealersById,
          customersById: customersById,
          routeLookup: routeLookup,
        );
        final flat = flattenAccountingDimensions(dimensions);
        if (flat.isEmpty) {
          summary['skippedSales'] = (summary['skippedSales'] ?? 0) + 1;
          continue;
        }

        final nowIso = DateTime.now().toIso8601String();
        final salesPatch = <String, dynamic>{
          'id': sale.id,
          'updatedAt': nowIso,
          ...flat,
          'accountingDimensions': flat,
          'dimensionVersion': 1,
        };
        salePatches.add(salesPatch);
        summary['patchedSales'] = (summary['patchedSales'] ?? 0) + 1;

        final resolvedRoute = sanitizeDimensionValue(flat['route']);
        final resolvedSalesmanId = sanitizeDimensionValue(flat['salesmanId']);
        final resolvedSalesmanName = sanitizeDimensionValue(
          flat['salesmanName'],
        );
        var localSaleChanged = false;
        if (resolvedRoute.isNotEmpty && sale.route != resolvedRoute) {
          sale.route = resolvedRoute;
          localSaleChanged = true;
        }
        if (resolvedSalesmanId.isNotEmpty &&
            sale.salesmanId != resolvedSalesmanId) {
          sale.salesmanId = resolvedSalesmanId;
          localSaleChanged = true;
        }
        if (resolvedSalesmanName.isNotEmpty &&
            sale.salesmanName != resolvedSalesmanName) {
          sale.salesmanName = resolvedSalesmanName;
          localSaleChanged = true;
        }
        if (localSaleChanged) {
          sale.updatedAt = DateTime.now();
          sale.syncStatus = SyncStatus.pending;
          salesToUpdate.add(sale);
          summary['updatedLocalSales'] =
              (summary['updatedLocalSales'] ?? 0) + 1;
        }

        final voucher = vouchersBySaleId[sale.id];
        if (voucher == null || voucher.type.trim().toLowerCase() != 'sales') {
          continue;
        }

        final voucherNarration = buildBackfillVoucherNarration(
          recipientName: sale.recipientName,
          dimensions: flat,
        );
        voucherPatches.add({
          'id': voucher.id,
          'updatedAt': nowIso,
          'narration': voucherNarration,
          ...flat,
          'accountingDimensions': flat,
          'dimensionVersion': 1,
        });
        summary['patchedVouchers'] = (summary['patchedVouchers'] ?? 0) + 1;

        if (voucher.narration != voucherNarration) {
          voucher.narration = voucherNarration;
          voucher.updatedAt = DateTime.now();
          voucher.syncStatus = SyncStatus.pending;
          vouchersToUpdate.add(voucher);
          summary['updatedLocalVouchers'] =
              (summary['updatedLocalVouchers'] ?? 0) + 1;
        }

        final entryEntities = entriesByVoucherId[voucher.id] ?? const [];
        for (final entry in entryEntities) {
          final entryNarration = buildBackfillEntryNarration(
            accountCode: entry.accountCode,
            recipientName: sale.recipientName,
            dimensions: flat,
          );
          entryPatches.add({
            'id': entry.id,
            'voucherId': entry.voucherId,
            'updatedAt': nowIso,
            'narration': entryNarration,
            ...flat,
            'accountingDimensions': flat,
            'dimensionVersion': 1,
          });
          summary['patchedEntries'] = (summary['patchedEntries'] ?? 0) + 1;

          if (entry.narration != entryNarration) {
            entry.narration = entryNarration;
            entry.updatedAt = DateTime.now();
            entry.syncStatus = SyncStatus.pending;
            entriesToUpdate.add(entry);
            summary['updatedLocalEntries'] =
                (summary['updatedLocalEntries'] ?? 0) + 1;
          }
        }
      } catch (e, stack) {
        summary['errors'] = (summary['errors'] ?? 0) + 1;
        AppLogger.warning(
          'Historical accounting backfill failed for sale ${sale.id}: $e',
          tag: 'Accounting',
        );
        AppLogger.debug(stack.toString(), tag: 'Accounting');
      }
    }

    if (dryRun) {
      summary['queuedSales'] = salePatches.length;
      summary['queuedVouchers'] = voucherPatches.length;
      summary['queuedEntries'] = entryPatches.length;
      return summary;
    }

    if (salesToUpdate.isNotEmpty ||
        vouchersToUpdate.isNotEmpty ||
        entriesToUpdate.isNotEmpty) {
      await _dbService.db.writeTxn(() async {
        if (salesToUpdate.isNotEmpty) {
          await _dbService.sales.putAll(salesToUpdate);
        }
        if (vouchersToUpdate.isNotEmpty) {
          await _dbService.vouchers.putAll(vouchersToUpdate);
        }
        if (entriesToUpdate.isNotEmpty) {
          await _dbService.voucherEntries.putAll(entriesToUpdate);
        }
      });
    }

    const salesCollection = 'sales';
    const vouchersCollection = 'vouchers';
    const voucherEntriesCollection = 'voucher_entries';

    await syncBackfillPayloads(
      collection: salesCollection,
      payloads: salePatches,
      syncImmediately: syncImmediately,
    );
    await syncBackfillPayloads(
      collection: vouchersCollection,
      payloads: voucherPatches,
      syncImmediately: syncImmediately,
    );
    await syncBackfillPayloads(
      collection: voucherEntriesCollection,
      payloads: entryPatches,
      syncImmediately: syncImmediately,
    );

    summary['queuedSales'] = salePatches.length;
    summary['queuedVouchers'] = voucherPatches.length;
    summary['queuedEntries'] = entryPatches.length;
    return summary;
  }

  Future<List<T>> _loadInChunks<T>(
    List<String> ids,
    Future<List<T>> Function(List<String> chunk) loader,
  ) async {
    if (ids.isEmpty) return <T>[];
    final results = <T>[];
    for (var i = 0; i < ids.length; i += _isarAnyOfChunkSize) {
      final end = (i + _isarAnyOfChunkSize < ids.length)
          ? i + _isarAnyOfChunkSize
          : ids.length;
      final chunk = ids.sublist(i, end);
      results.addAll(await loader(chunk));
    }
    return results;
  }

  Future<Map<String, RouteEntity>> _buildRouteLookup(
    Iterable<String> routeHints,
  ) async {
    final hints = routeHints
        .map(sanitizeDimensionValue)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (hints.isEmpty) {
      return <String, RouteEntity>{};
    }

    final routesByNameFuture = _loadInChunks<RouteEntity>(
      hints,
      (chunk) => _dbService.routes
          .filter()
          .anyOf(chunk, (q, String value) => q.nameEqualTo(value))
          .findAll(),
    );
    final routesByIdFuture = _loadInChunks<RouteEntity>(
      hints,
      (chunk) => _dbService.routes
          .filter()
          .anyOf(chunk, (q, String value) => q.idEqualTo(value))
          .findAll(),
    );
    final routesByName = await routesByNameFuture;
    final routesById = await routesByIdFuture;

    final routes = <RouteEntity>[
      ...routesByName,
      ...routesById,
    ];
    final lookup = <String, RouteEntity>{};
    for (final route in routes) {
      final byId = sanitizeDimensionValue(route.id);
      final byName = sanitizeDimensionValue(route.name);
      if (byId.isNotEmpty) lookup[byId] = route;
      if (byName.isNotEmpty) lookup[byName] = route;
    }
    return lookup;
  }

  Future<Map<String, DealerEntity>> _loadDealersByIds(List<String> ids) async {
    final records = await _loadInChunks<DealerEntity>(
      ids,
      (chunk) => _dbService.dealers
          .filter()
          .anyOf(chunk, (q, String id) => q.idEqualTo(id))
          .findAll(),
    );
    return {for (final dealer in records) dealer.id: dealer};
  }

  Future<Map<String, CustomerEntity>> _loadCustomersByIds(
    List<String> ids,
  ) async {
    final records = await _loadInChunks<CustomerEntity>(
      ids,
      (chunk) => _dbService.customers
          .filter()
          .anyOf(chunk, (q, String id) => q.idEqualTo(id))
          .findAll(),
    );
    return {for (final customer in records) customer.id: customer};
  }

  Future<Map<String, VoucherEntity>> _loadVouchersBySaleIds(
    List<String> saleIds,
  ) async {
    final records = await _loadInChunks<VoucherEntity>(
      saleIds,
      (chunk) => _dbService.vouchers
          .filter()
          .anyOf(chunk, (q, String id) => q.transactionRefIdEqualTo(id))
          .findAll(),
    );
    final map = <String, VoucherEntity>{};
    for (final voucher in records) {
      final saleId = voucher.transactionRefId;
      if (saleId.isEmpty) {
        continue;
      }
      final existing = map[saleId];
      if (existing == null && voucher.type.trim().toLowerCase() == 'sales') {
        map[saleId] = voucher;
      }
    }
    return map;
  }

  Future<Map<String, List<VoucherEntryEntity>>> _loadVoucherEntriesByVoucherIds(
    List<String> voucherIds,
  ) async {
    final records = await _loadInChunks<VoucherEntryEntity>(
      voucherIds,
      (chunk) => _dbService.voucherEntries
          .filter()
          .anyOf(chunk, (q, String id) => q.voucherIdEqualTo(id))
          .findAll(),
    );
    final grouped = <String, List<VoucherEntryEntity>>{};
    for (final entry in records) {
      final voucherId = entry.voucherId;
      if (voucherId.isEmpty) {
        continue;
      }
      grouped.putIfAbsent(voucherId, () => <VoucherEntryEntity>[]).add(entry);
    }
    return grouped;
  }
}
