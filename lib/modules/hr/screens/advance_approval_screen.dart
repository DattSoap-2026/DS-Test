import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/advance_service.dart';
import '../models/advance_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../utils/app_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class AdvanceApprovalScreen extends StatefulWidget {
  const AdvanceApprovalScreen({super.key});

  @override
  State<AdvanceApprovalScreen> createState() => _AdvanceApprovalScreenState();
}

class _AdvanceApprovalScreenState extends State<AdvanceApprovalScreen> {
  List<Advance> _requests = [];
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
      final service = context.read<AdvanceService>();
      final requests = await service.getPendingRequests();
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to load advance requests: $e');
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
        title: const Text('Advance Approvals'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('hr_advance_request'),
        tooltip: 'Add New Request',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRequestCard(Advance req) {
    final isLoan = req.type == 'Loan';

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
                  label: Text(req.type),
                  backgroundColor: isLoan
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rs. ${req.amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (isLoan && req.emiMonths != null) ...[
              const SizedBox(height: 4),
              Text(
                'EMI: Rs. ${req.emiAmount?.toStringAsFixed(0)} x ${req.emiMonths} months',
              ),
            ],
            if (req.purpose != null && req.purpose!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Purpose: ${req.purpose}'),
            ],
            const SizedBox(height: 8),
            Text(
              'Requested: ${req.requestDate.day}/${req.requestDate.month}/${req.requestDate.year}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
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
                  onPressed: () => _approve(req),
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

  Future<void> _approve(Advance req) async {
    try {
      final service = context.read<AdvanceService>();
      final auth = context.read<AuthProvider>();

      await service.approveAdvance(req.id, auth.currentUser?.name ?? 'Manager');
      await _loadRequests();
      if (mounted) {
        AppToast.showSuccess(context, 'Approved');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to approve request: $e');
      }
    }
  }

  Future<void> _showRejectDialog(Advance req) async {
    final reasonController = TextEditingController();
    final service = context.read<AdvanceService>();
    final auth = context.read<AuthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason',
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
        await service.rejectAdvance(
          req.id,
          auth.currentUser?.name ?? 'Manager',
          reason,
        );
        await _loadRequests();
        if (mounted) {
          AppToast.showSuccess(context, 'Rejected');
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, 'Failed to reject request: $e');
        }
      }
    }
    reasonController.dispose();
  }
}
