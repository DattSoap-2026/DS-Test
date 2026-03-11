import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/types/sales_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/sales_service.dart';
import '../../widgets/ui/unified_card.dart';

enum SalesmanKpiDrilldownMode { dailyShopSales, monthlyRouteSales }

class SalesmanKpiDrilldownScreen extends StatefulWidget {
  final SalesmanKpiDrilldownMode mode;
  final DateTime referenceDate;

  SalesmanKpiDrilldownScreen({
    super.key,
    required this.mode,
    DateTime? referenceDate,
  }) : referenceDate = referenceDate ?? DateTime.now();

  @override
  State<SalesmanKpiDrilldownScreen> createState() =>
      _SalesmanKpiDrilldownScreenState();
}

class _SalesmanKpiDrilldownScreenState extends State<SalesmanKpiDrilldownScreen> {
  static const int _pageSize = 250;
  late final SalesService _salesService;

  bool _isLoading = true;
  String? _errorMessage;
  List<Sale> _sales = const <Sale>[];
  List<_ShopSalesBucket> _shopBuckets = const <_ShopSalesBucket>[];
  List<_RouteSalesBucket> _routeBuckets = const <_RouteSalesBucket>[];
  double _totalAmount = 0;
  int _totalInvoices = 0;
  int _totalUniqueShops = 0;

