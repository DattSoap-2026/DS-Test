import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/reports/vehicle_expiry_report_models.dart';
import '../../services/reports/vehicle_expiry_report_service.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';

class VehicleExpiryReportScreen extends StatefulWidget {
  const VehicleExpiryReportScreen({super.key});

  @override
  State<VehicleExpiryReportScreen> createState() =>
      _VehicleExpiryReportScreenState();
}

class _VehicleExpiryReportScreenState extends State<VehicleExpiryReportScreen>
    with ReportPdfMixin<VehicleExpiryReportScreen> {
  late final VehiclesService _vehiclesService;
  late final VehicleExpiryReportService _reportService;

  bool _isLoading = true;
  List<Vehicle> _vehicles = [];
  VehicleExpiryReportData? _reportData;

  VehicleDocumentType? _selectedDocument;
  VehicleExpiryStatus? _selectedStatus;
  String _selectedVehicleId = 'all';
  bool _includeNoData = true;
  DateTime _asOfDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _reportService = VehicleExpiryReportService(_vehiclesService);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final vehicles = await _vehiclesService.getVehicles();
      final report = _reportService.buildFromVehicles(
        vehicles,
        query: _currentQuery(),
      );

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
        const SnackBar(content: Text('Failed to load vehicle expiry report')),
      );
    }
  }

  VehicleExpiryReportQuery _currentQuery() {
    return VehicleExpiryReportQuery(
      documentType: _selectedDocument,
      status: _selectedStatus,
      vehicleId: _selectedVehicleId == 'all' ? null : _selectedVehicleId,
      includeNoData: _includeNoData,
      asOfDate: _asOfDate,
    );
  }

  void _applyFilters() {
    setState(() {
      _reportData = _reportService.buildFromVehicles(
        _vehicles,
        query: _currentQuery(),
      );
    });
  }

  Future<void> _pickAsOfDate() async {
    final picked = await ResponsiveDatePickers.pickDate(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _asOfDate,
    );

    if (picked != null) {
      setState(() => _asOfDate = picked);
      _applyFilters();
    }
  }

  Color _statusColor(VehicleExpiryStatus status) {
    switch (status) {
      case VehicleExpiryStatus.expired:
        return Colors.red;
      case VehicleExpiryStatus.critical:
        return Colors.deepOrange;
      case VehicleExpiryStatus.upcoming:
        return Colors.amber.shade700;
      case VehicleExpiryStatus.ok:
        return Colors.green;
      case VehicleExpiryStatus.noData:
        return Colors.blueGrey;
    }
  }

  String _expiryText(VehicleExpiryReportRow row) {
    if (row.expiryDate == null) return 'Not set';
    return DateFormat('dd MMM yyyy').format(row.expiryDate!.toLocal());
  }

  String _daysText(VehicleExpiryReportRow row) {
    final days = row.daysRemaining;
    if (days == null) return 'No date';
    if (days < 0) return '${days.abs()} days overdue';
    if (days == 0) return 'Due today';
    return '$days days left';
  }

  @override
  Widget build(BuildContext context) {
    final report = _reportData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Expiry Report'),
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Vehicle Expiry Report'),
            onPrint: () => printReport('Vehicle Expiry Report'),
            onRefresh: _loadInitialData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltersCard(),
                if (report != null) _buildStatusSummary(report),
                Expanded(
                  child: report == null || report.rows.isEmpty
                      ? const Center(child: Text('No report rows found'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: report.rows.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final row = report.rows[index];
                            final statusColor = _statusColor(row.status);

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: statusColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  foregroundColor: statusColor,
                                  child: const Icon(
                                    Icons.assignment_late_outlined,
                                  ),
                                ),
                                title: Text(
                                  '${row.vehicleNumber} - ${row.documentType.label}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (row.vehicleName.trim().isNotEmpty)
                                      Text(row.vehicleName),
                                    Text('Expiry: ${_expiryText(row)}'),
                                    Text(_daysText(row)),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    row.status.label,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
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

  Widget _buildFiltersCard() {
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
                      _buildDocumentDropdown(isExpanded: true),
                      const SizedBox(height: 10),
                      _buildStatusDropdown(isExpanded: true),
                      const SizedBox(height: 10),
                      _buildVehicleDropdown(isExpanded: true),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _buildDocumentDropdown(isExpanded: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatusDropdown(isExpanded: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildVehicleDropdown(isExpanded: true)),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAsOfDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      'As of ${DateFormat('dd MMM yyyy').format(_asOfDate)}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SwitchListTile.adaptive(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include No Data'),
                    value: _includeNoData,
                    onChanged: (value) {
                      setState(() => _includeNoData = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentDropdown({required bool isExpanded}) {
    return DropdownButtonFormField<VehicleDocumentType?>(
      key: ValueKey<VehicleDocumentType?>(_selectedDocument),
      initialValue: _selectedDocument,
      isExpanded: isExpanded,
      decoration: const InputDecoration(
        labelText: 'Document',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<VehicleDocumentType?>(
          value: null,
          child: Text('All Documents'),
        ),
        ...VehicleDocumentType.values.map(
          (doc) => DropdownMenuItem<VehicleDocumentType?>(
            value: doc,
            child: Text(doc.label),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedDocument = value);
        _applyFilters();
      },
    );
  }

  Widget _buildStatusDropdown({required bool isExpanded}) {
    return DropdownButtonFormField<VehicleExpiryStatus?>(
      key: ValueKey<VehicleExpiryStatus?>(_selectedStatus),
      initialValue: _selectedStatus,
      isExpanded: isExpanded,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<VehicleExpiryStatus?>(
          value: null,
          child: Text('All Status'),
        ),
        ...VehicleExpiryStatus.values.map(
          (status) => DropdownMenuItem<VehicleExpiryStatus?>(
            value: status,
            child: Text(status.label),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedStatus = value);
        _applyFilters();
      },
    );
  }

  Widget _buildVehicleDropdown({required bool isExpanded}) {
    return DropdownButtonFormField<String>(
      key: ValueKey<String>(_selectedVehicleId),
      initialValue: _selectedVehicleId,
      isExpanded: isExpanded,
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

  Widget _buildStatusSummary(VehicleExpiryReportData report) {
    final counts = report.statusCounts;
    final statusOrder = [
      VehicleExpiryStatus.expired,
      VehicleExpiryStatus.critical,
      VehicleExpiryStatus.upcoming,
      VehicleExpiryStatus.ok,
      VehicleExpiryStatus.noData,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Chip(
            label: Text('Rows: ${report.totalRows}'),
            avatar: const Icon(Icons.list, size: 16),
          ),
          ...statusOrder.map((status) {
            final color = _statusColor(status);
            return Chip(
              avatar: Icon(Icons.circle, size: 12, color: color),
              label: Text('${status.label}: ${counts[status] ?? 0}'),
            );
          }),
        ],
      ),
    );
  }

  @override
  bool get hasExportData => _reportData != null && _reportData!.rows.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return ['Vehicle', 'Name', 'Document', 'Expiry Date', 'Status', 'Days'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    if (_reportData == null) return [];
    return _reportData!.rows
        .map(
          (row) => [
            row.vehicleNumber,
            row.vehicleName,
            row.documentType.label,
            _expiryText(row),
            row.status.label,
            _daysText(row),
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
      'As Of Date': DateFormat('dd-MMM-yyyy').format(_asOfDate),
      'Vehicle': selectedVehicle,
      'Document Type': _selectedDocument?.label ?? 'All',
      'Status': _selectedStatus?.label ?? 'All',
      'Include No Data': _includeNoData ? 'Yes' : 'No',
      if (report != null) 'Total Rows': report.totalRows.toString(),
    };
  }
}
