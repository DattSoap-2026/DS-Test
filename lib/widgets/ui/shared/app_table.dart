import 'package:flutter/material.dart';
import 'app_card.dart';

class AppTableColumn {
  final String label;
  final int flex;
  final double? width;
  final bool numeric;

  const AppTableColumn({
    required this.label,
    this.flex = 1,
    this.width,
    this.numeric = false,
  });
}

class AppTable extends StatelessWidget {
  final List<AppTableColumn> columns;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isLoading;
  final bool isEmpty;
  final Widget? emptyState;
  final Function(bool?)? onSelectAll;
  final bool? allSelected;
  final bool showCheckbox;

  const AppTable({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
    this.isLoading = false,
    this.isEmpty = false,
    this.emptyState,
    this.onSelectAll,
    this.allSelected,
    this.showCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isEmpty) {
      return emptyState ??
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                children: [
                  Icon(
                    Icons.table_rows_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (showCheckbox) ...[
                          SizedBox(
                            width: 32,
                            child: Checkbox(
                              value: allSelected,
                              onChanged: onSelectAll,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        ...columns.map((col) {
                          final text = Text(
                            col.label.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: col.numeric
                                ? TextAlign.right
                                : TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );

                          if (col.width != null) {
                            return SizedBox(width: col.width, child: text);
                          }
                          return Expanded(flex: col.flex, child: text);
                        }),
                      ],
                    ),
                  ),
                  // Body
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemCount,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.05),
                    ),
                    itemBuilder: itemBuilder,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
