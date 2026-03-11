import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/reports/vehicle_yearly_detailed_report_models.dart';
import '../../services/reports/vehicle_yearly_detailed_report_service.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class VehicleYearlyDetailedReportScreen extends StatefulWidget {
  const VehicleYearlyDetailedReportScreen({super.key});

  @override
  State<VehicleYearlyDetailedReportScreen> createState() =>
      _VehicleYearlyDetailedReportScreenState();
}

class _VehicleYearlyDetailedReportScreenState
    extends State<VehicleYearlyDetailedReportScreen>
    with ReportPdfMixin<VehicleYearlyDetailedReportScreen> {
  late final VehiclesService _vehiclesService;
  late final VehicleYearlyDetailedReportService _reportService;

  bool _isLoading = true;
  List<Vehicle> _vehicles = [];
  VehicleYearlyDetailedReportData? _reportData;

  late int _selectedYear;
  String _selectedVehicleId = 'all';
  bool _showZeroMonths = true;

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _reportService = VehicleYearlyDetailedReportService(_vehiclesService);
    _selectedYear = DateTime.now().year;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final vehicles = await _vehiclesService.getVehicles();
      final report = await _reportService.getReport(query: _currentQuery());

      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _reportData = report;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load yearly detailed report')),
      );
    }
  }

  VehicleYearlyDetailedReportQuery _currentQuery() {
    return VehicleYearlyDetailedReportQuery(
      year: _selectedYear,
      vehicleId: _selectedVehicleId == 'all' ? null : _selectedVehicleId,
    );
  }

  Future<void> _applyFilters() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final report = await _reportService.getReport(query: _currentQuery());
      if (!mounted) return;
      setState(() {
        _reportData = report;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply report filters')),
      );
    }
  }

  String _monthLabel(int month) {
    return DateFormat('MMM').format(DateTime(2000, month, 1));
  }

  @override
  Widget build(BuildContext context) {
    final report = _reportData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Yearly Details'),
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Vehicle Yearly Detailed Report'),
            onPrint: () => printReport('Vehicle Yearly Detailed Report'),
            onRefresh: _loadInitialData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterCard(),
                if (report != null) _buildSummaryCard(report.summary),
                Expanded(
                  child: report == null || report.vehicles.isEmpty
                      ? const Center(child: Text('No yearly detail data found'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: report.vehicles.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final detail = report.vehicles[index];
                            return _buildVehicleCard(detail);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterCard() {
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(7, (index) => currentYear - 3 + index);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;

                if (compact) {
                  return Column(
                    children: [
                      _buildYearDropdown(years),
                      const SizedBox(height: 10),
                      _buildVehicleDropdown(),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _buildYearDropdown(years)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildVehicleDropdown()),
                  ],
                );
              },
            ),
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Zero Months'),
              value: _showZeroMonths,
              onChanged: (value) {
                setState(() => _showZeroMonths = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown(List<int> years) {
    return DropdownButtonFormField<int>(
      key: ValueKey<int>(_selectedYear),
      initialValue: _selectedYear,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: years
          .map(
            (year) => DropdownMenuItem<int>(value: year, child: Text('$year')),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedYear = value);
        _applyFilters();
      },
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButtonFormField<String>(
      key: ValueKey<String>(_selectedVehicleId),
      initialValue: _selectedVehicleId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Vehicle',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: 'all', child: Text('All Vehicles')),
        ..._vehicles.map(
          (vehicle) => DropdownMenuItem(
            value: vehicle.id,
            child: Text(vehicle.number, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedVehicleId = value);
        _applyFilters();
      },
    );
  }

  Widget _buildSummaryCard(VehicleYearlyDetailedSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(label: Text('Vehicles: ${summary.vehicleCount}')),
              Chip(
                label: Text('Total: ${_currency.format(summary.totalCost)}'),
              ),
              Chip(
                label: Text(
                  'Maintenance: ${_currency.format(summary.maintenanceCost)} (${summary.maintenanceEntries})',
                ),
              ),
              Chip(
                label: Text(
                  'Tyre: ${_currency.format(summary.tyreCost)} (${summary.tyreEntries} logs)',
                ),
              ),
              Chip(label: Text('Tyres Replaced: ${summary.tyreReplacements}')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleYearlyVehicleDetail detail) {
    final monthRows = _showZeroMonths
        ? detail.months
        : detail.months
              .where(
                (month) =>
                    month.totalCost > 0 ||
                    month.maintenanceEntries > 0 ||
                    month.tyreEntries > 0 ||
                    month.tyreReplacements > 0,
              )
              .toList();

    return Card(
      child: ExpansionTile(
        title: Text(
          detail.vehicleNumber,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail.vehicleName.trim().isNotEmpty) Text(detail.vehicleName),
            Text(
              'Total: ${_currency.format(detail.totalCost)} | Maint: ${_currency.format(detail.totalMaintenanceCost)} | Tyre: ${_currency.format(detail.totalTyreCost)}',
            ),
          ],
        ),
        children: [
          if (monthRows.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('No month data after filter'),
              ),
            )
          else
            ...monthRows.map(
              (month) => ListTile(
                dense: true,
                title: Text('${_monthLabel(month.month)} $_selectedYear'),
                subtitle: Text(
                  'Maintenance: ${_currency.format(month.maintenanceCost)} (${month.maintenanceEntries}), '
                  'Tyre: ${_currency.format(month.tyreCost)} (${month.tyreEntries}), '
                  'Tyres Replaced: ${month.tyreReplacements}',
                ),
                trailing: Text(
                  _currency.format(month.totalCost),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get hasExportData =>
      _reportData != null && _reportData!.vehicles.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Vehicle',
      'Month',
      'Maintenance',
      'Tyre',
      'Tyres Replaced',
      'Total',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    final report = _reportData;
    if (report == null) return [];

    final rows = <List<dynamic>>[];
    for (final vehicle in report.vehicles) {
      final monthRows = _showZeroMonths
          ? vehicle.months
          : vehicle.months
                .where(
                  (month) =>
                      month.totalCost > 0 ||
                      month.maintenanceEntries > 0 ||
                      month.tyreEntries > 0 ||
                      month.tyreReplacements > 0,
                )
                .toList();

      if (monthRows.isEmpty) {
        rows.add([
          vehicle.vehicleNumber,
          '-',
          _currency.format(0),
          _currency.format(0),
          '0',
          _currency.format(0),
        ]);
        continue;
      }

      for (final month in monthRows) {
        rows.add([
          vehicle.vehicleNumber,
          '${_monthLabel(month.month)} $_selectedYear',
          _currency.format(month.maintenanceCost),
          _currency.format(month.tyreCost),
          month.tyreReplacements.toString(),
          _currency.format(month.totalCost),
        ]);
      }
    }
    return rows;
  }

  @override
  Map<String, String> buildFilterSummary() {
    final report = _reportData;
    final vList = _vehicles.where((v) => v.id == _selectedVehicleId).toList();
    final selectedVehicle = _selectedVehicleId == 'all'
        ? 'All Vehicles'
        : (vList.isNotEmpty ? vList.first.number : 'Unknown');

    return {
      'Year': _selectedYear.toString(),
      'Vehicle': selectedVehicle,
      'Show Zero Months': _showZeroMonths ? 'Yes' : 'No',
      if (report != null)
        'Total Expense': _currency.format(report.summary.totalCost),
      if (report != null)
        'Vehicles Analyzed': report.vehicles.length.toString(),
    };
  }
}
