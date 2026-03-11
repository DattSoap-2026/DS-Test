import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reports_service.dart';
import '../../utils/app_toast.dart';
import 'package:intl/intl.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class FleetPerformanceReportScreen extends StatefulWidget {
  const FleetPerformanceReportScreen({super.key});

  @override
  State<FleetPerformanceReportScreen> createState() =>
      _FleetPerformanceReportScreenState();
}

class _FleetPerformanceReportScreenState
    extends State<FleetPerformanceReportScreen>
    with ReportPdfMixin {
  late final ReportsService _reportsService;
  bool _isLoading = true;
  List<VehiclePerformanceData> _reportData = [];

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final filters = FilterOptions(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      );
      final result = await _reportsService.getVehiclePerformanceReport(filters);
      if (mounted) {
        setState(() {
          _reportData = result;
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

  @override
  bool get hasExportData => _reportData.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Vehicle No',
      'Name',
      'Distance (KM)',
      'Efficiency (Kmpl)',
      'Cost/KM (Rs)',
      'Diesel (Rs)',
      'Maint (Rs)',
      'Tyres (Rs)',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _reportData
        .map(
          (data) => [
            data.number,
            data.name,
            data.totalDistance.toStringAsFixed(0),
            data.actualAverage.toStringAsFixed(2),
            data.costPerKm.toStringAsFixed(2),
            data.totalDieselCost.toStringAsFixed(0),
            data.totalMaintenanceCost.toStringAsFixed(0),
            data.totalTyreCost.toStringAsFixed(0),
          ],
        )
        .toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    final df = DateFormat('dd MMM yyyy');
    return {
      'Date Range':
          '${df.format(_dateRange.start)} - ${df.format(_dateRange.end)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Performance'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Fleet Performance Report'),
            onPrint: () => printReport('Fleet Performance Report'),
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final picked = await ResponsiveDatePickers.pickDateRange(
                context: context,
                initialDateRange: _dateRange,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
                _loadReport();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ReportDateRangeButtons(
                    value: _dateRange,
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                    onChanged: (range) {
                      setState(() => _dateRange = range);
                      _loadReport();
                    },
                  ),
                ),
                Expanded(
                  child: _reportData.isEmpty
                      ? const Center(
                          child: Text('No data found for the selected period'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reportData.length,
                          itemBuilder: (context, index) {
                            return _buildVehicleCard(_reportData[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildVehicleCard(VehiclePerformanceData data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.local_shipping)),
            title: Text(
              data.number,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(data.name),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${data.totalDistance.toStringAsFixed(0)} KM',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text('Distance', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricItem(
                      'Efficiency',
                      '${data.actualAverage.toStringAsFixed(2)} Kmpl',
                      _getEfficiencyColor(data),
                    ),
                    _metricItem(
                      'Cost/KM',
                      '₹${data.costPerKm.toStringAsFixed(2)}',
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _costItem(
                      'Diesel',
                      data.totalDieselCost,
                      AppColors.warning,
                    ),
                    _costItem(
                      'Maintenance',
                      data.totalMaintenanceCost,
                      AppColors.error,
                    ),
                    _costItem('Tyres', data.totalTyreCost, AppColors.info),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _costItem(String label, double amount, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getEfficiencyColor(VehiclePerformanceData data) {
    final colorScheme = Theme.of(context).colorScheme;
    if (data.actualAverage <= 0) return colorScheme.onSurfaceVariant;
    if (data.actualAverage < data.minAverage) return AppColors.error;
    if (data.actualAverage > data.maxAverage) return AppColors.success;
    return AppColors.info;
  }
}
