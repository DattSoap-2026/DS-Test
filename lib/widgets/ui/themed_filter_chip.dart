import 'package:flutter/material.dart';
import 'package:flutter_app/utils/responsive.dart';

class ThemedFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback? onSelected;
  final EdgeInsets padding;
  final bool enabled;
  final bool showCheck;
  final TextStyle? textStyle;
  final IconData? leadingIcon;
  final double leadingIconSize;

  const ThemedFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.enabled = true,
    this.showCheck = false,
    this.textStyle,
    this.leadingIcon,
    this.leadingIconSize = 14,
  });

  @override
  State<ThemedFilterChip> createState() => _ThemedFilterChipState();
}

class _ThemedFilterChipState extends State<ThemedFilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canHover = Responsive.width(context) > 900;
    final isInteractive = widget.enabled && widget.onSelected != null;

    final background = widget.selected
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = widget.selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final baseBorder = widget.selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final hoverBorder = colorScheme.primary;

    return MouseRegion(
      onEnter: (_) {
        if (!canHover || !isInteractive) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!canHover || !isInteractive) return;
        setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: _hovered ? hoverBorder : baseBorder,
            width: widget.selected ? 1.4 : 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isInteractive ? widget.onSelected : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: widget.padding,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ).merge(widget.textStyle),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.showCheck && widget.selected) ...[
                        Icon(
                          Icons.check,
                          size: 14,
                          color: textColor,
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (widget.leadingIcon != null) ...[
                        Icon(
                          widget.leadingIcon,
                          size: widget.leadingIconSize,
                          color: textColor,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(widget.label),
                    ],
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}

