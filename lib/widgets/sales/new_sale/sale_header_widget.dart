import 'package:flutter/material.dart';
import '../../../models/customer.dart';
import '../../../widgets/ui/unified_card.dart';
import '../../../widgets/ui/custom_text_field.dart';

class SaleHeaderWidget extends StatelessWidget {
  final bool isMobile;
  final bool isSalesman;
  final List<String> availableRoutes;
  final String? selectedRoute;
  final Customer? selectedCustomer;
  final List<Customer> filteredCustomers;
  final List<Customer> allCustomers;
  final VoidCallback? onInputInteraction;
  final ValueChanged<String?> onRouteChanged;
  final ValueChanged<Customer?> onCustomerSelected;

  const SaleHeaderWidget({
    super.key,
    required this.isMobile,
    required this.isSalesman,
    required this.availableRoutes,
    required this.selectedRoute,
    required this.selectedCustomer,
    required this.filteredCustomers,
    required this.allCustomers,
    this.onInputInteraction,
    required this.onRouteChanged,
    required this.onCustomerSelected,
  });

  void _scrollFieldToTop(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.02,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
      Future<void>.delayed(const Duration(milliseconds: 260), () {
        if (!context.mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: 0.02,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      });
    });
  }

  void _focusAndOpenOptions({
    required BuildContext context,
    required FocusNode focusNode,
    required TextEditingController controller,
  }) {
    onInputInteraction?.call();
    _scrollFieldToTop(context);
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
    }
    if (controller.text.isEmpty) {
      controller.value = const TextEditingValue(
        text: ' ',
        selection: TextSelection.collapsed(offset: 1),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!focusNode.hasFocus) return;
        controller.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      });
    }
  }

  double _dropdownMaxHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final usableHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final maxHeight = usableHeight * 0.36;
    return maxHeight.clamp(170.0, 320.0);
  }

  double _dropdownWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (isMobile) {
      return (screenWidth - 48).clamp(220.0, 640.0);
    }
    return (screenWidth * 0.52).clamp(320.0, 640.0);
  }

  Widget _buildRouteSelector(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final openUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    final routeHint = availableRoutes.isEmpty
        ? 'No routes available'
        : 'Search and select route...';

    return Autocomplete<String>(
      optionsViewOpenDirection: openUp
          ? OptionsViewOpenDirection.up
          : OptionsViewOpenDirection.down,
      key: ValueKey<String>('route_${selectedRoute ?? ''}'),
      initialValue: TextEditingValue(text: selectedRoute ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (availableRoutes.isEmpty) return const Iterable<String>.empty();
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return availableRoutes;
        }
        return availableRoutes.where(
          (route) => route.toLowerCase().contains(query),
        );
      },
      onSelected: (route) {
        onRouteChanged(route);
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        final selectedText = selectedRoute ?? '';
        if (!focusNode.hasFocus && controller.text != selectedText) {
          controller.value = TextEditingValue(
            text: selectedText,
            selection: TextSelection.collapsed(offset: selectedText.length),
          );
        }

        return Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              onInputInteraction?.call();
              _scrollFieldToTop(context);
            }
          },
          child: CustomTextField(
            label: '',
            hintText: routeHint,
            controller: controller,
            focusNode: focusNode,
            readOnly: availableRoutes.isEmpty,
            onTap: () {
              if (availableRoutes.isEmpty) return;
              _focusAndOpenOptions(
                context: context,
                focusNode: focusNode,
                controller: controller,
              );
            },
            onChanged: (value) {
              if (value.trim().isEmpty && selectedRoute != null) {
                onRouteChanged(null);
              }
            },
            prefixIcon: Icons.route_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                focusNode.hasFocus
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              onPressed: availableRoutes.isEmpty
                  ? null
                  : () {
                      _focusAndOpenOptions(
                        context: context,
                        focusNode: focusNode,
                        controller: controller,
                      );
                    },
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final optionList = options.toList(growable: false);
        if (optionList.isEmpty) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: openUp ? 0 : 2,
              bottom: openUp ? 2 : 0,
            ),
            child: Material(
              elevation: 14,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: _dropdownWidth(context),
                constraints: BoxConstraints(
                  maxHeight: _dropdownMaxHeight(context),
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: optionList.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.08),
                  ),
                  itemBuilder: (context, index) {
                    final route = optionList[index];
                    final isSelected = route == selectedRoute;
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
                      minTileHeight: 42,
                      tileColor: isSelected
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: isDark ? 0.25 : 0.35,
                            )
                          : null,
                      title: Text(
                        route,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => onSelected(route),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerSelector(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final openUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Autocomplete<Customer>(
      optionsViewOpenDirection: openUp
          ? OptionsViewOpenDirection.up
          : OptionsViewOpenDirection.down,
      displayStringForOption: (Customer option) =>
          '${option.shopName} (${option.ownerName})',
      optionsBuilder: (TextEditingValue textEditingValue) {
        final customersToSearch = (selectedRoute != null)
            ? filteredCustomers
            : allCustomers;
        final query = textEditingValue.text.trim().toLowerCase();

        if (query.isEmpty) {
          return customersToSearch;
        }

        return customersToSearch.where(
          (c) =>
              c.shopName.toLowerCase().contains(query) ||
              c.ownerName.toLowerCase().contains(query),
        );
      },
      onSelected: (customer) {
        onCustomerSelected(customer);
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              onInputInteraction?.call();
              _scrollFieldToTop(context);
            }
          },
          child: CustomTextField(
            label: '',
            hintText: selectedRoute != null
                ? 'Search in $selectedRoute...'
                : 'Search all customers...',
            controller: controller,
            focusNode: focusNode,
            onTap: () {
              _focusAndOpenOptions(
                context: context,
                focusNode: focusNode,
                controller: controller,
              );
            },
            prefixIcon: Icons.search_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                focusNode.hasFocus
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              onPressed: () {
                _focusAndOpenOptions(
                  context: context,
                  focusNode: focusNode,
                  controller: controller,
                );
              },
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final optionList = options.toList(growable: false);
        if (optionList.isEmpty) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: openUp ? 0 : 2,
              bottom: openUp ? 2 : 0,
            ),
            child: Material(
              elevation: 14,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: _dropdownWidth(context),
                constraints: BoxConstraints(
                  maxHeight: _dropdownMaxHeight(context),
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: optionList.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.08),
                  ),
                  itemBuilder: (context, index) {
                    final customer = optionList[index];
                    final ownerName = customer.ownerName.trim();
                    final showOwner =
                        ownerName.isNotEmpty &&
                        ownerName.toLowerCase() !=
                            customer.shopName.trim().toLowerCase();
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
                      minTileHeight: showOwner ? 52 : 42,
                      tileColor: index == 0
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: isDark ? 0.15 : 0.28,
                            )
                          : null,
                      title: Text(
                        customer.shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: showOwner
                          ? Text(
                              ownerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () => onSelected(customer),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 20.0,
        vertical: isMobile ? 8.0 : 16.0,
      ),
      child: UnifiedCard(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_cart_checkout_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SALE DETAILS',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Route Selection
            if (availableRoutes.isNotEmpty || isSalesman) ...[
              Text(
                'Assign Route',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              _buildRouteSelector(context, theme, isDark),
              const SizedBox(height: 20),
            ],

            // Customer Selection
            if (selectedCustomer != null) ...[
              Text(
                'Customer Information',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCustomer!.shopName.toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Owner: ${selectedCustomer!.ownerName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      onPressed: () => onCustomerSelected(null),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Search Customer',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              _buildCustomerSelector(context, theme, isDark),
            ],
          ],
        ),
      ),
    );
  }
}
