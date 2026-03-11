import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/navigation/main_scaffold.dart';

import 'company_profile_screen.dart';
import 'general_settings_screen.dart';
import 'user_preferences_screen.dart';
import 'theme_settings_screen.dart';
import 'taxation_screen.dart'; // Consolidated Tax & GST
import 'transaction_series_screen.dart';
import 'fuel_settings_screen.dart';
import 'system_data_screen.dart'; // Consolidated Backup & Data
import 'custom_roles_screen.dart';
import 'audit_logs_screen.dart';
import 'currencies_screen.dart';
import 'incentives_screen.dart';
import '../management/schemes_screen.dart';
import '../management/users_screen.dart';
import '../management/department_management_screen.dart';
import '../management/sales_targets_screen.dart';
import 'whatsapp_settings_screen.dart';
import 'pdf_templates_screen.dart';
import '../../utils/responsive.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
// import 'mobile_app_screen.dart'; // Hidden
// import 'printing_settings_screen.dart'; // Hidden
// import 'units_management_screen.dart'; // Hidden
// import 'email_test_screen.dart'; // Hidden

class SettingsModuleScreen extends StatefulWidget {
  const SettingsModuleScreen({super.key});

  @override
  State<SettingsModuleScreen> createState() => _SettingsModuleScreenState();
}

class _SettingsModuleScreenState extends State<SettingsModuleScreen> {
  int _selectedTabIndex = 0;
  bool _showMobileList = true;

