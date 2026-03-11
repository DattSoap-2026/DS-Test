import 'package:flutter/material.dart';
import '../../models/types/task_types.dart';
import 'kanban_card.dart';

class KanbanColumn extends StatelessWidget {
  final TaskStatus id;
  final String title;
  final List<Task> tasks;
  final Color color;
  final VoidCallback onTaskUpdated;

  const KanbanColumn({
    super.key,
    required this.id,
    required this.title,
    required this.tasks,
    required this.color,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tasks List
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getEmptyMessage(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: KanbanCard(
                          task: tasks[index],
                          onTaskUpdated: onTaskUpdated,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (title) {
      case 'Open':
        return 'No pending tasks found';
      case 'In Progress':
        return 'No tasks currently in progress';
      case 'Completed':
        return 'No tasks have been completed yet';
      default:
        return 'No tasks';
    }
  }
}
