import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/leave_service.dart';
import '../models/leave_request_model.dart';
import '../../../utils/app_toast.dart';

class LeaveHistoryScreen extends StatefulWidget {
  final String employeeId;

  const LeaveHistoryScreen({super.key, required this.employeeId});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  List<LeaveRequest> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final service = context.read<LeaveService>();
      final history = await service.getLeaveHistory(widget.employeeId);
      if (!mounted) return;
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.showError(context, 'Failed to load leave history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Leave History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(child: Text('No leave records'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _history.length,
              itemBuilder: (ctx, i) => _buildHistoryTile(_history[i]),
            ),
    );
  }

  Widget _buildHistoryTile(LeaveRequest req) {
    final dateRange =
        '${req.startDate.day}/${req.startDate.month}/${req.startDate.year} - ${req.endDate.day}/${req.endDate.month}/${req.endDate.year}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(req.status).withValues(alpha: 0.2),
          child: Icon(
            _getStatusIcon(req.status),
            color: _getStatusColor(req.status),
          ),
        ),
        title: Text('${req.leaveType} - ${req.totalDays} days'),
        subtitle: Text(dateRange),
        trailing: Chip(
          label: Text(req.status),
          backgroundColor: _getStatusColor(req.status).withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }
}
