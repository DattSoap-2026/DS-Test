import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_service.dart';
import '../models/attendance_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../utils/app_toast.dart';

class AttendanceMarkScreen extends StatefulWidget {
  const AttendanceMarkScreen({super.key});

  @override
  State<AttendanceMarkScreen> createState() => _AttendanceMarkScreenState();
}

class _AttendanceMarkScreenState extends State<AttendanceMarkScreen> {
  Attendance? _todayAttendance;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTodayStatus();
  }

  Future<void> _loadTodayStatus() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final service = context.read<AttendanceService>();

    if (auth.currentUser?.id != null) {
      final attendance = await service.getTodayAttendance(auth.currentUser!.id);
      setState(() {
        _todayAttendance = attendance;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDateCard(now),
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateCard(DateTime now) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final hasCheckedIn = _todayAttendance?.checkInTime != null;
    final hasCheckedOut = _todayAttendance?.checkOutTime != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _timeCard(
                    'Check-in',
                    _todayAttendance?.checkInTime,
                    Icons.login,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _timeCard(
                    'Check-out',
                    _todayAttendance?.checkOutTime,
                    Icons.logout,
                    Colors.red,
                  ),
                ),
              ],
            ),
            if (hasCheckedIn && hasCheckedOut) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Worked: ${_todayAttendance!.workedHoursFormatted}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeCard(String label, DateTime? time, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            time != null
                ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                : '--:--',
            style: TextStyle(
              fontSize: 18,
              color: time != null ? color : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasCheckedIn = _todayAttendance?.checkInTime != null;
    final hasCheckedOut = _todayAttendance?.checkOutTime != null;
    final colorScheme = Theme.of(context).colorScheme;

    if (hasCheckedOut) {
      return Card(
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: colorScheme.onPrimary),
              SizedBox(width: 8),
              Text(
                'Attendance Complete',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : (hasCheckedIn ? _checkOut : _checkIn),
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(hasCheckedIn ? Icons.logout : Icons.login),
        label: Text(hasCheckedIn ? 'Check Out' : 'Check In'),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasCheckedIn ? Colors.red : Colors.green,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }

  Future<void> _checkIn() async {
    setState(() => _isProcessing = true);
    try {
      final auth = context.read<AuthProvider>();
      final service = context.read<AttendanceService>();

      await service.checkIn(employeeId: auth.currentUser!.id);
      await _loadTodayStatus();

      if (mounted) {
        AppToast.showSuccess(context, 'Checked in successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _checkOut() async {
    setState(() => _isProcessing = true);
    try {
      final auth = context.read<AuthProvider>();
      final service = context.read<AttendanceService>();

      await service.checkOut(employeeId: auth.currentUser!.id);
      await _loadTodayStatus();

      if (mounted) {
        AppToast.showSuccess(context, 'Checked out successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
