import 'package:flutter/material.dart';
import '../../services/roles_service.dart';
import '../../models/types/user_types.dart';
import '../../widgets/ui/custom_card.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/ui/themed_filter_chip.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';

class CustomRolesScreen extends StatefulWidget {
  final bool showHeader;

  const CustomRolesScreen({super.key, this.showHeader = true});

  @override
  State<CustomRolesScreen> createState() => _CustomRolesScreenState();
}

class _CustomRolesScreenState extends State<CustomRolesScreen> {
  late RolesService _rolesService;

  bool _isLoading = true;
  List<CustomRole> _roles = [];

  static const List<Map<String, dynamic>> _allPermissions = [
    {
      'module': PermissionModule.sales,
      'actions': [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
      ],
      'label': 'Sales',
    },
    {
      'module': PermissionModule.inventory,
      'actions': [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.approve,
      ],
      'label': 'Inventory',
    },
    {
      'module': PermissionModule.production,
      'actions': [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
      ],
      'label': 'Production',
    },
    {
      'module': PermissionModule.reports,
      'actions': [PermissionAction.read, PermissionAction.export],
      'label': 'Reports',
    },
    {
      'module': PermissionModule.users,
      'actions': [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
      ],
      'label': 'Users',
    },
    {
      'module': PermissionModule.customers,
      'actions': [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
      ],
      'label': 'Customers',
    },
    {
      'module': PermissionModule.vehicles,
      'actions': [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
      ],
      'label': 'Vehicles',
    },
    {
      'module': PermissionModule.settings,
      'actions': [PermissionAction.read, PermissionAction.update],
      'label': 'Settings',
    },
  ];

  @override
  void initState() {
    super.initState();
    _rolesService = context.read<RolesService>();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _rolesService.getRoles();
      if (mounted) {
        setState(() {
          _roles = roles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading roles: $e')));
      }
    }
  }

  Future<void> _deleteRole(String roleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Role'),
        content: const Text(
          'Are you sure you want to delete this role? This action cannot be undone.',
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

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _rolesService.deleteRole(roleId);
      await _loadRoles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting role: $e')));
      }
    }
  }

  void _showCreateRoleDialog() {
    // Local state for the dialog
    String newRoleName = '';
    String newRoleDescription = '';
    final Set<String> selectedPermissions = {};
    bool isActionLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> createRole() async {
            if (newRoleName.trim().isEmpty) return;
            if (selectedPermissions.isEmpty) return;

            setDialogState(() => isActionLoading = true);

            try {
              final permissions = selectedPermissions.map((key) {
                final parts = key.split(':');
                final modKey = parts[0];
                final actKey = parts[1];
                final module = PermissionModule.values.firstWhere(
                  (e) => e.value == modKey,
                  orElse: () => PermissionModule.values.first,
                );
                final action = PermissionAction.values.firstWhere(
                  (e) => e.value == actKey,
                  orElse: () => PermissionAction.values.first,
                );

                return Permission(
                  id: key,
                  module: module,
                  action: action,
                  label: '${module.value} - ${action.value}',
                );
              }).toList();

              final user = context.read<AuthProvider>().state.user;
              if (user == null) return;

              final role = CustomRole(
                id: '',
                name: newRoleName,
                description: newRoleDescription,
                permissions: permissions,
                isActive: true,
                createdAt: DateTime.now().toIso8601String(),
                createdBy: user.id,
                updatedAt: DateTime.now().toIso8601String(),
              );

              await _rolesService.createRole(role);

              if (context.mounted) {
                Navigator.pop(context);
                _loadRoles();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role created successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                setDialogState(() => isActionLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating role: $e')),
                );
              }
            }
          }

          return ResponsiveAlertDialog(
            title: const Text('Create Custom Role'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Role Name *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => newRoleName = val,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => newRoleDescription = val,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Permissions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: _allPermissions.map((group) {
                          final module = group['module'] as PermissionModule;
                          final actions =
                              group['actions'] as List<PermissionAction>;
                          final label = group['label'] as String;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: actions.map((action) {
                                    final key =
                                        '${module.value}:${action.value}';
                                    final isSelected = selectedPermissions
                                        .contains(key);

                                    return ThemedFilterChip(
                                      label: action.value,
                                      selected: isSelected,
                                      onSelected: () {
                                        setDialogState(() {
                                          if (isSelected) {
                                            selectedPermissions.remove(key);
                                          } else {
                                            selectedPermissions.add(key);
                                          }
                                        });
                                      },
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      textStyle: const TextStyle(fontSize: 11),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isActionLoading ? null : createRole,
                child: isActionLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Role'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: widget.showHeader
          ? null
          : FloatingActionButton.small(
              onPressed: _showCreateRoleDialog,
              child: const Icon(Icons.add_rounded),
            ),
      body: Column(
        children: [
          if (widget.showHeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Custom Roles',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _showCreateRoleDialog,
                    icon: const Icon(Icons.add_rounded),
                    iconSize: 22,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _roles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _roles.length,
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      return CustomCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.security,
                                        size: 20,
                                        color: AppColors.info,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        role.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 20,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () => _deleteRole(role.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              if (role.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  role.description,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Text(
                                'Permissions:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: role.permissions.map((p) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.info.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '${p.module.value}.${p.action.value}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No custom roles created yet',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateRoleDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Role'),
          ),
        ],
      ),
    );
  }
}

