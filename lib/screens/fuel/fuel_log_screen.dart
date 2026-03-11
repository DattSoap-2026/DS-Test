import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/diesel_service.dart';
import '../../services/vehicles_service.dart';
import '../../services/users_service.dart';
import '../../services/settings_service.dart';
import '../../models/types/user_types.dart';
import '../../modules/hr/models/employee_model.dart';
import '../../modules/hr/services/hr_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class FuelLogScreen extends StatefulWidget {
  const FuelLogScreen({super.key});

  @override
  State<FuelLogScreen> createState() => _FuelLogScreenState();
}

class _FuelLogScreenState extends State<FuelLogScreen> {
  late final DieselService _dieselService;
  late final VehiclesService _vehiclesService;
  late final UsersService _usersService;
  late final SettingsService _settingsService;
  late final HrService _hrService;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  List<Vehicle> _vehicles = [];
  List<AppUser> _drivers = [];
  List<String> _journeyRoutes = [];
  double _currentFuelStock = 0;
  double _mileagePenaltyRate = 0; // From settings

  Vehicle? _selectedVehicle;
  AppUser? _selectedDriver;
  String? _selectedJourneyRoute;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  bool _tankFull = false;

  DieselLog? _lastFullLog;
  List<DieselLog> _recentLogs = [];

  List<AppUser> _dedupeUsers(List<AppUser> users) {
    final map = <String, AppUser>{};
    for (final user in users) {
      map[user.id] = user;
    }
    return map.values.toList();
  }

  List<Vehicle> _dedupeVehicles(List<Vehicle> vehicles) {
    final map = <String, Vehicle>{};
    for (final vehicle in vehicles) {
      map[vehicle.id] = vehicle;
    }
    return map.values.toList();
  }

  Vehicle? _resolveSelectedVehicle(List<Vehicle> vehicles) {
    final selectedId = _selectedVehicle?.id;
    if (selectedId == null || selectedId.isEmpty) return null;
    for (final vehicle in vehicles) {
      if (vehicle.id == selectedId) return vehicle;
    }
    return null;
  }

  AppUser? _resolveSelectedDriver(List<AppUser> drivers) {
    final selectedId = _selectedDriver?.id;
    if (selectedId == null || selectedId.isEmpty) return null;
    for (final driver in drivers) {
      if (driver.id == selectedId) return driver;
    }
    return null;
  }

  String _normalizeRole(String value) {
    return value
        .trim()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toLowerCase();
  }

  bool _isActiveUser(AppUser user) {
    final status = (user.status ?? '').trim().toLowerCase();
    return user.isActive &&
        (status.isEmpty ||
            status == 'active' ||
            status == 'enabled' ||
            status == 'approved');
  }

  AppUser _driverFromEmployee(Employee employee) {
    final linkedUserId = employee.linkedUserId?.trim();
    final userId = (linkedUserId != null && linkedUserId.isNotEmpty)
        ? linkedUserId
        : 'emp_${employee.employeeId}';

    return AppUser(
      id: userId,
      name: employee.name,
      email: '${employee.employeeId.toLowerCase()}@hr.local',
      role: UserRole.driver,
      department: employee.department,
      phone: employee.mobile,
      departments: const [],
      status: employee.isActive ? 'active' : 'inactive',
      isActive: employee.isActive,
      createdAt: employee.createdAt.toIso8601String(),
    );
  }

  Future<List<AppUser>> _loadDriverCandidates() async {
    final employees = await _hrService.getAllEmployees(forceRefresh: true);
    final hrDrivers = employees
        .where((e) => e.isActive && _normalizeRole(e.roleType) == 'driver')
        .map(_driverFromEmployee)
        .toList();

    if (hrDrivers.isNotEmpty) {
      final deduped = _dedupeUsers(hrDrivers);
      deduped.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return deduped;
    }

    final users = await _usersService.getUsers(role: UserRole.driver);
    final strictDrivers = users
        .where((u) => u.role == UserRole.driver && _isActiveUser(u))
        .toList();

    final deduped = _dedupeUsers(strictDrivers);
    deduped.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return deduped;
  }

