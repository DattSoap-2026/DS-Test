import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import '../../services/database_service.dart';

class StuckQueueAlertCard extends StatefulWidget {
  const StuckQueueAlertCard({super.key});

  @override
  State<StuckQueueAlertCard> createState() => _StuckQueueAlertCardState();
}

class _StuckQueueAlertCardState extends State<StuckQueueAlertCard> {
  int _stuckCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final dbService = context.read<DatabaseService>();
      final allAlerts = await dbService.alerts.where().findAll();

      int count = 0;
      for (final alert in allAlerts) {
        if (alert.title == 'Stuck Queue Item' && !alert.isRead) {
          count++;
        }
      }

      if (mounted) {
        setState(() {
          _stuckCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _stuckCount <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF450a0a) : const Color(0xFFfef2f2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF991b1b) : const Color(0xFFfca5a5),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7f1d1d)
                    : const Color(0xFFfee2e2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: isDark
                    ? const Color(0xFFfca5a5)
                    : const Color(0xFFef4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sync Issues Detected',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? const Color(0xFFfca5a5)
                          : const Color(0xFF991b1b),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_stuckCount sales pending due to stock issues',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? const Color(0xFFfecaca)
                          : const Color(0xFFb91c1c),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () => context.push(
                '/dashboard/notifications',
              ), // Or another relevant route
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF991b1b)
                    : const Color(0xFFef4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}
