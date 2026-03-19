import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_service.dart';
import '../models/attendance_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../services/sync_manager.dart';

import 'package:intl/intl.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class AttendanceReportScreen extends StatefulWidget {
  final String? employeeId;

  const AttendanceReportScreen({super.key, this.employeeId});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  AttendanceSummary? _summary;
  List<Attendance> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final service = context.read<AttendanceService>();
    final empId = widget.employeeId ?? auth.currentUser?.id;

    if (empId != null) {
      final summary = await service.getMonthlySummary(
        empId,
        _selectedMonth,
        _selectedYear,
      );
      final startDate = DateTime(_selectedYear, _selectedMonth, 1);
      final endDate = DateTime(_selectedYear, _selectedMonth + 1, 0);
      final records = await service.getAttendanceByDateRange(
        empId,
        startDate,
        endDate,
      );

      setState(() {
        _summary = summary;
        _records = records;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync & Refresh',
            onPressed: () async {
              final sync = context.read<AppSyncCoordinator>();
              final user = context.read<AuthProvider>().currentUser;
              if (user != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing data from cloud...')),
                );
                await sync.syncAll(user, forceRefresh: true);
              }
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthSelector(),
                if (_summary != null) _buildSummaryCard(),
                Expanded(child: _buildRecordsList()),
              ],
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  if (_selectedMonth == 1) {
                    _selectedMonth = 12;
                    _selectedYear--;
                  } else {
                    _selectedMonth--;
                  }
                });
                _loadData();
              },
            ),
            Text(
              '${_getMonthName(_selectedMonth)} $_selectedYear',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final now = DateTime.now();
                if (_selectedYear < now.year ||
                    (_selectedYear == now.year && _selectedMonth < now.month)) {
                  setState(() {
                    if (_selectedMonth == 12) {
                      _selectedMonth = 1;
                      _selectedYear++;
                    } else {
                      _selectedMonth++;
                    }
                  });
                  _loadData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${_summary!.attendancePercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: _summary!.attendancePercentage >= 80
                    ? Colors.green
                    : _summary!.attendancePercentage >= 60
                    ? Colors.orange
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('Attendance Rate'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statChip('Present', _summary!.presentDays, Colors.green),
                _statChip('Late', _summary!.lateDays, Colors.orange),
                _statChip('Half', _summary!.halfDays, Colors.blue),
                _statChip('Leave', _summary!.leaveDays, Colors.purple),
                _statChip('Absent', _summary!.absentDays, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return const Center(child: Text('No attendance records this month'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _records.length,
      itemBuilder: (ctx, i) => _buildRecordTile(_records[i]),
    );
  }

  Widget _buildRecordTile(Attendance record) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        onTap: () => _showCorrectionDialog(record),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(
            record.status,
          ).withValues(alpha: 0.2),
          child: Text('${record.date.day}'),
        ),
        title: Text(
          '${_getDayName(record.date.weekday)}, ${record.date.day} ${_getMonthName(record.date.month)}',
        ),
        subtitle: Text(
          record.checkInTime != null
              ? 'In: ${_formatTime(record.checkInTime!)} - Out: ${record.checkOutTime != null ? _formatTime(record.checkOutTime!) : "--"}'
              : 'No check-in',
        ),
        trailing: Chip(
          label: Text(record.status, style: const TextStyle(fontSize: 11)),
          backgroundColor: _getStatusColor(
            record.status,
          ).withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Future<void> _showCorrectionDialog(Attendance record) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null || !user.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only Admins can correct attendance')),
      );
      return;
    }

    final service = context.read<AttendanceService>();
    String selectedStatus = record.status;
    final remarksController = TextEditingController(text: record.remarks);

    await showDialog(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        title: Text(
          'Correct Attendance - ${DateFormat('dd MMM').format(record.date)}',
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Present', 'Absent', 'Late', 'HalfDay', 'OnLeave']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedStatus = val);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Reason)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await service.correctDailyAttendance(
                  employeeId: record.employeeId,
                  date: record.date,
                  status: selectedStatus,
                  remarks: remarksController.text,
                  userId: user.id,
                  userName: user.name,
                );

                if (!ctx.mounted) return;
                Navigator.pop(ctx);

                if (!mounted) return;
                _loadData(); // Refresh list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance corrected')),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'HalfDay':
        return Colors.blue;
      case 'OnLeave':
        return Colors.purple;
      case 'Absent':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

