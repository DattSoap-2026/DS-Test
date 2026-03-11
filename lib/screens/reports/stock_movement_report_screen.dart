import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/reports_service.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart';
import '../../widgets/ui/custom_card.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class StockMovementReportScreen extends StatefulWidget {
  const StockMovementReportScreen({super.key});

  @override
  State<StockMovementReportScreen> createState() =>
      _StockMovementReportScreenState();
}

class _StockMovementReportScreenState extends State<StockMovementReportScreen>
    with ReportPdfMixin<StockMovementReportScreen> {
  late final ReportsService _reportsService;
  late final ProductsService _productsService;

  bool _isLoading = true;
  final bool _loadingMovements = false;
  List<Product> _products = [];
  String _selectedProductId = 'all';
  String _selectedType = 'all'; // 'all', 'in', 'out'

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  List<Map<String, dynamic>> _movements = [];
  final double _totalIn = 0;
  final double _totalOut = 0;

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _productsService = context.read<ProductsService>();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productsService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
        _loadMovements();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading products: $e');
      }
    }
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoading = true);
    try {
      final results = await _reportsService.getStocksMovement(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
        productId: _selectedProductId == 'all' ? null : _selectedProductId,
        movementType: _selectedType == 'all' ? null : _selectedType,
      );

      if (mounted) {
        setState(() {
          _movements = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading movements: $e');
      }
    }
  }

  @override
  bool get hasExportData => _movements.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Date & Time',
      'Product',
      'Movement Type',
      'Quantity',
      'Reason',
      'User',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _movements.map((m) {
      final isReceived = m['movementType'] == 'in';
      final createdAt = m['createdAt'] as Timestamp?;
      final date = createdAt != null ? createdAt.toDate() : DateTime.now();

      return [
        DateFormat('dd-MM-yyyy HH:mm').format(date),
        m['productName'] ?? 'Unknown',
        isReceived ? 'Stock In' : 'Stock Out',
        '${isReceived ? '+' : '-'}${m['quantity']}',
        m['reason'] ?? 'Manual',
        m['userName'] ?? 'System',
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    String productName = 'All Products';
    if (_selectedProductId != 'all') {
      try {
        productName = _products
            .firstWhere((p) => p.id == _selectedProductId)
            .name;
      } catch (_) {}
    }

    String typeName = 'All Types';
    if (_selectedType == 'in') typeName = 'Stock In';
    if (_selectedType == 'out') typeName = 'Stock Out';

    return {
      'Date Range':
          '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      'Product Filter': productName,
      'Movement Type': typeName,
      'Total Net Movement': (_totalIn - _totalOut).toStringAsFixed(0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movement Report'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Stock Movement Report'),
            onPrint: () => printReport('Stock Movement Report'),
            onRefresh: _loadMovements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(theme),
                _buildSummaryHeader(theme),
                Expanded(child: _buildMovementsList(theme)),
              ],
            ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final isNarrow = MediaQuery.sizeOf(context).width < 680;

    final productFilter = DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: theme.colorScheme.surface,
      initialValue: _selectedProductId,
      decoration: InputDecoration(
        labelText: 'Product',
        labelStyle: theme.textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text(
            'All Products',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        ..._products.map(
          (p) => DropdownMenuItem(
            value: p.id,
            child: Text(
              p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() => _selectedProductId = val);
          _loadMovements();
        }
      },
    );

    final typeFilter = DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: theme.colorScheme.surface,
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: 'Type',
        labelStyle: theme.textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text(
            'All Types',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        DropdownMenuItem(
          value: 'in',
          child: Text(
            'Stock In',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        DropdownMenuItem(
          value: 'out',
          child: Text(
            'Stock Out',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() => _selectedType = val);
          _loadMovements();
        }
      },
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          if (isNarrow) ...[
            productFilter,
            const SizedBox(height: 12),
            typeFilter,
          ] else
            Row(
              children: [
                Expanded(child: productFilter),
                const SizedBox(width: 12),
                Expanded(child: typeFilter),
              ],
            ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await ResponsiveDatePickers.pickDateRange(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
                _loadMovements();
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date Range',
                labelStyle: theme.textTheme.bodyMedium,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                prefixIcon: Icon(
                  Icons.date_range,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(
                '${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM').format(_dateRange.end)}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          ReportDateRangeButtons(
            value: _dateRange,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onChanged: (range) {
              setState(() => _dateRange = range);
              _loadMovements();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryCol(
            'Movements',
            '${_movements.length}',
            theme.colorScheme.onSurface,
            theme,
          ),
          _summaryCol(
            'Total In',
            '+${_totalIn.toStringAsFixed(0)}',
            AppColors.success,
            theme,
          ),
          _summaryCol(
            'Total Out',
            '-${_totalOut.toStringAsFixed(0)}',
            theme.colorScheme.error,
            theme,
          ),
          _summaryCol(
            'Net',
            (_totalIn - _totalOut).toStringAsFixed(0),
            theme.colorScheme.primary,
            theme,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(
    String label,
    String value,
    Color color,
    ThemeData theme, {
    bool bold = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMovementsList(ThemeData theme) {
    if (_loadingMovements) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_movements.isEmpty) {
      return Center(
        child: Text(
          'No movements found for selected filters',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movements.length,
      itemBuilder: (context, index) {
        final m = _movements[index];
        final isReceived = m['movementType'] == 'in';
        final createdAt = m['createdAt'] as Timestamp?;
        final date = createdAt != null ? createdAt.toDate() : DateTime.now();

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: isReceived
                  ? AppColors.success.withValues(alpha: 0.1)
                  : theme.colorScheme.error.withValues(alpha: 0.1),
              child: Icon(
                isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                color: isReceived ? AppColors.success : theme.colorScheme.error,
                size: 20,
              ),
            ),
            title: Text(
              m['productName'] ?? 'Unknown Product',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${DateFormat('dd MMM, HH:mm').format(date)} - ${m['reason'] ?? 'Manual'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isReceived ? '+' : '-'}${m['quantity']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isReceived
                        ? AppColors.success
                        : theme.colorScheme.error,
                    fontSize: 15,
                  ),
                ),
                Text(
                  m['userName'] ?? 'System',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