  @override
  void initState() {
    super.initState();
    _salesService = context.read<SalesService>();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = context.read<AuthProvider>().state.user;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not found.';
        });
        return;
      }

      final range = _dateRangeForMode(widget.mode, widget.referenceDate);
      final sales = await _fetchAllSales(
        salesmanId: user.id,
        startDate: range.start,
        endDate: range.end,
      );

      final totalAmount = sales.fold<double>(0, (sum, sale) {
        return sum + sale.totalAmount;
      });
      final totalInvoices = sales.length;
      final totalUniqueShops = sales
          .map(_recipientKey)
          .where((id) => id.isNotEmpty)
          .toSet()
          .length;

      if (!mounted) return;
      setState(() {
        _sales = sales;
        _totalAmount = totalAmount;
        _totalInvoices = totalInvoices;
        _totalUniqueShops = totalUniqueShops;
        _shopBuckets = widget.mode == SalesmanKpiDrilldownMode.dailyShopSales
            ? _buildShopBuckets(sales)
            : const <_ShopSalesBucket>[];
        _routeBuckets = widget.mode == SalesmanKpiDrilldownMode.monthlyRouteSales
            ? _buildRouteBuckets(sales)
            : const <_RouteSalesBucket>[];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load sales details: $e';
      });
    }
  }

  _DateRange _dateRangeForMode(
    SalesmanKpiDrilldownMode mode,
    DateTime referenceDate,
  ) {
    switch (mode) {
      case SalesmanKpiDrilldownMode.dailyShopSales:
        final day = DateTime(
          referenceDate.year,
          referenceDate.month,
          referenceDate.day,
        );
        return _DateRange(start: day, end: day);
      case SalesmanKpiDrilldownMode.monthlyRouteSales:
        final start = DateTime(referenceDate.year, referenceDate.month, 1);
        final end = DateTime(referenceDate.year, referenceDate.month + 1, 0);
        return _DateRange(start: start, end: end);
    }
  }

  Future<List<Sale>> _fetchAllSales({
    required String salesmanId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    var offset = 0;
    final allSales = <Sale>[];

    while (true) {
      final page = await _salesService.getSalesClient(
        salesmanId: salesmanId,
        startDate: startDate,
        endDate: endDate,
        limit: _pageSize,
        offset: offset,
      );

      if (page.isEmpty) break;
      allSales.addAll(page);

      if (page.length < _pageSize) break;
      offset += page.length;
    }

    return allSales;
  }

  List<_ShopSalesBucket> _buildShopBuckets(List<Sale> sales) {
    final map = <String, _MutableShopBucket>{};
    for (final sale in sales) {
      final key = _recipientKey(sale);
      if (key.isEmpty) continue;
      final bucket = map.putIfAbsent(
        key,
        () => _MutableShopBucket(
          shopKey: key,
          shopName: _recipientName(sale),
          routeName: _routeName(sale.route),
        ),
      );
      bucket.amount += sale.totalAmount;
      bucket.invoices += 1;
      final createdAt = _parseSaleDate(sale.createdAt);
      if (createdAt != null &&
          (bucket.lastSaleAt == null || createdAt.isAfter(bucket.lastSaleAt!))) {
        bucket.lastSaleAt = createdAt;
      }
    }

    final buckets = map.values
        .map(
          (it) => _ShopSalesBucket(
            shopKey: it.shopKey,
            shopName: it.shopName,
            routeName: it.routeName,
            invoices: it.invoices,
            amount: it.amount,
            lastSaleAt: it.lastSaleAt,
          ),
        )
        .toList()
      ..sort((a, b) {
        final amountCompare = b.amount.compareTo(a.amount);
        if (amountCompare != 0) return amountCompare;
        return a.shopName.toLowerCase().compareTo(b.shopName.toLowerCase());
      });
    return buckets;
  }

  List<_RouteSalesBucket> _buildRouteBuckets(List<Sale> sales) {
    final map = <String, _MutableRouteBucket>{};
    for (final sale in sales) {
      final routeName = _routeName(sale.route);
      final bucket = map.putIfAbsent(
        routeName,
        () => _MutableRouteBucket(routeName: routeName),
      );
      bucket.amount += sale.totalAmount;
      bucket.invoices += 1;
      final shopKey = _recipientKey(sale);
      if (shopKey.isNotEmpty) {
        bucket.shopKeys.add(shopKey);
      }
    }

    final buckets = map.values
        .map(
          (it) => _RouteSalesBucket(
            routeName: it.routeName,
            invoices: it.invoices,
            uniqueShops: it.shopKeys.length,
            amount: it.amount,
          ),
        )
        .toList()
      ..sort((a, b) {
        final amountCompare = b.amount.compareTo(a.amount);
        if (amountCompare != 0) return amountCompare;
        return a.routeName.toLowerCase().compareTo(b.routeName.toLowerCase());
      });
    return buckets;
  }

  String _recipientKey(Sale sale) {
    final recipientId = sale.recipientId.trim();
    if (recipientId.isNotEmpty) return recipientId;
    final recipientName = sale.recipientName.trim().toLowerCase();
    return recipientName;
  }

  String _recipientName(Sale sale) {
    final name = sale.recipientName.trim();
    if (name.isNotEmpty) return name;
    final id = sale.recipientId.trim();
    return id.isEmpty ? 'Unknown Shop' : id;
  }

  String _routeName(String? route) {
    final value = route?.trim();
    return (value == null || value.isEmpty) ? 'No Route' : value;
  }

  DateTime? _parseSaleDate(String value) {
    return DateTime.tryParse(value)?.toLocal();
  }

  String _formatMoney(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 2,
    ).format(value);
  }

  String _screenTitle() {
    switch (widget.mode) {
      case SalesmanKpiDrilldownMode.dailyShopSales:
        return 'Daily Shop Sales';
      case SalesmanKpiDrilldownMode.monthlyRouteSales:
        return 'Monthly Route Sales';
    }
  }

  String _periodLabel() {
    switch (widget.mode) {
      case SalesmanKpiDrilldownMode.dailyShopSales:
        return DateFormat('dd MMM yyyy').format(widget.referenceDate);
      case SalesmanKpiDrilldownMode.monthlyRouteSales:
        return DateFormat('MMMM yyyy').format(widget.referenceDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle())),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          UnifiedCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSummaryCard(theme),
        const SizedBox(height: 12),
        if (_sales.isEmpty)
          _buildEmptyState(theme)
        else if (widget.mode == SalesmanKpiDrilldownMode.dailyShopSales)
          ..._shopBuckets.map((bucket) => _buildShopCard(theme, bucket))
        else
          ..._routeBuckets.map((bucket) => _buildRouteCard(theme, bucket)),
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final isDaily = widget.mode == SalesmanKpiDrilldownMode.dailyShopSales;
    final bucketCount = isDaily ? _shopBuckets.length : _routeBuckets.length;
    final bucketLabel = isDaily ? 'Shops' : 'Routes';

    return UnifiedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _periodLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatMoney(_totalAmount),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metric(
                  label: bucketLabel,
                  value: bucketCount.toString(),
                  theme: theme,
                ),
              ),
              Expanded(
                child: _metric(
                  label: 'Invoices',
                  value: _totalInvoices.toString(),
                  theme: theme,
                ),
              ),
              Expanded(
                child: _metric(
                  label: 'Shops',
                  value: _totalUniqueShops.toString(),
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric({
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final message = widget.mode == SalesmanKpiDrilldownMode.dailyShopSales
        ? 'No sales found for this day.'
        : 'No sales found for this month.';
    return UnifiedCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildShopCard(ThemeData theme, _ShopSalesBucket bucket) {
    final timeText = bucket.lastSaleAt == null
        ? '-'
        : DateFormat('hh:mm a').format(bucket.lastSaleAt!);
    return UnifiedCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bucket.shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  '${bucket.routeName} • ${bucket.invoices} invoice(s) • Last $timeText',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMoney(bucket.amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(ThemeData theme, _RouteSalesBucket bucket) {
    final ratio = _totalAmount <= 0 ? 0.0 : (bucket.amount / _totalAmount);
    final share = (ratio * 100).toStringAsFixed(1);
    return UnifiedCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bucket.routeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                _formatMoney(bucket.amount),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${bucket.uniqueShops} shops • ${bucket.invoices} invoice(s) • $share%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange({required this.start, required this.end});
}

class _MutableShopBucket {
  final String shopKey;
  final String shopName;
  final String routeName;
  int invoices = 0;
  double amount = 0;
  DateTime? lastSaleAt;

  _MutableShopBucket({
    required this.shopKey,
    required this.shopName,
    required this.routeName,
  });
}

class _ShopSalesBucket {
  final String shopKey;
  final String shopName;
  final String routeName;
  final int invoices;
  final double amount;
  final DateTime? lastSaleAt;

  const _ShopSalesBucket({
    required this.shopKey,
    required this.shopName,
    required this.routeName,
    required this.invoices,
    required this.amount,
    required this.lastSaleAt,
  });
}

class _MutableRouteBucket {
  final String routeName;
  final Set<String> shopKeys = <String>{};
  int invoices = 0;
  double amount = 0;

  _MutableRouteBucket({required this.routeName});
}

class _RouteSalesBucket {
  final String routeName;
  final int uniqueShops;
  final int invoices;
  final double amount;

  const _RouteSalesBucket({
    required this.routeName,
    required this.uniqueShops,
    required this.invoices,
    required this.amount,
  });
}
