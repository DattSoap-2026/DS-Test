import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../services/vehicles_service.dart';
import '../../../widgets/ui/custom_card.dart';
import '../../../widgets/ui/themed_filter_chip.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class VehicleIssuesTab extends StatefulWidget {
  const VehicleIssuesTab({super.key});

  @override
  State<VehicleIssuesTab> createState() => _VehicleIssuesTabState();
}

class _VehicleIssuesTabState extends State<VehicleIssuesTab> {
  bool _isLoading = true;
  List<VehicleIssue> _issues = [];
  String _statusFilter = 'All'; // All, Open, In Progress, Resolved, Closed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final service = context.read<VehiclesService>();
      final issues = await service.getVehicleIssues(refreshRemote: forceRefresh);
      if (mounted) {
        setState(() {
          _issues = issues;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading issues: $e')));
      }
    }
  }

  Future<void> _showIssueDetails(VehicleIssue issue) async {
    final reportedDate = DateTime.tryParse(issue.reportedDate);
    final resolvedDate = issue.resolvedDate != null
        ? DateTime.tryParse(issue.resolvedDate!)
        : null;
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Issue - ${issue.vehicleNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${issue.status}'),
            const SizedBox(height: 6),
            Text('Priority: ${issue.priority}'),
            const SizedBox(height: 6),
            Text('Reported by: ${issue.reportedBy}'),
            if (reportedDate != null) ...[
              const SizedBox(height: 6),
              Text('Reported on: ${dateFormat.format(reportedDate)}'),
            ],
            if (resolvedDate != null) ...[
              const SizedBox(height: 6),
              Text('Resolved on: ${dateFormat.format(resolvedDate)}'),
            ],
            const SizedBox(height: 10),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(issue.description),
            if ((issue.resolutionNotes ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Resolution',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(issue.resolutionNotes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredIssues = _issues.where((issue) {
      if (_statusFilter == 'All') return true;
      return issue.status == _statusFilter;
    }).toList();

    return Column(
      children: [
        // Filter Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Open'),
                _buildFilterChip('In Progress'),
                _buildFilterChip('Resolved'),
                _buildFilterChip('Closed'),
              ],
            ),
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadData(forceRefresh: true),
            child: filteredIssues.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('No issues reported')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredIssues.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filteredIssues.length) {
                        return const SizedBox(height: 80); // Spacer
                      }
                      return _buildIssueCard(filteredIssues[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ThemedFilterChip(
        label: label,
        selected: _statusFilter == label,
        onSelected: () => setState(() => _statusFilter = label),
      ),
    );
  }

  Widget _buildIssueCard(VehicleIssue issue) {
    Color statusColor = AppColors.lightTextSecondary;
    if (issue.status == 'Open') statusColor = AppColors.error;
    if (issue.status == 'In Progress') statusColor = AppColors.warning;
    if (issue.status == 'Resolved') statusColor = AppColors.success;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(Icons.report_problem, color: statusColor),
        ),
        title: Text(
          '${issue.vehicleNumber} - ${issue.description}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    issue.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat(
                    'MMM dd, yyyy',
                  ).format(DateTime.parse(issue.reportedDate)),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            if (issue.priority != 'Medium')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Priority: ${issue.priority}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        issue.priority == 'Critical' || issue.priority == 'High'
                        ? AppColors.error
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showIssueDetails(issue),
      ),
    );
  }
}
