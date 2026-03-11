import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/sync_manager.dart';

/// Auto-sync status indicator (WhatsApp-like)
/// Shows sync status - no manual sync button needed
/// Sync happens automatically in background
class GlobalSyncButton extends StatelessWidget {
  final Color? iconColor;
  final double iconSize;

  const GlobalSyncButton({super.key, this.iconColor, this.iconSize = 24.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = iconColor ?? theme.colorScheme.onSurface;

    return Consumer<SyncManager>(
      builder: (context, syncManager, _) {
        // Syncing state
        if (syncManager.isSyncing) {
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
        if (syncManager.pendingCount > 0) {
          return Tooltip(
            message: '${syncManager.pendingCount} items syncing',
            child: Badge(
              label: Text('${syncManager.pendingCount}'),
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
