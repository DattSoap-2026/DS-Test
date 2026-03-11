import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/backup_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  late BackupService _backupService;

  // Backup State
  bool _isBackingUp = false;
  double _backupProgress = 0;
  String _backupStatus = '';
  // Default to Local for safety/speed, user can check Firebase
  final List<BackupSource> _backupSources = [BackupSource.local];

  // Restore State
  bool _isRestoring = false;
  double _restoreProgress = 0;
  String _restoreStatus = '';
  final List<BackupSource> _restoreTargets = [BackupSource.local];

  @override
  void initState() {
    super.initState();
    _backupService = context.read<BackupService>();
  }

  void _toggleBackupSource(BackupSource source) {
    setState(() {
      if (_backupSources.contains(source)) {
        _backupSources.remove(source);
      } else {
        _backupSources.add(source);
      }
    });
  }

  void _toggleRestoreTarget(BackupSource target) {
    setState(() {
      if (_restoreTargets.contains(target)) {
        _restoreTargets.remove(target);
      } else {
        _restoreTargets.add(target);
      }
    });
  }

  Future<void> _handleBackup() async {
    if (_backupSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one backup source.'),
        ),
      );
      return;
    }

    setState(() {
      _isBackingUp = true;
      _backupProgress = 0;
      _backupStatus = 'Initializing...';
    });

    try {
      // 1. Create Backup
      final backupData = await _backupService.createFullBackup(
        sources: _backupSources,
        onProgress: (current, total, message) {
          if (mounted) {
            setState(() {
              _backupProgress = current / total;
              _backupStatus = '$message ($current/$total)';
            });
          }
        },
      );

      // 2. Save File
      if (mounted) setState(() => _backupStatus = 'Saving file...');
      final path = await _backupService.saveBackupToFile(backupData);

      if (mounted) {
        setState(() {
          _isBackingUp = false;
          _backupStatus = '';
          _backupProgress = 0;
        });

        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup saved successfully to: $path'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // User cancelled saving
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup save cancelled')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
          _backupStatus = 'Failed: $e';
          _backupProgress = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    if (_restoreTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one restore target.'),
        ),
      );
      return;
    }

    try {
      // 1. Pick File
      final backupData = await _backupService.pickBackupFile();
      if (backupData == null) return; // User cancelled

      // 2. Confirm
      if (!mounted) return;

      final parsed = DateTime.tryParse(backupData.timestamp);
      final dateStr = parsed != null
          ? DateFormat('PPpp').format(parsed)
          : backupData.timestamp;

      String targetStr = _restoreTargets
          .map((e) => e == BackupSource.local ? 'Local Storage' : 'Firebase')
          .join(' & ');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => ResponsiveAlertDialog(
          title: const Text('Confirm Restore'),
          content: Text(
            'Are you sure you want to restore data from $dateStr?\n\nTarget(s): $targetStr\n\nThis will MERGE/OVERWRITE existing data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // 3. Perform Restore
      setState(() {
        _isRestoring = true;
        _restoreProgress = 0;
        _restoreStatus = 'Starting restore...';
      });

      await _backupService.restoreBackup(
        backupData,
        targets: _restoreTargets,
        onProgress: (current, total, message) {
          if (mounted) {
            setState(() {
              _restoreProgress = current / total;
              _restoreStatus = '$message ($current/$total)';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isRestoring = false;
          _restoreStatus = 'Restore Complete!';
          _restoreProgress = 1.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('System restored successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Reset status after delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _restoreStatus = '');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _restoreStatus = 'Failed.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backup & Restore',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your system data. Create manual backups or restore from a previous point.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ),
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACKUP CARD
                  Expanded(
                    child: CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.download,
                                    color: AppColors.info,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Manual Backup',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select data sources to backup:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            CheckboxListTile(
                              title: const Text('Local Storage'),
                              value: _backupSources.contains(
                                BackupSource.local,
                              ),
                              onChanged: (v) =>
                                  _toggleBackupSource(BackupSource.local),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                            CheckboxListTile(
                              title: const Text('Firebase (Cloud)'),
                              value: _backupSources.contains(
                                BackupSource.firebase,
                              ),
                              onChanged: (v) =>
                                  _toggleBackupSource(BackupSource.firebase),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.infoBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.info.withValues(alpha: 0.16)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Creates a JSON snapshot. ${_backupSources.isEmpty ? "Select a source." : ""}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            CustomButton(
                              label: _isBackingUp
                                  ? 'Creating Backup...'
                                  : 'Download Full Backup',
                              onPressed:
                                  (_isRestoring || _backupSources.isEmpty)
                                  ? null
                                  : _handleBackup,
                              isLoading: _isBackingUp,
                              width: double.infinity,
                              color: AppColors.info,
                            ),

                            if (_isBackingUp || _backupStatus.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: _backupProgress > 0
                                    ? _backupProgress
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _backupStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // RESTORE CARD
                  Expanded(
                    child: CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.upload,
                                    color: AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Restore Data',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select target storage to restore to:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            CheckboxListTile(
                              title: const Text('Local Storage'),
                              value: _restoreTargets.contains(
                                BackupSource.local,
                              ),
                              onChanged: (v) =>
                                  _toggleRestoreTarget(BackupSource.local),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                            CheckboxListTile(
                              title: const Text('Firebase (Cloud)'),
                              value: _restoreTargets.contains(
                                BackupSource.firebase,
                              ),
                              onChanged: (v) =>
                                  _toggleRestoreTarget(BackupSource.firebase),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.16)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 20,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.error,
                                        ),
                                        children: const [
                                          TextSpan(text: 'Restoring will '),
                                          TextSpan(
                                            text: 'merge/overwrite',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' data in selected targets!',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            CustomButton(
                              label: _isRestoring
                                  ? 'Restoring...'
                                  : 'Select Backup File',
                              onPressed:
                                  (_isBackingUp || _restoreTargets.isEmpty)
                                  ? null
                                  : _handleRestore,
                              isLoading: _isRestoring,
                              width: double.infinity,
                              color: AppColors.warning,
                              variant: ButtonVariant.outlined,
                            ),

                            if (_isRestoring || _restoreStatus.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: _restoreProgress > 0
                                    ? _restoreProgress
                                    : null,
                                color: AppColors.warning,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _restoreStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Automatic Monthly Backups',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'To set up automated backups, configure Google Cloud Scheduled Exports in the Cloud Console.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


