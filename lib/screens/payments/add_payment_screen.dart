import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/payments_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../../models/customer.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../services/settings_service.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_states.dart';
import '../../widgets/ui/themed_filter_chip.dart';

import '../../utils/service_handler.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class AddPaymentScreen extends StatefulWidget {
  final String? initialCustomerId;
  final String? initialCustomerName;

  const AddPaymentScreen({
    super.key,
    this.initialCustomerId,
    this.initialCustomerName,
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PaymentsService _paymentsService;
  late final SettingsService _settingsService;

  String? _selectedCustomerId;
  CompanyProfileData? _companyProfile;
  String? _selectedCustomerName;
  final _customerController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  PaymentMode _selectedMode = PaymentMode.cash;

  bool _isSaving = false;
  List<Customer> _customers = [];
  bool _isLoadingCustomers = false;

  @override
  void initState() {
    super.initState();
    _paymentsService = context.read<PaymentsService>();
    _settingsService = context.read<SettingsService>();
    _selectedCustomerId = widget.initialCustomerId;
    _selectedCustomerName = widget.initialCustomerName;
    _customerController.text = _selectedCustomerName ?? '';
    if (_selectedCustomerId == null) {
      _loadCustomers();
    }
    _loadCompanyProfile();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyProfile() async {
    final profile = await _settingsService.getCompanyProfileClient();
    if (mounted) {
      setState(() => _companyProfile = profile);
    }
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final customerRepo = context.read<CustomerRepository>();
      final entities = await customerRepo.getAllCustomers();
      if (mounted) {
        setState(() {
          _customers = entities.map((e) => e.toDomain()).toList();
          _isLoadingCustomers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCustomers = false);
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate() || _selectedCustomerId == null) {
      if (_selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer')),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.state.user;
    if (user == null) return;

    setState(() => _isSaving = true);

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
        setState(() => _isSaving = false);
      }
      return;
    }

    final paymentId = await ServiceHandler.execute<String?>(
      context,
      action: () => _paymentsService.addManualPayment(
        customerId: _selectedCustomerId!,
        customerName: _selectedCustomerName!,
        amount: amount,
        mode: _selectedMode,
        date: _selectedDate.toIso8601String(),
        reference: _referenceController.text.isEmpty
            ? null
            : _referenceController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        collectorId: user.id,
        collectorName: user.name,
      ),
    );

    if (paymentId != null && mounted) {
      final payment = ManualPayment(
        id: paymentId,
        customerId: _selectedCustomerId!,
        customerName: _selectedCustomerName!,
        amount: amount,
        mode: _selectedMode,
        date: _selectedDate.toIso8601String(),
        reference: _referenceController.text.isEmpty
            ? null
            : _referenceController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        collectorId: user.id,
        collectorName: user.name,
        createdAt: DateTime.now().toIso8601String(),
      );
      _showSuccessDialog(payment);
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                        const Text(
                          'Add Payment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCustomerSelector(),
                    const SizedBox(height: 20),
                    _buildAmountInput(),
                    const SizedBox(height: 20),
                    _buildPaymentModeSelector(),
                    const SizedBox(height: 20),
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildReferenceInput(),
                    const SizedBox(height: 20),
                    _buildNotesInput(),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'Record Payment',
                      onPressed: _isSaving ? null : _savePayment,
                      isLoading: _isSaving,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCustomerSelector() {
    return CustomTextField(
      label: 'Customer',
      hintText: 'Select Customer',
      readOnly: true,
      onTap: widget.initialCustomerId != null ? null : _showCustomerPicker,
      controller: _customerController,
      prefixIcon: Icons.person,
      suffixIcon: widget.initialCustomerId == null
          ? const Icon(Icons.arrow_drop_down)
          : null,
    );
  }

  Future<void> _showCustomerPicker() async {
    if (_isLoadingCustomers) return;
    if (_customers.isEmpty) {
      await _loadCustomers();
    }
    if (!mounted) return;
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final normalized = query.trim().toLowerCase();
            final filteredCustomers = normalized.isEmpty
                ? _customers
                : _customers.where((customer) {
                    final shop = customer.shopName.toLowerCase();
                    final owner = customer.ownerName.toLowerCase();
                    final mobile = customer.mobile.toLowerCase();
                    final route = customer.route.toLowerCase();
                    return shop.contains(normalized) ||
                        owner.contains(normalized) ||
                        mobile.contains(normalized) ||
                        route.contains(normalized);
                  }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.50,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                final theme = Theme.of(context);
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                        child: Row(
                          children: [
                            Text(
                              'Select Customer',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          onChanged: (value) =>
                              setModalState(() => query = value),
                          decoration: InputDecoration(
                            hintText:
                                'Search by shop, owner, mobile or route...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: query.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setModalState(() => query = '');
                                    },
                                    icon: const Icon(Icons.close, size: 18),
                                  )
                                : null,
                            isDense: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _isLoadingCustomers
                            ? const CustomLoadingIndicator()
                            : filteredCustomers.isEmpty
                            ? const Center(
                                child: CustomEmptyState(
                                  icon: Icons.search_off,
                                  title: 'No customers found',
                                  message:
                                      'Try a different name, route, or mobile number.',
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                                itemCount: filteredCustomers.length,
                                separatorBuilder: (_, _) => Divider(
                                  height: 1,
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  final customer = filteredCustomers[index];
                                  final isSelected =
                                      _selectedCustomerId == customer.id;
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      customer.shopName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${customer.ownerName} - ${customer.mobile}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '\u20B9${customer.balance.toStringAsFixed(0)}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.check_circle,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ],
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedCustomerId = customer.id;
                                        _selectedCustomerName =
                                            customer.shopName;
                                        _customerController.text =
                                            customer.shopName;
                                      });
                                      Navigator.pop(sheetContext);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(searchController.dispose);
  }

  Widget _buildAmountInput() {
    return CustomTextField(
      label: 'Amount',
      hintText: '0.00',
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.currency_rupee,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter amount';
        final parsed = double.tryParse(value);
        if (parsed == null) return 'Enter a valid number';
        if (parsed <= 0) return 'Amount must be greater than 0';
        return null;
      },
    );
  }

  Widget _buildPaymentModeSelector() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Mode',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;
            final chips = PaymentMode.values.map((mode) {
              final isSelected = _selectedMode == mode;
              return ThemedFilterChip(
                label: mode.toString().split('.').last.toUpperCase(),
                selected: isSelected,
                onSelected: () {
                  if (!isSelected) setState(() => _selectedMode = mode);
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList();

            if (isCompact) {
              final width = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map((chip) => SizedBox(width: width, child: chip))
                    .toList(),
              );
            }

            return Row(
              children: chips
                  .map(
                    (chip) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: chip,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return CustomTextField(
      label: 'Date',
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      controller: TextEditingController(
        text: DateFormat('dd MMM yyyy').format(_selectedDate),
      ),
      prefixIcon: Icons.calendar_today,
    );
  }

  Widget _buildReferenceInput() {
    return CustomTextField(
      label: 'Reference / TXN ID',
      hintText: 'Cheque No, Bank Ref, etc.',
      controller: _referenceController,
      prefixIcon: Icons.receipt_long,
    );
  }

  Widget _buildNotesInput() {
    return CustomTextField(
      label: 'Notes',
      hintText: 'Add internal notes here...',
      controller: _notesController,
      maxLines: 3,
      prefixIcon: Icons.notes,
    );
  }

  void _showSuccessDialog(ManualPayment payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResponsiveAlertDialog(
        title: const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 64,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payment Recorded!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Amount: \u20B9${payment.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 12,
              children: [
                _actionColumn(
                  Icons.print,
                  'Print',
                  () => PdfGenerator.generateAndPrintPaymentReceipt(
                    payment,
                    _companyProfile ?? CompanyProfileData(name: 'Datt Soap'),
                  ),
                ),
                _actionColumn(
                  Icons.share,
                  'Share',
                  () => PdfGenerator.sharePaymentReceipt(
                    payment,
                    _companyProfile ?? CompanyProfileData(name: 'Datt Soap'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(true); // Exit screen
            },
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  Widget _actionColumn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.infoBg,
            child: Icon(icon, color: AppColors.info),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}



