import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../ui/unified_card.dart';

class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isTrendPositive;
  final double? progress;
  final VoidCallback? onTap;
  final bool isGlass;
  final bool dense;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.isTrendPositive = true,
    this.progress,
    this.onTap,
    this.isGlass = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trendColor = isTrendPositive
        ? AppColors.success
        : theme.colorScheme.error;
    final compact = Responsive.isMobile(context);
    final padding = dense ? (compact ? 8.0 : 10.0) : (compact ? 10.0 : 14.0);
    final iconPadding = dense ? (compact ? 5.0 : 6.0) : (compact ? 6.0 : 8.0);
    final iconSize = dense ? (compact ? 16.0 : 18.0) : (compact ? 18.0 : 20.0);
    final gapL = dense ? (compact ? 4.0 : 6.0) : (compact ? 6.0 : 10.0);
    final gapS = dense ? 1.0 : (compact ? 1.0 : 2.0);

    Widget buildCardBody() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.2 : 0.08),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Watermark Icon
            Positioned(
              right: dense ? -8 : -12,
              bottom: dense ? -6 : -10,
              child: Icon(
                icon,
                size: dense ? 60 : 80,
                color: color.withValues(alpha: isDark ? 0.08 : 0.04),
              ),
            ),
            // Foreground Content
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.3 : 0.15),
                          borderRadius: BorderRadius.circular(dense ? 10 : 14),
                        ),
                        child: Icon(icon, color: color, size: iconSize),
                      ),
                      if (trend != null) const SizedBox(width: 8),
                      if (trend != null)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: dense ? 6 : 8,
                                  vertical: dense ? 3 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: trendColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isTrendPositive
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                      size: dense ? 12 : 14,
                                      color: trendColor,
                                    ),
                                    SizedBox(width: dense ? 3 : 4),
                                    Text(
                                      trend ?? '',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: trendColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: gapL),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (dense
                                ? theme.textTheme.headlineSmall
                                : theme.textTheme.headlineMedium)
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: dense ? -0.5 : -0.7,
                              height: 0.95,
                              fontSize: compact ? (dense ? 22 : 26) : null,
                            ),
                  ),
                  SizedBox(height: gapS),
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.8,
                      ),
                      fontWeight: FontWeight.w800,
                      letterSpacing: dense ? 0.5 : 0.7,
                      fontSize: compact ? 9 : (dense ? 10 : null),
                    ),
                  ),
                  if (progress != null) ...[
                    SizedBox(height: gapL),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (progress ?? 0.0).clamp(0.0, 1.0),
                        backgroundColor: theme
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ],
                  if (subtitle != null) ...[
                    SizedBox(height: compact ? 6 : 8),
                    Text(
                      subtitle ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: dense ? 9 : 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    final Widget cardContent = LayoutBuilder(
      builder: (context, constraints) {
        final body = buildCardBody();
        if (!constraints.hasBoundedHeight) return body;
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: body,
          ),
        );
      },
    );

    return UnifiedCard(
      isGlass: isGlass,
      onTap: onTap,
      padding: EdgeInsets.zero,
      useLayoutBuilder: true,
      child: cardContent,
    );
  }
}
