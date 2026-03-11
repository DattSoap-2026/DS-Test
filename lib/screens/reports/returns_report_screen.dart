import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/returns_service.dart';

import 'package:intl/intl.dart';
import '../../models/types/return_types.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

import '../../utils/app_toast.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class ReturnsReportScreen extends StatefulWidget {
  const ReturnsReportScreen({super.key});

  @override
  State<ReturnsReportScreen> createState() => _ReturnsReportScreenState();
}

class _ReturnsReportScreenState extends State<ReturnsReportScreen>
    with ReportPdfMixin {
  late final ReturnsService _returnsService;
  bool _isLoading = true;
  List<ReturnRequest> _requests = [];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _returnsService = context.read<ReturnsService>();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _returnsService.getReturnRequests(
        status: _selectedStatus,
      );
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading requests: $e');
      }
    }
  }

  @override
  bool get hasExportData => _requests.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return ['Date', 'Salesman', 'Type', 'Status', 'Items', 'Reason'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    final df = DateFormat('dd MMM yyyy HH:mm');
    return _requests.map((req) {
      final date = DateTime.tryParse(req.createdAt);
      final dateText = date != null ? df.format(date) : req.createdAt;

      final itemsText = req.items
          .map((i) => '${i.name} (${i.quantity} ${i.unit})')
          .join('\n');

      return [
        dateText,
        req.salesmanName,
        req.returnType.replaceAll('_', ' ').toUpperCase(),
        req.status.toUpperCase(),
        itemsText,
        req.reason,
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    return {
      'Status': _selectedStatus != null
          ? _selectedStatus!.toUpperCase()
          : 'All Statuses',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Returns Report'),
        centerTitle: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Returns Report'),
            onPrint: () => printReport('Returns Report'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requests.isEmpty
                ? const Center(child: Text('No return requests found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return _buildReturnCard(_requests[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return UnifiedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          const Text(
            'Filter:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedStatus,
                isExpanded: true,
                hint: const Text(
                  'All Statuses',
                  style: TextStyle(fontSize: 13),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Statuses', style: TextStyle(fontSize: 13)),
                  ),
                  const DropdownMenuItem(
                    value: 'pending',
                    child: Text('Pending', style: TextStyle(fontSize: 13)),
                  ),
                  const DropdownMenuItem(
                    value: 'approved',
                    child: Text('Approved', style: TextStyle(fontSize: 13)),
                  ),
                  const DropdownMenuItem(
                    value: 'rejected',
                    child: Text('Rejected', style: TextStyle(fontSize: 13)),
                  ),
                ],
                onChanged: (val) {
                  setState(() => _selectedStatus = val);
                  _loadRequests();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnCard(ReturnRequest request) {
    final df = DateFormat('MMM dd, hh:mm a');
    final date = DateTime.tryParse(request.createdAt);
    final dateText = date != null ? df.format(date) : request.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: UnifiedCard(
        onTap: null,
        backgroundColor: Theme.of(context).cardTheme.color,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.salesmanName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    request.returnType.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _statusBadge(request.status),
            ],
          ),
          subtitle: Text(
            dateText,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...request.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.name, style: const TextStyle(fontSize: 13)),
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Text(
                    'Reason: ${request.reason}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color = colorScheme.onSurfaceVariant;
    if (status == 'approved') color = AppColors.success;
    if (status == 'pending') color = AppColors.warning;
    if (status == 'rejected') color = AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
