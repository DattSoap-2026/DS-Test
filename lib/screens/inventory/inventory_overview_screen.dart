import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/types/product_types.dart';
import '../../widgets/inventory/inventory_table.dart';
import '../../widgets/inventory/inventory_analytics_card.dart';
import '../../widgets/inventory/inventory_search_filter.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../widgets/ui/custom_states.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../utils/unit_scope_utils.dart';

bool shouldIncludeProductForInventoryScope({
  required UserUnitScope scope,
  required Product product,
  required UserRole? userRole,
}) {
  // Regression lock: Bhatti supervisors must still see legacy inventory records
  // that have no department scope tokens saved yet.
  final allowLegacyUnscopedProducts = userRole == UserRole.bhattiSupervisor;
  return matchesUnitScope(
    scope: scope,
    tokens: [product.departmentId, ...product.allowedDepartmentIds],
    defaultIfNoScopeTokens: allowLegacyUnscopedProducts,
  );
}

class InventoryOverviewScreen extends StatefulWidget {
  const InventoryOverviewScreen({super.key});

  @override
  State<InventoryOverviewScreen> createState() =>
      _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState extends State<InventoryOverviewScreen>
    with TickerProviderStateMixin {
  List<Product> _products = [];
  bool _isLoading = true;
  FilterState _filters = FilterState();
  late String _currentTab;
  late TabController _tabController;
  UserRole? _currentUserRole;

  late List<String> _tabs;
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _currentUserRole = user?.role;
    _unitScope = resolveUserUnitScope(user);
    if (_currentUserRole == UserRole.bhattiSupervisor) {
      _tabs = ['semi', 'raw', 'oils', 'chemicals'];
      _currentTab = 'semi';
    } else if (_currentUserRole == UserRole.productionSupervisor) {
      _tabs = ['finished', 'semi', 'packaging'];
      _currentTab = 'finished';
    } else {
      _tabs = [
        'finished',
        'traded',
        'raw',
        'semi',
        'oils',
        'chemicals',
        'packaging',
      ];
      _currentTab = 'finished';
    }
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _tabController.addListener(_onTabChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTab = _tabs[_tabController.index];
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      // Use Repository (Offline First)
      final inventoryRepo = context.read<InventoryRepository>();
      final productEntities = await inventoryRepo.getAllProducts();

      // Map Entity -> Domain, apply scope filter, and deduplicate by ID
      final seen = <String>{};
      final products = productEntities
          .map((e) => e.toDomain())
          .where(_matchesScope)
          .where((p) => seen.add(p.id)) // remove duplicates
          .toList();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
      }
    }
  }

  bool _matchesScope(Product product) {
    return shouldIncludeProductForInventoryScope(
      scope: _unitScope,
      product: product,
      userRole: _currentUserRole,
    );
  }

  // Returns products filtered for a specific tab key.
  // Used by TabBarView so every tab child gets its OWN list (not shared state).
  List<Product> _getProductsForTab(String tab) {
    final itemType = _getItemTypeForTab(tab);
    if (itemType.isEmpty) return [];
    return _products.where((p) => p.itemType.value == itemType).toList();
  }

  // Returns the canonical itemType string for a given tab key.
  String _getItemTypeForTab(String tab) {
    switch (tab) {
      case 'finished':
        return 'Finished Good';
      case 'traded':
        return 'Traded Good';
      case 'raw':
        return 'Raw Material';
      case 'semi':
        return 'Semi-Finished Good';
      case 'oils':
        return 'Oils & Liquids';
      case 'chemicals':
        return 'Chemicals & Additives';
      case 'packaging':
        return 'Packaging Material';
      default:
        return '';
    }
  }

  List<String> get _uniqueCategories {
    return _products
        .map((p) => p.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isSupervisorView =
        context.read<AuthProvider>().currentUser?.role ==
            UserRole.bhattiSupervisor ||
        context.read<AuthProvider>().currentUser?.role ==
            UserRole.productionSupervisor;

    return Scaffold(
      body: _isLoading
          ? const CustomLoadingIndicator(message: 'Loading inventory...')
          : Column(
              children: [
                MasterScreenHeader(
                  title: 'Inventory Overview',
                  subtitle: 'Unified view of all stock across your business',
                  // icon: Icons.inventory_2_rounded, // MasterScreenHeader handles back button or leading icon differently
                  actions: [
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export feature coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Export CSV',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    if (!isSupervisorView) ...[
                      const SizedBox(width: 8),
                      CustomButton(
                        label: 'ADJUST',
                        icon: Icons.settings_suggest_rounded,
                        variant: ButtonVariant.outline,
                        isDense: true,
                        onPressed: () =>
                            context.go('/dashboard/inventory/adjust'),
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        label: 'PURCHASE',
                        icon: Icons.add_shopping_cart_rounded,
                        variant: ButtonVariant.primary,
                        isDense: true,
                        onPressed: () =>
                            context.go('/dashboard/inventory/purchase-orders'),
                      ),
                    ],
                  ],
                ),
                if (!_unitScope.canViewAll)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Unit Scope: ${_unitScope.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: InventoryAnalyticsCard(
                              products: _products,
                              loading: _isLoading,
                              isBhattiSupervisorView: isSupervisorView,
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: InventorySearchFilter(
                              onFilterChange: (filters) {
                                setState(() => _filters = filters);
                              },
                              categories: _uniqueCategories,
                              itemType: _getItemTypeForTab(_currentTab),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: UnifiedCard(
                              padding: const EdgeInsets.all(4),
                              child: ThemedTabBar(
                                controller: _tabController,
                                isScrollable: true,
                                tabs: _tabs.map((tab) {
                                  final count = _getTabCount(tab);
                                  final label = _getTabLabel(tab);
                                  return Tab(text: '$label ($count)');
                                }).toList(),
                                indicatorSize: TabBarIndicatorSize.tab,
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: _tabs.map((tab) {
                        // Each tab must use its OWN filtered list.
                        // Using _filteredProducts here was the bug — it depends
                        // on _currentTab so all tabs showed the same products.
                        return InventoryTable(
                          products: _getProductsForTab(tab),
                          type: _getItemTypeForTab(tab),
                          filters: _filters,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  int _getTabCount(String tab) {
    switch (tab) {
      case 'finished':
        return _products
            .where((p) => p.itemType.value == 'Finished Good')
            .length;
      case 'traded':
        return _products.where((p) => p.itemType.value == 'Traded Good').length;
      case 'raw':
        return _products
            .where((p) => p.itemType.value == 'Raw Material')
            .length;
      case 'semi':
        return _products
            .where((p) => p.itemType.value == 'Semi-Finished Good')
            .length;
      case 'oils':
        return _products
            .where((p) => p.itemType.value == 'Oils & Liquids')
            .length;
      case 'chemicals':
        return _products
            .where((p) => p.itemType.value == 'Chemicals & Additives')
            .length;
      case 'packaging':
        return _products
            .where((p) => p.itemType.value == 'Packaging Material')
            .length;
      default:
        return 0;
    }
  }

  String _getTabLabel(String tab) {
    switch (tab) {
      case 'finished':
        return 'Finished';
      case 'traded':
        return 'Traded';
      case 'raw':
        return 'Raw';
      case 'semi':
        return 'Semi';
      case 'oils':
        return 'Oils';
      case 'chemicals':
        return 'Chem';
      case 'packaging':
        return 'Pkg';
      default:
        return '';
    }
  }
}
