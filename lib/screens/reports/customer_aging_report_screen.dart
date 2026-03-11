import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/aging_service.dart';
import '../../widgets/ui/custom_card.dart';
import '../../utils/app_toast.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class CustomerAgingReportScreen extends StatefulWidget {
  const CustomerAgingReportScreen({super.key});

  @override
  State<CustomerAgingReportScreen> createState() =>
      _CustomerAgingReportScreenState();
}

class _CustomerAgingReportScreenState extends State<CustomerAgingReportScreen>
    with
        SingleTickerProviderStateMixin,
        ReportPdfMixin<CustomerAgingReportScreen> {
  late final AgingService _agingService;
  late final TabController _tabController;

  bool _isLoading = true;
  bool _isLocking = false;
  AgingSummary? _summary;

  @override
  void initState() {
    super.initState();
    _agingService = context.read<AgingService>();
    _tabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _agingService.generateAgingReport();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error: $e');
      }
    }
  }

  Future<void> _handleLockCritical() async {
    if (_summary == null || _summary!.criticalCustomers.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Lock Critical Customers'),
        content: Text(
          'This will block credit for ${_summary!.criticalCustomers.length} customers with payments overdue by 90+ days. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Lock Customers'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLocking = true);
    try {
      final result = await _agingService.lockCriticalCustomers(
        _summary!.criticalCustomers,
      );
      if (mounted) {
        AppToast.showSuccess(
          context,
          'Locked ${result['success']} customers, ${result['failed']} failed.',
        );
        _loadReport();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLocking = false);
    }
  }

  @override
  bool get hasExportData => _summary != null;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Customer Name',
      'Invoice Number',
      'Invoice Date',
      'Days Overdue',
      'Balance (₹)',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    if (_summary == null) return [];

    AgingBucket bucket;
    switch (_tabController.index) {
      case 0:
        bucket = _summary!.overdue90;
        break;
      case 1:
        bucket = _summary!.overdue60;
        break;
      case 2:
        bucket = _summary!.overdue30;
        break;
      case 3:
      default:
        bucket = _summary!.current;
        break;
    }

    return bucket.customers.map((c) {
      return [
        c.customerName,
        c.invoiceNumber,
        _formatDateSafe(c.invoiceDate),
        c.daysOverdue.toString(),
        c.balanceAmount.toStringAsFixed(2),
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    String tabName = '';
    switch (_tabController.index) {
      case 0:
        tabName = 'Critical (90+)';
        break;
      case 1:
        tabName = '61-90 Days';
        break;
      case 2:
        tabName = '31-60 Days';
        break;
      case 3:
        tabName = 'Current (0-30)';
        break;
    }

    return {
      'Active Category': tabName,
      'Total Outstanding': _summary != null
          ? '₹${NumberFormat.compact().format(_summary!.totalOutstanding)}'
          : '-',
      'Total Invoices Overdue': _summary != null
          ? '${_summary!.totalInvoices}'
          : '-',
      'Critical Customers Count': _summary != null
          ? '${_summary!.criticalCustomers.length}'
          : '-',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Aging Report'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Customer Aging Report'),
            onPrint: () => printReport('Customer Aging Report'),
            onRefresh: _loadReport,
          ),
          if (_summary != null && _summary!.criticalCustomers.isNotEmpty)
            IconButton(
              icon: _isLocking
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.lock_outline),
              onPressed: _isLocking ? null : _handleLockCritical,
              tooltip: 'Lock Critical Customers',
            ),
        ],
        bottom: ThemedTabBar(
          controller: _tabController,
          isScrollable: true,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
            alpha: 0.7,
          ),
          tabs: const [
            Tab(text: 'Critical (90+)'),
            Tab(text: '61-90 Days'),
            Tab(text: '31-60 Days'),
            Tab(text: 'Current (0-30)'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
          ? const Center(child: Text('Failed to generate report'))
          : Column(
              children: [
                _buildSummaryHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBucketList(_summary!.overdue90, AppColors.error),
                      _buildBucketList(_summary!.overdue60, AppColors.warning),
                      _buildBucketList(_summary!.overdue30, AppColors.warning),
                      _buildBucketList(_summary!.current, AppColors.success),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    final theme = Theme.of(context);
    final infoBg = theme.brightness == Brightness.dark
        ? AppColors.darkInfoBg
        : AppColors.infoBg;
    return Container(
      padding: const EdgeInsets.all(16),
      color: infoBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem(
            'Total Outstanding',
            '₹${NumberFormat.compact().format(_summary!.totalOutstanding)}',
            AppColors.info,
          ),
          _summaryItem(
            'Invoices',
            '${_summary!.totalInvoices}',
            theme.colorScheme.onSurfaceVariant,
          ),
          _summaryItem(
            'Critical',
            '${_summary!.criticalCustomers.length}',
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBucketList(AgingBucket bucket, Color color) {
    if (bucket.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.success.withValues(alpha: 0.24),
            ),
            const SizedBox(height: 12),
            Text(
              'No invoices in this bucket',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bucket.customers.length,
      itemBuilder: (context, index) {
        final cust = bucket.customers[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              cust.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Inv: ${cust.invoiceNumber} • Overdue: ${cust.daysOverdue} days',
            ),
            trailing: Text(
              '₹${NumberFormat('#,##,###').format(cust.balanceAmount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            childrenPadding: const EdgeInsets.all(16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Invoice Date:', _formatDateSafe(cust.invoiceDate)),
              _infoRow('Due Date:', _formatDateSafe(cust.dueDate)),
              _infoRow(
                'Total Amount:',
                '₹${cust.totalAmount.toStringAsFixed(2)}',
              ),
              _infoRow(
                'Paid Amount:',
                '₹${cust.paidAmount.toStringAsFixed(2)}',
              ),
              const Divider(),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to customer details if needed
                  },
                  child: const Text('View Customer Profile'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
