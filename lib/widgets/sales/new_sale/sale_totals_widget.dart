import 'package:flutter/material.dart';
import '../../../widgets/ui/unified_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class SaleTotalsWidget extends StatelessWidget {
  final bool isMobile;
  final bool useSalesmanToggles;
  final bool spDefaultDiscountEnabled;
  final bool gstToggleLocked;
  final bool additionalToggleLocked;
  final bool specialToggleLocked;
  final bool showBreakdown;
  final VoidCallback onToggleBreakdown;
  final String lineDiscountLabel;

  // Financials
  final double subtotal;
  final double lineItemDiscountsTotal;
  final double discountPercentage;
  final double discountAmount;
  final double additionalDiscountPercentage;
  final double additionalDiscountAmount;
  final double taxableAmount;
  final String gstType;
  final double gstPercentage;
  final double totalGst;
  final double grandTotal;

  // Callbacks
  final ValueChanged<String?> onGstTypeChanged;
  final ValueChanged<double?> onGstPercentageChanged;
  final ValueChanged<double?> onAdditionalDiscountChanged;
  final ValueChanged<bool>? onSpDefaultDiscountToggleChanged;
  final double specialDiscountPercentage;
  final List<double> specialDiscountOptions;
  final List<double> additionalDiscountOptions;
  final ValueChanged<double?>? onSpecialDiscountPercentageChanged;

  const SaleTotalsWidget({
    super.key,
    required this.isMobile,
    this.useSalesmanToggles = false,
    this.spDefaultDiscountEnabled = false,
    this.gstToggleLocked = false,
    this.additionalToggleLocked = false,
    this.specialToggleLocked = false,
    required this.showBreakdown,
    required this.onToggleBreakdown,
    this.lineDiscountLabel = 'Line Discounts',
    required this.subtotal,
    required this.lineItemDiscountsTotal,
    required this.discountPercentage,
    required this.discountAmount,
    required this.additionalDiscountPercentage,
    required this.additionalDiscountAmount,
    required this.taxableAmount,
    required this.gstType,
    required this.gstPercentage,
    required this.totalGst,
    required this.grandTotal,
    required this.onGstTypeChanged,
    required this.onGstPercentageChanged,
    required this.onAdditionalDiscountChanged,
    this.onSpDefaultDiscountToggleChanged,
    this.specialDiscountPercentage = 0,
    this.specialDiscountOptions = const [1, 2, 3, 5],
    this.additionalDiscountOptions = const [0, 5, 8, 13],
    this.onSpecialDiscountPercentageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discountedSubtotal = subtotal - lineItemDiscountsTotal;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        0,
        isMobile ? 12 : 20,
        isMobile ? 12 : 24,
      ),
      child: Column(
        children: [
          // Configuration Panel
          UnifiedCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (useSalesmanToggles)
                  _buildSalesmanToggleControls(context)
                else ...[
                  _buildGstSelectors(context, isMobile),
                  const SizedBox(height: 12),
                  _buildAdditionalDiscountField(context, isMobile),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grand Total Card
          UnifiedCard(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAYABLE AMOUNT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          '₹${grandTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      onPressed: onToggleBreakdown,
                      icon: Icon(
                        showBreakdown
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showBreakdown) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  _buildSummaryRow(context, 'Gross Sales', subtotal),
                  if (lineItemDiscountsTotal > 0)
                    _buildSummaryRow(
                      context,
                      lineDiscountLabel,
                      -lineItemDiscountsTotal,
                      isNegative: true,
                    ),
                  if (lineItemDiscountsTotal > 0)
                    _buildSummaryRow(
                      context,
                      'Discounted Subtotal',
                      discountedSubtotal,
                    ),
                  if (discountPercentage > 0)
                    _buildSummaryRow(
                      context,
                      'Primary Discount ($discountPercentage%)',
                      -discountAmount,
                      isNegative: true,
                    ),
                  if (additionalDiscountPercentage > 0)
                    _buildSummaryRow(
                      context,
                      'Additional Discount ($additionalDiscountPercentage%)',
                      -additionalDiscountAmount,
                      isNegative: true,
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, indent: 40, endIndent: 40),
                  ),
                  _buildSummaryRow(
                    context,
                    'Taxable Value',
                    taxableAmount,
                    isBold: true,
                  ),
                  if (gstType != 'None' && gstPercentage > 0) ...[
                    if (gstType == 'CGST+SGST') ...[
                      _buildSummaryRow(
                        context,
                        'CGST (${gstPercentage / 2}%)',
                        totalGst / 2,
                      ),
                      _buildSummaryRow(
                        context,
                        'SGST (${gstPercentage / 2}%)',
                        totalGst / 2,
                      ),
                    ] else
                      _buildSummaryRow(
                        context,
                        'IGST ($gstPercentage%)',
                        totalGst,
                      ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGstSelectors(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            key: ValueKey<String>('gst_type_$gstType'),
            initialValue: gstType,
            dropdownColor: theme.colorScheme.surface,
            iconEnabledColor: theme.colorScheme.primary,
            decoration: InputDecoration(
              labelText: 'GST Method',
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            items: ['None', 'CGST+SGST', 'IGST']
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onGstTypeChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<double>(
            key: ValueKey<String>('gst_pct_$gstPercentage'),
            initialValue: gstPercentage,
            dropdownColor: theme.colorScheme.surface,
            iconEnabledColor: theme.colorScheme.primary,
            decoration: InputDecoration(
              labelText: 'Tax %',
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            items: [0.0, 5.0, 12.0, 18.0, 28.0]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      '${e.toInt()}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onGstPercentageChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesmanToggleControls(BuildContext context) {
    final gstEnabled = gstType != 'None' && gstPercentage > 0;
    final additionalEnabled = additionalDiscountPercentage > 0;
    final specialEnabled = spDefaultDiscountEnabled;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildToggleChip(
                context,
                label: 'GST',
                enabled: gstEnabled,
                onChanged: gstToggleLocked
                    ? null
                    : (enabled) {
                        if (enabled) {
                          if (gstType == 'None') {
                            onGstTypeChanged('CGST+SGST');
                          }
                          if (gstPercentage <= 0) {
                            onGstPercentageChanged(5.0);
                          }
                        } else {
                          onGstTypeChanged('None');
                          onGstPercentageChanged(0.0);
                        }
                      },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleChip(
                context,
                label: 'Additional',
                enabled: additionalEnabled,
                onChanged: additionalToggleLocked
                    ? null
                    : (enabled) {
                        if (enabled) {
                          if (additionalDiscountPercentage <= 0) {
                            onAdditionalDiscountChanged(
                              _defaultAdditionalToggleValue(),
                            );
                          }
                        } else {
                          onAdditionalDiscountChanged(0.0);
                        }
                      },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleChip(
                context,
                label: 'SP+Default',
                enabled: specialEnabled,
                onChanged: specialToggleLocked
                    ? null
                    : (enabled) {
                        onSpDefaultDiscountToggleChanged?.call(enabled);
                      },
              ),
            ),
          ],
        ),
        if (gstEnabled) ...[
          const SizedBox(height: 12),
          _buildGstSelectors(context, isMobile),
        ],
        if (additionalEnabled) ...[
          const SizedBox(height: 12),
          _buildAdditionalDiscountField(context, isMobile),
        ],
        if (specialEnabled) ...[
          const SizedBox(height: 12),
          _buildSpecialDiscountField(context),
        ],
      ],
    );
  }

  Widget _buildToggleChip(
    BuildContext context, {
    required String label,
    required bool enabled,
    required ValueChanged<bool>? onChanged,
  }) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch.adaptive(value: enabled, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialDiscountField(BuildContext context) {
    final theme = Theme.of(context);
    final options =
        specialDiscountOptions
            .where((e) => e >= 0 && e <= 100)
            .map((e) => e.toDouble())
            .toSet()
            .toList()
          ..sort();
    final normalizedOptions = options.isEmpty ? <double>[1, 2, 3, 5] : options;
    final selected = normalizedOptions.contains(specialDiscountPercentage)
        ? specialDiscountPercentage
        : normalizedOptions.first;

    return DropdownButtonFormField<double>(
      key: ValueKey<String>('special_pct_$selected'),
      initialValue: selected,
      dropdownColor: theme.colorScheme.surface,
      iconEnabledColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        labelText: 'Special Discount (%)',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      items: normalizedOptions
          .map(
            (e) => DropdownMenuItem<double>(
              value: e,
              child: Text(
                e % 1 == 0 ? '${e.toInt()}%' : '${e.toStringAsFixed(2)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: specialToggleLocked
          ? null
          : onSpecialDiscountPercentageChanged,
    );
  }

  Widget _buildAdditionalDiscountField(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final options = _normalizedAdditionalOptions();
    final selected = options.contains(additionalDiscountPercentage)
        ? additionalDiscountPercentage
        : 0.0;

    return DropdownButtonFormField<double>(
      key: ValueKey<String>('additional_pct_$selected'),
      initialValue: selected,
      dropdownColor: theme.colorScheme.surface,
      iconEnabledColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        labelText: 'Offer Additional Discount (%)',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      items: options
          .map(
            (e) => DropdownMenuItem<double>(
              value: e,
              child: Text(
                e % 1 == 0 ? '${e.toInt()}%' : '${e.toStringAsFixed(2)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: additionalToggleLocked ? null : onAdditionalDiscountChanged,
    );
  }

  List<double> _normalizedAdditionalOptions() {
    final values =
        additionalDiscountOptions
            .where((e) => e >= 0 && e <= 100)
            .map((e) => e.toDouble())
            .toSet()
            .toList()
          ..sort();
    if (!values.contains(0)) values.insert(0, 0);
    if (values.length == 1) {
      values.add(5);
    }
    return values;
  }

  double _defaultAdditionalToggleValue() {
    final positiveValues = _normalizedAdditionalOptions()
        .where((e) => e > 0)
        .toList(growable: false);
    if (positiveValues.isEmpty) return 0;
    return positiveValues.first;
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
    bool isNegative = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              fontSize: isBold ? 14 : 13,
              color: theme.colorScheme.onSurface.withValues(
                alpha: isBold ? 1.0 : 0.6,
              ),
            ),
          ),
          Text(
            '${isNegative ? "- " : ""}₹${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              fontSize: isBold ? 14 : 13,
              color: isNegative
                  ? AppColors.error
                  : (isBold
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
