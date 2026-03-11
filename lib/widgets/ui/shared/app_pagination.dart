import 'package:flutter/material.dart';

class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool isLoading;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // If there's only one page (or zero), typically we might hide pagination,
    // or show it disabled. Let's auto-hide if pages <= 1 for cleaner UI.
    if (totalPages <= 1) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous
          _PageButton(
            icon: Icons.chevron_left_rounded,
            onPressed: (currentPage > 1 && !isLoading)
                ? () => onPageChanged(currentPage - 1)
                : null,
            tooltip: 'Previous Page',
          ),

          // Page Indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentPage',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  ' / $totalPages',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Next
          _PageButton(
            icon: Icons.chevron_right_rounded,
            onPressed: (currentPage < totalPages && !isLoading)
                ? () => onPageChanged(currentPage + 1)
                : null,
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _PageButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.transparent
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled
                ? theme.colorScheme.outline.withValues(alpha: 0.2)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDisabled
              ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
              : theme.colorScheme.primary,
        ),
      ),
    );
  }
}
