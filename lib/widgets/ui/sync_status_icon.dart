import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sync_manager.dart';

class SyncStatusIcon extends StatelessWidget {
  const SyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // We can't use context.watch<AppSyncCoordinator>() easily if the sync
    // coordinator lacks ChangeNotifier.
    // However, the coordinator is not guaranteed to be a ChangeNotifier yet.
    // We should make the sync coordinator a ChangeNotifier or use a Stream.
    // For now, let's assume we might need to convert it to ChangeNotifier
    // OR create a simple StreamBuilder if we exposed a stream.

    // Simplest: Poll or Make it ChangeNotifier
    // Reactive listener
    final isSyncing =
        context.select<AppSyncCoordinator, bool>((s) => s.isSyncing);

    if (isSyncing) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    // Optional: Show a "Cloud" icon when synced
    return IconButton(
      icon: Icon(
        Icons.cloud_done_outlined,
        size: 24,
        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
      ),
      onPressed: null,
      tooltip: 'Synced',
    );
  }
}

// BETTER APPROACH: Make the sync coordinator a ChangeNotifier
