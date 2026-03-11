import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/leave_service.dart';
import '../models/leave_request_model.dart';
import '../../../utils/app_toast.dart';

class LeaveRequestScreen extends StatefulWidget {
  final String employeeId;

  const LeaveRequestScreen({super.key, required this.employeeId});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = 'Casual';
  late final List<String> _leaveTypes;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  LeaveBalance? _balance;
  LeaveDayBreakdown? _dayBreakdown;
  bool _isBreakdownLoading = false;

  bool get _canSubmit {
    final fallbackDays = _endDate.difference(_startDate).inDays + 1;
    final chargeableDays = _dayBreakdown?.chargeableDays ?? fallbackDays;
    return !_isLoading && !_isBreakdownLoading && chargeableDays > 0;
  }

  @override
  void initState() {
    super.initState();
    _leaveTypes = context.read<LeaveService>().supportedLeaveTypes;
    if (_leaveTypes.isNotEmpty && !_leaveTypes.contains(_leaveType)) {
      _leaveType = _leaveTypes.first;
    }
    _loadBalance();
    _loadDayBreakdown();
  }

  Future<void> _loadBalance() async {
    final service = context.read<LeaveService>();
    final balance = await service.getLeaveBalance(widget.employeeId);
    if (!mounted) return;
    setState(() => _balance = balance);
  }

  Future<void> _loadDayBreakdown() async {
    setState(() => _isBreakdownLoading = true);
    try {
      final service = context.read<LeaveService>();
      final breakdown = await service.getLeaveDayBreakdown(
        employeeId: widget.employeeId,
        leaveType: _leaveType,
        startDate: _startDate,
        endDate: _endDate,
      );
      if (!mounted) return;
      setState(() => _dayBreakdown = breakdown);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dayBreakdown = null);
    } finally {
      if (mounted) setState(() => _isBreakdownLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_balance != null) _buildBalanceCard(),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _leaveType,
                decoration: const InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(),
                ),
                items: _leaveTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _leaveType = v);
                  _loadDayBreakdown();
                },
              ),
              const SizedBox(height: 16),
              _buildDatePicker('Start Date', _startDate, (d) {
                setState(() {
                  _startDate = d;
                  if (_endDate.isBefore(_startDate)) _endDate = _startDate;
                });
                _loadDayBreakdown();
              }, firstDate: DateTime.now()),
              const SizedBox(height: 16),
              _buildDatePicker('End Date', _endDate, (d) {
                setState(() => _endDate = d);
                _loadDayBreakdown();
              }, firstDate: _startDate),
              const SizedBox(height: 8),
              Text(
                'Chargeable Days: ${_dayBreakdown?.chargeableDays ?? (_endDate.difference(_startDate).inDays + 1)} | Calendar Days: ${_dayBreakdown?.calendarDays ?? (_endDate.difference(_startDate).inDays + 1)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_isBreakdownLoading) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 12),
              _buildPolicyHintCard(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submitRequest : null,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyHintCard() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Policy: Casual 8/year, Sick 8/year (company), Earned leave accrual as per worked days, Maternity up to 26 weeks.',
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Balance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _balanceChip('Casual', _balance!.remainingCasual, Colors.blue),
                _balanceChip('Sick', _balance!.remainingSick, Colors.orange),
                _balanceChip('Earned', _balance!.remainingEarned, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceChip(String label, int count, Color color) {
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
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onPicked,
    {
    required DateTime firstDate,
    }
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${date.day}/${date.month}/${date.year}'),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isBreakdownLoading) {
      AppToast.showError(
        context,
        'Please wait while leave day calculation completes.',
      );
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      AppToast.showError(context, 'End date cannot be before start date.');
      return;
    }
    final chargeableDays =
        _dayBreakdown?.chargeableDays ??
        (_endDate.difference(_startDate).inDays + 1);
    if (chargeableDays <= 0) {
      AppToast.showError(
        context,
        'Selected date range contains only weekly off days.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = context.read<LeaveService>();
      final reason = _reasonController.text.trim();
      await service.applyLeave(
        employeeId: widget.employeeId,
        leaveType: _leaveType,
        startDate: _startDate,
        endDate: _endDate,
        reason: reason.isEmpty ? null : reason,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Leave request submitted!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
