import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/audit_logs_service.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'settings_audit_logs_screen.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AuditLogsScreen extends StatefulWidget {
  final bool showHeader;

  const AuditLogsScreen({super.key, this.showHeader = true});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  late AuditLogsService _auditService;

  bool _isLoading = true;
  List<AuditLog> _logs = [];

  // Cleanup State
  bool _isCleanupLoading = false;
  int _logsToDeleteCount = 0;
  int _selectedRetentionDays = 90;

  @override
  void initState() {
    super.initState();
    _auditService = context.read<AuditLogsService>();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _auditService.getAuditLogs(limitCount: 100);
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading logs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _checkOldLogsCount() async {
    setState(() => _isCleanupLoading = true);
    try {
      final count = await _auditService.getOldAuditLogsCount(
        _selectedRetentionDays,
      );
      if (mounted) {
        setState(() {
          _logsToDeleteCount = count;
          _isCleanupLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCleanupLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error counting logs: $e")));
      }
    }
  }

  Future<void> _performCleanup() async {
    setState(() => _isCleanupLoading = true);
    try {
      final deleted = await _auditService.deleteOldAuditLogs(
        _selectedRetentionDays,
      );
      if (mounted) {
        setState(() {
          _isCleanupLoading = false;
          _logsToDeleteCount = 0;
        });
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Deleted $deleted old logs.")));
        _loadLogs(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCleanupLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error cleaning logs: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCleanupDialog() {
    final colors = Theme.of(context).colorScheme;
    // Reset state
    _selectedRetentionDays = 90;
    _logsToDeleteCount = 0;
    _checkOldLogsCount(); // Initial check

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ResponsiveAlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: AppColors.warning),
                SizedBox(width: 8),
                Text("Cleanup Old Logs"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delete audit logs older than a specified number of days. This action cannot be undone.",
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedRetentionDays,
                  decoration: const InputDecoration(
                    labelText: "Retention Period",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 30, child: Text("30 days")),
                    DropdownMenuItem(value: 60, child: Text("60 days")),
                    DropdownMenuItem(
                      value: 90,
                      child: Text("90 days (Recommended)"),
                    ),
                    DropdownMenuItem(value: 180, child: Text("180 days")),
                    DropdownMenuItem(value: 365, child: Text("1 year")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => _selectedRetentionDays = val);
                      (() async {
                        setDialogState(() => _isCleanupLoading = true);
                        try {
                          final count = await _auditService
                              .getOldAuditLogsCount(val);
                          if (context.mounted) {
                            setDialogState(() {
                              _logsToDeleteCount = count;
                              _isCleanupLoading = false;
                            });
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setDialogState(() => _isCleanupLoading = false);
                          }
                        }
                      })();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isCleanupLoading
                      ? const Row(
                          children: [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(width: 8),
                            Text("Calculating..."),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Logs to delete:",
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                            Text(
                              "$_logsToDeleteCount",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton.icon(
                onPressed: (_isCleanupLoading || _logsToDeleteCount == 0)
                    ? null
                    : () => _performCleanup(),
                icon: const Icon(Icons.delete_forever),
                label: const Text("Delete Logs"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getActionColor(String action, Color fallback) {
    switch (action) {
      case 'create':
        return AppColors.success;
      case 'update':
        return AppColors.info;
      case 'delete':
        return AppColors.error;
      default:
        return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final authState = context.watch<AuthProvider>().state;
    final isAdmin =
        authState.user?.role == UserRole.admin ||
        authState.user?.role == UserRole.owner;
    final actionButtons = <Widget>[
      if (isAdmin)
        IconButton(
          icon: const Icon(Icons.manage_search_rounded),
          tooltip: 'Settings Audit Logs',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsAuditLogsScreen(),
              ),
            );
          },
          iconSize: 22,
        ),
      if (isAdmin)
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined),
          tooltip: 'Cleanup Old Logs',
          onPressed: _showCleanupDialog,
          iconSize: 22,
        ),
      IconButton(
        icon: const Icon(Icons.refresh_rounded),
        onPressed: _loadLogs,
        iconSize: 22,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          if (widget.showHeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(
                  bottom: BorderSide(
                    color: colors.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Activity History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...actionButtons,
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actionButtons,
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                ? Center(
                    child: GlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No activity logs found",
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return AnimatedCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getActionColor(
                              log.action,
                              colors.onSurfaceVariant,
                            ).withValues(alpha: 0.1),
                            child: Icon(
                              log.action == 'delete'
                                  ? Icons.delete
                                  : log.action == 'create'
                                  ? Icons.add
                                  : Icons.edit,
                              color: _getActionColor(
                                log.action,
                                colors.onSurfaceVariant,
                              ),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            log.collectionName.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "${log.userName} • ${_formatDateSafe(log.timestamp, pattern: 'MMM dd, HH:mm')}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Changes:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (log.changes.isEmpty)
                                    const Text("No detailed changes recorded.")
                                  else
                                    ...log.changes.entries.map((e) {
                                      final val = e.value;
                                      String display;
                                      if (val is Map) {
                                        final oldV = val['oldValue'];
                                        final newV = val['newValue'];
                                        if (oldV != null && newV != null) {
                                          display = "$oldV -> $newV";
                                        } else {
                                          display = val.toString();
                                        }
                                      } else {
                                        display = val.toString();
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${e.key}: ",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                display,
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }
}
