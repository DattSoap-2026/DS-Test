import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/duty_service.dart';
import '../../services/gps_service.dart';
import '../../modules/hr/services/hr_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class DutyScreen extends StatefulWidget {
  const DutyScreen({super.key});

  @override
  State<DutyScreen> createState() => _DutyScreenState();
}

class _DutyScreenState extends State<DutyScreen> {
  // Services accessed via context
  // late final DutyService _dutyService; // Removed
  // late final GpsService _gpsService;   // Removed

  bool _isLoading = true;
  DutySession? _activeSession;
  Map<String, dynamic>? _startRules;
  DutySettings _dutySettings = DutySettings.defaults();

  // Local Stats
  int _durationMinutes = 0;
  double _distanceTraveled = 0.0;
  bool _isActiveTracking = false; // "Active Movement Mode" toggle

  // Timers
  Timer? _minuteTimer;
  Timer? _gpsTimer;

  final TextEditingController _odometerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Services provided by MultiProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    _gpsTimer?.cancel();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final dutyService = context.read<DutyService>();
      final session = await dutyService.getActiveDutySession(user.id);
      final dutySettings = await dutyService.getDutySettings();
      if (!mounted) return;
      final rules = await dutyService.checkDutyTimeRules(
        userId: user.id,
        role: user.role == UserRole.driver ? 'Driver' : 'Salesman',
      );

      if (mounted) {
        setState(() {
          _activeSession = session;
          _startRules = rules;
          _dutySettings = dutySettings;
          _isLoading = false;
          if (session != null) {
            _distanceTraveled = session.totalDistanceKm ?? 0.0;
            _startTimers();
          } else {
            _stopTimers();
            _distanceTraveled = 0.0;
            _durationMinutes = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error checking status: $e');
      }
    }
  }

  void _startTimers() {
    _minuteTimer?.cancel();
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateStats();
    });

