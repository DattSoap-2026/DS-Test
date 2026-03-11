import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/local/entities/dealer_entity.dart';
import '../../data/local/entities/sale_entity.dart';
import '../../data/repositories/dealer_repository.dart';
import '../../data/repositories/sales_repository.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../widgets/reports/report_export_actions.dart';

class DealerDetailHistoryScreen extends StatefulWidget {
  final String dealerId;
  final String? dealerName;

  const DealerDetailHistoryScreen({
    super.key,
    required this.dealerId,
    this.dealerName,
  });

  @override
  State<DealerDetailHistoryScreen> createState() =>
      _DealerDetailHistoryScreenState();
}

class _DealerDetailHistoryScreenState
    extends State<DealerDetailHistoryScreen>
    with ReportPdfMixin<DealerDetailHistoryScreen> {
  static const int _pageSize = 10;

  bool _isLoading = true;
  DealerEntity? _dealer;
  List<SaleEntity> _sales = [];
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dealerRepo = context.read<DealerRepository>();
      final salesRepo = context.read<SalesRepository>();

      final dealer = await dealerRepo.getDealerById(widget.dealerId);
      final allSales = await salesRepo.getAllSales();
      final normalizedName = _normalizeToken(
        dealer?.name ?? widget.dealerName ?? '',
      );

      final filtered = allSales.where((sale) {
        if (!_isDealerSale(sale)) return false;
        if (sale.recipientId == widget.dealerId) return true;
        if (normalizedName.isEmpty) return false;
        return _normalizeToken(sale.recipientName) == normalizedName;
      }).toList()
        ..sort((a, b) => _parseDate(b.createdAt).compareTo(_parseDate(a.createdAt)));

      if (!mounted) return;
      setState(() {
        _dealer = dealer;
        _sales = filtered;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load dealer history')),
      );
    }
  }

  String _normalizeToken(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_\-\s]+'), '');
  }

  bool _isDealerSale(SaleEntity sale) {
    final recipientType = _normalizeToken(sale.recipientType);
    final saleType = _normalizeToken(sale.saleType);
    return recipientType == 'dealer' ||
        saleType == 'directdealer' ||
        saleType == 'dealer';
  }

  double _saleAmount(SaleEntity sale) {
    return sale.totalAmount ?? sale.taxableAmount ?? sale.subtotal ?? 0;
  }

  bool _isPendingDispatch(SaleEntity sale) {
    final status = _normalizeToken(sale.status);
    return status == 'created' ||
        status == 'pending' ||
        status == 'pendingdispatch' ||
        status == 'intransit';
  }

  DateTime _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(iso)?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDate(String? iso, {String pattern = 'dd MMM yyyy, hh:mm a'}) {
    final date = _parseDate(iso);
    if (date.millisecondsSinceEpoch == 0) return '-';
    return DateFormat(pattern).format(date);
  }

  String _formatCurrency(double amount, {int decimals = 2}) {
    final formatted = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: decimals,
    ).format(amount);
    return 'Rs ${formatted.trim()}';
  }

  int get _totalPages {
    if (_sales.isEmpty) return 1;
    return (_sales.length / _pageSize).ceil();
  }

  List<SaleEntity> get _currentPageSales {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _sales.length) return const [];
    final end = (start + _pageSize).clamp(0, _sales.length);
    return _sales.sublist(start, end);
  }

  @override
  bool get hasExportData => _sales.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return const [
      'Date',
      'Order ID',
      'Status',
      'Items',
      'Amount',
      'Salesman',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _sales
        .map(
          (sale) => [
            _formatDate(sale.createdAt, pattern: 'dd MMM yyyy'),
            sale.id,
            (sale.status ?? '-'),
            (sale.items?.length ?? 0).toString(),
            _formatCurrency(_saleAmount(sale)),
            sale.salesmanName,
          ],
        )
        .toList(growable: false);
  }

  @override
  Map<String, String> buildFilterSummary() {
    final totalRevenue = _sales.fold<double>(0, (sum, sale) => sum + _saleAmount(sale));
    return {
      'Dealer': _dealer?.name ?? widget.dealerName ?? '-',
      'Orders': _sales.length.toString(),
      'Revenue': _formatCurrency(totalRevenue),
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = _dealer?.name ?? widget.dealerName ?? 'Dealer Details';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Dealer Detail History Report'),
            onPrint: () => printReport('Dealer Detail History Report'),
            onRefresh: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDealerInfoCard(),
                  const SizedBox(height: 12),
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildHistorySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildDealerInfoCard() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dealer?.name ?? widget.dealerName ?? 'Unknown Dealer',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _infoPill('Contact', _dealer?.contactPerson ?? '-'),
                _infoPill('Mobile', _dealer?.mobile ?? '-'),
                _infoPill('Route', _dealer?.assignedRouteName ?? '-'),
                _infoPill('Territory', _dealer?.territory ?? '-'),
                _infoPill('Status', _dealer?.status ?? '-'),
                _infoPill('GSTIN', _dealer?.gstin ?? '-'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${_dealer?.address ?? '-'}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalRevenue = _sales.fold<double>(0, (sum, sale) => sum + _saleAmount(sale));
    final pendingDispatch = _sales.where(_isPendingDispatch).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _statTile('Total Orders', _sales.length.toString()),
            _statTile('Pending Dispatch', pendingDispatch.toString()),
            _statTile('Total Revenue', _formatCurrency(totalRevenue)),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      width: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_sales.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No dispatch/sales records found for this dealer.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dispatch and Sales History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ..._currentPageSales.map(_historyCard),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Page $_currentPage / $_totalPages'),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _currentPage > 1
                  ? () => setState(() => _currentPage -= 1)
                  : null,
              child: const Text('Previous'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _currentPage < _totalPages
                  ? () => setState(() => _currentPage += 1)
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _historyCard(SaleEntity sale) {
    final theme = Theme.of(context);
    final statusRaw = (sale.status ?? '-').trim();
    final status = statusRaw.isEmpty ? '-' : statusRaw;
    final saleItems = sale.items ?? const <SaleItemEntity>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(sale.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatCurrency(_saleAmount(sale)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                Text('Route: ${sale.route ?? '-'}'),
                Text('Vehicle: ${sale.vehicleNumber ?? '-'}'),
                Text('Trip: ${sale.tripId ?? '-'}'),
                Text('Type: ${sale.saleType ?? '-'}'),
              ],
            ),
            const SizedBox(height: 10),
            if (saleItems.isEmpty)
              Text(
                'No item details',
                style: theme.textTheme.bodySmall,
              )
            else
              Column(
                children: saleItems.map((item) {
                  final qty = item.quantity ?? 0;
                  final price = item.price ?? 0;
                  final lineTotal =
                      item.lineTotalAmount ?? (qty.toDouble() * price);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name ?? 'Item',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('$qty x ${_formatCurrency(price)}'),
                        const SizedBox(width: 8),
                        Text(
                          _formatCurrency(lineTotal),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
