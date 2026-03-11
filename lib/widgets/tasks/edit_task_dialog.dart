import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/task_types.dart';
import '../../models/types/user_types.dart';
import '../../services/tasks_service.dart';
import '../../services/users_service.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final VoidCallback onClose;

  const EditTaskDialog({super.key, required this.task, required this.onClose});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TasksService _tasksService;
  late final UsersService _usersService;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _priority;
  late String _dueDate;
  String? _assignedToId;

  List<AppUser> _users = [];
  bool _loadingUsers = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tasksService = context.read<TasksService>();
    _usersService = context.read<UsersService>();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
    _assignedToId = widget.task.assignedTo.id;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _usersService.getUsers();
      setState(() {
        _users = users;
        _loadingUsers = false;

        // Ensure assigned user is in list (edge case: user deleted?)
        // If assignedToId is not in retrieved list, we might want to flag it or handle it,
        // but fetching all users should cover it unless deleted.
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

    if (_assignedToId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please assign to a user')));
      return;
    }

    final assignedUser = _users.firstWhere(
      (u) => u.id == _assignedToId,
      orElse: () => AppUser(
        id: widget.task.assignedTo.id,
        name: widget.task.assignedTo.name,
        email: '',
        role: UserRole.salesman,
        createdAt: '',
        status: 'active',
        departments: [],
      ),
    );

    setState(() => _submitting = true);

    try {
      await _tasksService.updateTask(
        id: widget.task.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        assignedTo: TaskUser(id: assignedUser.id, name: assignedUser.name),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
        widget.onClose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Task',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Priority and Due Date Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Due Date *'),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(_dueDate),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            _dueDate = date.toIso8601String().split('T')[0];
                          });
                        }
                      },
                      controller: TextEditingController(
                        text: _dueDate,
                      ), // Use controller to update from state
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
              const SizedBox(height: 16),

              // Assign To
              _loadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      initialValue: _assignedToId,
                      decoration: const InputDecoration(labelText: 'Assign To *'),
                      items: _users.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text('${user.name} (${user.role.value})'),
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
              const SizedBox(height: 24),

              // Buttons
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
