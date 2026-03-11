import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/reports/vehicle_monthly_expense_report_models.dart';
import '../../services/reports/vehicle_monthly_expense_report_service.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class VehicleMonthlyExpenseReportScreen extends StatefulWidget {
  const VehicleMonthlyExpenseReportScreen({super.key});

  @override
  State<VehicleMonthlyExpenseReportScreen> createState() =>
      _VehicleMonthlyExpenseReportScreenState();
}

class _VehicleMonthlyExpenseReportScreenState
    extends State<VehicleMonthlyExpenseReportScreen>
    with ReportPdfMixin<VehicleMonthlyExpenseReportScreen> {
  late final VehiclesService _vehiclesService;
  late final VehicleMonthlyExpenseReportService _reportService;

  bool _isLoading = true;
  List<Vehicle> _vehicles = [];
  VehicleMonthlyExpenseReportData? _reportData;

  late int _selectedYear;
  int? _selectedMonth;
  String _selectedVehicleId = 'all';

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _reportService = VehicleMonthlyExpenseReportService(_vehiclesService);
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
        const SnackBar(content: Text('Failed to load monthly expense report')),
      );
    }
  }

  VehicleMonthlyExpenseReportQuery _currentQuery() {
    return VehicleMonthlyExpenseReportQuery(
      year: _selectedYear,
      month: _selectedMonth,
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
    return DateFormat('MMMM').format(DateTime(2000, month, 1));
  }

  String _rowPeriodLabel(VehicleMonthlyExpenseRow row) {
    return '${_monthLabel(row.month)} ${row.year}';
  }

  @override
  Widget build(BuildContext context) {
    final report = _reportData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Monthly Expense'),
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Vehicle Monthly Expense Report'),
            onPrint: () => printReport('Vehicle Monthly Expense Report'),
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
                  child: report == null || report.rows.isEmpty
                      ? const Center(
                          child: Text('No monthly expense data found'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: report.rows.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final row = report.rows[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                ),
                                title: Text(
                                  '${row.vehicleNumber} - ${_rowPeriodLabel(row)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (row.vehicleName.trim().isNotEmpty)
                                      Text(row.vehicleName),
                                    Text(
                                      'Maintenance: ${_currency.format(row.maintenanceCost)} (${row.maintenanceEntries} entries)',
                                    ),
                                    Text(
                                      'Tyre: ${_currency.format(row.tyreCost)} (${row.tyreEntries} logs, ${row.tyreReplacements} replaced)',
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  _currency.format(row.totalCost),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
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
                      _buildMonthDropdown(),
                      const SizedBox(height: 10),
                      _buildVehicleDropdown(),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _buildYearDropdown(years)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMonthDropdown()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildVehicleDropdown()),
                  ],
                );
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

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int?>(
      key: ValueKey<int?>(_selectedMonth),
      initialValue: _selectedMonth,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('All Months')),
        ...List.generate(
          12,
          (index) => DropdownMenuItem<int?>(
            value: index + 1,
            child: Text(_monthLabel(index + 1)),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedMonth = value);
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

  Widget _buildSummaryCard(VehicleMonthlyExpenseSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
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

  @override
  bool get hasExportData => _reportData != null && _reportData!.rows.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Period',
      'Vehicle',
      'Name',
      'Maintenance',
      'Tyre',
      'Tyres Replaced',
      'Total',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    if (_reportData == null) return [];
    return _reportData!.rows
        .map(
          (row) => [
            _rowPeriodLabel(row),
            row.vehicleNumber,
            row.vehicleName,
            _currency.format(row.maintenanceCost),
            _currency.format(row.tyreCost),
            row.tyreReplacements.toString(),
            _currency.format(row.totalCost),
          ],
        )
        .toList();
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
      'Month': _selectedMonth != null
          ? _monthLabel(_selectedMonth!)
          : 'All Months',
      'Vehicle': selectedVehicle,
      if (report != null)
        'Total Expense': _currency.format(report.summary.totalCost),
    };
  }
}
