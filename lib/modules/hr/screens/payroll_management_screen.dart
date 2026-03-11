import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/payroll_service.dart';
import '../models/payroll_record_model.dart';
import '../services/hr_service.dart';
import '../../../services/reporting_service.dart';
import '../../../utils/app_toast.dart';

class PayrollManagementScreen extends StatefulWidget {
  const PayrollManagementScreen({super.key});

  @override
  State<PayrollManagementScreen> createState() =>
      _PayrollManagementScreenState();
}

class _PayrollManagementScreenState extends State<PayrollManagementScreen> {
  bool _isLoading = false;
  List<PayrollRecord> _payrolls = [];
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default to first day of current month
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);

    // Add post-frame callback to safely load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayrollData();
    });
  }

  Future<void> _loadPayrollData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final payrollService = context.read<PayrollService>();
      final records = await payrollService.getPayrolls(_selectedMonth);
      if (mounted) {
        setState(() {
          _payrolls = records;
        });
      }
    } catch (e) {
      debugPrint('Error loading payroll: $e');
      if (mounted) {
        AppToast.showError(context, 'Error loading data: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePayroll() async {
    setState(() => _isLoading = true);
    try {
      final payrollService = context.read<PayrollService>();
      await payrollService.generatePayrollForMonth(_selectedMonth);
      await _loadPayrollData(); // Reload
      if (mounted) {
        AppToast.showSuccess(context, 'Payroll generated successfully');
      }
    } catch (e) {
      debugPrint('Error generating payroll: $e');
      if (mounted) {
        AppToast.showError(context, 'Failed to generate payroll: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(PayrollRecord record, String newStatus) async {
    try {
      final payrollService = context.read<PayrollService>();
      await payrollService.updateStatus(record.id, newStatus);
      await _loadPayrollData(); // Refresh list
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Payroll'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Recalculate payroll',
            onPressed: _isLoading ? null : _generatePayroll,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPayrollData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthPicker(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payrolls.isEmpty
                ? _buildEmptyState()
                : _buildPayrollList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                  1,
                );
              });
              _loadPayrollData();
            },
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                  1,
                );
              });
              _loadPayrollData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No payroll records for ${DateFormat('MMMM').format(_selectedMonth)}',
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generatePayroll,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Payroll'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payrolls.length,
      itemBuilder: (context, index) {
        final record = _payrolls[index];
        return _buildPayrollCard(record);
      },
    );
  }

  Widget _buildPayrollCard(PayrollRecord record) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Status Color
    Color statusColor;
    if (record.status == 'Paid') {
      statusColor = Colors.green;
    } else if (record.status == 'Finalized') {
      statusColor = Colors.orange;
    } else {
      statusColor = colorScheme.onSurfaceVariant;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Show details dialog if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      record.employeeName.isNotEmpty
                          ? record.employeeName[0]
                          : '?',
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.employeeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                record.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${record.totalHours.toStringAsFixed(1)} Hrs',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Pay',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        'Rs. ${NumberFormat('#,##,##0.00').format(record.netSalary)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Actions
                      if (record.status == 'Draft')
                        TextButton(
                          onPressed: () => _updateStatus(record, 'Finalized'),
                          child: const Text('Finalize'),
                        ),
                      if (record.status == 'Finalized')
                        TextButton(
                          onPressed: () => _updateStatus(record, 'Paid'),
                          child: const Text('Mark Paid'),
                        ),

                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        tooltip: 'Download Payslip',
                        onPressed: () => _generatePayslip(record),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePayslip(PayrollRecord record) async {
    try {
      final reporting = context.read<ReportingService>();
      final hrService = context.read<HrService>();

      // Fetch real employee details
      final employee = await hrService.getEmployee(record.employeeId);

      if (employee == null) {
        if (mounted) {
          AppToast.showError(context, 'Employee details not found');
        }
        return;
      }

      final bytes = await reporting.generatePayslipPdf(
        employee: employee,
        month: DateFormat('yyyy-MM').parse(record.month),
        totalHours: record.totalHours,
        baseSalary: record.baseSalary,
        netSalary: record.netSalary,
        otHours: record.totalOvertimeHours,
        bonuses: record.bonuses,
        deductions: record.deductions,
      );
      await reporting.saveAndOpenPdf(
        bytes,
        'Payslip_${record.employeeId}_${record.month}.pdf',
      );
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to generate PDF: $e');
      }
    }
  }
}
