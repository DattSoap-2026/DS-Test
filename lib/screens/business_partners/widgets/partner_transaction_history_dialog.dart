import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/types/purchase_order_types.dart';
import '../../../models/types/sales_types.dart';
import '../../../services/purchase_order_service.dart';
import '../../../services/sales_service.dart';

class PartnerTransactionHistoryDialog {
  static Future<void> showSalesHistory(
    BuildContext context, {
    required String partnerId,
    required String partnerName,
    required String recipientType,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    if (isMobile) {
      return Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _SalesHistoryDialog(
            partnerId: partnerId,
            partnerName: partnerName,
            recipientType: recipientType,
            fullScreen: true,
          ),
        ),
      );
    }
    return showDialog<void>(
      context: context,
      builder: (_) => _SalesHistoryDialog(
        partnerId: partnerId,
        partnerName: partnerName,
        recipientType: recipientType,
        fullScreen: false,
      ),
    );
  }

  static Future<void> showPurchaseHistory(
    BuildContext context, {
    required String supplierId,
    required String supplierName,
    required bool isVendor,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    if (isMobile) {
      return Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _PurchaseHistoryDialog(
            supplierId: supplierId,
            supplierName: supplierName,
            isVendor: isVendor,
            fullScreen: true,
          ),
        ),
      );
    }
    return showDialog<void>(
      context: context,
      builder: (_) => _PurchaseHistoryDialog(
        supplierId: supplierId,
        supplierName: supplierName,
        isVendor: isVendor,
        fullScreen: false,
      ),
    );
  }
}

class _SalesHistoryDialog extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  final String recipientType;
  final bool fullScreen;

  const _SalesHistoryDialog({
    required this.partnerId,
    required this.partnerName,
    required this.recipientType,
    this.fullScreen = false,
  });

  @override
  State<_SalesHistoryDialog> createState() => _SalesHistoryDialogState();
}

