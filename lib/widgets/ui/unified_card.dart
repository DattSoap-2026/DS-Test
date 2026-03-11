import 'package:flutter/material.dart';

class UnifiedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final List<Widget>? actions;
  final bool isGlass;
  final Color? backgroundColor;
  final BoxBorder? border;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showShadow;
  final double? width;
  final bool useLayoutBuilder;
  final bool disableScroll;

  const UnifiedCard({
    super.key,
    required this.child,
    this.padding,
    this.title,
    this.actions,
    this.isGlass = false,
    this.backgroundColor,
    this.border,
    this.margin,
    this.onTap,
    this.showShadow = false,
    this.width,
    this.useLayoutBuilder = true,
    this.disableScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeActions = actions ?? const <Widget>[];
    final hasHeader = title != null || safeActions.isNotEmpty;

    Widget contentBody;
    if (useLayoutBuilder) {
      contentBody = LayoutBuilder(
        builder: (context, constraints) {
          final isBounded = constraints.hasBoundedHeight;
          final crossAxis = constraints.hasBoundedWidth
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start;
          Widget bodyChild = Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          );
          if (isBounded && !disableScroll) {
            bodyChild = ClipRect(
              child: SingleChildScrollView(
                primary: false,
                physics: const ClampingScrollPhysics(),
                child: bodyChild,
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: crossAxis,
            children: [
              if (hasHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (safeActions.isNotEmpty) ...safeActions,
                    ],
                  ),
                ),
              if (isBounded) Expanded(child: bodyChild) else bodyChild,
            ],
          );
        },
      );
    } else {
      contentBody = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (safeActions.isNotEmpty) ...safeActions,
                ],
              ),
            ),
          Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
        ],
      );
    }

    Widget content = Container(
      width: width,
      constraints: const BoxConstraints(minWidth: 1.0, minHeight: 1.0),
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(16),
        color: isGlass
            ? theme.colorScheme.surface.withValues(alpha: 0.12)
            : backgroundColor,
      ),
      child: contentBody,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }

    return Card(
      elevation: isGlass ? 0 : (showShadow ? 4 : 0),
      color: isGlass
          ? Colors.transparent
          : (backgroundColor ?? theme.colorScheme.surface),
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: border != null
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
