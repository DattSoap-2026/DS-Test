import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/master_data_service.dart';

import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class SystemMastersScreen extends StatefulWidget {
  final bool isReadOnly;
  final VoidCallback? onBack;
  final bool showHeader;
  const SystemMastersScreen({
    super.key,
    this.isReadOnly = false,
    this.onBack,
    this.showHeader = true,
  });

  @override
  State<SystemMastersScreen> createState() => _SystemMastersScreenState();
}

class _SystemMastersScreenState extends State<SystemMastersScreen>
    with SingleTickerProviderStateMixin {
  MasterDataService get _service => context.read<MasterDataService>();
  late TabController _tabController;
  bool _isLoading = true;

  List<ProductCategory> _categories = [];
  List<DynamicProductType> _productTypes = [];
  List<String> _units = [];

  void _showReadOnlyWarning() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Read-only mode: changes are disabled.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  // Filter Search states
  String _categorySearchQuery = '';
  String? _categoryTypeFilter;
  String _typeSearchQuery = '';

  List<ProductCategory> get _filteredCategories {
    var list = _categories;
    if (_categorySearchQuery.isNotEmpty) {
      list = list
          .where(
            (c) => c.name.toLowerCase().contains(
              _categorySearchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    if (_categoryTypeFilter != null) {
      list = list.where((c) => c.itemType == _categoryTypeFilter).toList();
    }
    return list;
  }

  List<DynamicProductType> get _filteredProductTypes {
    if (_typeSearchQuery.isEmpty) return _productTypes;
    return _productTypes
        .where(
          (t) =>
              t.name.toLowerCase().contains(_typeSearchQuery.toLowerCase()) ||
              t.description.toLowerCase().contains(
                _typeSearchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _service.getCategories();
      final productTypes = await _service.getProductTypes();
      final units = await _service.getUnits();
      if (mounted) {
        setState(() {
          _categories = categories;
          _productTypes = productTypes;
          _units = units;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.showHeader) _buildScreenHeader(),
                ThemedTabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Categories'),
                    Tab(text: 'Product Types'),
                    Tab(text: 'Units'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCategoriesTab(),
                      _buildProductTypesTab(),
                      _buildUnitsTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: widget.isReadOnly
          ? null
          : FloatingActionButton(
              heroTag: 'system_masters_fab',
              onPressed: _handleAddPress,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            ),
    );
  }

  Future<void> _handleDeepAudit() async {
    setState(() => _isLoading = true);
    final result = await _service.deepAuditAndSyncProducts();
    await _loadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deep Audit Complete: ${result['fixed']} product mappings verified and fixed.',
          ),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  Widget _buildScreenHeader() {
    return MasterScreenHeader(
      title: 'Global Masters',
      subtitle: 'Common reference data for entire system',
      helperText: 'Changes here affect all modules. Edit carefully.',
      color: AppColors.info,
      icon: Icons.settings_applications,
      emoji: '',
      onBack: widget.onBack,
      isReadOnly: widget.isReadOnly,
      actions: [
        if (!widget.isReadOnly) ...[
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.info),
            onSelected: (val) {
              if (val == 'fix_soap') _handleFixSoapBase();
              if (val == 'fix_geeta') _handleFixGeeta();
              if (val == 'audit_cleanup') _handleAuditCleanup();
              if (val == 'deep_audit') _handleDeepAudit();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'fix_soap',
                child: Text('Fix Soap Base Category'),
              ),
              const PopupMenuItem(
                value: 'fix_geeta',
                child: Text('Fix Geeta  Gita'),
              ),
              const PopupMenuItem(
                value: 'audit_cleanup',
                child: Text('Audit & Cleanup Duplicates'),
              ),
              const PopupMenuItem(
                value: 'deep_audit',
                child: Text('Audit & Link Products'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _handleAuditCleanup() async {
    setState(() => _isLoading = true);
    final result = await _service.deduplicateMasters();
    await _loadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Audit Complete: ${result['categories']} categories, ${result['types']} types deduplicated.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _buildUnitsTab() {
    if (_units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No units found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.isReadOnly ? null : _showAddUnitDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Unit'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _units.length,
      itemBuilder: (context, index) {
        final unit = _units[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.info.withValues(alpha: 0.1),
              child: const Icon(
                Icons.confirmation_number,
                color: AppColors.info,
              ),
            ),
            title: Text(
              unit,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: widget.isReadOnly
                  ? null
                  : () => _confirmDelete('unit', unit),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        _buildCategoryFilterBar(),
        Expanded(
          child: _filteredCategories.isEmpty
              ? _buildEmptyCategoriesState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _filteredCategories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Type: ${cat.itemType}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.info,
                              ),
                              onPressed: widget.isReadOnly
                                  ? null
                                  : () =>
                                        _showAddCategoryDialog(category: cat),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: widget.isReadOnly
                                  ? null
                                  : () => _confirmDelete('category', cat.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Categories...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              onChanged: (val) => setState(() => _categorySearchQuery = val),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _categoryTypeFilter,
                hint: const Text('All Types', style: TextStyle(fontSize: 13)),
                items: () {
                  final Set<String> typeNames = _productTypes
                      .map((e) => e.name)
                      .toSet();
                  if (_categoryTypeFilter != null) {
                    typeNames.add(_categoryTypeFilter!);
                  }

                  return [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...typeNames.map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(e),
                              size: 16,
                              color: _getTypeColor(e),
                            ),
                            const SizedBox(width: 12),
                            Text(e, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ];
                }(),
                onChanged: (val) => setState(() => _categoryTypeFilter = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _categories.isEmpty ? 'No categories found' : 'No results found',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_categories.isEmpty)
            ElevatedButton.icon(
              onPressed: widget.isReadOnly ? null : _showAddCategoryDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _categorySearchQuery = '';
                  _categoryTypeFilter = null;
                });
              },
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildProductTypesTab() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Product Types...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            onChanged: (val) => setState(() => _typeSearchQuery = val),
          ),
        ),
        Expanded(
          child: _filteredProductTypes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _productTypes.isEmpty
                            ? 'No product types found'
                            : 'No types match your search',
                      ),
                      const SizedBox(height: 16),
                      if (_productTypes.isEmpty)
                        ElevatedButton.icon(
                          onPressed: widget.isReadOnly
                              ? null
                              : _showAddProductTypeDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product Type'),
                        )
                      else
                        TextButton(
                          onPressed: () =>
                              setState(() => _typeSearchQuery = ''),
                          child: const Text('Clear Search'),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredProductTypes.length,
                  itemBuilder: (context, index) {
                    final type = _filteredProductTypes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _parseHexColor(
                            type.color,
                          ).withValues(alpha: 0.1),
                          child: Icon(
                            Icons.category,
                            color: _parseHexColor(type.color),
                          ),
                        ),
                        title: Text(
                          type.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(type.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.info,
                              ),
                              onPressed: widget.isReadOnly
                                  ? null
                                  : () =>
                                        _showAddProductTypeDialog(type: type),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: widget.isReadOnly
                                  ? null
                                  : () =>
                                        _confirmDelete('product_type', type.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _handleFixSoapBase() async {
    setState(() => _isLoading = true);
    final result = await _service.fixAllSemiFinishedToSoapBase();
    await _loadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fix Complete: ${result['products']} products, ${result['formulas']} formulas updated',
          ),
        ),
      );
    }
  }

  Future<void> _handleFixGeeta() async {
    setState(() => _isLoading = true);
    final total = await _service.migrateGeetaToGita();
    await _loadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration Complete: $total items updated')),
      );
    }
  }

  Color _getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('raw')) return AppColors.warning;
    if (t.contains('packaging')) return AppColors.info;
    if (t.contains('semi')) return AppColors.warning;
    if (t.contains('traded')) return AppColors.lightPrimary;
    if (t.contains('finish')) return AppColors.success;
    return AppColors.lightTextMuted;
  }

  IconData _getTypeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('raw')) return Icons.auto_awesome_mosaic;
    if (t.contains('packaging')) return Icons.inventory_2;
    if (t.contains('semi')) return Icons.whatshot;
    if (t.contains('traded')) return Icons.store;
    if (t.contains('finish')) return Icons.verified;
    if (t.contains('oil') || t.contains('liquid')) return Icons.opacity;
    if (t.contains('chemical') || t.contains('add')) return Icons.science;
    return Icons.category;
  }

  Color _parseHexColor(String hex) {
    try {
      if (hex.startsWith('bg-')) {
        // Tailwind mapping fallback
        if (hex.contains('slate')) return AppColors.lightTextMuted;
        if (hex.contains('blue')) return AppColors.info;
        if (hex.contains('purple')) return AppColors.info;
        if (hex.contains('green')) return AppColors.success;
        if (hex.contains('indigo')) return AppColors.info;
        return AppColors.lightTextMuted;
      }
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.info;
    }
  }

  void _handleAddPress() {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    if (_tabController.index == 0) {
      _showAddCategoryDialog();
    } else if (_tabController.index == 1) {
      _showAddProductTypeDialog();
    } else {
      _showAddUnitDialog();
    }
  }

  void _showAddUnitDialog() {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Add Unit of Measure'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Unit Name (e.g. Kg)'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final unitName = controller.text.trim();
                final success = await _service.addUnit(unitName);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Unit "$unitName" added successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to add unit'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                  _loadAllData();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog({ProductCategory? category}) {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    String itemType = category?.itemType ?? 'Finished Good';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ResponsiveAlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5FEF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEdit ? 'Edit Category' : 'Add Category',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _productTypes.any((e) => e.name == itemType)
                    ? itemType
                    : (_productTypes.isNotEmpty
                          ? _productTypes.first.name
                          : 'Finished Good'),
                items: () {
                  final Set<String> allTypes = _productTypes
                      .map((e) => e.name)
                      .toSet();
                  if (!allTypes.contains(itemType)) allTypes.add(itemType);

                  return allTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList();
                }(),
                onChanged: (val) {
                  setDialogState(() {
                    itemType = val!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Item Type'),
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
                if (nameController.text.trim().isNotEmpty) {
                  if (isEdit) {
                    await _service.updateCategory(
                      category.id,
                      nameController.text.trim(),
                      itemType,
                    );
                  } else {
                    await _service.addCategory(
                      nameController.text.trim(),
                      itemType,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                  _loadAllData();
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductTypeDialog({DynamicProductType? type}) {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    final isEdit = type != null;
    final nameController = TextEditingController(text: type?.name ?? '');
    final descController = TextEditingController(text: type?.description ?? '');
    String color = type?.color ?? '#4F46E5';
    String? displayUnit = type?.displayUnit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ResponsiveAlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5FEF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEdit ? 'Edit Product Type' : 'Add Product Type',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Type Name',
                    helperText: isEdit ? 'Name cannot be changed' : null,
                  ),
                  enabled: !isEdit,
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Display Unit (Stock Screen)',
                    helperText: 'Unit to show in stock screens',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: displayUnit,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Default (baseUnit)')),
                        ..._units.map((u) => DropdownMenuItem(value: u, child: Text(u))),
                      ],
                      onChanged: (val) => setDialogState(() => displayUnit = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Color Label"),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      [
                            '#EF4444',
                            '#F59E0B',
                            '#10B981',
                            '#3B82F6',
                            '#6366F1',
                            '#8B5CF6',
                            '#EC4899',
                            '#64748B',
                          ]
                          .map(
                            (c) => InkWell(
                              onTap: () => setDialogState(() => color = c),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _parseHexColor(c),
                                  shape: BoxShape.circle,
                                  border: color == c
                                      ? Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          )
                          .toList(),
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
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                final data = {
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'skuPrefix': isEdit
                      ? type.skuPrefix
                      : 'PRD', // Hidden defaults
                  'defaultGst': isEdit ? type.defaultGst : 18.0,
                  'defaultUom': isEdit ? type.defaultUom : 'Pcs',
                  'displayUnit': displayUnit,
                  'color': color,
                  'iconName': 'Package',
                  'tabs': ['Basic', 'Inventory'],
                };

                if (isEdit) {
                  await _service.updateProductType(type.id, data);
                } else {
                  await _service.addProductType(data);
                }

                if (context.mounted) Navigator.pop(context);
                _loadAllData();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String type, String id) {
    if (widget.isReadOnly) {
      _showReadOnlyWarning();
      return;
    }
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              if (type == 'category') {
                await _service.deleteCategory(id);
              } else if (type == 'product_type') {
                await _service.deleteProductType(id);
              } else if (type == 'unit') {
                await _service.deleteUnit(id); // ID is name for units
              }
              if (context.mounted) Navigator.pop(context);
              _loadAllData();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }
}
