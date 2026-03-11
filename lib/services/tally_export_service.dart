import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/maharashtra_zones.dart';
import '../data/local/entities/customer_entity.dart';
import '../data/local/entities/dealer_entity.dart';
import '../data/local/entities/route_entity.dart';
import '../data/local/entities/sale_entity.dart';
import 'base_service.dart';
import 'database_service.dart';

class TallyXmlGenerator {
  static String generate(
    List<Map<String, dynamic>> vouchers, {
    String companyName = 'Datt Soap',
  }) {
    final sanitizedCompany = _escapeXml(
      companyName.trim().isEmpty ? 'Datt Soap' : companyName,
    );
    final buffer = StringBuffer();
    buffer.writeln('<ENVELOPE>');
    buffer.writeln(' <HEADER>');
    buffer.writeln('  <TALLYREQUEST>Import Data</TALLYREQUEST>');
    buffer.writeln(' </HEADER>');
    buffer.writeln(' <BODY>');
    buffer.writeln('  <IMPORTDATA>');
    buffer.writeln('   <REQUESTDESC>');
    buffer.writeln('    <REPORTNAME>Vouchers</REPORTNAME>');
    buffer.writeln('    <STATICVARIABLES>');
    buffer.writeln(
      '     <SVCURRENTCOMPANY>$sanitizedCompany</SVCURRENTCOMPANY>',
    );
    buffer.writeln('    </STATICVARIABLES>');
    buffer.writeln('   </REQUESTDESC>');
    buffer.writeln('   <REQUESTDATA>');

    for (final voucher in vouchers) {
      buffer.writeln(_generateVoucherXml(voucher));
    }

    buffer.writeln('   </REQUESTDATA>');
    buffer.writeln('  </IMPORTDATA>');
    buffer.writeln(' </BODY>');
    buffer.writeln('</ENVELOPE>');
    return buffer.toString();
  }

  static String _generateVoucherXml(Map<String, dynamic> voucher) {
    final dateStr = (voucher['date'] as String)
        .split('T')[0]
        .replaceAll('-', '');

    String esc(dynamic value) => value
        .toString()
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');

    String amount(num value) => value.toStringAsFixed(2);

    return '''
    <TALLYMESSAGE xmlns:UDF="TallyUDF">
     <VOUCHER VCHTYPE="${esc(voucher['voucherType'])}" ACTION="Create" OBJVIEW="Invoice Voucher View">
      <DATE>$dateStr</DATE>
      <VOUCHERTYPENAME>${esc(voucher['voucherType'])}</VOUCHERTYPENAME>
      <VOUCHERNUMBER>${esc(voucher['voucherNumber'])}</VOUCHERNUMBER>
      <PARTYLEDGERNAME>${esc(voucher['partyName'])}</PARTYLEDGERNAME>
      <NARRATION>${esc(voucher['narration'])}</NARRATION>
      <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
      <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>

      <ALLLEDGERENTRIES.LIST>
       <LEDGERNAME>${esc(voucher['partyName'])}</LEDGERNAME>
       <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
       <LEDGERFROMITEM>No</LEDGERFROMITEM>
       <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
       <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
       <AMOUNT>-${amount((voucher['totalAmount'] as num?) ?? 0)}</AMOUNT>
      </ALLLEDGERENTRIES.LIST>

      <ALLLEDGERENTRIES.LIST>
       <LEDGERNAME>Sales Account</LEDGERNAME>
       <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
       <AMOUNT>${amount((voucher['taxableAmount'] as num?) ?? 0)}</AMOUNT>
      </ALLLEDGERENTRIES.LIST>

      ${_taxEntry(voucher, 'CGST', voucher['cgstRate'] as double?, voucher['cgstAmount'] as double?)}
      ${_taxEntry(voucher, 'SGST', voucher['sgstRate'] as double?, voucher['sgstAmount'] as double?)}
      ${_taxEntry(voucher, 'IGST', voucher['igstRate'] as double?, voucher['igstAmount'] as double?)}
     </VOUCHER>
    </TALLYMESSAGE>
      ''';
  }

  static String _taxEntry(
    Map<String, dynamic> voucher,
    String name,
    double? rate,
    double? amount,
  ) {
    if (amount == null || amount <= 0) return '';
    final formattedRate = _formatRate(rate);
    final ledgerName = formattedRate.isEmpty
        ? 'Output $name'
        : 'Output $name $formattedRate%';
    return '''
      <ALLLEDGERENTRIES.LIST>
       <LEDGERNAME>$ledgerName</LEDGERNAME>
       <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
       <AMOUNT>${amount.toStringAsFixed(2)}</AMOUNT>
      </ALLLEDGERENTRIES.LIST>
      ''';
  }

