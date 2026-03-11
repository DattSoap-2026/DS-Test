import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/suppliers_service.dart';
import '../business_partner_form_dialog.dart';
import '../widgets/partner_transaction_history_dialog.dart';
import '../partner_data_cache.dart';
import '../../../widgets/ui/glass_container.dart';
import '../../../widgets/ui/custom_text_field.dart';
import '../../../widgets/dashboard/kpi_card.dart';
import '../../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class SuppliersListView extends StatefulWidget {
  final PartnerType partnerType;
  const SuppliersListView({super.key, this.partnerType = PartnerType.supplier});

  @override
  State<SuppliersListView> createState() => _SuppliersListViewState();
}

class _SuppliersListViewState extends State<SuppliersListView>
    with AutomaticKeepAliveClientMixin {
  late final SuppliersService _suppliersService;
  List<Supplier> _allSuppliers = [];
  List<Supplier> _filteredSuppliers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All Status';

  @override
  void initState() {
    super.initState();
    _suppliersService = context.read<SuppliersService>();
    _restoreFromCache();
    _loadSuppliers(showLoader: _allSuppliers.isEmpty);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _currentType =>
      widget.partnerType == PartnerType.vendor ? 'vendor' : 'supplier';

  void _restoreFromCache() {
    final cachedSuppliers = BusinessPartnersDataCache.suppliersByType(
      _currentType,
    );
    if (cachedSuppliers == null || cachedSuppliers.isEmpty) return;
    _allSuppliers = cachedSuppliers;
    _filteredSuppliers = List<Supplier>.from(cachedSuppliers);
    _isLoading = false;
  }

  Future<void> _loadSuppliers({bool showLoader = true}) async {
    try {
      if (mounted && showLoader) {
        setState(() {
          _isLoading = true;
        });
      }
      final suppliers = await _suppliersService.getSuppliers(
        type: _currentType,
      );
      if (mounted) {
        setState(() {
          _allSuppliers = suppliers;
          BusinessPartnersDataCache.setSuppliersByType(_currentType, suppliers);
          _applyFilters(notify: false);
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
    final filteredSuppliers = _allSuppliers.where((s) {
      final matchesQuery =
          s.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          s.contactPerson.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          s.mobile.contains(_searchController.text);

      final matchesStatus =
          _statusFilter == 'All Status' ||
          (_statusFilter == 'Active' && s.status == 'active') ||
          (_statusFilter == 'Inactive' && s.status != 'active');

      return matchesQuery && matchesStatus;
    }).toList();

    if (!notify) {
      _filteredSuppliers = filteredSuppliers;
      return;
    }
    setState(() {
      _filteredSuppliers = filteredSuppliers;
    });
  }

  Future<void> _handleDelete(Supplier supplier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Text(
          'Delete ${widget.partnerType == PartnerType.vendor ? 'Vendor' : 'Supplier'}',
        ),
        content: Text('Are you sure you want to delete ${supplier.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _suppliersService.deleteSupplier(supplier.id);
        if (!mounted) {
          return;
        }
        _loadSuppliers(showLoader: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.partnerType == PartnerType.vendor ? 'Vendor' : 'Supplier'} deleted successfully',
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _showSupplierDialog([Supplier? supplier]) async {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    if (isMobile) {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (routeContext) => BusinessPartnerFormDialog(
            initialType: widget.partnerType,
            existingPartner: supplier,
            fullScreen: true,
            onSaved: () => Navigator.of(routeContext).pop(true),
          ),
        ),
      );
      if (saved == true && mounted) {
        _loadSuppliers(showLoader: false);
      }
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => BusinessPartnerFormDialog(
        initialType: widget.partnerType,
        existingPartner: supplier,
        onSaved: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (saved == true && mounted) {
      _loadSuppliers(showLoader: false);
    }
  }

  Future<void> _showSupplierHistory(Supplier supplier) async {
    await PartnerTransactionHistoryDialog.showPurchaseHistory(
      context,
      supplierId: supplier.id,
      supplierName: supplier.name,
      isVendor: supplier.type == 'vendor',
    );
  }

  Widget _buildStatusChip(ThemeData theme, Supplier supplier) {
    final isActive = supplier.status == 'active';
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

  Widget _buildMobileSuppliersList(ThemeData theme, bool isVendor) {
    if (_filteredSuppliers.isEmpty) {
      return Center(
        child: Text(
          isVendor ? 'No vendors found' : 'No suppliers found',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 86),
      itemCount: _filteredSuppliers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final supplier = _filteredSuppliers[index];
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
            onTap: () => _showSupplierDialog(supplier),
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
                          supplier.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(theme, supplier),
                    ],
                  ),
                  if (supplier.contactPerson.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      supplier.contactPerson,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    supplier.mobile,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if ((supplier.email ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      supplier.email!.trim(),
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
                      Text(
                        '#${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (val) {
                          if (val == 'history') {
                            _showSupplierHistory(supplier);
                          } else if (val == 'edit') {
                            _showSupplierDialog(supplier);
                          } else if (val == 'delete') {
                            _handleDelete(supplier);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'history',
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('View History'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  isVendor ? 'Edit Vendor' : 'Edit Supplier',
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    final isVendor = widget.partnerType == PartnerType.vendor;
    final title = isVendor ? 'Service Vendors' : 'Suppliers';
    final subtitle = isVendor
        ? 'Manage your external service providers.'
        : 'Manage your raw material suppliers.';
    final icon = isVendor
        ? Icons.engineering_outlined
        : Icons.local_shipping_outlined;
    final addLabel = isVendor ? 'Add Vendor' : 'Add Supplier';
    final total = _allSuppliers.length;
    final active = _allSuppliers.where((s) => s.status == 'active').length;
    final inactive = total - active;
    final rate = total > 0 ? (active / total * 100).toStringAsFixed(1) : '0.0';
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 900;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              MasterScreenHeader(
                title: title,
                subtitle: subtitle,
                icon: icon,
                color: AppColors.info,
                actions: [
                  TextButton.icon(
                    onPressed: () => _showSupplierDialog(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(addLabel),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: isMobile
                    ? Padding(
                        // [LOCKED] Mobile must use virtualized list (not DataTable)
                        // to avoid UI freeze/ANR with large supplier lists.
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Column(
                          children: [
                            _buildFilterSection(theme),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _buildMobileSuppliersList(theme, isVendor),
                            ),
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
                              active,
                              inactive,
                              rate,
                              theme,
                              isVendor,
                            ),
                            const SizedBox(height: 32),
                            _buildFilterSection(theme),
                            const SizedBox(height: 16),
                            _buildTableSection(theme, isVendor),
                          ],
                        ),
                      ),
              ),
            ],
          );
  }

  Widget _buildKPISection(
    int total,
    int active,
    int inactive,
    String rate,
    ThemeData theme,
    bool isVendor,
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
                title: 'Total ${isVendor ? 'Vendors' : 'Suppliers'}',
                value: total.toString(),
                icon: Icons.group_outlined,
                color: AppColors.info,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Active ${isVendor ? 'Vendors' : 'Suppliers'}',
                value: active.toString(),
                icon: Icons.check_circle_outlined,
                color: AppColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Inactive',
                value: inactive.toString(),
                icon: Icons.pause_circle_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KPICard(
                title: 'Active Rate',
                value: '$rate%',
                icon: Icons.trending_up,
                color: AppColors.info,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    final countBadge = GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 14,
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Text(
        '${_filteredSuppliers.length}/${_allSuppliers.length}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.success,
        ),
      ),
    );
    final statusDropdown = GlassContainer(
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
        final isNarrow = constraints.maxWidth < 760;
        final searchField = CustomTextField(
          label: '',
          controller: _searchController,
          hintText: 'Search suppliers, vendors...',
          prefixIcon: Icons.search_rounded,
          isDense: true,
          onChanged: (val) => _applyFilters(),
        );

        if (isNarrow) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: statusDropdown),
                  const SizedBox(width: 10),
                  countBadge,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 12),
            SizedBox(width: 190, child: statusDropdown),
            const SizedBox(width: 10),
            countBadge,
          ],
        );
      },
    );
  }

  Widget _buildTableSection(ThemeData theme, bool isVendor) {
    return Container(
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
              showCheckboxColumn: false,
              columns: [
                const DataColumn(
                  label: Text(
                    'S.No',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '${isVendor ? 'Vendor' : 'Supplier'} Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Contact Person',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Contact Number',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
              rows: _filteredSuppliers.asMap().entries.map((entry) {
                final index = entry.key;
                final s = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        s.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        s.contactPerson,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        s.mobile,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        s.email ?? 'N/A',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                          color: s.status == 'active'
                              ? AppColors.success.withValues(alpha: 0.15)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: s.status == 'active'
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
                              s.status == 'active' ? Icons.check : Icons.close,
                              size: 12,
                              color: s.status == 'active'
                                  ? AppColors.success
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              s.status == 'active' ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: s.status == 'active'
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
                            onPressed: () => _showSupplierHistory(s),
                          ),
                          IconButton(
                            tooltip: isVendor ? 'Edit vendor' : 'Edit supplier',
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => _showSupplierDialog(s),
                          ),
                          IconButton(
                            tooltip: isVendor
                                ? 'Delete vendor'
                                : 'Delete supplier',
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppColors.error,
                            ),
                            onPressed: () => _handleDelete(s),
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
