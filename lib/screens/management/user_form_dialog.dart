import 'package:flutter/material.dart';
import '../../models/types/user_types.dart';
import '../../services/settings_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class UserFormDialog extends StatefulWidget {
  final AppUser? user;
  final List<String> allRoutes;
  final List<OrgDepartment> allDepartments;

  const UserFormDialog({
    super.key,
    this.user,
    required this.allRoutes,
    required this.allDepartments,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late UserRole _role;
  String? _department;
  late String _status;
  late List<String> _assignedRoutes;
  String? _assignedBhatti;
  late List<UserDepartment> _userDepartments;
  late final List<OrgDepartment> _effectiveDepartments;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _role = widget.user?.role ?? UserRole.salesman;
    _effectiveDepartments = _buildEffectiveDepartments(widget.allDepartments);

    // Validate department using case-insensitive code matching.
    final byUpperCode = <String, String>{
      for (final dept in _effectiveDepartments)
        dept.code.trim().toUpperCase(): dept.code,
    };
    final userDept = widget.user?.department?.trim();
    if (userDept != null && userDept.isNotEmpty) {
      _department = byUpperCode[userDept.toUpperCase()];
    } else {
      _department = null;
    }
    if (_role == UserRole.accountant &&
        (_department == null || _department!.isEmpty)) {
      _department = _defaultAccountingDepartmentCode();
    }

    _status = widget.user?.status ?? 'active';
    _assignedRoutes = List<String>.from(widget.user?.assignedRoutes ?? []);

    // Validate bhatti assignment
    const validBhattis = ['Sona', 'Gita'];
    _assignedBhatti = validBhattis.contains(widget.user?.assignedBhatti)
        ? widget.user?.assignedBhatti
        : null;

    _userDepartments = List<UserDepartment>.from(
      widget.user?.departments ?? [],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'role': _role.value,
        'department': _department,
        'status': _status,
        'assignedRoutes': _role == UserRole.salesman ? _assignedRoutes : [],
        'assignedBhatti': _role == UserRole.bhattiSupervisor
            ? _assignedBhatti
            : null,
        'departments': _userDepartments.map((d) => d.toJson()).toList(),
      };

      Navigator.pop(context, userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ResponsiveAlertDialog(
      title: Text(widget.user == null ? 'Add New User' : 'Edit User'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.clamp(context, min: 320, max: 520, ratio: 0.9),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'System Role *',
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: UserRole.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            r.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _role = v;
                      if (_role == UserRole.accountant &&
                          (_department == null || _department!.isEmpty)) {
                        _department = _defaultAccountingDepartmentCode();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _department,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(
                        'None',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ..._effectiveDepartments.map(
                      (d) => DropdownMenuItem(
                        value: d.code,
                        child: Text(
                          d.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _department = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Account Status *',
                    prefixIcon: Icon(Icons.toggle_on),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Assignments & Permissions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),

                if (_role == UserRole.salesman) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Assigned Routes (Salesman only)',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  _buildRouteSelector(),
                ],

                if (_role == UserRole.bhattiSupervisor) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _assignedBhatti,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Bhatti',
                      prefixIcon: Icon(Icons.local_fire_department),
                    ),
                    items: ['Sona', 'Gita']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setState(() => _assignedBhatti = v),
                  ),
                ],

                const SizedBox(height: 16),
                Text(
                  'Departments',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                _buildDepartmentSection(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text(widget.user == null ? 'Create User' : 'Save Changes'),
        ),
      ],
    );
  }

  Widget _buildRouteSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_assignedRoutes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No routes assigned',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _assignedRoutes
                      .map(
                        (r) => Chip(
                          label: Text(r, style: const TextStyle(fontSize: 10)),
                          onDeleted: () =>
                              setState(() => _assignedRoutes.remove(r)),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            title: const Text('Select Routes', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.add_circle_outline, size: 20),
            onTap: () => _showMultiSelectDialog(
              title: 'Select Routes',
              options: widget.allRoutes,
              initialSelection: _assignedRoutes,
              onChanged: (selected) =>
                  setState(() => _assignedRoutes = selected),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        ..._userDepartments.asMap().entries.map((entry) {
          final idx = entry.key;
          final userDept = entry.value;
          return Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              dense: true,
              title: Text(
                userDept.main.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(userDept.team ?? 'No Team Selected'),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () => setState(() => _userDepartments.removeAt(idx)),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _showAddDepartmentDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Department'),
        ),
      ],
    );
  }

  void _showAddDepartmentDialog() {
    String? selectedMain;
    String? selectedTeam;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ResponsiveAlertDialog(
          title: const Text('Assign Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedMain,
                isExpanded: true,
                hint: const Text('Select Department'),
                items: _effectiveDepartments
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.code,
                        child: Text(
                          d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setDialogState(() {
                    selectedMain = v;
                    selectedTeam = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (selectedMain != null)
                DropdownButtonFormField<String>(
                  initialValue: selectedTeam,
                  isExpanded: true,
                  hint: const Text('Select Team (Optional)'),
                  items:
                      (_effectiveDepartments
                                  .cast<OrgDepartment?>()
                                  .firstWhere(
                                    (d) => d?.code == selectedMain,
                                    orElse: () => null,
                                  )
                                  ?.teams ??
                              const <DeptTeam>[])
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.code,
                              child: Text(
                                t.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setDialogState(() => selectedTeam = v),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedMain == null
                  ? null
                  : () {
                      setState(() {
                        _userDepartments.add(
                          UserDepartment(
                            main: selectedMain!,
                            team: selectedTeam,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog({
    required String title,
    required List<String> options,
    required List<String> initialSelection,
    required Function(List<String>) onChanged,
  }) {
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No routes available')),
      );
      return;
    }

    final sortedOptions = List<String>.from(options)..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    List<String> tempSelection = List.from(initialSelection);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredOptions = searchQuery.isEmpty
              ? sortedOptions
              : sortedOptions.where((opt) => opt.toLowerCase().contains(searchQuery.toLowerCase())).toList();

          return ResponsiveAlertDialog(
            title: Text(title),
            content: SizedBox(
              width: Responsive.clamp(context, min: 280, max: 360, ratio: 0.75),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search routes...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      isDense: true,
                    ),
                    onChanged: (val) => setDialogState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredOptions.isEmpty
                        ? Center(
                            child: Text(
                              'No routes found',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredOptions.length,
                            itemBuilder: (context, index) {
                              final opt = filteredOptions[index];
                              return CheckboxListTile(
                                title: Text(opt),
                                value: tempSelection.contains(opt),
                                dense: true,
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      tempSelection.add(opt);
                                    } else {
                                      tempSelection.remove(opt);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  onChanged(tempSelection);
                  Navigator.pop(context);
                },
                child: Text('Apply (${tempSelection.length})'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<OrgDepartment> _buildEffectiveDepartments(
    List<OrgDepartment> departments,
  ) {
    final byCode = <String, OrgDepartment>{};
    for (final dept in departments) {
      final code = dept.code.trim().toUpperCase();
      if (code.isEmpty) continue;
      byCode.putIfAbsent(code, () => dept);
    }

    final hasAccountingFamily = byCode.keys.any(
      (code) => code == 'ACCOUNTS' || code == 'ACCOUNTING' || code == 'FINANCE',
    );
    if (!hasAccountingFamily) {
      final now = DateTime.now().toIso8601String();
      byCode['ACCOUNTS'] = OrgDepartment(
        id: 'system_accounts',
        code: 'ACCOUNTS',
        name: 'Accounts',
        createdAt: now,
        updatedAt: now,
      );
    }

    final result = byCode.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  String? _defaultAccountingDepartmentCode() {
    for (final code in const ['ACCOUNTS', 'ACCOUNTING', 'FINANCE']) {
      final match = _effectiveDepartments.firstWhere(
        (dept) => dept.code.trim().toUpperCase() == code,
        orElse: () => OrgDepartment(
          id: '',
          code: '',
          name: '',
          createdAt: '',
          updatedAt: '',
        ),
      );
      if (match.code.isNotEmpty) return match.code;
    }
    return null;
  }
}
