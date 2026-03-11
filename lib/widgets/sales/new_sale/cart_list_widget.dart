import 'package:flutter/material.dart';
import '../../../models/types/sales_types.dart';
import '../../../widgets/ui/unified_card.dart';
import '../../../widgets/ui/custom_states.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/normalized_number_input_formatter.dart';
import '../../../utils/unit_converter.dart';

class CartListWidget extends StatelessWidget {
  final bool isMobile;
  final List<CartItem> cart;
  final ValueChanged<int> onRemoveItem;
  final Function(int index, int newQty) onUpdateQty;
  final bool isEditable;

  const CartListWidget({
    super.key,
    required this.isMobile,
    required this.cart,
    required this.onRemoveItem,
    required this.onUpdateQty,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (cart.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 64),
        child: const CustomEmptyState(
          icon: Icons.shopping_basket_outlined,
          title: 'Your cart is empty',
          message: 'Explore catalog above to add items',
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 8,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cart.length,
      itemBuilder: (context, index) {
        final item = cart[index];
        // Use centralized UnitConverter — no inline math
        final hasSecondary = UnitConverter.hasSecondaryUnit(
          item.secondaryUnit,
          item.conversionFactor ?? 1.0,
        );
        final secondaryQty = hasSecondary
            ? UnitConverter.fullSecondaryUnits(
                item.quantity.toDouble(),
                item.conversionFactor!,
              )
            : 0;
        final baseQty = hasSecondary
            ? UnitConverter.remainingBaseUnits(
                item.quantity.toDouble(),
                item.conversionFactor!,
              )
            : item.quantity;
        final qtyDisplayLabel = hasSecondary
            ? UnitConverter.formatDual(
                baseQty: item.quantity.toDouble(),
                baseUnit: item.baseUnit,
                secondaryUnit: item.secondaryUnit,
                conversionFactor: item.conversionFactor ?? 1.0,
              )
            : null;
        final lineSubtotal = _computeLineSubtotal(
          item: item,
          hasSecondary: hasSecondary,
          secondaryQty: secondaryQty,
          baseQty: baseQty,
        );
        final discountPct = item.discount.clamp(0.0, 100.0);
        final lineDiscountAmount = item.isFree
            ? 0.0
            : lineSubtotal * (discountPct / 100);
        final lineNetAmount = item.isFree
            ? 0.0
            : (lineSubtotal - lineDiscountAmount).clamp(0.0, double.infinity);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UnifiedCard(
            onTap: null,
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.6,
                          ),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name.toUpperCase(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.isFree)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'FREE',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (item.schemeName != null &&
                                item.schemeName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Applied: ${item.schemeName}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              hasSecondary
                                  ? '\u20B9${item.secondaryPrice?.toStringAsFixed(0)}/${item.secondaryUnit} & \u20B9${item.price.toStringAsFixed(0)}/${item.baseUnit}'
                                  : '\u20B9${item.price.toStringAsFixed(2)} per ${item.baseUnit}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!item.isFree)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.5,
                            ),
                            size: 22,
                          ),
                          onPressed: isEditable ? () => onRemoveItem(index) : null,
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.2)
                                    : theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasSecondary) ...[
                                    _buildModernQtyInput(
                                      context,
                                      value: secondaryQty,
                                      unit: item.secondaryUnit!,
                                      enabled: isEditable && !item.isFree,
                                      onChanged: (val) {
                                        final newTotalQty =
                                            (val * item.conversionFactor!)
                                                .toInt() +
                                            baseQty;
                                        onUpdateQty(index, newTotalQty);
                                      },
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      color: theme.dividerColor.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ],
                                  _buildModernQtyInput(
                                    context,
                                    value: baseQty,
                                    unit: item.baseUnit,
                                    enabled: isEditable && !item.isFree,
                                    onChanged: (val) {
                                      final newTotalQty =
                                          (secondaryQty *
                                                  (item.conversionFactor ?? 1))
                                              .toInt() +
                                          val;
                                      onUpdateQty(index, newTotalQty);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (!item.isFree)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Disc ${discountPct.toStringAsFixed(discountPct.truncateToDouble() == discountPct ? 0 : 1)}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.isFree
                                  ? 'FREE'
                                  : '\u20B9${lineNetAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: item.isFree
                                    ? AppColors.success
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            if (!item.isFree && lineDiscountAmount > 0)
                              Text(
                                '-\u20B9${lineDiscountAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Dual-unit read-only quantity badge (inside UnifiedCard Column)
                if (qtyDisplayLabel != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 12,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Total: $qtyDisplayLabel',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _computeLineSubtotal({
    required CartItem item,
    required bool hasSecondary,
    required int secondaryQty,
    required int baseQty,
  }) {
    if (item.isFree) return 0.0;
    if (hasSecondary &&
        item.secondaryPrice != null &&
        item.secondaryPrice! > 0) {
      // Use centralized UnitConverter values (already computed by caller)
      return (secondaryQty * item.secondaryPrice!) + (baseQty * item.price);
    }
    return item.price * item.quantity;
  }

  Widget _buildModernQtyInput(
    BuildContext context, {
    required int value,
    required String unit,
    required bool enabled,
    required ValueChanged<int> onChanged,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyBtn(
          context,
          icon: Icons.remove_rounded,
          onPressed: enabled && value > 0 ? () => onChanged(value - 1) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          child: InkWell(
            onTap: enabled
                ? () => _showQuantityInputDialog(
                    context,
                    currentValue: value,
                    unit: unit,
                    onSubmitted: onChanged,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    unit.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'tap',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary.withValues(alpha: 0.65),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _qtyBtn(
          context,
          icon: Icons.add_rounded,
          onPressed: enabled ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }

  Future<void> _showQuantityInputDialog(
    BuildContext context, {
    required int currentValue,
    required String unit,
    required ValueChanged<int> onSubmitted,
  }) async {
    final controller = TextEditingController(text: currentValue.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Enter Quantity (${unit.toUpperCase()})'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            inputFormatters: [
              NormalizedNumberInputFormatter.integer(keepZeroWhenEmpty: true),
            ],
            decoration: const InputDecoration(
              hintText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              final parsed = int.tryParse(controller.text.trim());
              Navigator.of(dialogContext).pop(parsed);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                Navigator.of(dialogContext).pop(parsed);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      onSubmitted(result);
    }
  }

  Widget _qtyBtn(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      style: IconButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
