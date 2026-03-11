import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/tank_service.dart';
import '../../../services/products_service.dart';
import '../../../widgets/ui/custom_button.dart';
import '../../../widgets/ui/custom_text_field.dart';
import '../../../models/types/product_types.dart';
import '../../../utils/responsive.dart';
import '../../../utils/normalized_number_input_formatter.dart';
import '../../../utils/storage_unit_helper.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class TankTransferDialog extends StatefulWidget {
  final Tank tank;
  final Function(String productId, double quantity) onTransfer;

  const TankTransferDialog({
    super.key,
    required this.tank,
    required this.onTransfer,
  });

  @override
  State<TankTransferDialog> createState() => _TankTransferDialogState();
}

class _TankTransferDialogState extends State<TankTransferDialog> {
  final _qtyController = TextEditingController();
  late final ProductsService _productsService;

  Product? _selectedProduct;
  List<Product> _availableProducts = [];
  bool _isLoadingProducts = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _productsService = context.read<ProductsService>();
    _qtyController.text = '0';
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      // Logic from React: Filter by itemType based on tank role
      // In Flutter, we'll try to find the exact material first
      final products = await _productsService.getProducts(status: 'active');

      if (mounted) {
        setState(() {
          // Pre-filter: matches materialId or is a compatible material
          _availableProducts = products
              .where(
                (p) =>
                    p.id == widget.tank.materialId ||
                    p.name.toLowerCase().contains(
                      widget.tank.materialName.toLowerCase(),
                    ),
              )
              .toList();

          if (_availableProducts.isNotEmpty) {
            _selectedProduct = _availableProducts.firstWhere(
              (p) => p.id == widget.tank.materialId,
              orElse: () => _availableProducts.first,
            );
          }

          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final infoBg =
        theme.brightness == Brightness.dark ? AppColors.darkInfoBg : AppColors.infoBg;
    final remainingCapacity = widget.tank.capacity - widget.tank.currentStock;
    final tankDisplayUnit = StorageUnitHelper.tankDisplayUnit(widget.tank.unit);

    return Container(
      padding: EdgeInsets.only(
        bottom: Responsive.viewInsetsBottom(context) + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warehouse Transfer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Transfer stock to ${widget.tank.name}',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.info.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.3 : 0.16,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining Capacity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${StorageUnitHelper.tankDisplayQuantity(remainingCapacity, storageUnit: widget.tank.unit).toStringAsFixed(2)} $tankDisplayUnit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.info.withValues(alpha: 0.35),
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<Product>(
                  decoration: const InputDecoration(
                    labelText: 'Source Product',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(Icons.warehouse_outlined),
                  ),
                  initialValue: _selectedProduct,
                  items: _availableProducts
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.name} (${p.stock.toStringAsFixed(2)} ${p.baseUnit})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedProduct = val),
                  isExpanded: true,
                ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Transfer Quantity',
            controller: _qtyController,
            suffixText: tankDisplayUnit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
            ],
            hintText: 'Enter amount...',
          ),
          const SizedBox(height: 32),
          CustomButton(
            label: 'Confirm Transfer',
            icon: Icons.check_circle_outline,
            isLoading: _isSaving,
            height: Responsive.clamp(
              context,
              min: 48,
              max: 60,
              ratio: 0.08,
            ),
            onPressed: () async {
              final qty = double.tryParse(_qtyController.text);
              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (qty > remainingCapacity + 0.1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exceeds remaining tank capacity!'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (_selectedProduct == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a source product'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (_selectedProduct!.stock < qty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Insufficient warehouse stock! Available: ${_selectedProduct!.stock}',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              setState(() => _isSaving = true);
              await widget.onTransfer(_selectedProduct!.id, qty);
              if (context.mounted) Navigator.pop(context);
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}