  static String _formatRate(double? rate) {
    if (rate == null || rate <= 0) return '';
    if ((rate - rate.round()).abs() < 0.0001) {
      return rate.round().toString();
    }
    return rate
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

class TallyExportPayload {
  final String xmlContent;
  final int count;
  final double total;
  final List<String> exportedSaleKeys;

  const TallyExportPayload({
    required this.xmlContent,
    required this.count,
    required this.total,
    required this.exportedSaleKeys,
  });
}

class TallyExportService extends BaseService {
  static const int _salesPageSize = 500;
  static const String _exportedSalesPrefsKey = 'tally_exported_sales_v1';
  static const int _maxExportedSalesHistory = 10000;

  final DatabaseService _dbService;

  TallyExportService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

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

  Future<Map<String, dynamic>> getExportPreview(
    DateTime start,
    DateTime end, {
    String voucherType = 'sales',
    bool includeExported = false,
  }) async {
    try {
      final eligible = await _collectEligibleSales(
        start,
        end,
        voucherType: voucherType,
        includeExported: includeExported,
      );
      final totalAmount = eligible.fold<double>(
        0,
        (sum, sale) => sum + (sale.totalAmount ?? 0).toDouble(),
      );
      return {'count': eligible.length, 'total': totalAmount};
    } catch (e) {
      handleError(e, 'getExportPreview');
      rethrow;
    }
  }

  Future<TallyExportPayload> generateTallyExportPayloadForDateRange(
    DateTime start,
    DateTime end, {
    String voucherType = 'sales',
    String companyName = 'Datt Soap',
    bool includeExported = false,
  }) async {
    try {
      final normalizedVoucherType = _normalizeVoucherType(voucherType);
      final eligible = await _collectEligibleSales(
        start,
        end,
        voucherType: normalizedVoucherType,
        includeExported: includeExported,
      );
      final lookup = _DimensionLookupContext(_dbService);
      final vouchers = <Map<String, dynamic>>[];
      final exportedSaleKeys = <String>[];
      var totalAmount = 0.0;

      for (final sale in eligible) {
        vouchers.add(
          await _saleToTallyVoucher(
            sale,
            normalizedVoucherType: normalizedVoucherType,
            lookup: lookup,
          ),
        );
        totalAmount += (sale.totalAmount ?? 0).toDouble();
        final exportKey = _saleExportKey(sale);
        if (exportKey.isNotEmpty) {
          exportedSaleKeys.add(exportKey);
        }
      }

      vouchers.sort(
        (a, b) => (a['date'] as String).compareTo(b['date'] as String),
      );

      return TallyExportPayload(
        xmlContent: TallyXmlGenerator.generate(
          vouchers,
          companyName: companyName,
        ),
        count: vouchers.length,
        total: totalAmount,
        exportedSaleKeys: exportedSaleKeys,
      );
    } catch (e) {
      handleError(e, 'generateTallyExportPayloadForDateRange');
      rethrow;
    }
  }

  Future<String> generateTallyXmlForDateRange(
    DateTime start,
    DateTime end, {
    String voucherType = 'sales',
    String companyName = 'Datt Soap',
    bool includeExported = false,
  }) async {
    final payload = await generateTallyExportPayloadForDateRange(
      start,
      end,
      voucherType: voucherType,
      companyName: companyName,
      includeExported: includeExported,
    );
    return payload.xmlContent;
  }

  Future<void> markSalesAsExported(Iterable<String> saleKeys) async {
    final normalizedKeys = saleKeys
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (normalizedKeys.isEmpty) return;

    final map = await _loadExportedSalesMap();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    for (final key in normalizedKeys) {
      map[key] = nowIso;
    }
    if (map.length > _maxExportedSalesHistory) {
      final entries = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      map
        ..clear()
        ..addEntries(entries.take(_maxExportedSalesHistory));
    }
    await _saveExportedSalesMap(map);
  }

  Future<List<SaleEntity>> _collectEligibleSales(
    DateTime start,
    DateTime end, {
    required String voucherType,
    required bool includeExported,
  }) async {
    final normalizedVoucherType = _normalizeVoucherType(voucherType);
    if (normalizedVoucherType != 'sales') {
      return <SaleEntity>[];
    }

    final range = _toInclusiveDateRange(start, end);
    final exportedKeys = includeExported
        ? const <String>{}
        : await _loadExportedSaleKeys();
    final sales = await _fetchAllSalesPaged();
    final eligible = <SaleEntity>[];

    for (final sale in sales) {
      if (sale.recipientType.trim().toLowerCase() != 'customer') continue;
      if ((sale.status ?? '').trim().toLowerCase() == 'cancelled') continue;

      final createdAt = DateTime.tryParse(sale.createdAt);
      if (createdAt == null) continue;
      if (createdAt.isBefore(range.startUtc) ||
          createdAt.isAfter(range.endUtc)) {
        continue;
      }

      if (!includeExported) {
        final key = _saleExportKey(sale);
        if (key.isNotEmpty && exportedKeys.contains(key)) {
          continue;
        }
      }

      eligible.add(sale);
    }

    eligible.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return eligible;
  }

  String _normalizeVoucherType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'sales') {
      return normalized;
    }
    throw UnsupportedError(
      'Unsupported voucher type "$value". Currently supported: sales',
    );
  }

