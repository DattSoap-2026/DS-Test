import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/diesel_service.dart';
import '../../services/vehicles_service.dart';
import '../../services/users_service.dart';
import '../../widgets/ui/unified_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../models/types/user_types.dart';

class DieselReportScreen extends StatefulWidget {
  const DieselReportScreen({super.key});

  @override
  State<DieselReportScreen> createState() => _DieselReportScreenState();
}

class _DieselReportScreenState extends State<DieselReportScreen>
    with SingleTickerProviderStateMixin, ReportPdfMixin<DieselReportScreen> {
  late DieselService _dieselService;
  late VehiclesService _vehiclesService;
  late UsersService _usersService;
  late TabController _tabController;

  bool _isLoading = true;
  bool _loadingVehicles = true;
  bool _loadingDrivers = true;

  // Data
  List<DieselLog> _logs = [];
  List<Vehicle> _vehicles = [];
  List<String> _drivers = [];

  // Filters
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
    end: DateTime.now(),
  );
  String _selectedVehicleId = 'all';
  String _selectedDriverName = 'all';

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    _vehiclesService = context.read<VehiclesService>();
    _usersService = context.read<UsersService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadVehicles();
    _loadDrivers();
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      final v = await _vehiclesService.getVehicles(status: 'active');
      if (mounted) {
        setState(() {
          _vehicles = v;
          _loadingVehicles = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading vehicles: $e");
      if (mounted) setState(() => _loadingVehicles = false);
    }
  }

  Future<void> _loadDrivers() async {
    try {
      final users = await _usersService.getUsers(role: UserRole.driver);
      final names =
          users
              .map((u) => u.name.trim())
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (mounted) {
        setState(() {
          _drivers = names;
          _loadingDrivers = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading drivers: $e");
      if (mounted) setState(() => _loadingDrivers = false);
    }
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      final results = await _dieselService.getDieselLogs(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
        vehicleId: _selectedVehicleId == 'all' ? null : _selectedVehicleId,
      );
      var filtered = results;
      if (_selectedDriverName != 'all') {
        final selected = _selectedDriverName.trim().toLowerCase();
        filtered = results.where((log) {
          return log.driverName.trim().toLowerCase() == selected;
        }).toList();
      }

      if (mounted) {
        setState(() {
          _logs = filtered;
          final reportDriverNames = results
              .map((log) => log.driverName.trim())
              .where((name) => name.isNotEmpty)
              .toSet();
          if (reportDriverNames.isNotEmpty) {
            _drivers = {..._drivers, ...reportDriverNames}.toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          }
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

  Future<void> _selectDateRange() async {
    final picked = await ResponsiveDatePickers.pickDateRange(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadReport();
    }
  }

  // Analytics Helpers
  double get _totalCost => _logs.fold(0, (sum, log) => sum + log.totalCost);
  double get _totalLiters => _logs.fold(0, (sum, log) => sum + log.liters);

  // Mileage Logic: React logic filters outliers 0 < m < 50
  List<double> get _validMileages => _logs
      .map((l) => l.cycleEfficiency ?? l.mileage ?? 0)
      .where((m) => m > 0 && m < 50)
      .toList();

  double get _avgMileage => _validMileages.isNotEmpty
      ? _validMileages.reduce((a, b) => a + b) / _validMileages.length
      : 0;
  double get _totalPenalty =>
      _logs.fold(0, (sum, log) => sum + (log.penaltyAmount ?? 0));
  bool get _isDriverFilterActive => _selectedDriverName != 'all';

  List<_MonthlyPenaltySummary> get _monthlyPenaltyReport {
    final grouped = <String, _MonthlyPenaltySummary>{};

    for (final log in _logs) {
      final date = DateTime.tryParse(log.fillDate);
      if (date == null) continue;
      final key = DateFormat('yyyy-MM').format(date);
      final label = DateFormat('MMM yyyy').format(date);
      final existing =
          grouped[key] ??
          _MonthlyPenaltySummary(
            monthKey: key,
            monthLabel: label,
            fills: 0,
            liters: 0,
            cost: 0,
            penalty: 0,
          );

      grouped[key] = _MonthlyPenaltySummary(
        monthKey: key,
        monthLabel: label,
        fills: existing.fills + 1,
        liters: existing.liters + log.liters,
        cost: existing.cost + log.totalCost,
        penalty: existing.penalty + (log.penaltyAmount ?? 0),
      );
    }

    final list = grouped.values.toList()
      ..sort((a, b) => a.monthKey.compareTo(b.monthKey));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diesel Report'),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Diesel Report'),
            onPrint: () => printReport('Diesel Report'),
            onRefresh: _loadReport,
          ),
        ],
        bottom: ThemedTabBar(
          controller: _tabController,
          unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Efficiency'),
            Tab(text: 'Mileage'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildEfficiencyTab(),
          _buildMileageTab(), // Just a placeholder for now to match React structure
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilters(),
          _buildKPIs(),
          if (_isDriverFilterActive) ...[
            const SizedBox(height: 12),
            _buildDriverMonthlySummary(),
          ],
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Fuel Logs",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 8),
          _buildLogList(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return UnifiedCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;

              final dateFilter = UnifiedCard(
                onTap: _selectDateRange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                backgroundColor: Theme.of(context).cardTheme.color,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
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
                      "${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM').format(_dateRange.end)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );

              final vehicleFilter = DropdownButtonFormField<String>(
                initialValue: _selectedVehicleId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Vehicle',
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
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All')),
                  ..._vehicles.map(
                    (v) => DropdownMenuItem(
                      value: v.id,
                      child: Text(v.number, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: _loadingVehicles
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() => _selectedVehicleId = val);
                          _loadReport();
                        }
                      },
              );
              final driverFilter = _buildDriverFilterField();

              if (isMobile) {
                return Column(
                  children: [
                    dateFilter,
                    const SizedBox(height: 10),
                    vehicleFilter,
                    const SizedBox(height: 10),
                    driverFilter,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 2, child: dateFilter),
                  const SizedBox(width: 12),
                  Expanded(child: vehicleFilter),
                  const SizedBox(width: 12),
                  Expanded(child: driverFilter),
                ],
              );
            },
          ),
          ReportDateRangeButtons(
            value: _dateRange,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onChanged: (range) {
              setState(() => _dateRange = range);
              _loadReport();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDriverFilterField() {
    final hasSelection = _selectedDriverName != 'all';
    final selectedText = hasSelection ? _selectedDriverName : 'All Drivers';

    return InkWell(
      onTap: _loadingDrivers ? null : _openDriverPicker,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Driver',
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                _loadingDrivers ? 'Loading drivers...' : selectedText,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: hasSelection
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.search, size: 18, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Future<void> _openDriverPicker() async {
    if (_loadingDrivers) return;

    var query = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final normalized = query.trim().toLowerCase();
            final matches = _drivers.where((name) {
              if (normalized.isEmpty) return true;
              return name.toLowerCase().contains(normalized);
            }).toList();
            final visible = normalized.isEmpty && matches.length > 150
                ? matches.take(150).toList()
                : matches;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() => query = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search driver...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('All Drivers'),
                    trailing: _selectedDriverName == 'all'
                        ? const Icon(Icons.check, size: 18)
                        : null,
                    onTap: () {
                      setState(() => _selectedDriverName = 'all');
                      Navigator.of(context).pop();
                      _loadReport();
                    },
                  ),
                  if (normalized.isEmpty && matches.length > 150)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        'Showing first 150 drivers. Type to narrow results.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  Expanded(
                    child: visible.isEmpty
                        ? const Center(child: Text('No drivers found'))
                        : ListView.builder(
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final driver = visible[index];
                              return ListTile(
                                title: Text(driver),
                                trailing: _selectedDriverName == driver
                                    ? const Icon(Icons.check, size: 18)
                                    : null,
                                onTap: () {
                                  setState(() => _selectedDriverName = driver);
                                  Navigator.of(context).pop();
                                  _loadReport();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKPIs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final cardWidth = isMobile
            ? constraints.maxWidth
            : (constraints.maxWidth - 8) / 2;

        final cards = [
          _buildStatCard(
            'Total Cost',
            '₹${_totalCost.toStringAsFixed(0)}',
            Icons.currency_rupee,
            AppColors.error,
          ),
          _buildStatCard(
            'Total Fuel',
            '${_totalLiters.toStringAsFixed(1)} L',
            Icons.local_gas_station,
            AppColors.info,
          ),
          _buildStatCard(
            'Avg Mileage',
            '${_avgMileage.toStringAsFixed(2)} km/l',
            Icons.speed,
            _avgMileage > 10 ? AppColors.success : AppColors.warning,
          ),
          _buildStatCard(
            'Fills',
            '${_logs.length}',
            Icons.opacity,
            AppColors.lightPrimary,
          ),
          if (_isDriverFilterActive)
            _buildStatCard(
              'Total Penalty',
              'Rs ${_totalPenalty.toStringAsFixed(0)}',
              Icons.warning_amber,
              _totalPenalty > 0 ? AppColors.error : AppColors.success,
            ),
        ];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return UnifiedCard(
      onTap: null,
      backgroundColor: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverMonthlySummary() {
    final monthly = _monthlyPenaltyReport;
    final totalMonthlyPenalty = monthly.fold<double>(
      0,
      (sum, month) => sum + month.penalty,
    );

    return UnifiedCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: Theme.of(context).cardTheme.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Monthly Report: $_selectedDriverName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Total Monthly Penalty: Rs ${totalMonthlyPenalty.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: totalMonthlyPenalty > 0
                  ? AppColors.error
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          if (monthly.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No monthly entries found for selected driver.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthly.length,
              separatorBuilder: (_, _) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final item = monthly[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.monthLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: Text('Fills: ${item.fills}')),
                    Expanded(
                      child: Text('Fuel: ${item.liters.toStringAsFixed(1)} L'),
                    ),
                    Expanded(
                      child: Text(
                        'Penalty: Rs ${item.penalty.toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_logs.isEmpty) return const Center(child: Text("No fuel logs found"));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final log = _logs[index];
        final mileage = log.cycleEfficiency ?? log.mileage ?? 0;
        Color mileageColor = mileage >= 12
            ? AppColors.success
            : (mileage >= 8 ? AppColors.warning : AppColors.error);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log.vehicleNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${log.totalCost.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (log.driverName.trim().isNotEmpty)
                    Text(
                      'Driver: ${log.driverName.trim()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  if (log.driverName.trim().isNotEmpty)
                    const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDateSafe(log.fillDate, pattern: 'dd MMM'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const Spacer(),
                      if (mileage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: mileageColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${mileage.toStringAsFixed(1)} km/l',
                            style: TextStyle(
                              color: mileageColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${log.liters.toStringAsFixed(1)} L @ ₹${log.rate}/L',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      if (log.penaltyAmount != null && log.penaltyAmount! > 0)
                        Text(
                          'Penalty: ₹${log.penaltyAmount!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Widget _buildEfficiencyTab() {
    // Placeholder for Efficiency Analysis
    // In React: Vehicle Fuel Efficiency Analysis
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final Map<String, List<DieselLog>> byVehicle = {};
    for (var log in _logs) {
      if (!byVehicle.containsKey(log.vehicleId)) byVehicle[log.vehicleId] = [];
      byVehicle[log.vehicleId]!.add(log);
    }

    final stats = <Map<String, dynamic>>[];
    byVehicle.forEach((vId, vLogs) {
      final totalL = vLogs.fold(0.0, (s, l) => s + l.liters);
      final totalC = vLogs.fold(0.0, (s, l) => s + l.totalCost);
      final totalD = vLogs.fold(0.0, (s, l) => s + (l.cycleDistance ?? 0));
      final avgM = totalL > 0 ? totalD / totalL : 0.0;
      if (vLogs.isNotEmpty) {
        stats.add({
          'name': vLogs.first.vehicleNumber,
          'avgMileage': avgM,
          'cost': totalC,
        });
      }
    });

    stats.sort(
      (a, b) =>
          (b['avgMileage'] as double).compareTo(a['avgMileage'] as double),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final item = stats[index];
        final avgM = item['avgMileage'] as double;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: ListTile(
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Total Cost: ₹${(item['cost'] as double).toStringAsFixed(0)}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${avgM.toStringAsFixed(2)} km/l',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: avgM >= 10 ? AppColors.success : AppColors.warning,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Average",
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMileageTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_validMileages.isEmpty) {
      return const Center(child: Text("No mileage data available"));
    }

    // Bucket mileages: 0-5, 5-10, 10-15, 15-20, 20+
    final buckets = LatencyBuckets();
    for (var m in _validMileages) {
      if (m < 5) {
        buckets.b1++;
      } else if (m < 10) {
        buckets.b2++;
      } else if (m < 15) {
        buckets.b3++;
      } else if (m < 20) {
        buckets.b4++;
      } else {
        buckets.b5++;
      }
    }

    final theme = Theme.of(context);
    final data = [buckets.b1, buckets.b2, buckets.b3, buckets.b4, buckets.b5];
    final labels = ['0-5', '5-10', '10-15', '15-20', '20+'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Mileage Distribution (km/l)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (data.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= labels.length) {
                          return const Text('');
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[value.toInt()],
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].toDouble(),
                        color: theme.primaryColor,
                        width: 25,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Analyzed from ${_logs.length} trip entries",
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get hasExportData => _logs.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    if (_tabController.index == 1) {
      // Efficiency
      return ['Vehicle', 'Total Cost (₹)', 'Avg Mileage (km/l)'];
    }
    // Overview & Mileage
    return [
      'Date',
      'Vehicle No',
      'Driver',
      'Liters',
      'Rate (₹)',
      'Cost (₹)',
      'Mileage',
      'Penalty (₹)',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    if (_tabController.index == 1) {
      // Efficiency
      final Map<String, List<DieselLog>> byVehicle = {};
      for (var log in _logs) {
        if (!byVehicle.containsKey(log.vehicleId)) {
          byVehicle[log.vehicleId] = [];
        }
        byVehicle[log.vehicleId]!.add(log);
      }

      final stats = <Map<String, dynamic>>[];
      byVehicle.forEach((vId, vLogs) {
        final totalL = vLogs.fold(0.0, (s, l) => s + l.liters);
        final totalC = vLogs.fold(0.0, (s, l) => s + l.totalCost);
        final totalD = vLogs.fold(0.0, (s, l) => s + (l.cycleDistance ?? 0));
        final avgM = totalL > 0 ? totalD / totalL : 0.0;
        if (vLogs.isNotEmpty) {
          stats.add({
            'name': vLogs.first.vehicleNumber,
            'avgMileage': avgM,
            'cost': totalC,
          });
        }
      });

      stats.sort(
        (a, b) =>
            (b['avgMileage'] as double).compareTo(a['avgMileage'] as double),
      );

      return stats
          .map(
            (item) => [
              item['name'],
              (item['cost'] as double).toStringAsFixed(0),
              (item['avgMileage'] as double).toStringAsFixed(2),
            ],
          )
          .toList();
    }

    // Overview & Mileage
    return _logs.map((log) {
      final mileage = log.cycleEfficiency ?? log.mileage ?? 0;
      return [
        _formatDateSafe(log.fillDate),
        log.vehicleNumber,
        log.driverName.isNotEmpty ? log.driverName : '-',
        log.liters.toStringAsFixed(1),
        log.rate.toStringAsFixed(2),
        log.totalCost.toStringAsFixed(0),
        mileage > 0 ? mileage.toStringAsFixed(1) : 'N/A',
        (log.penaltyAmount ?? 0).toStringAsFixed(0),
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    String tabName = [
      'Overview',
      'Efficiency',
      'Mileage',
    ][_tabController.index];

    final vList = _vehicles.where((v) => v.id == _selectedVehicleId).toList();
    final selectedVehicle = _selectedVehicleId == 'all'
        ? 'All Vehicles'
        : (vList.isNotEmpty ? vList.first.number : 'Unknown');

    return {
      'Date Range':
          '${DateFormat('dd-MMM-yyyy').format(_dateRange.start)} - ${DateFormat('dd-MMM-yyyy').format(_dateRange.end)}',
      'Vehicle': selectedVehicle,
      'Driver': _selectedDriverName == 'all'
          ? 'All Drivers'
          : _selectedDriverName,
      'Active Tab': tabName,
      'Total Fuel': '${_totalLiters.toStringAsFixed(1)} L',
      'Total Cost': '₹${_totalCost.toStringAsFixed(0)}',
      'Total Penalty': 'Rs ${_totalPenalty.toStringAsFixed(0)}',
      'Avg Mileage': '${_avgMileage.toStringAsFixed(2)} km/l',
    };
  }
}

class LatencyBuckets {
  int b1 = 0;
  int b2 = 0;
  int b3 = 0;
  int b4 = 0;
  int b5 = 0;
}

class _MonthlyPenaltySummary {
  final String monthKey;
  final String monthLabel;
  final int fills;
  final double liters;
  final double cost;
  final double penalty;

  const _MonthlyPenaltySummary({
    required this.monthKey,
    required this.monthLabel,
    required this.fills,
    required this.liters,
    required this.cost,
    required this.penalty,
  });
}