class _SalesHistoryDialogState extends State<_SalesHistoryDialog> {
  bool _isLoading = true;
  List<Sale> _sales = [];
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  List<Sale> get _filteredSales {
    return _sales.where((sale) {
      final saleDate = DateTime.tryParse(sale.createdAt);
      if (saleDate == null) return false;
      if (_startDate != null && saleDate.isBefore(_dayStart(_startDate!))) {
        return false;
      }
      if (_endDate != null && saleDate.isAfter(_dayEnd(_endDate!))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSalesHistory();
  }

  Future<void> _loadSalesHistory() async {
    try {
      final salesService = context.read<SalesService>();
      final sales = await salesService.getSalesClient(
        customerId: widget.partnerId,
        recipientType: widget.recipientType,
        limit: 500,
      );
      if (!mounted) return;
      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? _endDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_endDate != null && picked.isAfter(_endDate!)) {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      if (_startDate != null && picked.isBefore(_startDate!)) {
        _startDate = picked;
      }
    });
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSales = _filteredSales;
    final totalAmount = filteredSales.fold<double>(
      0.0,
      (sum, sale) => sum + sale.totalAmount,
    );

    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Sales History'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.partnerName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${filteredSales.length} invoices | ${_formatCurrency(totalAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _DateRangeFilterBar(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: _pickStartDate,
              onSelectEnd: _pickEndDate,
              onClear: _clearDateRange,
            ),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 620),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.partnerName} - Sales History',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${filteredSales.length} invoices | ${_formatCurrency(totalAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            _DateRangeFilterBar(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: _pickStartDate,
              onSelectEnd: _pickEndDate,
              onClear: _clearDateRange,
            ),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load history: $_error',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_sales.isEmpty) {
      return Center(
        child: Text(
          'No sales history found',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final filteredSales = _filteredSales;
    if (filteredSales.isEmpty) {
      return Center(
        child: Text(
          'No sales in selected date range',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filteredSales.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final sale = filteredSales[index];
        final dateText = _formatDate(sale.createdAt);
        final invoiceNo = sale.humanReadableId?.trim().isNotEmpty == true
            ? sale.humanReadableId!
            : _shortInvoiceNo(sale.id);
        final statusText = (sale.status ?? 'created').toUpperCase();

        return Material(
          color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openSaleInvoice(sale),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoiceNo,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dateText | ${sale.items.length} items',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatCurrency(sale.totalAmount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSaleInvoice(Sale sale) async {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    if (isMobile) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _SaleInvoicePreviewDialog(
            sale: sale,
            fullScreen: true,
          ),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _SaleInvoicePreviewDialog(sale: sale, fullScreen: false),
    );
  }
}

class _PurchaseHistoryDialog extends StatefulWidget {
  final String supplierId;
  final String supplierName;
  final bool isVendor;
  final bool fullScreen;

  const _PurchaseHistoryDialog({
    required this.supplierId,
    required this.supplierName,
    required this.isVendor,
    this.fullScreen = false,
  });

  @override
  State<_PurchaseHistoryDialog> createState() => _PurchaseHistoryDialogState();
}

class _PurchaseHistoryDialogState extends State<_PurchaseHistoryDialog> {
  bool _isLoading = true;
  List<PurchaseOrder> _orders = [];
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  List<PurchaseOrder> get _filteredOrders {
    return _orders.where((order) {
      final orderDate = DateTime.tryParse(order.createdAt);
      if (orderDate == null) return false;
      if (_startDate != null && orderDate.isBefore(_dayStart(_startDate!))) {
        return false;
      }
      if (_endDate != null && orderDate.isAfter(_dayEnd(_endDate!))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPurchaseHistory();
  }

  Future<void> _loadPurchaseHistory() async {
    try {
      final service = context.read<PurchaseOrderService>();
      final orders = await service.getAllPurchaseOrders();
      final filtered = orders
          .where((order) => order.supplierId == widget.supplierId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _orders = filtered;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? _endDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_endDate != null && picked.isAfter(_endDate!)) {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      if (_startDate != null && picked.isBefore(_startDate!)) {
        _startDate = picked;
      }
    });
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredOrders = _filteredOrders;
    final totalAmount = filteredOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.totalAmount,
    );
    final label = widget.isVendor ? 'Vendor' : 'Supplier';

    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Purchase History'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Icon(Icons.receipt_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.supplierName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$label bills: ${filteredOrders.length} | ${_formatCurrency(totalAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _DateRangeFilterBar(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: _pickStartDate,
              onSelectEnd: _pickEndDate,
              onClear: _clearDateRange,
            ),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 620),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.supplierName} - Purchase History',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '$label bills: ${filteredOrders.length} | ${_formatCurrency(totalAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            _DateRangeFilterBar(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: _pickStartDate,
              onSelectEnd: _pickEndDate,
              onClear: _clearDateRange,
            ),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load history: $_error',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Text(
          'No purchase bills found',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final filteredOrders = _filteredOrders;
    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          'No purchase bills in selected date range',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final dateText = _formatDate(order.createdAt);
        return Material(
          color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).pop();
              context.pushNamed(
                'purchase_order_details',
                pathParameters: {'poId': order.id},
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.poNumber,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dateText | ${order.items.length} items',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(order.totalAmount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
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

class _SaleInvoicePreviewDialog extends StatelessWidget {
  final Sale sale;
  final bool fullScreen;

  const _SaleInvoicePreviewDialog({
    required this.sale,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoiceNo = sale.humanReadableId?.trim().isNotEmpty == true
        ? sale.humanReadableId!
        : _shortInvoiceNo(sale.id);
    final gstTotal =
        (sale.cgstAmount ?? 0.0) +
        (sale.sgstAmount ?? 0.0) +
        (sale.igstAmount ?? 0.0);

    final invoiceList = ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _kv(theme, 'Recipient', sale.recipientName),
        _kv(theme, 'Type', sale.recipientType.toUpperCase()),
        _kv(theme, 'Payment', sale.paymentStatus.toUpperCase()),
        const SizedBox(height: 12),
        Text(
          'Items',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...sale.items.map((item) {
          final lineTotal = item.quantity * item.price;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${item.quantity} x ${_formatCurrency(item.price)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 10),
                Text(
                  _formatCurrency(lineTotal),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
        const Divider(height: 24),
        _kv(theme, 'Subtotal', _formatCurrency(sale.subtotal)),
        _kv(theme, 'Taxable', _formatCurrency(sale.taxableAmount)),
        _kv(theme, 'GST', _formatCurrency(gstTotal)),
        _kv(theme, 'Total', _formatCurrency(sale.totalAmount), highlight: true),
      ],
    );

    if (fullScreen) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Sales Invoice'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$invoiceNo | ${_formatDate(sale.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        body: invoiceList,
      );
    }

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 680),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Invoice',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '$invoiceNo | ${_formatDate(sale.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(child: invoiceList),
          ],
        ),
      ),
    );
  }

  Widget _kv(
    ThemeData theme,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: highlight ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeFilterBar extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;
  final VoidCallback onClear;

  const _DateRangeFilterBar({
    required this.startDate,
    required this.endDate,
    required this.onSelectStart,
    required this.onSelectEnd,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRange = startDate != null || endDate != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: onSelectStart,
            icon: const Icon(Icons.event_available_rounded, size: 16),
            label: Text(
              startDate == null
                  ? 'From Date'
                  : DateFormat('dd MMM yyyy').format(startDate!),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onSelectEnd,
            icon: const Icon(Icons.event_rounded, size: 16),
            label: Text(
              endDate == null
                  ? 'To Date'
                  : DateFormat('dd MMM yyyy').format(endDate!),
            ),
          ),
          if (hasRange)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}

String _shortInvoiceNo(String id) {
  if (id.length <= 6) return id.toUpperCase();
  return '#${id.substring(id.length - 6).toUpperCase()}';
}

String _formatCurrency(double value) {
  return NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ').format(value);
}

String _formatDate(String rawIso) {
  final parsed = DateTime.tryParse(rawIso);
  if (parsed == null) return rawIso;
  return DateFormat('dd MMM yyyy').format(parsed);
}

DateTime _dayStart(DateTime value) => DateTime(value.year, value.month, value.day);

DateTime _dayEnd(DateTime value) =>
    DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
