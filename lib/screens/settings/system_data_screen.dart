import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/backup_service.dart';
import '../../services/data_management_service.dart';
import '../../services/sync_manager.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../data/repositories/user_repository.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class SystemDataScreen extends StatefulWidget {
  final bool showHeader;

  const SystemDataScreen({super.key, this.showHeader = true});

  @override
  State<SystemDataScreen> createState() => _SystemDataScreenState();
}

class _SystemDataScreenState extends State<SystemDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using a Column instead of Scaffold to avoid nested Scaffold issues (double app bars, etc.)
    return Column(
      children: [
        // Custom Header Area
        Container(
          padding: EdgeInsets.fromLTRB(24, widget.showHeader ? 24 : 8, 24, 0),
          color: Theme.of(context).cardTheme.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                Text(
                  'System Data',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ThemedTabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Backups & Restore'),
                  Tab(
                    text: 'Data Buckets',
                  ), // Renamed from Maintenance for brevity
                ],
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_BackupsTab(), _DataMaintenanceTab()],
          ),
        ),
      ],
    );
  }
}

// --- TAB 1: Backups (From BackupScreen) ---

class _BackupsTab extends StatefulWidget {
  const _BackupsTab();

  @override
  State<_BackupsTab> createState() => _BackupsTabState();
}

class _BackupsTabState extends State<_BackupsTab> {
  late BackupService _backupService;

  // Backup State
  bool _isBackingUp = false;
  double _backupProgress = 0;
  String _backupStatus = '';
  final List<BackupSource> _backupSources = [BackupSource.local];

  // Restore State
  bool _isRestoring = false;
  double _restoreProgress = 0;
  String _restoreStatus = '';
  final List<BackupSource> _restoreTargets = [BackupSource.local];

  void _toggleBackupSource(BackupSource source) {
    setState(() {
      if (_backupSources.contains(source)) {
        if (_backupSources.length > 1) {
          _backupSources.remove(source);
        }
      } else {
        _backupSources.add(source);
      }
    });
  }

