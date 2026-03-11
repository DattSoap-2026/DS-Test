import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/advance_service.dart';
import '../models/advance_model.dart';
import '../../../providers/auth/auth_provider.dart';

class AdvanceHistoryScreen extends StatefulWidget {
  final String? employeeId;

  const AdvanceHistoryScreen({super.key, this.employeeId});

  @override
  State<AdvanceHistoryScreen> createState() => _AdvanceHistoryScreenState();
}

class _AdvanceHistoryScreenState extends State<AdvanceHistoryScreen> {
  List<Advance> _advances = [];
  AdvanceSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final service = context.read<AdvanceService>();
    final empId = widget.employeeId ?? auth.currentUser?.id;

    if (empId != null) {
      final history = await service.getAdvanceHistory(empId);
      final summary = await service.getAdvanceSummary(empId);

      setState(() {
        _advances = history;
        _summary = summary;
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
        title: const Text('Advance History'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_summary != null) _buildSummaryCard(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statColumn(
              'Outstanding',
              '₹${_summary!.totalOutstanding.toStringAsFixed(0)}',
              Colors.red,
            ),
            _statColumn(
              'Active',
              '${_summary!.activeAdvances + _summary!.activeLoans}',
              Colors.orange,
            ),
            _statColumn(
              'Total',
              '₹${(_summary!.totalAdvances + _summary!.totalLoans).toStringAsFixed(0)}',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildList() {
    if (_advances.isEmpty) {
      return const Center(child: Text('No advance history'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _advances.length,
      itemBuilder: (ctx, i) => _buildAdvanceCard(_advances[i]),
    );
  }

  Widget _buildAdvanceCard(Advance adv) {
    final statusColor = _getStatusColor(adv.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: adv.type == 'Loan'
              ? Colors.blue.shade100
              : Colors.green.shade100,
          child: Icon(
            adv.type == 'Loan' ? Icons.account_balance : Icons.money,
            color: adv.type == 'Loan' ? Colors.blue : Colors.green,
          ),
        ),
        title: Text('₹${adv.amount.toStringAsFixed(0)} (${adv.type})'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (adv.status == 'Active') ...[
              LinearProgressIndicator(
                value: adv.progressPercent / 100,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 4),
              Text('Remaining: ₹${adv.remainingAmount.toStringAsFixed(0)}'),
            ] else
              Text(
                '${adv.requestDate.day}/${adv.requestDate.month}/${adv.requestDate.year}',
              ),
          ],
        ),
        trailing: Chip(
          label: Text(adv.status, style: const TextStyle(fontSize: 11)),
          backgroundColor: statusColor.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
      case 'Active':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Cleared':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}
