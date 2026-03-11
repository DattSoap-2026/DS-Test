import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/return_types.dart';
import '../../services/customers_service.dart';
import '../../services/returns_service.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/sales_service.dart';
import '../../models/types/sales_types.dart';
import '../../utils/normalized_number_input_formatter.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class CustomerReturnScreen extends StatefulWidget {
  const CustomerReturnScreen({super.key});

  @override
  State<CustomerReturnScreen> createState() => _CustomerReturnScreenState();
}

class _CustomerReturnScreenState extends State<CustomerReturnScreen> {
  // Services
  late CustomersService _customersService;
  late ReturnsService _returnsService;
  late SalesService _salesService;
  late AuthProvider _authProvider;

  // State
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Customer> _allCustomers = [];

  // Selection
  Customer? _selectedCustomer;
  final List<ReturnItem> _cart = [];

  // New state for sales selection
  List<Sale> _customerSales = [];
  Sale? _selectedSale;
  bool _isLoadingSales = false;

  @override
  void initState() {
    super.initState();
    _customersService = context.read<CustomersService>();
    _returnsService = context.read<ReturnsService>();
    _salesService = context.read<SalesService>();
    _authProvider = context.read<AuthProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Customers (offline first)
      final customers = await _customersService.getCustomers();
      // Optimized for search later

      if (mounted) {
        setState(() {
          _allCustomers = customers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _fetchCustomerSales(String customerId) async {
    setState(() {
      _isLoadingSales = true;
      _customerSales = [];
      _selectedSale = null;
    });
    try {
      final user = _authProvider.state.user;
      final sales = await _salesService.getSalesByCustomerClient(
        customerId,
        user?.id ?? '',
      );
      if (mounted) {
        setState(() {
          _customerSales = sales;
          _isLoadingSales = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSales = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading sales: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      bottomNavigationBar: _cart.isEmpty ? null : _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerSelection(),
          const SizedBox(height: 16),
          if (_selectedCustomer != null) ...[
            _buildSaleSelection(),
            const SizedBox(height: 16),
          ],
          if (_selectedSale != null) ...[
            _buildProductAdder(),
            const SizedBox(height: 24),
            _buildReturnList(),
          ],
          if (_selectedSale == null && _selectedCustomer != null)
            _buildEmptyStateForSales(),
          if (_selectedCustomer == null) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildCustomerSelection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Customer',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Autocomplete<Customer>(
            displayStringForOption: (c) => '${c.shopName} (${c.ownerName})',
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable.empty();
              return _allCustomers.where(
                (c) =>
                    (c.shopName.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    )) ||
                    (c.ownerName.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    )),
              );
            },
            onSelected: (selection) {
              setState(() {
                _selectedCustomer = selection;
                _selectedSale = null;
                _customerSales = [];
                _cart.clear(); // Clear cart when customer changes
                _fetchCustomerSales(selection.id);
              });
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  return CustomTextField(
                    label: 'Search Shop Name or Owner',
                    controller: controller,
                    focusNode: focusNode,
                    prefixIcon: Icons.search,
                  );
                },
          ),
          if (_selectedCustomer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store, color: Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCustomer!.shopName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          _selectedCustomer!.mobile,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _selectedCustomer = null),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaleSelection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Original Sale',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingSales)
            const Center(child: CircularProgressIndicator())
          else if (_customerSales.isEmpty)
            const Text(
              'No previous sales found for this customer.',
              style: TextStyle(color: AppColors.error),
            )
          else
            DropdownButtonFormField<Sale>(
              decoration: const InputDecoration(
                labelText: 'Pick a Sale Record',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.history),
              ),
              initialValue: _selectedSale,
              items: _customerSales.map((sale) {
                final dateStr = sale.createdAt.split('T')[0];
                final displayId =
                    sale.humanReadableId ??
                    sale.id.substring(sale.id.length - 6);
                return DropdownMenuItem(
                  value: sale,
                  child: Text(
                    'Sale: $displayId - $dateStr (\u20B9${sale.totalAmount.toStringAsFixed(2)})',
                  ),
                );
              }).toList(),
              onChanged: (sale) {
                setState(() {
                  _selectedSale = sale;
                  _cart.clear(); // Reset return items when sale changes
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateForSales() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _isLoadingSales
                  ? 'Searching for past sales...'
                  : 'No sales found. Try another customer.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductAdder() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Items to Return',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnList() {
    if (_cart.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Return Summary (${_cart.length} items)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._cart.map((item) {
          // Find disposition logic if strictly using models,
          // but ReturnItem doesn't track Reason/Disposition per item in the basic schema.
          // Wait, the ReturnRequest has ONE reason/disposition? Or per item?
          // The schema: `ReturnRequest` has `disposition`. `ReturnItem` does NOT.
          // This means a single Request must be ALL "Good Stock" or ALL "Damaged".
          // If user mixes good/bad, we might need 2 requests or update schema.
          // For simplicity in Phase 4, let's assume one disposition per request.
          // Or we can let user bundle them.
          // Let's enforce One Disposition per Request for now to keep it simple.

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${item.quantity} ${item.unit}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () {
                  setState(() {
                    _cart.remove(item);
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.assignment_return_outlined,
              size: 60,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a customer to start return',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOGS

  void _showAddProductDialog() {
    if (_selectedSale == null) return;
    showDialog(
      context: context,
      builder: (context) => _AddProductDialog(
        saleItems: _selectedSale!.items,
        onAdd: (item) {
          setState(() => _cart.add(item));
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReturn,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                )
              : const Text(
                  'SUBMIT RETURN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Future<void> _submitReturn() async {
    if (_selectedCustomer == null || _cart.isEmpty) return;

    // Ask for Disposition (Good/Bad) and Reason
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          _ConfirmReturnDialog(customerName: _selectedCustomer!.shopName),
    );

    if (result == null) return;

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final user = context.read<AuthProvider>().state.user;
      if (user == null) throw Exception('User not logged in');

      // 1. Calculate Total Refund Amount
      double totalRefund = 0.0;
      for (final item in _cart) {
        if (item.price != null) {
          totalRefund += item.quantity * item.price!;
        }
      }

      // 2. Submit Return Request
      await _returnsService.addReturnRequest(
        returnType: 'sales_return', // Customer Return
        salesmanId: user.id,
        salesmanName: user.name,
        items: _cart,
        reason: result['reason']!,
        disposition: result['disposition'],
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.shopName,
        originalSaleId: _selectedSale?.id,
      );

      // 3. Update locally and cleanup UI

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Return Submitted. Customer Credited: \u20B9${totalRefund.toStringAsFixed(2)}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Clear form
        setState(() {
          _selectedCustomer = null;
          _cart.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _AddProductDialog extends StatefulWidget {
  final List<SaleItem> saleItems;
  final Function(ReturnItem) onAdd;

  const _AddProductDialog({required this.saleItems, required this.onAdd});

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  SaleItem? _selectedItem;
  final TextEditingController _qtyController = TextEditingController(text: '0');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAlertDialog(
      title: const Text('Add Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<SaleItem>(
            decoration: const InputDecoration(
              labelText: 'Select Item from Sale',
              border: OutlineInputBorder(),
            ),
            initialValue: _selectedItem,
            items: widget.saleItems.map((item) {
              final netQty = item.quantity - (item.returnedQuantity);
              return DropdownMenuItem(
                value: item,
                child: Text(
                  '${item.name} ($netQty / ${item.quantity} ${item.baseUnit})',
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedItem = val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qtyController,
            decoration: InputDecoration(
              labelText: 'Quantity',
              suffixText: _selectedItem?.baseUnit ?? '',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedItem != null && _qtyController.text.isNotEmpty) {
              final qty = double.tryParse(_qtyController.text) ?? 0;
              final netQty =
                  _selectedItem!.quantity - (_selectedItem!.returnedQuantity);
              if (qty > 0 && qty <= netQty) {
                widget.onAdd(
                  ReturnItem(
                    productId: _selectedItem!.productId,
                    name: _selectedItem!.name,
                    quantity: qty,
                    unit: _selectedItem!.baseUnit,
                    price: _selectedItem!.price, // use sale price
                  ),
                );
                Navigator.pop(context);
              } else if (qty > netQty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cannot return more than available ($netQty sold items remaining)',
                    ),
                  ),
                );
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _ConfirmReturnDialog extends StatefulWidget {
  final String customerName;
  const _ConfirmReturnDialog({required this.customerName});

  @override
  State<_ConfirmReturnDialog> createState() => _ConfirmReturnDialogState();
}

class _ConfirmReturnDialogState extends State<_ConfirmReturnDialog> {
  String _disposition = 'Good Stock'; // Default
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ResponsiveAlertDialog(
      title: const Text('Confirm Return'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Return from: ${widget.customerName}'),
          const SizedBox(height: 16),
          const Text(
            'Condition:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButtonFormField<String>(
            initialValue: _disposition,
            items: [
              'Good Stock',
              'Bad Stock',
              'Expired',
              'Damaged',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _disposition = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason / Remarks',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'disposition': _disposition,
              'reason': _reasonController.text.isEmpty
                  ? 'Customer Return'
                  : _reasonController.text,
            });
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}




