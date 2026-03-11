import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/task_types.dart';
import '../../models/types/user_types.dart';
import '../../services/tasks_service.dart';
import '../../services/users_service.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:flutter_app/utils/responsive.dart';

class NewTaskDialog extends StatefulWidget {
  final VoidCallback onClose;

  const NewTaskDialog({super.key, required this.onClose});

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TasksService _tasksService;
  late final UsersService _usersService;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  String _dueDate = '';
  String? _assignedToId;

  List<AppUser> _users = [];
  bool _loadingUsers = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tasksService = context.read<TasksService>();
    _usersService = context.read<UsersService>();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _usersService.getUsers();
      setState(() {
        _users = users; // Show all users
        _loadingUsers = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingUsers = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().state.user;
    if (user == null || _assignedToId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final assignedUser = _users.cast<AppUser?>().firstWhere(
      (u) => u?.id == _assignedToId,
      orElse: () => null,
    );
    if (assignedUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Assigned user not found')));
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await _tasksService.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        createdBy: TaskUser(id: user.id, name: user.name),
        assignedTo: TaskUser(id: assignedUser.id, name: assignedUser.name),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully')),
        );
        widget.onClose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.clamp(context, min: 300, max: 520, ratio: 0.9),
          maxHeight: Responsive.height(context) * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 430;
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Task',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          border: const OutlineInputBorder(),
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: const OutlineInputBorder(),
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      if (isNarrow) ...[
                        DropdownButtonFormField<TaskPriority>(
                          initialValue: _priority,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            border: const OutlineInputBorder(),
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          items: TaskPriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _priority = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dueDateController,
                          decoration: InputDecoration(
                            labelText: 'Due Date *',
                            border: const OutlineInputBorder(),
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                _dueDate = date.toIso8601String().split('T')[0];
                                _dueDateController.text = _dueDate;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Due date is required';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<TaskPriority>(
                                initialValue: _priority,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Priority',
                                  border: const OutlineInputBorder(),
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                ),
                                items: TaskPriority.values.map((priority) {
                                  return DropdownMenuItem(
                                    value: priority,
                                    child: Text(priority.value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _priority = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _dueDateController,
                                decoration: InputDecoration(
                                  labelText: 'Due Date *',
                                  border: const OutlineInputBorder(),
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dueDate = date.toIso8601String().split(
                                        'T',
                                      )[0];
                                      _dueDateController.text = _dueDate;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Due date is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      _loadingUsers
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              initialValue: _assignedToId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Assign To *',
                                border: const OutlineInputBorder(),
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                              ),
                              items: _users.map((user) {
                                return DropdownMenuItem(
                                  value: user.id,
                                  child: Text(
                                    '${user.name} (${user.role.value})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _assignedToId = value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please assign to a user';
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 20),
                      if (isNarrow) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _handleSubmit,
                            child: _submitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Create Task'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: widget.onClose,
                            child: const Text('Cancel'),
                          ),
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onClose,
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _submitting ? null : _handleSubmit,
                              child: _submitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Create Task'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
