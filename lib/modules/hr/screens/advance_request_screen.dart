import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/advance_service.dart';
import '../services/hr_service.dart';
import '../models/advance_model.dart';
import '../models/employee_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../utils/app_toast.dart';
import '../../../widgets/ui/themed_segment_control.dart';

class AdvanceRequestScreen extends StatefulWidget {
  final String? employeeId;
  const AdvanceRequestScreen({super.key, this.employeeId});

  @override
  State<AdvanceRequestScreen> createState() => _AdvanceRequestScreenState();
}

class _AdvanceRequestScreenState extends State<AdvanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _emiController = TextEditingController();

  String _type = 'Advance';
  bool _isLoading = false;
  AdvanceSummary? _summary;
  String? _selectedEmployeeId;
  List<Employee> _employees = [];
  bool _isLoadingEmployees = false;

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId = widget.employeeId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final hrService = context.read<HrService>();
    
    // Load employees if we need to select one
    if (widget.employeeId == null) {
      setState(() => _isLoadingEmployees = true);
      try {
        _employees = await hrService.getAllEmployees();
      } catch (e) {
        debugPrint('Error loading employees: $e');
      } finally {
        if (mounted) setState(() => _isLoadingEmployees = false);
      }
    }

    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final auth = context.read<AuthProvider>();
    final service = context.read<AdvanceService>();

    final targetId = _selectedEmployeeId ?? auth.currentUser?.id;

    if (targetId != null) {
      try {
        final summary = await service.getAdvanceSummary(targetId);
        if (mounted) setState(() => _summary = summary);
      } catch (e) {
        debugPrint('Error loading summary: $e');
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _emiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Advance/Loan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.employeeId == null) _buildEmployeeSelector(),
              const SizedBox(height: 16),
              if (_summary != null) _buildSummaryCard(),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  if (double.tryParse(v) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_type == 'Loan') ...[
                TextFormField(
                  controller: _emiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'EMI Months',
                    hintText: 'Number of installments',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (_type == 'Loan' && (v == null || v.isEmpty)) {
                      return 'Enter EMI months';
                    }
                    if (_type == 'Loan' && int.tryParse(v!) == null) {
                      return 'Invalid months';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  hintText: 'Reason for request',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
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

  Widget _buildEmployeeSelector() {
    if (_isLoadingEmployees) {
      return const Center(child: LinearProgressIndicator());
    }
    return DropdownButtonFormField<String>(
      initialValue: _selectedEmployeeId,
      decoration: const InputDecoration(
        labelText: 'Select Employee',
        border: OutlineInputBorder(),
      ),
      items: _employees.map((emp) {
        return DropdownMenuItem(
          value: emp.employeeId,
          child: Text('${emp.name} (${emp.employeeId})'),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedEmployeeId = val;
          _summary = null;
        });
        _loadSummary();
      },
      validator: (v) => v == null ? 'Please select an employee' : null,
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Outstanding',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  'Advances',
                  _summary!.activeAdvances,
                  '₹${_summary!.totalAdvances.toStringAsFixed(0)}',
                ),
                _statItem(
                  'Loans',
                  _summary!.activeLoans,
                  '₹${_summary!.totalLoans.toStringAsFixed(0)}',
                ),
                _statItem(
                  'Outstanding',
                  0,
                  '₹${_summary!.totalOutstanding.toStringAsFixed(0)}',
                  highlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
    String label,
    int count,
    String amount, {
    bool highlight = false,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        if (count > 0) Text('($count)', style: const TextStyle(fontSize: 10)),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return ThemedSegmentControl<String>(
      selected: {_type},
      onSelectionChanged: (s) => setState(() => _type = s.first),
      segments: const [
        ButtonSegment(value: 'Advance', label: Text('Advance')),
        ButtonSegment(value: 'Loan', label: Text('Loan')),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployeeId == null) {
      AppToast.showError(context, 'Please select an employee');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = context.read<AdvanceService>();

      await service.requestAdvance(
        employeeId: _selectedEmployeeId!,
        type: _type,
        amount: double.parse(_amountController.text),
        purpose: _purposeController.text.isNotEmpty
            ? _purposeController.text
            : null,
        emiMonths: _type == 'Loan' ? int.tryParse(_emiController.text) : null,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Request submitted successfully');
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
}
