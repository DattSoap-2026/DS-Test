import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/leave_service.dart';
import '../models/leave_request_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../utils/app_toast.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  List<LeaveRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final service = context.read<LeaveService>();
      final requests = await service.getPendingRequests();
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to load leave requests: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Approvals'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRequests),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? const Center(child: Text('No pending requests'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _requests.length,
              itemBuilder: (ctx, i) => _buildRequestCard(_requests[i]),
            ),
    );
  }

  Widget _buildRequestCard(LeaveRequest req) {
    final days = req.totalDays;
    final dateRange =
        '${req.startDate.day}/${req.startDate.month} - ${req.endDate.day}/${req.endDate.month}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  req.employeeName ?? 'Employee',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(req.leaveType),
                  backgroundColor: _getLeaveTypeColor(req.leaveType),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text('$dateRange ($days days)'),
              ],
            ),
            if (req.reason != null && req.reason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Reason: ${req.reason}'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _showRejectDialog(req),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _approveRequest(req),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLeaveTypeColor(String type) {
    switch (type) {
      case 'Sick':
        return Colors.orange.shade100;
      case 'Casual':
        return Colors.blue.shade100;
      case 'Earned':
        return Colors.green.shade100;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Future<void> _approveRequest(LeaveRequest req) async {
    try {
      final service = context.read<LeaveService>();
      final authProvider = context.read<AuthProvider>();
      final approverName = authProvider.currentUser?.name ?? 'Manager';

      await service.approveLeave(req.id, approverName);
      await _loadRequests();
      if (mounted) {
        AppToast.showSuccess(context, 'Leave approved');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to approve leave: $e');
      }
    }
  }

  Future<void> _showRejectDialog(LeaveRequest req) async {
    final reasonController = TextEditingController();
    final service = context.read<LeaveService>();
    final authProvider = context.read<AuthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        title: const Text('Reject Leave'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final reason = reasonController.text.trim();
      if (reason.isEmpty) {
        if (mounted) {
          AppToast.showError(context, 'Rejection reason is required');
        }
        reasonController.dispose();
        return;
      }
      try {
        await service.rejectLeave(
          req.id,
          authProvider.currentUser?.name ?? 'Manager',
          reason,
        );
        await _loadRequests();
        if (mounted) {
          AppToast.showSuccess(context, 'Leave rejected');
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, 'Failed to reject leave: $e');
        }
      }
    }
    reasonController.dispose();
  }
}
