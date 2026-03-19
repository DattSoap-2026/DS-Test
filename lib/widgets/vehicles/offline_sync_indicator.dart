import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../services/sync_manager.dart';

class OfflineSyncIndicator extends StatelessWidget {
  const OfflineSyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSyncCoordinator>(
      builder: (context, appSyncCoordinator, _) {
        final pendingCount = appSyncCoordinator.pendingCount;
        final isSyncing = appSyncCoordinator.isSyncing;
        // Note: lastSyncTime not available in the current sync coordinator
        // Using placeholder for now
        final DateTime? lastSynced = null;

        if (pendingCount == 0 && !isSyncing) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSyncing
                ? AppColors.info.withValues(alpha: 0.1)
                : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSyncing ? AppColors.info : AppColors.warning,
            ),
          ),
          child: Row(
            children: [
              if (isSyncing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.info),
                  ),
                )
              else
                Icon(Icons.cloud_upload, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSyncing
                      ? 'Syncing changes...'
                      : '$pendingCount change(s) pending sync',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSyncing ? AppColors.info : AppColors.warning,
                  ),
                ),
              ),
              if (lastSynced != null && !isSyncing)
                Text(
                  _formatLastSync(lastSynced),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              if (!isSyncing && pendingCount > 0) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.sync, size: 18),
                  onPressed: () {
                    appSyncCoordinator.syncAll(null);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Sync Now',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatLastSync(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
