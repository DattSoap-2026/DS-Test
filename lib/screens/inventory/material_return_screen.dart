import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/inventory_service.dart';
import '../../services/database_service.dart';
import '../../services/department_service.dart';
import '../../data/local/entities/department_stock_entity.dart';
import 'package:isar/isar.dart';
import '../../utils/normalized_number_input_formatter.dart';

import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/shared/app_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class MaterialReturnScreen extends StatefulWidget {
  const MaterialReturnScreen({super.key});

  @override
  State<MaterialReturnScreen> createState() => _MaterialReturnScreenState();
}

class _MaterialReturnScreenState extends State<MaterialReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _selectedDepartment;
  late final List<String> _departments;

  final List<Map<String, dynamic>> _selectedItems = [];
  List<DepartmentStockEntity> _deptProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _departments = DepartmentService().getDepartmentNames();
  }

  @override
  void dispose() {
    for (final item in _selectedItems) {
      (item['controller'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDeptProducts(String dept) async {
    setState(() => _isLoadingProducts = true);
    try {
      final dbService = context.read<DatabaseService>();
      final products = await dbService.departmentStocks
          .filter()
          .departmentNameEqualTo(dept)
          .stockGreaterThan(0)
          .findAll();

      setState(() {
        _deptProducts = products;
        _isLoadingProducts = false;
        _selectedItems.clear(); // Clear previously selected items of other dept
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addItem() {
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select department first')));
      return;
    }
    setState(() {
      _selectedItems.add({
        'productId': null,
        'productName': null,
        'unit': null,
        'currentStock': 0.0,
        'quantity': 0.0,
        'controller': TextEditingController(text: '0'),
      });
    });
  }

  void _removeItem(int index) {
    final controller = _selectedItems[index]['controller'] as TextEditingController?;
    controller?.dispose();
    setState(() => _selectedItems.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDepartment == null || _selectedItems.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final inventory = context.read<InventoryService>();
      final user = auth.state.user;
      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppDialog.show(
            context,
            title: 'Error',
            content: const Text('User not authenticated'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
        return;
      }

      await inventory.returnFromDepartment(
        departmentName: _selectedDepartment!,
        items: _selectedItems
            .map(
              (e) => {
                'productId': e['productId'],
                'productName': e['productName'],
                'quantity': e['quantity'],
                'unit': e['unit'],
              },
            )
            .toList(),
        returnedByUserId: user.id,
        returnedByUserName: user.name,
        notes: 'Manual Return via App',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materials returned successfully')),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Return Materials',
            subtitle: 'Return measurements to main warehouse',
            icon: Icons.input_rounded,
            color: Theme.of(context).colorScheme.primary,
            onBack: () => context.pop(),
            actions: [
              IconButton(
                onPressed: () {
                  if (_selectedDepartment != null) {
                    _loadDeptProducts(_selectedDepartment!);
                  }
                },
                icon: const Icon(Icons.sync_rounded),
                tooltip: 'Refresh Dept Stock',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // From Department Selection
                    UnifiedCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'FROM DEPARTMENT',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDepartment,
                            decoration: InputDecoration(
                              labelText: 'Select Source Department',
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
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
                            dropdownColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            items: _departments
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _selectedDepartment = val;
                                _loadDeptProducts(val);
                              }
                            },
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_selectedDepartment != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ITEMS TO RETURN',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 1.0,
                                ),
                          ),
                          CustomButton(
                            label: 'ADD MATERIAL',
                            icon: Icons.add_rounded,
                            onPressed: _addItem,
                            variant: ButtonVariant.outline,
                            isDense: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isLoadingProducts)
                        const Center(child: CircularProgressIndicator())
                      else if (_deptProducts.isEmpty &&
                          _selectedDepartment != null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text('No stock found in this department'),
                          ),
                        )
                      else ...[
                        ..._selectedItems.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          return UnifiedCard(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        initialValue: item['productId'],
                                        decoration: InputDecoration(
                                          labelText: 'Select Material',
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.3),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        dropdownColor: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(16),
                                        items: _deptProducts
                                            .map(
                                              (p) => DropdownMenuItem(
                                                value: p.productId,
                                                child: Text(
                                                  "${p.productName} (${p.stock.toStringAsFixed(1)} ${p.unit})",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          final p = _deptProducts
                                              .cast<DepartmentStockEntity?>()
                                              .firstWhere(
                                                (element) =>
                                                    element?.productId == val,
                                                orElse: () => null,
                                              );
                                          if (p == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Selected material not found',
                                                ),
                                                backgroundColor:
                                                    AppColors.error,
                                              ),
                                            );
                                            return;
                                          }
                                          setState(() {
                                            item['productId'] = val;
                                            item['productName'] = p.productName;
                                            item['unit'] = p.unit;
                                            item['currentStock'] = p.stock;
                                          });
                                        },
                                        validator: (v) =>
                                            v == null ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () => _removeItem(idx),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Return Quantity',
                                        controller: item['controller'],
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          NormalizedNumberInputFormatter.decimal(
                                            keepZeroWhenEmpty: true,
                                          ),
                                        ],
                                        onChanged: (v) => item['quantity'] =
                                            double.tryParse(v) ?? 0.0,
                                        validator: (v) {
                                          final q =
                                              double.tryParse(v ?? '') ?? 0.0;
                                          if (q <= 0) {
                                            return 'Enter qty';
                                          }
                                          if (q > (item['currentStock'] ?? 0)) {
                                            return 'Max: ${item['currentStock']}';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item['unit'] ?? 'UNIT',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                    const SizedBox(height: 32),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'CONFIRM RETURN TO WAREHOUSE',
                      icon: Icons.check_circle_rounded,
                      onPressed:
                          _isLoading ||
                              _selectedDepartment == null ||
                              _selectedItems.isEmpty
                          ? null
                          : _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

