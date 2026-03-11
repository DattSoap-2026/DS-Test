import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hr_service.dart';
import '../models/employee_model.dart';
import '../../../services/duty_service.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import '../../../utils/responsive.dart';

class HrDashboardScreen extends StatefulWidget {
  const HrDashboardScreen({super.key});

  @override
  State<HrDashboardScreen> createState() => _HrDashboardScreenState();
}

class _HrDashboardScreenState extends State<HrDashboardScreen> {
  bool _isLoading = true;
  List<Employee> _employees = [];
  List<DutySession> _todaySessions = [];
  final ScrollController _quickActionsController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quickActionsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final hrService = context.read<HrService>();
      final dutyService = context.read<DutyService>();

      _employees = await hrService.getAllEmployees();

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // We don't have a direct "getAllSessionsForDate" that returns a Future in DutyService yet,
      // but we can subscribe or add one if needed.
      // For now, let's use the stream but convert it to a one-time fetch for dashboard.
      // Actually, DutyService.subscribeToDateDutySessions(todayStr).first might work.
      _todaySessions = await dutyService
          .subscribeToDateDutySessions(todayStr)
          .first
          .timeout(const Duration(seconds: 2), onTimeout: () => []);
    } catch (e) {
      debugPrint('Error loading HR data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopActionRow(),
                    const SizedBox(height: 16),
                    _buildStatCards(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Active Employees Today', () {
                      context.pushNamed('hr_attendance');
                    }),
                    const SizedBox(height: 12),
                    _buildActiveSessionsList(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Recent Employees', () {
                      context.pushNamed('hr_employee_list');
                    }),
                    const SizedBox(height: 12),
                    _buildRecentEmployeesList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Staff',
            value: _employees.length.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'On Duty Now',
            value: _todaySessions
                .where((s) => s.status == 'active')
                .length
                .toString(),
            icon: Icons.timer,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTopActionRow() {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final actionSpacing = isMobile ? 10.0 : 16.0;
    final actionWidth = isMobile ? 78.0 : 88.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Scrollbar(
        controller: _quickActionsController,
        thumbVisibility: isMobile,
        notificationPredicate: (notification) =>
            notification.metrics.axis == Axis.horizontal,
        child: SingleChildScrollView(
          controller: _quickActionsController,
          scrollDirection: Axis.horizontal,
          primary: false,
          dragStartBehavior: DragStartBehavior.down,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              _QuickActionBtn(
                icon: Icons.calendar_today,
                label: 'Attendance',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_attendance'),
              ),
              SizedBox(width: actionSpacing),
              _QuickActionBtn(
                icon: Icons.beach_access,
                label: 'Holidays',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_holidays'),
              ),
              SizedBox(width: actionSpacing),
              _QuickActionBtn(
                icon: Icons.date_range,
                label: 'Leaves',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_leave_approval'),
              ),
              SizedBox(width: actionSpacing),
              _QuickActionBtn(
                icon: Icons.monetization_on,
                label: 'Advances',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_advance_approval'),
              ),
              SizedBox(width: actionSpacing),
              _QuickActionBtn(
                icon: Icons.star,
                label: 'Reviews',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_performance_list'),
              ),
              SizedBox(width: actionSpacing),
              _QuickActionBtn(
                icon: Icons.folder,
                label: 'Documents',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_document_list'),
              ),
              SizedBox(width: actionSpacing),
              _QuickActionBtn(
                icon: Icons.payments_outlined,
                label: 'Payroll',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_payroll'),
              ),
              SizedBox(width: actionSpacing),
              _QuickActionBtn(
                icon: Icons.people_outline,
                label: 'Staff List',
                width: actionWidth,
                onTap: () => context.pushNamed('hr_employee_list'),
              ),
              SizedBox(width: actionSpacing),
              TextButton.icon(
                onPressed: () => context.pushNamed('hr_employee_add'),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Employee'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }

  Widget _buildActiveSessionsList() {
    final active = _todaySessions.where((s) => s.status == 'active').toList();
    if (active.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No one is currently on duty',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: active.length > 5 ? 5 : active.length,
      itemBuilder: (context, index) {
        final session = active[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(session.userName),
            subtitle: Text(
              'Started: ${DateFormat('HH:mm').format(DateTime.parse(session.loginTime))}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LIVE',
                style: TextStyle(
                  color: isDark ? Colors.greenAccent : Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentEmployeesList() {
    if (_employees.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No employees registered yet',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _employees.length > 5 ? 5 : _employees.length,
      itemBuilder: (context, index) {
        final emp = _employees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                emp.name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(emp.name),
            subtitle: Text('${emp.roleType.toUpperCase()} | ${emp.department}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed('hr_employee_list'),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.isMobile(context) ? 11 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
