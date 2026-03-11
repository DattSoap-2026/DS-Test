import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/tank_service.dart';
import '../../../services/suppliers_service.dart';
import '../../../utils/responsive.dart';
import '../../../utils/normalized_number_input_formatter.dart';
import '../../../utils/storage_unit_helper.dart';
import '../../../widgets/ui/custom_button.dart';
import '../../../widgets/ui/custom_text_field.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class TankFillDialog extends StatefulWidget {
  final Tank tank;
  final Function(double quantity, String? supplierId, String? supplierName)
  onFill;

  const TankFillDialog({super.key, required this.tank, required this.onFill});

  @override
  State<TankFillDialog> createState() => _TankFillDialogState();
}

class _TankFillDialogState extends State<TankFillDialog> {
  final _qtyController = TextEditingController();
  late final SuppliersService _suppliersService;

  Map<String, String>? _selectedSupplier;
  List<Map<String, String>> _suppliers = [];
  bool _isLoadingSuppliers = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _suppliersService = context.read<SuppliersService>();
    _qtyController.text = '0';
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoadingSuppliers = true);
    try {
      final list = await _suppliersService.getSuppliers();
      if (mounted) {
        setState(() {
          _suppliers = list.map((s) => {'id': s.id, 'name': s.name}).toList();
          _isLoadingSuppliers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSuppliers = false);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fill Tank (Refill)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Space Available:',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${StorageUnitHelper.tankDisplayQuantity(remainingCapacity, storageUnit: widget.tank.unit).toStringAsFixed(2)} $tankDisplayUnit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isLoadingSuppliers
              ? const LinearProgressIndicator()
              : DropdownButtonFormField<Map<String, String>>(
                  decoration: const InputDecoration(
                    labelText: 'Source Supplier (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  initialValue: _selectedSupplier,
                  items: _suppliers
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s, child: Text(s['name']!)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSupplier = val),
                ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Fill Quantity ($tankDisplayUnit)',
            controller: _qtyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
            ],
            hintText: 'Enter amount to add...',
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'COMPLETE FILL',
            isLoading: _isSaving,
            onPressed: () async {
              final qty = double.tryParse(_qtyController.text);
              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                  ),
                );
                return;
              }

              if (qty > remainingCapacity + 0.1) {
                // small buf
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exceeds remaining capacity!')),
                );
                return;
              }

              setState(() => _isSaving = true);
              await widget.onFill(
                qty,
                _selectedSupplier?['id'],
                _selectedSupplier?['name'],
              );
              if (context.mounted) Navigator.pop(context);
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

