import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alert_provider.dart';
import '../../providers/service_providers.dart';
import '../../services/alert_service.dart';
import '../../models/types/alert_types.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsFutureProvider);
    final alertService = ref.read(alertServiceProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _confirmClear(context, alertService),
            tooltip: 'Clear Read',
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading alerts: $err')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Center(child: Text('All clear! No alerts today.')),
              ],
            );
          }

          return ListView.builder(
            itemCount: alerts.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertTile(
                alert: alert,
                onTap: () async {
                  final currentUser = ref
                      .read(authProviderProvider)
                      .currentUser;
                  await alertService.markAsRead(alert.id, user: currentUser);
                  ref.invalidate(alertsFutureProvider);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, AlertService service) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Clear All Alerts?'),
        content: const Text(
          'This will permanently delete ALL system alerts including unread.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              await service.clearAllAlerts();
              if (context.mounted) Navigator.pop(context);
              ref.invalidate(alertsFutureProvider);
            },
            child: const Text(
              'CLEAR ALL',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final SystemAlert alert;
  final VoidCallback onTap;

  const _AlertTile({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = _getSeverityColor(alert.severity);
    final cardColor = alert.isRead
        ? colors.surfaceContainerLow
        : colors.surfaceContainerHighest;

    return Card(
      elevation: alert.isRead ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getTypeIcon(alert.type), color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          alert.title,
                          style: TextStyle(
                            fontWeight: alert.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          timeago.format(alert.createdAt),
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.error;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.criticalStock:
        return Icons.inventory_2;
      case AlertType.vehicleExpiry:
        return Icons.local_shipping;
      case AlertType.attendanceLate:
        return Icons.access_time;
      case AlertType.attendanceMissed:
        return Icons.person_off;
      case AlertType.dispatchReceived:
        return Icons.assignment_turned_in;
      case AlertType.paymentPending:
        return Icons.payment;
      case AlertType.systemUpdate:
        return Icons.update;
      case AlertType.other:
        return Icons.info;
    }
  }
}
