import 'package:flutter/material.dart';

import '../../utils/responsive.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveConfig config) builder;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.builder,
    this.scrollable = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = Responsive.configForWidth(constraints.maxWidth);
        final resolvedPadding =
            padding ??
            EdgeInsets.symmetric(horizontal: config.horizontalPadding);
        final content = Padding(
          padding: resolvedPadding,
          child: builder(context, config),
        );
        if (!scrollable) return content;
        return SingleChildScrollView(child: content);
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    final config = Responsive.configOf(context);
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(horizontal: config.horizontalPadding);
    final constrainedChild = maxWidth == null
        ? child
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: child,
          );

    return Padding(
      padding: resolvedPadding,
      child: Align(alignment: alignment, child: constrainedChild),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final bool forceWrap;
  final double wrapBelowWidth;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final WrapAlignment wrapAlignment;
  final WrapCrossAlignment wrapCrossAlignment;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 8,
    this.forceWrap = false,
    this.wrapBelowWidth = 1024,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.wrapAlignment = WrapAlignment.start,
    this.wrapCrossAlignment = WrapCrossAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldWrap = forceWrap || constraints.maxWidth < wrapBelowWidth;
        if (shouldWrap) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            alignment: wrapAlignment,
            crossAxisAlignment: wrapCrossAlignment,
            children: children,
          );
        }
        return Row(
          mainAxisAlignment: rowMainAxisAlignment,
          crossAxisAlignment: rowCrossAxisAlignment,
          children: _withSpacing(children, spacing),
        );
      },
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets, double gap) {
    if (widgets.length <= 1) return widgets;
    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i != widgets.length - 1) {
        result.add(SizedBox(width: gap));
      }
    }
    return result;
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;
  final int minColumns;
  final int maxColumns;
  final double spacing;
  final double runSpacing;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minTileWidth = 260,
    this.minColumns = 1,
    this.maxColumns = 6,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Responsive.columnsForWidth(
          constraints.maxWidth,
          minTileWidth: minTileWidth,
          min: minColumns,
          max: maxColumns,
          spacing: spacing,
        );
        final tileWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map((child) => SizedBox(width: tileWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class AdaptiveFormLayout extends StatelessWidget {
  final List<Widget> children;
  final int maxColumns;
  final double minColumnWidth;
  final double spacing;
  final double runSpacing;

  const AdaptiveFormLayout({
    super.key,
    required this.children,
    this.maxColumns = 2,
    this.minColumnWidth = 320,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final computedColumns = Responsive.columnsForWidth(
          constraints.maxWidth,
          minTileWidth: minColumnWidth,
          min: 1,
          max: maxColumns,
          spacing: spacing,
        );
        final columnWidth =
            (constraints.maxWidth - ((computedColumns - 1) * spacing)) /
            computedColumns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map((child) => SizedBox(width: columnWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
