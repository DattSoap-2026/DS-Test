import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/diesel_service.dart';
import '../../services/suppliers_service.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class FuelStockScreen extends StatefulWidget {
  const FuelStockScreen({super.key});

  @override
  State<FuelStockScreen> createState() => _FuelStockScreenState();
}

class _FuelStockScreenState extends State<FuelStockScreen> {
  late final DieselService _dieselService;
  late final SuppliersService _suppliersService;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showSupplierValidation = false;

  List<Supplier> _suppliers = [];
  List<FuelPurchase> _purchases = [];
  double _currentStock = 0;
  bool _showHistory = false;

  Supplier? _selectedSupplier;
  DateTime _purchaseDate = DateTime.now();
  final TextEditingController _quantityController = TextEditingController(
    text: '0',
  );
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _supplierSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    _suppliersService = context.read<SuppliersService>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final suppliers = await _suppliersService.getSuppliers(status: 'active');
      final stock = await _dieselService.getFuelStock();
      final purchases = await _dieselService.getFuelPurchases();
      if (mounted) {
        setState(() {
          _suppliers = suppliers..sort((a, b) => a.name.compareTo(b.name));
          _currentStock = stock;
          _purchases = purchases;
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

  Future<void> _submit() async {
    if (_isSaving) return;

    final isFormValid = _formKey.currentState!.validate();
    final isSupplierMissing = _selectedSupplier == null;
    if (!isFormValid || isSupplierMissing) {
      setState(() => _showSupplierValidation = isSupplierMissing);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final quantity = double.tryParse(_quantityController.text);
      final rate = double.tryParse(_rateController.text);
      if (quantity == null || rate == null || quantity <= 0 || rate <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid quantity and rate')),
        );
        return;
      }

      await _dieselService.addFuelStock(
        quantity: quantity,
        rate: rate,
        supplierName: _selectedSupplier!.name,
        purchaseDate: _purchaseDate.toIso8601String().split('T')[0],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fuel stock added successfully')),
        );
        _quantityController.text = '0';
        _rateController.clear();
        _supplierSearchController.clear();
        _showSupplierValidation = false;
        _selectedSupplier = null;
        _purchaseDate = DateTime.now();
        _loadData(); // Refresh current stock
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _rateController.dispose();
    _supplierSearchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
      return;
    }

    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/dashboard/fuel/')) {
      context.go('/dashboard/fuel');
      return;
    }
    if (path.startsWith('/dashboard/reports/')) {
      context.go('/dashboard/reports');
      return;
    }
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double quantity = double.tryParse(_quantityController.text) ?? 0;
    final double rate = double.tryParse(_rateController.text) ?? 0;
    final totalCost = quantity * rate;
    final NumberFormat currencyFormatter = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Fuel Stock'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 12 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile) ...[
                        _buildStockKPI(),
                        const SizedBox(height: 12),
                        _buildHistoryToggleCard(),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildStockKPI()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildHistoryToggleCard()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildForm(
                        totalCost,
                        currencyFormatter,
                        isMobile: isMobile,
                      ),
                      if (_showHistory) ...[
                        const SizedBox(height: 24),
                        _buildHistoryList(currencyFormatter),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStockKPI() {
    return Card(
      elevation: 0,
      color: AppColors.warning.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.warning,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Fuel Stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_currentStock.toStringAsFixed(1)} Ltr',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryToggleCard() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: _showHistory
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _showHistory
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _showHistory = !_showHistory),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _showHistory
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  color: _showHistory
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase History',
                      style: TextStyle(
                        fontSize: 12,
                        color: _showHistory
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _showHistory ? 'HIDE' : 'SHOW',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _showHistory
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(NumberFormat currencyFormatter) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Purchases',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_purchases.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No purchase history found.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _purchases.length > 5 ? 5 : _purchases.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final p = _purchases[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      p.supplierName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(p.purchaseDate)),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${p.quantity} Ltr',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(p.totalAmount),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (_purchases.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.pushNamed('fuel_history'),
                  child: const Text('VIEW ALL HISTORY'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    double totalCost,
    NumberFormat currencyFormatter, {
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Purchase Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Log a new diesel purchase record.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              if (isMobile) ...[
                _buildPurchaseDateField(),
                const SizedBox(height: 12),
                _buildQuantityField(),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _buildPurchaseDateField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildQuantityField()),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<Supplier>(
                    width: constraints.maxWidth,
                    controller: _supplierSearchController,
                    initialSelection: _selectedSupplier,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    menuHeight: 320,
                    leadingIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    label: const Text('Search Supplier'),
                    dropdownMenuEntries: _suppliers
                        .map<DropdownMenuEntry<Supplier>>((s) {
                          return DropdownMenuEntry<Supplier>(
                            value: s,
                            label: s.name,
                          );
                        })
                        .toList(),
                    onSelected: (s) => setState(() {
                      _selectedSupplier = s;
                      _showSupplierValidation = false;
                    }),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        theme.colorScheme.surface,
                      ),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                    ),
                  );
                },
              ),
              if (_showSupplierValidation && _selectedSupplier == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Supplier is required',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate per Liter',
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => setState(() {}),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Investment',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(totalCost),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (isMobile) ...[
                OutlinedButton(
                  onPressed: _resetFormFields,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('RESET'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                          )
                        : const Text(
                            'ADD TO STOCK',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFormFields,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('RESET'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                              )
                            : const Text(
                                'ADD TO STOCK',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseDateField() {
    return InkWell(
      onTap: () async {
        final date = await ResponsiveDatePickers.pickDate(
          context: context,
          initialDate: _purchaseDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          helpText: 'Select Purchase Date',
          confirmText: 'Apply',
        );
        if (date != null) setState(() => _purchaseDate = date);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Purchase Date',
          border: OutlineInputBorder(),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(_purchaseDate)),
      ),
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Quantity (Liters)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
      ],
      onChanged: (v) => setState(() {}),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  void _resetFormFields() {
    _quantityController.text = '0';
    _rateController.clear();
    _supplierSearchController.clear();
    setState(() {
      _selectedSupplier = null;
      _showSupplierValidation = false;
    });
  }
}
