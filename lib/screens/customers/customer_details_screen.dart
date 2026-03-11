import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/customers_service.dart';
import '../../services/payments_service.dart';
import '../../services/aging_service.dart';
import '../../data/repositories/customer_repository.dart';
import 'customer_form_dialog.dart';
import '../../services/settings_service.dart';
import '../../services/sales_service.dart';
import '../../models/types/sales_types.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/utils/responsive.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final PaymentsService _paymentsService;
  late final AgingService _agingService;
  late final SettingsService _settingsService;
  late final SalesService _salesService;

  Customer? _customer;
  List<ManualPayment> _ledger = [];
  AgingSummary? _agingSummary;
  List<Sale> _recentSales = [];
  Map<int, double> _monthlySales = {};

  bool _isLoading = true;
  // ignore: unused_field
  bool _isLoadingLedger = false;
  List<String> _allRoutes = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _paymentsService = context.read<PaymentsService>();
    _agingService = context.read<AgingService>();
    _settingsService = context.read<SettingsService>();
    _salesService = context.read<SalesService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadCustomer(),
      _loadLedger(),
      _loadAging(),
      _loadRoutes(),
      _loadSalesData(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await _settingsService.getRoutes();
      if (mounted) setState(() => _allRoutes = routes);
    } catch (e) {
      debugPrint('Error loading routes: $e');
    }
  }

  Future<void> _loadCustomer() async {
    try {
      final customerRepo = context.read<CustomerRepository>();
      final customerEntity = await customerRepo.getCustomerById(
        widget.customerId,
      );
      if (mounted) {
        setState(() {
          _customer = customerEntity?.toDomain();
        });
      }
    } catch (e) {
      debugPrint('Error loading customer: $e');
    }
  }

  Future<void> _loadLedger() async {
    try {
      _isLoadingLedger = true;
      final ledger = await _paymentsService.getPayments(
        customerId: widget.customerId,
      );
      if (mounted) {
        setState(() {
          _ledger = ledger;
          _isLoadingLedger = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLedger = false);
    }
  }

  Future<void> _loadAging() async {
    try {
      final summary = await _agingService.generateAgingReport();
      if (mounted) setState(() => _agingSummary = summary);
    } catch (e) {
      debugPrint('Error loading aging: $e');
    }
  }

  Future<void> _loadSalesData() async {
    try {
      final sales = await _salesService.getSalesClient(
        customerId: widget.customerId,
        limit: 50,
      );
      final now = DateTime.now();
      final Map<int, double> tempMonthly = {};
      for (int i = 0; i < 6; i++) {
        final date = DateTime(now.year, now.month - i, 1);
        tempMonthly[date.month] = 0.0;
      }
      for (var sale in sales) {
        final saleDate = DateTime.parse(sale.createdAt);
        if (tempMonthly.containsKey(saleDate.month)) {
          tempMonthly[saleDate.month] =
              (tempMonthly[saleDate.month] ?? 0) + sale.totalAmount;
        }
      }
      if (mounted) {
        setState(() {
          _recentSales = sales;
          _monthlySales = tempMonthly;
        });
      }
    } catch (e) {
      debugPrint('Error loading sales: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_customer == null) {
      return const Scaffold(body: Center(child: Text('Customer not found')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildKPISection(),
                _buildChartSection(),
                _buildTabButtons(),
                _buildTabContent(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFABs(),
    );
  }

  Widget _buildSliverAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: colorScheme.onPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditDialog(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.store_rounded,
                  size: 150,
                  color: colorScheme.onPrimary.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _customer!.shopName,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.route_rounded,
                          size: 16,
                          color: colorScheme.onPrimary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _customer!.route,
                          style: TextStyle(
                            color: colorScheme.onPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: colorScheme.onPrimary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _customer!.city ?? 'N/A',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPISection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: KPICard(
              title: 'Outstanding',
              value: '₹${NumberFormat('#,##,###').format(_customer!.balance)}',
              icon: Icons.account_balance_wallet,
              color: _customer!.balance > 0 ? AppColors.warning : AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KPICard(
              title: '6M Sales',
              value:
                  '₹${NumberFormat('#,##,###').format(_monthlySales.values.fold(0.0, (a, b) => a + b))}',
              icon: Icons.trending_up,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    if (_monthlySales.isEmpty) return const SizedBox.shrink();
    final sortedMonths = _monthlySales.keys.toList()..sort();
    final spots = sortedMonths
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), _monthlySales[e.value] ?? 0))
        .toList();

    return UnifiedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Trend (6 Months)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ThemedTabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Order History'),
          Tab(text: 'Financials'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: Responsive.clamp(context, min: 360, max: 620, ratio: 0.7),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalesTab(),
          _buildFinancialsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          UnifiedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Divider(),
                const SizedBox(height: 8),
                _infoRow(Icons.person, 'Owner', _customer!.ownerName),
                _infoRow(Icons.phone, 'Mobile', _customer!.mobile),
                if (_customer!.alternateMobile != null)
                  _infoRow(
                    Icons.phone_iphone,
                    'WhatsApp',
                    _customer!.alternateMobile!,
                  ),
                if (_customer!.email != null)
                  _infoRow(Icons.email, 'Email', _customer!.email!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          UnifiedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Divider(),
                const SizedBox(height: 8),
                _infoRow(Icons.location_on, 'Address', _customer!.address),
                _infoRow(Icons.map, 'City', _customer!.city ?? 'N/A'),
                _infoRow(Icons.route, 'Route', _customer!.route),
                if (_customer!.gstin != null)
                  _infoRow(Icons.receipt, 'GSTIN', _customer!.gstin!),
                if (_customer!.pan != null)
                  _infoRow(Icons.credit_card, 'PAN', _customer!.pan!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    if (_recentSales.isEmpty) return const Center(child: Text('No orders yet'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentSales.length,
      itemBuilder: (context, index) {
        final sale = _recentSales[index];
        return UnifiedCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              'INV-${sale.id.substring(sale.id.length - 6).toUpperCase()}',
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy').format(DateTime.parse(sale.createdAt)),
            ),
            trailing: Text(
              '₹${NumberFormat('#,##,###').format(sale.totalAmount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => context.pushNamed(
              'sales_details',
              pathParameters: {'id': sale.id},
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinancialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgingSection(),
          const SizedBox(height: 24),
          const Text(
            'Recent Payments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildLedgerList(),
        ],
      ),
    );
  }

  Widget _buildAgingSection() {
    if (_agingSummary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<AgingCustomerDetail> allDetails = [
      ..._agingSummary!.current.customers,
      ..._agingSummary!.overdue30.customers,
      ..._agingSummary!.overdue60.customers,
      ..._agingSummary!.overdue90.customers,
    ];

    final customerInvoices = allDetails
        .where((d) => d.customerId == widget.customerId)
        .toList();

    return UnifiedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Outstanding Invoices',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Divider(),
          const SizedBox(height: 8),
          if (customerInvoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No pending invoices'),
            )
          else
            ...customerInvoices.map(
              (inv) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Inv: ${inv.invoiceNumber}'),
                subtitle: Text('${inv.daysOverdue} days overdue'),
                trailing: Text(
                  '₹${inv.balanceAmount.toInt()}',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLedgerList() {
    if (_ledger.isEmpty) return const Center(child: Text('No payment history'));
    return Column(
      children: _ledger
          .map(
            (payment) => UnifiedCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.download,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
                title: Text('₹${payment.amount.toInt()}'),
                subtitle: Text(
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(payment.date)),
                ),
                trailing: Text(
                  payment.mode.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFABs() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'pay',
          onPressed: () async {
            final result = await context.pushNamed(
              'payments_add',
              extra: {
                'customerId': _customer!.id,
                'customerName': _customer!.shopName,
              },
            );
            if (result == true) _loadAll();
          },
          label: const Text('Add Payment'),
          icon: const Icon(Icons.add_card),
          backgroundColor: AppColors.success,
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'order',
          onPressed: () => context.pushNamed('sales_new', extra: _customer),
          label: const Text('New Order'),
          icon: const Icon(Icons.shopping_basket),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomerFormDialog(
        customer: _customer,
        allRoutes: _allRoutes,
        onSaved: () {
          _loadCustomer();
          Navigator.pop(context);
        },
      ),
    );
  }
}

