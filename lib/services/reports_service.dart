import 'dart:convert';
import 'dart:isolate';
import 'package:isar/isar.dart' as isar;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/customer_entity.dart';
import '../data/local/entities/diesel_log_entity.dart';
import '../data/local/entities/dealer_entity.dart';
import '../data/local/entities/voucher_entity.dart';
import '../data/local/base_entity.dart';
import '../models/types/user_types.dart';
import '../services/field_encryption_service.dart';

// Collection Names
const salesCollection = 'sales';
const usersCollection = 'users';
const targetsCollection = 'sales_targets';
const vehiclesCollection = 'vehicles';
const dieselLogsCollection = 'diesel_logs';
const productsCollection = 'products';
const dealersCollection = 'dealers';

// Models
class SalesmanPerformanceData {
  final String salesmanId;
  final String salesmanName;
  int totalSales;
  int totalItemsSold;
  double totalRevenue;
  double totalTarget;
  double achievementPercentage;
  double achievedAmount;

  SalesmanPerformanceData({
    required this.salesmanId,
    required this.salesmanName,
    this.totalSales = 0,
    this.totalItemsSold = 0,
    this.totalRevenue = 0,
    this.totalTarget = 0,
    this.achievementPercentage = 0,
    this.achievedAmount = 0,
  });

