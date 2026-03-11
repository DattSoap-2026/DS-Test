import 'package:flutter/material.dart';
import 'routes_management_screen.dart';
import 'department_management_screen.dart';
import 'system_masters_screen.dart';
import 'products_list_screen.dart';
import 'formulas_screen.dart';
import 'incentives_screen.dart';
import 'sales_targets_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../models/types/product_types.dart';
import '../inventory/tanks_list_screen.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../services/master_data_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/responsive/responsive_layout.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({super.key});

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMaster; // null = show cards, non-null = show embedded screen

  List<DynamicProductType> _dynamicProductTypes = [];
  bool _isLoadingTypes = true;
  late final MasterDataService _masterDataService;

  @override
  void initState() {
    super.initState();
    _masterDataService = context.read<MasterDataService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 0) {
        _loadTypes(); // Refresh when coming back to Product Masters tab
      }
    });
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() => _isLoadingTypes = true);
    try {
      final types = await _masterDataService.getProductTypes();
      if (mounted) {
        setState(() {
          _dynamicProductTypes = types;
          _isLoadingTypes = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTypes = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectMaster(String masterKey) {
    setState(() => _selectedMaster = masterKey);
  }

  void _clearSelection() {
    setState(() => _selectedMaster = null);
  }

  String _normalizeTypeLabel(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return raw;
    return ProductType.fromString(raw).value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedMaster == null) ...[
            MasterScreenHeader(
              title: 'MASTER DATA',
              subtitle:
                  'Central repository for products, config, and system mappings',
              emoji: '',
            ),
            _buildTabBar(),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductionTab(),
                _buildConfigTab(),
                _buildSystemTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ThemedTabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Product Masters'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Production Config'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Categorization'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionTab() {
    final theme = Theme.of(context);
    if (_isLoadingTypes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dynamicProductTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No Product Types Found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(2); // Go to Categorization
              },
              child: const Text('Add Categories/Types'),
            ),
          ],
        ),
      );
    }

    final normalizedTypeMap = <String, DynamicProductType>{};
    for (final type in _dynamicProductTypes) {
      final normalizedName = _normalizeTypeLabel(type.name);
      final existing = normalizedTypeMap[normalizedName];
      if (existing == null || existing.name != normalizedName) {
        normalizedTypeMap[normalizedName] = type;
      }
    }

    final sortedTypeEntries = normalizedTypeMap.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return _buildTabContent(
      masterKey: 'production_masters',
      cards: sortedTypeEntries.map((entry) {
        final type = entry.value;
        final normalizedName = entry.key;
        return _MasterTile(
          title: normalizedName,
          icon: _getIconForName(type.iconName),
          color: _getColorForHex(
            type.color,
            fallback: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: () => _selectMaster('type_$normalizedName'),
          description: type.description,
        );
      }).toList(),
    );
  }

  IconData _getIconForName(String name) {
    switch (name) {
      case 'Package':
        return Icons.inventory_2_rounded;
      case 'Droplets':
        return Icons.opacity_rounded;
      case 'Beaker':
        return Icons.science_rounded;
      case 'Factory':
        return Icons.factory_rounded;
      case 'Store':
        return Icons.shopping_bag_rounded;
      case 'Check':
        return Icons.check_circle_rounded;
      case 'Grain':
        return Icons.grain_rounded;
      case 'Whatshot':
        return Icons.whatshot_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _getColorForHex(String hex, {Color? fallback}) {
    final resolvedFallback = fallback ?? const Color(0xFF4f46e5);
    if (hex.startsWith('bg-')) {
      if (hex.contains('green')) return AppColors.success;
      if (hex.contains('brown') || hex.contains('slate')) return Colors.brown;
      if (hex.contains('orange')) return AppColors.warning;
      if (hex.contains('deepOrange')) return Colors.deepOrange;
      if (hex.contains('blue')) return AppColors.info;
      if (hex.contains('purple')) return AppColors.info;
      if (hex.contains('indigo')) return const Color(0xFF4f46e5);
      return resolvedFallback;
    }
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return resolvedFallback;
    }
  }

  Widget _buildConfigTab() {
    return _buildTabContent(
      masterKey: 'production_config',
      cards: [
        _MasterTile(
          title: 'Formulas & Recipes',
          icon: Icons.science_rounded,
          color: AppColors.info,
          onTap: () => _selectMaster('formulas'),
          description: 'Manage production recipes',
        ),
        _MasterTile(
          title: 'Tanks & Storage',
          icon: Icons.opacity_rounded,
          color: AppColors.info,
          onTap: () => _selectMaster('tanks'),
          description: 'Oil & chemical tanks',
        ),
        _MasterTile(
          title: 'Logistics Options',
          icon: Icons.map_rounded,
          color: AppColors.warning,
          onTap: () => _selectMaster('routes_vehicles'),
          description: 'Routes & Vehicles masters',
        ),
      ],
    );
  }

  Widget _buildSystemTab() {
    // This tab now directly embeds the SystemMastersScreen logic for Categories, Types, and Units
    if (_selectedMaster != null) {
      return _buildEmbeddedScreen(_selectedMaster!);
    }
    return const SystemMastersScreen(showHeader: false);
  }

  Widget _buildTabContent({
    required String masterKey,
    required List<Widget> cards,
  }) {
    // If a master is selected, show its embedded screen
    if (_selectedMaster != null) {
      // Return DIRECTLY, no column, no custom back header (child handles it)
      return _buildEmbeddedScreen(_selectedMaster!);
    }

    // Otherwise, show the card grid
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.configOf(context).horizontalPadding),
      child: AdaptiveGrid(
        minTileWidth: 220,
        maxColumns: 4,
        spacing: 16,
        runSpacing: 16,
        children: cards,
      ),
    );
  }

  String _getMasterTitle(String masterKey) {
    final titles = {
      'routes_vehicles': 'Routes & Vehicles',
      'departments': 'Departments',
      'global_masters': 'Global Masters',
      'raw_materials': 'Raw Materials',
      'packaging': 'Packaging Material',
      'semi_finished': 'Semi-Finished (Bhatti)',
      'formulas': 'Formulas & Recipes',
      'tanks': 'Tanks & Storage',
      'finished_goods': 'Finished Goods',
      'incentives': 'Incentives',
      'sales_targets': 'Sales Targets',
      'traded_goods': 'Traded Goods',
    };
    return titles[masterKey] ?? masterKey;
  }

  Widget _buildEmbeddedScreen(String masterKey) {
    final user = context.read<AuthProvider>().currentUser;
    final role = user?.role;
    final isAdmin = role == UserRole.admin || role == UserRole.owner;
    final isStoreIncharge = role == UserRole.storeIncharge;

    // Permission Logic
    final canEditProduction =
        isAdmin ||
        isStoreIncharge ||
        role == UserRole.productionManager ||
        role == UserRole.productionSupervisor;

    final canEditSales =
        isAdmin || isStoreIncharge || role == UserRole.salesManager;
    final canEditProductCatalog = isAdmin || isStoreIncharge;

    final canEditSystem = isAdmin;

    // Helper to determine read-only status
    bool isReadOnly(String section) {
      if (section == 'production') return !canEditProduction;
      if (section == 'sales') return !canEditSales;
      if (section == 'system') return !canEditSystem;
      return true;
    }

    if (masterKey.startsWith('type_')) {
      final typeName = _normalizeTypeLabel(masterKey.replaceFirst('type_', ''));
      return ProductsManagementScreen(
        initialTypeFilter: typeName,
        isMasterDataMode: true,
        isReadOnly: !canEditProductCatalog,
        onBack: _clearSelection,
      );
    }

    switch (masterKey) {
      // System Configuration
      case 'routes_vehicles':
        return RoutesManagementScreen(
          onBack: _clearSelection,
          isReadOnly: isReadOnly('system'),
        );
      case 'departments':
        return DepartmentManagementScreen(
          onBack: _clearSelection,
          isReadOnly: isReadOnly('system'),
        );
      case 'global_masters':
        return SystemMastersScreen(
          isReadOnly: isReadOnly('system'),
          onBack: _clearSelection,
        );

      // Production Masters
      case 'raw_materials':
        return ProductsManagementScreen(
          initialTypeFilter: 'Raw Material',
          isMasterDataMode: true,
          isReadOnly: !canEditProductCatalog,
          onBack: _clearSelection,
        );
      case 'packaging':
        return ProductsManagementScreen(
          initialTypeFilter: 'Packaging Material',
          isMasterDataMode: true,
          isReadOnly: !canEditProductCatalog,
          onBack: _clearSelection,
        );
      case 'semi_finished':
        return ProductsManagementScreen(
          initialTypeFilter: 'Semi-Finished Good',
          isMasterDataMode: true,
          isReadOnly: !canEditProductCatalog,
          onBack: _clearSelection,
        );
      case 'formulas':
        return FormulasManagementScreen(
          isReadOnly: isReadOnly('production'),
          onBack: _clearSelection,
        );
      case 'tanks':
        return TanksListScreen(
          isReadOnly: isReadOnly('production'),
          onBack: _clearSelection,
        );

      // Finishing & Sales
      case 'finished_goods':
        return ProductsManagementScreen(
          initialTypeFilter: 'Finished Good',
          isMasterDataMode: true,
          isReadOnly: !canEditProductCatalog,
          onBack: _clearSelection,
        );
      case 'incentives':
        return IncentivesManagementScreen(onBack: _clearSelection);
      case 'sales_targets':
        return SalesTargetsScreen(onBack: _clearSelection);
      case 'traded_goods':
        return ProductsManagementScreen(
          initialTypeFilter: 'Traded Good',
          isMasterDataMode: true,
          isReadOnly: !canEditProductCatalog,
          onBack: _clearSelection,
        );

      // Fallback (should never reach here)
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Screen Not Found',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getMasterTitle(masterKey),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _MasterTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MasterTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
