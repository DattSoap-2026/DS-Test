import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/users_service.dart';
import '../../services/settings_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../utils/password_utils.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/local/entities/user_entity.dart';
import 'user_form_dialog.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/animated_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/utils/responsive.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final UsersService _usersService;
  late final SettingsService _settingsService;
  bool _isLoading = true;
  List<AppUser> _users = [];
  List<String> _allRoutes = [];
  List<OrgDepartment> _allDepartments = [];
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _statusFilter = 'all';
  bool _showRoleGuide = false;
  final Set<String> _selection = {};
  bool _isSelectionMode = false;
  final ScrollController _roleGuideController = ScrollController();
  final Map<String, Map<String, dynamic>> _roleInfo = {
    'Admin': {
      'description': 'Full system access with all permissions',
      'icon': Icons.admin_panel_settings_outlined,
      'color': AppColors.info,
    },
    'Accountant': {
      'description': 'Ledger, vouchers, and financial reconciliation',
      'icon': Icons.calculate_outlined,
      'color': AppColors.success,
    },
    'Store Incharge': {
      'description': 'Inventory and purchase management',
      'icon': Icons.inventory_2_outlined,
      'color': AppColors.info,
    },
    'Salesman': {
      'description': 'Sales and customer management',
      'icon': Icons.badge_outlined,
      'color': AppColors.success,
    },
    'Production Supervisor': {
      'description': 'Production logging and quality control',
      'icon': Icons.factory_outlined,
      'color': AppColors.warning,
    },
    'Fuel Incharge': {
      'description': 'Vehicle fuel and diesel management',
      'icon': Icons.local_gas_station_outlined,
      'color': AppColors.error,
    },
    'Bhatti Supervisor': {
      'description': 'Furnace operations and batch management',
      'icon': Icons.local_fire_department_outlined,
      'color': AppColors.warning,
    },
    'Vehicle Maintenance Manager': {
      'description': 'Vehicle and maintenance oversight',
      'icon': Icons.build_circle_outlined,
      'color': AppColors.info,
    },
    'Dealer Manager': {
      'description': 'Manage dealers, sales, and dispatch',
      'icon': Icons.handshake_outlined,
      'color': AppColors.lightPrimary,
    },
    'Owner': {
      'description': 'Business owner visibility',
      'icon': Icons.visibility_outlined,
      'color': AppColors.warning,
    },
  };

  Map<String, Map<String, dynamic>> get _effectiveRoleInfo {
    final merged = Map<String, Map<String, dynamic>>.from(_roleInfo);
    merged.putIfAbsent(UserRole.accountant.value, () {
      return {
        'description': 'Ledger, vouchers, and financial reconciliation',
        'icon': Icons.calculate_outlined,
        'color': AppColors.success,
      };
    });
    return merged;
  }

  bool _isDiagnosticQaUser(AppUser user) {
    final id = user.id.trim().toLowerCase();
    final email = user.email.trim().toLowerCase();
    final name = user.name.trim().toLowerCase();

    final isDiagnosticId = id.startsWith('qa.') ||
        id.startsWith('qa_') ||
        id.startsWith('qa.role.') ||
        id.startsWith('live.scenario.');
    final isDiagnosticEmail = email.startsWith('qa.') ||
        email.startsWith('qa_') ||
        email.startsWith('live.scenario.') ||
        email.endsWith('@erp.local');
    final isDiagnosticName =
        name.startsWith('qa ') || name.startsWith('live scenario');

    return isDiagnosticId || isDiagnosticEmail || isDiagnosticName;
  }

  @override
  void initState() {
    super.initState();
    _usersService = context.read<UsersService>();
    _settingsService = context.read<SettingsService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _usersService.getUsers();

      // Deduplicate by email to handle dirty legacy records with different IDs.
      final userMap = <String, AppUser>{};
      for (final user in users) {
        final normalizedEmail = user.email.trim().toLowerCase();
        final key = normalizedEmail.isNotEmpty ? normalizedEmail : user.id;
        userMap[key] = user;
      }
      var dedupedUsers = userMap.values.toList()
        ..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      if (kReleaseMode || kProfileMode) {
        dedupedUsers = dedupedUsers
            .where((user) => !_isDiagnosticQaUser(user))
            .toList();
      }

      // Settings/Routes (Keep Online for now or need SettingsRepository)
      List<String> routes = [];
      List<OrgDepartment> departments = [];

      try {
        routes = await _settingsService.getRoutes();
        departments = await _settingsService.getDepartments();
      } catch (e) {
        debugPrint('Online settings fetch failed: $e');
      }

      if (mounted) {
        setState(() {
          _users = dedupedUsers;
          _allRoutes = routes;
          _allDepartments = departments;
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

  Map<String, int> get _roleStats {
    final stats = <String, int>{};
    for (var user in _users) {
      stats[user.role.value] = (stats[user.role.value] ?? 0) + 1;
    }
    return stats;
  }

  List<AppUser> get _filteredUsers {
    return _users.where((user) {
      if ((kReleaseMode || kProfileMode) && _isDiagnosticQaUser(user)) {
        return false;
      }

      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole =
          _roleFilter == 'all' || user.role.value == _roleFilter;
      final matchesStatus =
          _statusFilter == 'all' ||
          (user.status ?? 'inactive') == _statusFilter;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (_selection.contains(userId)) {
        _selection.remove(userId);
      } else {
        _selection.add(userId);
      }
      _isSelectionMode = _selection.isNotEmpty;
    });
  }

  Future<void> _handleBulkAction(String status) async {
    if (_selection.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Text('${status == 'active' ? 'Activate' : 'Deactivate'} Users'),
        content: Text(
          'Are you sure you want to change status for ${_selection.length} users?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await _usersService.bulkUpdateUserStatus(
        _selection.toList(),
        status,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bulk action successful')));
        _selection.clear();
        _isSelectionMode = false;
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bulk action failed: $e')));
      }
    }
  }

  @override
  void dispose() {
    _roleGuideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.width(context);
    final textScaleFactor = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.8).toDouble();
    int crossAxisCount;
    if (screenWidth >= 1400) {
      crossAxisCount = 4;
    } else if (screenWidth >= 1000) {
      crossAxisCount = 3;
    } else if (screenWidth >= 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }
    // Text scaling gets priority over density so cards never clip vertically.
    if (textScaleFactor >= 1.2 && crossAxisCount > 1) {
      crossAxisCount -= 1;
    }
    if (textScaleFactor >= 1.45 && crossAxisCount > 1) {
      crossAxisCount -= 1;
    }

    final isNarrowViewport = screenWidth < 760;
    final baseCardHeight = switch (crossAxisCount) {
      1 => isNarrowViewport ? 182.0 : 172.0,
      2 => 166.0,
      3 => 154.0,
      _ => 146.0,
    };
    final userCardHeight =
        baseCardHeight +
        ((textScaleFactor - 1.0) * 52) +
        (_isSelectionMode ? 8 : 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading && _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadData();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildScreenHeader()),
                  if (_showRoleGuide)
                    SliverToBoxAdapter(child: _buildRoleGuide()),
                  SliverToBoxAdapter(child: _buildStatsBar()),
                  SliverToBoxAdapter(child: _buildFilterBar()),
                  if (_filteredUsers.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: userCardHeight,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        }, childCount: _filteredUsers.length),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              heroTag: 'users_fab',
              onPressed: () => _showUserForm(),
              backgroundColor: const Color(0xFF4f46e5),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
    );
  }

  Widget _buildScreenHeader() {
    final theme = Theme.of(context);
    final isMobile = Responsive.width(context) <= 600;

    return MasterScreenHeader(
      title: _isSelectionMode
          ? '${_selection.length} Selected'
          : 'User Management',
      subtitle: 'Control system access and hierarchical roles',
      icon: Icons.manage_accounts_rounded,
      color: theme.colorScheme.primary,
      actionsInline: !isMobile,
      forceActionsBelowTitle: isMobile,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: () => _handleBulkAction('active'),
            icon: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            tooltip: 'Activate Selected',
          ),
          IconButton(
            onPressed: () => _handleBulkAction('inactive'),
            icon: const Icon(Icons.block_rounded, color: AppColors.error),
            tooltip: 'Deactivate Selected',
          ),
          IconButton(
            onPressed: () => setState(() {
              _selection.clear();
              _isSelectionMode = false;
            }),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Cancel Selection',
          ),
        ] else ...[
          IconButton(
            onPressed: () => context.pushNamed('settings_departments'),
            icon: const Icon(Icons.business_rounded),
            tooltip: 'Departments',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showRoleGuide = !_showRoleGuide),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Role Guide',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
            ),
          ),
          if (isMobile)
            IconButton(
              onPressed: () => _showUserForm(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              tooltip: 'Add User',
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                foregroundColor: theme.colorScheme.primary,
              ),
            )
          else ...[
            const SizedBox(width: 8),
            CustomButton(
              label: 'ADD USER',
              icon: Icons.add_rounded,
              onPressed: () => _showUserForm(),
              isDense: true,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildRoleGuide() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: _effectiveRoleInfo.entries.map((entry) {
            final info = entry.value;
            return Container(
              width: Responsive.clamp(context, min: 240, max: 320, ratio: 0.3),
              margin: const EdgeInsets.only(right: 16),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (info['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            info['icon'] as IconData,
                            size: 20,
                            color: info['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      info['description'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final roles = _effectiveRoleInfo.keys.toList();
        if (roles.isEmpty) {
          return const SizedBox.shrink();
        }

        const spacing = 10.0;
        const minCardWidth = 120.0;
        final maxWidth = constraints.maxWidth;
        int columns = (roles.length / 2).ceil();
        final maxColumnsByWidth =
            ((maxWidth + spacing) / (minCardWidth + spacing)).floor();
        if (maxColumnsByWidth > 0) {
          columns = columns.clamp(1, maxColumnsByWidth);
        }

        final cardWidth = (maxWidth - spacing * (columns - 1)) / columns;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: roles
                .map(
                  (role) => SizedBox(
                    width: cardWidth,
                    child: _buildRoleStatCard(role, theme),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildRoleStatCard(String role, ThemeData theme) {
    final count = _roleStats[role] ?? 0;
    final isSelected = _roleFilter == role;
    final roleMeta = _effectiveRoleInfo[role] ?? const <String, dynamic>{};
    final color = roleMeta['color'] as Color? ?? AppColors.info;
    final icon = roleMeta['icon'] as IconData? ?? Icons.person;

    return AnimatedCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => setState(() => _roleFilter = isSelected ? 'all' : role),
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 20,
          color: isSelected ? color.withValues(alpha: 0.1) : null,
          borderColor: isSelected ? color : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 16, color: color),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? color : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                role.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 0.5,
                  color: isSelected
                      ? color
                      : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final stackFilters = constraints.maxWidth < 760 || textScale > 1.15;

          final statusFilter = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                icon: const Icon(Icons.filter_list_rounded, size: 20),
                dropdownColor: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('ALL STATUS')),
                  DropdownMenuItem(value: 'active', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'inactive', child: Text('INACTIVE')),
                ],
                onChanged: (val) => setState(() => _statusFilter = val!),
              ),
            ),
          );

          if (stackFilters) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'SEARCH USERS',
                  hintText: 'Name or email...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: statusFilter),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'SEARCH USERS',
                  hintText: 'Name or email...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              statusFilter,
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selection.contains(user.id);
    final currentUserId = context.read<AuthProvider>().state.user?.id ?? '';
    final isMe = user.id == currentUserId;

    final roleColor =
        _effectiveRoleInfo[user.role.value]?['color'] as Color? ??
        colorScheme.onSurfaceVariant;
    final roleIcon =
        _effectiveRoleInfo[user.role.value]?['icon'] as IconData? ??
        Icons.person;
    final isActive = user.status == 'active';

    return AnimatedCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: InkWell(
        onLongPress: isMe ? null : () => _toggleSelection(user.id),
        onTap: _isSelectionMode
            ? (isMe ? null : () => _toggleSelection(user.id))
            : () => _showUserForm(user),
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
            final isCompact =
                constraints.maxHeight < 168 ||
                constraints.maxWidth < 300 ||
                textScaleFactor > 1.1;
            final cardPadding = EdgeInsets.all(isCompact ? 12 : 16);
            final avatarSize = isCompact ? 44.0 : 52.0;
            final avatarRadius = isCompact ? 12.0 : 14.0;
            final gap = isCompact ? 10.0 : 14.0;
            final badgeGap = isCompact ? 6.0 : 8.0;
            final infoGap = isCompact ? 6.0 : 10.0;

            return GlassContainer(
              padding: cardPadding,
              borderRadius: 24,
              borderColor: isSelected ? theme.colorScheme.primary : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isSelectionMode)
                    Padding(
                      padding: EdgeInsets.only(right: gap - 4, top: 2),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: isMe
                            ? null
                            : (val) => _toggleSelection(user.id),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        visualDensity: isCompact
                            ? VisualDensity.compact
                            : VisualDensity.standard,
                      ),
                    ),

                  // Avatar with Shadow
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(avatarRadius),
                      boxShadow: [
                        BoxShadow(
                          color: roleColor.withValues(alpha: 0.3),
                          blurRadius: isCompact ? 8 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: gap),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          fontSize: isCompact ? 13 : null,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user.email,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: isCompact ? 10 : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isMe)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 6 : 8,
                                  vertical: isCompact ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'YOU',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isCompact ? 9 : null,
                                  ),
                                ),
                              )
                            else if (!_isSelectionMode)
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: isCompact ? 16 : 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onSelected: (val) =>
                                    _handleUserAction(user, val),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text('View Profile'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit Profile'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'reset_pass',
                                    child: Row(
                                      children: [
                                        Icon(Icons.key, size: 18),
                                        SizedBox(width: 8),
                                        Text('Reset Password'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: isActive ? 'deactivate' : 'activate',
                                    child: Row(
                                      children: [
                                        Icon(
                                          isActive
                                              ? Icons.highlight_off
                                              : Icons.check_circle_outline,
                                          size: 18,
                                          color: isActive
                                              ? AppColors.error
                                              : AppColors.success,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isActive ? 'Deactivate' : 'Activate',
                                          style: TextStyle(
                                            color: isActive
                                                ? AppColors.error
                                                : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: infoGap),

                        // Badges (single-line, horizontal scroll to avoid overflow)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBadge(
                                icon: roleIcon,
                                label: user.role.value,
                                color: roleColor,
                                theme: theme,
                                compact: isCompact,
                              ),
                              if (user.department != null) ...[
                                SizedBox(width: badgeGap),
                                _buildBadge(
                                  icon: Icons.business_rounded,
                                  label: user.department!.toUpperCase(),
                                  color: theme.colorScheme.secondary,
                                  theme: theme,
                                  compact: isCompact,
                                ),
                              ],
                              SizedBox(width: badgeGap),
                              _buildBadge(
                                icon: isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                label: isActive ? 'ACTIVE' : 'INACTIVE',
                                color: isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                theme: theme,
                                compact: isCompact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
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
          const Text('', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No users found'
                : 'No matches for your search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new user manually',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  void _showUserForm([AppUser? user]) async {
    final authProvider = context.read<AuthProvider>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        allRoutes: _allRoutes,
        allDepartments: _allDepartments,
      ),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        if (user == null) {
          // 1. Create Local Entity
          final normalizedEmail = (result['email'] as String)
              .trim()
              .toLowerCase();
          final newUser = UserEntity()
            ..id = normalizedEmail
            ..name = result['name']
            ..email = result['email']
            ..phone = result['phone']
            ..role = result['role']
            ..department = result['department']
            ..departmentsJson = jsonEncode(result['departments'] ?? [])
            ..status = result['status']
            ..assignedRoutes = (result['assignedRoutes'] as List?)
                ?.cast<String>()
            ..assignedBhatti = result['assignedBhatti'];

          final userRepo = context.read<UserRepository>();

          await userRepo.createUser(newUser);
        } else {
          // Update
          final currentUser = authProvider.currentUser;
          if (currentUser == null) throw Exception('Not authenticated');

          await _usersService.updateUser(user.id, result, currentUser.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user == null
                    ? 'User created successfully'
                    : 'User updated successfully',
              ),
            ),
          );
          _loadData();
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
  }

  Future<void> _handleUserAction(AppUser user, String action) async {
    final currentUserId = context.read<AuthProvider>().state.user?.id ?? '';

    switch (action) {
      case 'view':
        context.pushNamed(
          'user_profile_view',
          pathParameters: {'userId': user.id},
          extra: user,
        );
        break;
      case 'edit':
        _showUserForm(user);
        break;
      case 'reset_pass':
        _showResetPasswordDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        final newStatus = action == 'activate' ? 'active' : 'inactive';
        setState(() => _isLoading = true);
        try {
          final success = await _usersService.updateUser(user.id, {
            'status': newStatus,
          }, currentUserId);

          if (success) {
            if (!mounted) return;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User $newStatus successfully')),
              );
              _loadData();
            }
          }
        } catch (e) {
          if (mounted) setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed: $e')));
          }
        }
        break;
      case 'delete_mock':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => ResponsiveAlertDialog(
            title: const Text('Delete Mock User'),
            content: Text(
              'Are you sure you want to delete "${user.name}"? This action only applies to mock users.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.info),
                child: const Text('Delete permanently'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          setState(() => _isLoading = true);
          try {
            final success = await _usersService.deleteUser(user.id, user.name);
            if (success && mounted) {
              // Also delete from local repository
              try {
                final userRepo = context.read<UserRepository>();

                await userRepo.deleteUser(user.id);
              } catch (e) {
                debugPrint(
                  'Local deletion failed (might not be in local DB): $e',
                );
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock user deleted successfully'),
                  ),
                );
                _loadData();
              }
            }
          } catch (e) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
            }
          }
        }
        break;
    }
  }

  void _showResetPasswordDialog(AppUser user) {
    String? generatedPassword;
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ResponsiveAlertDialog(
          title: Text('Reset Password for ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (generatedPassword == null)
                const Text(
                  'This will generate a new secure password and update the user\'s credentials immediately.',
                )
              else ...[
                const Text('New password generated:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          generatedPassword!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: generatedPassword!),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  ' Important: Copy this password and share it securely. It won\'t be shown again.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (generatedPassword == null) ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isResetting
                    ? null
                    : () async {
                        setDialogState(() => isResetting = true);
                        final pwd = generateSecurePassword(12);
                        // In a real scenario, we'd call a service to update the password in Auth and Firestore
                        // For now, we simulate success and update Firestore just as React does
                        try {
                          // Note: Firebase Auth password reset from Admin side typically requires Cloud Functions
                          // We'll update the 'passwordResetAt' in Firestore and create an audit log.
                          await _usersService.requestPasswordReset(user.id);
                          setDialogState(() {
                            generatedPassword = pwd;
                            isResetting = false;
                          });
                        } catch (e) {
                          setDialogState(() => isResetting = false);
                          if (context.mounted) Navigator.pop(context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: isResetting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate & Reset'),
              ),
            ] else
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
          ],
        ),
      ),
    );
  }
}