  void _toggleRestoreTarget(BackupSource target) {
    setState(() {
      if (_restoreTargets.contains(target)) {
        if (_restoreTargets.length > 1) {
          _restoreTargets.remove(target);
        }
      } else {
        _restoreTargets.add(target);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _backupService = context.read<BackupService>();
  }

  Future<void> _handleBackup() async {
    setState(() {
      _isBackingUp = true;
      _backupProgress = 0;
      _backupStatus = 'Initializing...';
    });

    try {
      if (_backupSources.isEmpty) {
        throw Exception("Please select at least one backup source.");
      }

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
              content: Text('Backup saved successfully: $path'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
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
    try {
      final backupData = await _backupService.pickBackupFile();
      if (backupData == null) return;

      if (!mounted) return;

      final parsed = DateTime.tryParse(backupData.timestamp);
      final dateStr = parsed != null
          ? DateFormat('PPpp').format(parsed)
          : backupData.timestamp;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => ResponsiveAlertDialog(
          title: const Text('Confirm Restore'),
          content: Text(
            'Are you sure you want to restore data from $dateStr? This will merge/overwrite existing data. THIS ACTION CANNOT BE UNDONE.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('RESTORE'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _isRestoring = true;
        _restoreProgress = 0;
        _restoreStatus = 'Starting restore...';
      });

      if (_restoreTargets.isEmpty) {
        throw Exception("Please select at least one restore target.");
      }

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
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_download,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Manual Backup",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Create a complete JSON snapshot of your database.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Source Selection:",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text("Local Storage (Isar)"),
                    value: _backupSources.contains(BackupSource.local),
                    onChanged: (v) => _toggleBackupSource(BackupSource.local),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text("Firebase (Cloud Firestore)"),
                    value: _backupSources.contains(BackupSource.firebase),
                    onChanged: (v) =>
                        _toggleBackupSource(BackupSource.firebase),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: _isBackingUp
                        ? 'Backing up...'
                        : 'Download Full Backup',
                    onPressed: _isRestoring ? null : _handleBackup,
                    isLoading: _isBackingUp,
                    width: double.infinity,
                    color: Theme.of(context).primaryColor,
                  ),
                  if (_isBackingUp || _backupStatus.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _backupProgress > 0 ? _backupProgress : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _backupStatus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.settings_backup_restore,
                    size: 48,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Restore Data",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Import a previous JSON backup file. Careful!",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Target Selection:",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text("Local Storage (Isar)"),
                    value: _restoreTargets.contains(BackupSource.local),
                    onChanged: (v) => _toggleRestoreTarget(BackupSource.local),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text("Firebase (Cloud Firestore)"),
                    value: _restoreTargets.contains(BackupSource.firebase),
                    onChanged: (v) =>
                        _toggleRestoreTarget(BackupSource.firebase),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: _isRestoring ? 'Restoring...' : 'Select Backup File',
                    onPressed: _isBackingUp ? null : _handleRestore,
                    isLoading: _isRestoring,
                    width: double.infinity,
                    color: AppColors.warning,
                    variant: ButtonVariant.outlined,
                  ),
                  if (_isRestoring || _restoreStatus.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _restoreProgress > 0 ? _restoreProgress : null,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _restoreStatus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CustomCard(
            child: ListTile(
              leading: Icon(Icons.schedule, color: AppColors.info),
              title: Text("Automated Backups"),
              subtitle: Text(
                "Configure Google Cloud Scheduler for automatic daily exports.",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TAB 2: Data Maintenance (From DataManagementScreen) ---

class _DataMaintenanceTab extends StatefulWidget {
  const _DataMaintenanceTab();

  @override
  State<_DataMaintenanceTab> createState() => _DataMaintenanceTabState();
}

class _DataMaintenanceTabState extends State<_DataMaintenanceTab> {
  late final DataManagementService _dataService;
  Map<String, int> _counts = {};
  List<FileSystemEntity> _mockFiles = [];
  bool _isLoading = true;
  bool _isFullResetting = false;
  String _fullResetStatus = '';

  @override
  void initState() {
    super.initState();
    _dataService = context.read<DataManagementService>();
    _refreshCounts();
    _loadMockFiles();
  }

  Future<void> _loadMockFiles() async {
    final files = await _dataService.getMockDataFiles();
    if (mounted) {
      setState(() {
        _mockFiles = files;
      });
    }
  }

  Future<void> _refreshCounts() async {
    setState(() => _isLoading = true);
    final counts = await _dataService.getDataCount();
    if (mounted) {
      setState(() {
        _counts = counts;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleReset(
    String title,
    Future<bool> Function() resetFn,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Text('Reset $title?'),
        content: Text(
          'Are you sure? This will DELETE ALL $title data. Cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('RESET ALL DATA'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await resetFn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '$title reset successfully' : 'Failed to reset',
            ),
          ),
        );
        _refreshCounts();
      }
    }
  }

  Future<bool> _confirmFullTransactionReset() async {
    const phrase = 'RESET TRANSACTIONS';
    final controller = TextEditingController();
    bool canConfirm = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => ResponsiveAlertDialog(
          title: const Text('Confirm Full Transaction Reset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will permanently delete all transactional data from Firebase and local storage. Master data will remain.',
              ),
              const SizedBox(height: 12),
              const Text('Type the phrase below to continue.'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (value) {
                  final matches = value.trim().toUpperCase() == phrase;
                  if (matches != canConfirm) {
                    setState(() => canConfirm = matches);
                  }
                },
                decoration: const InputDecoration(hintText: phrase),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: canConfirm ? () => Navigator.pop(ctx, true) : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('RESET NOW'),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    return confirmed == true;
  }

  Future<void> _handleFullTransactionReset() async {
    if (_isFullResetting) return;
    final user = context.read<AuthProvider>().state.user;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
        content: Text('User not available. Please login again.'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (!user.isAdmin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only Admin/Owner can run this reset.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Internet connection required for full reset.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await _confirmFullTransactionReset();
    if (!confirmed) return;

    // Verify backup exists or prompt user
    if (!mounted) return;
    final backupConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        title: const Text('Backup Verification'),
        content: const Text(
          'Have you created a recent backup? This reset is IRREVERSIBLE.\n\nRecommended: Go to Backups & Restore tab and download a backup first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel - Create Backup First'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Continue Without Backup'),
          ),
        ],
      ),
    );

    if (backupConfirmed != true) return;

    if (!mounted) return;
    setState(() {
      _isFullResetting = true;
      _fullResetStatus = 'Starting reset...';
    });
    
    bool success = false;
    String? errorMessage;
    try {
      success = await _dataService.resetTransactionalData(
        userId: user.id,
        userName: user.name,
        isAdmin: user.isAdmin,
        onProgress: (message) {
          if (!mounted) return;
          setState(() => _fullResetStatus = message);
        },
      ).timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          throw Exception('Reset operation timed out after 10 minutes. Please check your internet connection and try again.');
        },
      );
    } catch (e) {
      errorMessage = e.toString();
      success = false;
    }

    if (!mounted) return;
    if (success) {
      setState(() => _fullResetStatus = 'Resyncing master data...');
      try {
        final appSyncCoordinator = context.read<AppSyncCoordinator>();
        await appSyncCoordinator.syncAll(user, forceRefresh: true).timeout(
          const Duration(minutes: 5),
          onTimeout: () => SyncRunResult.skipped('Sync timeout'),
        );
      } catch (e) {
        // Ignore sync errors during cleanup
      }
    }

    if (!mounted) return;
    setState(() {
      _isFullResetting = false;
      _fullResetStatus = '';
    });

    final summary = success
        ? 'Reset completed successfully.\n\n'
              'RESET (All entries cleared):\n'
              '- Sales, Sale Items, Sales History, Sales Payments, Sales Returns\n'
              '- Dispatches, Dispatch Items, Dispatch History\n'
              '- Salesman Allocated Stock, Stock Transactions, Stock History\n'
              '- Purchase Orders, Payments, Returns\n'
              '- Production Logs, Cutting Batches, Bhatti Batches\n'
              '- Semi-Finish Stock Entries, Stock Ledger\n'
              '- Payroll, Advances, Leave Requests, Attendance\n'
              '- Fuel Logs, Vehicle Maintenance, Tyre Logs\n'
              '- Vehicle Issues, Vouchers, Schemes\n'
              '- Route Orders, Route Order Items, Tasks\n'
              '- GPS Locations, Notifications, Alerts\n\n'
              'KEPT (Master data intact):\n'
              '- Users, Staff, Routes, Business Partners\n'
              '- Products (stock reset to Opening Stock)\n'
              '- Vehicles, Tank Names, Godown Names\n'
              '- Tank/Godown stock reset to 0 (names kept)\n'
              '- Employee Documents (PRESERVED)\n'
              '- Master Data (Units, Categories, Company Profile)'
        : 'Reset failed. ${errorMessage ?? "Unknown error occurred."}';

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResponsiveAlertDialog(
        title: Text(success ? 'Reset Complete' : 'Reset Failed'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary),
              if (!success) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Troubleshooting Tips:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your internet connection\n'
                        '• Verify Firebase is properly configured\n'
                        '• Ensure you have Admin/Owner permissions\n'
                        '• Try again after a few minutes\n'
                        '• Contact support if issue persists',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (success) {
      _refreshCounts();
    }
  }

  Future<void> _handleExport(String key, String title) async {
    // Show format selection dialog
    final format = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('Export as Excel (.xlsx)'),
              onTap: () => Navigator.pop(context, 'xlsx'),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.info),
              title: const Text('Export as CSV (.csv)'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
          ],
        ),
      ),
    );

    if (format == null) return;

    try {
      if (format == 'xlsx') {
        final bytes = await _dataService.exportCollectionToExcel(key);
        if (bytes == null || bytes.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('No data found.')));
          }
          return;
        }

        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save $title Export',
          fileName: '${key}_export.xlsx',
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (result != null) {
          await File(result).writeAsBytes(bytes);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Saved to $result')));
          }
        }
      } else {
        // CSV
        final csv = await _dataService.exportCollectionToCsv(key);
        if (csv == null || csv.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('No data found.')));
          }
          return;
        }
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save $title Export',
          fileName: '${key}_export.csv',
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );
        if (result != null) {
          await File(result).writeAsString(csv);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Saved to $result')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _handleManualImport(String key, String title) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      _processImport(File(result.files.single.path!), title);
    }
  }

  Future<void> _processImport(File file, String title) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      if (!mounted) return;
      final user = context.read<AuthProvider>().state.user;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => ResponsiveAlertDialog(
          title: Text('Import into $title?'),
          content: Text(
            'Merge $ext records? Existing IDs will be overwritten.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isLoading = true);

      String? error;
      if (ext == 'xlsx') {
        final bytes = await file.readAsBytes();
        error = await _dataService.importDataFromExcel(
          bytes,
          user?.id ?? 'sys',
          user?.name ?? 'System',
        );
      } else {
        final content = await file.readAsString();
        error = await _dataService.importDataFromJson(
          content,
          user?.id ?? 'sys',
          user?.name ?? 'System',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error == null ? 'Success' : 'Failed: $error')),
        );
        _refreshCounts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Manage your system data buckets. Export to backup or import to migrate data.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.info),
                  onPressed: _refreshCounts,
                  tooltip: 'Refresh Counts',
                  iconSize: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildCompactBucketCard(
            'Sales',
            'sales',
            () => _dataService.resetAllSales(),
            Icons.shopping_cart,
          ),
          _buildCompactBucketCard(
            'Dispatches',
            'dispatches',
            () => _dataService.resetAllDispatches(),
            Icons.local_shipping,
          ),
          _buildCompactBucketCard(
            'Sales, Invoices, Dispatches & Dashboards\n(Keeps Master/GPS)',
            'sales_and_dispatches',
            () => _dataService.resetSalesDispatchesDashboards(),
            Icons.receipt_long,
            isCritical: true,
          ),
          _buildCompactBucketCard(
            'Routes & Logistics',
            'routes',
            () => _dataService.resetAllRoutes(),
            Icons.map,
          ),
          _buildCompactBucketCard(
            'Route Orders & History',
            'route_orders',
            () => _dataService.resetAllRouteOrders(),
            Icons.route,
          ),
          _buildCompactBucketCard(
            'Users (Reset All)',
            'users',
            () async {
              final user = context.read<AuthProvider>().state.user;
              final userRepo = context.read<UserRepository>();
              return await _dataService.resetAllUsers(
                user?.id ?? '',
                localRepo: userRepo,
              );
            },
            Icons.people,
            isCritical: true,
          ),
          _buildCompactBucketCard(
            'Production Logs',
            'production',
            () => _dataService.resetAllProduction(),
            Icons.factory,
          ),
          _buildCompactBucketCard(
            'Product Master',
            'products',
            () => _dataService.resetAllProducts(),
            Icons.inventory_2,
            isCritical: true,
          ),

          const SizedBox(height: 12),
          _buildFullResetCard(),

          const Divider(height: 32),

          // Mock Data Section
          Text(
            "Local Mock Files (Dev)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (_mockFiles.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "No mock files found in local storage.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mockFiles.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final f = _mockFiles[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.insert_drive_file,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(f.path.split(Platform.pathSeparator).last),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.upload, size: 16),
                      label: const Text("Import"),
                      onPressed: () => _processImport(File(f.path), "System"),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullResetCard() {
    final theme = Theme.of(context);
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Full Transaction Reset',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Keeps: Users, Routes, Business Partners (Customers/Dealers), Products, Vehicles, Staff List, Tank Names, Godown Names, Departments, Locations (GPS), Employee Documents (PRESERVED), Master Data (Units, Categories, Company Profile). Tank/Godown stock is reset to 0; names remain.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Resets: Sales (Items, History, Payments, Returns), Dispatches (Items, History), Salesman Stock (Allocated, Transactions, History), Purchases, Payments, Production Logs, Production Batches, Cutting Batches, Bhatti Batches, Stock Ledger, Tanks (entries), Payroll, Advances, Leave Requests, Attendance, Fuel Logs, Vehicle Maintenance, Tyre Logs, Vehicle Issues, Vouchers, Schemes, Tasks, Route Orders (Items), Notifications, Alerts.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: _isFullResetting
                  ? 'Resetting...'
                  : 'Run Full Transaction Reset',
              onPressed: _isFullResetting ? null : _handleFullTransactionReset,
              variant: ButtonVariant.danger,
              isLoading: _isFullResetting,
              width: double.infinity,
            ),
            if (_isFullResetting) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
              if (_fullResetStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _fullResetStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBucketCard(
    String title,
    String key,
    Future<bool> Function() resetFn,
    IconData icon, {
    bool isCritical = false,
  }) {
    final theme = Theme.of(context);
    final count = _counts[key] ?? 0;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ), // Compact padding
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isCritical ? AppColors.error : AppColors.info)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isCritical ? AppColors.error : AppColors.info,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$count records',
                    style: TextStyle(
                      color: count > 0
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  Icons.download,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  'Export',
                  () => _handleExport(key, title),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Icons.upload,
                  AppColors.success,
                  'Import',
                  () => _handleManualImport(key, title),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Icons.delete_outline,
                  isCritical ? AppColors.error : AppColors.warning,
                  'Reset',
                  () => _handleReset(title, resetFn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(4),
            color: color.withValues(alpha: 0.05),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
