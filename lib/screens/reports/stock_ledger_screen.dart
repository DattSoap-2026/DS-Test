import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/inventory_service.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart';
import '../../utils/app_toast.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

import '../../widgets/ui/unified_card.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';

class StockLedgerScreen extends StatefulWidget {
  const StockLedgerScreen({super.key});

  @override
  State<StockLedgerScreen> createState() => _StockLedgerScreenState();
}

class _StockLedgerScreenState extends State<StockLedgerScreen>
    with ReportPdfMixin<StockLedgerScreen> {
  late final InventoryService _inventoryService;
  late final ProductsService _productsService;

  bool _isLoading = true;
  bool _loadingLedger = false;
  List<Product> _products = [];
  String? _selectedProductId;
  Product? _selectedProduct;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  List<Map<String, dynamic>> _movements = [];
  double _openingStock = 0;
  double _closingStock = 0;
  double _totalIn = 0;
  double _totalOut = 0;

  @override
  bool get hasExportData => _selectedProduct != null && _movements.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return const ['Date', 'Type', 'Qty', 'Balance', 'Reason', 'Notes'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _movements
        .map((row) {
          final createdAt = row['createdAt'] as DateTime?;
          return [
            createdAt != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)
                : '-',
            (row['movementType']?.toString() ?? '').toUpperCase(),
            (row['quantity'] ?? 0).toString(),
            (row['balance'] ?? 0).toString(),
            row['reason']?.toString() ?? '-',
            row['notes']?.toString() ?? '-',
          ];
        })
        .toList(growable: false);
  }

  @override
  Map<String, String> buildFilterSummary() {
    return {
      'Product': _selectedProduct?.name ?? '-',
      'Period':
          '${DateFormat('dd MMM yyyy').format(_dateRange.start)} to ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      'Opening': _openingStock.toStringAsFixed(2),
      'Closing': _closingStock.toStringAsFixed(2),
    };
  }

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<InventoryService>();
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading products: $e');
      }
    }
  }

  Future<void> _loadLedger() async {
    if (_selectedProductId == null) return;

    setState(() => _loadingLedger = true);
    try {
      _selectedProduct = _products.cast<Product?>().firstWhere(
        (p) => p?.id == _selectedProductId,
        orElse: () => null,
      );
      if (_selectedProduct == null) {
        if (mounted) {
          setState(() => _loadingLedger = false);
          AppToast.showError(context, 'Selected product not found');
        }
        return;
      }

      final entries = await _inventoryService.getStockLedgerEntries(
        productId: _selectedProductId,
        startDate: _dateRange.start,
        endDate: DateTime(
          _dateRange.end.year,
          _dateRange.end.month,
          _dateRange.end.day,
          23,
          59,
          59,
        ),
      );

      double totalIn = 0;
      double totalOut = 0;

      for (final entry in entries) {
        final qty = entry.quantityChange;
        if (qty >= 0) {
          totalIn += qty;
        } else {
          totalOut += qty.abs();
        }
      }

      final currentStock = _selectedProduct!.stock.toDouble();
      final openingStock = entries.isNotEmpty
          ? entries.first.runningBalance - entries.first.quantityChange
          : currentStock;
      final closingStock = entries.isNotEmpty
          ? entries.last.runningBalance
          : currentStock;

      final ledgerRows = entries
          .map(
            (entry) => {
              'id': entry.id,
              'movementType': entry.quantityChange >= 0 ? 'in' : 'out',
              'quantity': entry.quantityChange.abs(),
              'balance': entry.runningBalance,
              'createdAt': entry.transactionDate,
              'reason': entry.transactionType,
              'notes': entry.notes,
              'unit': entry.unit,
            },
          )
          .toList()
          .reversed
          .toList();

      if (mounted) {
        setState(() {
          _movements = ledgerRows;
          _openingStock = openingStock;
          _closingStock = closingStock;
          _totalIn = totalIn;
          _totalOut = totalOut;
          _loadingLedger = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingLedger = false);
        AppToast.showError(context, 'Error generating ledger: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Ledger'),
        centerTitle: false,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Stock Ledger Report'),
            onPrint: () => printReport('Stock Ledger Report'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                if (_selectedProductId != null) ...[
                  _buildSummaryStrip(),
                  Expanded(child: _buildLedgerList()),
                ] else
                  const Expanded(
                    child: Center(
                      child: Text('Please select a product to view its ledger'),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return UnifiedCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedProductId),
            initialValue: _selectedProductId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Select Product',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _products
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => _selectedProductId = val);
              if (val != null) _loadLedger();
            },
          ),
          const SizedBox(height: 12),
          UnifiedCard(
            onTap: () async {
              final picked = await ResponsiveDatePickers.pickDateRange(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
                _loadLedger();
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: Theme.of(context).cardTheme.color,
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        '${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM').format(_dateRange.end)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ReportDateRangeButtons(
            value: _dateRange,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onChanged: (range) {
              setState(() => _dateRange = range);
              _loadLedger();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip() {
    return UnifiedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            'Opening',
            _openingStock,
            Theme.of(context).colorScheme.secondary,
          ),
          _statItem(
            'Total In',
            _totalIn,
            Theme.of(context).colorScheme.primary,
          ),
          _statItem(
            'Total Out',
            _totalOut,
            Theme.of(context).colorScheme.error,
          ),
          _statItem(
            'Closing',
            _closingStock,
            Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, double value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerList() {
    if (_loadingLedger) return const Center(child: CircularProgressIndicator());
    if (_movements.isEmpty) {
      return const Center(child: Text('No transactions for this period'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movements.length,
      itemBuilder: (context, index) {
        final m = _movements[index];
        final isReceived = m['movementType'] == 'in';
        final rawCreatedAt = m['createdAt'];
        final date = rawCreatedAt is DateTime
            ? rawCreatedAt
            : DateTime.tryParse(rawCreatedAt?.toString() ?? '') ??
                  DateTime.now();
        final qty = (m['quantity'] as num? ?? 0).toDouble();
        final balance = (m['balance'] as num? ?? 0).toDouble();
        final reasonText = (m['notes'] ?? m['reason'] ?? 'Manual')
            .toString()
            .trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          (isReceived
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error)
                              .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isReceived ? Icons.add : Icons.remove,
                      size: 16,
                      color: isReceived
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMM, yyyy').format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reasonText.isEmpty ? 'Manual' : reasonText,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isReceived ? '+' : '-'}${qty.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isReceived
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Bal: ${balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
