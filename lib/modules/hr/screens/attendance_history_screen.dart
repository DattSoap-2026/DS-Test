import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/duty_service.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  late Stream<List<DutySession>> _sessionsStream;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _sessionsStream = context.read<DutyService>().subscribeToDateDutySessions(
      dateStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _updateStream();
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('EEE, dd MMM yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedDate = DateTime.now();
                    _updateStream();
                  }),
                  child: const Text('Today'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DutySession>>(
              stream: _sessionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final sessions = snapshot.data ?? [];
                if (sessions.isEmpty) {
                  return const Center(child: Text('No logs for this date'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final s = sessions[index];
                    final duration = s.logoutTime != null
                        ? DateTime.parse(
                            s.logoutTime!,
                          ).difference(DateTime.parse(s.loginTime))
                        : null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: _buildStatusIndicator(s.status),
                        title: Text(
                          s.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login: ${DateFormat('HH:mm').format(DateTime.parse(s.loginTime))}',
                            ),
                            if (s.logoutTime != null)
                              Text(
                                'Logout: ${DateFormat('HH:mm').format(DateTime.parse(s.logoutTime!))}',
                              ),
                            if (duration != null)
                              Text(
                                'Duration: ${duration.inHours}h ${duration.inMinutes % 60}m',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        trailing: s.status == 'active'
                            ? const Icon(
                                Icons.online_prediction,
                                color: Colors.green,
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color = Theme.of(context).colorScheme.onSurfaceVariant;
    if (status == 'active') color = Colors.green;
    if (status == 'completed') color = Colors.blue;

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
