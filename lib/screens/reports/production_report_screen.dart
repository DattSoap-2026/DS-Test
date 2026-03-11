import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/production_repository.dart';
import '../../models/types/product_types.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/production_service.dart'; // Import for models
import '../../services/products_service.dart';
import '../../utils/unit_scope_utils.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/unified_card.dart';
import '../../data/local/entities/production_entry_entity.dart';
import '../../utils/app_toast.dart';
import '../../utils/responsive.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/ui/shimmer_loading.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class ProductionReportScreen extends StatefulWidget {
  const ProductionReportScreen({super.key});

  @override
  State<ProductionReportScreen> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen>
    with
        SingleTickerProviderStateMixin,
        ReportPdfMixin<ProductionReportScreen> {
  late TabController _tabController;

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  List<ProductionDailyEntryEntity> _logs = [];

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // Analytics
  List<Map<String, dynamic>> _dailyTrend = [];
  Map<String, Map<String, dynamic>> _materialUsage = {};
  List<Map<String, dynamic>> _supervisorPerf = [];
  Map<String, dynamic> _timeAnalysis = {};
  double _overallEfficiency = 100.0;
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});
  bool _isScopeFallbackMode = false;
  bool _isSupervisorCompatibilityMode = false;
  String _dependencySignature = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = context.read<AuthProvider>().currentUser;
    final nextSignature = _buildDependencySignature(currentUser);
    if (nextSignature == _dependencySignature) return;
    _dependencySignature = nextSignature;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _buildDependencySignature(AppUser? user) {
    if (user == null) return 'guest';
    final departments = user.departments
        .map((d) => '${d.main}:${d.team ?? ''}')
        .join('|');
    return [
      user.id,
      user.role.value,
      user.department ?? '',
      user.assignedBhatti ?? '',
      departments,
    ].join('::');
  }

  String get _unitScopeDisplayLabel {
    if (_isSupervisorCompatibilityMode) {
      return 'All Units (Compatibility Mode)';
    }
    return _unitScope.label;
  }

  Future<void> _loadData({bool forcePageLoader = false}) async {
    if (!mounted) return;
    if (_isRefreshing) return;
    setState(() {
      final showFullLoader = forcePageLoader || !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
    });

    try {
      final currentUser = context.read<AuthProvider>().currentUser;
      _unitScope = resolveUserUnitScope(currentUser);
      final hasNoScopeTokens = !_unitScope.canViewAll && _unitScope.keys.isEmpty;
      final isSupervisorCompatibilityMode =
          hasNoScopeTokens && currentUser?.role == UserRole.productionSupervisor;
      final effectiveScope = hasNoScopeTokens ? null : _unitScope;
      final showScopeFallbackBanner =
          hasNoScopeTokens && !isSupervisorCompatibilityMode;
      final repo = context.read<ProductionRepository>();
      final service = context.read<ProductionService>();
      final productsService = context.read<ProductsService>();

      // parallel fetch
      final results = await Future.wait([
        repo.getProductionEntriesByDateRange(
          startDate: _dateRange.start,
          endDate: _dateRange.end,
        ),
        service.getProductionTargetsInDateRange(
          _dateRange.start,
          _dateRange.end,
        ),
        service.getDetailedProductionLogs(
          startDate: _dateRange.start,
          endDate: _dateRange.end,
        ),
        productsService.getProducts(),
      ]);

      final allLogs = results[0] as List<ProductionDailyEntryEntity>;
      final allTargets = results[1] as List<ProductionTarget>;
      final allDetailedLogs = results[2] as List<DetailedProductionLog>;
      final products = results[3] as List<Product>;

      final productById = {for (final p in products) p.id: p};

      final logs = allLogs
          .where((entry) => _matchesProductionEntryScope(entry, scope: effectiveScope))
          .toList();
      final allowedBatchNumbers = logs
          .expand((entry) => entry.items)
          .map((item) => item.batchNumber.trim().toLowerCase())
          .where((batchNumber) => batchNumber.isNotEmpty)
          .toSet();

      final detailedLogs = allDetailedLogs.where((log) {
        final batchNumber = log.batchNumber.trim().toLowerCase();
        if (allowedBatchNumbers.isNotEmpty &&
            allowedBatchNumbers.contains(batchNumber)) {
          return true;
        }
        final product = productById[log.productId];
        return _matchesProductScope(product, scope: effectiveScope);
      }).toList();

      final targets = allTargets.where((target) {
        final product = productById[target.productId];
        return _matchesProductScope(product, scope: effectiveScope);
      }).toList();

      _calcAnalytics(logs, targets, detailedLogs);

      if (mounted) {
        setState(() {
          _logs = logs;
          _isScopeFallbackMode = showScopeFallbackBanner;
          _isSupervisorCompatibilityMode = isSupervisorCompatibilityMode;
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
        });
        AppToast.showError(context, 'Error loading report: $e');
      }
    }
  }

  bool _matchesProductionEntryScope(
    ProductionDailyEntryEntity entry, {
    UserUnitScope? scope,
  }) {
    if (scope == null) return true;
    return matchesUnitScope(
      scope: scope,
      tokens: [entry.departmentCode, entry.departmentName, entry.teamCode],
      defaultIfNoScopeTokens: false,
    );
  }

  bool _matchesProductScope(
    Product? product, {
    UserUnitScope? scope,
  }) {
    if (scope == null) return true;
    if (product == null) {
      return scope.canViewAll;
    }
    return matchesUnitScope(
      scope: scope,
      tokens: [product.departmentId, ...product.allowedDepartmentIds],
      defaultIfNoScopeTokens: false,
    );
  }

  void _calcAnalytics(
    List<ProductionDailyEntryEntity> logs,
    List<ProductionTarget> targets,
    List<DetailedProductionLog> detailedLogs,
  ) {
    // 1. Daily Trend & Efficiency
    final dailyMap = <String, Map<String, dynamic>>{};

    for (var l in logs) {
      final date = l.date.toIso8601String().split('T')[0];
      if (!dailyMap.containsKey(date)) {
        dailyMap[date] = {
          'date': date,
          'produced': 0.0,
          'wastage': 0.0,
          'target': 0.0,
        };
      }
      final dayQty = l.items.fold<int>(0, (sum, i) => sum + i.totalBatchQuantity);
      dailyMap[date]!['produced'] =
          (dailyMap[date]!['produced'] as double) + dayQty;
    }

    // Merge Targets into Daily Map
    double totalTarget = 0;
    double totalAchieved = 0;

    for (var t in targets) {
      final date = t.targetDate; // YYYY-MM-DD
      if (!dailyMap.containsKey(date)) {
        // Even if no logs, we might have had a target
        dailyMap[date] = {
          'date': date,
          'produced':
              0.0, // May be filled by actuals later if logic differs, but here assume logs matches
          'wastage': 0.0,
          'target': 0.0,
        };
      }
      dailyMap[date]!['target'] =
          (dailyMap[date]!['target'] as double) + t.targetQuantity;
      totalTarget += t.targetQuantity;
    }

    // Calculate daily efficiency
    for (var key in dailyMap.keys) {
      final d = dailyMap[key]!;
      final produced = d['produced'] as double;
      final target = d['target'] as double;
      if (produced > 0) totalAchieved += produced;

      d['efficiency'] = (target > 0)
          ? (produced / target) * 100
          : (produced > 0 ? 100.0 : 0.0);
    }

    _dailyTrend = dailyMap.values.toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));

    _overallEfficiency = (totalTarget > 0)
        ? (totalAchieved / totalTarget) * 100
        : 0.0;

    // 2. Material Consumption (Aggregation)
    final matMap = <String, Map<String, dynamic>>{};

    void aggregateMaterial(List<Map<String, dynamic>>? materials) {
      if (materials == null) return;
      for (var m in materials) {
        // Handle different key naming conventions if they exist, fallback to 'name' or 'materialName'
        final name =
            m['materialName'] ?? m['productName'] ?? m['name'] ?? 'Unknown';
        final qty = (m['quantity'] as num?)?.toDouble() ?? 0.0;
        final unit = m['unit'] ?? 'Unit';

        final key = "$name-$unit";
        if (!matMap.containsKey(key)) {
          matMap[key] = {'name': name, 'quantity': 0.0, 'unit': unit};
        }
        matMap[key]!['quantity'] = (matMap[key]!['quantity'] as double) + qty;
      }
    }

    for (var log in detailedLogs) {
      aggregateMaterial(log.semiFinishedGoodsUsed);
      aggregateMaterial(log.packagingMaterialsUsed);
      aggregateMaterial(log.additionalRawMaterialsUsed);
    }
    _materialUsage = matMap;

    // 3. Supervisor Perf
    final supMap = <String, Map<String, dynamic>>{};

    for (var l in logs) {
      final sId = l.createdBy;
      final sName = l.createdByName;

      if (!supMap.containsKey(sId)) {
        supMap[sId] = {
          'id': sId,
          'name': sName,
          'batches': 0,
          'produced': 0,
          'wastage': 0.0,
        };
      }

      supMap[sId]!['batches'] += l.items.length;
      final prod = l.items.fold(0, (sum, i) => sum + i.totalBatchQuantity);
      supMap[sId]!['produced'] += prod;
    }

    _supervisorPerf = supMap.values.toList();
    for (var s in _supervisorPerf) {
      s['avgBatch'] = (s['batches'] > 0) ? s['produced'] / s['batches'] : 0.0;
      // Estimate efficiency based on overall average for now
      s['efficiency'] = _overallEfficiency;
    }
    _supervisorPerf.sort((a, b) => b['produced'].compareTo(a['produced']));

    int totalBatches = logs.fold<int>(0, (sum, l) => sum + l.items.length);
    double totalProdVal = logs.fold<double>(
      0,
      (sum, l) => sum + l.items.fold<int>(0, (s, i) => s + i.totalBatchQuantity),
    );
    double avgBatch = totalBatches > 0 ? totalProdVal / totalBatches : 0;

    _timeAnalysis = {
      'totalBatches': totalBatches,
      'totalUnits': totalProdVal,
      'avgBatchSize': avgBatch,
    };
  }

  Future<void> _selectDateRange() async {
    final picked = await ResponsiveDatePickers.pickDateRange(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadData();
    }
  }

  @override
  bool get hasExportData {
    switch (_tabController.index) {
      case 0:
        return _dailyTrend.isNotEmpty;
      case 1:
        return _materialUsage.isNotEmpty;
      case 2:
        return _supervisorPerf.isNotEmpty;
      case 3:
        return _logs.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  List<String> buildPdfHeaders() {
    switch (_tabController.index) {
      case 0:
        return ['Date', 'Produced', 'Target', 'Efficiency %'];
      case 1:
        return ['Material/Product', 'Quantity', 'Unit'];
      case 2:
        return ['Supervisor', 'Batches', 'Output', 'Efficiency %'];
      case 3:
        return ['Date', 'Dept/Team', 'Supervisor', 'Batches', 'Total Qty'];
      default:
        return [];
    }
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    switch (_tabController.index) {
      case 0:
        return _dailyTrend
            .map(
              (d) => [
                _formatDateSafe(d['date']?.toString() ?? ''),
                d['produced'].toString(),
                d['target'].toString(),
                '${(d['efficiency'] as double).toStringAsFixed(1)}%',
              ],
            )
            .toList();
      case 1:
        final sortedKeys = _materialUsage.keys.toList()..sort();
        return sortedKeys.map((k) {
          final m = _materialUsage[k]!;
          return [m['name'], m['quantity'].toString(), m['unit']];
        }).toList();
      case 2:
        return _supervisorPerf
            .map(
              (s) => [
                s['name'],
                s['batches'].toString(),
                s['produced'].toString(),
                '${(s['efficiency'] as double).toStringAsFixed(1)}%',
              ],
            )
            .toList();
      case 3:
        return _logs.map((l) {
          final qty = l.items.fold(0, (sum, i) => sum + i.totalBatchQuantity);
          return [
            DateFormat('dd MMM yyyy').format(l.date),
            l.departmentName,
            l.createdByName,
            l.items.length.toString(),
            qty.toString(),
          ];
        }).toList();
      default:
        return [];
    }
  }

  @override
  Map<String, String> buildFilterSummary() {
    String tabName = [
      'Trends',
      'Materials',
      'Supervisors',
      'Logs',
    ][_tabController.index];
    return {
      'Date Range':
          '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      'Active Tab': tabName,
      'Unit Scope': _unitScopeDisplayLabel,
      'Overall Efficiency': '${_overallEfficiency.toStringAsFixed(1)}%',
      'Total Produced': (_timeAnalysis['totalUnits'] ?? 0).toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Analytics'),
        bottom: ThemedTabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trends'),
            Tab(text: 'Materials'),
            Tab(text: 'Supervisors'),
            Tab(text: 'Logs'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Production Analytics Report'),
            onPrint: () => printReport('Production Analytics Report'),
            onRefresh: _loadData,
          ),
        ],
      ),
      body: (_isLoading && !_hasLoadedOnce)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Unit Scope: $_unitScopeDisplayLabel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (_isScopeFallbackMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _buildScopeFallbackBanner(),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ReportDateRangeButtons(
                    value: _dateRange,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    onChanged: (range) {
                      setState(() => _dateRange = range);
                      _loadData();
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabRefreshShell(
                        label: 'Refreshing trends',
                        child: _buildTrendsTab(),
                      ),
                      _buildTabRefreshShell(
                        label: 'Refreshing materials',
                        child: _buildMaterialsTab(),
                      ),
                      _buildTabRefreshShell(
                        label: 'Refreshing supervisors',
                        child: _buildSupervisorTab(),
                      ),
                      _buildTabRefreshShell(
                        label: 'Refreshing logs',
                        child: _buildLogsTab(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabRefreshShell({
    required String label,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isRefreshing
              ? Container(
                  key: ValueKey('refresh_$label'),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          color: theme.colorScheme.primary,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('refresh_none')),
        ),
        Expanded(
          child: ShimmerLoading(
            isLoading: _isRefreshing,
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildScopeFallbackBanner() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No unit assigned. Contact admin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (_isRefreshing && _dailyTrend.isEmpty) {
      return _buildTrendsSkeleton();
    }

    if (_dailyTrend.isEmpty) {
      return Center(
        child: Text(
          'No production trends available for this period.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKpi(
                  'Total Produced',
                  (_timeAnalysis['totalUnits'] ?? 0).toStringAsFixed(0),
                  Theme.of(context).colorScheme.primary,
                  Icons.factory,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpi(
                  'Efficiency',
                  '${_overallEfficiency.toStringAsFixed(1)}%',
                  (_overallEfficiency >= 90)
                      ? AppColors.success
                      : AppColors.warning,
                  Icons.speed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Daily Performance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dailyTrend.length,
            itemBuilder: (context, index) {
              final d = _dailyTrend[index];
              final eff = d['efficiency'] as double;
              final dateText = _formatDateSafe(
                d['date']?.toString() ?? '',
                pattern: 'EEE, dd MMM',
              );
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${eff.toStringAsFixed(0)}% Eff',
                            style: TextStyle(
                              color: (eff >= 90)
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat('Produced', d['produced']),
                          _buildMiniStat('Target', d['target']),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    if (_isRefreshing && _materialUsage.isEmpty) {
      return _buildSimpleListSkeleton(cardCount: 5);
    }

    if (_materialUsage.isEmpty) {
      return const Center(
        child: Text("No material usage data available for this period."),
      );
    }

    final sortedKeys = _materialUsage.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final data = _materialUsage[key]!;
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.science, size: 20)),
            title: Text(data['name']),
            trailing: Text(
              "${(data['quantity'] as double).toStringAsFixed(2)} ${data['unit']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupervisorTab() {
    if (_isRefreshing && _supervisorPerf.isEmpty) {
      return _buildSimpleListSkeleton(cardCount: 4);
    }

    if (_supervisorPerf.isEmpty) {
      return Center(
        child: Text(
          'No supervisor performance data available for this period.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _supervisorPerf.length,
      itemBuilder: (context, index) {
        final s = _supervisorPerf[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Eff: ${s['efficiency'].toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat('Batches', s['batches']),
                    _buildMiniStat('Output', s['produced']),
                    // Wastage not tracked per supervisor in this view yet
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogsTab() {
    if (_isRefreshing && _logs.isEmpty) {
      return _buildSimpleListSkeleton(cardCount: 4, cardHeight: 110);
    }

    if (_logs.isEmpty) {
      return Center(
        child: Text(
          'No production logs available for this period.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        final isLast = index == _logs.length - 1;
        return _buildTimelineEntry(log, isLast: isLast);
      },
    );
  }

  Widget _buildTimelineEntry(
    ProductionDailyEntryEntity log, {
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final totalQty = log.items.fold(0, (sum, i) => sum + i.totalBatchQuantity);
    final day = DateFormat('dd').format(log.date);
    final month = DateFormat('MMM').format(log.date).toUpperCase();
    final weekday = DateFormat('EEE').format(log.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.clamp(
                  context,
                  min: 52,
                  max: 72,
                  ratio: 0.08,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    day,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    month,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weekday,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: UnifiedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.departmentName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _buildLogChip(
                          '${log.items.length} batches',
                          AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supervisor: ${log.createdByName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildLogMeta(
                          Icons.inventory_2_outlined,
                          'Units: ${totalQty.toStringAsFixed(0)}',
                        ),
                        _buildLogMeta(
                          Icons.event_available_rounded,
                          'Date: ${DateFormat('dd MMM').format(log.date)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Widget _buildLogChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildLogMeta(IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpi(String title, String value, Color color, IconData icon) {
    final theme = Theme.of(context);
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, dynamic value, {Color? color}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonBlock(height: 120)),
            const SizedBox(width: 8),
            Expanded(child: _buildSkeletonBlock(height: 120)),
          ],
        ),
        const SizedBox(height: 20),
        _buildSkeletonBlock(height: 22, width: 180),
        const SizedBox(height: 10),
        ...List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSkeletonBlock(height: 84),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleListSkeleton({
    required int cardCount,
    double cardHeight = 72,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cardCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildSkeletonBlock(height: cardHeight),
      ),
    );
  }

  Widget _buildSkeletonBlock({required double height, double? width}) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
