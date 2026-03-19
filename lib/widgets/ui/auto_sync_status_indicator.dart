import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/sync_manager.dart';

/// WhatsApp-like auto-sync status indicator
/// Shows sync status without requiring user interaction
class AutoSyncStatusIndicator extends StatelessWidget {
  final Color? iconColor;
  final double iconSize;

  const AutoSyncStatusIndicator({
    super.key,
    this.iconColor,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = iconColor ?? theme.colorScheme.onSurface;

    return Consumer<AppSyncCoordinator>(
      builder: (context, appSyncCoordinator, _) {
        // Syncing state
        if (appSyncCoordinator.isSyncing) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              ),
            ),
          );
        }

        // Pending items
        if (appSyncCoordinator.pendingCount > 0) {
          return Tooltip(
            message: '${appSyncCoordinator.pendingCount} items pending sync',
            child: Badge(
              label: Text('${appSyncCoordinator.pendingCount}'),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: iconSize,
                color: effectiveColor.withValues(alpha: 0.7),
              ),
            ),
          );
        }

        // All synced
        return Tooltip(
          message: 'All data synced',
          child: Icon(
            Icons.cloud_done_outlined,
            size: iconSize,
            color: Colors.green.withValues(alpha: 0.8),
          ),
        );
      },
    );
  }
}
