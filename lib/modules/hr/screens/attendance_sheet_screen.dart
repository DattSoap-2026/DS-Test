import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/attendance_model.dart';
import '../models/employee_model.dart';
import '../services/attendance_service.dart';
import '../services/holiday_service.dart';
import '../models/holiday_model.dart';
import '../services/hr_service.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../widgets/ui/themed_tab_bar.dart';
import '../../../utils/responsive.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class AttendanceSheetScreen extends StatefulWidget {
  const AttendanceSheetScreen({super.key});

  @override
  State<AttendanceSheetScreen> createState() => _AttendanceSheetScreenState();
}

class _AttendanceSheetScreenState extends State<AttendanceSheetScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;
  List<Employee> _employees = [];
  List<Attendance> _attendance = [];
  List<Holiday> _holidays = [];
  bool _showDailyGrid = true;

  // Tabs: All then strict roles requested
  final List<String> _tabs = [
    'All Staff',
    'Driver',
    'Worker',
    'Helper',
    'Office Staff',
    'Security', // Mapping GateKeeper
    'Salesman',
  ];
  late TabController _tabController;
  final ScrollController _verticalController1 = ScrollController();
  final ScrollController _verticalController2 = ScrollController();
  final ScrollController _verticalController3 = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _tabController.addListener(() => setState(() {}));

    // Sync scrolling with safety checks
    _verticalController1.addListener(() {
      if (_verticalController2.hasClients &&
          _verticalController1.offset != _verticalController2.offset) {
        _verticalController2.jumpTo(_verticalController1.offset);
      }
      if (_verticalController3.hasClients &&
          _verticalController1.offset != _verticalController3.offset) {
        _verticalController3.jumpTo(_verticalController1.offset);
      }
    });

    _verticalController2.addListener(() {
      if (_verticalController1.hasClients &&
          _verticalController2.offset != _verticalController1.offset) {
        _verticalController1.jumpTo(_verticalController2.offset);
      }
      if (_verticalController3.hasClients &&
          _verticalController2.offset != _verticalController3.offset) {
        _verticalController3.jumpTo(_verticalController2.offset);
      }
    });

    _verticalController3.addListener(() {
      if (_verticalController1.hasClients &&
          _verticalController3.offset != _verticalController1.offset) {
        _verticalController1.jumpTo(_verticalController3.offset);
      }
      if (_verticalController2.hasClients &&
          _verticalController3.offset != _verticalController2.offset) {
        _verticalController2.jumpTo(_verticalController3.offset);
      }
    });

    _horizontalController.addListener(_syncHorizontalScrollState);

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _verticalController1.dispose();
    _verticalController2.dispose();
    _verticalController3.dispose();
    _horizontalController.removeListener(_syncHorizontalScrollState);
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> _reloadAttendanceOnly() async {
    if (!mounted) return;
    try {
      final attService = context.read<AttendanceService>();
      final newAttendance = await attService.getAttendancesForMonth(_selectedMonth);
      if (mounted) {
        setState(() {
          _attendance = newAttendance;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reloading: $e')),
        );
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final hrService = context.read<HrService>();
      final attService = context.read<AttendanceService>();

      final holidayService = context.read<HolidayService>();

      // Load all active employees
      final allEmployees = await hrService.getAllEmployees();
      _employees = allEmployees.where((e) => e.isActive).toList();

      // Load attendance for the month
      _attendance = await attService.getAttendancesForMonth(_selectedMonth);
      
      // Load holidays
      _holidays = await holidayService.getHolidaysForMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_horizontalController.hasClients) {
        _horizontalController.jumpTo(0);
      }
    });
    _loadData();
  }

  Future<void> _scrollTableHorizontally(double delta) async {
    if (!_horizontalController.hasClients) return;
    final position = _horizontalController.position;
    final target = (_horizontalController.offset + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (target == _horizontalController.offset) return;
    await _horizontalController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _syncHorizontalScrollState() {
    if (!mounted || !_horizontalController.hasClients) return;
    final position = _horizontalController.position;
    final canLeft = position.pixels > position.minScrollExtent + 0.5;
    final canRight = position.pixels < position.maxScrollExtent - 0.5;
    if (canLeft == _canScrollLeft && canRight == _canScrollRight) return;
    setState(() {
      _canScrollLeft = canLeft;
      _canScrollRight = canRight;
    });
  }

  void _refreshHorizontalScrollStatePostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_horizontalController.hasClients) {
        if (_canScrollLeft || _canScrollRight) {
          setState(() {
            _canScrollLeft = false;
            _canScrollRight = false;
          });
        }
        return;
      }
      _syncHorizontalScrollState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Attendance Sheet'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: ThemedTabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 16,
                    ),
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
                _buildCompactMonthSelector(isMobile: isMobile),
                SizedBox(width: isMobile ? 4 : 16),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showDailyGrid ? Icons.visibility : Icons.visibility_off,
            ),
            tooltip: _showDailyGrid ? 'Hide Daily Grid' : 'Show Daily Grid',
            onPressed: () => setState(() => _showDailyGrid = !_showDailyGrid),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Month Selector moved to AppBar
          _buildSummaryMetrics(_filterEmployees(_tabs[_tabController.index])),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildAttendanceTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMonthSelector({required bool isMobile}) {
    final iconSize = isMobile ? 18.0 : 20.0;
    final iconConstraints = BoxConstraints(
      minWidth: isMobile ? 28 : 40,
      minHeight: isMobile ? 28 : 40,
    );
    final monthLabel = isMobile
        ? DateFormat('MMM yyyy').format(_selectedMonth)
        : DateFormat('MMMM yyyy').format(_selectedMonth);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: iconConstraints,
          icon: Icon(Icons.chevron_left, size: iconSize),
          onPressed: () => _changeMonth(-1),
          tooltip: 'Previous Month',
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 90 : 130),
          child: Text(
            monthLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: iconConstraints,
          icon: Icon(Icons.chevron_right, size: iconSize),
          onPressed: () => _changeMonth(1),
          tooltip: 'Next Month',
        ),
        // Lock Indicator
        if (_selectedMonth.isBefore(
          DateTime(DateTime.now().year, DateTime.now().month),
        ))
          Tooltip(
            message: 'Month Locked',
            child: Icon(
              Icons.lock,
              size: isMobile ? 13 : 16,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryMetrics(List<Employee> employees) {
    if (_employees.isEmpty) return const SizedBox.shrink();

    final today = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == today.year && 
                          _selectedMonth.month == today.month;
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    int present = 0;
    int absent = 0;
    int late = 0;
    int halfDay = 0;
    int leaves = 0;

    final empIds = employees.map((e) => e.employeeId).toSet();
    
    // Show today's attendance if current month, otherwise show month summary
    final relevantAttendance = isCurrentMonth
        ? _attendance.where((a) => 
            empIds.contains(a.employeeId) && 
            DateFormat('yyyy-MM-dd').format(a.date) == todayStr)
        : _attendance.where((a) => empIds.contains(a.employeeId));

    for (var a in relevantAttendance) {
      if (a.status == 'Present') {
        present++;
      } else if (a.status == 'Absent') {
        absent++;
      } else if (a.status == 'Late') {
        late++;
      } else if (a.status == 'HalfDay') {
        halfDay++;
      } else if (a.status == 'OnLeave') {
        leaves++;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isCurrentMonth)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Today\'s Attendance (${DateFormat('dd MMM').format(today)})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Present', present, Colors.green, 'Present'),
                _buildStatItem('Absent', absent, Colors.red, 'Absent'),
                _buildStatItem('Late', late, Colors.orange, 'Late'),
                _buildStatItem('Half Day', halfDay, Colors.blue, 'HalfDay'),
                _buildStatItem('Leave', leaves, Colors.purple, 'OnLeave'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, String statusFilter) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: count > 0 ? () => _showFilteredEmployees(statusFilter) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilteredEmployees(String status) {
    final today = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == today.year && 
                          _selectedMonth.month == today.month;
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    
    final filteredEmployees = _filterEmployees(_tabs[_tabController.index]);
    final matchingEmployees = <Employee>[];
    
    for (var emp in filteredEmployees) {
      final record = _attendance.firstWhere(
        (a) => a.employeeId == emp.employeeId && 
               (isCurrentMonth 
                 ? DateFormat('yyyy-MM-dd').format(a.date) == todayStr
                 : true) &&
               a.status == status,
        orElse: () => Attendance(
          id: '',
          employeeId: '',
          date: DateTime.now(),
          status: '',
          updatedAt: DateTime.now(),
        ),
      );
      
      if (record.id.isNotEmpty) {
        matchingEmployees.add(emp);
      }
    }
    
    if (matchingEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No employees with $status status')),
      );
      return;
    }
    
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$status Employees',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                if (isCurrentMonth)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      'Today (${DateFormat('dd MMM yyyy').format(today)})',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const Divider(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: matchingEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = matchingEmployees[index];
                      final empRecord = _attendance.firstWhere(
                        (a) => a.employeeId == emp.employeeId && 
                               (isCurrentMonth 
                                 ? DateFormat('yyyy-MM-dd').format(a.date) == todayStr
                                 : true) &&
                               a.status == status,
                        orElse: () => Attendance(
                          id: '',
                          employeeId: '',
                          date: DateTime.now(),
                          status: '',
                          updatedAt: DateTime.now(),
                        ),
                      );
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          child: Text(
                            emp.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: theme.colorScheme.onPrimary),
                          ),
                        ),
                        title: Text(emp.name),
                        subtitle: Row(
                          children: [
                            Text(emp.roleType),
                            if (empRecord.id.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${DateFormat('HH:mm').format(empRecord.effectiveMarkedAt)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showEmployeeDetails(emp);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceTable() {
    final filteredEmployees = _filterEmployees(_tabs[_tabController.index]);
    if (filteredEmployees.isEmpty) {
      return const Center(child: Text('No employees found for this role'));
    }

    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final employeeColumnWidth = isMobile ? 140.0 : 160.0;
    const cellWidth = 50.0;
    const summaryColumnCount = 7;
    const summaryWidth = summaryColumnCount * cellWidth;
    final dailyGridWidth = daysInMonth * cellWidth;
    final scrollableWidth = summaryWidth + (_showDailyGrid ? dailyGridWidth : 0);
    _refreshHorizontalScrollStatePostFrame();

    final employeeColumn = SizedBox(
      width: employeeColumnWidth,
      child: Column(
        children: [
          _buildHeaderCell(
            'Employee',
            width: employeeColumnWidth,
            height: 50,
          ),
          Expanded(
            child: ListView.builder(
              controller: _verticalController1,
              itemCount: filteredEmployees.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (ctx, i) {
                final emp = filteredEmployees[i];
                return InkWell(
                  onTap: () => _showEmployeeDetails(emp),
                  child: Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: theme.dividerColor),
                        right: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          emp.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          emp.roleType,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.hintColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    final horizontalTable = Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      notificationPredicate: (notification) =>
          notification.metrics.axis == Axis.horizontal,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: scrollableWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showDailyGrid)
                SizedBox(
                  width: dailyGridWidth,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: List.generate(daysInMonth, (index) {
                            final date = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month,
                              index + 1,
                            );
                            final isWeekend = date.weekday == DateTime.sunday;
                            return _buildHeaderCell(
                              '${index + 1}\n${DateFormat('E').format(date).substring(0, 1)}',
                              width: cellWidth,
                              color: isWeekend
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : null,
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _verticalController2,
                          itemCount: filteredEmployees.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (ctx, i) {
                            final emp = filteredEmployees[i];
                            return SizedBox(
                              height: 50,
                              child: Row(
                                children: List.generate(daysInMonth, (dIndex) {
                                  final date = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month,
                                    dIndex + 1,
                                  );
                                  return _buildCell(emp, date);
                                }),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: summaryWidth,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _buildHeaderCell(
                            'P',
                            width: cellWidth,
                            color: theme.brightness == Brightness.dark
                                ? Colors.green[900]?.withValues(alpha: 0.5)
                                : Colors.green[100],
                            textColor: theme.brightness == Brightness.dark
                                ? Colors.green[200]
                                : theme.colorScheme.onSurface,
                          ),
                          _buildHeaderCell(
                            'A',
                            width: cellWidth,
                            color: theme.brightness == Brightness.dark
                                ? Colors.red[900]?.withValues(alpha: 0.5)
                                : Colors.red[100],
                            textColor: theme.brightness == Brightness.dark
                                ? Colors.red[200]
                                : theme.colorScheme.onSurface,
                          ),
                          _buildHeaderCell(
                            'L',
                            width: cellWidth,
                            color: theme.brightness == Brightness.dark
                                ? Colors.orange[900]?.withValues(alpha: 0.5)
                                : Colors.orange[100],
                            textColor: theme.brightness == Brightness.dark
                                ? Colors.orange[200]
                                : theme.colorScheme.onSurface,
                          ),
                          _buildHeaderCell(
                            'HD',
                            width: cellWidth,
                            color: theme.brightness == Brightness.dark
                                ? Colors.blue[900]?.withValues(alpha: 0.5)
                                : Colors.blue[100],
                            textColor: theme.brightness == Brightness.dark
                                ? Colors.blue[200]
                                : theme.colorScheme.onSurface,
                          ),
                          _buildHeaderCell(
                            'WO',
                            width: cellWidth,
                            color: theme.brightness == Brightness.dark
                                ? theme.colorScheme.surfaceContainerLow
                                : theme.colorScheme.surfaceContainerHighest,
                          ),
                          _buildHeaderCell(
                            'OT',
                            width: cellWidth,
                            color: theme.brightness == Brightness.dark
                                ? Colors.purple[900]?.withValues(alpha: 0.5)
                                : Colors.purple[100],
                            textColor: theme.brightness == Brightness.dark
                                ? Colors.purple[200]
                                : theme.colorScheme.onSurface,
                          ),
                          _buildHeaderCell(
                            'WD',
                            width: cellWidth,
                            color: theme.brightness == Brightness.dark
                                ? Colors.teal[900]?.withValues(alpha: 0.5)
                                : Colors.teal[100],
                            textColor: theme.brightness == Brightness.dark
                                ? Colors.teal[200]
                                : theme.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _verticalController3,
                        itemCount: filteredEmployees.length,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (ctx, i) {
                          final summary = _calculateSummary(filteredEmployees[i]);
                          return Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: theme.dividerColor),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildSummaryCell(summary.presentDays.toString()),
                                _buildSummaryCell(summary.absentDays.toString()),
                                _buildSummaryCell(summary.lateDays.toString()),
                                _buildSummaryCell(summary.halfDays.toString()),
                                _buildSummaryCell(summary.weeklyOffDays.toString()),
                                _buildSummaryCell(
                                  summary.totalOvertimeHours > 0
                                      ? summary.totalOvertimeHours.toStringAsFixed(1)
                                      : '0',
                                ),
                                _buildSummaryCell(
                                  summary.totalWorkingDays.toString(),
                                  isBold: true,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Use left/right buttons or scrollbar to view full month',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Scroll left',
                onPressed: _canScrollLeft
                    ? () => _scrollTableHorizontally(isMobile ? -220 : -300)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Scroll right',
                onPressed: _canScrollRight
                    ? () => _scrollTableHorizontally(isMobile ? 220 : 300)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
            child: Row(
              children: [
                employeeColumn,
                Expanded(child: horizontalTable),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AttendanceSummary _calculateSummary(Employee emp) {
    int presentDays = 0;
    int absentDays = 0;
    int lateDays = 0;
    int halfDays = 0;
    int leaveDays = 0;
    int woWorked = 0;
    double totalOt = 0;

    int daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    int scheduledWeeklyOffs = 0;

    final empAttendance = _attendance
        .where((a) => a.employeeId == emp.employeeId)
        .toList();

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      
      if (date.weekday == emp.weeklyOffDay) {
        scheduledWeeklyOffs++;
      }

      final isHoliday = _holidays.any((h) => 
          h.date.toString().split(' ')[0] == dateKey);
      
      if (isHoliday) {
        // Just track it for internal loop if needed
      }

      final record = empAttendance.firstWhere(
        (a) => DateFormat('yyyy-MM-dd').format(a.date) == dateKey,
        orElse: () => Attendance(
          id: '',
          employeeId: emp.employeeId,
          date: date,
          status: '',
          updatedAt: DateTime.now(),
        ),
      );

      if (record.id.isNotEmpty || record.status.isNotEmpty) {
        if (record.overtimeHours != null) {
          totalOt += record.overtimeHours!;
        }

        switch (record.status) {
          case 'Present':
            presentDays++;
            break;
          case 'Absent':
            if (!isHoliday) absentDays++;
            break;
          case 'Late':
            lateDays++;
            break;
          case 'HalfDay':
            halfDays++;
            break;
          case 'OnLeave':
            leaveDays++;
            break;
          case 'WeeklyOffWorked':
            woWorked++;
            break;
        }
      }
    }

    // WD = Total Days - WO - Holidays (Standard)
    // User logic: WD = Total Days - WO - Approved Leaves
    int wd = daysInMonth - scheduledWeeklyOffs - leaveDays;

    return AttendanceSummary(
      employeeId: emp.employeeId,
      month: _selectedMonth.month,
      year: _selectedMonth.year,
      presentDays: presentDays,
      absentDays: absentDays,
      lateDays: lateDays,
      halfDays: halfDays,
      leaveDays: leaveDays,
      weeklyOffWorkedDays: woWorked,
      weeklyOffDays: scheduledWeeklyOffs,
      totalWorkingDays: wd,
      totalOvertimeHours: totalOt,
    );
  }

  Widget _buildSummaryCell(String text, {bool isBold = false}) {
    return Container(
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(
              alpha: 0.2,
            ),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  List<Employee> _filterEmployees(String tabName) {
    if (tabName == 'All Staff') {
      return _employees..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    // Normalize mapping
    String searchRole = _normalizeRole(tabName);

    return _employees.where((e) {
      final role = _normalizeRole(e.roleType);
      if (searchRole == 'security' && role == 'gatekeeper') return true;
      return role.contains(searchRole);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  String _normalizeRole(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
  }

  Widget _buildHeaderCell(
    String text, {
    double? width,
    double? height,
    Color? color,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
          right: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showEmployeeDetails(Employee emp) {
    final summary = _calculateSummary(emp);
    final theme = Theme.of(context);

    // Get all records for this month
    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final monthRecords = <Attendance>[];

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, i);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final record = _attendance.firstWhere(
        (a) =>
            a.employeeId == emp.employeeId &&
            DateFormat('yyyy-MM-dd').format(a.date) == dateStr,
        orElse: () => Attendance(
          id: '',
          employeeId: emp.employeeId,
          date: date,
          status: 'None',
          updatedAt: DateTime.now(),
        ),
      );
      monthRecords.add(record);
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        emp.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp.name, style: theme.textTheme.headlineSmall),
                        Text(emp.roleType, style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          summary.presentDays.toString(),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'Present',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          summary.absentDays.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'Absent',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          summary.lateDays.toString(),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'Late',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          summary.halfDays.toString(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'HalfDay',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'Attendance Log (${DateFormat('MMMM yyyy').format(_selectedMonth)})',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: monthRecords.length,
                    itemBuilder: (context, index) {
                      final record = monthRecords[index];
                      final date = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month,
                        index + 1,
                      );
                      final isWeekend = date.weekday == emp.weeklyOffDay;
                      if (record.id.isEmpty && !isWeekend) {
                        return const SizedBox.shrink();
                      }

                      Color statusColor =
                          Theme.of(context).colorScheme.onSurfaceVariant;
                      if (record.status == 'Present') {
                        statusColor = Colors.green;
                      }
                      if (record.status == 'Absent') {
                        statusColor = Colors.red;
                      }
                      if (record.status == 'Late') {
                        statusColor = Colors.orange;
                      }
                      if (record.status == 'HalfDay') {
                        statusColor = Colors.blue;
                      }
                      if (record.status == 'WeeklyOffWorked') {
                        statusColor = Colors.purple;
                      }

                      return ListTile(
                        dense: true,
                        leading: Text(
                          DateFormat('dd MMM (E)').format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Row(
                          children: [
                            Text(
                              record.id.isEmpty
                                  ? (isWeekend ? 'Weekly Off' : 'Not Marked')
                                  : record.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (record.id.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('HH:mm').format(record.effectiveMarkedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: record.remarks != null
                            ? Text(record.remarks!)
                            : null,
                        trailing: record.isCorrected
                            ? const Icon(Icons.edit, size: 14)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(Employee emp, DateTime date) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Find attendance
    final record = _attendance.firstWhere(
      (a) =>
          a.employeeId == emp.employeeId &&
          DateFormat('yyyy-MM-dd').format(a.date) == dateStr,
      orElse: () => Attendance(
        id: '',
        employeeId: emp.employeeId,
        date: date,
        status: 'None',
        updatedAt: DateTime.now(),
      ),
    );

    // Determine State
    bool isPresent = record.id.isNotEmpty;
    bool isHoliday = _holidays.any((h) => 
        DateFormat('yyyy-MM-dd').format(h.date) == dateStr);
    bool isWeeklyOff = date.weekday == emp.weeklyOffDay;
    bool isLocked = record.id.isNotEmpty && record.isLocked;

    Color? cellColor;
    if (isHoliday) {
      cellColor = Colors.orange[50];
    }

    Widget content;

    if (isPresent) {
      // Marked
      switch (record.status) {
        case 'Present':
          content = const Icon(Icons.check, color: Colors.green, size: 20);
          break;
        case 'Absent':
          content = const Icon(Icons.close, color: Colors.red, size: 20);
          break;
        case 'Late':
          content = const Icon(
            Icons.access_time,
            color: Colors.orange,
            size: 20,
          );
          break;
        case 'HalfDay':
          content = const Icon(
            Icons.star_half,
            color: Colors.orangeAccent,
            size: 20,
          );
          break;
        case 'WeeklyOff':
          cellColor = Colors.blue[100];
          content = const Text(
            'WO',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          );
          break;
        case 'WeeklyOffWorked':
          cellColor = Colors.purple[50];
          content = const Icon(Icons.star, color: Colors.purple, size: 20);
          break;
        case 'OnLeave':
          content = const Text(
            'L',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          );
          break;
        default:
          content = Text(record.status.substring(0, 1));
      }

      if (record.isCorrected) {
        // Overlay edit indicator
        content = Stack(
          alignment: Alignment.center,
          children: [
            content,
            const Positioned(
              right: 2,
              top: 2,
              child: Icon(Icons.edit, size: 8, color: Colors.orange),
            ),
          ],
        );
      }
    } else {
      // Not Marked
      if (isHoliday) {
        content = const Text(
          'H',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        );
      } else if (isWeeklyOff) {
        cellColor = Colors.blue[50];
        content = const Text(
          'WO',
          style: TextStyle(color: Colors.blueGrey, fontSize: 10),
        );
      } else {
        content = Container(); // Empty tap target
      }
    }

    if (isLocked) {
      cellColor = (cellColor ?? Colors.transparent).withValues(alpha: 0.5);
    }

    return GestureDetector(
      onTap: () =>
          _handleCellTap(emp, date, record, isPresent, isWeeklyOff, isLocked),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cellColor,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
        ),
        child: isLocked
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(opacity: 0.5, child: content),
                  Icon(
                    Icons.lock,
                    size: 12,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ],
              )
            : content,
      ),
    );
  }

  Future<void> _handleCellTap(
    Employee emp,
    DateTime date,
    Attendance record,
    bool isPresent,
    bool isWeeklyOff,
    bool isLocked,
  ) async {
    final service = context.read<AttendanceService>();

    // Case 1: Already Marked -> Edit / View
    if (isPresent) {
      _showEditDialog(record, emp);
      return;
    }

    // Case 2: Weekly Off but Empty -> Mark as Worked?
    if (isWeeklyOff) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => ResponsiveAlertDialog(
          title: const Text('Weekly Off'),
          content: Text(
            '${emp.name} is on weekly off. Mark as worked (Overtime)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Mark Worked'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await service.markDailyAttendance(
          employeeId: emp.employeeId,
          date: date,
          status: 'WeeklyOffWorked',
          isOvertime: true,
          remarks: 'Worked on Weekly Off',
        );
        await _reloadAttendanceOnly();
      }
      return;
    }

    // Case 3: Empty -> Quick Mark Present
    await showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Mark ${emp.name}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _mark(emp, date, 'Present');
            },
            child: const Row(
              children: [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 8),
                Text('Present'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _mark(emp, date, 'Absent');
            },
            child: const Row(
              children: [
                Icon(Icons.close, color: Colors.red),
                SizedBox(width: 8),
                Text('Absent'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _mark(emp, date, 'Late');
            },
            child: const Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange),
                SizedBox(width: 8),
                Text('Late'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _mark(emp, date, 'HalfDay');
            },
            child: const Row(
              children: [
                Icon(Icons.star_half, color: Colors.orangeAccent),
                SizedBox(width: 8),
                Text('Half Day'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mark(Employee emp, DateTime date, String status) async {
    try {
      await context.read<AttendanceService>().markDailyAttendance(
        employeeId: emp.employeeId,
        date: date,
        status: status,
      );
      // Reload only attendance data without resetting scroll
      await _reloadAttendanceOnly();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _showEditDialog(Attendance record, Employee emp) async {
    final user = context.read<AuthProvider>().currentUser;
    final service = context.read<AttendanceService>();

    bool canEdit = !record.isLocked || (user?.isAdmin ?? false);

    String selectedStatus = record.status;
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => ResponsiveAlertDialog(
          title: Text(
            '${canEdit ? "Edit" : "View"} Attendance - ${DateFormat('dd MMM').format(record.date)}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Employee: ${emp.name}'),
              const SizedBox(height: 16),
              IgnorePointer(
                ignoring: !canEdit,
                child: Opacity(
                  opacity: canEdit ? 1.0 : 0.7,
                  child: DropdownButtonFormField<String>(
                    // value: selectedStatus, // Deprecated in favor of initialValue?
                    // Actually, keep value for controlled input but ignore lint if it insists on initialValue for form field.
                    // But here we are reactively updating it via setState.
                    // Let's try initialValue and rely on key to rebuild? No.
                    // Let's stick with value but acknowledging it is standard.
                    // ignore: deprecated_member_use
                    value: selectedStatus,
                    items:
                        [
                              'Present',
                              'Absent',
                              'Late',
                              'HalfDay',
                              'OnLeave',
                              'WeeklyOffWorked',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => selectedStatus = v!),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Mandatory)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                enabled: canEdit,
              ),
              if (record.auditLog.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Audit Log:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100, // Limit height
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: record.auditLog.length,
                    itemBuilder: (context, index) {
                      final log = record.auditLog[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        title: Text('${log.oldStatus} -> ${log.newStatus}'),
                        subtitle: Text(
                          '${log.editedBy}  ${DateFormat('dd MMM HH:mm').format(log.editedAt)}\nReason: ${log.reason}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            if (canEdit)
              ElevatedButton(
                onPressed: () async {
                  if (reasonController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reason is required')),
                    );
                    return;
                  }
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);
                  try {
                    await service.correctDailyAttendance(
                      employeeId: record.employeeId,
                      date: record.date,
                      status: selectedStatus,
                      remarks: reasonController.text,
                      userId: user?.id ?? 'Unknown',
                      userName: user?.name ?? 'Unknown',
                      forceUnlock: user?.isAdmin ?? false,
                    );
                    if (navigator.mounted) navigator.pop();
                    await _reloadAttendanceOnly();
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
                child: const Text('Save Correction'),
              ),
          ],
        ),
      ),
    );
  }
}
