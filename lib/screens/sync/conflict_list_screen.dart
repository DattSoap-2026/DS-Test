import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/local/entities/conflict_entity.dart';
import '../../services/conflict_service.dart';
import '../../services/sync_manager.dart';
import '../../utils/app_logger.dart';
import '../../core/theme/app_colors.dart';
import 'conflict_details_dialog.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class ConflictListScreen extends StatefulWidget {
  const ConflictListScreen({super.key});

  @override
  State<ConflictListScreen> createState() => _ConflictListScreenState();
}

class _ConflictListScreenState extends State<ConflictListScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final conflictService = Provider.of<ConflictService>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Conflicts'),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          TextButton.icon(
            onPressed: () => _resolveAll(context, ResolutionStrategy.useServer),
            icon: Icon(Icons.download, color: colorScheme.onPrimary),
            label: Text(
              'Accept All Server',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ConflictEntity>>(
        stream: conflictService.watchPendingConflicts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conflicts = snapshot.data ?? [];

          if (conflicts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending conflicts',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return _buildConflictCard(context, conflict);
            },
          );
        },
      ),
    );
  }

  Widget _buildConflictCard(BuildContext context, ConflictEntity conflict) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showConflictDetails(context, conflict),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEntityTypeColor(
                        conflict.entityType,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      conflict.entityType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getEntityTypeColor(conflict.entityType),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(conflict.conflictDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'ID: ${conflict.entityId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Conflicting local changes found while downloading server updates.',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _resolveConflict(
                      context,
                      conflict,
                      ResolutionStrategy.useLocal,
                    ),
                    child: const Text('Keep Local'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _resolveConflict(
                      context,
                      conflict,
                      ResolutionStrategy.useServer,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Use Server'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEntityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'users':
        return AppColors.info;
      case 'dealers':
        return AppColors.warning;
      case 'customers':
        return AppColors.success;
      case 'products':
        return AppColors.info;
      case 'sales':
        return AppColors.error;
      case 'returns':
        return AppColors.lightPrimary;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Future<void> _showConflictDetails(
    BuildContext context,
    ConflictEntity conflict,
  ) async {
    showDialog(
      context: context,
      builder: (context) => ConflictDetailsDialog(conflict: conflict),
    );
  }

  Future<void> _resolveConflict(
    BuildContext context,
    ConflictEntity conflict,
    ResolutionStrategy strategy,
  ) async {
    final conflictService = Provider.of<ConflictService>(
      context,
      listen: false,
    );
    final appSyncCoordinator =
        Provider.of<AppSyncCoordinator>(context, listen: false);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      if (mounted) setState(() => _isLoading = true);

      final success = await conflictService.resolveConflict(
        conflict.id,
        strategy,
        syncCoordinator: appSyncCoordinator,
      );

      if (!mounted) return;

      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Conflict resolved successfully')),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to resolve conflict')),
        );
      }
    } catch (e) {
      AppLogger.error('Error resolving conflict', error: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resolveAll(
    BuildContext context,
    ResolutionStrategy strategy,
  ) async {
    final conflictService = Provider.of<ConflictService>(
      context,
      listen: false,
    );
    final appSyncCoordinator =
        Provider.of<AppSyncCoordinator>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Confirm Resolution'),
        content: Text(
          'Are you sure you want to resolve all conflicts using ${strategy == ResolutionStrategy.useServer ? "Server" : "Local"} data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);
      final conflicts = await conflictService.getPendingConflicts();
      int successCount = 0;

      for (final conflict in conflicts) {
        final success = await conflictService.resolveConflict(
          conflict.id,
          strategy,
          syncCoordinator: appSyncCoordinator,
        );
        if (success) successCount++;
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Resolved $successCount conflicts')),
      );
    } catch (e) {
      AppLogger.error('Error resolving all conflicts', error: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}


