import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/auth/auth_provider.dart';
import '../../services/warehouse_service.dart';
import '../../services/warehouse_transfer_service.dart';
import '../../services/products_service.dart';
import '../../services/database_service.dart';
import '../../data/local/entities/stock_balance_entity.dart';
import '../../models/inventory/warehouse.dart';
import '../../models/inventory/warehouse_transfer.dart';
import '../../models/types/product_types.dart';
import '../../utils/responsive.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/animated_card.dart';
import '../../utils/app_toast.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class WarehouseTransferScreen extends StatefulWidget {
  const WarehouseTransferScreen({super.key});

  @override
  State<WarehouseTransferScreen> createState() =>
      _WarehouseTransferScreenState();
}

class _WarehouseTransferScreenState extends State<WarehouseTransferScreen>
    with SingleTickerProviderStateMixin {
  late final WarehouseService _warehouseService;
  late final WarehouseTransferService _transferService;
  late final ProductsService _productsService;
  late final DatabaseService _dbService;
  late final TabController _tabController;

  bool _isLoading = true;
  bool _isTransferring = false;
  List<Warehouse> _warehouses = [];
  List<Product> _allProducts = [];
  List<WarehouseTransfer> _transferHistory = [];

  // Transfer Form State
  String? _fromWarehouseId;
  String? _toWarehouseId;
  Product? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  double _availableStock = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _warehouseService = context.read<WarehouseService>();
    _transferService = context.read<WarehouseTransferService>();
    _productsService = context.read<ProductsService>();
    _dbService = context.read<DatabaseService>();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final warehouseResult = await _warehouseService.getWarehouseOptions();
      final products = await _productsService.getProducts();
      final transfers = await _transferService.getTransferHistory();

      if (mounted) {
        setState(() {
          _warehouses = warehouseResult.warehouses;
          _allProducts = products.where((p) => p.status == 'active').toList();
          _transferHistory = transfers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error loading data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAvailableStock() async {
    if (_fromWarehouseId == null || _selectedProduct == null) {
      setState(() => _availableStock = 0.0);
      return;
    }

    try {
      final balanceId = '${_fromWarehouseId!}_${_selectedProduct!.id}';
      final balance = await _dbService.stockBalances.getById(balanceId);

      setState(() => _availableStock = balance?.quantity ?? 0.0);
    } catch (e) {
      setState(() => _availableStock = 0.0);
    }
  }

  Future<void> _performTransfer() async {
    if (_fromWarehouseId == null) {
      AppToast.showError(context, 'Please select source warehouse');
      return;
    }
    if (_toWarehouseId == null) {
      AppToast.showError(context, 'Please select destination warehouse');
      return;
    }
    if (_selectedProduct == null) {
      AppToast.showError(context, 'Please select a product');
      return;
    }

    final quantityStr = _quantityController.text.trim();
    if (quantityStr.isEmpty) {
      AppToast.showError(context, 'Please enter quantity');
      return;
    }

    final quantity = double.tryParse(quantityStr);
    if (quantity == null || quantity <= 0) {
      AppToast.showError(context, 'Invalid quantity');
      return;
    }

    if (quantity > _availableStock) {
      AppToast.showError(
        context,
        'Insufficient stock. Available: $_availableStock',
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      AppToast.showError(context, 'User not authenticated');
      return;
    }

    final fromWarehouse = _warehouses.firstWhere((w) => w.id == _fromWarehouseId);
    final toWarehouse = _warehouses.firstWhere((w) => w.id == _toWarehouseId);

    setState(() => _isTransferring = true);

    try {
      await _transferService.transferStock(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        fromWarehouseId: fromWarehouse.id,
        fromWarehouseName: fromWarehouse.name,
        toWarehouseId: toWarehouse.id,
        toWarehouseName: toWarehouse.name,
        quantity: quantity,
        unit: _selectedProduct!.baseUnit,
        transferredBy: user.id,
        transferredByName: user.name,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        AppToast.showSuccess(
          context,
          'Transferred $quantity ${_selectedProduct!.baseUnit} from ${fromWarehouse.name} to ${toWarehouse.name}',
        );
        _clearForm();
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }

  void _clearForm() {
    setState(() {
      _selectedProduct = null;
      _quantityController.clear();
      _notesController.clear();
      _availableStock = 0.0;
    });
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _allProducts;
    return _allProducts.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Warehouse Transfer',
            subtitle: 'Move stock between warehouses',
            icon: Icons.swap_horiz_rounded,
            color: theme.colorScheme.primary,
            onBack: () => context.pop(),
            actions: [
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
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
            tabs: const [
              Tab(text: 'NEW TRANSFER', icon: Icon(Icons.send_rounded)),
              Tab(text: 'HISTORY', icon: Icon(Icons.history_rounded)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransferForm(theme),
                _buildTransferHistory(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferForm(ThemeData theme) {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Warehouse Selection
          GlassContainer(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            borderRadius: isMobile ? 18 : 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warehouse_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'WAREHOUSE SELECTION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildWarehouseDropdown(
                        label: 'From Warehouse',
                        value: _fromWarehouseId,
                        onChanged: (value) {
                          setState(() {
                            _fromWarehouseId = value;
                            if (_fromWarehouseId == _toWarehouseId) {
                              _toWarehouseId = null;
                            }
                          });
                          _updateAvailableStock();
                        },
                        theme: theme,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildWarehouseDropdown(
                        label: 'To Warehouse',
                        value: _toWarehouseId,
                        onChanged: (value) {
                          setState(() => _toWarehouseId = value);
                        },
                        theme: theme,
                        excludeId: _fromWarehouseId,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product Selection
          GlassContainer(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            borderRadius: isMobile ? 18 : 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PRODUCT SELECTION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search product...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isSelected = _selectedProduct?.id == product.id;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        title: Text(
                          product.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${product.sku} • ${product.baseUnit}',
                          style: theme.textTheme.labelSmall,
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedProduct = product);
                          _updateAvailableStock();
                        },
                      );
                    },
                  ),
                ),
                if (_selectedProduct != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Available Stock: ',
                          style: theme.textTheme.labelMedium,
                        ),
                        Text(
                          '$_availableStock ${_selectedProduct!.baseUnit}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quantity & Notes
          GlassContainer(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            borderRadius: isMobile ? 18 : 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TRANSFER DETAILS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    NormalizedNumberInputFormatter.decimal(
                      keepZeroWhenEmpty: false,
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Enter quantity to transfer',
                    suffixText: _selectedProduct?.baseUnit ?? '',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add transfer notes...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
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
          const SizedBox(height: 24),

          // Transfer Button
          CustomButton(
            label: _isTransferring ? 'TRANSFERRING...' : 'TRANSFER STOCK',
            icon: Icons.send_rounded,
            onPressed: _isTransferring ? null : _performTransfer,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
    String? excludeId,
  }) {
    final availableWarehouses = excludeId == null
        ? _warehouses
        : _warehouses.where((w) => w.id != excludeId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Select'),
          items: availableWarehouses.map((warehouse) {
            return DropdownMenuItem(
              value: warehouse.id,
              child: Text(
                warehouse.name,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTransferHistory(ThemeData theme) {
    if (_transferHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No transfer history',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transferHistory.length,
      itemBuilder: (context, index) {
        final transfer = _transferHistory[index];
        return AnimatedCard(
          child: GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transfer.productName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${transfer.quantity} ${transfer.unit}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTransferLocation(
                        theme,
                        transfer.fromWarehouseName,
                        Icons.logout_rounded,
                        AppColors.error,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: _buildTransferLocation(
                        theme,
                        transfer.toWarehouseName,
                        Icons.login_rounded,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      transfer.transferredByName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(transfer.transferDate),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (transfer.notes != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            transfer.notes!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransferLocation(
    ThemeData theme,
    String name,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
