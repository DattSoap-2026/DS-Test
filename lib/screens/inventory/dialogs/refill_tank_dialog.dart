import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/service_providers.dart';
import '../../../../providers/suppliers_provider.dart';
import '../../../../providers/purchase_orders_provider.dart';
import '../../../../models/types/purchase_order_types.dart';
import '../../../../providers/auth/auth_provider.dart';
import '../../../../services/tank_service.dart';
import '../../../../services/suppliers_service.dart';
import '../../../utils/responsive.dart';
import '../../../utils/normalized_number_input_formatter.dart';
import '../../../utils/storage_unit_helper.dart';
import '../../../widgets/ui/glass_container.dart';
import '../../../widgets/ui/custom_text_field.dart';
import '../../../widgets/ui/custom_button.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class RefillTankDialog extends ConsumerStatefulWidget {
  final Tank? initialTank;
  final List<Tank> allTanks;

  const RefillTankDialog({super.key, this.initialTank, required this.allTanks});

  @override
  ConsumerState<RefillTankDialog> createState() => _RefillTankDialogState();
}

class _RefillTankDialogState extends ConsumerState<RefillTankDialog> {
  final _formKey = GlobalKey<FormState>();
  Tank? _selectedTank;
  final _quantityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _supplierNameController = TextEditingController();
  bool _isSubmitting = false;

