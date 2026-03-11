import 'package:flutter/material.dart';

class ThemedSegmentControl<T> extends StatelessWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final VisualDensity? visualDensity;
  final MaterialTapTargetSize? tapTargetSize;

  const ThemedSegmentControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.textStyle,
    this.visualDensity,
    this.tapTargetSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: showSelectedIcon,
      style: ButtonStyle(
        animationDuration: const Duration(milliseconds: 200),
        padding: WidgetStatePropertyAll(padding),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        visualDensity: visualDensity,
        tapTargetSize: tapTargetSize,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimaryContainer;
          }
          return colorScheme.onSurfaceVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withValues(alpha: 0.08);
          }
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.12);
          }
          return Colors.transparent;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return BorderSide(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 1.4 : 1.0,
          );
        }),
        textStyle: WidgetStatePropertyAll(
          theme.textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.w600)
              .merge(textStyle),
        ),
      ),
    );
  }
}
