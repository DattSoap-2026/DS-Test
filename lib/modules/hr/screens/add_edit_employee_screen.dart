import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hr_service.dart';
import '../models/employee_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/local/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_toast.dart';
import '../../../services/settings_service.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final String? employeeId;
  const AddEditEmployeeScreen({super.key, this.employeeId});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  late TabController _tabController;
  int _currentStep = 0;

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _salaryController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _bankDetailsController = TextEditingController();
  final _otMultiplierController = TextEditingController(text: '1.0');
  DateTime _joiningDate = DateTime.now();
  DateTime? _exitDate;

  String _roleType = 'worker';
  String _paymentMethod = 'Bank Transfer';
  String? _linkedUserId;
  String? _selectedDepartment;
  bool _isActive = true;
  int _weeklyOffDay = DateTime.sunday;

  TimeOfDay _shiftStartTime = const TimeOfDay(hour: 9, minute: 0);

  List<UserEntity> _availableUsers = [];
  List<OrgDepartment> _availableDepartments = [];
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentStep = _tabController.index);
    });
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _idController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _salaryController.dispose();
    _hourlyRateController.dispose();
    _bankDetailsController.dispose();
    _otMultiplierController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final userRepo = context.read<UserRepository>();
      final settingsService = context.read<SettingsService>();
      final results = await Future.wait([
        userRepo.getAllUsers(),
        settingsService.getDepartments(),
      ]);
      _availableUsers = results[0] as List<UserEntity>;
      _availableDepartments =
          (results[1] as List<OrgDepartment>)
              .where((d) => d.isActive)
              .toList();

      if (!mounted) return;

      if (widget.employeeId != null) {
        final hrService = context.read<HrService>();
        final emp = await hrService.getEmployee(widget.employeeId!);
        if (!mounted) return;
        if (emp != null) {
          _idController.text = emp.employeeId;
          _nameController.text = emp.name;
          _selectedDepartment = emp.department.isNotEmpty ? emp.department : null;
          _mobileController.text = emp.mobile;
          _roleType = emp.roleType;
          _linkedUserId = emp.linkedUserId;
          _isActive = emp.isActive;
          _salaryController.text = emp.baseMonthlySalary?.toString() ?? '';
          _hourlyRateController.text = emp.hourlyRate?.toString() ?? '';
          _paymentMethod = emp.paymentMethod ?? 'Bank Transfer';
          _bankDetailsController.text = emp.bankDetails ?? '';
          _weeklyOffDay = emp.weeklyOffDay;
          _createdAt = emp.createdAt;
          _shiftStartTime = TimeOfDay(
            hour: emp.shiftStartHour,
            minute: emp.shiftStartMinute,
          );
          _joiningDate = emp.joiningDate;
          _exitDate = emp.exitDate;
          _otMultiplierController.text = emp.overtimeMultiplier.toString();
        }
      } else {
        _idController.text =
            'EMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        _createdAt = DateTime.now();
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectShiftTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _shiftStartTime,
    );
    if (picked != null) {
      setState(() => _shiftStartTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final hrService = context.read<HrService>();
      final employee = Employee(
        employeeId: _idController.text.trim(),
        name: _nameController.text.trim(),
        roleType: _roleType,
        linkedUserId: _linkedUserId,
        department: (_selectedDepartment ?? '').trim(),
        mobile: _mobileController.text.trim(),
        isActive: _isActive,
        createdAt: _createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        baseMonthlySalary: double.tryParse(_salaryController.text.trim()),
        hourlyRate: double.tryParse(_hourlyRateController.text.trim()),
        paymentMethod: _paymentMethod,
        bankDetails: _bankDetailsController.text.trim(),
        weeklyOffDay: _weeklyOffDay,
        shiftStartHour: _shiftStartTime.hour,
        shiftStartMinute: _shiftStartTime.minute,
        joiningDate: _joiningDate,
        exitDate: _exitDate,
        overtimeMultiplier: double.tryParse(_otMultiplierController.text) ?? 1.0,
      );

      if (widget.employeeId == null) {
        await hrService.createEmployee(employee);
      } else {
        await hrService.updateEmployee(employee);
      }

      if (mounted) {
        AppToast.showSuccess(context, 'Employee saved successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error saving employee: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.employeeId == null ? 'Add New Employee' : 'Edit Employee',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Basic Info'),
            Tab(icon: Icon(Icons.work), text: 'Work Details'),
            Tab(icon: Icon(Icons.payments), text: 'Payroll'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildWorkDetailsTab(),
            _buildPayrollTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _tabController.animateTo(_currentStep - 1),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleNext,
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text(_currentStep == 2 ? 'SAVE' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        _tabController.animateTo(_currentStep + 1);
      }
    } else {
      _save();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _idController.text.isNotEmpty && _nameController.text.isNotEmpty;
      case 1:
        return _selectedDepartment != null && _selectedDepartment!.isNotEmpty;
      default:
        return true;
    }
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _idController,
            decoration: const InputDecoration(
              labelText: 'Employee ID',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
            enabled: widget.employeeId == null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobileController,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _linkedUserId,
            decoration: const InputDecoration(
              labelText: 'Link User Account (Optional)',
              helperText: 'Links this employee to a system login',
              prefixIcon: Icon(Icons.link),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              ..._availableUsers.map(
                (u) => DropdownMenuItem(
                  value: u.id,
                  child: Text('${u.name} (${u.role})'),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _linkedUserId = v),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Is Active'),
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _roleType,
            decoration: const InputDecoration(
              labelText: 'Role Type',
              prefixIcon: Icon(Icons.work),
            ),
            items: [
              'worker',
              'helper',
              'driver',
              'security_guard',
              'office_staff',
              'salesman',
            ]
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _roleType = v!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.business),
            ),
            hint: const Text('Select Department'),
            items: [
              ..._availableDepartments.map(
                (d) => DropdownMenuItem(
                  value: d.name,
                  child: Text(d.name),
                ),
              ),
              if (_selectedDepartment != null &&
                  _selectedDepartment!.isNotEmpty &&
                  !_availableDepartments.any(
                    (d) => d.name == _selectedDepartment,
                  ))
                DropdownMenuItem(
                  value: _selectedDepartment,
                  child: Text(_selectedDepartment!),
                ),
            ],
            onChanged: (v) => setState(() => _selectedDepartment = v),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _weeklyOffDay,
            decoration: const InputDecoration(
              labelText: 'Weekly Off Day',
              helperText: 'Auto-marked as Weekly Off in attendance',
              prefixIcon: Icon(Icons.event_busy),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Monday')),
              DropdownMenuItem(value: 2, child: Text('Tuesday')),
              DropdownMenuItem(value: 3, child: Text('Wednesday')),
              DropdownMenuItem(value: 4, child: Text('Thursday')),
              DropdownMenuItem(value: 5, child: Text('Friday')),
              DropdownMenuItem(value: 6, child: Text('Saturday')),
              DropdownMenuItem(value: 7, child: Text('Sunday')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _weeklyOffDay = v);
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Shift Start Time'),
            subtitle: Text(_shiftStartTime.format(context)),
            leading: const Icon(Icons.access_time),
            trailing: const Icon(Icons.edit),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: _selectShiftTime,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Joining Date'),
            subtitle: Text(_joiningDate.toString().split(' ')[0]),
            leading: const Icon(Icons.calendar_today),
            trailing: const Icon(Icons.edit),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _joiningDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _joiningDate = picked);
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Exit Date (Optional)'),
            subtitle: Text(_exitDate?.toString().split(' ')[0] ?? 'Not Set'),
            leading: const Icon(Icons.exit_to_app),
            trailing: const Icon(Icons.edit),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _exitDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _exitDate = picked);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _salaryController,
            decoration: const InputDecoration(
              labelText: 'Base Monthly Salary (Optional)',
              prefixText: '₹ ',
              prefixIcon: Icon(Icons.currency_rupee),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _hourlyRateController,
            decoration: const InputDecoration(
              labelText: 'Hourly Rate',
              prefixText: '₹ ',
              helperText: 'For attendance calculation',
              prefixIcon: Icon(Icons.schedule),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _otMultiplierController,
            decoration: const InputDecoration(
              labelText: 'Overtime Multiplier',
              helperText: 'e.g., 1.0, 1.5, 2.0',
              prefixIcon: Icon(Icons.trending_up),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              prefixIcon: Icon(Icons.payment),
            ),
            items: ['Bank Transfer', 'Cash', 'Cheque']
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bankDetailsController,
            decoration: const InputDecoration(
              labelText: 'Bank Details / Notes',
              hintText: 'Account No, IFSC, or Payment instructions',
              prefixIcon: Icon(Icons.account_balance),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
