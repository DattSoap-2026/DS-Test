import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/types/return_types.dart';
import '../../services/settings_service.dart';
import '../../utils/pdf_generator.dart';

class ReturnRequestDetailsScreen extends StatelessWidget {
  final ReturnRequest request;
  final bool canApprove;
  final Future<void> Function(bool)? onAction;

  const ReturnRequestDetailsScreen({
    super.key,
    required this.request,
    this.canApprove = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = request.status == 'pending';
    final totalValue = request.items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * (item.price ?? 0)),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Return Request Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context),
              const SizedBox(height: 12),
              Center(child: _buildStatusBadge(context, request.status)),
              const SizedBox(height: 16),
              Text(
                'Returned Items',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildItemsCard(context),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: 'Total Value: ',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: _formatCurrency(totalValue),
                        style: const TextStyle(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _printCreditNote(context),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Print Credit Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                  if (isPending && canApprove)
                    OutlinedButton(
                      onPressed: () => _handleAction(context, approve: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Reject'),
                    ),
                  if (isPending && canApprove)
                    ElevatedButton(
                      onPressed: () => _handleAction(context, approve: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: const Text('Approve'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            'Salesman',
            request.salesmanName,
            theme.colorScheme.primary,
          ),
          _buildInfoRow(
            context,
            'Date',
            _formatDateSafe(request.createdAt, pattern: 'MMMM d, yyyy'),
            theme.colorScheme.onSurfaceVariant,
          ),
          _buildInfoRow(
            context,
            'Type',
            request.returnType.replaceAll('_', ' '),
            theme.colorScheme.secondary,
          ),
          _buildInfoRow(
            context,
            'Reason',
            request.reason,
            theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: request.items.length,
        separatorBuilder: (_, index) => Divider(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
        itemBuilder: (context, index) {
          final item = request.items[index];
          final price = item.price ?? 0;
          final itemTotal = item.quantity * price;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetric(
                      context,
                      label: 'Qty',
                      value: item.quantity.toStringAsFixed(0),
                    ),
                    _buildMetric(
                      context,
                      label: 'Unit Price',
                      value: _formatCurrency(price),
                    ),
                    _buildMetric(
                      context,
                      label: 'Total',
                      value: _formatCurrency(itemTotal),
                      emphasize: true,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required String value,
    bool emphasize = false,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: emphasize
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'approved':
        bgColor = AppColors.success;
        textColor = theme.colorScheme.onPrimary;
        break;
      case 'rejected':
        bgColor = AppColors.error.withValues(alpha: 0.16);
        textColor = AppColors.error;
        break;
      default:
        bgColor = AppColors.warning.withValues(alpha: 0.16);
        textColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  String _formatCurrency(double value) {
    return '\u20B9${NumberFormat('#,##,###.00').format(value)}';
  }

  Future<void> _printCreditNote(BuildContext context) async {
    try {
      final company = await context
          .read<SettingsService>()
          .getCompanyProfileClient();
      if (context.mounted && company != null) {
        await PdfGenerator.generateAndPrintCreditNote(request, company);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company profile not found')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error printing: $e')));
      }
    }
  }

  Future<void> _handleAction(
    BuildContext context, {
    required bool approve,
  }) async {
    final handler = onAction;
    if (handler != null) {
      await handler(approve);
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
