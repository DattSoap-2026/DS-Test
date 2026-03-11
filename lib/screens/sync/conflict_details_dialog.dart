import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/local/entities/conflict_entity.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/utils/responsive.dart';

class ConflictDetailsDialog extends StatelessWidget {
  final ConflictEntity conflict;

  const ConflictDetailsDialog({super.key, required this.conflict});

  @override
  Widget build(BuildContext context) {
    final localData = jsonDecode(conflict.localData);
    final serverData = jsonDecode(conflict.serverData);
    final colorScheme = Theme.of(context).colorScheme;

    // Find keys with different values
    final allKeys = <String>{...localData.keys, ...serverData.keys}.toList();
    final conflictingKeys = allKeys
        .where((key) => localData[key].toString() != serverData[key].toString())
        .toList();

    return ResponsiveAlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.compare_arrows,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Conflict Details'),
        ],
      ),
      content: SizedBox(
        width: Responsive.width(context) * 0.9,
        height: Responsive.height(context) * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entity: ${conflict.entityType.toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'ID: ${conflict.entityId}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: conflictingKeys.map((key) {
                    return _buildComparisonRow(
                      context,
                      key,
                      localData[key],
                      serverData[key],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    String key,
    dynamic local,
    dynamic server,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.05),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LOCAL',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        local?.toString() ?? 'null',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.05),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SERVER',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        server?.toString() ?? 'null',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



