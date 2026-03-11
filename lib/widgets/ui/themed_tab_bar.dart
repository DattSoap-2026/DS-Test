import 'package:flutter/material.dart';

class ThemedTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  final List<Widget> tabs;
  final bool isScrollable;
  final TabAlignment? tabAlignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? labelPadding;
  final ValueChanged<int>? onTap;
  final TabBarIndicatorSize indicatorSize;
  final EdgeInsetsGeometry indicatorPadding;
  final bool? enableFeedback;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final Color? indicatorBorderColor;

  const ThemedTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.tabAlignment,
    this.padding,
    this.labelPadding,
    this.onTap,
    this.indicatorSize = TabBarIndicatorSize.tab,
    this.indicatorPadding = const EdgeInsets.symmetric(
      horizontal: 4,
      vertical: 6,
    ),
    this.enableFeedback,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.indicatorBorderColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final compactScreen = MediaQuery.sizeOf(context).width < 430;
    final effectiveIsScrollable = isScrollable || compactScreen;

    return TabBar(
      controller: controller,
      tabs: tabs,
      isScrollable: effectiveIsScrollable,
      tabAlignment:
          tabAlignment ?? (effectiveIsScrollable ? TabAlignment.start : null),
      padding: padding,
      labelPadding: labelPadding,
      onTap: onTap,
      enableFeedback: enableFeedback,
      indicatorSize: indicatorSize,
      indicatorPadding: indicatorPadding,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.primary.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
      indicator: BoxDecoration(
        color: indicatorColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: indicatorBorderColor ?? colorScheme.primary),
      ),
      labelColor: labelColor ?? colorScheme.onPrimaryContainer,
      unselectedLabelColor:
          unselectedLabelColor ?? colorScheme.onSurfaceVariant,
      dividerColor: Colors.transparent,
      labelStyle:
          labelStyle ??
          theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          unselectedLabelStyle ??
          theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
