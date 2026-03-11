import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sales_targets_service.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class SalesTargetsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SalesTargetsScreen({super.key, this.onBack});

  @override
  State<SalesTargetsScreen> createState() => _SalesTargetsScreenState();
}

class _SalesTargetsScreenState extends State<SalesTargetsScreen> {
  late final SalesTargetsService _targetsService;
  late final UsersService _usersService;
  bool _isLoading = true;
  List<AppUser> _salesmen = [];
  List<SalesTarget> _targets = [];
  String _searchQuery = '';

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _targetsService = context.read<SalesTargetsService>();
    _usersService = context.read<UsersService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _usersService.getUsers(role: UserRole.salesman),
        _targetsService.getSalesTargets(null), // Fetch all targets
      ]);
      if (mounted) {
        setState(() {
          _salesmen = results[0] as List<AppUser>;
          _targets = results[1] as List<SalesTarget>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  SalesTarget? _getTargetForSalesman(String id) {
    return _targets
        .cast<SalesTarget?>()
        .firstWhere(
          (t) =>
              t?.salesmanId == id &&
              t?.month == _selectedMonth &&
              t?.year == _selectedYear,
          orElse: () => null,
        );
  }

  double get _totalTarget {
    double total = 0;
    for (var salesman in _salesmen) {
      final t = _getTargetForSalesman(salesman.id);
      if (t != null) total += t.targetAmount;
    }
    return total;
  }

  double get _totalAchieved {
    double total = 0;
    for (var salesman in _salesmen) {
      final t = _getTargetForSalesman(salesman.id);
      if (t != null) total += t.achievedAmount;
    }
    return total;
  }

  AppUser? get _topPerformer {
    AppUser? top;
    double maxAchieved = -1;
    for (var salesman in _salesmen) {
      final t = _getTargetForSalesman(salesman.id);
      if (t != null && t.achievedAmount > maxAchieved) {
        maxAchieved = t.achievedAmount;
        top = salesman;
      }
    }
    return top;
  }

  List<AppUser> get _filteredSalesmen {
    if (_searchQuery.isEmpty) return _salesmen;
    return _salesmen
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildScreenHeader()),
                SliverToBoxAdapter(child: _buildPeriodSelector()),
                SliverToBoxAdapter(child: _buildDashboardStats()),
                SliverToBoxAdapter(child: _buildSearchField()),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final salesman = _filteredSalesmen[index];
                      final target = _getTargetForSalesman(salesman.id);
                      return _buildSalesmanCard(salesman, target);
                    }, childCount: _filteredSalesmen.length),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildScreenHeader() {
    return MasterScreenHeader(
      title: 'Sales Targets',
      subtitle: 'Performance targets for sales team',
      helperText:
          'Targets are used for reporting and incentive comparison only.',
      color: AppColors.info,
      icon: Icons.track_changes,
      onBack: widget.onBack,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.info),
          onPressed: _loadData,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _selectedMonth,
              items: List.generate(
                12,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_getMonthName(i + 1)),
                ),
              ),
              onChanged: (val) => setState(() => _selectedMonth = val!),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _selectedYear,
              items: List.generate(
                5,
                (i) => DropdownMenuItem(
                  value: 2024 + i,
                  child: Text('${2024 + i}'),
                ),
              ),
              onChanged: (val) => setState(() => _selectedYear = val!),
            ),
            const SizedBox(width: 16),
            Text(
              'Period: ${_getMonthName(_selectedMonth)} $_selectedYear',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    final theme = Theme.of(context);
    final progress = _totalTarget > 0 ? _totalAchieved / _totalTarget : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Target',
                  '\u20B9${_totalTarget.toStringAsFixed(0)}',
                  Icons.ads_click,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Achieved',
                  '\u20B9${_totalAchieved.toStringAsFixed(0)}',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPerformerCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerCard() {
    final theme = Theme.of(context);
    final performer = _topPerformer;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.warning,
          child: Icon(
            Icons.emoji_events,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(
          'Top Performer',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          performer?.name ?? 'No data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: performer != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: performer == null
            ? null
            : _buildBadge('Most Achieved', AppColors.warning),
      ),
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search salesman...',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          isDense: true,
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildSalesmanCard(AppUser salesman, SalesTarget? target) {
    final theme = Theme.of(context);
    final progress = target != null && target.targetAmount > 0
        ? target.achievedAmount / target.targetAmount
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    salesman.name[0],
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salesman.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        salesman.email,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_note, color: theme.colorScheme.primary),
                  onPressed: () => _showSetTargetDialog(salesman, target),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achieved: \u20B9${target?.achievedAmount.toStringAsFixed(0) ?? "0"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Target: \u20B9${target?.targetAmount.toStringAsFixed(0) ?? "0"}',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.outlineVariant.withValues(
                alpha: 0.1,
              ),
              valueColor: AlwaysStoppedAnimation(
                progress >= 1.0
                    ? AppColors.success
                    : theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% Completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: progress >= 1.0
                        ? AppColors.success
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (progress >= 1.0) _buildBadge('Target Met', AppColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSetTargetDialog(AppUser salesman, SalesTarget? existing) {
    final theme = Theme.of(context);
    final controller = TextEditingController(
      text: existing?.targetAmount.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Text('Edit Target: ${salesman.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setting target for ${_getMonthName(_selectedMonth)} $_selectedYear',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Target Amount (\u20B9)',
                hintText: 'Enter amount...',
                border: OutlineInputBorder(),
                prefixText: '\u20B9 ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              setState(() => _isLoading = true);
              try {
                await _targetsService.setSalesTarget(
                  AddSalesTargetPayload(
                    salesmanId: salesman.id,
                    salesmanName: salesman.name,
                    month: _selectedMonth,
                    year: _selectedYear,
                    targetAmount: amount,
                  ),
                );
                _loadData();
              } finally {
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Update Target'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int m) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m];
  }
}




