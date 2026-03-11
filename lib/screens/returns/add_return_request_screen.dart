import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/types/return_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/product_types.dart';
import '../../data/repositories/returns_repository.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/local/entities/return_entity.dart';
import '../../utils/app_toast.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/themed_segment_control.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';

class AddReturnRequestScreen extends StatefulWidget {
  const AddReturnRequestScreen({super.key});

  @override
  State<AddReturnRequestScreen> createState() => _AddReturnRequestScreenState();
}

class _AddReturnRequestScreenState extends State<AddReturnRequestScreen> {
  // Removes direct service usage

  String _returnType = 'stock_return';
  final _reasonController = TextEditingController();
  String _disposition = 'Good Stock';

  final List<ReturnItem> _selectedItems = [];
  List<Product> _allProducts = [];
  bool _isLoadingProducts = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      // Use InventoryRepository (Local DB)
      final inventoryRepo = context.read<InventoryRepository>();
      final productEntities = await inventoryRepo.getAllProducts();

      if (mounted) {
        setState(() {
          _allProducts = productEntities.map((e) => e.toDomain()).toList();
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProductSelector(
        products: _allProducts,
        onSelected: (product, qty) {
          setState(() {
            _selectedItems.add(
              ReturnItem(
                productId: product.id,
                name: product.name,
                quantity: qty,
                unit: product.baseUnit,
                price: product.price,
              ),
            );
          });
        },
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_selectedItems.isEmpty) {
      AppToast.showWarning(context, 'Please add at least one item');
      return;
    }
    if (_reasonController.text.isEmpty) {
      AppToast.showWarning(context, 'Please provide a reason');
      return;
    }

    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final returnEntity = ReturnEntity()
        ..returnType = _returnType
        ..salesmanId = user.id
        ..salesmanName = user.name
        ..items = _selectedItems
            .map(
              (e) => ReturnItemEntity()
                ..productId = e.productId
                ..name = e.name
                ..quantity = e.quantity
                ..unit = e.unit
                ..price = e.price,
            )
            .toList()
        ..reason = _reasonController.text
        ..status = 'pending'
        ..disposition = _returnType == 'sales_return' ? _disposition : null
        ..createdAt = DateTime.now();

      await context.read<ReturnsRepository>().saveReturnRequest(returnEntity);

      if (mounted) {
        AppToast.showSuccess(
          context,
          'Return request queued for sync (Offline Saved)',
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'New Return Request',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTypeSelector(),
                  const SizedBox(height: 16),
                  _buildDetailsCard(),
                  const SizedBox(height: 16),
                  _buildItemsCard(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Return Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ThemedSegmentControl<String>(
              segments: const [
                ButtonSegment(
                  value: 'stock_return',
                  label: Text('Stock Return'),
                  icon: Icon(Icons.inventory_2_outlined),
                ),
                ButtonSegment(
                  value: 'sales_return',
                  label: Text('Sales Return'),
                  icon: Icon(Icons.shopping_bag_outlined),
                ),
              ],
              selected: {_returnType},
              onSelectionChanged: (val) =>
                  setState(() => _returnType = val.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (_returnType == 'sales_return') ...[
              DropdownButtonFormField<String>(
                initialValue: _disposition,
                decoration: const InputDecoration(
                  labelText: 'Condition / Disposition',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Good Stock',
                    child: Text('Good Stock (Resellable)'),
                  ),
                  DropdownMenuItem(
                    value: 'Bad Stock',
                    child: Text('Bad Stock (Damaged/Expired)'),
                  ),
                ],
                onChanged: (val) => setState(() => _disposition = val!),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for Return',
                hintText: 'Describe why items are being returned...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products List',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Product'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.05,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_selectedItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.add_shopping_cart,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No items added yet',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedItems.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _selectedItems[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.quantity} ${item.unit} - \u20B9${item.price} / unit',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () =>
                        setState(() => _selectedItems.removeAt(index)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: _isSaving ? null : _submitRequest,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: _isSaving
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'SUBMIT RETURN REQUEST',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
    );
  }
}

class _ProductSelector extends StatefulWidget {
  final List<Product> products;
  final Function(Product, double) onSelected;

  const _ProductSelector({required this.products, required this.onSelected});

  @override
  State<_ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<_ProductSelector> {
  Product? _selectedProduct;
  final _qtyController = TextEditingController(text: '0');
  String _search = '';

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products
        .where((p) => p.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: Responsive.viewInsetsBottom(context),
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search product...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _search = val),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: Responsive.clamp(context, min: 220, max: 320, ratio: 0.5),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final p = filtered[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('Current Price: \u20B9${p.price}'),
                  selected: _selectedProduct?.id == p.id,
                  onTap: () => setState(() => _selectedProduct = p),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.decimal(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _selectedProduct == null
                    ? null
                    : () {
                        final qty = double.tryParse(_qtyController.text) ?? 0;
                        if (qty > 0) {
                          widget.onSelected(_selectedProduct!, qty);
                          Navigator.pop(context);
                        }
                      },
                child: const Text('Add to Return'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}



