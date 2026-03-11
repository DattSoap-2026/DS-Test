import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Widget? title;
  final Widget? subtitle;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  final Widget? footer;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(16),
    this.actions,
    this.footer,
    this.onTap,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget card = Container(
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.25 : 0.12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(padding: padding, child: _buildContent(context)),
              )
            : Padding(padding: padding, child: _buildContent(context)),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }

    return card;
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || actions != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        child: title!,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
              if (actions != null)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        child,
        if (footer != null) ...[
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          footer!,
        ],
      ],
    );
  }
}
