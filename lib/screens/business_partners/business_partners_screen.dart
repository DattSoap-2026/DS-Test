import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/user_types.dart';
import '../../data/repositories/dealer_repository.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/suppliers_service.dart';
import 'views/all_partners_list_view.dart';
import 'views/customers_list_view.dart';
import 'views/dealers_list_view.dart';
import 'views/suppliers_list_view.dart';
import 'partner_data_cache.dart';
import 'business_partner_form_dialog.dart'; // Import for PartnerType
import '../../widgets/ui/themed_tab_bar.dart';

class BusinessPartnersScreen extends StatefulWidget {
  final int initialTabIndex; // 0=All, 1=Cust, 2=Deal, 3=Supp, 4=Vend

  const BusinessPartnersScreen({super.key, this.initialTabIndex = 0});

  @override
  State<BusinessPartnersScreen> createState() => _BusinessPartnersScreenState();
}

class _BusinessPartnersScreenState extends State<BusinessPartnersScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<_TabDefinition> _availableTabs = [];
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTabs();
    });
  }

  void _initTabs() {
    final user = context.read<AuthProvider>().state.user;
    final role = user?.role;

    List<_TabDefinition> tabs = [];

    // Define all possible tabs
    final allTab = _TabDefinition(
      id: 0,
      label: 'All',
      widget: const AllPartnersListView(),
    );
    final custTab = _TabDefinition(
      id: 1,
      label: 'Customers',
      widget: const CustomersListView(),
    );
    final dealTab = _TabDefinition(
      id: 2,
      label: 'Dealers',
      widget: const DealersListView(),
    );
    final suppTab = _TabDefinition(
      id: 3,
      label: 'Suppliers',
      widget: const SuppliersListView(partnerType: PartnerType.supplier),
    );
    final vendTab = _TabDefinition(
      id: 4,
      label: 'Service Vendors',
      widget: const SuppliersListView(partnerType: PartnerType.vendor),
    );

    // Filter based on Role
    if (role == UserRole.admin || role == UserRole.owner) {
      tabs = [allTab, custTab, dealTab, suppTab, vendTab];
    } else if (role == UserRole.salesman) {
      // Salesman explicitly allowed only Customers
      tabs = [custTab];
    } else if (role == UserRole.storeIncharge) {
      // Store Incharge explicitly allowed Suppliers & Vendors
      tabs = [suppTab, vendTab];
    } else if (role == UserRole.dealerManager) {
      // Dealer Manager explicitly allowed only Dealers
      tabs = [dealTab];
    } else {
      // Fallback or explicit denial
      tabs = [];
    }

    if (mounted) {
      setState(() {
        _availableTabs = tabs;
        _isLoadingRole = false;

        if (tabs.isNotEmpty) {
          // Determine initial index based on requested logical ID
          int targetIndex = 0;
          for (int i = 0; i < tabs.length; i++) {
            if (tabs[i].id == widget.initialTabIndex) {
              targetIndex = i;
              break;
            }
          }

          _tabController = TabController(
            length: tabs.length,
            vsync: this,
            initialIndex: targetIndex,
            animationDuration: const Duration(milliseconds: 200),
          );
        }
      });
      _warmUpTabCaches(tabs);
    }
  }

  void _warmUpTabCaches(List<_TabDefinition> tabs) {
    final isMobile = MediaQuery.sizeOf(context).width < 900;
    if (isMobile) {
      // [LOCKED] Skip background warm-up on phones to avoid startup jank/ANR on
      // large partner datasets. Individual tabs still load data on demand.
      return;
    }

    final availableIds = tabs.map((tab) => tab.id).toSet();
    if (availableIds.contains(0)) {
      // All tab already fetches customers + dealers + suppliers in a single pass.
      // Warming dealers/suppliers here duplicates local I/O on first open.
      return;
    }

    if (availableIds.contains(2) && BusinessPartnersDataCache.dealers == null) {
      unawaited(() async {
        try {
          final dealerRepo = context.read<DealerRepository>();
          final entities = await dealerRepo.getAllDealers();
          BusinessPartnersDataCache.dealers = entities
              .map((entity) => entity.toDomain())
              .toList();
        } catch (_) {
          // Silent: warm-up should never block UI.
        }
      }());
    }

    void warmSuppliersIfNeeded({required int tabId, required String type}) {
      if (!availableIds.contains(tabId)) return;
      if (BusinessPartnersDataCache.suppliersByType(type) != null) return;
      unawaited(() async {
        try {
          final suppliersService = context.read<SuppliersService>();
          final suppliers = await suppliersService.getSuppliers(type: type);
          BusinessPartnersDataCache.setSuppliersByType(type, suppliers);
        } catch (_) {
          // Silent: warm-up should never block UI.
        }
      }());
    }

    warmSuppliersIfNeeded(tabId: 3, type: 'supplier');
    warmSuppliersIfNeeded(tabId: 4, type: 'vendor');
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_availableTabs.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Access Denied: You do not have permission to view Business Partners.',
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final showTabHeader = !isMobile || _availableTabs.length > 1;

    return Column(
      children: [
        if (showTabHeader)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: ThemedTabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: _availableTabs
                  .map((t) => Tab(text: t.label.toUpperCase()))
                  .toList(),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _availableTabs.map((t) {
              final tabId = t.id;
              if (tabId == 0) {
                return const AllPartnersListView(key: PageStorageKey('all'));
              }
              if (tabId == 1) {
                return const CustomersListView(key: PageStorageKey('cust'));
              }
              if (tabId == 2) {
                return const DealersListView(key: PageStorageKey('deal'));
              }

              if (tabId == 3) {
                return const SuppliersListView(
                  key: PageStorageKey('supp'),
                  partnerType: PartnerType.supplier,
                );
              }
              return const SuppliersListView(
                key: PageStorageKey('vend'),
                partnerType: PartnerType.vendor,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TabDefinition {
  final int id;
  final String label;
  final Widget widget;

  _TabDefinition({required this.id, required this.label, required this.widget});
}
