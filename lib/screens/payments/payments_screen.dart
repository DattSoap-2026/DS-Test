import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/payments_service.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../services/settings_service.dart';
import '../../utils/pdf_generator.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late final PaymentsService _paymentsService;
  late final SettingsService _settingsService;

  List<ManualPayment> _payments = [];
  bool _isLoading = true;
  CompanyProfileData? _companyProfile;

  @override
  void initState() {
    super.initState();
    _paymentsService = context.read<PaymentsService>();
    _settingsService = context.read<SettingsService>();
    _loadPayments();
    _loadCompanyProfile();
  }

  Future<void> _loadCompanyProfile() async {
    final profile = await _settingsService.getCompanyProfileClient();
    if (mounted) {
      setState(() => _companyProfile = profile);
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final payments = await _paymentsService.getPayments();
    if (mounted) {
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadPayments,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadPayments,
                    child: ListView.builder(
                      itemCount: _payments.length,
                      itemBuilder: (context, index) {
                        final payment = _payments[index];
                        return _buildPaymentCard(payment);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'payments_fab',
        onPressed: () => context.push('/dashboard/payments/add'),
        backgroundColor: const Color(0xFF4f46e5),
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No payments recorded yet',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.push('/dashboard/payments/add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4f46e5),
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Add First Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(ManualPayment payment) {
    final date = DateTime.parse(payment.date);
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getModeColor(payment.mode).withValues(alpha: 0.1),
          child: Icon(
            _getModeIcon(payment.mode),
            color: _getModeColor(payment.mode),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                payment.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '₹${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment.mode.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (payment.reference != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ref: ${payment.reference}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                payment.notes!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Collected by: ${payment.collectorName}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Payment Receipt',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      Icons.print,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Print / Preview PDF'),
                    onTap: () {
                      Navigator.pop(context);
                      PdfGenerator.generateAndPrintPaymentReceipt(
                        payment,
                        _companyProfile ??
                            CompanyProfileData(name: 'Datt Soap'),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Share PDF'),
                    onTap: () {
                      Navigator.pop(context);
                      PdfGenerator.sharePaymentReceipt(
                        payment,
                        _companyProfile ??
                            CompanyProfileData(name: 'Datt Soap'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return AppColors.success;
      case PaymentMode.cheque:
        return AppColors.warning;
      case PaymentMode.transfer:
        return AppColors.info;
      case PaymentMode.online:
        return AppColors.info;
    }
  }

  IconData _getModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.money;
      case PaymentMode.cheque:
        return Icons.account_balance_wallet;
      case PaymentMode.transfer:
        return Icons.account_balance;
      case PaymentMode.online:
        return Icons.language;
    }
  }
}

