import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/bhatti_repository.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/bhatti_service.dart'; // Import for service & models
import '../../models/types/user_types.dart';
import '../../widgets/ui/custom_card.dart';
import '../../data/local/entities/bhatti_entry_entity.dart';
import '../../utils/app_toast.dart';
import '../../utils/unit_scope_utils.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class BhattiReportScreen extends StatefulWidget {
  const BhattiReportScreen({super.key});

  @override
  State<BhattiReportScreen> createState() => _BhattiReportScreenState();
}

class _BhattiReportScreenState extends State<BhattiReportScreen>
    with SingleTickerProviderStateMixin, ReportPdfMixin<BhattiReportScreen> {
  late TabController _tabController;

  bool _isLoading = true;
  List<BhattiDailyEntryEntity> _entries = [];
  List<BhattiBatch> _detailedBatches = [];
  List<Map<String, dynamic>> _wastages = [];

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // Analytics
  int _totalBatches = 0;
  int _gitaBatches = 0;
  int _sonaBatches = 0;
  int _totalBoxes = 0;
  double _totalWastage = 0;
  Map<String, Map<String, dynamic>> _materialConsumption = {};
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});

  bool _matchesScope(Iterable<String?> tokens) {
    return matchesUnitScope(
      scope: _unitScope,
      tokens: tokens,
      defaultIfNoScopeTokens: false,
    );
  }

  String _normalizeBhattiKey(String? value) {
    final raw = (value ?? '').trim().toLowerCase();
    if (raw.contains('gita') || raw.contains('geeta')) return 'gita';
    if (raw.contains('sona')) return 'sona';
    return raw;
  }

  void _handleBack() {
    final user = context.read<AuthProvider>().state.user;
    if (user?.role == UserRole.bhattiSupervisor) {
      context.go('/dashboard/bhatti/overview');
      return;
    }

    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/dashboard/reports/')) {
      context.go('/dashboard/reports');
      return;
    }
    context.go('/dashboard');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = context.read<AuthProvider>().currentUser;
      _unitScope = resolveUserUnitScope(currentUser);

      final repo = context.read<BhattiRepository>();
      final service = context.read<BhattiService>();

      String? bhattiFilter;
      if (_unitScope.keys.isNotEmpty && !_unitScope.canViewAll) {
        // If they have a specific unit, use it for filtering
        bhattiFilter = _unitScope.keys.first;
      }

      final results = await Future.wait([
        repo.getBhattiEntriesByDateRange(
          startDate: _dateRange.start,
          endDate: _dateRange.end,
        ),
        service.getBhattiBatches(
          startDate: _dateRange.start,
          endDate: _dateRange.end,
          bhattiName: bhattiFilter,
        ),
        service.getWastageLogs(
          startDate: _dateRange.start,
          endDate: _dateRange.end,
          bhattiName: bhattiFilter,
        ),
      ]);

      final entries = (results[0] as List<BhattiDailyEntryEntity>)
          .where((e) => _matchesScope([e.bhattiId, e.bhattiName, e.teamCode]))
          .toList();
      final detailedBatches = (results[1] as List<BhattiBatch>)
          .where((b) => _matchesScope([b.bhattiName, b.targetProductName]))
          .toList();

      final wastages = (results[2] as List<Map<String, dynamic>>)
          .where(
            (w) => _matchesScope([
              w['returnedTo']?.toString(),
              w['productName']?.toString(),
            ]),
          )
          .toList();

      _calcAnalytics(entries, detailedBatches, wastages);

      if (mounted) {
        setState(() {
          _entries = entries;
          _detailedBatches = detailedBatches;
          _wastages = wastages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading report: $e');
      }
    }
  }

  void _calcAnalytics(
    List<BhattiDailyEntryEntity> entries,
    List<BhattiBatch> detailedBatches,
    List<Map<String, dynamic>> wastages,
  ) {
    // Prefer detailed batch source because cooking page now writes bhatti_batches.
    if (detailedBatches.isNotEmpty) {
      _totalBatches = detailedBatches.fold(0, (sum, b) => sum + b.batchCount);
      _gitaBatches = detailedBatches
          .where((b) => _normalizeBhattiKey(b.bhattiName) == 'gita')
          .fold(0, (sum, b) => sum + b.batchCount);
      _sonaBatches = detailedBatches
          .where((b) => _normalizeBhattiKey(b.bhattiName) == 'sona')
          .fold(0, (sum, b) => sum + b.batchCount);
      _totalBoxes = detailedBatches.fold(0, (sum, b) => sum + b.outputBoxes);
    } else {
      _totalBatches = entries.fold(0, (sum, e) => sum + e.batchCount);
      _gitaBatches = entries
          .where((e) => _normalizeBhattiKey(e.bhattiName) == 'gita')
          .fold(0, (sum, e) => sum + e.batchCount);
      _sonaBatches = entries
          .where((e) => _normalizeBhattiKey(e.bhattiName) == 'sona')
          .fold(0, (sum, e) => sum + e.batchCount);
      _totalBoxes = entries.fold(0, (sum, e) => sum + e.outputBoxes);
    }

    // Wastage logic
    _totalWastage = wastages.fold(0.0, (sum, w) {
      return sum + ((w['quantity'] as num?)?.toDouble() ?? 0.0);
    });

    // Material Consumption Aggregation
    final matMap = <String, Map<String, dynamic>>{};

    void aggregate(List<Map<String, dynamic>>? items) {
      if (items == null) return;
      for (var item in items) {
        // Keys might vary: 'materialName', 'productName'
        final name =
            item['materialName'] ??
            item['productName'] ??
            item['name'] ??
            'Unknown';
        final qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
        final unit = item['unit'] ?? 'Unit'; // Default unit

        final key = "$name-$unit";
        if (!matMap.containsKey(key)) {
          matMap[key] = {'name': name, 'quantity': 0.0, 'unit': unit};
        }
        matMap[key]!['quantity'] = (matMap[key]!['quantity'] as double) + qty;
      }
    }

    for (var b in detailedBatches) {
      aggregate(b.rawMaterialsConsumed);
      aggregate(b.tankConsumptions);
    }
    _materialConsumption = matMap;
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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bhatti Report'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _selectDateRange,
            tooltip: 'Select Range',
          ),
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Bhatti Report'),
            onPrint: () => printReport('Bhatti Report'),
            onRefresh: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 12 : 24,
                    isMobile ? 12 : 16,
                    isMobile ? 12 : 24,
                    8,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            'Unit Scope: ${_unitScope.label}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      ReportDateRangeButtons(
                        value: _dateRange,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onChanged: (range) {
                          setState(() => _dateRange = range);
                          _loadData();
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: ThemedTabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: EdgeInsets.zero,
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Materials'),
                            Tab(text: 'Batches'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildMaterialsTab(),
                      _buildBatchesTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final kpis = <Widget>[
      _buildKpi(
        'Total Batches',
        _totalBatches.toString(),
        Theme.of(context).colorScheme.primary,
        Icons.local_fire_department,
      ),
      _buildKpi(
        'Total Output',
        '$_totalBoxes Boxes',
        Theme.of(context).colorScheme.secondary,
        Icons.inventory_2,
      ),
      _buildKpi(
        'Gita Bhatti',
        _gitaBatches.toString(),
        Theme.of(context).colorScheme.tertiary,
        Icons.whatshot,
      ),
      _buildKpi(
        'Sona Bhatti',
        _sonaBatches.toString(),
        Theme.of(context).colorScheme.tertiary,
        Icons.whatshot,
      ),
      _buildKpi(
        'Total Wastage',
        '${_totalWastage.toStringAsFixed(2)} kg',
        Theme.of(context).colorScheme.error,
        Icons.recycling,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final cardWidth = isNarrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 8) / 2;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kpis
                    .map((card) => SizedBox(width: cardWidth, child: card))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 24),
          if (_wastages.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Wastage Logs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            _buildWastageList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    if (_materialConsumption.isEmpty) {
      return const Center(
        child: Text("No material consumption data available."),
      );
    }

    final sortedKeys = _materialConsumption.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final data = _materialConsumption[key]!;
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.science, size: 20)),
            title: Text(
              data['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "Total: ${(data['quantity'] as double).toStringAsFixed(2)} ${data['unit']}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatchesTab() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_detailedBatches.isNotEmpty) {
      // Use detailed batches if available
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _detailedBatches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final b = _detailedBatches[index];
          return CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          b.bhattiName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b.batchNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Boxes: ${b.outputBoxes} | Status: ${b.status}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (b.rawMaterialsConsumed.isNotEmpty)
                    Text(
                      'Materials: ${b.rawMaterialsConsumed.length} items',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Date: ${_formatDateSafe(b.createdAt, pattern: 'dd MMM HH:mm')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (_entries.isEmpty) return const Center(child: Text("No entries found"));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final b = _entries[index];
        return CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        b.bhattiName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${b.batchCount} batches'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fuel: ${b.fuelConsumption.toStringAsFixed(1)} L | Boxes: ${b.outputBoxes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${DateFormat('dd MMM').format(b.date)}',
                      ),
                    ),
                    if (b.notes != null)
                      Expanded(
                        child: Text(
                          b.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWastageList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _wastages.length > 5 ? 5 : _wastages.length, // Show top 5
      itemBuilder: (context, index) {
        final w = _wastages[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            w['productName'] ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "${w['returnedTo']} - ${w['reason'] ?? ''}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            "${w['quantity']} ${w['unit']}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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

  Widget _buildKpi(String title, String value, Color color, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
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
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get hasExportData {
    switch (_tabController.index) {
      case 0:
        return true;
      case 1:
        return _materialConsumption.isNotEmpty;
      case 2:
        return _detailedBatches.isNotEmpty || _entries.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  List<String> buildPdfHeaders() {
    switch (_tabController.index) {
      case 0:
        return ['Product', 'Returned To', 'Reason', 'Quantity'];
      case 1:
        return ['Material/Product', 'Quantity', 'Unit'];
      case 2:
        if (_detailedBatches.isNotEmpty) {
          return ['Bhatti', 'Batch No', 'Output Boxes', 'Status', 'Date'];
        } else {
          return ['Bhatti', 'Batches', 'Fuel (L)', 'Output Boxes', 'Date'];
        }
      default:
        return [];
    }
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    switch (_tabController.index) {
      case 0:
        return _wastages
            .map(
              (w) => [
                w['productName'] ?? 'Unknown',
                w['returnedTo']?.toString() ?? '',
                w['reason']?.toString() ?? '',
                "${w['quantity']} ${w['unit']}",
              ],
            )
            .toList();
      case 1:
        final sortedKeys = _materialConsumption.keys.toList()..sort();
        return sortedKeys.map((k) {
          final m = _materialConsumption[k]!;
          return [
            m['name'],
            (m['quantity'] as double).toStringAsFixed(2),
            m['unit'],
          ];
        }).toList();
      case 2:
        if (_detailedBatches.isNotEmpty) {
          return _detailedBatches
              .map(
                (b) => [
                  b.bhattiName,
                  b.batchNumber,
                  b.outputBoxes.toString(),
                  b.status,
                  _formatDateSafe(b.createdAt, pattern: 'dd MMM yyyy HH:mm'),
                ],
              )
              .toList();
        } else {
          return _entries
              .map(
                (e) => [
                  e.bhattiName,
                  e.batchCount.toString(),
                  e.fuelConsumption.toStringAsFixed(1),
                  e.outputBoxes.toString(),
                  DateFormat('dd MMM yyyy').format(e.date),
                ],
              )
              .toList();
        }
      default:
        return [];
    }
  }

  @override
  Map<String, String> buildFilterSummary() {
    String tabName = ['Overview', 'Materials', 'Batches'][_tabController.index];

    final summary = <String, String>{
      'Date Range':
          '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      'Active Tab': tabName,
      'Unit Scope': _unitScope.label,
    };

    if (_tabController.index == 0) {
      summary['Total Batches'] = _totalBatches.toString();
      summary['Total Output'] = '$_totalBoxes Boxes';
      summary['Gita Bhatti'] = _gitaBatches.toString();
      summary['Sona Bhatti'] = _sonaBatches.toString();
      summary['Total Wastage'] = '${_totalWastage.toStringAsFixed(2)} kg';
    }

    return summary;
  }
}