  List<Tank> get _sortedTanks {
    final sorted = List<Tank>.from(widget.allTanks);
    sorted.sort(Tank.compareByDisplayOrder);
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _selectedTank = widget.initialTank;
    _quantityController.text = '0';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceController.dispose();
    _supplierNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTank == null) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authProviderProvider).currentUser;
      if (user == null) throw Exception('User not logged in');
      final qty = double.tryParse(_quantityController.text);
      if (qty == null || qty <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid quantity'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isSubmitting = false);
        }
        return;
      }

      final repo = ref.read(tankRepositoryProvider);
      await repo.refillTank(
        tankId: _selectedTank!.id,
        quantity: qty,
        referenceId: _referenceController.text.isEmpty
            ? 'REFILL-${DateTime.now().millisecondsSinceEpoch}'
            : _referenceController.text,
        operatorId: user.id,
        operatorName: user.name,
        supplierName: _supplierNameController.text.isEmpty
            ? 'Manual Refill'
            : _supplierNameController.text,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tank refilled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tankDisplayUnit = StorageUnitHelper.tankDisplayUnit(
      _selectedTank?.unit,
    );

    // Reactive Supplier and PO Loading
    final suppliersAsync = ref.watch(suppliersFutureProvider);
    // Auto-fill PO Reference when loaded
    ref.listen(purchaseOrdersFutureProvider, (previous, next) {
      if (next is AsyncData<List<PurchaseOrder>> && next.value.isNotEmpty) {
        if (_referenceController.text.isEmpty) {
          final pos = List<PurchaseOrder>.from(next.value);
          pos.sort((a, b) {
            final aDate = DateTime.tryParse(a.createdAt) ?? DateTime(2000);
            final bDate = DateTime.tryParse(b.createdAt) ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
          final latestPo = pos.first;
          final poRef = latestPo.poNumber.isNotEmpty
              ? latestPo.poNumber
              : latestPo.id;
          _referenceController.text = poRef;
        }
      }
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: Responsive.dialogInsetPadding(context),
      child: ConstrainedBox(
        constraints: Responsive.dialogConstraints(
          context,
          maxWidth: 560,
          maxHeightFactor: 0.92,
        ),
        child: GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          borderRadius: 32,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refill Unit',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Replenish storage inventory',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Storage Unit: Searchable combo-box ───────────────────────
              // Autocomplete so results always appear BELOW the search field.
              Text(
                'STORAGE UNIT',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Autocomplete<Tank>(
                initialValue: _selectedTank != null
                    ? TextEditingValue(
                        text:
                            '${_selectedTank!.name} (${_selectedTank!.materialName})',
                      )
                    : null,
                displayStringForOption: (t) => '${t.name} (${t.materialName})',
                optionsBuilder: (TextEditingValue textValue) {
                  if (textValue.text.isEmpty) return _sortedTanks;
                  final q = textValue.text.toLowerCase();
                  return _sortedTanks.where(
                    (t) =>
                        t.name.toLowerCase().contains(q) ||
                        t.materialName.toLowerCase().contains(q),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 6,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final tank = options.elementAt(index);
                            final isSelected = _selectedTank?.id == tank.id;
                            return ListTile(
                              leading: Icon(
                                Icons.water_drop_rounded,
                                size: 18,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              title: Text(
                                tank.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                tank.materialName,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onTap: () => onSelected(tank),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                fieldViewBuilder:
                    (
                      context,
                      fieldController,
                      fieldFocusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller: fieldController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search storage unit...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                          ),
                          suffixIcon: _selectedTank != null
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : null,
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (_) => _selectedTank == null
                            ? 'Please select a tank'
                            : null,
                      );
                    },
                onSelected: (Tank tank) {
                  setState(() => _selectedTank = tank);
                },
              ),

              // Tank info chip — shown after selection
              if (_selectedTank != null) ...[
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Stock: ${StorageUnitHelper.tankDisplayQuantity(_selectedTank!.currentStock, storageUnit: _selectedTank!.unit).toStringAsFixed(2)} $tankDisplayUnit',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Capacity: ${StorageUnitHelper.tankDisplayQuantity(_selectedTank!.capacity, storageUnit: _selectedTank!.unit).toStringAsFixed(2)} $tankDisplayUnit',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Quantity + Reference ─────────────────────────────────────
              // FIX 2: Reference field pre-filled with latest PO number
              LayoutBuilder(
                builder: (context, constraints) {
                  final useSingleColumn = constraints.maxWidth < 620;
                  final qtyField = CustomTextField(
                    label: 'Refill Quantity',
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      NormalizedNumberInputFormatter.decimal(
                        keepZeroWhenEmpty: true,
                      ),
                    ],
                    hintText: '0.00',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        tankDisplayUnit,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final qty = double.tryParse(v);
                      if (qty == null || qty <= 0) return 'Invalid quantity';
                      if (_selectedTank != null &&
                          _selectedTank!.currentStock + qty >
                              _selectedTank!.capacity) {
                        return 'Exceeds capacity';
                      }
                      return null;
                    },
                  );
                  final refField = CustomTextField(
                    label: 'Reference (PO / Invoice)',
                    controller: _referenceController,
                    hintText: 'e.g. PO-2024-001',
                  );
                  if (useSingleColumn) {
                    return Column(
                      children: [
                        qtyField,
                        const SizedBox(height: 16),
                        refField,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(flex: 2, child: qtyField),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: refField),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── FIX 3: Supplier — pre-loaded, shows all on focus ─────────
              Text(
                'SUPPLIER',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              suppliersAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (err, _) => CustomTextField(
                  label: '',
                  controller: _supplierNameController,
                  hintText: 'Enter Supplier Name',
                  prefixIcon: Icons.business_outlined,
                ),
                data: (suppliers) {
                  if (suppliers.isEmpty) {
                    return CustomTextField(
                      label: '',
                      controller: _supplierNameController,
                      hintText: 'Enter Supplier Name',
                      prefixIcon: Icons.business_outlined,
                    );
                  }
                  return Autocomplete<Supplier>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return suppliers;
                      }
                      return suppliers.where(
                        (s) => s.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    displayStringForOption: (Supplier option) => option.name,
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final supplier = options.elementAt(index);
                                return ListTile(
                                  leading: const Icon(
                                    Icons.business_rounded,
                                    size: 18,
                                  ),
                                  title: Text(
                                    supplier.name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: supplier.city != null
                                      ? Text(
                                          supplier.city!,
                                          style: const TextStyle(fontSize: 12),
                                        )
                                      : null,
                                  onTap: () => onSelected(supplier),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder:
                        (
                          BuildContext context,
                          TextEditingController fieldController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          return CustomTextField(
                            label: '',
                            controller: fieldController,
                            focusNode: fieldFocusNode,
                            hintText: 'Search Approved Suppliers',
                            prefixIcon: Icons.search_rounded,
                            onChanged: (val) {
                              _supplierNameController.text = val;
                            },
                          );
                        },
                    onSelected: (Supplier selection) {
                      _supplierNameController.text = selection.name;
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 420;
                  if (stacked) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: 'CONFIRM REFILL',
                            onPressed: _submit,
                            isLoading: _isSubmitting,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: 'CANCEL',
                            onPressed: () => Navigator.pop(context),
                            variant: ButtonVariant.outline,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'CANCEL',
                          onPressed: () => Navigator.pop(context),
                          variant: ButtonVariant.outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          label: 'CONFIRM REFILL',
                          onPressed: _submit,
                          isLoading: _isSubmitting,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
