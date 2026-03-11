import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/vehicles_service.dart';
import '../../services/diesel_service.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/vehicles/expiry_alerts_widget.dart';
import '../../widgets/vehicles/offline_sync_indicator.dart';

import 'tabs/tyres_tab.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import 'tabs/vehicle_issues_tab.dart'; // Added
import 'dialogs/vehicle_issue_dialog.dart'; // Added
import 'dialogs/bulk_operations_dialog.dart';
import '../reports/vehicle_expiry_report_screen.dart';
import '../reports/vehicle_monthly_expense_report_screen.dart';
import '../reports/vehicle_yearly_detailed_report_screen.dart';
import 'vehicle_analytics_dashboard.dart';

class VehicleManagementScreen extends StatefulWidget {
  final int initialTabIndex;

  const VehicleManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen>
    with SingleTickerProviderStateMixin {
  late final VehiclesService _vehiclesService;
  late final DieselService _dieselService;
  late TabController _tabController;

  bool _isLoading = true;

  List<Vehicle> _vehicles = [];
  List<MaintenanceLog> _maintenanceLogs = [];
  List<DieselLog> _dieselLogs = [];
  Map<String, dynamic> _expiryAlerts = {'critical': [], 'warning': []};

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'Rs ',
    decimalDigits: 0,
  );

  // Fleet Tab Filters
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All Status';
  String _typeFilter = 'All Types';
  String _sortBy = 'Recent';

