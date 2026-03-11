import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/sales_service.dart'; // Added
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart'; // Added
import '../../models/types/sales_types.dart'; // Fixed import
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:intl/intl.dart'; // Added
import 'package:flutter_app/core/theme/app_colors.dart';

class IncentivesScreen extends StatefulWidget {
  const IncentivesScreen({super.key});

  @override
  State<IncentivesScreen> createState() => _IncentivesScreenState();
}

class _IncentivesScreenState extends State<IncentivesScreen>
    with SingleTickerProviderStateMixin {
  late final SettingsService _settingsService;
  // SalesService will be accessed via Provider to use the global instance

  late TabController _tabController;

  bool _isLoading = true;
  bool _isSaving = false;
  late ReportsPreferences _prefs;

  // Dashboard State
  List<Sale> _mtdSales = [];
  double _mtdTotalSales = 0;
  double _mtdCommission = 0;

  // Controllers - General
  final _workDaysController = TextEditingController();
  final _dailyTargetController = TextEditingController();
  final _dailyIncentiveController = TextEditingController();
  final _newCustomerIncentiveController = TextEditingController();
  final _miscellaneousBonusController = TextEditingController();
  final _mileagePenaltyController = TextEditingController();

  // Controllers - Commission
  final _basePercentageController = TextEditingController();
  final _targetThresholdController = TextEditingController();
  final _targetBonusController = TextEditingController();

  // Calculator State
  double _calcSales = 50000;
  double _calcTarget = 40000;

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _tabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Preferences (Everyone needs this for rules/calc)
      _prefs = await _settingsService.getReportsPreferences();

      if (!mounted) return;

      // 2. Populate Admin Controllers
      _populateControllers();

      // 3. Load Salesman Specific Data (if applicable)
      final user = context.read<AuthProvider>().state.user;
      if (user != null && user.role == UserRole.salesman) {
        await _loadSalesmanStats(user.id);
        if (!mounted) return;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Error handling but allow offline defaults if prefs fail?
        // _prefs is late, so we must succeed or handle it.
        // Assuming settings service handled it.
      }
    }
  }

  void _populateControllers() {
    _workDaysController.text = _prefs.requiredMonthlyWorkDays.toString();
    _dailyTargetController.text = _prefs.dailyCounterTarget.toString();
    _dailyIncentiveController.text = _prefs.dailyIncentiveAmount.toString();
    _newCustomerIncentiveController.text = _prefs.newCustomerIncentive
        .toString();
    _miscellaneousBonusController.text = _prefs.miscellaneousBonus.toString();
    _mileagePenaltyController.text = _prefs.mileagePenaltyAmount.toString();

    _basePercentageController.text = _prefs.baseCommissionPercentage.toString();
    _targetThresholdController.text = _prefs.monthlyTargetIncentiveThreshold
        .toString();
    _targetBonusController.text = _prefs.targetBonusPercentage.toString();
  }

  Future<void> _loadSalesmanStats(String salesmanId) async {
    try {
      final salesService = context.read<SalesService>(); // Use global
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Offline Local Fetch
      final sales = await salesService.getSalesClient(
        salesmanId: salesmanId,
        startDate: startOfMonth,
      );

      double total = 0;
      double commission = 0;

      for (var sale in sales) {
        total += sale.totalAmount;
        commission += sale.commissionAmount ?? 0.0;
      }

      setState(() {
        _mtdSales = sales;
        _mtdTotalSales = total;
        _mtdCommission = commission;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _workDaysController.dispose();
    _dailyTargetController.dispose();
    _dailyIncentiveController.dispose();
    _newCustomerIncentiveController.dispose();
    _miscellaneousBonusController.dispose();
    _mileagePenaltyController.dispose();
    _basePercentageController.dispose();
    _targetThresholdController.dispose();
    _targetBonusController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final updatedPrefs = ReportsPreferences(
        isAiEnabled: _prefs.isAiEnabled,
        defaultDateRange: _prefs.defaultDateRange,
        defaultSalesReportGrouping: _prefs.defaultSalesReportGrouping,
        lowStockThreshold: _prefs.lowStockThreshold,
        workingDays: _prefs.workingDays,
        requiredMonthlyWorkDays:
            int.tryParse(_workDaysController.text) ??
            _prefs.requiredMonthlyWorkDays,
        dailyCounterTarget:
            int.tryParse(_dailyTargetController.text) ??
            _prefs.dailyCounterTarget,
        dailyIncentiveAmount:
            double.tryParse(_dailyIncentiveController.text) ??
            _prefs.dailyIncentiveAmount,
        newCustomerIncentive:
            double.tryParse(_newCustomerIncentiveController.text) ??
            _prefs.newCustomerIncentive,
        miscellaneousBonus:
            double.tryParse(_miscellaneousBonusController.text) ??
            _prefs.miscellaneousBonus,
        mileagePenaltyAmount:
            double.tryParse(_mileagePenaltyController.text) ??
            _prefs.mileagePenaltyAmount,

        commissionType: _prefs.commissionType,
        baseCommissionPercentage:
            double.tryParse(_basePercentageController.text) ??
            _prefs.baseCommissionPercentage,
        commissionSlabs: _prefs.commissionSlabs,
        targetBonusPercentage:
            double.tryParse(_targetBonusController.text) ??
            _prefs.targetBonusPercentage,
        monthlyTargetIncentiveThreshold:
            double.tryParse(_targetThresholdController.text) ??
            _prefs.monthlyTargetIncentiveThreshold,
        monthlyTargetIncentivePercentage:
            _prefs.monthlyTargetIncentivePercentage,

        financialYearStart: _prefs.financialYearStart,
        defaultDashboardKPIs: _prefs.defaultDashboardKPIs,
      );

      final success = await _settingsService.updateReportsPreferences(
        updatedPrefs,
        user.id,
        user.name,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences saved successfully')),
          );
          _loadData(); // Reload to refresh state
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save preferences')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please Log In')));
    }

    // Role Branching
    if (user.role == UserRole.salesman) {
      return _buildSalesmanView();
    } else {
      return _buildAdminView();
    }
  }

  Widget _buildAdminView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Incentives'),
        bottom: ThemedTabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Rules'),
            Tab(
              icon: Icon(Icons.account_balance_wallet_outlined),
              text: 'Commission',
            ),
            Tab(icon: Icon(Icons.trending_up), text: 'Incentives'),
            Tab(icon: Icon(Icons.calculate_outlined), text: 'Calculator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRulesTab(),
          _buildCommissionTab(),
          _buildIncentivesTab(),
          _buildCalculatorTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            label: 'Save All Settings',
            icon: Icons.save,
            isLoading: _isSaving,
            onPressed: _handleSave,
          ),
        ),
      ),
    );
  }

  Widget _buildSalesmanView() {
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          final user = context.read<AuthProvider>().state.user;
          if (user != null) await _loadSalesmanStats(user.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEarningsSummary(),
              const SizedBox(height: 24),
              const Text(
                "Recent Sales",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              _buildRecentSalesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSummary() {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4f46e5), const Color(0xFF818cf8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4f46e5).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Commission Earned (Month To Date)",
            style: TextStyle(
              color: onPrimary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_mtdCommission.toStringAsFixed(0)}',
            style: TextStyle(
              color: onPrimary,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: onPrimary.withValues(alpha: 0.24), height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Sales",
                    style: TextStyle(
                      color: onPrimary.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '₹${_mtdTotalSales.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Sales Count",
                    style: TextStyle(
                      color: onPrimary.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${_mtdSales.length}',
                    style: TextStyle(
                      color: onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSalesList() {
    if (_mtdSales.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No sales recorded this month"),
        ),
      );
    }

    // Show top 5
    final recent = _mtdSales.take(10).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      itemBuilder: (context, index) {
        final sale = recent[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              sale.recipientName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _formatDateSafe(sale.createdAt, pattern: 'MMM dd, hh:mm a'),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${sale.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if ((sale.commissionAmount ?? 0) > 0)
                  Text(
                    '+ ₹${sale.commissionAmount!.toStringAsFixed(2)} comm',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
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

  Widget _buildRulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Defaults',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  initialValue: _prefs.defaultDateRange,
                  decoration: const InputDecoration(
                    labelText: 'Default Date Range',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('Last 7 Days')),
                    DropdownMenuItem(value: 30, child: Text('Last 30 Days')),
                    DropdownMenuItem(value: 90, child: Text('Last 90 Days')),
                  ],
                  onChanged: (v) => setState(
                    () => _prefs = ReportsPreferences.fromJson({
                      ..._prefs.toJson(),
                      'defaultDateRange': v,
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Low Stock Threshold',
                  initialValue: _prefs.lowStockThreshold.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _prefs = ReportsPreferences.fromJson({
                    ..._prefs.toJson(),
                    'lowStockThreshold': int.tryParse(v) ?? 10,
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Work Force Metrics',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Required Monthly Work Days',
                  controller: _workDaysController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Daily Counter Visit Target',
                  controller: _dailyTargetController,
                  keyboardType: TextInputType.number,
                  hintText: 'Min shops to visit per day',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commission Structure',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Choose how commission is calculated on sales',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _prefs.commissionType,
                  decoration: const InputDecoration(
                    labelText: 'Commission Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Flat Percentage'),
                    ),
                    DropdownMenuItem(
                      value: 'slab',
                      child: Text('Slab-Based (Tiered)'),
                    ),
                    DropdownMenuItem(
                      value: 'target_based',
                      child: Text('Target + Bonus'),
                    ),
                  ],
                  onChanged: (v) => setState(
                    () => _prefs = ReportsPreferences.fromJson({
                      ..._prefs.toJson(),
                      'commissionType': v,
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                if (_prefs.commissionType == 'percentage') ...[
                  CustomTextField(
                    label: 'Base Commission %',
                    controller: _basePercentageController,
                    keyboardType: TextInputType.number,
                    suffixText: '%',
                  ),
                ] else if (_prefs.commissionType == 'slab') ...[
                  _buildSlabManagement(),
                ] else if (_prefs.commissionType == 'target_based') ...[
                  CustomTextField(
                    label: 'Base Commission %',
                    controller: _basePercentageController,
                    keyboardType: TextInputType.number,
                    suffixText: '%',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Target Goal %',
                          controller: _targetThresholdController,
                          keyboardType: TextInputType.number,
                          suffixText: '%',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Bonus %',
                          controller: _targetBonusController,
                          keyboardType: TextInputType.number,
                          suffixText: '%',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Bonus applied if Sales >= Target Goal %',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlabManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Commission Slabs',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _prefs.commissionSlabs.add(
                    CommissionSlab(minAmount: 0, maxAmount: 0, percentage: 0),
                  );
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Slab'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_prefs.commissionSlabs.isEmpty)
          Center(
            child: Text(
              'No slabs defined',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _prefs.commissionSlabs.length,
            itemBuilder: (context, index) {
              final slab = _prefs.commissionSlabs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.info.withValues(alpha: 0.1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: 'Min',
                        initialValue: slab.minAmount.toString(),
                        keyboardType: TextInputType.number,
                        isDense: true,
                        onChanged: (v) =>
                            _updateSlab(index, minAmount: double.tryParse(v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: 'Max',
                        initialValue: slab.maxAmount.toString(),
                        keyboardType: TextInputType.number,
                        isDense: true,
                        onChanged: (v) =>
                            _updateSlab(index, maxAmount: double.tryParse(v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: '%',
                        initialValue: slab.percentage.toString(),
                        keyboardType: TextInputType.number,
                        isDense: true,
                        onChanged: (v) =>
                            _updateSlab(index, percentage: double.tryParse(v)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _prefs.commissionSlabs.removeAt(index),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _updateSlab(
    int index, {
    double? minAmount,
    double? maxAmount,
    double? percentage,
  }) {
    final old = _prefs.commissionSlabs[index];
    setState(() {
      _prefs.commissionSlabs[index] = CommissionSlab(
        minAmount: minAmount ?? old.minAmount,
        maxAmount: maxAmount ?? old.maxAmount,
        percentage: percentage ?? old.percentage,
      );
    });
  }

  Widget _buildIncentivesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance Bonuses',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Daily Incentive (₹)',
                  controller: _dailyIncentiveController,
                  keyboardType: TextInputType.number,
                  prefixText: '₹',
                  hintText: 'Bonus for meeting daily visit target',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'New Customer Bonus (₹)',
                  controller: _newCustomerIncentiveController,
                  keyboardType: TextInputType.number,
                  prefixText: '₹',
                  hintText: 'Per new shop onboarded',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Misc & Penalties',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Miscellaneous Bonus (₹)',
                  controller: _miscellaneousBonusController,
                  keyboardType: TextInputType.number,
                  prefixText: '₹',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Mileage Penalty (₹/deficit)',
                  controller: _mileagePenaltyController,
                  keyboardType: TextInputType.number,
                  prefixText: '₹',
                  hintText: 'Penalty for low fuel efficiency',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    final result = _calculateIncentive();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Calculator',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Preview earnings based on current settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Estimated Sales (₹)',
                        initialValue: _calcSales.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(
                          () => _calcSales = double.tryParse(v) ?? 0,
                        ),
                      ),
                    ),
                    if (_prefs.commissionType == 'target_based') ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Monthly Target (₹)',
                          initialValue: _calcTarget.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(
                            () => _calcTarget = double.tryParse(v) ?? 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildResultDisplay(result),
        ],
      ),
    );
  }

  Widget _buildResultDisplay(Map<String, dynamic> result) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'PROJECTED COMMISSION',
            style: TextStyle(
              color: onPrimary.withValues(alpha: 0.7),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${(result['total'] as double).toStringAsFixed(2)}',
            style: TextStyle(
              color: onPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: onPrimary.withValues(alpha: 0.24)),
          const SizedBox(height: 16),
          _buildResultRow(
            'Base Commission',
            '₹${(result['base'] as double).toStringAsFixed(2)}',
          ),
          if (result['bonus'] > 0)
            _buildResultRow(
              'Target Bonus',
              '+ ₹${(result['bonus'] as double).toStringAsFixed(2)}',
              isBonus: true,
            ),
          const SizedBox(height: 12),
          Text(
            'Calculation Type: ${_prefs.commissionType.toUpperCase()}',
            style: TextStyle(
              color: onPrimary.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBonus = false}) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: onPrimary, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: isBonus ? AppColors.success : onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateIncentive() {
    double base = 0;
    double bonus = 0;

    if (_prefs.commissionType == 'percentage') {
      final pct =
          double.tryParse(_basePercentageController.text) ??
          _prefs.baseCommissionPercentage;
      base = _calcSales * (pct / 100);
    } else if (_prefs.commissionType == 'slab') {
      double remaining = _calcSales;
      for (var slab in _prefs.commissionSlabs) {
        if (remaining <= 0) break;
        double slabTotal = slab.maxAmount - slab.minAmount;
        if (slabTotal <= 0) slabTotal = 99999999;

        double taxableInSlab = (remaining > slabTotal) ? slabTotal : remaining;
        base += taxableInSlab * (slab.percentage / 100);
        remaining -= taxableInSlab;
      }
    } else if (_prefs.commissionType == 'target_based') {
      final basePct =
          double.tryParse(_basePercentageController.text) ??
          _prefs.baseCommissionPercentage;
      base = _calcSales * (basePct / 100);

      final targetGoalPct =
          double.tryParse(_targetThresholdController.text) ??
          _prefs.monthlyTargetIncentiveThreshold;
      final bonusPct =
          double.tryParse(_targetBonusController.text) ??
          _prefs.targetBonusPercentage;

      final achievement = (_calcSales / _calcTarget) * 100;
      if (achievement >= targetGoalPct) {
        bonus = base * (bonusPct / 100);
      }
    }

    return {'base': base, 'bonus': bonus, 'total': base + bonus};
  }
}
