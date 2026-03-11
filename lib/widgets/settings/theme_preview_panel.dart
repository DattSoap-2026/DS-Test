import 'package:flutter/material.dart';

class ThemePreviewPanel extends StatelessWidget {
  final ThemeData previewTheme;

  const ThemePreviewPanel({super.key, required this.previewTheme});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: previewTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Live Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _PreviewKpiCard(),
                const SizedBox(height: 12),
                const _PreviewActionButton(),
                const SizedBox(height: 12),
                Text(
                  'Dashboard Summary',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Revenue and operations insights preview.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PreviewKpiCard extends StatelessWidget {
  static const double _targetValue = 12.4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.trending_up,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Sales',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  key: ValueKey(colorScheme.primary.toARGB32()),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0, end: _targetValue),
                  builder: (context, value, child) {
                    return Text(
                      '\u20B9${value.toStringAsFixed(1)}L',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewActionButton extends StatefulWidget {
  const _PreviewActionButton();

  @override
  State<_PreviewActionButton> createState() => _PreviewActionButtonState();
}

class _PreviewActionButtonState extends State<_PreviewActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = colorScheme.primary;
    final hoverColor = Color.alphaBlend(
      colorScheme.onPrimary.withValues(alpha: 0.08),
      baseColor,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: baseColor.withValues(alpha: _hovered ? 0.4 : 0.2),
          ),
        ),
        child: Tooltip(
          message: 'Preview only - action is disabled in theme demo.',
          child: FilledButton.icon(
            onPressed: null,
            style: FilledButton.styleFrom(
              backgroundColor: _hovered ? hoverColor : baseColor,
              foregroundColor: colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Primary Action'),
          ),
        ),
      ),
    );
  }
}
