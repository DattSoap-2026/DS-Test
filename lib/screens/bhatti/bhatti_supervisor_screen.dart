import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth/auth_provider.dart';
import '../../services/bhatti_service.dart';
import '../../utils/mobile_header_typography.dart';
import '../../utils/access_guard.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../widgets/reports/report_export_actions.dart';

class BhattiSupervisorScreen extends StatefulWidget {
  const BhattiSupervisorScreen({super.key});

  @override
  State<BhattiSupervisorScreen> createState() => _BhattiSupervisorScreenState();
}

class _BhattiSupervisorScreenState extends State<BhattiSupervisorScreen>
    with ReportPdfMixin<BhattiSupervisorScreen> {
  bool _isLoading = false;
  List<BhattiBatch> _batches = [];
  String _selectedBhatti = 'All';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  Future<void> _handleBackNavigation() async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      await navigator.maybePop();
      return;
    }
    if (!mounted) return;
    context.go('/dashboard/bhatti/overview');
  }

  @override
  void initState() {
    super.initState();
    AccessGuard.checkBhattiAccess(context);
    _checkAccess();
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.role.canAccessBhatti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied: Bhatti operations restricted to authorized roles')),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final service = context.read<BhattiService>();
      final bhattiFilter = _selectedBhatti == 'All'
          ? null
          : '$_selectedBhatti Bhatti';

      final batches = await service.getBhattiBatches(
        bhattiName: bhattiFilter,
        startDate: DateTime(
          _dateRange.start.year,
          _dateRange.start.month,
          _dateRange.start.day,
        ),
        endDate: DateTime(
          _dateRange.end.year,
          _dateRange.end.month,
          _dateRange.end.day,
          23,
          59,
          59,
        ),
      );

      if (!mounted) return;
      setState(() {
        _batches = batches;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading bhatti batch history: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading batch history: $e')));
    }
  }

  Future<void> _openBatchEdit(BhattiBatch batch) async {
    final result = await context.push<bool>(
      '/dashboard/bhatti/batch/${batch.id}/edit',
    );
    if (result == true) {
      await _loadData();
    }
  }

  void _onBhattiFilterChanged(String value) {
    if (_selectedBhatti == value) return;
    setState(() => _selectedBhatti = value);
    _loadData();
  }

  @override
  bool get hasExportData => _batches.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Created At',
      'Batch Number',
      'Bhatti',
      'Product',
      'Batch Count',
      'Output Boxes',
      'Status',
      'Supervisor',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _batches
        .map(
          (batch) => [
            _formatCreatedAt(batch.createdAt),
            batch.batchNumber,
            batch.bhattiName,
            batch.targetProductName,
            batch.batchCount,
            batch.outputBoxes,
            batch.status.toUpperCase(),
            batch.supervisorName,
          ],
        )
        .toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    return {
      'Bhatti': _selectedBhatti == 'All' ? 'All Bhatti' : _selectedBhatti,
      'Date Range': _dateRangeLabel,
      'Rows': _batches.length.toString(),
    };
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked == null) return;
    setState(() => _dateRange = picked);
    _loadData();
  }

  void _setQuickRangeDays(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    setState(() {
      _dateRange = DateTimeRange(start: start, end: now);
    });
    _loadData();
  }

  bool _isQuickRangeSelected(int days) {
    final now = DateTime.now();
    final expectedStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final actualStart = DateTime(
      _dateRange.start.year,
      _dateRange.start.month,
      _dateRange.start.day,
    );
    final actualEnd = DateTime(
      _dateRange.end.year,
      _dateRange.end.month,
      _dateRange.end.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    return actualStart == expectedStart && actualEnd == today;
  }

  String get _dateRangeLabel {
    final start = DateFormat('dd MMM yyyy').format(_dateRange.start);
    final end = DateFormat('dd MMM yyyy').format(_dateRange.end);
    return '$start - $end';
  }

  String _formatCreatedAt(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final useMobileTypography = useMobileHeaderTypographyForWidth(width);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                if (isMobile)
                  IconButton(
                    onPressed: _handleBackNavigation,
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Text(
                    'Batch History',
                    style: TextStyle(
                      fontSize: useMobileTypography
                          ? mobileHeaderTitleFontSize
                          : 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: useMobileTypography ? -0.2 : 0,
                    ),
                  ),
                ),
                ReportExportActions(
                  isLoading: isExporting,
                  onExport: () => exportReport('Bhatti Batch History'),
                  onPrint: () => printReport('Bhatti Batch History'),
                  onRefresh: _loadData,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedBhatti == 'All',
                  onTap: () => _onBhattiFilterChanged('All'),
                ),
                _FilterChip(
                  label: 'Sona',
                  selected: _selectedBhatti == 'Sona',
                  onTap: () => _onBhattiFilterChanged('Sona'),
                ),
                _FilterChip(
                  label: 'Gita',
                  selected: _selectedBhatti == 'Gita',
                  onTap: () => _onBhattiFilterChanged('Gita'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _dateRangeLabel,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                _FilterChip(
                  label: '7D',
                  selected: _isQuickRangeSelected(7),
                  onTap: () => _setQuickRangeDays(7),
                ),
                _FilterChip(
                  label: '30D',
                  selected: _isQuickRangeSelected(30),
                  onTap: () => _setQuickRangeDays(30),
                ),
                _FilterChip(
                  label: '90D',
                  selected: _isQuickRangeSelected(90),
                  onTap: () => _setQuickRangeDays(90),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _batches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No batch history found',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _batches.length,
                      itemBuilder: (context, index) {
                        final batch = _batches[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => _openBatchEdit(batch),
                            isThreeLine: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            leading: const CircleAvatar(
                              child: Icon(Icons.local_fire_department),
                            ),
                            title: Text(
                              batch.targetProductName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Batch: ${batch.batchNumber} | ${batch.bhattiName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Batches: ${batch.batchCount} | Output: ${batch.outputBoxes} boxes | ${_formatCreatedAt(batch.createdAt)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: batch.status == 'completed'
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                batch.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: batch.status == 'completed'
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
