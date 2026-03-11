import 'package:flutter/material.dart';
import '../ui/unified_card.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/responsive.dart';

class DashboardTable extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<List<dynamic>> rows;
  final VoidCallback? onViewAll;
  final Widget? summary;

  const DashboardTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.onViewAll,
    this.summary,
  });

  bool _isNumericColumn(String column) {
    final key = column.toLowerCase();
    return key.contains('stock') ||
        key.contains('threshold') ||
        key.contains('amount') ||
        key.contains('sold') ||
        key.contains('revenue') ||
        key.contains('yield') ||
        key.contains('unit');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UnifiedCard(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactTable = constraints.maxWidth < 560;
          final headingRowHeight = isCompactTable ? 36.0 : 40.0;
          final dataRowMinHeight = isCompactTable ? 42.0 : 48.0;
          final dataRowMaxHeight = isCompactTable ? 52.0 : 56.0;
          final horizontalMargin = isCompactTable ? 10.0 : 16.0;
          final columnSpacing = isCompactTable ? 14.0 : 28.0;
          final minTableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 0.0;

          final table = SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minTableWidth),
                child: DataTable(
                  headingRowHeight: headingRowHeight,
                  dataRowMinHeight: dataRowMinHeight,
                  dataRowMaxHeight: dataRowMaxHeight,
                  horizontalMargin: horizontalMargin,
                  columnSpacing: columnSpacing,
                  headingRowColor: WidgetStatePropertyAll(
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  ),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.05),
                    ),
                  ),
                  columns: columns
                      .map(
                        (col) => DataColumn(
                          numeric: _isNumericColumn(col),
                          label: Text(
                            col,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.bold,
                              fontSize: isCompactTable ? 11 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  rows: rows
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(
                          color: WidgetStatePropertyAll(
                            entry.key.isEven
                                ? Colors.transparent
                                : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.2),
                          ),
                          cells: entry.value.asMap().entries.map((cellEntry) {
                            final colIndex = cellEntry.key;
                            final cell = cellEntry.value;
                            final numeric = colIndex < columns.length
                                ? _isNumericColumn(columns[colIndex])
                                : false;

                            final Widget child = cell is Widget
                                ? cell
                                : Text(
                                    cell.toString(),
                                    textAlign: numeric
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: isCompactTable ? 12 : 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );

                            return DataCell(
                              Align(
                                alignment: numeric
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: child,
                              ),
                            );
                          }).toList(),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );

          final compactHeader = Responsive.isMobile(context);
          final header = Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              if (onViewAll != null) ...[
                const SizedBox(width: 8),
                if (compactHeader)
                  IconButton(
                    onPressed: onViewAll,
                    tooltip: 'View All',
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  )
                else
                  TextButton.icon(
                    onPressed: onViewAll,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      textStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ],
          );

          if (!constraints.hasBoundedHeight) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: Responsive.clamp(
                      context,
                      min: 300,
                      max: 420,
                      ratio: 0.35,
                    ),
                  ),
                  child: table,
                ),
                if (summary != null) ...[const SizedBox(height: 12), summary!],
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 16),
              Expanded(child: table),
              if (summary != null) ...[const SizedBox(height: 12), summary!],
            ],
          );
        },
      ),
    );
  }
}

class DashboardStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool compact;

  const DashboardStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPad = compact ? 7.0 : 10.0;
    final verticalPad = compact ? 3.0 : 4.0;
    final fontSize = compact ? 9.0 : 10.0;
    final letterSpacing = compact ? 0.6 : 1.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}

class LowStockTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback? onViewAll;

  const LowStockTable({super.key, required this.items, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final criticalCount = items.where((item) {
      final stock = (item['stock'] as num).toDouble();
      final threshold = (item['threshold'] as num).toDouble();
      return stock < (threshold * 0.5);
    }).length;
    final warningCount = items.length - criticalCount;
    return DashboardTable(
      title: 'Low Stock Raw Materials',
      onViewAll: onViewAll,
      columns: const ['Material', 'Stock', 'Threshold', 'Status'],
      rows: items.map((item) {
        final stock = (item['stock'] as num).toDouble();
        final threshold = (item['threshold'] as num).toDouble();
        final isCritical = stock < (threshold * 0.5);

        return [
          item['name'],
          '$stock ${item['unit']}',
          '$threshold ${item['unit']}',
          DashboardStatusBadge(
            label: isCritical ? 'Critical' : 'Warning',
            color: isCritical ? theme.colorScheme.error : AppColors.warning,
            compact: true,
          ),
        ];
      }).toList(),
      summary: items.isEmpty
          ? null
          : _SummaryRow(
              items: [
                _SummaryItem(
                  label: 'Listed',
                  value: items.length.toString(),
                  color: theme.colorScheme.primary,
                ),
                _SummaryItem(
                  label: 'Critical',
                  value: criticalCount.toString(),
                  color: theme.colorScheme.error,
                ),
                _SummaryItem(
                  label: 'Warning',
                  value: warningCount.toString(),
                  color: AppColors.warning,
                ),
              ],
            ),
    );
  }
}

