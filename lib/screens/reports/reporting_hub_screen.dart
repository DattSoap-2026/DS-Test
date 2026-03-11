import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/products_service.dart';
import '../../services/sales_service.dart';
import '../../services/settings_service.dart';
import '../../utils/app_toast.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/ui/master_screen_header.dart';

enum _ReportQuickExport { stockSummary, monthlySales }

class ReportingHubScreen extends StatefulWidget {
  const ReportingHubScreen({super.key});

  @override
  State<ReportingHubScreen> createState() => _ReportingHubScreenState();
}

class _ReportingHubScreenState extends State<ReportingHubScreen> {
  bool _isExporting = false;

  Future<void> _runQuickExport(_ReportQuickExport option) async {
    setState(() => _isExporting = true);
    try {
      switch (option) {
        case _ReportQuickExport.stockSummary:
          await _exportStockSummaryReport();
          break;
        case _ReportQuickExport.monthlySales:
          await _exportMonthlySalesReport();
          break;
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Print Failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _reportQuickExportTitle(_ReportQuickExport option) {
    switch (option) {
      case _ReportQuickExport.stockSummary:
        return 'Stock Summary';
      case _ReportQuickExport.monthlySales:
        return 'Monthly Sales';
    }
  }

  String _reportQuickExportSubtitle(_ReportQuickExport option) {
    switch (option) {
      case _ReportQuickExport.stockSummary:
        return 'Current stock levels and valuation';
      case _ReportQuickExport.monthlySales:
        return 'Sales summary for current month';
    }
  }

  IconData _reportQuickExportIcon(_ReportQuickExport option) {
    switch (option) {
      case _ReportQuickExport.stockSummary:
        return Icons.inventory_2_outlined;
      case _ReportQuickExport.monthlySales:
        return Icons.calendar_month_outlined;
    }
  }

  String _reportQuickExportEmoji(_ReportQuickExport option) {
    switch (option) {
      case _ReportQuickExport.stockSummary:
        return '📦';
      case _ReportQuickExport.monthlySales:
        return '🧾';
    }
  }

  Future<void> _exportStockSummaryReport() async {
    final productService = context.read<ProductsService>();
    final settingsService = context.read<SettingsService>();

    final products = await productService.getProducts();
    final company = await settingsService.getCompanyProfileClient();

    final headers = [
      'Product',
      'Category',
      'Stock',
      'Unit',
      'Avg Cost',
      'Value',
    ];
    final rows = products
        .map(
          (product) => [
            product.name,
            product.category,
            product.stock.toStringAsFixed(2),
            product.baseUnit,
            'Rs ${((product.averageCost ?? 0)).toStringAsFixed(2)}',
            'Rs ${(product.stock * (product.averageCost ?? 0)).toStringAsFixed(2)}',
          ],
        )
        .toList();

    await PdfGenerator.generateAndPrintGenericReport(
      'Stock Summary Report',
      headers,
      rows,
      company ?? CompanyProfileData(),
      subtitle:
          'As of ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
    );
  }

  Future<void> _exportMonthlySalesReport() async {
    final salesService = context.read<SalesService>();
    final settingsService = context.read<SettingsService>();

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final sales = await salesService.getSales(
      startDate: firstDay,
      endDate: now,
    );
    final company = await settingsService.getCompanyProfileClient();

    final headers = ['Date', 'Invoice', 'Customer', 'Amount', 'Status'];
    final rows = sales
        .map(
          (sale) => [
            _formatDateSafe(sale.createdAt, pattern: 'dd/MM'),
            sale.humanReadableId ?? sale.id.substring(0, 8),
            sale.recipientName,
            'Rs ${sale.totalAmount.toStringAsFixed(0)}',
            (sale.status ?? 'unknown').toUpperCase(),
          ],
        )
        .toList();

    await PdfGenerator.generateAndPrintGenericReport(
      'Monthly Sales Report',
      headers,
      rows,
      company ?? CompanyProfileData(),
      subtitle:
          'Period: ${DateFormat('MMMM yyyy').format(now)} (${sales.length} invoices)',
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface,
                    colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MasterScreenHeader(
                  title: 'Reporting Hub',
                  subtitle:
                      'Centralized reports designed for mobile and desktop',
                  icon: Icons.summarize_rounded,
                  color: colorScheme.primary,
                  actions: [
                    if (_isExporting)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      PopupMenuButton<_ReportQuickExport>(
                        tooltip: 'Quick Print',
                        icon: Icon(
                          Icons.print_outlined,
                          color: colorScheme.primary,
                        ),
                        onSelected: _runQuickExport,
                        itemBuilder: (context) => _ReportQuickExport.values
                            .map(
                              (option) => PopupMenuItem<_ReportQuickExport>(
                                value: option,
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(_reportQuickExportIcon(option)),
                                  title: Text(_reportQuickExportTitle(option)),
                                  subtitle: Text(
                                    _reportQuickExportSubtitle(option),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final horizontalPadding = _horizontalPadding(width);

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickExportsPanel(context),
                            const SizedBox(height: 20),
                            ...sections.map(
                              (section) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildSectionPanel(context, section),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExportsPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.24)),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text('⚡', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Exports',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 580;
                final items = _ReportQuickExport.values
                    .map((option) => _buildQuickExportTile(context, option))
                    .toList();

                if (compact) {
                  return Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        items[i],
                        if (i < items.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      Expanded(child: items[i]),
                      if (i < items.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickExportTile(
    BuildContext context,
    _ReportQuickExport option,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _isExporting ? null : () => _runQuickExport(option),
      child: Ink(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.24),
          ),
          color: colorScheme.surface.withValues(alpha: 0.4),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                _reportQuickExportEmoji(option),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _reportQuickExportTitle(option),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _reportQuickExportSubtitle(option),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.print, size: 15, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionPanel(BuildContext context, _ReportSection section) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.38)),
        gradient: LinearGradient(
          colors: [
            colorScheme.surface.withValues(alpha: 0.75),
            section.color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: section.color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final panelWidth = constraints.maxWidth;
            final columns = _reportColumnCount(panelWidth);
            final gap = panelWidth < 500 ? 8.0 : 12.0;
            final itemWidth = (panelWidth - ((columns - 1) * gap)) / columns;
            final tileHeight = _reportTileHeight(panelWidth, itemWidth);
            final compact = itemWidth < 130;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: section.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        section.emoji,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        section.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: section.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${section.items.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: section.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  section.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: section.items
                      .map(
                        (item) => SizedBox(
                          width: itemWidth,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: tileHeight),
                            child: _buildReportTile(
                              context,
                              item,
                              section.color,
                              compact,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context,
    _ReportItem item,
    Color sectionColor,
    bool compact,
  ) {
    final theme = Theme.of(context);
    final tileBackground = theme.colorScheme.surfaceContainerHigh.withValues(
      alpha: 0.94,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(item.route),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              tileBackground,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.96),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.52),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: sectionColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: sectionColor.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(item.emoji, style: const TextStyle(fontSize: 17)),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              item.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
                fontSize: compact ? 12 : null,
              ),
              maxLines: compact ? 2 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text(
                item.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _reportColumnCount(double width) {
    if (width < 330) return 2;
    if (width < 760) return 3;
    return 4;
  }

  double _horizontalPadding(double width) {
    if (width >= 1400) return 26;
    if (width >= 1000) return 20;
    if (width >= 600) return 14;
    return 10;
  }

  double _reportTileHeight(double width, double itemWidth) {
    if (itemWidth < 92) return 136;
    if (itemWidth < 120) return 142;
    if (itemWidth < 170) return 136;
    return 128;
  }

  List<_ReportSection> _buildSections(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      _ReportSection(
        title: 'Sales & Customers',
        subtitle: 'Revenue, dispatch and customer performance reports',
        emoji: '📈',
        icon: Icons.people_outline,
        color: colorScheme.primary,
        items: [
          _ReportItem(
            title: 'Sales Report',
            emoji: 'SR',
            icon: Icons.bar_chart_rounded,
            route: '/dashboard/reports/sales',
            description: 'Advanced sales analytics',
          ),
          _ReportItem(
            title: 'Sales Dispatch',
            emoji: '🚚',
            icon: Icons.local_shipping,
            route: '/dashboard/reports/sales-dispatch',
            description: 'Daily dispatch logs',
          ),
          _ReportItem(
            title: 'Salesman Perf.',
            emoji: '🧑‍💼',
            icon: Icons.person_outline,
            route: '/dashboard/reports/salesman',
            description: 'Performance vs targets',
          ),
          _ReportItem(
            title: 'Target Achievement',
            emoji: '🎯',
            icon: Icons.track_changes,
            route: '/dashboard/reports/target-achievement',
            description: 'Monthly completion status',
          ),
          _ReportItem(
            title: 'Customer Aging',
            emoji: '🧾',
            icon: Icons.history,
            route: '/dashboard/reports/customer-aging',
            description: 'Outstanding receivables',
          ),
          _ReportItem(
            title: 'Dealer Performance',
            emoji: '🏪',
            icon: Icons.store,
            route: '/dashboard/reports/dealer',
            description: 'Dealer sales tracking',
          ),
        ],
      ),
      _ReportSection(
        title: 'Inventory & Stock',
        subtitle: 'Stock movement, valuation and fuel inventory',
        emoji: '📦',
        icon: Icons.inventory_2_outlined,
        color: colorScheme.tertiary,
        items: [
          _ReportItem(
            title: 'Stock Ledger',
            emoji: '📒',
            icon: Icons.menu_book,
            route: '/dashboard/reports/stock-ledger',
            description: 'Item-wise in/out history',
          ),
          _ReportItem(
            title: 'Stock Valuation',
            emoji: '💰',
            icon: Icons.attach_money,
            route: '/dashboard/reports/stock-valuation',
            description: 'Current inventory value',
          ),
          _ReportItem(
            title: 'Stock Movement',
            emoji: '🔄',
            icon: Icons.compare_arrows,
            route: '/dashboard/reports/stock-movement',
            description: 'Detailed movement logs',
          ),
          _ReportItem(
            title: 'Fuel Stock',
            emoji: '⛽',
            icon: Icons.local_gas_station,
            route: '/dashboard/fuel/stock',
            description: 'Diesel tank balances',
          ),
        ],
      ),
      _ReportSection(
        title: 'Production & Manufacturing',
        subtitle: 'Output, yield and waste optimization reports',
        emoji: '🏭',
        icon: Icons.factory_outlined,
        color: colorScheme.secondary,
        items: [
          _ReportItem(
            title: 'Production',
            emoji: '⚙️',
            icon: Icons.precision_manufacturing,
            route: '/dashboard/reports/production',
            description: 'Daily output overview',
          ),
          _ReportItem(
            title: 'Bhatti',
            emoji: '🔥',
            icon: Icons.outdoor_grill,
            route: '/dashboard/reports/bhatti',
            description: 'Batch and cooking logs',
          ),
          _ReportItem(
            title: 'Cutting Yield',
            emoji: '✂️',
            icon: Icons.content_cut,
            route: '/dashboard/reports/cutting-yield',
            description: 'Yield efficiency analysis',
          ),
          _ReportItem(
            title: 'Waste Analysis',
            emoji: '♻️',
            icon: Icons.delete_outline,
            route: '/dashboard/reports/waste-analysis',
            description: 'Wastage trend tracking',
          ),
        ],
      ),
      _ReportSection(
        title: 'Finance & Compliance',
        subtitle: 'Financial statements and tax reporting',
        emoji: '🏦',
        icon: Icons.account_balance_outlined,
        color: colorScheme.error,
        items: [
          _ReportItem(
            title: 'Financial Report',
            emoji: '💼',
            icon: Icons.account_balance_wallet,
            route: '/dashboard/reports/financial',
            description: 'P&L and expenses',
          ),
          _ReportItem(
            title: 'GST Report',
            emoji: '🧮',
            icon: Icons.receipt_long,
            route: '/dashboard/reports/gst',
            description: 'Tax filing summary',
          ),
        ],
      ),
      _ReportSection(
        title: 'Fleet & Transport',
        subtitle: 'Fuel, maintenance and vehicle operations',
        emoji: '🚛',
        icon: Icons.local_shipping_outlined,
        color: colorScheme.primary,
        items: [
          _ReportItem(
            title: 'Diesel Usage',
            emoji: '🛢️',
            icon: Icons.opacity,
            route: '/dashboard/reports/diesel',
            description: 'Vehicle fuel usage',
          ),
          _ReportItem(
            title: 'Maintenance',
            emoji: '🛠️',
            icon: Icons.build,
            route: '/dashboard/reports/maintenance',
            description: 'Repair and service logs',
          ),
          _ReportItem(
            title: 'Tyre Report',
            emoji: '🛞',
            icon: Icons.tire_repair,
            route: '/dashboard/reports/tyre',
            description: 'Tyre lifecycle tracking',
          ),
          _ReportItem(
            title: 'Vehicle Reports',
            emoji: '🚘',
            icon: Icons.directions_car_filled_outlined,
            route: '/dashboard/vehicles',
            description: 'Expiry, monthly, yearly',
          ),
        ],
      ),
    ];
  }
}

class _ReportSection {
  final String title;
  final String subtitle;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<_ReportItem> items;

  const _ReportSection({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _ReportItem {
  final String title;
  final String emoji;
  final IconData icon;
  final String route;
  final String description;

  const _ReportItem({
    required this.title,
    required this.emoji,
    required this.icon,
    required this.route,
    required this.description,
  });
}
