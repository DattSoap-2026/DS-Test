import 'package:flutter/material.dart';
import '../../../models/types/product_types.dart';
import '../../../widgets/ui/custom_text_field.dart';
import '../../../widgets/ui/unified_card.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';
import 'package:flutter_app/utils/unit_converter.dart';

class ProductSelectorWidget extends StatefulWidget {
  final bool isMobile;
  final List<Product> allProducts;
  final Set<String> selectedProductIds;
  final ValueChanged<Product> onProductSelected;
  final VoidCallback? onSearchInteraction;
  final bool enabled;

  const ProductSelectorWidget({
    super.key,
    required this.isMobile,
    required this.allProducts,
    this.selectedProductIds = const <String>{},
    required this.onProductSelected,
    this.onSearchInteraction,
    this.enabled = true,
  });

  @override
  State<ProductSelectorWidget> createState() => _ProductSelectorWidgetState();
}

class _ProductSelectorWidgetState extends State<ProductSelectorWidget> {
  TextEditingController? _fieldController;
  FocusNode? _fieldFocusNode;

  Iterable<Product> _buildOptions(TextEditingValue textEditingValue) {
    if (!widget.enabled) return const <Product>[];
    final sellableProducts =
        widget.allProducts
            .where(
              (p) =>
                  p.type == ProductTypeEnum.finished ||
                  p.type == ProductTypeEnum.traded,
            )
            .where((p) => !widget.selectedProductIds.contains(p.id))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    if (textEditingValue.text.isEmpty) {
      return sellableProducts;
    }

    final query = textEditingValue.text.toLowerCase();
    return sellableProducts.where(
      (option) =>
          option.name.toLowerCase().contains(query) ||
          option.sku.toLowerCase().contains(query),
    );
  }

  void _triggerSearchInteraction(BuildContext context) {
    if (!widget.enabled) return;
    widget.onSearchInteraction?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.04,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom;
    final dropdownMaxHeight = (usableHeight * 0.38).clamp(180.0, 340.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 12 : 20,
        vertical: 4,
      ),
      child: Autocomplete<Product>(
        optionsViewOpenDirection: OptionsViewOpenDirection.down,
        displayStringForOption: (Product option) => option.name,
        optionsBuilder: _buildOptions,
        onSelected: (product) {
          if (!widget.enabled) return;
          widget.onProductSelected(product);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fieldController?.clear();
            _fieldFocusNode?.unfocus();
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          _fieldController = controller;
          _fieldFocusNode = focusNode;

          return Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) _triggerSearchInteraction(context);
            },
            child: CustomTextField(
              label: '',
              hintText: 'Scan or Search Product...',
              controller: controller,
              focusNode: focusNode,
              readOnly: !widget.enabled,
              onTap: () {
                if (!widget.enabled) return;
                _triggerSearchInteraction(context);
                if (!focusNode.hasFocus) {
                  focusNode.requestFocus();
                }
                // Force Autocomplete to re-evaluate options on empty click
                if (controller.text.isEmpty) {
                  controller.text = ' ';
                  controller.clear();
                }
              },
              prefixIcon: Icons.qr_code_scanner_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  focusNode.hasFocus
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: theme.colorScheme.primary,
                ),
                onPressed: !widget.enabled
                    ? null
                    : () {
                  if (focusNode.hasFocus) {
                    focusNode.unfocus();
                  } else {
                    _triggerSearchInteraction(context);
                    focusNode.requestFocus();
                    if (controller.text.isEmpty) {
                      controller.text = ' ';
                      controller.clear();
                    }
                  }
                },
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          if (!widget.enabled) return const SizedBox.shrink();
          final optionList = options.toList(growable: false);
          if (optionList.isEmpty) return const SizedBox.shrink();
          return Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: UnifiedCard(
                width: Responsive.width(context) - (widget.isMobile ? 24 : 40),
                padding: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: dropdownMaxHeight),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: optionList.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.05),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final Product option = optionList[index];
                      final hasBox = UnitConverter.hasSecondaryUnit(
                        option.secondaryUnit,
                        option.conversionFactor,
                      );
                      final stockDisplay = hasBox
                          ? UnitConverter.formatDual(
                              baseQty: option.stock,
                              baseUnit: option.baseUnit,
                              secondaryUnit: option.secondaryUnit,
                              conversionFactor: option.conversionFactor,
                            )
                          : '${option.stock.toInt()} ${option.baseUnit}';
                      return ListTile(
                        hoverColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                        title: Text(
                          option.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SKU: ${option.sku} | ₹${option.price.toStringAsFixed(2)}/${option.baseUnit}'
                              '${hasBox && option.secondaryPrice != null ? ' | ₹${option.secondaryPrice!.toStringAsFixed(2)}/${option.secondaryUnit}' : ''}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 11,
                                  color: option.stock > 0
                                      ? AppColors.success
                                      : theme.colorScheme.error.withValues(
                                          alpha: 0.7,
                                        ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Stock: $stockDisplay',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: option.stock > 0
                                        ? AppColors.success
                                        : theme.colorScheme.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.add_circle_outline_rounded,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        onTap: () {
                          if (!widget.enabled) return;
                          _fieldFocusNode?.unfocus();
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
