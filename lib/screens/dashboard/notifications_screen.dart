import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/types/alert_types.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/custom_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/service_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsFutureProvider);
    final currentUser = ref.watch(authProviderProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(alertServiceProvider).clearReadAlerts();
              ref.invalidate(alertsFutureProvider);
            },
            child: const Text('Clear Read'),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366f1)),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(context, alert, currentUser);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here\nwhen there are updates',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    SystemAlert alert,
    AppUser? currentUser,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isCritical = alert.severity == AlertSeverity.critical;
    final bool isWarning = alert.severity == AlertSeverity.warning;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          if (!alert.isRead) {
            await ref
                .read(alertServiceProvider)
                .markAsRead(alert.id, user: currentUser);
            ref.invalidate(alertsFutureProvider);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: alert.isRead
                ? Colors.transparent
                : theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 48,
                decoration: BoxDecoration(
                  color: isCritical
                      ? theme.colorScheme.error
                      : isWarning
                      ? AppColors.warning
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              _buildIcon(alert.type, isCritical, isWarning, theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: alert.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: alert.isRead
                                  ? theme.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    )
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(alert.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: alert.isRead
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(alert.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
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

  Widget _buildIcon(
    AlertType type,
    bool isCritical,
    bool isWarning,
    ThemeData theme,
  ) {
    IconData iconData;
    Color color;

    switch (type) {
      case AlertType.criticalStock:
        iconData = Icons.inventory_2_outlined;
        break;
      case AlertType.vehicleExpiry:
        iconData = Icons.local_shipping_outlined;
        break;
      case AlertType.attendanceLate:
      case AlertType.attendanceMissed:
        iconData = Icons.person_off_outlined;
        break;
      case AlertType.dispatchReceived:
        iconData = Icons.assignment_turned_in_outlined;
        break;
      case AlertType.paymentPending:
        iconData = Icons.payments_outlined;
        break;
      default:
        iconData = Icons.notifications_none_rounded;
    }

    if (isCritical) {
      color = theme.colorScheme.error;
    } else if (isWarning) {
      color = AppColors.warning;
    } else {
      color = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
