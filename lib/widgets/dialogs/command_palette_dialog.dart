import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/main_scaffold.dart';
import '../../utils/responsive.dart';

class CommandPaletteDialog extends StatefulWidget {
  const CommandPaletteDialog({super.key});

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final List<Map<String, dynamic>> _allCommands = [
    {'label': 'Dashboard', 'icon': Icons.dashboard, 'route': '/dashboard'},
    {
      'label': 'New Sale',
      'icon': Icons.point_of_sale,
      'route': '/dashboard/sales/new',
    },
    {
      'label': 'Add Vehicle',
      'icon': Icons.directions_car,
      'route': '/dashboard/vehicles/add',
    },
    {
      'label': 'Vehicle Maintenance',
      'icon': Icons.build,
      'route': '/dashboard/vehicles/maintenance/add',
    },
    {
      'label': 'Vehicle Fleet',
      'icon': Icons.local_shipping,
      'route': '/dashboard/vehicles/all',
    },
    {
      'label': 'Inventory Stock',
      'icon': Icons.inventory,
      'route': '/dashboard/inventory/stock-overview',
    },
    {
      'label': 'Purchase Orders',
      'icon': Icons.shopping_cart,
      'route': '/dashboard/inventory/purchase-orders',
    },
    {
      'label': 'Settings',
      'icon': Icons.settings,
      'route': '/dashboard/settings',
    },
  ];

  List<Map<String, dynamic>> _filteredCommands = [];

  @override
  void initState() {
    super.initState();
    _filteredCommands = _allCommands;
    _searchController.addListener(_filterCommands);
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  void _filterCommands() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommands = _allCommands.where((cmd) {
        return cmd['label'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _executeCommand(Map<String, dynamic> command) {
    Navigator.of(context).pop(); // Close dialog first
    final route = command['route']?.toString();
    if (route != null) {
      final isDesktop = !Responsive.isMobile(context);
      final normalizedRoute = route.split('?').first;
      final isSettingsRoute =
          normalizedRoute == '/dashboard/settings' ||
          normalizedRoute.startsWith('/dashboard/settings/');

      if (isDesktop && isSettingsRoute) {
        final scaffoldState = context.findAncestorStateOfType<MainScaffoldState>();
        if (scaffoldState != null) {
          scaffoldState.openNewTab(route);
          return;
        }
      }

      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final dialogHeight = Responsive.clamp(
      context,
      min: 320,
      max: 500,
      ratio: 0.7,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: Responsive.dialogInsetPadding(context),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: Responsive.dialogConstraints(
          context,
          maxWidth: 600,
          maxHeightFactor: 0.9,
        ),
        child: SizedBox(
          height: dialogHeight,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: isDark ? 0.5 : 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Type a command or search...',
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(Icons.search, color: theme.hintColor),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),

                // Results List
                Expanded(
                  child: _filteredCommands.isEmpty
                      ? Center(
                          child: Text(
                            'No commands found',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredCommands.length,
                          itemBuilder: (context, index) {
                            final cmd = _filteredCommands[index];
                            return ListTile(
                              leading: Icon(
                                cmd['icon'],
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              title: Text(
                                cmd['label'],
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                              hoverColor: colorScheme.onSurface.withValues(
                                alpha: 0.05,
                              ),
                              onTap: () => _executeCommand(cmd),
                            );
                          },
                        ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      _footerBadge(context, 'Esc', 'Close'),
                      const SizedBox(width: 12),
                      _footerBadge(context, 'Enter', 'Select'),
                      const Spacer(),
                      Text(
                        'DattSoap ERP',
                        style: TextStyle(color: theme.hintColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerBadge(BuildContext context, String key, String action) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            key,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(action, style: TextStyle(color: theme.hintColor, fontSize: 12)),
      ],
    );
  }
}