  Future<void> _fetchRecentLogs(String vehicleId) async {
    try {
      final logs = await _dieselService.getDieselLogs(
        vehicleId: vehicleId,
        limitCount: 5,
      );
      if (mounted) {
        setState(() => _recentLogs = logs);
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    _vehiclesService = context.read<VehiclesService>();
    _usersService = context.read<UsersService>();
    _settingsService = context.read<SettingsService>();
    _hrService = context.read<HrService>();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final vehicles = await _vehiclesService.getVehicles(status: 'active');
      final drivers = await _loadDriverCandidates();
      final routes = await _loadJourneyRoutes();
      final uniqueVehicles = _dedupeVehicles(vehicles);
      final uniqueDrivers = _dedupeUsers(drivers);
      final selectedVehicle = _resolveSelectedVehicle(uniqueVehicles);
      final selectedDriver = _resolveSelectedDriver(uniqueDrivers);
      final rate = await _dieselService.getLatestDieselRate();
      final stock = await _dieselService.getFuelStock();

      // Fetch fuel settings for penalty
      double penaltyRate = 0;
      final settings = await _settingsService.getFuelSettings();
      penaltyRate = settings?.globalPenaltyRate ?? 0;

      if (mounted) {
        setState(() {
          _vehicles = uniqueVehicles;
          _drivers = uniqueDrivers;
          _selectedVehicle = selectedVehicle;
          _selectedDriver = selectedDriver;
          _journeyRoutes = routes;
          _currentFuelStock = stock;
          _mileagePenaltyRate = penaltyRate;
          _rateController.text = rate.toStringAsFixed(2);
          _isLoading = false;
        });

        if (_drivers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active drivers found in HR employees.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<List<String>> _loadJourneyRoutes() async {
    try {
      final routeData = await _vehiclesService.getRoutes();
      final routes = routeData
          .where((r) {
            final status = (r['status'] ?? '').toString().toLowerCase();
            final isActive = r['isActive'] == true;
            return isActive || status.isEmpty || status == 'active';
          })
          .map((r) {
            final rawName = (r['name'] ?? r['routeName'] ?? '')
                .toString()
                .trim();
            return rawName;
          })
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      routes.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return routes;
    } catch (e) {
      debugPrint('Error loading journey routes: $e');
      return const [];
    }
  }

  Future<void> _onVehicleChanged(Vehicle? v) async {
    if (v == null) return;
    setState(() {
      _selectedVehicle = v;
      _lastFullLog = null;
    });

    try {
      final log = await _dieselService.getLastFullTankLog(v.id);
      await _fetchRecentLogs(v.id);
      if (mounted) {
        setState(() {
          _lastFullLog = log;
        });
      }
    } catch (e) {
      debugPrint('Error fetching last full log: $e');
    }
  }

  Map<String, double> _calculateTripAnalytics() {
    double liters = double.tryParse(_litersController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double odometer = double.tryParse(_odometerController.text) ?? 0;

    if (_selectedVehicle == null || liters <= 0 || odometer <= 0) {
      return {
        'distance': 0,
        'totalCost': liters * rate,
        'mileage': 0,
        'penalty': 0,
      };
    }

    double startOdometer =
        _lastFullLog?.odometerReading ?? _selectedVehicle!.currentOdometer;
    double distance = odometer - startOdometer;
    if (distance < 0) distance = 0;

    double mileage = 0;
    double penalty = 0;

    if (_tankFull && distance > 0 && liters > 0) {
      mileage = distance / liters;

      double minAverage = _selectedVehicle!.minAverage;
      if (minAverage > 0 && mileage < minAverage && _mileagePenaltyRate > 0) {
        double expectedFuel = distance / minAverage;
        double extraFuel = liters - expectedFuel;
        if (extraFuel > 0) {
          penalty = extraFuel * _mileagePenaltyRate;
        }
      }
    }

    return {
      'distance': distance,
      'totalCost': liters * rate,
      'mileage': mileage,
      'penalty': penalty,
    };
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate() ||
        _selectedVehicle == null ||
        _selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final liters = double.tryParse(_litersController.text);
    if (liters == null || liters <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid liters value'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (liters > _currentFuelStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient fuel stock. Available: ${_currentFuelStock.toStringAsFixed(1)} L',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final odometer = double.tryParse(_odometerController.text);
    if (odometer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid odometer reading'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (odometer < _selectedVehicle!.currentOdometer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Odometer cannot be less than previous reading (${_selectedVehicle!.currentOdometer} km)',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final analytics = _calculateTripAnalytics();
      final rate = double.tryParse(_rateController.text);
      if (rate == null || rate <= 0) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid rate'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final logData = {
        'vehicleId': _selectedVehicle!.id,
        'vehicleNumber': _selectedVehicle!.number,
        'driverName': _selectedDriver!.name,
        'fillDate': _selectedDate.toIso8601String().split('T')[0],
        'liters': liters,
        'rate': rate,
        'odometerReading': odometer,
        'tankFull': _tankFull,
        'journeyFrom': 'Datt Soap Factory',
        'journeyTo': _toController.text,
        'penaltyAmount': analytics['penalty'],
      };

      await _dieselService.addDieselLog(logData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diesel log added successfully')),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _resetForm() {
    setState(() {
      _isSaving = false;
      _litersController.clear();
      _odometerController.clear();
      _toController.clear();
      _selectedJourneyRoute = null;
      _selectedVehicle = null;
      _selectedDriver = null;
      _tankFull = false;
      _selectedDate = DateTime.now();
    });
    _loadInitialData(); // Refresh stock
  }

  @override
  void dispose() {
    _litersController.dispose();
    _rateController.dispose();
    _odometerController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analytics = _calculateTripAnalytics();
    final NumberFormat currencyFormatter = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'Add Diesel Log',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTopStats(isMobile: isMobile),
                        const SizedBox(height: 20),
                        if (isMobile) ...[
                          _buildLogForm(isMobile: true),
                          const SizedBox(height: 12),
                          _buildAnalyticsCard(
                            analytics,
                            currencyFormatter,
                            isMobile: true,
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildLogForm()),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: _buildAnalyticsCard(
                                  analytics,
                                  currencyFormatter,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTopStats({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.opacity, color: AppColors.warning, size: 32),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Fuel Stock',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${_currentFuelStock.toStringAsFixed(1)} Ltr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogForm({bool isMobile = false}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          children: [
            DropdownButtonFormField<Vehicle>(
              initialValue: _selectedVehicle,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Vehicle',
                border: OutlineInputBorder(),
              ),
              items: _vehicles
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        '${v.name} (${v.number})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _onVehicleChanged,
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppUser>(
              initialValue: _selectedDriver,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Driver',
                border: OutlineInputBorder(),
              ),
              items: _drivers
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(
                        d.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (d) => setState(() => _selectedDriver = d),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            if (isMobile) ...[
              _buildOldOdometerPanel(theme),
              const SizedBox(height: 12),
              _buildCurrentOdometerField(),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildOldOdometerPanel(theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCurrentOdometerField()),
                ],
              ),
            ],
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Tank Full?'),
              subtitle: const Text('Required for efficiency calculation'),
              value: _tankFull,
              onChanged: (v) => setState(() => _tankFull = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            if (isMobile) ...[
              _buildJourneyField(theme),
              const SizedBox(height: 12),
              _buildDateField(),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildJourneyField(theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateField()),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (isMobile) ...[
              _buildLitersField(),
              const SizedBox(height: 12),
              _buildRateField(),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildLitersField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRateField()),
                ],
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                      )
                    : const Text(
                        'ADD DIESEL LOG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOldOdometerPanel(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Old Odometer',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_selectedVehicle?.currentOdometer.toStringAsFixed(0) ?? 0} km',
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentOdometerField() {
    return TextFormField(
      controller: _odometerController,
      decoration: const InputDecoration(
        labelText: 'Current Odometer',
        suffixText: 'km',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) => setState(() {}),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildJourneyField(ThemeData theme) {
    if (_journeyRoutes.isEmpty) {
      return TextFormField(
        controller: _toController,
        decoration: const InputDecoration(
          labelText: 'Journey To',
          border: OutlineInputBorder(),
          hintText: 'Enter destination',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth,
          controller: _toController,
          initialSelection: _selectedJourneyRoute,
          label: const Text('Journey To'),
          menuHeight: 240,
          enableFilter: true,
          requestFocusOnTap: true,
          leadingIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          dropdownMenuEntries: _journeyRoutes
              .map(
                (route) =>
                    DropdownMenuEntry<String>(value: route, label: route),
              )
              .toList(),
          onSelected: (value) {
            setState(() => _selectedJourneyRoute = value);
          },
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
            side: WidgetStatePropertyAll(
              BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 90)),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
      ),
    );
  }

  Widget _buildLitersField() {
    return TextFormField(
      controller: _litersController,
      decoration: const InputDecoration(
        labelText: 'Liters',
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) => setState(() {}),
      validator: (v) {
        if (v!.isEmpty) return 'Required';
        final parsed = double.tryParse(v);
        if (parsed == null) return 'Invalid number';
        if (parsed > _currentFuelStock) {
          return 'Insufficient Stock';
        }
        return null;
      },
    );
  }

  Widget _buildRateField() {
    return TextFormField(
      controller: _rateController,
      decoration: const InputDecoration(
        labelText: 'Rate/Ltr',
        prefixText: 'Rs ',
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      enabled: false,
    );
  }

  Widget _buildRecentHistory() {
    final theme = Theme.of(context);
    if (_selectedVehicle == null || _recentLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentLogs.length,
              separatorBuilder: (c, i) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final log = _recentLogs[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'dd MMM',
                            ).format(DateTime.parse(log.fillDate)),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            log.driverName,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${log.odometerReading.toStringAsFixed(0)} km',
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    Map<String, double> analytics,
    NumberFormat currencyFormatter, {
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Real-time calculation',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                _buildStepRow(
                  Icons.straighten,
                  'Total Distance',
                  '${analytics['distance']!.toStringAsFixed(1)} km',
                ),
                const Divider(height: 24),
                _buildStepRow(
                  Icons.currency_rupee,
                  'Total Cost',
                  currencyFormatter.format(analytics['totalCost']),
                ),
                const Divider(height: 24),
                _buildStepRow(
                  Icons.speed,
                  'Efficiency',
                  '${analytics['mileage']!.toStringAsFixed(2)} km/L',
                ),
                if (analytics['penalty']! > 0) ...[
                  const Divider(height: 24),
                  _buildStepRow(
                    Icons.warning_amber_rounded,
                    'Penalty',
                    currencyFormatter.format(analytics['penalty']),
                    color: AppColors.error,
                  ),
                ],
              ],
            ),
          ),
        ),
        _buildRecentHistory(),
      ],
    );
  }

  Widget _buildStepRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