class PendingDispatchTable extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final VoidCallback? onViewAll;

  const PendingDispatchTable({super.key, required this.orders, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAmount = orders.fold<double>(
      0.0,
      (sum, order) => sum + ((order['amount'] as num?)?.toDouble() ?? 0.0),
    );
    return DashboardTable(
      title: 'Pending Dispatch Orders',
      onViewAll: onViewAll,
      columns: const ['Order ID', 'Customer', 'Amount', 'Status'],
      rows: orders.map((order) {
        return [
          '#${order['id'].toString().substring(0, 8).toUpperCase()}',
          order['customerName'],
          '\u20B9${(order['amount'] as num).toStringAsFixed(0)}',
          DashboardStatusBadge(
            label: 'Pending',
            color: theme.colorScheme.secondary,
            compact: true,
          ),
        ];
      }).toList(),
      summary: orders.isEmpty
          ? null
          : _SummaryRow(
              items: [
                _SummaryItem(
                  label: 'Orders',
                  value: orders.length.toString(),
                  color: theme.colorScheme.primary,
                ),
                _SummaryItem(
                  label: 'Total Amount',
                  value: '\u20B9${totalAmount.toStringAsFixed(0)}',
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
    );
  }
}

class RecentDispatchTable extends StatelessWidget {
  final List<Map<String, dynamic>> dispatches;
  final VoidCallback? onViewAll;

  const RecentDispatchTable({
    super.key,
    required this.dispatches,
    this.onViewAll,
  });

  String _resolveRecipient(Map<String, dynamic> dispatch) {
    final salesmanName = (dispatch['recipientName'] ?? '').toString().trim();
    final dealerName = (dispatch['dealerName'] ?? '').toString().trim();
    if (salesmanName.isNotEmpty && dealerName.isNotEmpty) {
      return '$salesmanName -> $dealerName';
    }
    if (salesmanName.isNotEmpty) return salesmanName;
    if (dealerName.isNotEmpty) return dealerName;
    return 'Unknown';
  }

  String _resolveRoute(Map<String, dynamic> dispatch) {
    final route = (dispatch['route'] ?? '').toString().trim();
    return route.isNotEmpty ? route : '-';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  String _shortenDispatchId(String dispatchId) {
    if (dispatchId.isEmpty) return 'N/A';
    if (dispatchId.length <= 12) return dispatchId;
    return '${dispatchId.substring(0, 12)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalItems = dispatches.fold<int>(
      0,
      (sum, row) => sum + ((row['quantity'] as num?)?.toInt() ?? 0),
    );

    return DashboardTable(
      title: 'Recent Dispatches',
      onViewAll: onViewAll,
      columns: const ['Date', 'Dispatch', 'To', 'Route', 'Items', 'Action'],
      rows: dispatches.map((dispatch) {
        final dispatchId = (dispatch['dispatchId'] ?? '').toString().trim();
        final quantity = (dispatch['quantity'] as num?)?.toInt() ?? 0;
        final createdAt = dispatch['createdAt']?.toString();
        
        return [
          _formatDate(createdAt),
          _shortenDispatchId(dispatchId.isNotEmpty ? dispatchId : 'N/A'),
          _resolveRecipient(dispatch),
          _resolveRoute(dispatch),
          '$quantity Items',
          IconButton(
            icon: Icon(
              Icons.visibility_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              _showDispatchInvoice(context, dispatch);
            },
            tooltip: 'View Invoice',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ];
      }).toList(),
      summary: dispatches.isEmpty
          ? null
          : _SummaryRow(
              items: [
                _SummaryItem(
                  label: 'Dispatches',
                  value: dispatches.length.toString(),
                  color: theme.colorScheme.primary,
                ),
                _SummaryItem(
                  label: 'Items',
                  value: totalItems.toString(),
                  color: AppColors.info,
                ),
              ],
            ),
    );
  }

  void _showDispatchInvoice(BuildContext context, Map<String, dynamic> dispatch) {
    final theme = Theme.of(context);
    final dispatchId = (dispatch['dispatchId'] ?? '').toString().trim();
    final salesmanName = (dispatch['recipientName'] ?? '').toString().trim();
    final dealerName = (dispatch['dealerName'] ?? '').toString().trim();
    final route = _resolveRoute(dispatch);
    final quantity = (dispatch['quantity'] as num?)?.toInt() ?? 0;
    final createdAt = dispatch['createdAt']?.toString();
    final items = (dispatch['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final isDealer = dispatch['isDealer'] == true;
    final totalAmount = (dispatch['totalAmount'] as num?)?.toDouble() ?? 0.0;
    
    final now = createdAt != null ? DateTime.tryParse(createdAt) : DateTime.now();
    final dateText = now != null
        ? '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}'
        : '-';
    final timeText = now != null
        ? '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
        : '-';

    double subtotal = 0.0;
    if (items.isNotEmpty) {
      for (var item in items) {
        subtotal += (item['amount'] as num?)?.toDouble() ?? 0.0;
      }
    }
    final discount = subtotal - totalAmount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispatch Challan',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Date: $dateText  |  Time: $timeText',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Datt Soap Factory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('123 Railway Station MIDC', style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                        const SizedBox(height: 8),
                        Text('Dispatch ID: $dispatchId', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (salesmanName.isNotEmpty)
                          Text('Salesman: $salesmanName', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (dealerName.isNotEmpty)
                          Text('Dealer: $dealerName', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        Text('Route: $route', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (items.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                            child: Row(
                              children: const [
                                Expanded(flex: 1, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                Expanded(flex: 4, child: Text('Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          ...items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                            final rate = (item['rate'] as num?)?.toDouble() ?? 0.0;
                            final amount = (item['amount'] as num?)?.toDouble() ?? (qty * rate);
                            final unit = (item['unit'] ?? '').toString();
                            final productName = (item['productName'] ?? '').toString();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6))),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 1, child: Text('${index + 1}', style: const TextStyle(fontSize: 11))),
                                  Expanded(flex: 4, child: Text(productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                                  Expanded(flex: 2, child: Text('$qty $unit', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                                  Expanded(flex: 2, child: Text('₹${rate.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11))),
                                  Expanded(flex: 2, child: Text('₹${amount.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isDealer) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 280,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSummaryRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
                              if (discount > 0) ...[
                                const SizedBox(height: 4),
                                _buildSummaryRow('Discount:', '-₹${discount.toStringAsFixed(2)}', color: AppColors.error),
                              ],
                              const Divider(height: 16),
                              _buildSummaryRow('Total Amount:', '₹${totalAmount.toStringAsFixed(2)}', isBold: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL ITEMS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                              Text('$quantity Items', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : null)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

class RecentBatchesTable extends StatelessWidget {
  final List<Map<String, dynamic>> batches;
  final VoidCallback? onViewAll;

  const RecentBatchesTable({super.key, required this.batches, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final totalUnits = batches.fold<double>(
      0.0,
      (sum, batch) =>
          sum + ((batch['unitsProduced'] as num?)?.toDouble() ?? 0.0),
    );
    return DashboardTable(
      title: 'Recent Production Batches',
      onViewAll: onViewAll,
      columns: const ['Batch ID', 'Product', 'Yield', 'Status'],
      rows: batches.map((batch) {
        return [
          batch['batchNumber'] ?? batch['id'].toString().substring(0, 8),
          batch['productName'],
          '${batch['unitsProduced']} Units',
          const DashboardStatusBadge(
            label: 'Completed',
            color: AppColors.success,
            compact: true,
          ),
        ];
      }).toList(),
      summary: batches.isEmpty
          ? null
          : _SummaryRow(
              items: [
                _SummaryItem(
                  label: 'Batches',
                  value: batches.length.toString(),
                  color: AppColors.info,
                ),
                _SummaryItem(
                  label: 'Units',
                  value: totalUnits.toStringAsFixed(0),
                  color: AppColors.success,
                ),
              ],
            ),
    );
  }
}

class TopProductsTable extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final VoidCallback? onViewAll;

  const TopProductsTable({super.key, required this.products, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalUnits = products.fold<int>(
      0,
      (sum, product) => sum + ((product['sold'] as num?)?.toInt() ?? 0),
    );
    final totalRevenue = products.fold<double>(
      0.0,
      (sum, product) => sum + ((product['revenue'] as num?)?.toDouble() ?? 0.0),
    );
    return DashboardTable(
      title: 'Top Selling Products',
      onViewAll: onViewAll,
      columns: const ['Product', 'Sold', 'Revenue', 'Growth'],
      rows: products.map((product) {
        return [
          product['name'],
          '${product['sold']} Units',
          '\u20B9${(product['revenue'] as num).toStringAsFixed(0)}',
          DashboardStatusBadge(
            label: '+12%',
            color: theme.colorScheme.primary,
            compact: true,
          ),
        ];
      }).toList(),
      summary: products.isEmpty
          ? null
          : _SummaryRow(
              items: [
                _SummaryItem(
                  label: 'Units',
                  value: totalUnits.toString(),
                  color: theme.colorScheme.primary,
                ),
                _SummaryItem(
                  label: 'Revenue',
                  value: '\u20B9${totalRevenue.toStringAsFixed(0)}',
                  color: AppColors.success,
                ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<_SummaryItem> items;

  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.color.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: item.color,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });
}
