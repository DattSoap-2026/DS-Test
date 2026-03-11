import 'package:flutter/material.dart';
import '../../../services/tank_service.dart';
import '../../../utils/normalized_number_input_formatter.dart';
import '../../../utils/responsive.dart';
import '../../../utils/storage_unit_helper.dart';
import '../../../widgets/ui/custom_button.dart';
import '../../../widgets/ui/custom_text_field.dart';

class TankAdjustDialog extends StatefulWidget {
  final Tank tank;
  final Function(double newStock, String reason) onAdjust;

  const TankAdjustDialog({
    super.key,
    required this.tank,
    required this.onAdjust,
  });

  @override
  State<TankAdjustDialog> createState() => _TankAdjustDialogState();
}

class _TankAdjustDialogState extends State<TankAdjustDialog> {
  final _stockController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _stockController.text = widget.tank.currentStock.toString();
  }

  @override
  void dispose() {
    _stockController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Adjust Tank Stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Current: ${StorageUnitHelper.tankDisplayQuantity(widget.tank.currentStock, storageUnit: widget.tank.unit).toStringAsFixed(2)} $tankDisplayUnit',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'New Stock Level',
            controller: _stockController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Reason for Adjustment',
            controller: _reasonController,
            hintText: 'Leakage, Overfill correction, etc.',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['Leakage', 'Physical Check', 'Entry Error']
                .map(
                  (reason) => ActionChip(
                    label: Text(reason, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _reasonController.text = reason,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'CONFIRM ADJUSTMENT',
            isLoading: _isSaving,
            onPressed: () async {
              final newStock = double.tryParse(_stockController.text);
              final reason = _reasonController.text;

              if (newStock == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid stock level'),
                  ),
                );
                return;
              }

              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              setState(() => _isSaving = true);
              await widget.onAdjust(newStock, reason);
              if (context.mounted) Navigator.pop(context);
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
