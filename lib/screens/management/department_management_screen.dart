import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class DepartmentManagementScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isReadOnly;
  const DepartmentManagementScreen({
    super.key,
    this.onBack,
    this.isReadOnly = false,
  });

  @override
  State<DepartmentManagementScreen> createState() =>
      _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState
    extends State<DepartmentManagementScreen> {
  late final SettingsService _settingsService;
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<OrgDepartment> _departments = [];

  void _showReadOnlyWarning() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Read-only mode: changes are disabled.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoading = true);
    try {
      final depts = await _settingsService.getDepartments();
      if (mounted) {
        setState(() {
          _departments = depts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showDepartmentDialog([OrgDepartment? dept]) {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    final codeController = TextEditingController(text: dept?.code ?? '');
    final nameController = TextEditingController(text: dept?.name ?? '');
    final descController = TextEditingController(text: dept?.description ?? '');
    bool isActive = dept?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ResponsiveAlertDialog(
          title: Text(dept == null ? 'Add Department' : 'Edit Department'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  enabled: dept == null,
                  decoration: const InputDecoration(
                    labelText: 'Code (e.g. production)',
                    helperText: 'Lowercase, no spaces',
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (val) => setDialogState(() => isActive = val),
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
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final user = context.read<AuthProvider>().state.user;
                      if (user == null) return;

                      final code = codeController.text.trim().toLowerCase();
                      if (code.isEmpty) return;

                      // Check for duplicates
                      if (dept == null) {
                        final exists = _departments.any((d) => d.code == code);
                        if (exists) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Department code already exists'),
                              ),
                            );
                          }
                          return;
                        }
                      }

                      final data = {
                        'code': code,
                        'name': nameController.text.trim(),
                        'description': descController.text.trim(),
                        'isActive': isActive,
                      };

                      setState(() => _isSubmitting = true);

                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      bool success;
                      if (dept == null) {
                        success = await _settingsService.addDepartment(
                          data,
                          user.id,
                          user.name,
                        );
                      } else {
                        success = await _settingsService.updateDepartment(
                          dept.id,
                          data,
                          user.id,
                          user.name,
                        );
                      }

                      if (mounted) {
                        setState(() => _isSubmitting = false);
                        if (success) {
                          navigator.pop();
                          _loadDepartments();
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save department'),
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamDialog(OrgDepartment dept) {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    final codeController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Text('Add Team to ${dept.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Team Code'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Team Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = context.read<AuthProvider>().state.user;
              if (user == null) return;

              final code = codeController.text.trim().toLowerCase();
              final name = nameController.text.trim();
              if (code.isEmpty || name.isEmpty) return;

              // Check for duplicate team code within this department
              final exists = dept.teams.any((t) => t.code == code);
              if (exists) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Team code already exists in this department',
                      ),
                    ),
                  );
                }
                return;
              }

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              final team = DeptTeam(code: code, name: name);
              final success = await _settingsService.addTeamToDepartment(
                dept.id,
                team,
                user.id,
                user.name,
              );

              if (mounted) {
                if (success) {
                  navigator.pop();
                  _loadDepartments();
                } else {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Failed to add team')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteDepartment(OrgDepartment dept) async {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Department'),
        content: Text(
          'Are you sure you want to delete "${dept.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().state.user;
      if (user == null) return;
      await _settingsService.deleteDepartment(dept.id, user.id, user.name);
      _loadDepartments();
    }
  }

  Future<void> _handleSyncDefaults() async {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Syncing defaults...')));
    await _settingsService.syncDefaultDepartments(
      _departments,
      user.id,
      user.name,
    );
    if (mounted) _loadDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildScreenHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadDepartments,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Manage departments and teams for user access control.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_departments.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('', style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 16),
                              const Text('No departments found'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: widget.isReadOnly
                                    ? null
                                    : _handleSyncDefaults,
                                child: const Text('Sync Defaults'),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._departments.map(
                          (dept) => _buildDepartmentCard(dept),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildScreenHeader() {
    final theme = Theme.of(context);
    return MasterScreenHeader(
      title: 'Departments',
      subtitle: 'Internal business departments',
      helperText: 'Department controls access and reporting hierarchy.',
      color: AppColors.warning,
      icon: Icons.business_rounded,
      emoji: '',
      onBack: widget.onBack,
      actions: [
        ElevatedButton.icon(
          onPressed: widget.isReadOnly
              ? null
              : () => _showDepartmentDialog(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Department'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          onPressed: _loadDepartments,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildDepartmentCard(OrgDepartment dept) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_work_rounded,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        dept.code.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(dept.isActive),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  enabled: !widget.isReadOnly,
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (val) {
                    if (widget.isReadOnly) return;
                    if (val == 'edit') _showDepartmentDialog(dept);
                    if (val == 'delete') _handleDeleteDepartment(dept);
                  },
                  itemBuilder: (context) => widget.isReadOnly
                      ? const [
                          PopupMenuItem(
                            enabled: false,
                            child: Text('Read-only'),
                          ),
                        ]
                      : [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 18),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
          if (dept.description != null && dept.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                dept.description!,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.05),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TEAMS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 14,
                      ),
                      label: const Text('Add Team'),
                      onPressed: widget.isReadOnly
                          ? null
                          : () => _showTeamDialog(dept),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (dept.teams.isEmpty)
                  Text(
                    'No sub-teams defined for this department.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dept.teams
                        .map((team) => _buildTeamChip(dept, team))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    final theme = Theme.of(context);
    final color =
        isActive ? AppColors.success : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTeamChip(OrgDepartment dept, DeptTeam team) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            team.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 14),
            onPressed: widget.isReadOnly
                ? null
                : () async {
                    final user = context.read<AuthProvider>().state.user;
                    if (user == null) return;
                    await _settingsService.removeTeamFromDepartment(
                      dept.id,
                      team,
                      user.id,
                      user.name,
                    );
                    _loadDepartments();
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}



