import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/ui/unified_card.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class MaintenanceReportScreen extends StatefulWidget {
  const MaintenanceReportScreen({super.key});

  @override
  State<MaintenanceReportScreen> createState() =>
      _MaintenanceReportScreenState();
}

class _MaintenanceReportScreenState extends State<MaintenanceReportScreen>
    with
        SingleTickerProviderStateMixin,
        ReportPdfMixin<MaintenanceReportScreen> {
  late VehiclesService _vehiclesService;
  late TabController _tabController;

  bool _isLoading = true;
  bool _loadingVehicles = true;

  // Data
  List<MaintenanceLog> _logs = [];
  List<Vehicle> _vehicles = [];

  // Filters
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
    end: DateTime.now(),
  );
  String _selectedVehicleId = 'all';

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadVehicles();
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

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      final results = await _vehiclesService.getMaintenanceLogs(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
        vehicleId: _selectedVehicleId == 'all' ? null : _selectedVehicleId,
      );

      if (mounted) {
        setState(() {
          _logs = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading maintenance report: $e");
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
  int get _totalServices => _logs.length;
  double get _avgCostPerService =>
      _totalServices > 0 ? _totalCost / _totalServices : 0;
  int get _vehiclesServiced => _logs.map((e) => e.vehicleId).toSet().length;

  Map<String, Map<String, dynamic>> _calculateVehicleStats() {
    final stats = <String, Map<String, dynamic>>{};
    for (var log in _logs) {
      if (!stats.containsKey(log.vehicleId)) {
        stats[log.vehicleId] = {
          'name': log.vehicleNumber,
          'count': 0,
          'cost': 0.0,
          'lastDate': log.serviceDate,
        };
      }
      final entry = stats[log.vehicleId]!;
      entry['count'] += 1;
      entry['cost'] += log.totalCost;
      if (log.serviceDate.compareTo(entry['lastDate']) > 0) {
        entry['lastDate'] = log.serviceDate;
      }
    }
    return stats;
  }

  Map<String, Map<String, dynamic>> _calculateTypeStats() {
    final stats = <String, Map<String, dynamic>>{};
    // Note: MaintenanceLog description usually contains items or type strictly.
    // React code parses items from a detailed structure, but here we might just have simple description or need deeper parsing
    // The Flutter model has 'type' field (Routine, Repair, etc) which is high level.
    // For item-level breakdown we'd need item lists which might be in description or a separate collection in future.
    // React code uses log.items.forEach. Let's check Flutter model.
    // Flutter model `MaintenanceLog` has simple fields. It doesn't have `items` list in this version?
    // Let's re-read vehicle_service.dart. Yes, fields are id, vehicleId, ... description, totalCost, type.
    // It seems the React version is more advanced with items list. The Flutter model is simpler.
    // I will aggregate by `type` (Routine, Repair, etc) instead of items for now until model is updated.

    for (var log in _logs) {
      final type = log.type;
      if (!stats.containsKey(type)) {
        stats[type] = {'count': 0, 'cost': 0.0};
      }
      stats[type]!['count'] += 1;
      stats[type]!['cost'] += log.totalCost;
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Report'),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Maintenance Report'),
            onPrint: () => printReport('Maintenance Report'),
            onRefresh: _loadReport,
          ),
        ],
        bottom: ThemedTabBar(
          controller: _tabController,
          unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'By Vehicle'),
            Tab(text: 'Types'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildVehicleTab(), _buildTypeTab()],
      ),
    );
  }

  Widget _buildFilters() {
    return UnifiedCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;

              final dateRangeFilter = UnifiedCard(
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

              if (isCompact) {
                return Column(
                  children: [
                    dateRangeFilter,
                    const SizedBox(height: 10),
                    vehicleFilter,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: dateRangeFilter),
                  const SizedBox(width: 12),
                  Expanded(child: vehicleFilter),
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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilters(),
          _buildKPIs(),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent Logs",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 8),
          _buildLogList(),
        ],
      ),
    );
  }

  Widget _buildKPIs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Cost',
                '₹${_totalCost.toStringAsFixed(0)}',
                Icons.currency_rupee,
                AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Avg Cost',
                '₹${_avgCostPerService.toStringAsFixed(0)}',
                Icons.analytics,
                AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Services',
                '$_totalServices',
                Icons.build,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Vehicles',
                '$_vehiclesServiced',
                Icons.directions_car,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildLogList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_logs.isEmpty) return const Center(child: Text("No logs found"));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final log = _logs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              collapsedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.build,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                log.vehicleNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${_formatDateSafe(log.serviceDate, pattern: 'dd MMM')} • ${log.type}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              trailing: Text(
                '₹${log.totalCost.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                if (log.description.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Note: ${log.description}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                  const Divider(),
                ],
                ...log.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.partName),
                        Text(
                          '${item.quantity.toStringAsFixed(0)} x ₹${item.price.toStringAsFixed(0)} = ₹${(item.quantity * item.price).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vendor:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      log.vendor,
                      style: TextStyle(color: Theme.of(context).primaryColor),
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

  Widget _buildVehicleTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final stats = _calculateVehicleStats();
    final sortedKeys = stats.keys.toList()
      ..sort(
        (a, b) => (stats[b]!['cost'] as double).compareTo(
          stats[a]!['cost'] as double,
        ),
      );

    if (sortedKeys.isEmpty) return const Center(child: Text("No data"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final id = sortedKeys[index];
        final data = stats[id]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: ListTile(
              title: Text(
                data['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${data['count']} services • Last: ${_formatDateSafe(data['lastDate']?.toString() ?? '', pattern: 'dd MMM')}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(data['cost'] as double).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'Total Cost',
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

  Widget _buildTypeTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final stats = _calculateTypeStats();
    final sortedKeys = stats.keys.toList()
      ..sort(
        (a, b) => (stats[b]!['cost'] as double).compareTo(
          stats[a]!['cost'] as double,
        ),
      );

    if (sortedKeys.isEmpty) return const Center(child: Text("No data"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final type = sortedKeys[index];
        final data = stats[type]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  type[0],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              title: Text(
                type,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${data['count']} occurrences',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              trailing: Text(
                '₹${(data['cost'] as double).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
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

  @override
  bool get hasExportData => _logs.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    switch (_tabController.index) {
      case 0:
        return ['Date', 'Vehicle', 'Type', 'Vendor', 'Cost (₹)', 'Description'];
      case 1:
        return ['Vehicle', 'Services', 'Last Service', 'Total Cost (₹)'];
      case 2:
        return ['Type', 'Occurrences', 'Total Cost (₹)'];
      default:
        return [];
    }
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    switch (_tabController.index) {
      case 0:
        return _logs
            .map(
              (log) => [
                _formatDateSafe(log.serviceDate),
                log.vehicleNumber,
                log.type,
                log.vendor,
                log.totalCost.toStringAsFixed(0),
                log.description,
              ],
            )
            .toList();
      case 1:
        final stats = _calculateVehicleStats();
        final sortedKeys = stats.keys.toList()
          ..sort(
            (a, b) => (stats[b]!['cost'] as double).compareTo(
              stats[a]!['cost'] as double,
            ),
          );
        return sortedKeys.map((id) {
          final data = stats[id]!;
          return [
            data['name'],
            data['count'].toString(),
            _formatDateSafe(data['lastDate']?.toString() ?? ''),
            (data['cost'] as double).toStringAsFixed(0),
          ];
        }).toList();
      case 2:
        final stats = _calculateTypeStats();
        final sortedKeys = stats.keys.toList()
          ..sort(
            (a, b) => (stats[b]!['cost'] as double).compareTo(
              stats[a]!['cost'] as double,
            ),
          );
        return sortedKeys.map((type) {
          final data = stats[type]!;
          return [
            type,
            data['count'].toString(),
            (data['cost'] as double).toStringAsFixed(0),
          ];
        }).toList();
      default:
        return [];
    }
  }

  @override
  Map<String, String> buildFilterSummary() {
    String tabName = ['Overview', 'By Vehicle', 'Types'][_tabController.index];
    final vList = _vehicles.where((v) => v.id == _selectedVehicleId).toList();
    final selectedVehicle = _selectedVehicleId == 'all'
        ? 'All Vehicles'
        : (vList.isNotEmpty ? vList.first.number : 'Unknown');

    return {
      'Date Range':
          '${DateFormat('dd-MMM-yyyy').format(_dateRange.start)} - ${DateFormat('dd-MMM-yyyy').format(_dateRange.end)}',
      'Vehicle': selectedVehicle,
      'Active Tab': tabName,
      'Total Services': _totalServices.toString(),
      'Vehicles Serviced': _vehiclesServiced.toString(),
      'Total Cost': '₹${_totalCost.toStringAsFixed(0)}',
    };
  }
}
