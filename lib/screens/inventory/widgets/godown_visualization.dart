import 'package:flutter/material.dart';

class GodownVisualization extends StatelessWidget {
  final double usagePercent; // 0 to 100
  final Color bagColor;

  const GodownVisualization({
    super.key,
    required this.usagePercent,
    required this.bagColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const int rows = 4;
    const int cols = 4;
    final int totalBlocks = rows * cols;
    final int occupiedBlocks = (totalBlocks * (usagePercent / 100)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.4,
              ),
              itemCount: totalBlocks,
              itemBuilder: (context, index) {
                final isOccupied = index < occupiedBlocks;
                return Container(
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? bagColor
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isOccupied
                        ? [
                            BoxShadow(
                              color: bagColor.withValues(alpha: 0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'RACK CAPACITY VISUALIZATION',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
