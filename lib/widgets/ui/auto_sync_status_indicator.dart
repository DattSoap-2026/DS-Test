import 'package:flutter/material.dart';

import '../../core/sync/sync_service.dart';

/// Read-only sync indicator driven by the SyncService stream.
class AutoSyncStatusIndicator extends StatelessWidget {
  const AutoSyncStatusIndicator({
    super.key,
    this.iconSize = 18,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatusSnapshot>(
      stream: SyncService.instance.statusStream,
      initialData: SyncService.instance.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncService.instance.currentStatus;
        final pendingCount = status.pendingCount + status.failedCount;

        if (!status.isOnline && pendingCount <= 0) {
          return const SizedBox.shrink();
        }

        if (!status.isOnline) {
          return Tooltip(
            message: 'Offline, $pendingCount pending',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: iconSize,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          );
        }

        if (status.isSyncing || pendingCount > 0) {
          return Tooltip(
            message: status.isSyncing ? 'Syncing' : '$pendingCount pending',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber.shade700,
                  ),
                ),
              ),
            ),
          );
        }

        return Tooltip(
          message: 'All synced',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.cloud_done_rounded,
              size: iconSize,
              color: Colors.green.shade600,
            ),
          ),
        );
      },
    );
  }
}
