import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../services/inventory_service.dart';
import '../../services/database_service.dart';
import '../../services/tank_service.dart';
import '../../services/department_service.dart';
import '../../data/repositories/tank_repository.dart';
import '../../data/local/entities/product_entity.dart';
import 'package:isar/isar.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../utils/unit_scope_utils.dart';

import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/themed_filter_chip.dart';
import '../../widgets/ui/shared/app_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';

class MaterialIssueScreen extends StatefulWidget {
  const MaterialIssueScreen({super.key});

  @override
  State<MaterialIssueScreen> createState() => _MaterialIssueScreenState();
}

class _MaterialIssueScreenState extends State<MaterialIssueScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TabController _tabController;

  String? _selectedDepartment;
  late final List<String> _departments;

  final List<Map<String, dynamic>> _cartItems = [];
  List<ProductEntity> _availableProducts = [];
  List<Tank> _allTanks = [];
  bool _isLoadingProducts = true;
  String _categoryFilter = 'All';
  TextEditingController? _productSearchController;
  final Map<String, TextEditingController> _qtyControllers = {};

  Tank? _selectedTank;
  final _tankQtyController = TextEditingController();
  String _tankDepartmentFilter = 'All'; // 'All', 'Sona', 'Gita'
  final _supplierNameController = TextEditingController();
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});

  @override
  void initState() {
    super.initState();
    _departments = DepartmentService().getDepartmentNames();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.state.user;
    _unitScope = resolveUserUnitScope(user);
    final isBhattiSupervisor = user?.role == UserRole.bhattiSupervisor;
    _tabController = TabController(
      length: isBhattiSupervisor ? 2 : 3,
      vsync: this,
    );
    _loadProducts();

    // Auto-set department filter for Bhatti Supervisors
    if (!_unitScope.canViewAll && _unitScope.keys.isNotEmpty) {
      final key = _unitScope.keys.first;
      _tankDepartmentFilter =
          key.substring(0, 1).toUpperCase() + key.substring(1);
    }

    _loadTanks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _tankQtyController.dispose();
    _supplierNameController.dispose();
    _productSearchController = null;
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final dbService = context.read<DatabaseService>();
      final products = await dbService.products
          .filter()
          .idGreaterThan('')
          .findAll();

      bool isIssuable(ProductEntity product) {
        final type = product.type.trim().toLowerCase();
        final itemType = product.itemType.trim().toLowerCase();
        if (type == 'raw' ||
            type == 'raw_material' ||
            type == 'packaging' ||
            type == 'packing_material') {
          return true;
        }
        return itemType == 'raw material' ||
            itemType == 'packaging material' ||
            itemType == 'oils & liquids' ||
            itemType == 'chemicals & additives';
      }

      final filteredProducts = products
          .where((p) => !p.isDeleted)
          .where((p) => (p.status ?? 'active').trim().toLowerCase() == 'active')
          .where(isIssuable)
          .toList();

      if (mounted) {
        setState(() {
          _availableProducts = filteredProducts;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  Future<void> _loadTanks() async {
    try {
      final bhattiName = _unitScope.canViewAll
          ? null
          : _unitScope.keys.firstOrNull;

      final tankRepo = context.read<TankRepository>();
      final tanks = await tankRepo.getTanks(bhattiName: bhattiName);
      if (mounted) {
        setState(() {
          _allTanks = tanks;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tanks: $e')));
      }
    }
  }

  Future<void> _addNewDepartment() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        maxWidth: 520,
        title: const Text('Add New Department'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Department Name',
            hintText: 'e.g. Gita Cutting',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(ctx, name);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        if (!_departments.contains(result)) {
          _departments.add(result);
        }
        _selectedDepartment = result;
      });
    }
  }

  void _addProductToCart(ProductEntity product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['productId'] == product.id,
    );
    if (existingIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is already in the cart'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if ((product.stock ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is out of stock'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _cartItems.add({
        'productId': product.id,
        'productName': product.name,
        'unit': product.baseUnit,
        'currentStock': product.stock ?? 0.0,
        'quantity': 0.0,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showAddMaterialDialog() async {
    final controller = TextEditingController();
    final unitController = TextEditingController(text: 'KG');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        maxWidth: 560,
        title: const Text('Add Raw Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Material Name',
                hintText: 'e.g. Coconut Oil',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g. KG, LTR',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.straighten),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              final unit = unitController.text.trim();
              if (name.isNotEmpty && unit.isNotEmpty) {
                Navigator.pop(ctx, {'name': name, 'unit': unit});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
    unitController.dispose();

    if (result != null && mounted) {
      setState(() {
        _cartItems.add({
          'productId': 'custom_${DateTime.now().millisecondsSinceEpoch}',
          'productName': result['name']!,
          'unit': result['unit']!,
          'currentStock': 0.0,
          'quantity': 0.0,
          'isCustom': true,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result['name']} added to cart'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _removeFromCart(int index) {
    final item = _cartItems[index];
    final controller = _qtyControllers.remove(item['productId']);
    controller?.dispose();
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Validate quantities
    bool hasInvalidQty = false;
    String? errorMessage;

    for (final item in _cartItems) {
      final qty = item['quantity'] as double;
      final currentStock = item['currentStock'] as double;
      final isCustom = item['isCustom'] == true;

      if (qty <= 0) {
        hasInvalidQty = true;
        errorMessage = 'Please enter valid quantities for all items';
        break;
      }

      if (!isCustom && qty > currentStock) {
        hasInvalidQty = true;
        errorMessage =
            '${item['productName']}: Quantity ($qty) exceeds stock ($currentStock)';
        break;
      }
    }

    if (hasInvalidQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Invalid quantities'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final inventoryService = context.read<InventoryService>();
      final currentUser = authProvider.state.user;
      if (currentUser == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        }
        return;
      }

      final itemsToIssue = _cartItems.map((item) {
        return {
          'productId': item['productId'],
          'productName': item['productName'],
          'quantity': item['quantity'],
          'unit': item['unit'],
        };
      }).toList();

      await inventoryService.transferToDepartment(
        departmentName: _selectedDepartment!,
        items: itemsToIssue,
        issuedByUserId: currentUser.id,
        issuedByUserName: currentUser.name,
        notes: 'Manual Issue via App',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_cartItems.length} material(s) issued to $_selectedDepartment successfully',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppDialog.show(
          context,
          title: 'Error',
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Iterable<ProductEntity> _getFilteredProducts() {
    final cartProductIds = _cartItems.map((item) => item['productId']).toSet();
    var filtered = _availableProducts.where(
      (p) => !cartProductIds.contains(p.id),
    );

    // Get tank material names to exclude
    final tankMaterialNames = _allTanks
        .map((t) => t.materialName.toLowerCase())
        .toSet();

    if (_categoryFilter == 'Raw Material') {
      filtered = filtered.where((p) {
        final type = p.type.trim().toLowerCase();
        final itemType = p.itemType.trim().toLowerCase();
        final name = p.name.toLowerCase();
        // Exclude tank materials
        if (tankMaterialNames.contains(name)) return false;
        return type == 'raw' ||
            type == 'raw_material' ||
            itemType == 'raw material' ||
            itemType == 'oils & liquids' ||
            itemType == 'chemicals & additives';
      });
    } else if (_categoryFilter == 'Packing') {
      filtered = filtered.where((p) {
        final type = p.type.trim().toLowerCase();
        final itemType = p.itemType.trim().toLowerCase();
        return type == 'packaging' ||
            type == 'packing_material' ||
            itemType == 'packaging material';
      });
    } else {
      // For 'All', exclude tank materials
      filtered = filtered.where(
        (p) => !tankMaterialNames.contains(p.name.toLowerCase()),
      );
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProducts) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final user = context.read<AuthProvider>().state.user;
    final isBhattiSupervisor = user?.role == UserRole.bhattiSupervisor;

    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Issue Materials',
            subtitle: isBhattiSupervisor
                ? 'Refill tanks and godowns'
                : 'Transfer stock to department',
            icon: Icons.output_rounded,
            color: theme.colorScheme.primary,
            onBack: () => context.pop(),
            actions: [
              IconButton(
                onPressed: () {
                  _loadProducts();
                  _loadTanks();
                },
                icon: const Icon(Icons.sync_rounded),
                tooltip: 'Refresh',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          TabBar(
            controller: _tabController,
            tabs: isBhattiSupervisor
                ? const [Tab(text: 'Refill Tank'), Tab(text: 'Refill Godown')]
                : const [
                    Tab(text: 'Issue Material'),
                    Tab(text: 'Refill Tank'),
                    Tab(text: 'Refill Godown'),
                  ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: isBhattiSupervisor
                  ? [_buildRefillTab('tank'), _buildRefillTab('godown')]
                  : [
                      _buildIssueMaterialTab(),
                      _buildRefillTab('tank'),
                      _buildRefillTab('godown'),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentSelection() {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'STEP 1 — SELECT DEPARTMENT',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._departments.map((dept) {
                final selected = _selectedDepartment == dept;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDepartment = dept),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      dept,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: _addNewDepartment,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 15,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add Dept.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMaterialSection() {
    return Row(
      children: [
        Expanded(child: _buildProductSearch()),
        const SizedBox(width: 12),
        CustomButton(
          label: 'Add Material',
          onPressed: () => _showAddMaterialDialog(),
          icon: Icons.add_circle_outline,
          variant: ButtonVariant.outlined,
        ),
      ],
    );
  }

  Widget _buildProductSearch() {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Autocomplete<ProductEntity>(
              displayStringForOption: (option) => option.name,
              optionsBuilder: (textEditingValue) {
                final filtered = _getFilteredProducts();
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<ProductEntity>.empty();
                }
                return filtered.where(
                  (p) => p.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (product) {
                _addProductToCart(product);
                _productSearchController?.clear();
                FocusScope.of(context).unfocus();
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _productSearchController = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search material name...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  controller.clear();
                                  focusNode.requestFocus();
                                },
                              )
                            : Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.3),
                              ),
                      ),
                      onSubmitted: (value) {
                        onFieldSubmitted();
                        controller.clear();
                      },
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      elevation: 20,
                      shadowColor: theme.shadowColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final ProductEntity option = options.elementAt(
                              index,
                            );
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                option.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    option.itemType,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 1,
                                    height: 10,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.inventory_2_rounded,
                                    size: 11,
                                    color: (option.stock ?? 0) > 0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${(option.stock ?? 0).toStringAsFixed(1)} ${option.baseUnit}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: (option.stock ?? 0) > 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          ThemedFilterChip(
            label: 'All',
            selected: _categoryFilter == 'All',
            onSelected: () => setState(() => _categoryFilter = 'All'),
          ),
          const SizedBox(width: 8),
          ThemedFilterChip(
            label: 'Raw Material',
            selected: _categoryFilter == 'Raw Material',
            onSelected: () => setState(() => _categoryFilter = 'Raw Material'),
          ),
          const SizedBox(width: 8),
          ThemedFilterChip(
            label: 'Packing',
            selected: _categoryFilter == 'Packing',
            onSelected: () => setState(() => _categoryFilter = 'Packing'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartTable() {
    final theme = Theme.of(context);
    if (_cartItems.isEmpty) {
      return UnifiedCard(
        padding: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 220),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No materials added yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search and add materials above to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return UnifiedCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text('PRODUCT NAME', style: _headerStyle(theme)),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text('QUANTITY', style: _headerStyle(theme)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text('STOCK', style: _headerStyle(theme)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('ACTION', style: _headerStyle(theme)),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 24,
              endIndent: 24,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item['productName'] as String).toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(child: _buildQuantityInput(item, index)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(item['currentStock'] as double).toStringAsFixed(1)} ${item['unit']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => _removeFromCart(index),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.5,
                            ),
                            size: 20,
                          ),
                          tooltip: 'Remove Item',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(ThemeData theme) {
    return theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    );
  }

  Widget _buildQuantityInput(Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);
    final controller = _qtyControllers.putIfAbsent(
      item['productId'],
      () => TextEditingController(
        text: item['quantity'] == 0.0 ? '' : item['quantity'].toString(),
      ),
    );

    final currentStock = item['currentStock'] as double;
    final isCustom = item['isCustom'] == true;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72, maxWidth: 104),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: false),
          ],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: theme.colorScheme.primary,
          maxLines: 1,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
                width: 1.4,
              ),
            ),
            hintText: '0',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            suffix: Text(
              item['unit'],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          onChanged: (val) {
            final qty = double.tryParse(val) ?? 0.0;

            // Validate against stock for non-custom items
            if (!isCustom && qty > currentStock) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Quantity exceeds available stock (${currentStock.toStringAsFixed(1)} ${item['unit']})',
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            setState(() {
              _cartItems[index]['quantity'] = qty;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSummaryAndSubmit() {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (_cartItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_cartItems.length} material(s) · To: $_selectedDepartment',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        CustomButton(
          label: 'CONFIRM MATERIAL ISSUE',
          onPressed: _submit,
          isLoading: _isLoading,
          icon: Icons.check_circle_rounded,
        ),
      ],
    );
  }

  Widget _buildIssueMaterialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDepartmentSelection(),
            const SizedBox(height: 24),
            if (_selectedDepartment != null) ...[
              _buildAddMaterialSection(),
              const SizedBox(height: 24),
              _buildCartTable(),
              const SizedBox(height: 24),
              _buildSummaryAndSubmit(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRefillTab(String type) {
    var tanks = _allTanks.where((t) => t.type == type).toList();
    final user = context.read<AuthProvider>().state.user;
    final isBhattiSupervisor = user?.role == UserRole.bhattiSupervisor;

    // Apply department filter
    if (_tankDepartmentFilter != 'All') {
      tanks = tanks
          .where(
            (t) => t.department.toLowerCase().contains(
              _tankDepartmentFilter.toLowerCase(),
            ),
          )
          .toList();
    }

    final theme = Theme.of(context);

    // Get purchase stock for selected tank material
    ProductEntity? purchaseStock;
    if (_selectedTank != null) {
      try {
        purchaseStock = _availableProducts.firstWhere(
          (p) =>
              p.name.toLowerCase() == _selectedTank!.materialName.toLowerCase(),
        );
      } catch (_) {
        purchaseStock = null;
      }

      // Auto-populate supplier name from product
      if (purchaseStock != null && _supplierNameController.text.isEmpty) {
        _supplierNameController.text = purchaseStock.supplierName ?? '';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Department Filter - only show if Admin
          if (!isBhattiSupervisor)
            UnifiedCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'FILTER:',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ThemedFilterChip(
                    label: 'All',
                    selected: _tankDepartmentFilter == 'All',
                    onSelected: () => setState(() {
                      _tankDepartmentFilter = 'All';
                      _selectedTank = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  ThemedFilterChip(
                    label: 'Sona',
                    selected: _tankDepartmentFilter == 'Sona',
                    onSelected: () => setState(() {
                      _tankDepartmentFilter = 'Sona';
                      _selectedTank = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  ThemedFilterChip(
                    label: 'Gita',
                    selected: _tankDepartmentFilter == 'Gita',
                    onSelected: () => setState(() {
                      _tankDepartmentFilter = 'Gita';
                      _selectedTank = null;
                    }),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Tank Selection
          UnifiedCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT ${type.toUpperCase()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 14),
                if (tanks.isEmpty)
                  Text(
                    'No ${type}s available for selected filter',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tanks.map((tank) {
                      final selected = _selectedTank?.id == tank.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTank = tank;
                            // Auto-populate supplier from product
                            try {
                              final product = _availableProducts.firstWhere(
                                (p) =>
                                    p.name.toLowerCase() ==
                                    tank.materialName.toLowerCase(),
                              );
                              _supplierNameController.text =
                                  product.supplierName ?? '';
                            } catch (_) {
                              _supplierNameController.text = '';
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.water_drop_rounded,
                                    size: 16,
                                    color: selected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tank.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tank.materialName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? theme.colorScheme.onPrimary.withValues(
                                          alpha: 0.8,
                                        )
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? theme.colorScheme.onPrimary.withValues(
                                          alpha: 0.2,
                                        )
                                      : theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${tank.currentStock.toStringAsFixed(1)}/${tank.capacity.toStringAsFixed(0)} ${tank.unit}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          if (_selectedTank != null && purchaseStock != null) ...[
            const SizedBox(height: 24),

            // Purchase Stock Info
            UnifiedCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Stock Available',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(purchaseStock.stock ?? 0).toStringAsFixed(2)} ${purchaseStock.baseUnit}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Refill Form
            UnifiedCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REFILL DETAILS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _tankQtyController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                NormalizedNumberInputFormatter.decimal(
                                  keepZeroWhenEmpty: false,
                                ),
                              ],
                              decoration: InputDecoration(
                                hintText: '0.00',
                                suffix: Text(
                                  _selectedTank!.unit,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor: theme
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Supplier Name',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _supplierNameController,
                              decoration: InputDecoration(
                                hintText: 'Enter supplier',
                                prefixIcon: Icon(
                                  Icons.business_rounded,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: theme
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Stock:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${_selectedTank!.currentStock.toStringAsFixed(2)} ${_selectedTank!.unit}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Capacity:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${_selectedTank!.capacity.toStringAsFixed(2)} ${_selectedTank!.unit}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'CONFIRM REFILL',
              onPressed: _submitRefill,
              isLoading: _isLoading,
              icon: Icons.check_circle_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitRefill() async {
    if (_selectedTank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tank/godown')),
      );
      return;
    }

    final qty = double.tryParse(_tankQtyController.text) ?? 0.0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid quantity')),
      );
      return;
    }

    // Check purchase stock
    ProductEntity? purchaseStock;
    try {
      purchaseStock = _availableProducts.firstWhere(
        (p) =>
            p.name.toLowerCase() == _selectedTank!.materialName.toLowerCase(),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found in inventory')),
      );
      setState(() => _isLoading = false);
      return;
    }

    if ((purchaseStock.stock ?? 0) < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient purchase stock. Available: ${purchaseStock.stock?.toStringAsFixed(2)} ${purchaseStock.baseUnit}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().state.user;
      if (user == null) throw Exception('User not authenticated');

      final supplierName = _supplierNameController.text.trim().isEmpty
          ? 'Manual Refill'
          : _supplierNameController.text.trim();

      final repo = context.read<TankRepository>();
      await repo.refillTank(
        tankId: _selectedTank!.id,
        quantity: qty,
        referenceId: 'REFILL-${DateTime.now().millisecondsSinceEpoch}',
        operatorId: user.id,
        operatorName: user.name,
        supplierName: supplierName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedTank!.name} refilled successfully with $qty ${_selectedTank!.unit}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _tankQtyController.clear();
        _supplierNameController.clear();
        setState(() {
          _selectedTank = null;
          _isLoading = false;
        });
        _loadTanks();
        _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
