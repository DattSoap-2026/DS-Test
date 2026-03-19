import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sync_manager.dart';
import '../../utils/app_toast.dart';

/// Developer utility to manually reset stuck opening stock queue items.
class OpeningStockQueueResetButton extends StatefulWidget {
  const OpeningStockQueueResetButton({super.key});

  @override
  State<OpeningStockQueueResetButton> createState() =>
      _OpeningStockQueueResetButtonState();
}

class _OpeningStockQueueResetButtonState
    extends State<OpeningStockQueueResetButton> {
  bool _isResetting = false;

  Future<void> _resetQueue() async {
    if (_isResetting) return;

    setState(() => _isResetting = true);

    try {
      final appSyncCoordinator = context.read<AppSyncCoordinator>();
      final resetCount = await appSyncCoordinator.resetStuckOpeningStockRetry();

      if (mounted) {
        if (resetCount > 0) {
          AppToast.showSuccess(
            context,
            'Reset $resetCount items. Syncing...',
          );
          appSyncCoordinator.scheduleDebouncedSync(
            forceRefresh: false,
            debounce: const Duration(milliseconds: 500),
          );
        } else {
          AppToast.showInfo(context, 'No stuck items found');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Reset failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isResetting ? null : _resetQueue,
      icon: _isResetting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded),
      label: Text(_isResetting ? 'Resetting...' : 'Reset Queue'),
    );
  }
}
