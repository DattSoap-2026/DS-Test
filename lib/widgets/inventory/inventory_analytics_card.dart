import 'package:flutter/material.dart';
import '../../models/types/product_types.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final Map<String, dynamic>? trend;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isMobile = Responsive.isMobile(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(
      1.0,
      1.35,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 112 ||
            constraints.maxWidth < 160 ||
            textScale > 1.12;
        final pad = compact ? 8.0 : 12.0;
        final iconPad = compact ? 6.0 : 8.0;
        final iconSize = compact ? 14.0 : 18.0;
        final valueSize = compact
            ? (isMobile ? 14.0 : 17.0)
            : (isMobile ? 17.0 : 21.0);
        final labelSize = compact ? 7.0 : (isMobile ? 8.0 : 9.0);
        final gap1 = compact ? 4.0 : 8.0;
        final gap2 = compact ? 1.0 : 2.0;

        final body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(iconPad),
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: iconSize, color: colors.onPrimary),
                ),
                if (trend != null)
                  _buildTrendBadge(context, trend!, compact: compact),
              ],
            ),
            SizedBox(height: gap1),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.w900,
                color: colors.onPrimary,
                letterSpacing: compact ? -0.2 : -0.5,
              ),
            ),
            SizedBox(height: gap2),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: labelSize,
                letterSpacing: compact ? 0.6 : 1.0,
                color: colors.onPrimary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        );

        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: compact ? 72 : 100,
                  height: compact ? 72 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.onPrimary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(pad),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendBadge(
    BuildContext context,
    Map<String, dynamic> trend, {
    bool compact = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    final direction = trend['direction'] as String?;
    final value = trend['value'];
    final displayValue = (value as num?)?.toDouble() ?? 0.0;
    final isUp = direction == 'up';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: colors.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: compact ? 8 : 10,
            color: colors.onPrimary,
          ),
          SizedBox(width: compact ? 2 : 4),
          Text(
            '${displayValue.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: compact ? 7.5 : 9,
              fontWeight: FontWeight.w900,
              color: colors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryAnalyticsCard extends StatelessWidget {
  final List<Product> products;
  final bool loading;
  final bool isBhattiSupervisorView;

  const InventoryAnalyticsCard({
    super.key,
    required this.products,
    this.loading = false,
    this.isBhattiSupervisorView = false,
  });

  Map<String, dynamic> get _metrics {
    if (loading || products.isEmpty) {
      return {
        'totalValue': 0.0,
        'totalVariants': 0,
        'lowStockItems': 0,
        'outOfStockItems': 0,
        'stockAvailability': 0,
        'reorderAlerts': 0,
      };
    }

    double totalValue = 0;
    int totalVariants = products.length;
    int lowStockItems = 0;
    int outOfStockItems = 0;
    int reorderAlerts = 0;

    for (final product in products) {
      totalValue += product.price * product.stock;

      if (product.stock == 0) {
        outOfStockItems++;
      } else if (product.stock <= (product.minimumSafetyStock ?? 0)) {
        lowStockItems++;
      }

      if (product.reorderLevel != null &&
          product.stock <= product.reorderLevel! * 1.2 &&
          product.stock > product.reorderLevel!) {
        reorderAlerts++;
      }
    }

    int stockAvailability = totalVariants > 0
        ? ((totalVariants - outOfStockItems - lowStockItems) /
                  totalVariants *
                  100)
              .round()
        : 0;

    return {
      'totalValue': totalValue,
      'totalVariants': totalVariants,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'stockAvailability': stockAvailability,
      'reorderAlerts': reorderAlerts,
    };
  }

  String _formatPrice(double value) {
    return '\u20B9${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(
      1.0,
      1.35,
    );

    if (loading) {
      final colors = Theme.of(context).colorScheme;
      final loadingCount = isBhattiSupervisorView ? 4 : 6;
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1400 ? 6 : (width >= 900 ? 3 : 2);
          final baseHeight = width >= 1400
              ? 122.0
              : (width >= 900 ? 132.0 : 142.0);
          final cardHeight = (baseHeight * textScale).clamp(
            baseHeight,
            baseHeight + 36,
          );
          return GridView.builder(
            itemCount: loadingCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: cardHeight,
            ),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      );
    }

    final colors = Theme.of(context).colorScheme;
    final metricCards = [
      {
        'label': 'Total Stock Value',
        'value': _formatPrice((metrics['totalValue'] as num).toDouble()),
        'icon': Icons.attach_money,
        'gradient': LinearGradient(
          colors: [colors.primary, colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'trend': {'value': 12.0, 'direction': 'up'},
      },
      {
        'label': 'Product Variants',
        'value': metrics['totalVariants'].toString(),
        'icon': Icons.inventory,
        'gradient': LinearGradient(
          colors: [colors.secondary, colors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'label': 'Low Stock Items',
        'value': metrics['lowStockItems'].toString(),
        'icon': Icons.warning,
        'gradient': LinearGradient(
          colors: [
            AppColors.warning,
            AppColors.error.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'trend': metrics['lowStockItems'] > 0
            ? {'value': 5.0, 'direction': 'up'}
            : null,
      },
      {
        'label': 'Out of Stock',
        'value': metrics['outOfStockItems'].toString(),
        'icon': Icons.inventory_2,
        'gradient': LinearGradient(
          colors: [
            AppColors.error,
            AppColors.error.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'label': 'Stock Availability',
        'value': '${metrics['stockAvailability']}%',
        'icon': Icons.trending_up,
        'gradient': LinearGradient(
          colors: [
            AppColors.success,
            AppColors.success.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'trend': {'value': 2.5, 'direction': 'up'},
      },
      {
        'label': 'Reorder Alerts',
        'value': metrics['reorderAlerts'].toString(),
        'icon': Icons.notifications,
        'gradient': LinearGradient(
          colors: [
            AppColors.warning,
            AppColors.warning.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'trend': metrics['reorderAlerts'] > 0
            ? {
                'value': (metrics['reorderAlerts'] as int).toDouble(),
                'direction': 'up',
              }
            : null,
      },
    ];

    final filteredCards = isBhattiSupervisorView
        ? metricCards
              .where(
                (card) =>
                    card['label'] != 'Total Stock Value' &&
                    card['label'] != 'Stock Availability',
              )
              .toList()
        : metricCards;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1400 ? 6 : (width >= 900 ? 3 : 2);
        final baseHeight = width >= 1400
            ? 122.0
            : (width >= 900 ? 132.0 : 142.0);
        final cardHeight = (baseHeight * textScale).clamp(
          baseHeight,
          baseHeight + 36,
        );

        return GridView.builder(
          itemCount: filteredCards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            final card = filteredCards[index];
            return MetricCard(
              label: card['label'] as String,
              value: card['value'] as String,
              icon: card['icon'] as IconData,
              gradient: card['gradient'] as LinearGradient,
              trend: card['trend'] as Map<String, dynamic>?,
            );
          },
        );
      },
    );
  }
}