    _scheduleGpsTimer();
    _updateStats(); // Initial update
  }

  void _stopTimers() {
    _minuteTimer?.cancel();
    _gpsTimer?.cancel();
  }

  void _scheduleGpsTimer() {
    _gpsTimer?.cancel();
    // Normal Mode: 60 mins | Active Mode: 15 mins
    final interval = _isActiveTracking
        ? const Duration(minutes: 15)
        : const Duration(minutes: 60);
    _gpsTimer = Timer.periodic(interval, (timer) {
      _performGpsUpdate();
    });
  }

  void _updateStats() {
    if (_activeSession == null) return;

    final now = DateTime.now();

    if (_hasReachedTrackingCutoff(now)) {
      _forceStopTracking();
      return;
    }

    final loginTime = DateTime.tryParse(_activeSession!.loginTime);
    if (loginTime == null) return;
    setState(() {
      _durationMinutes = now.difference(loginTime).inMinutes;
    });
  }

  int? _parseClockToMinutes(String? value) {
    final raw = value?.trim() ?? '';
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (match == null) return null;
    final hours = int.tryParse(match.group(1)!);
    final minutes = int.tryParse(match.group(2)!);
    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;
    return hours * 60 + minutes;
  }

  int _resolveTrackingCutoffMinutes() {
    final role = _activeSession?.userRole;
    final roleSettings = role == null ? null : _dutySettings.roleSettings[role];
    final dutyEndTime =
        _activeSession?.dutyEndTime ??
        roleSettings?.endTime ??
        _dutySettings.globalSettings.defaultEndTime;
    final dutyEndMinutes = _parseClockToMinutes(dutyEndTime) ?? (20 * 60);
    if (!_dutySettings.advancedTracking.continueTrackingAfterDutyEnd) {
      return dutyEndMinutes;
    }
    return _parseClockToMinutes(
          _dutySettings.advancedTracking.maxTrackingCutoffTime,
        ) ??
        dutyEndMinutes;
  }

  bool _hasReachedTrackingCutoff(DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;
    return currentMinutes >= _resolveTrackingCutoffMinutes();
  }

  String _trackingCutoffLabel() {
    final cutoffMinutes = _resolveTrackingCutoffMinutes();
    final hours = (cutoffMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (cutoffMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Future<void> _performGpsUpdate() async {
    if (_activeSession == null) return;

    final location = await context.read<GpsService>().getCurrentLocation();
    if (!mounted) return;
    if (location == null) return;

    // Check Company Geo-Fence for Auto-Stop logic
    final dutyService = context.read<DutyService>();
    final isAtCompany = await dutyService.checkCompanyGeoFence(
      location.latitude!,
      location.longitude!,
    );
    if (!mounted) return;
    if (isAtCompany && _dutySettings.advancedTracking.enableSmartAutoStop) {
      _promptEndDuty('You have reached company location. End duty?');
      return;
    }

    // Accumulate distance (simplified: only from last update if we had it, but here we just get one point)
    // Real implementation would store last point locally.
    // To match "client-side only" & "battery-optimized", we just update the point and sync.
    await context.read<GpsService>().updateEntityLocation(
      _activeSession!.userId,
      location,
    );

    // In a real scenario, we'd calculate distance between two points stored locally.
    // For this migration, we assume distance is updated progressively on server via updateEntityLocation
    // OR we pull the running total.
    // Let's assume we pull updated stats occasionally.
  }

  void _forceStopTracking() {
    _stopTimers();
    _showError(
      'Duty cutoff reached (${_trackingCutoffLabel()}). Tracking stopped automatically.',
    );
    // In a real app, this might also call endDutySession automatically if required by policy.
  }

  Future<void> _toggleDuty() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    if (_activeSession == null) {
      // Start Duty logic
      if (_startRules?['canStart'] == false) {
        _showError(_startRules?['message'] ?? 'Duty cannot be started.');
        return;
      }

      setState(() => _isLoading = true);
      setState(() => _isLoading = true);
      try {
        final loc = await context.read<GpsService>().getCurrentLocation();
        if (!mounted) return;

        String? empId;
        try {
          // Attempt to find linked employee
          final hrService = context.read<HrService>();
          final emp = await hrService.getEmployeeByUserId(user.id);
          if (!mounted) return;
          empId = emp?.employeeId;
        } catch (_) {
          // Proceed even if HR service fails (e.g. offline)
        }

        final dutyService = context.read<DutyService>();
        final success = await dutyService.startDutySession({
          'userId': user.id,
          'employeeId': empId,
          'userName': user.name,
          'userRole': user.role == UserRole.driver ? 'Driver' : 'Salesman',
          'date': DateTime.now().toIso8601String().split('T')[0],
          'loginTime': DateTime.now().toIso8601String(),
          'loginLatitude': loc?.latitude ?? 0.0,
          'loginLongitude': loc?.longitude ?? 0.0,
          'gpsEnabled': true,
          'vehicleId': user.assignedVehicleId,
          'vehicleNumber': user.assignedVehicleNumber,
        });
        if (!mounted) return;

        if (success != null) {
          _checkStatus();
        }
      } catch (e) {
        _showError('Failed to start duty: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _promptEndDuty('End duty session?');
    }
  }

  void _promptEndDuty(String message) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return ResponsiveAlertDialog(
          title: const Text('End Duty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              TextField(
                controller: _odometerController,
                decoration: const InputDecoration(
                  labelText: 'Closing Odometer (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_odometerController.text.isEmpty) {
                  _showError('Odometer reading is mandatory');
                  return;
                }
                Navigator.pop(context);
                _endDuty();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Confirm End'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _endDuty() async {
    setState(() => _isLoading = true);
    try {
      final gpsService = context.read<GpsService>();
      final loc = await gpsService.getCurrentLocation();
      if (!mounted) return;

      final dutyService = context.read<DutyService>();
      final success = await dutyService.endDutySession(_activeSession!.id, {
        'logoutTime': DateTime.now().toIso8601String(),
        'logoutLatitude': loc?.latitude ?? 0.0,
        'logoutLongitude': loc?.longitude ?? 0.0,
        'endOdometer': double.tryParse(_odometerController.text) ?? 0.0,
        'totalDistanceKm': _distanceTraveled,
      });
      if (!mounted) return;

      if (success) {
        _odometerController.clear();
        _checkStatus();
      }
    } catch (e) {
      _showError('Failed to end duty: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Service Tracking')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _checkStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDutyStateCard(),
                    const SizedBox(height: 16),
                    if (_activeSession != null) ...[
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildTrackingModeCard(),
                      const SizedBox(height: 24),
                    ],
                    _buildInstructionsCard(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _activeSession == null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _toggleDuty,
                icon: const Icon(Icons.play_arrow),
                label: const Text('START DUTY'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.success,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDutyStateCard() {
    final bool isOnDuty = _activeSession != null;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOnDuty ? AppColors.success : colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnDuty ? ' ON DUTY' : ' OFF DUTY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isOnDuty
                            ? AppColors.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                if (isOnDuty)
                  IconButton(
                    onPressed: _toggleDuty,
                    icon: const Icon(
                      Icons.stop_circle,
                      color: AppColors.error,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final hours = _durationMinutes ~/ 60;
    final mins = _durationMinutes % 60;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 520 ? 1 : 2;
        final childAspectRatio = constraints.maxWidth < 520 ? 1.8 : 1.3;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatItem(
              'Duration',
              '${hours}h ${mins}m',
              Icons.timer,
              AppColors.info,
            ),
            _buildStatItem(
              'Distance',
              '${_distanceTraveled.toStringAsFixed(1)} KM',
              Icons.directions_car,
              AppColors.warning,
            ),
            _buildStatItem(
              'GPS Status',
              'ON',
              Icons.gps_fixed,
              AppColors.success,
            ),
            _buildStatItem(
              'Cut-off',
              _trackingCutoffLabel(),
              Icons.access_time,
              AppColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingModeCard() {
    return Card(
      child: SwitchListTile(
        title: const Text('Active Movement Mode'),
        subtitle: const Text(
          'GPS updates every 15 mins (Higher battery usage)',
        ),
        secondary: const Icon(Icons.electric_bolt, color: AppColors.warning),
        value: _isActiveTracking,
        onChanged: (val) {
          setState(() {
            _isActiveTracking = val;
            _scheduleGpsTimer();
          });
        },
      ),
    );
  }

  Widget _buildInstructionsCard() {
    final autoStopEnabled = _dutySettings.advancedTracking.enableSmartAutoStop;
    return Card(
      color: AppColors.infoBg,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracking Policy:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            BulletPoint(
              'Tracking automatically stops at ${_trackingCutoffLabel()}.',
            ),
            BulletPoint(
              autoStopEnabled
                  ? 'Returning to company area can trigger duty end prompt.'
                  : 'Company geofence auto-stop is disabled in settings.',
            ),
            const BulletPoint('GPS updates once per hour in Normal mode.'),
            const BulletPoint('Keep App open or in recent for best tracking.'),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}