  // Service Tab Filters
  String? _selectedVehicleFilter;
  DateTimeRange? _selectedDateRange;
  String? _selectedServiceTypeFilter;

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _dieselService = context.read<DieselService>();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadAllData();
  }

  @override
  void didUpdateWidget(VehicleManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
      return;
    }
    context.go('/dashboard');
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final vehiclesFuture = _vehiclesService.getVehicles();
      final maintenanceFuture = _vehiclesService.getMaintenanceLogs();
      final dieselFuture = _dieselService.getDieselLogs();
      final alertsFuture = _vehiclesService.getExpiryAlerts();

      final results = await Future.wait([
        vehiclesFuture,
        maintenanceFuture,
        dieselFuture,
        alertsFuture,
      ]);

      final vehicles = results[0] as List<Vehicle>;
      final maintenanceLogs = results[1] as List<MaintenanceLog>;
      final dieselLogs = results[2] as List<DieselLog>;
      final alerts = results[3] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _maintenanceLogs = maintenanceLogs;
          _dieselLogs = dieselLogs;
          _expiryAlerts = alerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silent error for dashboard loads to avoid popup spam, check logs
        debugPrint('Error loading vehicle data: $e');
      }
    }
  }

  Future<void> _deleteMaintenanceLog(MaintenanceLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Log'),
        content: Text(
          'Are you sure you want to delete the maintenance log for ${log.vehicleNumber} on ${log.serviceDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _vehiclesService.deleteMaintenanceLog(
          log.id,
          log.vehicleId,
          log.totalCost,
        );
        _loadAllData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Log deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;
    final theme = Theme.of(context);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }

    if (user.role != UserRole.admin && user.role != UserRole.storeIncharge) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You do not have access to this module',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Contact your administrator for access',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      animationDuration: const Duration(milliseconds: 200),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Reports'),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
            tooltip: 'Back',
          ),
        ),
        body: Column(
          children: [
            const OfflineSyncIndicator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ThemedTabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                      onTap: (_) => setState(() {}),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      tabs: const [
                        Tab(text: 'All Vehicles'),
                        Tab(text: 'Maintenance Logs'),
                        Tab(text: 'Diesel Logs'),
                        Tab(text: 'Tyre Logs'),
                        Tab(text: 'Reported Issues'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined),
                    tooltip: 'Analytics Dashboard',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehicleAnalyticsDashboard(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.assessment_outlined),
                    tooltip: 'Expiry Report',
                    onPressed: _openVehicleExpiryReport,
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt_long_outlined),
                    tooltip: 'Monthly Expense Report',
                    onPressed: _openVehicleMonthlyExpenseReport,
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined),
                    tooltip: 'Yearly Detailed Report',
                    onPressed: _openVehicleYearlyDetailedReport,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'More Options',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => BulkOperationsDialog(vehicles: _vehicles),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadAllData,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildVehiclesTableTab(),
                        _buildMaintenanceView(),
                        _buildDieselLogsView(),
                        const TyresTab(),
                        _buildIssuesView(),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'vehicle_fab',
          onPressed: _handleFabPress,
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
          label: Text(
            _getFabLabel(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getFabLabel() {
    switch (_tabController.index) {
      case 0:
        return 'Add Vehicle';
      case 1:
        return 'Add Service';
      case 2:
        return 'Fuel Entry';
      case 3:
        return 'Add Tyre';
      case 4:
        return 'Report Issue';
      default:
        return 'Add';
    }
  }

  void _handleFabPress() async {
    bool? refresh;
    switch (_tabController.index) {
      case 0: // All Vehicles
        refresh = await context.push('/dashboard/vehicles/add');
        break;
      case 1: // Maintenance Logs
        refresh = await context.push('/dashboard/vehicles/maintenance/add');
        break;
      case 2: // Diesel Logs
        refresh = await context.push('/dashboard/vehicles/diesel/add');
        break;
      case 3: // Tyre Logs
        refresh = await context.push('/dashboard/vehicles/tyres/add');
        break;
      case 4: // Reported Issues
        refresh = await showDialog<bool>(
          context: context,
          builder: (context) => const VehicleIssueReportDialog(),
        );
        break;
    }
    if (refresh == true) {
      _loadAllData();
    }
  }

  Future<void> _openVehicleExpiryReport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VehicleExpiryReportScreen(),
      ),
    );
  }

  Future<void> _openVehicleMonthlyExpenseReport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VehicleMonthlyExpenseReportScreen(),
      ),
    );
  }

  Future<void> _openVehicleYearlyDetailedReport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VehicleYearlyDetailedReportScreen(),
      ),
    );
  }

  Widget _buildVehiclesTableTab() {
    final query = _searchController.text.toLowerCase();
    var filteredVehicles = _vehicles.where((v) {
      final matchesQuery =
          query.isEmpty ||
          v.number.toLowerCase().contains(query) ||
          v.name.toLowerCase().contains(query) ||
          (v.model?.toLowerCase().contains(query) ?? false);

      final matchesStatus =
          _statusFilter == 'All Status' ||
          (_statusFilter == 'Active' && v.status == 'active') ||
          (_statusFilter == 'Inactive' && v.status == 'inactive') ||
          (_statusFilter == 'Under Maintenance' &&
              v.status == 'under_maintenance');

      final matchesType =
          _typeFilter == 'All Types' || v.type == _typeFilter;

      return matchesQuery && matchesStatus && matchesType;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'Recent':
        filteredVehicles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Name':
        filteredVehicles.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Number':
        filteredVehicles.sort((a, b) => a.number.compareTo(b.number));
        break;
      case 'Cost':
        filteredVehicles.sort((a, b) => b.costPerKm.compareTo(a.costPerKm));
        break;
    }

    return Column(
      children: [
        ExpiryAlertsWidget(
          alerts: _expiryAlerts,
          onViewAll: _openVehicleExpiryReport,
        ),
        _buildFleetSearch(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAllData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    _buildTableHeader(),
                    const Divider(height: 1),
                    if (filteredVehicles.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No vehicles found',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    else
                      ...filteredVehicles.map((v) => _buildVehicleTableRow(v)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFleetSearch() {
    final vehicleTypes = ['All Types', ...{'Truck', 'Tanker', 'Tempo', 'Lorry', 'Car', 'Other'}];
    final sortOptions = ['Recent', 'Name', 'Number', 'Cost'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search vehicles...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    items: ['All Status', 'Active', 'Inactive', 'Under Maintenance']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, style: const TextStyle(fontSize: 13)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _statusFilter = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _typeFilter,
                      items: vehicleTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _typeFilter = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      items: sortOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text('Sort: $s', style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _sortBy = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Vehicle Number',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Model',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Current Status',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Action',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTableRow(Vehicle vehicle) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push(
        '/dashboard/vehicles/detail/${vehicle.id}',
        extra: vehicle,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (vehicle.name.isNotEmpty)
                    Text(
                      vehicle.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                vehicle.model?.isNotEmpty == true ? vehicle.model! : 'N/A',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusBadge(vehicle.status),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    String statusText;
    final theme = Theme.of(context);

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = AppColors.success;
        statusText = 'Active';
        break;
      case 'maintenance':
      case 'under_maintenance':
        statusColor = AppColors.warning;
        statusText = 'Maintenance';
        break;
      case 'inactive':
        statusColor = theme.colorScheme.outline;
        statusText = 'Inactive';
        break;
      default:
        statusColor = AppColors.info;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMaintenanceView() {
    final theme = Theme.of(context);
    final effectiveRange =
        _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
    // Filter logic
    final filteredLogs = _maintenanceLogs.where((log) {
      if (_selectedVehicleFilter != null &&
          log.vehicleId != _selectedVehicleFilter) {
        return false;
      }
      if (_selectedServiceTypeFilter != null &&
          log.type != _selectedServiceTypeFilter) {
        return false;
      }
      if (_selectedDateRange != null) {
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end.add(const Duration(days: 1));
        final logDate = DateTime.tryParse(log.serviceDate);
        if (logDate == null ||
            logDate.isBefore(start) ||
            logDate.isAfter(end)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Get unique service types for filter
    final serviceTypes = _maintenanceLogs.map((e) => e.type).toSet().toList();
    serviceTypes.sort();

    return Column(
      children: [
        // Filters Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Vehicle Filter
                    _buildFilterDropdown(
                      hint: 'All Vehicles',
                      value: _selectedVehicleFilter,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Vehicles'),
                        ),
                        ..._vehicles.map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(
                              v.number,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedVehicleFilter = val;
                        });
                      },
                    ),
                    const SizedBox(width: 12),

                    // Date Range Filter
                    OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _selectedDateRange == null
                            ? 'All Dates'
                            : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Type Filter
                    if (serviceTypes.isNotEmpty) ...[
                      _buildFilterDropdown(
                        hint: 'Service Type',
                        value: _selectedServiceTypeFilter,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...serviceTypes.map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedServiceTypeFilter = val;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Clear Filters
                    if (_selectedVehicleFilter != null ||
                        _selectedDateRange != null ||
                        _selectedServiceTypeFilter != null)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: 'Clear Filters',
                        onPressed: () {
                          setState(() {
                            _selectedVehicleFilter = null;
                            _selectedDateRange = null;
                            _selectedServiceTypeFilter = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
              ReportDateRangeButtons(
                value: effectiveRange,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onChanged: (range) {
                  setState(() {
                    _selectedDateRange = range;
                  });
                },
              ),
            ],
          ),
        ),

        // Logs List
        Expanded(
          child: filteredLogs.isEmpty
              ? _buildEmptyState('No service logs found matching filters')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(filteredLogs[index]);
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await ResponsiveDatePickers.pickDateRange(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          items: items,
          onChanged: onChanged,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildServiceCard(MaintenanceLog log) {
    final dateText = _formatDateSafe(
      log.serviceDate,
      pattern: 'EEE, MMM d, yyyy',
    );

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showMaintenanceDetails(log),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            log.vehicleNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (log.type == 'Breakdown')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BREAKDOWN',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 20),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (val) async {
                              if (val == 'view') _showMaintenanceDetails(log);
                              if (val == 'edit') {
                                final refresh = await context.push(
                                  '/dashboard/vehicles/maintenance/edit',
                                  extra: log,
                                );
                                if (refresh == true) {
                                  _loadAllData();
                                }
                              }
                              if (val == 'delete') _deleteMaintenanceLog(log);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        log.type,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  if (log.odometerReading != null) ...[
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.speed, size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          '${log.odometerReading} km',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: AppColors.success,
                      ),
                      Text(
                        _currencyFormat.format(log.totalCost),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (log.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                log.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            if (log.items.isNotEmpty || log.partsReplaced != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.list,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${log.items.length} tasks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (log.partsReplaced != null &&
                      log.partsReplaced!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.settings_outlined,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${log.partsReplaced!.length} parts',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMaintenanceDetails(MaintenanceLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Details: ${log.vehicleNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailItem('Date', _formatDateSafe(log.serviceDate)),
                  _buildDetailItem('Vendor', log.vendor),
                  _buildDetailItem('Type', log.type),
                  if (log.nextServiceDate != null)
                    _buildDetailItem(
                      'Next Service',
                      _formatDateSafe(log.nextServiceDate!),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Parts & Services',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (log.items.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No itemized parts recorded'),
                      ),
                    )
                  else
                    ...log.items.map(
                      (item) => ListTile(
                        dense: true,
                        title: Text(item.partName),
                        subtitle: Text(
                          'Qty: ${item.quantity.toStringAsFixed(0)} x ${_currencyFormat.format(item.price)}',
                        ),
                        trailing: Text(
                          _currencyFormat.format(item.quantity * item.price),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(log.totalCost),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDieselLogsView() {
    if (_dieselLogs.isEmpty) return _buildEmptyState('No diesel logs');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dieselLogs.length,
      itemBuilder: (context, index) {
        final log = _dieselLogs[index];
        final bool isLow = log.status == 'LOW_AVERAGE';
        final bool isGood = log.status == 'GOOD_AVERAGE';

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isLow
                  ? AppColors.errorBg
                  : (isGood ? AppColors.successBg : AppColors.infoBg),
              child: Icon(
                Icons.local_gas_station,
                color: isLow
                    ? AppColors.error
                    : (isGood ? AppColors.success : AppColors.info),
              ),
            ),
            title: Text(
              log.vehicleNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${log.liters.toStringAsFixed(1)} L | ${_currencyFormat.format(log.totalCost)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatDateSafe(log.fillDate, pattern: 'dd MMM')),
                if (log.cycleEfficiency != null)
                  Text(
                    '${log.cycleEfficiency!.toStringAsFixed(1)} kmpl',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isLow ? AppColors.error : AppColors.success,
                    ),
                  ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Driver', log.driverName),
                    _buildDetailRow(
                      'Odometer',
                      '${log.odometerReading.toStringAsFixed(0)} km',
                    ),
                    if (log.cycleDistance != null)
                      _buildDetailRow(
                        'Distance Covered',
                        '${log.cycleDistance!.toStringAsFixed(0)} km',
                      ),
                    if (log.penaltyAmount != null && log.penaltyAmount! > 0)
                      _buildDetailRow(
                        'Fuel Penalty',
                        'Rs ${log.penaltyAmount!.toStringAsFixed(0)}',
                        color: AppColors.error,
                      ),
                    if (log.journeyFrom != null)
                      _buildDetailRow(
                        'Route',
                        '${log.journeyFrom} -> ${log.journeyTo}',
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesView() {
    return const VehicleIssuesTab();
  }
}
