import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/types/task_types.dart';
import '../../services/tasks_service.dart';
import '../ui/themed_tab_bar.dart';

import 'kanban_column.dart';

class KanbanBoard extends StatefulWidget {
  final String? userId;
  final bool isAdmin;
  const KanbanBoard({super.key, this.userId, this.isAdmin = false});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final TasksService _tasksService;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _loading = true;
  StreamSubscription<List<Task>>? _taskSubscription;

  // Filters
  String _searchTerm = '';
  String _priorityFilter = 'all';
  bool _showOverdueOnly = false;

  @override
  void initState() {
    super.initState();
    _tasksService = context.read<TasksService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    // Subscribe to real-time task updates
    Stream<List<Task>> taskStream;

    if (widget.isAdmin || widget.userId == null) {
      taskStream = _tasksService.getTasksStream();
    } else {
      taskStream = _tasksService.getTasksForUserStream(widget.userId!);
    }

    _taskSubscription?.cancel();
    _taskSubscription = taskStream.listen(
      (tasks) {
        if (mounted) {
          setState(() {
            _tasks = tasks;
            _loading = false;
          });
          _applyFilters();
        }
      },
      onError: (e) {
        debugPrint(' Kanban Error: $e');
        if (mounted) {
          setState(() {
            _loading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
        }
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        // Search filter
        if (_searchTerm.isNotEmpty) {
          final searchLower = _searchTerm.toLowerCase();
          final matchesTitle = task.title.toLowerCase().contains(searchLower);
          final matchesDesc = task.description.toLowerCase().contains(
            searchLower,
          );
          final matchesAssignee = task.assignedTo.name.toLowerCase().contains(
            searchLower,
          );
          if (!matchesTitle && !matchesDesc && !matchesAssignee) return false;
        }

        // Priority filter
        if (_priorityFilter != 'all' &&
            task.priority.value != _priorityFilter) {
          return false;
        }

        // Overdue filter
        if (_showOverdueOnly && task.status != TaskStatus.completed) {
          try {
            final dueDate = DateTime.parse(task.dueDate);
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final dueDateOnly = DateTime(
              dueDate.year,
              dueDate.month,
              dueDate.day,
            );
            if (!dueDateOnly.isBefore(today)) return false;
          } catch (e) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  int _getOverdueCount() {
    return _tasks.where((task) {
      if (task.status == TaskStatus.completed) return false;
      try {
        final dueDate = DateTime.parse(task.dueDate);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
        return dueDateOnly.isBefore(today);
      } catch (e) {
        return false;
      }
    }).length;
  }

  bool get _hasActiveFilters =>
      _searchTerm.isNotEmpty || _priorityFilter != 'all' || _showOverdueOnly;

  void _clearAllFilters() {
    setState(() {
      _searchTerm = '';
      _priorityFilter = 'all';
      _showOverdueOnly = false;
    });
    _applyFilters();
  }

  List<Task> _getTasksByStatus(TaskStatus status) {
    return _filteredTasks.where((task) => task.status == status).toList();
  }

  void _handleTaskUpdated() {
    // No need to manually reload - real-time stream will update automatically
    // Just reapply filters with current tasks
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unified Search & Filters (Responsive)
              Builder(
                builder: (context) {
                  final searchField = TextField(
                    decoration: InputDecoration(
                      hintText: isMobile
                          ? 'Search tasks...'
                          : 'Search tasks by title, description, or assignee...',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() => _searchTerm = '');
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchTerm = value);
                      _applyFilters();
                    },
                  );

                  final filtersGroup = Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 4 : 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(
                              () => _showOverdueOnly = !_showOverdueOnly,
                            );
                            _applyFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _showOverdueOnly
                                  ? theme.colorScheme.errorContainer
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _showOverdueOnly
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: _showOverdueOnly
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Overdue',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _showOverdueOnly
                                        ? theme.colorScheme.onErrorContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (_getOverdueCount() > 0) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_getOverdueCount()}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: theme.colorScheme.onError,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: isMobile ? 122 : 130,
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _priorityFilter,
                              isExpanded: true,
                              isDense: true,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface,
                              ),
                              selectedItemBuilder: (context) {
                                final labels = isMobile
                                    ? <String, String>{
                                        'all': 'All',
                                        'High': 'High',
                                        'Medium': 'Medium',
                                        'Low': 'Low',
                                      }
                                    : <String, String>{
                                        'all': 'All Priorities',
                                        'High': 'High',
                                        'Medium': 'Medium',
                                        'Low': 'Low',
                                      };
                                return <String>['all', 'High', 'Medium', 'Low']
                                    .map(
                                      (value) => Text(
                                        labels[value] ?? value,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                    .toList();
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('All Priorities'),
                                ),
                                DropdownMenuItem(
                                  value: 'High',
                                  child: Text('High'),
                                ),
                                DropdownMenuItem(
                                  value: 'Medium',
                                  child: Text('Medium'),
                                ),
                                DropdownMenuItem(
                                  value: 'Low',
                                  child: Text('Low'),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() => _priorityFilter = val!);
                                _applyFilters();
                              },
                            ),
                          ),
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _clearAllFilters,
                            child: const Text(
                              'Clear',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        searchField,
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: filtersGroup,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: searchField),
                      const SizedBox(width: 8),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: filtersGroup,
                        ),
                      ),
                    ],
                  );
                },
              ),

              if (_hasActiveFilters) ...[
                const SizedBox(height: 8),
                Text(
                  'Found ${_filteredTasks.length} tasks',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Kanban Section
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : isMobile
                    ? Column(
                        children: [
                          ThemedTabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            tabs: [
                              Tab(
                                text:
                                    'Assigned (${_getTasksByStatus(TaskStatus.assigned).length})',
                              ),
                              Tab(
                                text:
                                    'In Progress (${_getTasksByStatus(TaskStatus.inProgress).length})',
                              ),
                              Tab(
                                text:
                                    'Done (${_getTasksByStatus(TaskStatus.completed).length})',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildColumn(
                                  TaskStatus.assigned,
                                  'Assigned',
                                  theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                ),
                                _buildColumn(
                                  TaskStatus.inProgress,
                                  'In Progress',
                                  theme.colorScheme.primaryContainer.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                _buildColumn(
                                  TaskStatus.completed,
                                  'Completed',
                                  theme.colorScheme.tertiaryContainer
                                      .withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildColumn(
                              TaskStatus.assigned,
                              'Assigned',
                              theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildColumn(
                              TaskStatus.inProgress,
                              'In Progress',
                              theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildColumn(
                              TaskStatus.completed,
                              'Completed',
                              theme.colorScheme.tertiaryContainer.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumn(TaskStatus status, String title, Color color) {
    return KanbanColumn(
      id: status,
      title: title,
      tasks: _getTasksByStatus(status),
      color: color,
      onTaskUpdated: _handleTaskUpdated,
    );
  }
}

