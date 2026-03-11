import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/tasks/kanban_board.dart';
import '../../widgets/tasks/new_task_dialog.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showNewTaskDialog = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().state.user;

    return Scaffold(
      body: Column(
        children: [
          // Header with Back Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isMobile = constraints.maxWidth < 600;
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'Back',
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Task Board',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Manage and track your tasks',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    context.push('/dashboard/tasks/history'),
                                icon: const Icon(Icons.history, size: 18),
                                label: const Text('History'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    setState(() => _showNewTaskDialog = true),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('New Task'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Board',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Manage and track your tasks with drag-and-drop',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/dashboard/tasks/history');
                        },
                        icon: Icon(
                          Icons.history,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        label: const Text('Task History'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showNewTaskDialog = true;
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Task'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          // Kanban Board
          Expanded(
            child: KanbanBoard(
              userId: user?.id,
              isAdmin: user?.isAdmin ?? false,
            ),
          ),
        ],
      ),
      // New Task Dialog
      floatingActionButton: _showNewTaskDialog
          ? NewTaskDialog(
              onClose: () {
                setState(() {
                  _showNewTaskDialog = false;
                });
              },
            )
          : null,
    );
  }
}
