import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/dealer_repository.dart';
import '../../../services/suppliers_service.dart';
import '../../../services/customers_service.dart';
import '../../../services/dealers_service.dart';
import '../business_partner_form_dialog.dart';
import '../widgets/partner_transaction_history_dialog.dart';
import '../partner_data_cache.dart';
import '../../../widgets/ui/glass_container.dart';
import '../../../widgets/ui/custom_text_field.dart';
import '../../../widgets/dashboard/kpi_card.dart';
import '../../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AllPartnersListView extends StatefulWidget {
  const AllPartnersListView({super.key});

  @override
  State<AllPartnersListView> createState() => _AllPartnersListViewState();
}

class _AllPartnersListViewState extends State<AllPartnersListView>
    with AutomaticKeepAliveClientMixin {
  static const int _desktopRowStep = 120;
  List<dynamic> _allPartners = []; // Customer, Dealer, or Supplier
  List<dynamic> _filteredPartners = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All Status';
  String _typeFilter = 'All Types';
  int _desktopRowLimit = _desktopRowStep;

  @override
  void initState() {
    super.initState();
    _restoreFromCache();
    _loadAllPartners(showLoader: _allPartners.isEmpty);
  }

  void _restoreFromCache() {
    final cachedCustomers =
        BusinessPartnersDataCache.customers?.customers ?? [];
    final cachedDealers = BusinessPartnersDataCache.dealers ?? [];
    final cachedSuppliers =
        BusinessPartnersDataCache.suppliersByType('supplier') ?? [];
    final cachedVendors =
        BusinessPartnersDataCache.suppliersByType('vendor') ?? [];

    if (cachedCustomers.isEmpty &&
        cachedDealers.isEmpty &&
        cachedSuppliers.isEmpty &&
        cachedVendors.isEmpty) {
      return;
    }

    _allPartners = [
      ...cachedCustomers,
      ...cachedDealers,
      ...cachedSuppliers,
      ...cachedVendors,
    ];
    _filteredPartners = List<dynamic>.from(_allPartners);
    _isLoading = false;
  }

  Future<void> _loadAllPartners({bool showLoader = true}) async {
    try {
      if (mounted && showLoader) {
        setState(() => _isLoading = true);
      }

      final customerRepo = context.read<CustomerRepository>();
      final dealerRepo = context.read<DealerRepository>();
      final suppliersService = context.read<SuppliersService>();

      final results = await Future.wait([
        customerRepo.getAllCustomers(),
        dealerRepo.getAllDealers(),
        suppliersService.getSuppliers(),
      ]);

      final customers = (results[0] as List<dynamic>)
          .map((e) => e.toDomain() as Customer)
          .toList(); // CustomerEntity -> Customer
      final dealers = (results[1] as List<dynamic>)
          .map((e) => e.toDomain() as Dealer)
          .toList(); // DealerEntity -> Dealer
      final suppliers = results[2] as List<Supplier>;
      final suppliersOnly = suppliers.where((s) => s.type != 'vendor').toList();
      final vendorsOnly = suppliers.where((s) => s.type == 'vendor').toList();

      if (mounted) {
        setState(() {
          _allPartners = [...customers, ...dealers, ...suppliers];
          _applyFilters(notify: false);
          BusinessPartnersDataCache.dealers = dealers;
          BusinessPartnersDataCache.setSuppliersByType(
            'supplier',
            suppliersOnly,
          );
          BusinessPartnersDataCache.setSuppliersByType('vendor', vendorsOnly);
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

  void _applyFilters({bool notify = true}) {
    final filteredPartners = _allPartners.where((p) {
      String name = '';
      String contact = '';
      String mobile = '';
      String status = 'active';

      if (p is Customer) {
        name = p.shopName;
        contact = p.ownerName;
        mobile = p.mobile;
        status = p.status;
      } else if (p is Dealer) {
        name = p.name;
        contact = p.contactPerson;
        mobile = p.mobile;
        status = p.status ?? 'active';
      } else if (p is Supplier) {
        name = p.name;
        contact = p.contactPerson;
        mobile = p.mobile;
        status = p.status;
      }

      final matchesQuery =
          name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          contact.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          mobile.contains(_searchController.text);

      final matchesStatus =
          _statusFilter == 'All Status' ||
          (_statusFilter == 'Active' && status == 'active') ||
          (_statusFilter == 'Inactive' && status != 'active');

      final matchesType =
          _typeFilter == 'All Types' ||
          (_typeFilter == 'Customers' && p is Customer) ||
          (_typeFilter == 'Dealers' && p is Dealer) ||
          (_typeFilter == 'Suppliers' && p is Supplier && p.type != 'vendor') ||
          (_typeFilter == 'Vendors' && p is Supplier && p.type == 'vendor');

      return matchesQuery && matchesStatus && matchesType;
    }).toList();

    if (!notify) {
      _filteredPartners = filteredPartners;
      _desktopRowLimit = _desktopRowStep;
      return;
    }
    setState(() {
      _filteredPartners = filteredPartners;
      _desktopRowLimit = _desktopRowStep;
    });
  }

  Future<void> _showDialog(dynamic partner) async {
    final PartnerType type;
    if (partner == null) {
      type = PartnerType.customer;
    } else if (partner is Customer) {
      type = PartnerType.customer;
    } else if (partner is Dealer) {
      type = PartnerType.dealer;
    } else {
      final s = partner as Supplier;
      type = s.type == 'vendor' ? PartnerType.vendor : PartnerType.supplier;
    }

    final isMobile = MediaQuery.sizeOf(context).width < 700;
    if (isMobile) {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (routeContext) => BusinessPartnerFormDialog(
            initialType: type,
            existingPartner: partner,
            fullScreen: true,
            onSaved: () => Navigator.of(routeContext).pop(true),
          ),
        ),
      );
      if (saved == true && mounted) {
        _loadAllPartners(showLoader: false);
      }
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => BusinessPartnerFormDialog(
        initialType: type,
        existingPartner: partner,
        onSaved: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (saved == true && mounted) {
      _loadAllPartners(showLoader: false);
    }
  }

  Future<void> _showPartnerHistory(dynamic partner) async {
    if (partner is Customer) {
      await PartnerTransactionHistoryDialog.showSalesHistory(
        context,
        partnerId: partner.id,
        partnerName: partner.shopName,
        recipientType: 'customer',
      );
      return;
    }

    if (partner is Dealer) {
      await PartnerTransactionHistoryDialog.showSalesHistory(
        context,
        partnerId: partner.id,
        partnerName: partner.name,
        recipientType: 'dealer',
      );
      return;
    }

    if (partner is Supplier) {
      await PartnerTransactionHistoryDialog.showPurchaseHistory(
        context,
        supplierId: partner.id,
        supplierName: partner.name,
        isVendor: partner.type == 'vendor',
      );
    }
  }

  String _partnerTypeLabel(dynamic partner) {
    if (partner is Customer) return 'Customer';
    if (partner is Dealer) return 'Dealer';
    if (partner is Supplier && partner.type == 'vendor') return 'Vendor';
    return 'Supplier';
  }

  Color _partnerTypeColor(dynamic partner, ThemeData theme) {
    if (partner is Customer) return AppColors.info;
    if (partner is Dealer) return AppColors.warning;
    if (partner is Supplier && partner.type == 'vendor') return AppColors.info;
    if (partner is Supplier) return AppColors.lightPrimary;
    return theme.colorScheme.onSurfaceVariant;
  }

  String _partnerName(dynamic partner) {
    if (partner is Customer) return partner.shopName;
    if (partner is Dealer) return partner.name;
    if (partner is Supplier) return partner.name;
    return '';
  }

  String _partnerContact(dynamic partner) {
    if (partner is Customer) return partner.ownerName;
    if (partner is Dealer) return partner.contactPerson;
    if (partner is Supplier) return partner.contactPerson;
    return '';
  }

  String _partnerMobile(dynamic partner) {
    if (partner is Customer) return partner.mobile;
    if (partner is Dealer) return partner.mobile;
    if (partner is Supplier) return partner.mobile;
    return '';
  }

  String _partnerStatus(dynamic partner) {
    if (partner is Customer) return partner.status;
    if (partner is Dealer) return partner.status ?? 'active';
    if (partner is Supplier) return partner.status;
    return 'active';
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    final normalized = status.toLowerCase();
    final isActive = normalized == 'active';
    final color = isActive ? AppColors.success : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildMobilePartnersList(ThemeData theme) {
    if (_filteredPartners.isEmpty) {
      return Center(
        child: Text(
          'No partners found',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 86),
      itemCount: _filteredPartners.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final partner = _filteredPartners[index];
        final type = _partnerTypeLabel(partner);
        final typeColor = _partnerTypeColor(partner, theme);
        final name = _partnerName(partner);
        final contact = _partnerContact(partner);
        final mobile = _partnerMobile(partner);
        final status = _partnerStatus(partner);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showDialog(partner),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (contact.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      contact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (mobile.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      mobile,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(theme, status),
                      const Spacer(),
                      IconButton(
                        tooltip: 'History',
                        onPressed: () => _showPartnerHistory(partner),
                        icon: Icon(
                          Icons.receipt_long_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _showDialog(partner),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // KPI Calculations
    final total = _allPartners.length;
    final customersCount = _allPartners.whereType<Customer>().length;
    final dealersCount = _allPartners.whereType<Dealer>().length;
    final suppliersCount = _allPartners.whereType<Supplier>().length;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 900;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              MasterScreenHeader(
                title: 'Business Partners',
                subtitle: 'Overview of all business relationships.',
                icon: Icons.pie_chart_outline,
                color: AppColors.info,
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showDialog(null),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Partner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: isMobile
                    ? Padding(
                        // [LOCKED] Mobile must use virtualized list (not DataTable)
                        // to prevent ANR on large partner datasets.
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Column(
                          children: [
                            _buildFilterSection(theme),
                            const SizedBox(height: 12),
                            Expanded(child: _buildMobilePartnersList(theme)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildKPISection(
                              total,
                              customersCount,
                              dealersCount,
                              suppliersCount,
                              theme,
                            ),
                            const SizedBox(height: 32),
                            _buildFilterSection(theme),
                            const SizedBox(height: 16),
                            _buildTableSection(theme),
                          ],
                        ),
                      ),
              ),
            ],
          );
  }

  Widget _buildKPISection(
    int total,
    int customers,
    int dealers,
    int suppliers,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final cardWidth = isMobile
            ? (constraints.maxWidth - 16) / 2
            : (constraints.maxWidth - 48) / 4;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Total Partners',
                value: total.toString(),
                icon: Icons.pie_chart,
                color: AppColors.info,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Customers',
                value: customers.toString(),
                icon: Icons.group_outlined,
                color: AppColors.info,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Dealers',
                value: dealers.toString(),
                icon: Icons.store_outlined,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Suppliers',
                value: suppliers.toString(),
                icon: Icons.local_shipping_outlined,
                color: AppColors.lightPrimary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    final searchField = CustomTextField(
      label: '',
      controller: _searchController,
      hintText: 'Search partners...',
      prefixIcon: Icons.search_rounded,
      isDense: true,
      onChanged: (val) => _applyFilters(),
    );

    final typeFilter = GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      borderRadius: 20,
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: theme.colorScheme.surface,
          value: _typeFilter,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.primary,
          ),
          items: ['All Types', 'Customers', 'Dealers', 'Suppliers', 'Vendors']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _typeFilter = val);
              _applyFilters();
            }
          },
        ),
      ),
    );

    final statusFilter = GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      borderRadius: 20,
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: theme.colorScheme.surface,
          value: _statusFilter,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.primary,
          ),
          items: ['All Status', 'Active', 'Inactive']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _statusFilter = val);
              _applyFilters();
            }
          },
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 840;
        if (isNarrow) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: typeFilter),
                  const SizedBox(width: 10),
                  Expanded(child: statusFilter),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 2, child: searchField),
            const SizedBox(width: 12),
            SizedBox(width: 190, child: typeFilter),
            const SizedBox(width: 12),
            SizedBox(width: 190, child: statusFilter),
          ],
        );
      },
    );
  }

  Widget _buildTableSection(ThemeData theme) {
    final visiblePartners = _filteredPartners.take(_desktopRowLimit).toList();
    final hasMore = _filteredPartners.length > visiblePartners.length;
    final remainingRows = _filteredPartners.length - visiblePartners.length;
    final loadCount = remainingRows > _desktopRowStep
        ? _desktopRowStep
        : remainingRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.02),
                blurRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1000),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerLow,
                  ),
                  horizontalMargin: 24,
                  columnSpacing: 24,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 60,
                  columns: [
                    const DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Contact Person',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Mobile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  rows: visiblePartners.map((p) {
                    String type = '';
                    String name = '';
                    String contact = '';
                    String mobile = '';
                    String status = 'active';
                    Color typeColor = theme.colorScheme.onSurfaceVariant;

                    if (p is Customer) {
                      type = 'Customer';
                      typeColor = AppColors.info;
                      name = p.shopName;
                      contact = p.ownerName;
                      mobile = p.mobile;
                      status = p.status;
                    } else if (p is Dealer) {
                      type = 'Dealer';
                      typeColor = AppColors.warning;
                      name = p.name;
                      contact = p.contactPerson;
                      mobile = p.mobile;
                      status = p.status ?? 'active';
                    } else if (p is Supplier) {
                      if (p.type == 'vendor') {
                        type = 'Vendor';
                        typeColor = AppColors.info;
                      } else {
                        type = 'Supplier';
                        typeColor = AppColors.lightPrimary;
                      }
                      name = p.name;
                      contact = p.contactPerson;
                      mobile = p.mobile;
                      status = p.status;
                    }

                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: typeColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            contact,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            mobile,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'active'
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: status == 'active'
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : theme.colorScheme.outline.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status == 'active'
                                      ? Icons.check
                                      : Icons.close,
                                  size: 12,
                                  color: status == 'active'
                                      ? AppColors.success
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status == 'active' ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: status == 'active'
                                        ? AppColors.success
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'View history',
                                icon: Icon(
                                  Icons.receipt_long_outlined,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () => _showPartnerHistory(p),
                              ),
                              IconButton(
                                tooltip: 'Edit partner',
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => _showDialog(p),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        if (hasMore) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _desktopRowLimit = (_desktopRowLimit + _desktopRowStep).clamp(
                    _desktopRowStep,
                    _filteredPartners.length,
                  );
                });
              },
              icon: const Icon(Icons.expand_more),
              label: Text('Load $loadCount more'),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
