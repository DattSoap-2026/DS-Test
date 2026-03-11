import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/settings_service.dart';
import '../../models/types/user_types.dart';
import '../../services/users_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/themed_filter_chip.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class GeneralSettingsScreen extends StatefulWidget {
  final bool showHeader;

  const GeneralSettingsScreen({super.key, this.showHeader = true});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final UsersService _usersService;
  late final SettingsService _settingsService;
  late TabController _tabController;

  bool _isLoading = true;
  bool _isSaving = false;

  // Global Settings controllers
  final _businessStartController = TextEditingController();
  final _businessEndController = TextEditingController();

  GeneralSettingsData _settings = GeneralSettingsData(
    businessStartTime: '09:00',
    businessEndTime: '20:00',
    workingDays: [1, 2, 3, 4, 5, 6],
    emailNotifications: true,
    smsNotifications: false,
    pushNotifications: true,
    lowStockAlert: true,
    salesTargetReminder: true,
    theme: 'system',
    language: 'en',
    dateFormat: 'DD/MM/YYYY',
    currency: 'INR',
    retentionDays: 90,
    autoBackup: false,
    backupFrequency: 'weekly',
    allowNegativeStock: false,
    enforceCreditLimit: true,
    maxDiscountPercentage: 10,
    orderEditWindowMinutes: 30,
    trackingIntervalMinutes: 5,
    trackOnlyWorkHours: true,
    staleLocationThresholdMinutes: 15,
    sessionTimeoutMinutes: 60,
    maxLoginAttempts: 5,
    salesmanSpecialDiscountOptions: const [1, 2, 3, 5],
    salesmanCustomerSpecialDiscount: 5,
    salesmanDealerSpecialDiscount: 5,
    salesmanAdditionalDiscountOptions: const [5, 8, 13],
    salesmanCustomerAdditionalDiscount: 5,
    salesmanDealerAdditionalDiscount: 5,
    allowSalesmanGstToggle: true,
    allowSalesmanAdditionalDiscountToggle: true,
    allowSalesmanSpecialDiscountToggle: true,
    allowDealerGstToggle: true,
    allowDealerAdditionalDiscountToggle: true,
    allowDealerSpecialDiscountToggle: true,
    dealerAdditionalDiscountOptions: const [2, 5, 10, 15],
    dealerAdditionalDiscountDefault: 5,
    dealerSpecialDiscountOptions: const [1, 2, 3, 5],
    dealerSpecialDiscountDefault: 5,
  );

  DutySettings _dutySettings = DutySettings(
    globalSettings: DutyGlobalSettings(
      defaultStartTime: '08:00',
      defaultEndTime: '20:00',
      workingDays: [1, 2, 3, 4, 5, 6],
      autoGpsOff: false,
      gpsPollingIntervalMs: 30000,
      idleThresholdMinutes: 5,
      staleLocationMinutes: 10,
    ),
    advancedTracking: DutyAdvancedTracking(
      baseReturnRadiusMeters: 300,
      baseReturnSpeedKmh: 5.0,
      stationaryMinutesRequired: 10,
      maxTrackingCutoffTime: '23:00',
      overtimeAlertEnabled: true,
      maxOvertimeMinutes: 300,
      enableSmartAutoStop: true,
      continueTrackingAfterDutyEnd: true,
    ),
    roleSettings: {},
    sundayOverrides: [],
  );

  List<dynamic> _users = [];
  String? _selectedUserId;
  DateTime? _selectedDate;
  final _overrideReasonController = TextEditingController();

  final List<Map<String, dynamic>> _weekDays = [
    {'value': 0, 'label': 'Sunday', 'short': 'Sun'},
    {'value': 1, 'label': 'Monday', 'short': 'Mon'},
    {'value': 2, 'label': 'Tuesday', 'short': 'Tue'},
    {'value': 3, 'label': 'Wednesday', 'short': 'Wed'},
    {'value': 4, 'label': 'Thursday', 'short': 'Thu'},
    {'value': 5, 'label': 'Friday', 'short': 'Fri'},
    {'value': 6, 'label': 'Saturday', 'short': 'Sat'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 6,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _settingsService = context.read<SettingsService>();
    _usersService = context.read<UsersService>();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessStartController.dispose();
    _businessEndController.dispose();
    _overrideReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _settingsService.getGeneralSettings();
      final dutySettings = await _settingsService.getDutySettings();
      final users = await _usersService.getUsers();

      if (mounted) {
        setState(() {
          if (settings != null) {
            _settings = settings;
            _businessStartController.text =
                _settings.businessStartTime ?? '09:00';
            _businessEndController.text = _settings.businessEndTime ?? '20:00';
          }
          if (dutySettings != null) _dutySettings = dutySettings;
          _users = users
              .where(
                (u) => u.role == UserRole.driver || u.role == UserRole.salesman,
              )
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleSave() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      _settings.businessStartTime = _businessStartController.text;
      _settings.businessEndTime = _businessEndController.text;

      final success1 = await _settingsService.updateGeneralSettings(
        _settings,
        user.id,
        user.name,
      );
      final success2 = await _settingsService.updateDutySettings(
        _dutySettings,
        user.id,
        user.name,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (success1 && success2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save some settings')),
          );
        }
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

  void _addOverride() {
    if (_selectedUserId == null ||
        _selectedDate == null ||
        _overrideReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all override fields')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final user = context.read<AuthProvider>().state.user;

    setState(() {
      _dutySettings.sundayOverrides.add(
        SundayOverride(
          date: dateStr,
          allowedUserIds: [_selectedUserId!],
          reason: _overrideReasonController.text,
          approvedBy: user?.name ?? 'Admin',
          approvedAt: DateTime.now().toIso8601String(),
        ),
      );
      _selectedUserId = null;
      _selectedDate = null;
      _overrideReasonController.clear();
    });
  }

  void _removeOverride(int index) {
    setState(() {
      _dutySettings.sundayOverrides.removeAt(index);
    });
  }

  List<double> _parseDiscountOptions(
    String raw, {
    List<double> fallback = const [1, 2, 3, 5],
  }) {
    final values =
        raw
            .split(',')
            .map((e) => double.tryParse(e.trim()))
            .whereType<double>()
            .where((e) => e > 0 && e <= 100)
            .map((e) => e.toDouble())
            .toSet()
            .toList()
          ..sort();
    return values.isEmpty ? fallback : values;
  }

  String _formatDiscountOptions(
    List<double>? values, {
    List<double> fallback = const [1, 2, 3, 5],
  }) {
    final safe =
        (values ?? const <double>[])
            .where((e) => e > 0 && e <= 100)
            .toSet()
            .toList()
          ..sort();
    final normalized = safe.isEmpty ? fallback : safe;
    return normalized
        .map(
          (e) => e.truncateToDouble() == e
              ? e.toInt().toString()
              : e.toStringAsFixed(2),
        )
        .join(', ');
  }

  double? _parseBoundedDiscount(String raw) {
    return double.tryParse(raw.trim())?.clamp(0.0, 100.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom Header Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showHeader) ...[
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'General Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                ThemedTabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Business'),
                    Tab(text: 'Duty'),
                    Tab(text: 'Controls'),
                    Tab(text: 'Alerts'),
                    Tab(text: 'Display'),
                    Tab(text: 'Data'),
                  ],
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBusinessTab(),
                _buildDutyTab(),
                _buildControlsTab(),
                _buildAlertsTab(),
                _buildDisplayTab(),
                _buildDataTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            label: 'Save All Settings',
            icon: Icons.save,
            isLoading: _isSaving,
            onPressed: _handleSave,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.flag, color: AppColors.info),
                  ),
                  title: const Text(
                    'Route Targets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Manage monthly sales targets for routes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed('/dashboard/settings/route-targets');
                  },
                ),
                const Divider(height: 32),
                const Text(
                  'Business Hours',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Set your operating hours and working days',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Start Time',
                        hintText: '09:00',
                        controller: _businessStartController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'End Time',
                        hintText: '20:00',
                        controller: _businessEndController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Working Days',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _weekDays.map((day) {
                    final isSelected =
                        _settings.workingDays?.contains(day['value']) ?? false;
                    return ThemedFilterChip(
                      label: day['short'] as String,
                      selected: isSelected,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: theme.textTheme.labelSmall,
                      onSelected: () {
                        setState(() {
                          _settings.workingDays ??= [];
                          if (isSelected) {
                            _settings.workingDays!.remove(day['value']);
                          } else {
                            _settings.workingDays!.add(day['value'] as int);
                            _settings.workingDays!.sort();
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Duty Timings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Global working hours and days for field staff',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Default Start',
                        hintText: '08:00',
                        initialValue:
                            _dutySettings.globalSettings.defaultStartTime,
                        onChanged: (v) => setState(() {
                          _dutySettings = _dutySettings.copyWith(
                            globalSettings: _dutySettings.globalSettings
                                .copyWith(defaultStartTime: v),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Default End',
                        hintText: '20:00',
                        initialValue:
                            _dutySettings.globalSettings.defaultEndTime,
                        onChanged: (v) => setState(() {
                          _dutySettings = _dutySettings.copyWith(
                            globalSettings: _dutySettings.globalSettings
                                .copyWith(defaultEndTime: v),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Working Days',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _weekDays.map((day) {
                    final isSelected = _dutySettings.globalSettings.workingDays
                        .contains(day['value']);
                    return ThemedFilterChip(
                      label: day['short'] as String,
                      selected: isSelected,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: theme.textTheme.labelSmall,
                      onSelected: () {
                        setState(() {
                          final currentDays = List<int>.from(
                            _dutySettings.globalSettings.workingDays,
                          );
                          if (isSelected) {
                            currentDays.remove(day['value']);
                          } else {
                            currentDays.add(day['value'] as int);
                            currentDays.sort();
                          }
                          _dutySettings = _dutySettings.copyWith(
                            globalSettings: _dutySettings.globalSettings
                                .copyWith(workingDays: currentDays),
                          );
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'GPS Polling (ms)',
                        keyboardType: TextInputType.number,
                        initialValue: _dutySettings
                            .globalSettings
                            .gpsPollingIntervalMs
                            .toString(),
                        onChanged: (v) {
                          final val = int.tryParse(v);
                          if (val != null) {
                            setState(() {
                              _dutySettings = _dutySettings.copyWith(
                                globalSettings: _dutySettings.globalSettings
                                    .copyWith(gpsPollingIntervalMs: val),
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Idle Threshold (Min)',
                        keyboardType: TextInputType.number,
                        initialValue: _dutySettings
                            .globalSettings
                            .idleThresholdMinutes
                            .toString(),
                        onChanged: (v) {
                          final val = int.tryParse(v);
                          if (val != null) {
                            setState(() {
                              _dutySettings = _dutySettings.copyWith(
                                globalSettings: _dutySettings.globalSettings
                                    .copyWith(idleThresholdMinutes: val),
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto-Stop Behavior',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Tracking behavior when staff returns to base',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Smart Return Stop'),
                  subtitle: const Text(
                    'Auto-stop when back at base after duty hours',
                  ),
                  value: _dutySettings.advancedTracking.enableSmartAutoStop,
                  onChanged: (v) => setState(() {
                    _dutySettings = _dutySettings.copyWith(
                      advancedTracking: _dutySettings.advancedTracking.copyWith(
                        enableSmartAutoStop: v,
                      ),
                    );
                  }),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Post-Duty Tracking'),
                  subtitle: const Text(
                    'Allow tracking after hours if still moving',
                  ),
                  value: _dutySettings
                      .advancedTracking
                      .continueTrackingAfterDutyEnd,
                  onChanged: (v) => setState(() {
                    _dutySettings = _dutySettings.copyWith(
                      advancedTracking: _dutySettings.advancedTracking.copyWith(
                        continueTrackingAfterDutyEnd: v,
                      ),
                    );
                  }),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Base Radius (m)',
                        keyboardType: TextInputType.number,
                        initialValue: _dutySettings
                            .advancedTracking
                            .baseReturnRadiusMeters
                            .toString(),
                        onChanged: (v) {
                          final val = int.tryParse(v);
                          if (val != null) {
                            setState(() {
                              _dutySettings = _dutySettings.copyWith(
                                advancedTracking: _dutySettings.advancedTracking
                                    .copyWith(baseReturnRadiusMeters: val),
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Safety Cut-off',
                        hintText: '23:00',
                        initialValue: _dutySettings
                            .advancedTracking
                            .maxTrackingCutoffTime,
                        onChanged: (v) => setState(() {
                          _dutySettings = _dutySettings.copyWith(
                            advancedTracking: _dutySettings.advancedTracking
                                .copyWith(maxTrackingCutoffTime: v),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Session Overrides',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Allow specific users to work on off-days (e.g. Sundays)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedUserId,
                        decoration: const InputDecoration(
                          labelText: 'User',
                          border: OutlineInputBorder(),
                        ),
                        items: _users
                            .map(
                              (u) => DropdownMenuItem<String>(
                                value: u.id,
                                child: Text(u.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedUserId = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 7),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Select'
                                : DateFormat('dd MMM').format(_selectedDate!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Reason',
                  controller: _overrideReasonController,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Add Override',
                  icon: Icons.add,
                  onPressed: _addOverride,
                  width: double.infinity,
                ),
                if (_dutySettings.sundayOverrides.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Active Overrides',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_dutySettings.sundayOverrides.length, (idx) {
                    final o = _dutySettings.sundayOverrides[idx];
                    final allowedUserId = o.allowedUserIds.isNotEmpty
                        ? o.allowedUserIds.first
                        : null;
                    final u = allowedUserId == null
                        ? null
                        : _users.firstWhere(
                            (u) => u.id == allowedUserId,
                            orElse: () => null,
                          );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline, size: 20),
                      ),
                      title: Text(u?.name ?? 'Unknown User'),
                      subtitle: Text('${o.date} - ${o.reason}'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: () => _removeOverride(idx),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSalesControlCard(),
          const SizedBox(height: 16),
          _buildGpsControlCard(),
          const SizedBox(height: 16),
          _buildSecurityControlCard(),
        ],
      ),
    );
  }

  Widget _buildSalesControlCard() {
    final theme = Theme.of(context);
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales & Orders',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Manage sales restrictions and limits',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Allow Negative Stock'),
            subtitle: const Text('Bill items even if stock is 0'),
            value: _settings.allowNegativeStock ?? false,
            onChanged: (val) =>
                setState(() => _settings.allowNegativeStock = val),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Enforce Credit Limit'),
            subtitle: const Text('Block billing if limit exceeded'),
            value: _settings.enforceCreditLimit ?? true,
            onChanged: (val) =>
                setState(() => _settings.enforceCreditLimit = val),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Max Discount (%)',
                  keyboardType: TextInputType.number,
                  initialValue: _settings.maxDiscountPercentage?.toString(),
                  onChanged: (v) =>
                      _settings.maxDiscountPercentage = double.tryParse(v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Edit Window (Min)',
                  keyboardType: TextInputType.number,
                  initialValue: _settings.orderEditWindowMinutes?.toString(),
                  onChanged: (v) =>
                      _settings.orderEditWindowMinutes = int.tryParse(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Discount Governance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Separate controls for Salesman and Dealer. Settings are enforced on sale screens.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _buildRoleDiscountPanel(
            title: 'Salesman Controls',
            subtitle:
                'For New Sale screen. Configure primary and fallback defaults for salesman.',
            accentColor: theme.colorScheme.primary,
            children: [
              _buildInlineToggle(
                title: 'GST Toggle',
                subtitle: 'OFF locks GST control on salesman sale screen.',
                value: _settings.allowSalesmanGstToggle ?? true,
                onChanged: (val) =>
                    setState(() => _settings.allowSalesmanGstToggle = val),
              ),
              _buildInlineToggle(
                title: 'Additional Discount Toggle',
                subtitle: 'OFF locks additional discount for salesman.',
                value: _settings.allowSalesmanAdditionalDiscountToggle ?? true,
                onChanged: (val) => setState(
                  () => _settings.allowSalesmanAdditionalDiscountToggle = val,
                ),
              ),
              _buildInlineToggle(
                title: 'Special Discount Toggle',
                subtitle: 'OFF locks SP+Default for salesman.',
                value: _settings.allowSalesmanSpecialDiscountToggle ?? true,
                onChanged: (val) => setState(
                  () => _settings.allowSalesmanSpecialDiscountToggle = val,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Customer Additional Default (%)',
                      keyboardType: TextInputType.number,
                      initialValue: _settings.salesmanCustomerAdditionalDiscount
                          ?.toString(),
                      onChanged: (v) =>
                          _settings.salesmanCustomerAdditionalDiscount =
                              _parseBoundedDiscount(v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Fallback Additional Default (%)',
                      keyboardType: TextInputType.number,
                      initialValue: _settings.salesmanDealerAdditionalDiscount
                          ?.toString(),
                      onChanged: (v) =>
                          _settings.salesmanDealerAdditionalDiscount =
                              _parseBoundedDiscount(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Additional Discount Options (%)',
                hintText: '5, 8, 13',
                initialValue: _formatDiscountOptions(
                  _settings.salesmanAdditionalDiscountOptions,
                  fallback: const [5, 8, 13],
                ),
                onChanged: (v) => _settings.salesmanAdditionalDiscountOptions =
                    _parseDiscountOptions(v, fallback: const [5, 8, 13]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Customer SP Default (%)',
                      keyboardType: TextInputType.number,
                      initialValue: _settings.salesmanCustomerSpecialDiscount
                          ?.toString(),
                      onChanged: (v) =>
                          _settings.salesmanCustomerSpecialDiscount =
                              _parseBoundedDiscount(v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Fallback SP Default (%)',
                      keyboardType: TextInputType.number,
                      initialValue: _settings.salesmanDealerSpecialDiscount
                          ?.toString(),
                      onChanged: (v) =>
                          _settings.salesmanDealerSpecialDiscount =
                              _parseBoundedDiscount(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Special Discount Options (%)',
                hintText: '1, 2, 3, 5',
                initialValue: _formatDiscountOptions(
                  _settings.salesmanSpecialDiscountOptions,
                ),
                onChanged: (v) => _settings.salesmanSpecialDiscountOptions =
                    _parseDiscountOptions(v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRoleDiscountPanel(
            title: 'Dealer Controls',
            subtitle:
                'For Dealer Dispatch screen. Locks and options are enforced directly.',
            accentColor: theme.colorScheme.secondary,
            children: [
              _buildInlineToggle(
                title: 'GST Toggle',
                subtitle: 'OFF locks GST for dealer dispatch.',
                value: _settings.allowDealerGstToggle ?? true,
                onChanged: (val) =>
                    setState(() => _settings.allowDealerGstToggle = val),
              ),
              _buildInlineToggle(
                title: 'Additional Discount Toggle',
                subtitle: 'OFF locks additional discount for dealer dispatch.',
                value: _settings.allowDealerAdditionalDiscountToggle ?? true,
                onChanged: (val) => setState(
                  () => _settings.allowDealerAdditionalDiscountToggle = val,
                ),
              ),
              _buildInlineToggle(
                title: 'Special Discount Toggle',
                subtitle: 'OFF locks special discount for dealer dispatch.',
                value: _settings.allowDealerSpecialDiscountToggle ?? true,
                onChanged: (val) => setState(
                  () => _settings.allowDealerSpecialDiscountToggle = val,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Dealer Additional Default (%)',
                      keyboardType: TextInputType.number,
                      initialValue: _settings.dealerAdditionalDiscountDefault
                          ?.toString(),
                      onChanged: (v) =>
                          _settings.dealerAdditionalDiscountDefault =
                              _parseBoundedDiscount(v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Dealer SP Default (%)',
                      keyboardType: TextInputType.number,
                      initialValue: _settings.dealerSpecialDiscountDefault
                          ?.toString(),
                      onChanged: (v) => _settings.dealerSpecialDiscountDefault =
                          _parseBoundedDiscount(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Dealer Additional Options (%)',
                hintText: '2, 5, 10, 15',
                initialValue: _formatDiscountOptions(
                  _settings.dealerAdditionalDiscountOptions,
                  fallback: const [2, 5, 10, 15],
                ),
                onChanged: (v) => _settings.dealerAdditionalDiscountOptions =
                    _parseDiscountOptions(v, fallback: const [2, 5, 10, 15]),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Dealer Special Options (%)',
                hintText: '1, 2, 3, 5',
                initialValue: _formatDiscountOptions(
                  _settings.dealerSpecialDiscountOptions,
                ),
                onChanged: (v) => _settings.dealerSpecialDiscountOptions =
                    _parseDiscountOptions(v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDiscountPanel({
    required String title,
    required String subtitle,
    required Color accentColor,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInlineToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildGpsControlCard() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GPS Tracking',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Configure location tracking behavior',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Work Hours Only'),
            subtitle: const Text('Disable GPS after work hours'),
            value: _settings.trackOnlyWorkHours ?? true,
            onChanged: (val) =>
                setState(() => _settings.trackOnlyWorkHours = val),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Interval (Min)',
                  keyboardType: TextInputType.number,
                  initialValue: _settings.trackingIntervalMinutes?.toString(),
                  onChanged: (v) =>
                      _settings.trackingIntervalMinutes = int.tryParse(v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Stale Threshold (Min)',
                  keyboardType: TextInputType.number,
                  initialValue: _settings.staleLocationThresholdMinutes
                      ?.toString(),
                  onChanged: (v) =>
                      _settings.staleLocationThresholdMinutes = int.tryParse(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityControlCard() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Access control and timeouts',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Session Timeout (Min)',
                  keyboardType: TextInputType.number,
                  initialValue: _settings.sessionTimeoutMinutes?.toString(),
                  onChanged: (v) =>
                      _settings.sessionTimeoutMinutes = int.tryParse(v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Max Login Attempts',
                  keyboardType: TextInputType.number,
                  initialValue: _settings.maxLoginAttempts?.toString(),
                  onChanged: (v) =>
                      _settings.maxLoginAttempts = int.tryParse(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Control how you receive alerts and updates',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                _switch(
                  'Email Notifications',
                  'Receive notifications via email',
                  _settings.emailNotifications ?? true,
                  (v) => setState(() => _settings.emailNotifications = v),
                ),
                _switch(
                  'SMS Notifications',
                  'Receive notifications via SMS',
                  _settings.smsNotifications ?? false,
                  (v) => setState(() => _settings.smsNotifications = v),
                ),
                _switch(
                  'Push Notifications',
                  'Receive mobile push notifications',
                  _settings.pushNotifications ?? true,
                  (v) => setState(() => _settings.pushNotifications = v),
                ),
                const Divider(height: 32),
                const Text(
                  'Alert Types',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _switch(
                  'Low Stock Alerts',
                  'Get notified when stock is low',
                  _settings.lowStockAlert ?? true,
                  (v) => setState(() => _settings.lowStockAlert = v),
                  isMuted: true,
                ),
                _switch(
                  'Sales Target Reminders',
                  'Monthly target achievement reminders',
                  _settings.salesTargetReminder ?? true,
                  (v) => setState(() => _settings.salesTargetReminder = v),
                  isMuted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool isMuted = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMuted ? colors.surfaceContainerLow : null,
        borderRadius: BorderRadius.circular(8),
        border: isMuted
            ? Border.all(color: colors.outlineVariant)
            : Border.all(color: colors.outlineVariant),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDisplayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Display Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Customize how the system looks and feels',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _settings.theme,
                  decoration: const InputDecoration(
                    labelText: 'Theme',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    DropdownMenuItem(value: 'system', child: Text('System')),
                  ],
                  onChanged: (v) => setState(() => _settings.theme = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _settings.language,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                    DropdownMenuItem(
                      value: 'hi',
                      child: Text('🇮🇳 हिंदी (Hindi)'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _settings.language = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _settings.dateFormat,
                  decoration: const InputDecoration(
                    labelText: 'Date Format',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'DD/MM/YYYY',
                      child: Text('DD/MM/YYYY'),
                    ),
                    DropdownMenuItem(
                      value: 'MM/DD/YYYY',
                      child: Text('MM/DD/YYYY'),
                    ),
                    DropdownMenuItem(
                      value: 'YYYY-MM-DD',
                      child: Text('YYYY-MM-DD'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _settings.dateFormat = v),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Default Currency',
                  initialValue: _settings.currency,
                  readOnly: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Management',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Configure data retention and backup preferences',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Data Retention Period (Days)',
                  keyboardType: TextInputType.number,
                  initialValue: _settings.retentionDays?.toString(),
                  onChanged: (v) => _settings.retentionDays = int.tryParse(v),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Automatic Backups'),
                  subtitle: const Text('Enable scheduled automatic backups'),
                  value: _settings.autoBackup ?? false,
                  onChanged: (val) =>
                      setState(() => _settings.autoBackup = val),
                  contentPadding: EdgeInsets.zero,
                ),
                if (_settings.autoBackup == true) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.backupFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Backup Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _settings.backupFrequency = v),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Automatic backups require additional storage. Configure backup storage in Firebase Console.',
                          style: TextStyle(fontSize: 12, color: AppColors.info),
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
    );
  }
}
