import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_colors.dart';
import '../../models/types/task_types.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/tasks_service.dart';
import '../ui/unified_card.dart';
import 'edit_task_dialog.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class KanbanCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTaskUpdated;

  const KanbanCard({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<KanbanCard> createState() => _KanbanCardState();
}

class _KanbanCardState extends State<KanbanCard> {
  bool _updating = false;
  bool _deleting = false;
  bool _showEditDialog = false;
  bool _showDeleteDialog = false;

  bool _canEdit(AppUser? user) {
    if (user == null) {
      return false;
    }
    return user.role == UserRole.admin || widget.task.createdBy.id == user.id;
  }

  bool _canDelete(AppUser? user) {
    if (user == null) {
      return false;
    }
    return user.role == UserRole.admin || widget.task.createdBy.id == user.id;
  }

  bool _canChangeStatus(AppUser? user) {
    if (user == null) {
      return false;
    }
    return user.role == UserRole.admin ||
        widget.task.createdBy.id == user.id ||
        widget.task.assignedTo.id == user.id;
  }

  TaskStatus? _getNextStatus() {
    if (widget.task.status == TaskStatus.assigned) {
      return TaskStatus.viewed;
    }
    if (widget.task.status == TaskStatus.viewed) {
      return TaskStatus.inProgress;
    }
    if (widget.task.status == TaskStatus.inProgress) {
      return TaskStatus.completed;
    }
    return null;
  }

  Color _getPriorityColor(ThemeData theme) {
    switch (widget.task.priority) {
      case TaskPriority.low:
        return AppColors.info;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.high:
        return theme.colorScheme.error;
    }
  }

  String _getInitials(String name) {
    return name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .toUpperCase()
        .substring(0, name.split(' ').length > 1 ? 2 : 1);
  }

  Future<void> _handleQuickStatusChange() async {
    final nextStatus = _getNextStatus();
    if (nextStatus == null || _updating) return;

    final user = context.read<AuthProvider>().state.user;
    if (!_canChangeStatus(user)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to update this task'),
          ),
        );
      }
      return;
    }

    setState(() => _updating = true);

    try {
      final tasksService = context.read<TasksService>();
      await tasksService.updateTask(id: widget.task.id, status: nextStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextStatus == TaskStatus.inProgress
                  ? 'Task is now in progress'
                  : 'Task marked as completed',
            ),
          ),
        );
        widget.onTaskUpdated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _deleting = true);

    try {
      final tasksService = context.read<TasksService>();
      await tasksService.deleteTask(widget.task.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
        widget.onTaskUpdated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
          _showDeleteDialog = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().state.user;
    final nextStatus = _getNextStatus();
    final canChangeStatus = _canChangeStatus(user);

    final card = UnifiedCard(
      padding: const EdgeInsets.all(16),
      showShadow: true,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.drag_handle,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            if (widget.task.description.isNotEmpty) ...[
              Text(
                widget.task.description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],

            // Priority and Due Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(theme).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getPriorityColor(theme).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.task.priority.value,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getPriorityColor(theme),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Due Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Quick Status Change Button
            if (nextStatus != null && canChangeStatus) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: _updating ? null : _handleQuickStatusChange,
                  icon: _updating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          widget.task.status == TaskStatus.assigned ||
                                  widget.task.status == TaskStatus.viewed
                              ? Icons.play_arrow
                              : Icons.check_circle,
                          size: 14,
                        ),
                  label: Text(
                    _updating
                        ? 'Updating...'
                        : (widget.task.status == TaskStatus.assigned
                              ? 'VIEW TASK'
                              : widget.task.status == TaskStatus.viewed
                              ? 'START WORKING'
                              : 'MARK COMPLETED'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color:
                          (widget.task.status == TaskStatus.assigned ||
                              widget.task.status == TaskStatus.viewed)
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : AppColors.success.withValues(alpha: 0.5),
                    ),
                    foregroundColor:
                        (widget.task.status == TaskStatus.assigned ||
                            widget.task.status == TaskStatus.viewed)
                        ? theme.colorScheme.primary
                        : AppColors.success,
                  ),
                ),
              ),
            ],

            // Footer: Assignee and Actions
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Assignee
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        _getInitials(widget.task.assignedTo.name),
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.task.assignedTo.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                // Edit/Delete Buttons
                if (_canEdit(user) || _canDelete(user))
                  Row(
                    children: [
                      if (_canEdit(user))
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _showEditDialog = true;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (_canDelete(user))
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            setState(() {
                              _showDeleteDialog = true;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
    );

    // Show dialogs when needed
    if (_showDeleteDialog) {
      Future.microtask(() {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => ResponsiveAlertDialog(
            title: const Text('Delete Task'),
            content: Text(
              'Are you sure you want to delete "${widget.task.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showDeleteDialog = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _deleting
                    ? null
                    : () async {
                        await _handleDelete();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: _deleting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onError,
                        ),
                      )
                    : const Text('Delete'),
              ),
            ],
          ),
        );
      });
    }

    if (_showEditDialog) {
      Future.microtask(() {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => EditTaskDialog(
            task: widget.task,
            onClose: () {
              setState(() {
                _showEditDialog = false;
              });
              Navigator.of(context).pop();
              widget.onTaskUpdated();
            },
          ),
        );
        // Reset flag immediately to avoid multiple popups if build is called again before dialog closes
        // Actually best pattern is to just set it false here, but since we are inside build,
        // we shouldn't trigger setState. Future.microtask handles it.
        // But better logic: call showDialog then setState false AFTER it closes?
        // No, we want to trigger it from the button.
        // The button sets _showEditDialog = true.
        // This block detects it and shows dialog.
        // We must set it back to false so it doesn't show again on next rebuild.
        setState(() {
          _showEditDialog = false;
        });
      });
    }

    return card;
  }

  String _formatDueDate() {
    try {
      final dueDate = DateTime.parse(widget.task.dueDate);
      return timeago.format(dueDate);
    } catch (e) {
      return widget.task.dueDate;
    }
  }
}

