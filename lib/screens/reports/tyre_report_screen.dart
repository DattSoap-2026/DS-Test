import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/ui/custom_card.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class TyreReportScreen extends StatefulWidget {
  const TyreReportScreen({super.key});

  @override
  State<TyreReportScreen> createState() => _TyreReportScreenState();
}

class _TyreReportScreenState extends State<TyreReportScreen>
    with ReportPdfMixin<TyreReportScreen> {
  late VehiclesService _vehiclesService;

  bool _isLoading = true;
  bool _loadingVehicles = true;

  // Data
  List<TyreLog> _logs = [];
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
    _loadVehicles();
    _loadReport();
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
      final results = await _vehiclesService.getTyreLogs(
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

  double get _totalCost => _logs.fold(0.0, (sum, log) => sum + log.totalCost);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tyre Log Report'),
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Tyre Log Report'),
            onPrint: () => printReport('Tyre Log Report'),
            onRefresh: _loadReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Cost",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${_totalCost.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      "${_logs.length} logs found",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Filtered Results",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLogList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 700;

                final dateRangeFilter = InkWell(
                  onTap: _selectDateRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date Range',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      "${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM').format(_dateRange.end)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );

                final vehicleFilter = DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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
      ),
    );
  }

  Widget _buildLogList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_logs.isEmpty) return const Center(child: Text("No logs found"));

    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final log = _logs[index];
        return CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateSafe(log.installationDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${log.totalCost.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Vehicle: ${log.vehicleNumber}'),
                Text('Items Changed: ${log.items.length}'),
                const Divider(),
                Wrap(
                  spacing: 4,
                  children: log.items
                      .map(
                        (item) => Chip(
                          label: Text('${item.brand} (${item.position})'),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                      )
                      .toList(),
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

  @override
  bool get hasExportData => _logs.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return ['Date', 'Vehicle', 'Cost (₹)', 'Items Changed'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _logs
        .map(
          (log) => [
            _formatDateSafe(log.installationDate),
            log.vehicleNumber,
            log.totalCost.toStringAsFixed(0),
            log.items.map((i) => '${i.brand} (${i.position})').join(', '),
          ],
        )
        .toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    final vList = _vehicles.where((v) => v.id == _selectedVehicleId).toList();
    final selectedVehicle = _selectedVehicleId == 'all'
        ? 'All Vehicles'
        : (vList.isNotEmpty ? vList.first.number : 'Unknown');

    return {
      'Date Range':
          '${DateFormat('dd-MMM-yyyy').format(_dateRange.start)} - ${DateFormat('dd-MMM-yyyy').format(_dateRange.end)}',
      'Vehicle': selectedVehicle,
      'Total Cost': '₹${_totalCost.toStringAsFixed(0)}',
      'Total Logs': _logs.length.toString(),
    };
  }
}