  _InclusiveDateRange _toInclusiveDateRange(DateTime start, DateTime end) {
    final startLocal = DateTime(start.year, start.month, start.day);
    final endLocal = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    if (endLocal.isBefore(startLocal)) {
      return _InclusiveDateRange(
        startUtc: startLocal.toUtc(),
        endUtc: DateTime(
          startLocal.year,
          startLocal.month,
          startLocal.day,
          23,
          59,
          59,
          999,
        ).toUtc(),
      );
    }
    return _InclusiveDateRange(
      startUtc: startLocal.toUtc(),
      endUtc: endLocal.toUtc(),
    );
  }

  String _saleExportKey(SaleEntity sale) {
    final id = sale.id.trim();
    if (id.isNotEmpty) return 'sale:$id';
    final humanReadableId = (sale.humanReadableId ?? '').trim();
    if (humanReadableId.isNotEmpty) return 'sale_hr:$humanReadableId';
    return '';
  }

  Future<Set<String>> _loadExportedSaleKeys() async {
    final map = await _loadExportedSalesMap();
    return map.keys.toSet();
  }

  Future<Map<String, String>> _loadExportedSalesMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_exportedSalesPrefsKey);
    if (raw == null || raw.trim().isEmpty) {
      return <String, String>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, String>{};
      }
      final map = <String, String>{};
      decoded.forEach((key, value) {
        final k = key.toString().trim();
        final v = value?.toString().trim() ?? '';
        if (k.isNotEmpty && v.isNotEmpty) {
          map[k] = v;
        }
      });
      return map;
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<void> _saveExportedSalesMap(Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_exportedSalesPrefsKey, jsonEncode(map));
  }

  Future<Map<String, dynamic>> _saleToTallyVoucher(
    SaleEntity sale, {
    required String normalizedVoucherType,
    required _DimensionLookupContext lookup,
  }) async {
    final total = (sale.totalAmount ?? 0).toDouble();

    final cgst = (sale.cgstAmount ?? 0).toDouble();
    final sgst = (sale.sgstAmount ?? 0).toDouble();
    final igst = (sale.igstAmount ?? 0).toDouble();
    final totalTax = cgst + sgst + igst;
    var taxable = (sale.taxableAmount ?? (total - totalTax)).toDouble();
    if (taxable < 0) {
      taxable = 0;
    }

    final gstPercent = (sale.gstPercentage ?? 0).toDouble();
    final gstType = sale.gstType;

    var cgstRate = 0.0;
    var sgstRate = 0.0;
    var igstRate = 0.0;

    if (gstType == 'CGST+SGST') {
      cgstRate = gstPercent / 2;
      sgstRate = gstPercent / 2;
    } else if (gstType == 'IGST') {
      igstRate = gstPercent;
    }

    final dimensions = await _resolveAccountingDimensions(sale, lookup: lookup);
    final dimensionNarration = _composeDimensionNarration(dimensions);
    final baseNarration = 'Invoice ${sale.humanReadableId ?? sale.id}';
    final finalNarration = dimensionNarration.isEmpty
        ? baseNarration
        : '$baseNarration | $dimensionNarration';

    return {
      'voucherNumber': sale.humanReadableId ?? sale.id,
      'date': sale.createdAt,
      'partyName': sale.recipientName,
      'voucherType': _tallyVoucherType(normalizedVoucherType),
      'taxableAmount': taxable,
      'cgstRate': cgstRate,
      'cgstAmount': cgst,
      'sgstRate': sgstRate,
      'sgstAmount': sgst,
      'igstRate': igstRate,
      'igstAmount': igst,
      'totalAmount': total,
      'narration': finalNarration,
      ...dimensions,
    };
  }

  Future<Map<String, dynamic>> _resolveAccountingDimensions(
    SaleEntity sale, {
    required _DimensionLookupContext lookup,
  }) async {
    var route = _sanitizeDimensionValue(sale.route);
    var district = '';
    var division = '';
    var dealerId = '';
    var dealerName = '';
    final recipientId = _sanitizeDimensionValue(sale.recipientId);

    final recipientType = sale.recipientType.trim().toLowerCase();
    if (recipientType == 'dealer') {
      dealerId = recipientId;
      dealerName = _sanitizeDimensionValue(sale.recipientName);
      final dealer = await lookup.dealerById(recipientId);
      if (dealer != null) {
        if (route.isEmpty) {
          route = _sanitizeDimensionValue(dealer.assignedRouteName);
        }
        district = _sanitizeDimensionValue(dealer.territory);
        if (district.isEmpty) {
          district = _sanitizeDimensionValue(dealer.city);
        }
      }
    } else if (recipientType == 'customer') {
      final customer = await lookup.customerById(recipientId);
      if (customer != null) {
        if (route.isEmpty) {
          route = _sanitizeDimensionValue(customer.route);
        }
        try {
          final city = customer.toDomain().city;
          if (district.isEmpty) {
            district = _sanitizeDimensionValue(city);
          }
        } catch (_) {
          // Best-effort export even when encrypted fields are unavailable.
        }
      }
    }

    if (route.isNotEmpty) {
      final routeEntity = await lookup.routeByNameOrId(route);
      if (routeEntity != null && district.isEmpty) {
        district = _extractDistrictFromText(routeEntity.description ?? '');
      }
    }

    if (division.isEmpty && district.isNotEmpty) {
      final zone = MaharashtraZones.getZoneForDistrict(district);
      if (zone != null) {
        division = _sanitizeDimensionValue(zone);
      }
    }

    final saleDate = _formatDateOnly(sale.createdAt);
    final salesmanId = _sanitizeDimensionValue(sale.salesmanId);
    final salesmanName = _sanitizeDimensionValue(sale.salesmanName);

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

  String _composeDimensionNarration(Map<String, dynamic> dimensions) {
    final tags = <String>[];

    void push(String key, String label) {
      final value = _sanitizeDimensionValue(dimensions[key], maxLength: 64);
      if (value.isNotEmpty) {
        tags.add('$label:$value');
      }
    }

    push('route', 'Route');
    push('district', 'District');
    push('division', 'Division');
    push('salesmanName', 'Salesman');
    push('saleDate', 'Date');
    push('dealerName', 'Dealer');
    return tags.join(' | ');
  }

  String _extractDistrictFromText(String source) {
    final cleaned = _sanitizeDimensionValue(source);
    if (cleaned.isEmpty) return '';

    if (MaharashtraZones.getZoneForDistrict(cleaned) != null) {
      return cleaned;
    }

    final parts = cleaned.split(',');
    for (final part in parts) {
      final trimmed = _sanitizeDimensionValue(part);
      if (trimmed.isEmpty) continue;
      if (MaharashtraZones.getZoneForDistrict(trimmed) != null) {
        return trimmed;
      }
    }
    return cleaned;
  }

  String _formatDateOnly(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return '';
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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

  String _tallyVoucherType(String normalizedVoucherType) {
    switch (normalizedVoucherType) {
      case 'sales':
      default:
        return 'Sales';
    }
  }
}

class _InclusiveDateRange {
  final DateTime startUtc;
  final DateTime endUtc;

  const _InclusiveDateRange({required this.startUtc, required this.endUtc});
}

class _DimensionLookupContext {
  final DatabaseService _dbService;
  final Map<String, DealerEntity?> _dealerById = <String, DealerEntity?>{};
  final Map<String, CustomerEntity?> _customerById =
      <String, CustomerEntity?>{};
  final Map<String, RouteEntity?> _routeByToken = <String, RouteEntity?>{};

  _DimensionLookupContext(this._dbService);

  Future<DealerEntity?> dealerById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    if (_dealerById.containsKey(normalized)) {
      return _dealerById[normalized];
    }
    final dealer = await _dbService.dealers
        .filter()
        .idEqualTo(normalized)
        .findFirst();
    _dealerById[normalized] = dealer;
    return dealer;
  }

  Future<CustomerEntity?> customerById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    if (_customerById.containsKey(normalized)) {
      return _customerById[normalized];
    }
    final customer = await _dbService.customers
        .filter()
        .idEqualTo(normalized)
        .findFirst();
    _customerById[normalized] = customer;
    return customer;
  }

  Future<RouteEntity?> routeByNameOrId(String token) async {
    final normalized = token.trim();
    if (normalized.isEmpty) return null;
    if (_routeByToken.containsKey(normalized)) {
      return _routeByToken[normalized];
    }
    final byName = await _dbService.routes
        .filter()
        .nameEqualTo(normalized)
        .findFirst();
    final route =
        byName ??
        await _dbService.routes.filter().idEqualTo(normalized).findFirst();
    _routeByToken[normalized] = route;
    return route;
  }
}
