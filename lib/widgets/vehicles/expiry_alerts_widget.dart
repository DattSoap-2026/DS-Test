import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class ExpiryAlertsWidget extends StatelessWidget {
  final Map<String, dynamic> alerts;
  final VoidCallback onViewAll;

  const ExpiryAlertsWidget({
    super.key,
    required this.alerts,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final critical = alerts['critical'] as List<Map<String, dynamic>>? ?? [];
    final warning = alerts['warning'] as List<Map<String, dynamic>>? ?? [];
    final totalCount = critical.length + warning.length;

    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: critical.isNotEmpty
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: critical.isNotEmpty ? AppColors.error : AppColors.warning,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                critical.isNotEmpty ? Icons.error : Icons.warning,
                color: critical.isNotEmpty ? AppColors.error : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  critical.isNotEmpty
                      ? '$totalCount Document(s) Expired!'
                      : '$totalCount Document(s) Expiring Soon',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: critical.isNotEmpty ? AppColors.error : AppColors.warning,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
            ],
          ),
          if (critical.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...critical.take(2).map((alert) => _buildAlertItem(alert, true)),
          ] else if (warning.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...warning.take(2).map((alert) => _buildAlertItem(alert, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert, bool isCritical) {
    final expiry = alert['expiry'] as DateTime?;
    final daysLeft = alert['daysLeft'] as int;
    final expiryText = expiry != null
        ? DateFormat('dd MMM yyyy').format(expiry)
        : 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: isCritical ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${alert['vehicle']} - ${alert['type']}: $expiryText (${daysLeft < 0 ? 'Expired' : '$daysLeft days'})',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