  // Updated List based on Audit
  final List<Map<String, dynamic>> _settingsOptions = [
    {
      'icon': Icons.business,
      'title': 'Company Profile',
      'route': '/dashboard/settings/company-profile',
    },
    {
      'icon': Icons.settings,
      'title': 'General Settings',
      'route': '/dashboard/settings/general',
    },
    {
      'icon': Icons.person,
      'title': 'My Preferences',
      'route': '/dashboard/settings/preferences',
    },
    {
      'icon': Icons.palette_outlined,
      'title': 'Theme & Appearance',
      'route': '/dashboard/settings/theme-appearance',
    },
    {
      'icon': Icons.account_balance_wallet,
      'title': 'Taxation Management',
      'route': '/dashboard/settings/gst',
    },
    {
      'icon': Icons.numbers,
      'title': 'Transaction Series',
      'route': '/dashboard/settings/transaction-series',
    },
    {
      'icon': Icons.local_gas_station,
      'title': 'Fuel Settings',
      'route': '/dashboard/settings/fuel',
    },
    {
      'icon': Icons.local_offer_outlined,
      'title': 'Schemes & Offers',
      'route': '/dashboard/settings/schemes',
    },
    {
      'icon': Icons.storage,
      'title': 'System Data',
      'route': '/dashboard/settings/data-management',
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Incentives & Commission',
      'route': '/dashboard/settings/incentives',
    },
    {
      'icon': Icons.security,
      'title': 'Custom Roles',
      'route': '/dashboard/settings/custom-roles',
    },
    {
      'icon': Icons.people,
      'title': 'User Management',
      'route': '/dashboard/settings/users',
    },
    {
      'icon': Icons.business_outlined,
      'title': 'Departments',
      'route': '/dashboard/settings/departments',
    },
    {
      'icon': Icons.track_changes,
      'title': 'Sales Targets',
      'route': '/dashboard/settings/sales-targets',
    },
    {
      'icon': Icons.attach_money,
      'title': 'Currencies',
      'route': '/dashboard/settings/currencies',
    },
    {
      'icon': Icons.history,
      'title': 'Activity History',
      'route': '/dashboard/settings/audit-logs',
    },
    {
      'icon': Icons.picture_as_pdf,
      'title': 'PDF Templates',
      'route': '/dashboard/settings/pdf-templates',
    },
    {
      'icon': Icons.chat,
      'title': 'WhatsApp Integration',
      'route': '/dashboard/settings/whatsapp',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ... (keep existing build logic)
    final user = context.watch<AuthProvider>().state.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }

    if (user.role != UserRole.admin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Admin access required for Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact your administrator for access',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isDesktop = Responsive.width(context) > 800;
    final showInnerHeaders = isDesktop;

    // IMPORTANT: Must match _settingsOptions order exactly
    final children = [
      CompanyProfileScreen(showHeader: showInnerHeaders),
      GeneralSettingsScreen(showHeader: showInnerHeaders),
      UserPreferencesScreen(showHeader: showInnerHeaders),
      ThemeSettingsScreen(showHeader: showInnerHeaders),
      TaxationScreen(showHeader: showInnerHeaders),
      TransactionSeriesScreen(showHeader: showInnerHeaders),
      FuelSettingsScreen(showHeader: showInnerHeaders),
      const SchemesScreen(),
      SystemDataScreen(showHeader: showInnerHeaders),
      const IncentivesScreen(),
      CustomRolesScreen(showHeader: showInnerHeaders),
      const UsersScreen(),
      const DepartmentManagementScreen(),
      const SalesTargetsScreen(),
      CurrenciesScreen(showHeader: showInnerHeaders),
      AuditLogsScreen(showHeader: showInnerHeaders),
      PdfTemplatesScreen(showHeader: showInnerHeaders),
      const WhatsAppSettingsScreen(),
    ];

    return Scaffold(
      body: isDesktop
          ? _buildDesktopLayout(children)
          : _buildMobileLayout(children),
    );
  }

  void _handleContextMenu(String path, TapDownDetails details) {
    final scaffoldState = context.findAncestorStateOfType<MainScaffoldState>();
    if (scaffoldState == null) return;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(details.globalPosition, details.globalPosition),
      Offset.zero & Size(Responsive.width(context), Responsive.height(context)),
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'new_tab',
          child: const Row(
            children: [
              Icon(Icons.tab, size: 18),
              SizedBox(width: 8),
              Text('Open in New Tab'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'split_view',
          child: const Row(
            children: [
              Icon(Icons.vertical_split, size: 18),
              SizedBox(width: 8),
              Text('Open in Split View'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'new_window',
          child: const Row(
            children: [
              Icon(Icons.open_in_new, size: 18),
              SizedBox(width: 8),
              Text('Open in New Window'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!mounted) return;
      if (value == 'new_tab') {
        scaffoldState.openNewTab(path);
      } else if (value == 'split_view') {
        scaffoldState.openSplitView(path);
      } else if (value == 'new_window') {
        scaffoldState.openNewWindow(path);
      }
    });
  }

  Widget _buildDesktopLayout(List<Widget> children) {
    final navWidth = Responsive.clamp(
      context,
      min: 220,
      max: 300,
      ratio: 0.22,
    );
    return Row(
      children: [
        // Navigation sidebar
        Container(
          width: navWidth,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: ListView.builder(
            itemCount: _settingsOptions.length,
            itemBuilder: (context, index) {
              final item = _settingsOptions[index];
              return _buildNavTile(
                index,
                item['icon'] as IconData,
                item['title'] as String,
                item['route'] as String?,
              );
            },
          ),
        ),
        // Main content area
        Expanded(
          child: IndexedStack(index: _selectedTabIndex, children: children),
        ),
      ],
    );
  }

  // Mobile layout unchanged except passing route if needed (though mobile usually doesn't do new tab)
  Widget _buildMobileLayout(List<Widget> children) {
    if (_showMobileList) {
      return ListView.separated(
        itemCount: _settingsOptions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _settingsOptions[index];
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(item['title'] as String),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
                _showMobileList = false;
              });
            },
          );
        },
      );
    }

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showMobileList = true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _settingsOptions[_selectedTabIndex]['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(index: _selectedTabIndex, children: children),
        ),
      ],
    );
  }

  Widget _buildNavTile(int index, IconData icon, String title, String? route) {
    final theme = Theme.of(context);
    final isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      onSecondaryTapDown: (details) =>
          route != null ? _handleContextMenu(route, details) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.cardColor : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