  factory SalesmanPerformanceData.fromJson(Map<String, dynamic> json) {
    return SalesmanPerformanceData(
      salesmanId: (json['salesmanId'] ?? '').toString(),
      salesmanName: (json['salesmanName'] ?? '').toString(),
      totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
      totalItemsSold: (json['totalItemsSold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalTarget: (json['totalTarget'] as num?)?.toDouble() ?? 0,
      achievementPercentage:
          (json['achievementPercentage'] as num?)?.toDouble() ?? 0,
      achievedAmount: (json['achievedAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'totalSales': totalSales,
      'totalItemsSold': totalItemsSold,
      'totalRevenue': totalRevenue,
      'totalTarget': totalTarget,
      'achievementPercentage': achievementPercentage,
      'achievedAmount': achievedAmount,
    };
  }
}

class SalesmanOverallStats {
  double totalRevenue;
  int totalSales;
  int totalItemsSold;
  int activeSalesmen;

  SalesmanOverallStats({
    this.totalRevenue = 0,
    this.totalSales = 0,
    this.totalItemsSold = 0,
    this.activeSalesmen = 0,
  });

  factory SalesmanOverallStats.fromJson(Map<String, dynamic> json) {
    return SalesmanOverallStats(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
      totalItemsSold: (json['totalItemsSold'] as num?)?.toInt() ?? 0,
      activeSalesmen: (json['activeSalesmen'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalSales': totalSales,
      'totalItemsSold': totalItemsSold,
      'activeSalesmen': activeSalesmen,
    };
  }
}

class DealerPerformanceData {
  final String dealerId;
  final String dealerName;
  int totalOrders;
  double totalRevenue;
  String? lastOrderDate;
  String topProduct;
  final Map<String, int> _productCounts;

  DealerPerformanceData({
    required this.dealerId,
    required this.dealerName,
    this.totalOrders = 0,
    this.totalRevenue = 0,
    this.lastOrderDate,
    this.topProduct = 'N/A',
    Map<String, int>? productCounts,
  }) : _productCounts = productCounts ?? {};
}

class DealerOverallStats {
  double totalRevenue;
  int totalOrders;
  int activeDealers;

  DealerOverallStats({
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.activeDealers = 0,
  });
}

class VehiclePerformanceData {
  final String id;
  final String name;
  final String number;
  final double totalDistance;
  final double totalDieselCost;
  final double totalMaintenanceCost;
  final double totalTyreCost;
  final double actualAverage;
  final double costPerKm;
  final double minAverage;
  final double maxAverage;

  VehiclePerformanceData({
    required this.id,
    required this.name,
    required this.number,
    required this.totalDistance,
    required this.totalDieselCost,
    required this.totalMaintenanceCost,
    required this.totalTyreCost,
    required this.actualAverage,
    required this.costPerKm,
    required this.minAverage,
    required this.maxAverage,
  });
}

class FilterOptions {
  final String? salesmanId;
  final String? route;
  final String? customerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? dealerId;

  FilterOptions({
    this.salesmanId,
    this.route,
    this.customerId,
    this.startDate,
    this.endDate,
    this.dealerId,
  });
}

enum SalesReportGroupBy { daily, monthly, yearly }

class SalesReportOption {
  final String id;
  final String label;

  const SalesReportOption({required this.id, required this.label});
}

class SalesReportFilterMeta {
  final List<String> divisions;
  final List<String> districts;
  final List<String> routes;
  final List<SalesReportOption> salesmen;
  final List<SalesReportOption> dealers;
  final List<int> years;

  const SalesReportFilterMeta({
    required this.divisions,
    required this.districts,
    required this.routes,
    required this.salesmen,
    required this.dealers,
    required this.years,
  });
}

class SalesReportQuery {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? recipientType;
  final String? division;
  final String? district;
  final String? route;
  final String? salesmanId;
  final String? dealerId;
  final SalesReportGroupBy groupBy;
  final bool includeCancelled;

  const SalesReportQuery({
    this.startDate,
    this.endDate,
    this.recipientType,
    this.division,
    this.district,
    this.route,
    this.salesmanId,
    this.dealerId,
    this.groupBy = SalesReportGroupBy.monthly,
    this.includeCancelled = false,
  });
}

class SalesReportRecord {
  final String saleId;
  final String invoiceId;
  final DateTime createdAt;
  final String recipientType;
  final String recipientId;
  final String recipientName;
  final String salesmanId;
  final String salesmanName;
  final String route;
  final String district;
  final String division;
  final String dealerId;
  final String dealerName;
  final String status;
  final double totalAmount;
  final int lineItems;
  final int quantity;

  const SalesReportRecord({
    required this.saleId,
    required this.invoiceId,
    required this.createdAt,
    required this.recipientType,
    required this.recipientId,
    required this.recipientName,
    required this.salesmanId,
    required this.salesmanName,
    required this.route,
    required this.district,
    required this.division,
    required this.dealerId,
    required this.dealerName,
    required this.status,
    required this.totalAmount,
    required this.lineItems,
    required this.quantity,
  });
}

class SalesReportBucket {
  final String key;
  final String label;
  final int transactions;
  final int quantity;
  final int lineItems;
  final double revenue;

  const SalesReportBucket({
    required this.key,
    required this.label,
    required this.transactions,
    required this.quantity,
    required this.lineItems,
    required this.revenue,
  });
}

class SalesAdvancedReport {
  final List<SalesReportRecord> records;
  final List<SalesReportBucket> trend;
  final List<SalesReportBucket> byDivision;
  final List<SalesReportBucket> byDistrict;
  final List<SalesReportBucket> byRoute;
  final List<SalesReportBucket> bySalesman;
  final List<SalesReportBucket> byDealer;
  final double totalRevenue;
  final int totalTransactions;
  final int totalLineItems;
  final int totalQuantity;
  final double averageOrderValue;

  const SalesAdvancedReport({
    required this.records,
    required this.trend,
    required this.byDivision,
    required this.byDistrict,
    required this.byRoute,
    required this.bySalesman,
    required this.byDealer,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.totalLineItems,
    required this.totalQuantity,
    required this.averageOrderValue,
  });
}

// New Financial Models
class ProfitMarginData {
  final String productId;
  final String productName;
  double totalRevenue;
  double totalCost;
  double grossMargin;
  double marginPercentage;
  double totalQuantity;

  ProfitMarginData({
    required this.productId,
    required this.productName,
    this.totalRevenue = 0,
    this.totalCost = 0,
    this.grossMargin = 0,
    this.marginPercentage = 0,
    this.totalQuantity = 0,
  });
}

class StockValuationItem {
  final String productId;
  final String productName;
  final String category;
  final double stock;
  final String unit;
  final double costPerUnit;
  final double totalValue;

  StockValuationItem({
    required this.productId,
    required this.productName,
    required this.category,
    required this.stock,
    required this.unit,
    required this.costPerUnit,
    required this.totalValue,
  });
}

class StockValuationReport {
  final List<StockValuationItem> items;
  final double totalValue;

  StockValuationReport({required this.items, required this.totalValue});
}

double _reportRound2(double value) {
  return (value * 100).roundToDouble() / 100;
}

String _reportBucketKeyForDate(DateTime date, String groupBy) {
  switch (groupBy) {
    case 'daily':
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    case 'yearly':
      return date.year.toString();
    case 'monthly':
    default:
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
  }
}

String _reportBucketLabelForDate(DateTime date, String groupBy) {
  const monthLabels = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  switch (groupBy) {
    case 'daily':
      return '${date.day.toString().padLeft(2, '0')} ${monthLabels[date.month - 1]} ${date.year}';
    case 'yearly':
      return date.year.toString();
    case 'monthly':
    default:
      return '${monthLabels[date.month - 1]} ${date.year}';
  }
}

void _reportAccumulateBucket(
  Map<String, Map<String, dynamic>> buckets, {
  required String key,
  required String label,
  required int quantity,
  required int lineItems,
  required double revenue,
}) {
  final entry = buckets.putIfAbsent(
    key,
    () => <String, dynamic>{
      'key': key,
      'label': label,
      'transactions': 0,
      'quantity': 0,
      'lineItems': 0,
      'revenue': 0.0,
    },
  );
  entry['transactions'] = (entry['transactions'] as int) + 1;
  entry['quantity'] = (entry['quantity'] as int) + quantity;
  entry['lineItems'] = (entry['lineItems'] as int) + lineItems;
  entry['revenue'] =
      (entry['revenue'] as double) + (revenue.isFinite ? revenue : 0.0);
}

List<Map<String, dynamic>> _reportFinalizeBuckets(
  Map<String, Map<String, dynamic>> buckets, {
  bool sortByKeyAsc = false,
}) {
  final list = buckets.values
      .map(
        (entry) => <String, dynamic>{
          'key': entry['key']?.toString() ?? '',
          'label': entry['label']?.toString() ?? '',
          'transactions': (entry['transactions'] as num?)?.toInt() ?? 0,
          'quantity': (entry['quantity'] as num?)?.toInt() ?? 0,
          'lineItems': (entry['lineItems'] as num?)?.toInt() ?? 0,
          'revenue': _reportRound2((entry['revenue'] as num?)?.toDouble() ?? 0),
        },
      )
      .toList(growable: false);

  if (sortByKeyAsc) {
    list.sort(
      (a, b) => (a['key'] as String).compareTo((b['key'] as String)),
    );
  } else {
    list.sort((a, b) {
      final revenueCompare = (b['revenue'] as double).compareTo(
        a['revenue'] as double,
      );
      if (revenueCompare != 0) return revenueCompare;
      return (a['label'] as String).toLowerCase().compareTo(
        (b['label'] as String).toLowerCase(),
      );
    });
  }
  return list;
}

Map<String, dynamic> _computeSalesAdvancedAggregate(
  List<Map<String, dynamic>> records, {
  required String groupByName,
}) {
  final trend = <String, Map<String, dynamic>>{};
  final byDivision = <String, Map<String, dynamic>>{};
  final byDistrict = <String, Map<String, dynamic>>{};
  final byRoute = <String, Map<String, dynamic>>{};
  final bySalesman = <String, Map<String, dynamic>>{};
  final byDealer = <String, Map<String, dynamic>>{};

  var totalRevenue = 0.0;
  var totalQuantity = 0;
  var totalLineItems = 0;

  for (final record in records) {
    final createdAt = DateTime.tryParse(record['createdAt']?.toString() ?? '');
    if (createdAt == null) continue;

    final quantity = (record['quantity'] as num?)?.toInt() ?? 0;
    final lineItems = (record['lineItems'] as num?)?.toInt() ?? 0;
    final revenue = (record['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final division = record['division']?.toString() ?? '';
    final district = record['district']?.toString() ?? '';
    final route = record['route']?.toString() ?? '';
    final salesmanId = record['salesmanId']?.toString() ?? '';
    final salesmanName = record['salesmanName']?.toString() ?? '';
    final dealerId = record['dealerId']?.toString() ?? '';
    final dealerName = record['dealerName']?.toString() ?? '';

    totalRevenue += revenue;
    totalQuantity += quantity;
    totalLineItems += lineItems;

    final trendKey = _reportBucketKeyForDate(createdAt, groupByName);
    final trendLabel = _reportBucketLabelForDate(createdAt, groupByName);
    _reportAccumulateBucket(
      trend,
      key: trendKey,
      label: trendLabel,
      quantity: quantity,
      lineItems: lineItems,
      revenue: revenue,
    );

    _reportAccumulateBucket(
      byDivision,
      key: division.toLowerCase(),
      label: division,
      quantity: quantity,
      lineItems: lineItems,
      revenue: revenue,
    );
    _reportAccumulateBucket(
      byDistrict,
      key: district.toLowerCase(),
      label: district,
      quantity: quantity,
      lineItems: lineItems,
      revenue: revenue,
    );
    _reportAccumulateBucket(
      byRoute,
      key: route.toLowerCase(),
      label: route,
      quantity: quantity,
      lineItems: lineItems,
      revenue: revenue,
    );

    final salesmanKey = salesmanId.isNotEmpty
        ? salesmanId.toLowerCase()
        : salesmanName.toLowerCase();
    _reportAccumulateBucket(
      bySalesman,
      key: salesmanKey,
      label: salesmanName,
      quantity: quantity,
      lineItems: lineItems,
      revenue: revenue,
    );

    final dealerKey = dealerId.isNotEmpty
        ? dealerId.toLowerCase()
        : dealerName.toLowerCase();
    _reportAccumulateBucket(
      byDealer,
      key: dealerKey,
      label: dealerName,
      quantity: quantity,
      lineItems: lineItems,
      revenue: revenue,
    );
  }

  final totalTransactions = records.length;
  final averageOrderValue = totalTransactions > 0
      ? _reportRound2(totalRevenue / totalTransactions)
      : 0.0;

  return <String, dynamic>{
    'totalRevenue': _reportRound2(totalRevenue),
    'totalQuantity': totalQuantity,
    'totalLineItems': totalLineItems,
    'totalTransactions': totalTransactions,
    'averageOrderValue': averageOrderValue,
    'trend': _reportFinalizeBuckets(trend, sortByKeyAsc: true),
    'byDivision': _reportFinalizeBuckets(byDivision),
    'byDistrict': _reportFinalizeBuckets(byDistrict),
    'byRoute': _reportFinalizeBuckets(byRoute),
    'bySalesman': _reportFinalizeBuckets(bySalesman),
    'byDealer': _reportFinalizeBuckets(byDealer),
  };
}

Future<Map<String, dynamic>> _computeSalesAdvancedAggregateBackground(
  List<Map<String, dynamic>> records, {
  required String groupByName,
}) {
  final payload = <String, dynamic>{
    'records': records,
    'groupByName': groupByName,
  };
  return Isolate.run(() {
    final rawRecords = payload['records'] as List<dynamic>? ?? const [];
    final normalizedRecords = rawRecords
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
    final rawGroupBy = payload['groupByName']?.toString().trim();
    final normalizedGroupBy =
        (rawGroupBy == null || rawGroupBy.isEmpty) ? 'monthly' : rawGroupBy;
    return _computeSalesAdvancedAggregate(
      normalizedRecords,
      groupByName: normalizedGroupBy,
    );
  });
}

class ReportsService extends BaseService {
  static const int _salesPageSize = 500;
  static const int _stockLedgerPageSize = 500;
  static final RegExp _opaqueIdPattern = RegExp(r'^[A-Za-z0-9_-]{18,}$');
  static final RegExp _stockReturnReasonPattern = RegExp(
    r'^stock\s+return:\s*[A-Za-z0-9_-]+(?:\s+from\s+(.+))?$',
    caseSensitive: false,
  );
  static final RegExp _badStockReturnReasonPattern = RegExp(
    r'^bad\s+stock\s+return:\s*[A-Za-z0-9_-]+(?:\s*\(original\s+sale:\s*[A-Za-z0-9_-]+\))?$',
    caseSensitive: false,
  );
  static final RegExp _reasonFromNamePattern = RegExp(
    r'\bfrom\s+(.+)$',
    caseSensitive: false,
  );
  final DatabaseService _dbService = DatabaseService(); // Access local DB
  final FieldEncryptionService _fieldEncryption =
      FieldEncryptionService.instance;
  ReportsService(super.firebase);

  double _round(double val) => (val * 100).round() / 100;

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

  Future<List<SaleEntity>> _loadSalesForAdvancedReportPaged({
    DateTime? queryStart,
    DateTime? queryEnd,
  }) async {
    final sales = await _fetchAllSalesPaged();
    if (queryStart == null && queryEnd == null) {
      return sales;
    }
    return sales.where((sale) {
      final createdAt = DateTime.tryParse(sale.createdAt);
      if (createdAt == null) return false;
      if (queryStart != null && createdAt.isBefore(queryStart)) return false;
      if (queryEnd != null && createdAt.isAfter(queryEnd)) return false;
      return true;
    }).toList(growable: false);
  }

  Future<List<StockLedgerEntity>> _fetchAllStockLedgerPaged() async {
    final allEntries = <StockLedgerEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.stockLedger
          .where()
          .offset(offset)
          .limit(_stockLedgerPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      allEntries.addAll(chunk);
      if (chunk.length < _stockLedgerPageSize) {
        break;
      }
      offset += _stockLedgerPageSize;
    }
    return allEntries;
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  Future<List<SaleEntity>> _loadCustomerSalesForPerformance(
    FilterOptions filters,
  ) async {
    final startIso = filters.startDate?.toIso8601String();
    final endIso = filters.endDate == null
        ? null
        : _endOfDay(filters.endDate!).toIso8601String();

    if (startIso != null && endIso != null) {
      return _dbService.sales
          .filter()
          .recipientTypeEqualTo('customer')
          .and()
          .createdAtBetween(startIso, endIso)
          .findAll();
    }
    if (startIso != null) {
      return _dbService.sales
          .filter()
          .recipientTypeEqualTo('customer')
          .and()
          .createdAtGreaterThan(startIso)
          .findAll();
    }
    if (endIso != null) {
      return _dbService.sales
          .filter()
          .recipientTypeEqualTo('customer')
          .and()
          .createdAtLessThan(endIso)
          .findAll();
    }
    return _dbService.sales.filter().recipientTypeEqualTo('customer').findAll();
  }

  Future<Map<String, String>> _loadProductNameMap(
    Iterable<String> productIds,
  ) async {
    final ids = productIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const <String, String>{};

    final hashed = ids.map(fastHash).toList(growable: false);
    final records = await _dbService.products.getAll(hashed);
    final map = <String, String>{};
    for (var i = 0; i < ids.length; i++) {
      final entity = records[i];
      if (entity == null) continue;
      final name = entity.name.trim();
      if (name.isNotEmpty) {
        map[ids[i]] = name;
      }
    }
    return map;
  }

  Future<Map<String, String>> _loadUserNameMap(Iterable<String> userIds) async {
    final ids = userIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const <String, String>{};

    final hashed = ids.map(fastHash).toList(growable: false);
    final records = await _dbService.users.getAll(hashed);
    final map = <String, String>{};
    for (var i = 0; i < ids.length; i++) {
      final entity = records[i];
      if (entity == null) continue;
      final name = entity.name?.trim() ?? '';
      if (name.isNotEmpty) {
        map[ids[i]] = name;
      }
    }
    return map;
  }

  Future<Map<String, String>> _loadReturnSalesmanNameMap(
    Iterable<String?> referenceIds,
  ) async {
    final ids = referenceIds
        .whereType<String>()
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const <String, String>{};

    final hashed = ids.map(fastHash).toList(growable: false);
    final records = await _dbService.returns.getAll(hashed);
    final map = <String, String>{};
    for (var i = 0; i < ids.length; i++) {
      final entity = records[i];
      if (entity == null) continue;
      final name = entity.salesmanName.trim();
      if (name.isNotEmpty) {
        map[ids[i]] = name;
      }
    }
    return map;
  }

  bool _looksLikeOpaqueId(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty &&
        !trimmed.contains(' ') &&
        _opaqueIdPattern.hasMatch(trimmed);
  }

  String _toTitleCaseWords(String input) {
    final words = input
        .split(RegExp(r'[\s_]+'))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) return input;
    return words
        .map(
          (w) =>
              '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }

  String _formatTransactionTypeLabel(String transactionType) {
    final tx = transactionType.trim().toUpperCase();
    const labels = <String, String>{
      'RETURN_IN': 'Stock Return',
      'RETURN_BAD_STOCK': 'Bad Stock Return',
      'RETURN_DEPT': 'Department Return',
      'ISSUE_DEPT': 'Department Issue',
      'PRODUCTION_IN': 'Production In',
      'PRODUCTION_OUT': 'Production Out',
      'OPENING': 'Opening Stock',
      'ADJUSTMENT': 'Stock Adjustment',
      'IN': 'Stock In',
      'OUT': 'Stock Out',
      'SALE_OUT': 'Sale Out',
    };
    final mapped = labels[tx];
    if (mapped != null) return mapped;
    return _toTitleCaseWords(transactionType);
  }

  String? _extractActorNameFromReason(String reasonText) {
    final match = _reasonFromNamePattern.firstMatch(reasonText.trim());
    final candidate = match?.group(1)?.trim();
    if (candidate == null || candidate.isEmpty) return null;
    if (_looksLikeOpaqueId(candidate)) return null;
    return candidate;
  }

  String _normalizeStockMovementReason({
    required String rawReason,
    required String transactionType,
    String? returnSalesmanName,
  }) {
    final reason = rawReason.trim();
    if (reason.isEmpty || reason == 'Auto-generated') {
      return _formatTransactionTypeLabel(transactionType);
    }

    if (_stockReturnReasonPattern.hasMatch(reason)) {
      final fromInReason = _stockReturnReasonPattern
          .firstMatch(reason)
          ?.group(1)
          ?.trim();
      final fromName = (fromInReason != null && fromInReason.isNotEmpty)
          ? fromInReason
          : returnSalesmanName?.trim();
      if (fromName != null &&
          fromName.isNotEmpty &&
          !_looksLikeOpaqueId(fromName)) {
        return 'Stock Return from $fromName';
      }
      return 'Stock Return';
    }

    if (_badStockReturnReasonPattern.hasMatch(reason)) {
      final fromName = returnSalesmanName?.trim();
      if (fromName != null &&
          fromName.isNotEmpty &&
          !_looksLikeOpaqueId(fromName)) {
        return 'Bad Stock Return from $fromName';
      }
      return 'Bad Stock Return';
    }

    if (reason.toLowerCase().startsWith('ref type:')) {
      final refType = reason.substring('ref type:'.length).trim();
      if (refType.isNotEmpty) {
        return _toTitleCaseWords(refType);
      }
      return _formatTransactionTypeLabel(transactionType);
    }

    if (reason == transactionType || _looksLikeOpaqueId(reason)) {
      return _formatTransactionTypeLabel(transactionType);
    }

    return reason;
  }

  String _resolveStockMovementUserName({
    required String performedBy,
    required Map<String, String> userMap,
    required String normalizedReason,
    String? returnSalesmanName,
  }) {
    final key = performedBy.trim();
    final mapped = userMap[key]?.trim();
    if (mapped != null && mapped.isNotEmpty) {
      return mapped;
    }

    final fromReturn = returnSalesmanName?.trim();
    if (fromReturn != null && fromReturn.isNotEmpty) {
      return fromReturn;
    }

    final fromReason = _extractActorNameFromReason(normalizedReason);
    if (fromReason != null && fromReason.isNotEmpty) {
      return fromReason;
    }

    if (key.isEmpty || key.toLowerCase() == 'system') {
      return 'System';
    }

    if (!_looksLikeOpaqueId(key)) {
      return key;
    }

    return 'Unknown User';
  }

  bool _isDispatchRecord(Map<String, dynamic> data) {
    return data['dispatchId'] != null &&
        data['salesmanId'] != null &&
        data['items'] is List;
  }

  String? _resolveDispatchRoute(Map<String, dynamic> data) {
    final route = data['route']?.toString();
    if (route != null && route.isNotEmpty) return route;
    final salesRoute = data['salesRoute']?.toString();
    if (salesRoute != null && salesRoute.isNotEmpty) return salesRoute;
    final dispatchRoute = data['dispatchRoute']?.toString();
    if (dispatchRoute != null && dispatchRoute.isNotEmpty) {
      return dispatchRoute;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _loadLocalDispatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('local_stock_movements');
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final raw = jsonDecode(jsonStr);
      if (raw is! List) return [];
      final List<Map<String, dynamic>> records = [];
      for (final item in raw) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (_isDispatchRecord(map)) {
            records.add(map);
          }
        }
      }
      return records;
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _mapDispatchToSalesRecord(
    Map<String, dynamic> dispatch,
  ) {
    final items = (dispatch['items'] as List?) ?? const [];
    return {
      'id': dispatch['id'],
      'totalAmount': dispatch['totalAmount'] ?? 0,
      'recipientType': 'salesman',
      'salesmanId': dispatch['salesmanId'],
      'salesmanName': dispatch['salesmanName'],
      'createdAt': dispatch['createdAt'],
      'route': _resolveDispatchRoute(dispatch),
      'items': items
          .map(
            (i) => {
              'name': (i is Map) ? i['name'] : null,
              'quantity': (i is Map) ? i['quantity'] : null,
              'price': (i is Map) ? i['price'] : null,
            },
          )
          .toList(),
    };
  }

  double? _decryptProductDouble(String productId, String field, double? value) {
    if (value == null) return null;
    return _fieldEncryption.decryptDouble(
      value,
      'product:$productId:$field',
      magnitude: 1e5,
    );
  }

  String _normalizeReportText(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    if (text.isEmpty) return '';
    final lower = text.toLowerCase();
    if (lower == 'null' || lower == 'n/a' || lower == 'na' || lower == '-') {
      return '';
    }
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _displayOrUnassigned(String value) {
    return value.isEmpty ? 'Unassigned' : value;
  }

  bool _matchesTextFilter(String actual, String? filter) {
    final wanted = _normalizeReportText(filter);
    if (wanted.isEmpty || wanted.toLowerCase() == 'all') return true;
    return actual.toLowerCase() == wanted.toLowerCase();
  }

  bool _matchesIdFilter(String actual, String? filter) {
    final wanted = _normalizeReportText(filter);
    if (wanted.isEmpty || wanted.toLowerCase() == 'all') return true;
    return actual.toLowerCase() == wanted.toLowerCase();
  }

  int _sumSaleQuantity(SaleEntity sale) {
    return sale.items?.fold<int>(
          0,
          (sum, item) => sum + (item.quantity ?? 0),
        ) ??
        0;
  }

  int _countSaleLineItems(SaleEntity sale) {
    return sale.items?.length ?? 0;
  }

  int _voucherScore(VoucherEntity voucher) {
    var score = 0;
    if (_normalizeReportText(voucher.route).isNotEmpty) score += 2;
    if (_normalizeReportText(voucher.district).isNotEmpty) score += 2;
    if (_normalizeReportText(voucher.division).isNotEmpty) score += 2;
    if (_normalizeReportText(voucher.salesmanId).isNotEmpty) score += 2;
    if (_normalizeReportText(voucher.salesmanName).isNotEmpty) score += 1;
    if (_normalizeReportText(voucher.dealerId).isNotEmpty) score += 2;
    if (_normalizeReportText(voucher.dealerName).isNotEmpty) score += 1;
    return score;
  }

  Map<String, VoucherEntity> _mapBestVoucherBySaleId(
    List<VoucherEntity> vouchers,
    Set<String> saleIds,
  ) {
    final map = <String, VoucherEntity>{};
    for (final voucher in vouchers) {
      final saleId = _normalizeReportText(voucher.transactionRefId);
      if (saleId.isEmpty || !saleIds.contains(saleId)) continue;

      final current = map[saleId];
      if (current == null || _voucherScore(voucher) > _voucherScore(current)) {
        map[saleId] = voucher;
      }
    }
    return map;
  }

  List<SalesReportBucket> _bucketListFromAggregate(dynamic raw) {
    if (raw is! List) return const <SalesReportBucket>[];
    final buckets = <SalesReportBucket>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      buckets.add(
        SalesReportBucket(
          key: map['key']?.toString() ?? '',
          label: map['label']?.toString() ?? '',
          transactions: (map['transactions'] as num?)?.toInt() ?? 0,
          quantity: (map['quantity'] as num?)?.toInt() ?? 0,
          lineItems: (map['lineItems'] as num?)?.toInt() ?? 0,
          revenue: _round((map['revenue'] as num?)?.toDouble() ?? 0),
        ),
      );
    }
    return buckets;
  }

  Future<SalesReportFilterMeta> getSalesReportFilterMeta() async {
    try {
      final sales = await _fetchAllSalesPaged();
      final vouchers = await _dbService.vouchers.where().findAll();
      final dealers = await _dbService.dealers.where().findAll();
      final customers = await _dbService.customers.where().findAll();

      final saleIds = sales
          .map((s) => _normalizeReportText(s.id))
          .where((id) => id.isNotEmpty)
          .toSet();
      final voucherBySale = _mapBestVoucherBySaleId(vouchers, saleIds);

      final dealerById = <String, DealerEntity>{
        for (final dealer in dealers)
          if (_normalizeReportText(dealer.id).isNotEmpty)
            _normalizeReportText(dealer.id): dealer,
      };
      final customerById = <String, CustomerEntity>{
        for (final customer in customers)
          if (_normalizeReportText(customer.id).isNotEmpty)
            _normalizeReportText(customer.id): customer,
      };

      final divisions = <String>{};
      final districts = <String>{};
      final routes = <String>{};
      final years = <int>{};
      final salesmen = <String, SalesReportOption>{};
      final dealerOptions = <String, SalesReportOption>{};

      for (final sale in sales) {
        final saleId = _normalizeReportText(sale.id);
        final recipientType = _normalizeReportText(
          sale.recipientType,
        ).toLowerCase();
        final recipientId = _normalizeReportText(sale.recipientId);
        final voucher = voucherBySale[saleId];
        final dealer = dealerById[recipientId];
        final customer = customerById[recipientId];

        final route = _normalizeReportText(
          voucher?.route ??
              sale.route ??
              (recipientType == 'customer' ? customer?.route : null) ??
              (recipientType == 'dealer' ? dealer?.assignedRouteName : null),
        );
        final district = _normalizeReportText(
          voucher?.district ??
              (recipientType == 'dealer' ? dealer?.city : null),
        );
        final division = _normalizeReportText(
          voucher?.division ??
              (recipientType == 'dealer' ? dealer?.territory : null),
        );

        if (route.isNotEmpty) routes.add(route);
        if (district.isNotEmpty) districts.add(district);
        if (division.isNotEmpty) divisions.add(division);

        final salesmanId = _normalizeReportText(
          voucher?.salesmanId ?? sale.salesmanId,
        );
        final salesmanName = _normalizeReportText(
          voucher?.salesmanName ?? sale.salesmanName,
        );
        if (salesmanId.isNotEmpty) {
          salesmen[salesmanId] = SalesReportOption(
            id: salesmanId,
            label: salesmanName.isNotEmpty ? salesmanName : salesmanId,
          );
        }

        final dealerId = _normalizeReportText(
          voucher?.dealerId ?? (recipientType == 'dealer' ? recipientId : null),
        );
        final dealerName = _normalizeReportText(
          voucher?.dealerName ??
              (dealerId.isNotEmpty ? dealerById[dealerId]?.name : null) ??
              (recipientType == 'dealer' ? sale.recipientName : null),
        );
        if (dealerId.isNotEmpty) {
          dealerOptions[dealerId] = SalesReportOption(
            id: dealerId,
            label: dealerName.isNotEmpty ? dealerName : dealerId,
          );
        }

        final createdAt = DateTime.tryParse(sale.createdAt);
        if (createdAt != null) years.add(createdAt.year);
      }

      for (final dealer in dealers) {
        final id = _normalizeReportText(dealer.id);
        if (id.isNotEmpty && !dealerOptions.containsKey(id)) {
          final label = _normalizeReportText(dealer.name);
          dealerOptions[id] = SalesReportOption(
            id: id,
            label: label.isNotEmpty ? label : id,
          );
        }
        final route = _normalizeReportText(dealer.assignedRouteName);
        if (route.isNotEmpty) routes.add(route);
        final district = _normalizeReportText(dealer.city);
        if (district.isNotEmpty) districts.add(district);
        final division = _normalizeReportText(dealer.territory);
        if (division.isNotEmpty) divisions.add(division);
      }

      final divisionList = divisions.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      final districtList = districts.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      final routeList = routes.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      final salesmenList = salesmen.values.toList()
        ..sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );
      final dealerList = dealerOptions.values.toList()
        ..sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );

      if (years.isEmpty) years.add(DateTime.now().year);
      final yearList = years.toList()..sort((a, b) => b.compareTo(a));

      return SalesReportFilterMeta(
        divisions: divisionList,
        districts: districtList,
        routes: routeList,
        salesmen: salesmenList,
        dealers: dealerList,
        years: yearList,
      );
    } catch (e) {
      throw handleError(e, 'getSalesReportFilterMeta');
    }
  }

  Future<SalesAdvancedReport> getSalesAdvancedReport(
    SalesReportQuery query,
  ) async {
    try {
      final queryStart = query.startDate == null
          ? null
          : DateTime(
              query.startDate!.year,
              query.startDate!.month,
              query.startDate!.day,
            );
      final queryEnd = query.endDate == null ? null : _endOfDay(query.endDate!);

      final sales = await _loadSalesForAdvancedReportPaged(
        queryStart: queryStart,
        queryEnd: queryEnd,
      );

      if (sales.isEmpty) {
        return const SalesAdvancedReport(
          records: <SalesReportRecord>[],
          trend: <SalesReportBucket>[],
          byDivision: <SalesReportBucket>[],
          byDistrict: <SalesReportBucket>[],
          byRoute: <SalesReportBucket>[],
          bySalesman: <SalesReportBucket>[],
          byDealer: <SalesReportBucket>[],
          totalRevenue: 0,
          totalTransactions: 0,
          totalLineItems: 0,
          totalQuantity: 0,
          averageOrderValue: 0,
        );
      }

      final saleIds = sales
          .map((sale) => _normalizeReportText(sale.id))
          .where((id) => id.isNotEmpty)
          .toSet();
      final vouchers = await _dbService.vouchers.where().findAll();
      final voucherBySale = _mapBestVoucherBySaleId(vouchers, saleIds);
      final dealers = await _dbService.dealers.where().findAll();
      final customers = await _dbService.customers.where().findAll();

      final dealerById = <String, DealerEntity>{
        for (final dealer in dealers)
          if (_normalizeReportText(dealer.id).isNotEmpty)
            _normalizeReportText(dealer.id): dealer,
      };
      final customerById = <String, CustomerEntity>{
        for (final customer in customers)
          if (_normalizeReportText(customer.id).isNotEmpty)
            _normalizeReportText(customer.id): customer,
      };

      final recipientFilter = _normalizeReportText(
        query.recipientType,
      ).toLowerCase();

      final records = <SalesReportRecord>[];
      for (final sale in sales) {
        final createdAt = DateTime.tryParse(sale.createdAt);
        if (createdAt == null) continue;
        if (queryStart != null && createdAt.isBefore(queryStart)) continue;
        if (queryEnd != null && createdAt.isAfter(queryEnd)) continue;

        final status = _normalizeReportText(sale.status).toLowerCase();
        if (!query.includeCancelled && status == 'cancelled') {
          continue;
        }

        final recipientType = _normalizeReportText(
          sale.recipientType,
        ).toLowerCase();
        if (recipientFilter.isNotEmpty &&
            recipientFilter != 'all' &&
            recipientType != recipientFilter) {
          continue;
        }

        final saleId = _normalizeReportText(sale.id);
        final recipientId = _normalizeReportText(sale.recipientId);
        final voucher = voucherBySale[saleId];
        final dealer = dealerById[recipientId];
        final customer = customerById[recipientId];

        final route = _normalizeReportText(
          voucher?.route ??
              sale.route ??
              (recipientType == 'customer' ? customer?.route : null) ??
              (recipientType == 'dealer' ? dealer?.assignedRouteName : null),
        );
        final district = _normalizeReportText(
          voucher?.district ??
              (recipientType == 'dealer' ? dealer?.city : null),
        );
        final division = _normalizeReportText(
          voucher?.division ??
              (recipientType == 'dealer' ? dealer?.territory : null),
        );
        final salesmanId = _normalizeReportText(
          voucher?.salesmanId ?? sale.salesmanId,
        );
        final salesmanName = _normalizeReportText(
          voucher?.salesmanName ?? sale.salesmanName,
        );
        final dealerId = _normalizeReportText(
          voucher?.dealerId ?? (recipientType == 'dealer' ? recipientId : null),
        );
        final dealerName = _normalizeReportText(
          voucher?.dealerName ??
              (dealerId.isNotEmpty ? dealerById[dealerId]?.name : null) ??
              (recipientType == 'dealer' ? sale.recipientName : null),
        );

        if (!_matchesTextFilter(division, query.division)) continue;
        if (!_matchesTextFilter(district, query.district)) continue;
        if (!_matchesTextFilter(route, query.route)) continue;
        if (!_matchesIdFilter(salesmanId, query.salesmanId)) continue;
        if (!_matchesIdFilter(dealerId, query.dealerId)) continue;

        final invoiceId = _normalizeReportText(sale.humanReadableId).isNotEmpty
            ? sale.humanReadableId!.trim()
            : (sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id);

        records.add(
          SalesReportRecord(
            saleId: sale.id,
            invoiceId: invoiceId,
            createdAt: createdAt,
            recipientType: recipientType,
            recipientId: recipientId,
            recipientName: _normalizeReportText(sale.recipientName),
            salesmanId: salesmanId,
            salesmanName: _displayOrUnassigned(salesmanName),
            route: _displayOrUnassigned(route),
            district: _displayOrUnassigned(district),
            division: _displayOrUnassigned(division),
            dealerId: dealerId,
            dealerName: _displayOrUnassigned(dealerName),
            status: _normalizeReportText(sale.status),
            totalAmount: _round((sale.totalAmount ?? 0).toDouble()),
            lineItems: _countSaleLineItems(sale),
            quantity: _sumSaleQuantity(sale),
          ),
        );
      }

      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final aggregateInput = records
          .map(
            (record) => <String, dynamic>{
              'createdAt': record.createdAt.toIso8601String(),
              'totalAmount': record.totalAmount,
              'quantity': record.quantity,
              'lineItems': record.lineItems,
              'division': record.division,
              'district': record.district,
              'route': record.route,
              'salesmanId': record.salesmanId,
              'salesmanName': record.salesmanName,
              'dealerId': record.dealerId,
              'dealerName': record.dealerName,
            },
          )
          .toList(growable: false);
      late final Map<String, dynamic> aggregate;
      try {
        aggregate = await _computeSalesAdvancedAggregateBackground(
          aggregateInput,
          groupByName: query.groupBy.name,
        );
      } catch (_) {
        // Fail-open fallback keeps report generation functional even if
        // isolate transport rejects payload at runtime.
        aggregate = _computeSalesAdvancedAggregate(
          aggregateInput,
          groupByName: query.groupBy.name,
        );
      }
      final trend = _bucketListFromAggregate(aggregate['trend']);
      final byDivision = _bucketListFromAggregate(aggregate['byDivision']);
      final byDistrict = _bucketListFromAggregate(aggregate['byDistrict']);
      final byRoute = _bucketListFromAggregate(aggregate['byRoute']);
      final bySalesman = _bucketListFromAggregate(aggregate['bySalesman']);
      final byDealer = _bucketListFromAggregate(aggregate['byDealer']);
      final totalTransactions =
          (aggregate['totalTransactions'] as num?)?.toInt() ?? records.length;
      final totalRevenue =
          _round((aggregate['totalRevenue'] as num?)?.toDouble() ?? 0);
      final totalLineItems =
          (aggregate['totalLineItems'] as num?)?.toInt() ?? 0;
      final totalQuantity =
          (aggregate['totalQuantity'] as num?)?.toInt() ?? 0;
      final averageOrderValue =
          _round((aggregate['averageOrderValue'] as num?)?.toDouble() ?? 0);

      return SalesAdvancedReport(
        records: records,
        trend: trend,
        byDivision: byDivision,
        byDistrict: byDistrict,
        byRoute: byRoute,
        bySalesman: bySalesman,
        byDealer: byDealer,
        totalRevenue: _round(totalRevenue),
        totalTransactions: totalTransactions,
        totalLineItems: totalLineItems,
        totalQuantity: totalQuantity,
        averageOrderValue: averageOrderValue,
      );
    } catch (e) {
      throw handleError(e, 'getSalesAdvancedReport');
    }
  }

  Future<Map<String, dynamic>> getSalesmanPerformanceReport(
    FilterOptions filters,
  ) async {
    try {
      // 1. Fetch Salesmen from Isar (in-memory filter)
      final allUsers = await _dbService.users.where().findAll();
      final salesmen = allUsers
          .where((u) => u.role != null && u.role == UserRole.salesman.value)
          .toList();

      final overallStats = SalesmanOverallStats(
        activeSalesmen: salesmen.where((d) => d.status == 'active').length,
      );

      if (salesmen.isEmpty) {
        return {'performanceData': [], 'overallStats': overallStats};
      }

      final performanceMap = <String, SalesmanPerformanceData>{};
      for (var user in salesmen) {
        performanceMap[user.id] = SalesmanPerformanceData(
          salesmanId: user.id,
          salesmanName: user.name ?? '',
        );
      }

      // 2. Fetch customer sales with DB-side recipient/date predicates.
      final sales = await _loadCustomerSalesForPerformance(filters);

      for (var sale in sales) {
        final sId = sale.salesmanId;
        if (performanceMap.containsKey(sId)) {
          final perf = performanceMap[sId]!;
          final amt = sale.totalAmount ?? 0.0;
          final itemCount =
              sale.items?.fold<int>(
                0,
                (sum, item) => sum + (item.quantity ?? 0),
              ) ??
              0;

          perf.totalRevenue = _round(perf.totalRevenue + amt);
          perf.totalItemsSold += itemCount;
          perf.totalSales += 1;

          overallStats.totalRevenue = _round(overallStats.totalRevenue + amt);
          overallStats.totalItemsSold += itemCount;
          overallStats.totalSales += 1;
        }
      }

      // 3. Targets from Isar (in-memory filter)
      int targetMonth = filters.startDate?.month ?? DateTime.now().month;
      int targetYear = filters.startDate?.year ?? DateTime.now().year;

      final allTargets = await _dbService.salesTargets.where().findAll();
      final targets = allTargets
          .where((t) => t.month == targetMonth && t.year == targetYear)
          .toList();

      for (var target in targets) {
        if (performanceMap.containsKey(target.salesmanId)) {
          performanceMap[target.salesmanId]!.totalTarget = target.targetAmount;
        }
      }

      // Calc Percentages
      for (var perf in performanceMap.values) {
        if (perf.totalTarget > 0) {
          perf.achievementPercentage =
              (perf.totalRevenue / perf.totalTarget) * 100;
          perf.achievedAmount = perf.totalRevenue;
        }
      }

      final sortedList = performanceMap.values.toList()
        ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

      return {'performanceData': sortedList, 'overallStats': overallStats};
    } catch (e) {
      throw handleError(e, 'getSalesmanPerformanceReport');
    }
  }

  Future<List<VehiclePerformanceData>> getVehiclePerformanceReport(
    FilterOptions filters,
  ) async {
    try {
      // 1. Fetch Vehicles from Isar
      final vehicles = await _dbService.vehicles.where().findAll();

      // 2. Fetch Diesel Logs from Isar with DB-side date predicates.
      final endOfDay = filters.endDate == null
          ? null
          : _endOfDay(filters.endDate!);
      List<DieselLogEntity> logs;
      if (filters.startDate != null && endOfDay != null) {
        logs = await _dbService.dieselLogs
            .filter()
            .fillDateBetween(
              filters.startDate!,
              endOfDay,
              includeLower: true,
              includeUpper: true,
            )
            .findAll();
      } else if (filters.startDate != null) {
        logs = await _dbService.dieselLogs
            .filter()
            .fillDateGreaterThan(filters.startDate!, include: true)
            .findAll();
      } else if (endOfDay != null) {
        logs = await _dbService.dieselLogs
            .filter()
            .fillDateLessThan(endOfDay, include: true)
            .findAll();
      } else {
        logs = await _dbService.dieselLogs.where().findAll();
      }

      final logsByVehicle = <String, List<DieselLogEntity>>{};
      for (final log in logs) {
        logsByVehicle
            .putIfAbsent(log.vehicleId, () => <DieselLogEntity>[])
            .add(log);
      }

      final List<VehiclePerformanceData> report = [];

      for (var vehicle in vehicles) {
        final vLogs = logsByVehicle[vehicle.id] ?? const <DieselLogEntity>[];

        double totalDist = 0;
        double totalLiters = 0;
        double totalCost = 0;

        for (var l in vLogs) {
          totalDist += l.distance ?? 0;
          totalLiters += l.liters;
          totalCost += l.totalCost;
        }

        final maintCost = vehicle.totalMaintenanceCost;
        final tyreCost = vehicle.totalTyreCost;
        final otherCosts = maintCost + tyreCost;

        final actualAvg = totalLiters > 0 ? totalDist / totalLiters : 0.0;
        final costPerKm = totalDist > 0
            ? (totalCost + otherCosts) / totalDist
            : 0.0;

        report.add(
          VehiclePerformanceData(
            id: vehicle.id,
            name: vehicle.name,
            number: vehicle.number,
            totalDistance: totalDist,
            totalDieselCost: totalCost,
            totalMaintenanceCost: maintCost,
            totalTyreCost: tyreCost,
            actualAverage: actualAvg,
            costPerKm: costPerKm,
            minAverage: vehicle.minAverage,
            maxAverage: vehicle.maxAverage,
          ),
        );
      }

      report.sort((a, b) => b.totalDistance.compareTo(a.totalDistance));
      return report;
    } catch (e) {
      throw handleError(e, 'getVehiclePerformanceReport');
    }
  }

  // Simplified version of Dealer Report to avoid complexity - can implement fully if needed
  // Using original implementation:
  Future<Map<String, dynamic>> getDealerPerformanceReport(
    FilterOptions filters,
  ) async {
    try {
      // Offline-First: Fetch from Isar
      final dealers = (filters.dealerId != null && filters.dealerId != 'all')
          ? await _dbService.dealers
                .where()
                .idEqualTo(filters.dealerId!)
                .findAll()
          : await _dbService.dealers.where().findAll();

      final dealerStats = DealerOverallStats(
        activeDealers: dealers.where((d) => d.status == 'active').length,
      );

      if (dealers.isEmpty) {
        return {'performanceData': [], 'overallStats': dealerStats};
      }

      final resultList = <DealerPerformanceData>[];
      final perfMap = <String, DealerPerformanceData>{};
      for (var d in dealers) {
        perfMap[d.id] = DealerPerformanceData(
          dealerId: d.id,
          dealerName: d.name,
        );
      }

      // Fetch Sales for Dealiers
      var salesQuery = _dbService.sales.filter().recipientTypeEqualTo('dealer');

      if (filters.startDate != null && filters.endDate != null) {
        salesQuery = salesQuery.createdAtBetween(
          filters.startDate!.toIso8601String(),
          DateTime(
            filters.endDate!.year,
            filters.endDate!.month,
            filters.endDate!.day,
            23,
            59,
            59,
          ).toIso8601String(),
        );
      } else if (filters.startDate != null) {
        salesQuery = salesQuery.createdAtGreaterThan(
          filters.startDate!.toIso8601String(),
        );
      }

      final sales = await salesQuery.findAll();

      for (var s in sales) {
        final dId = s.recipientId;

        if (perfMap.containsKey(dId)) {
          final stats = perfMap[dId]!;
          final amt = s.totalAmount ?? 0.0;
          final createdAt = s.createdAt;

          stats.totalOrders += 1;
          stats.totalRevenue = _round(stats.totalRevenue + amt);

          // Last Order Date
          if (stats.lastOrderDate == null ||
              createdAt.compareTo(stats.lastOrderDate!) > 0) {
            stats.lastOrderDate = createdAt;
          }

          // Top Product Logic
          for (SaleItemEntity item in s.items ?? <SaleItemEntity>[]) {
            final pName = item.name ?? 'Unknown';
            final qty = item.quantity ?? 0;
            stats._productCounts[pName] =
                (stats._productCounts[pName] ?? 0) + qty;
          }

          dealerStats.totalOrders += 1;
          dealerStats.totalRevenue = _round(dealerStats.totalRevenue + amt);
        }
      }

      // Determine Top Product
      for (var stats in perfMap.values) {
        if (stats._productCounts.isNotEmpty) {
          var top = stats._productCounts.entries.first;
          for (var entry in stats._productCounts.entries) {
            if (entry.value > top.value) top = entry;
          }
          stats.topProduct = top.key;
        }
      }

      resultList.addAll(perfMap.values);
      resultList.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

      return {'performanceData': resultList, 'overallStats': dealerStats};
    } catch (e) {
      throw handleError(e, 'getDealerPerformanceReport');
    }
  }

  Future<List<ProfitMarginData>> getProfitMarginReport(
    FilterOptions filters,
  ) async {
    try {
      // Offline-First: Fetch from Isar
      var salesQuery = _dbService.sales.filter().recipientTypeEqualTo(
        'customer',
      );

      if (filters.startDate != null && filters.endDate != null) {
        salesQuery = salesQuery.createdAtBetween(
          filters.startDate!.toIso8601String(),
          DateTime(
            filters.endDate!.year,
            filters.endDate!.month,
            filters.endDate!.day,
            23,
            59,
            59,
          ).toIso8601String(),
        );
      } else if (filters.startDate != null) {
        salesQuery = salesQuery.createdAtGreaterThan(
          filters.startDate!.toIso8601String(),
        );
      }

      final sales = await salesQuery.findAll();

      // Fetch products for cost lookups (Local)
      final localProducts = await _dbService.products.where().findAll();
      final productCostMap = <String, double>{};

      for (var p in localProducts) {
        final cost =
            _decryptProductDouble(p.id, 'averageCost', p.averageCost) ??
            _decryptProductDouble(p.id, 'purchasePrice', p.purchasePrice) ??
            0.0;
        productCostMap[p.id] = cost;
      }

      final marginMap = <String, ProfitMarginData>{};

      for (var s in sales) {
        for (SaleItemEntity item in s.items ?? <SaleItemEntity>[]) {
          final productId = item.productId;
          if (productId == null) continue;

          final quantity = (item.quantity ?? 0).toDouble();
          final price = (item.price ?? 0.0).toDouble();
          final name = item.name ?? 'Unknown';

          final costPerUnit = productCostMap[productId] ?? 0.0;
          final revenue = item.lineNetAmount ?? (quantity * price);
          final cost = quantity * costPerUnit;

          if (!marginMap.containsKey(productId)) {
            marginMap[productId] = ProfitMarginData(
              productId: productId,
              productName: name,
            );
          }

          final entry = marginMap[productId]!;
          entry.totalRevenue += revenue;
          entry.totalCost += cost;
          entry.totalQuantity += quantity;
        }
      }

      final reportData = marginMap.values.toList();
      for (var entry in reportData) {
        entry.grossMargin = entry.totalRevenue - entry.totalCost;
        entry.marginPercentage = entry.totalRevenue > 0
            ? (entry.grossMargin / entry.totalRevenue) * 100
            : 0;
      }

      reportData.sort((a, b) => b.grossMargin.compareTo(a.grossMargin));
      return reportData;
    } catch (e) {
      throw handleError(e, 'getProfitMarginReport');
    }
  }

  Future<StockValuationReport> getStockValuationReport() async {
    try {
      // Offline-First: Fetch from Isar
      final products = await _dbService.products.where().findAll();

      double totalSysValue = 0;
      final items = <StockValuationItem>[];

      for (var product in products) {
        // Skip deleted or inactive if you have a status field in entity
        if (product.status != 'active') continue;

        final cost =
            _decryptProductDouble(
              product.id,
              'averageCost',
              product.averageCost,
            ) ??
            _decryptProductDouble(product.id, 'price', product.price) ??
            0.0;
        final stock = product.stock ?? 0.0;
        final val = stock * cost;

        totalSysValue += val;

        items.add(
          StockValuationItem(
            productId: product.id,
            productName: product.name,
            category: product.category ?? 'General',
            stock: stock,
            unit: product.baseUnit,
            costPerUnit: cost,
            totalValue: val,
          ),
        );
      }

      items.sort((a, b) => b.totalValue.compareTo(a.totalValue));

      return StockValuationReport(items: items, totalValue: totalSysValue);
    } catch (e) {
      throw handleError(e, 'getStockValuationReport');
    }
  }

  Future<SalesDispatchReport> getSalesDispatchReport(
    FilterOptions filters,
  ) async {
    try {
      // Offline-First: Fetch from Isar
      // Note: For large datasets, Isar's .filter() is better, but composite queries can be tricky.
      // Fetching all 'Sales' isn't too heavy for a local DB usually (10k-50k records is fine).
      // We can optimize with date range filter at Isar level.
      List<SaleEntity> salesEntities;

      if (filters.startDate != null && filters.endDate != null) {
        // Simple optimization: filtering by date if possible
        // SaleEntity.createdAt is String (ISO 8601)
        final start = filters.startDate!.toIso8601String();
        final end = DateTime(
          filters.endDate!.year,
          filters.endDate!.month,
          filters.endDate!.day,
          23,
          59,
          59,
        ).toIso8601String();

        salesEntities = await _dbService.sales
            .filter()
            .createdAtBetween(start, end)
            .findAll();
      } else if (filters.startDate != null) {
        salesEntities = await _dbService.sales
            .filter()
            .createdAtGreaterThan(filters.startDate!.toIso8601String())
            .findAll();
      } else {
        // Fallback if no date filter (Risk of large fetch, but 'All Time' is rare)
        salesEntities = await _fetchAllSalesPaged();
      }

      // Convert to Domain/Map equivalent for processing
      // Keeping it simple: Map what we need or check Entity directly
      List<Map<String, dynamic>> sales = [];

      for (var s in salesEntities) {
        // In-Memory Filters that stick to the plan
        if (filters.endDate != null && filters.startDate == null) {
          // If only endDate provided (unlikely in UI but safe check)
          final eod = DateTime(
            filters.endDate!.year,
            filters.endDate!.month,
            filters.endDate!.day,
            23,
            59,
            59,
          );
          if (DateTime.parse(s.createdAt).isAfter(eod)) continue;
        }

        if (filters.salesmanId != null && filters.salesmanId != 'all') {
          if (s.salesmanId != filters.salesmanId) continue;
        }

        if (filters.route != null && filters.route != 'all') {
          if (s.route != filters.route) continue;
        }

        // Recipient Type / Transaction Type
        if (filters.dealerId == 'customer') {
          if (s.recipientType != 'customer') continue;
        } else if (filters.dealerId == 'dealer') {
          if (s.recipientType != 'dealer') continue;
        } else if (filters.dealerId == 'salesman') {
          if (s.recipientType != 'salesman') continue;
        }

        // Map Entity to Map for existing stats logic (lazy migration)
        sales.add({
          'id': s.id,
          'totalAmount': s.totalAmount,
          'recipientType': s.recipientType,
          'recipientName': s.recipientName,
          'humanReadableId': s.humanReadableId ?? s.id.substring(0, 6),
          'gstType': s.gstType ?? 'None',
          'salesmanId': s.salesmanId,
          'salesmanName': s.salesmanName,
          'createdAt': s.createdAt,
          'route': s.route,
          'items':
              s.items
                  ?.map(
                    (i) => {
                      'name': i.name,
                      'quantity': i.quantity,
                      'price': i.price,
                    },
                  )
                  .toList() ??
              [],
        });
      }

      final includeDispatches =
          filters.dealerId == null ||
          filters.dealerId == 'all' ||
          filters.dealerId == 'salesman';
      if (includeDispatches) {
        final dispatches = await _loadLocalDispatches();
        final endOfDay = (filters.endDate != null)
            ? DateTime(
                filters.endDate!.year,
                filters.endDate!.month,
                filters.endDate!.day,
                23,
                59,
                59,
              )
            : null;
        for (final dispatch in dispatches) {
          final createdAtStr = dispatch['createdAt']?.toString();
          if (createdAtStr == null || createdAtStr.isEmpty) continue;
          final createdAt = DateTime.tryParse(createdAtStr);
          if (createdAt == null) continue;
          if (filters.startDate != null &&
              createdAt.isBefore(filters.startDate!)) {
            continue;
          }
          if (endOfDay != null && createdAt.isAfter(endOfDay)) continue;

          if (filters.salesmanId != null &&
              filters.salesmanId != 'all' &&
              dispatch['salesmanId'] != filters.salesmanId) {
            continue;
          }

          if (filters.route != null && filters.route != 'all') {
            final route = _resolveDispatchRoute(dispatch);
            if (route != filters.route) continue;
          }

          sales.add(_mapDispatchToSalesRecord(dispatch));
        }
      }

      double totalRevenue = 0;
      int totalTransactions = sales.length;
      int totalItemsSold = 0;
      double totalCustomerSales = 0;
      double totalDealerDispatches = 0;
      double totalSalesmanDispatches = 0;

      final salesmanStats = <String, Map<String, dynamic>>{};
      final productStats = <String, Map<String, dynamic>>{};

      for (var sale in sales) {
        final amt = (sale['totalAmount'] as num? ?? 0).toDouble();
        totalRevenue += amt;

        final rType = sale['recipientType'] as String?;
        if (rType == 'customer') totalCustomerSales += amt;
        if (rType == 'dealer') totalDealerDispatches += amt;
        if (rType == 'salesman') totalSalesmanDispatches += amt;

        // Salesman Stats
        final sId = sale['salesmanId'] as String? ?? 'unknown';
        final sName = sale['salesmanName'] as String? ?? 'Unknown';

        if (!salesmanStats.containsKey(sId)) {
          salesmanStats[sId] = {'name': sName, 'revenue': 0.0, 'count': 0};
        }
        salesmanStats[sId]!['revenue'] += amt;
        salesmanStats[sId]!['count'] += 1;

        // Product Stats
        final items = (sale['items'] as List?) ?? [];
        for (var item in items) {
          final pName = item['name'] as String? ?? 'Unknown';
          final qty = (item['quantity'] as num? ?? 0).toInt();
          final price = (item['price'] as num? ?? 0).toDouble();
          final lineNet = (item['lineNetAmount'] as num?)?.toDouble();

          totalItemsSold += qty;

          if (!productStats.containsKey(pName)) {
            productStats[pName] = {
              'name': pName,
              'quantity': 0,
              'revenue': 0.0,
              'count': 0,
            };
          }
          productStats[pName]!['quantity'] += qty;
          productStats[pName]!['revenue'] += lineNet ?? (qty * price);
          productStats[pName]!['count'] += 1;
        }
      }

      // Determine Top Salesman
      Map<String, dynamic> topSalesman = {
        'name': '-',
        'revenue': 0.0,
        'count': 0,
      };
      if (salesmanStats.isNotEmpty) {
        final sorted = salesmanStats.values.toList()
          ..sort(
            (a, b) =>
                (b['revenue'] as double).compareTo(a['revenue'] as double),
          );
        if (sorted.isNotEmpty) topSalesman = sorted.first;
      }

      // Determine Top Product
      Map<String, dynamic> topProduct = {
        'name': '-',
        'quantity': 0,
        'revenue': 0.0,
      };
      if (productStats.isNotEmpty) {
        final sorted = productStats.values.toList()
          ..sort(
            (a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int),
          );
        if (sorted.isNotEmpty) topProduct = sorted.first;
      }

      return SalesDispatchReport(
        totalRevenue: totalRevenue,
        totalTransactions: totalTransactions,
        totalItemsSold: totalItemsSold,
        avgTransactionValue: totalTransactions > 0
            ? totalRevenue / totalTransactions
            : 0,
        totalCustomerSales: totalCustomerSales,
        totalDealerDispatches: totalDealerDispatches,
        totalSalesmanDispatches: totalSalesmanDispatches,
        topSalesmanName: topSalesman['name'] as String,
        topSalesmanRevenue: (topSalesman['revenue'] as num).toDouble(),
        topProductName: topProduct['name'] as String,
        topProductQuantity: (topProduct['quantity'] as num).toInt(),
        sales: sales, // Return processed map list
      );
    } catch (e) {
      throw handleError(e, 'getSalesDispatchReport');
    }
  }

  Future<List<Map<String, dynamic>>> getStocksMovement({
    String? productId,
    String? movementType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 1. Local First Strategy (True Offline History)
      List<StockLedgerEntity> movements;
      final boundedEnd = endDate == null ? null : _endOfDay(endDate);
      if (startDate != null && boundedEnd != null) {
        movements = await _dbService.stockLedger
            .filter()
            .transactionDateBetween(
              startDate,
              boundedEnd,
              includeLower: true,
              includeUpper: true,
            )
            .findAll();
      } else if (startDate != null) {
        movements = await _dbService.stockLedger
            .filter()
            .transactionDateGreaterThan(startDate, include: true)
            .findAll();
      } else if (boundedEnd != null) {
        movements = await _dbService.stockLedger
            .filter()
            .transactionDateLessThan(boundedEnd, include: true)
            .findAll();
      } else if (productId != null && productId.isNotEmpty) {
        movements = await _dbService.stockLedger
            .filter()
            .productIdEqualTo(productId)
            .findAll();
      } else {
        movements = await _fetchAllStockLedgerPaged();
      }

      // Filter by Product
      if (productId != null && productId.isNotEmpty) {
        movements = movements.where((m) => m.productId == productId).toList();
      }

      // In-memory filtering for remaining fields (MovementType)
      if (movementType != null) {
        final typeSig = movementType.toUpperCase();
        // Map 'in' to 'IN', 'out' to 'OUT'
        // But LEDGER might have 'ADJUSTMENT', 'OPENING', which we need to classify?
        // Usually transactionType is IN, OUT, OPENING.
        if (typeSig == 'IN') {
          movements = movements
              .where(
                (m) =>
                    m.transactionType == 'IN' ||
                    m.transactionType == 'RETURN_DEPT' ||
                    m.quantityChange > 0,
              )
              .toList();
        } else if (typeSig == 'OUT') {
          movements = movements
              .where(
                (m) =>
                    m.transactionType == 'OUT' ||
                    m.transactionType == 'ISSUE_DEPT' ||
                    m.quantityChange < 0,
              )
              .toList();
        }
      }

      final productMap = await _loadProductNameMap(
        movements.map((m) => m.productId),
      );
      final userMap = await _loadUserNameMap(
        movements.map((m) => m.performedBy),
      );
      final returnSalesmanNameMap = await _loadReturnSalesmanNameMap(
        movements.map((m) => m.referenceId),
      );

      // Map to UI expected format
      // Expected: quantity, movementType ('in'/'out'), createdAt (Timestamp), reason, userName, productName
      final result = <Map<String, dynamic>>[];

      for (var m in movements) {
        final pName = productMap[m.productId] ?? 'Unknown Product';
        final returnSalesmanName =
            (m.referenceId == null || m.referenceId!.trim().isEmpty)
            ? null
            : returnSalesmanNameMap[m.referenceId!.trim()];

        String reasonText = m.transactionType;
        if (m.notes != null &&
            m.notes!.trim().isNotEmpty &&
            m.notes != 'Auto-generated') {
          reasonText = m.notes!;
        }
        reasonText = _normalizeStockMovementReason(
          rawReason: reasonText,
          transactionType: m.transactionType,
          returnSalesmanName: returnSalesmanName,
        );
        final uName = _resolveStockMovementUserName(
          performedBy: m.performedBy,
          userMap: userMap,
          normalizedReason: reasonText,
          returnSalesmanName: returnSalesmanName,
        );

        result.add({
          'id': m.id,
          'productId': m.productId,
          'productName': pName,
          'quantity': m.quantityChange.abs(),
          'movementType': m.quantityChange >= 0 ? 'in' : 'out',
          'createdAt': firestore.Timestamp.fromDate(
            m.transactionDate,
          ), // UI expects Timestamp
          'reason': reasonText,
          'referenceId': m.referenceId,
          'userName': uName,
        });
      }

      // Sort desc
      result.sort(
        (a, b) => (b['createdAt'] as firestore.Timestamp).compareTo(
          a['createdAt'] as firestore.Timestamp,
        ),
      );

      return result;
    } catch (e) {
      // Fallback or Log
      // throw handleError(e, 'getStocksMovement');
      // If local fails, maybe return empty list rather than crash
      return [];
    }
  }
}

class SalesDispatchReport {
  final double totalRevenue;
  final int totalTransactions;
  final int totalItemsSold;
  final double avgTransactionValue;
  final double totalCustomerSales;
  final double totalDealerDispatches;
  final double totalSalesmanDispatches;
  final String topSalesmanName;
  final double topSalesmanRevenue;
  final String topProductName;
  final int topProductQuantity;
  final List<Map<String, dynamic>> sales;

  SalesDispatchReport({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.avgTransactionValue,
    required this.totalCustomerSales,
    required this.totalDealerDispatches,
    required this.totalSalesmanDispatches,
    required this.topSalesmanName,
    required this.topSalesmanRevenue,
    required this.topProductName,
    required this.topProductQuantity,
    required this.sales,
  });
}
