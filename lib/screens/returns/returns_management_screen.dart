import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../models/types/return_types.dart';

import '../../services/returns_service.dart';
import '../../utils/app_toast.dart';
import '../../utils/responsive.dart';

import 'package:intl/intl.dart';
import 'dialogs/return_details_dialog.dart';
import 'return_details_screen.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class ReturnsManagementScreen extends StatefulWidget {
  const ReturnsManagementScreen({super.key});

  @override
  State<ReturnsManagementScreen> createState() =>
      _ReturnsManagementScreenState();
}

class _ReturnsManagementScreenState extends State<ReturnsManagementScreen> {
  late final ReturnsService _returnsService;
  List<ReturnRequest> _allRequests = [];
  List<ReturnRequest> _filteredRequests = [];
  bool _isLoading = true;
  String _statusFilter = 'pending';
  String _dateFilter = 'all';
  String _searchQuery = '';
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _returnsService = context.read<ReturnsService>();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) {
      return;
    }

    try {
      setState(() => _isLoading = true);
      final requests = await _returnsService.getReturnRequests(
        status: _statusFilter == 'all' ? null : _statusFilter,
        salesmanId: user.role == UserRole.salesman ? user.id : null,
      );
      if (mounted) {
        setState(() {
          _allRequests = requests;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    List<ReturnRequest> result = List.from(_allRequests);

    // Apply date filter
    final now = DateTime.now();
    if (_dateFilter == 'today') {
      result = result.where((r) {
        final date = DateTime.tryParse(r.createdAt);
        if (date == null) return false;
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).toList();
    } else if (_dateFilter == 'week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      result = result.where((r) {
        final date = DateTime.tryParse(r.createdAt);
        if (date == null) return false;
        return date.isAfter(weekAgo);
      }).toList();
    } else if (_dateFilter == 'month') {
      result = result.where((r) {
        final date = DateTime.tryParse(r.createdAt);
        if (date == null) return false;
        return date.year == now.year && date.month == now.month;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((r) {
        return r.salesmanName.toLowerCase().contains(query) ||
            r.items.any((item) => item.name.toLowerCase().contains(query));
      }).toList();
    }

    setState(() {
      _filteredRequests = result;
    });
  }

  Future<void> _processRequest(String id, bool approve) async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) {
      return;
    }

    try {
      bool success = false;
      if (approve) {
        success = await _returnsService.approveReturnRequest(id, user.id);
      } else {
        success = await _returnsService.rejectReturnRequest(id, user.id);
      }

      if (success && mounted) {
        if (approve) {
          AppToast.showSuccess(context, 'Request approved successfully');
        } else {
          AppToast.showInfo(context, 'Request rejected');
        }
        _loadReturns();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    }
  }

  Future<void> _openDetailsView(ReturnRequest request) async {
    final user = context.read<AuthProvider>().state.user;
    final canApprove =
        user?.role == UserRole.admin || user?.role == UserRole.storeIncharge;

    if (Responsive.isMobile(context)) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReturnRequestDetailsScreen(
            request: request,
            canApprove: canApprove,
            onAction: (approve) => _processRequest(request.id, approve),
          ),
          fullscreenDialog: true,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ReturnRequestDetailsDialog(
        request: request,
        canApprove: canApprove,
        onAction: (approve) => _processRequest(request.id, approve),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().state.user;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please login to continue',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    if (user.role != UserRole.admin &&
        user.role != UserRole.storeIncharge &&
        user.role != UserRole.salesman) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'You do not have access to this module',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Return Approvals',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and process product return requests.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Status Tabs + Date Filters
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by salesman or item...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 16),
                    // Filters Row (Responsive)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final dateFilters = <Widget>[
                          _buildDateFilterPill('All Time', 'all', theme),
                          _buildDateFilterPill('Today', 'today', theme),
                          _buildDateFilterPill('This Week', 'week', theme),
                          _buildDateFilterPill('This Month', 'month', theme),
                        ];
                        final statusFilters = <Widget>[
                          _buildStatusTab('Pending', 'pending', theme),
                          _buildStatusTab('Approved', 'approved', theme),
                          _buildStatusTab('Rejected', 'rejected', theme),
                        ];
                        final useWrappedLayout = constraints.maxWidth < 980;

                        if (useWrappedLayout) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: dateFilters,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: statusFilters,
                              ),
                            ],
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...dateFilters.map(
                                (filter) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: filter,
                                ),
                              ),
                              Container(
                                height: 24,
                                width: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              ...statusFilters.map(
                                (filter) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: filter,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRequests.isEmpty
                  ? _buildEmptyState(theme)
                  : Responsive.isMobile(context)
                  ? _buildMobileRequestsList(theme)
                  : _buildDesktopRequestsTable(theme),
            ),
          ),
        ],
      ),
      floatingActionButton: user.role == UserRole.salesman
          ? FloatingActionButton.extended(
              heroTag: 'returns_fab',
              onPressed: () async {
                final result = await context.pushNamed('returns_new');
                if (result == true) {
                  _loadReturns();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildDateFilterPill(String label, String value, ThemeData theme) {
    final isSelected = _dateFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _dateFilter = value);
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, String value, ThemeData theme) {
    final isSelected = _statusFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _statusFilter = value);
        _loadReturns();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopRequestsTable(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Salesman',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Type',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Reason',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Status',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'Actions',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _filteredRequests.length,
            separatorBuilder: (_, index) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            itemBuilder: (context, index) {
              return _buildTableRow(_filteredRequests[index], index, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileRequestsList(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredRequests.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildMobileRequestCard(_filteredRequests[index], theme);
      },
    );
  }

  Widget _buildMobileRequestCard(ReturnRequest request, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetailsView(request),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateSafe(
                            request.createdAt,
                            pattern: 'MMMM d, yyyy',
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.salesmanName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 20),
                    tooltip: 'View Details',
                    onPressed: () => _openDetailsView(request),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildReturnTypeChip(request.returnType, theme),
                  _buildStatusChip(request.status, theme),
                ],
              ),
              if (request.reason.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  request.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(ReturnRequest request, int index, ThemeData theme) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: InkWell(
        onTap: () => _openDetailsView(request),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: isHovered
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : null,
          child: Row(
            children: [
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  _formatDateSafe(request.createdAt, pattern: 'MMMM d, yyyy'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  request.salesmanName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildReturnTypeChip(request.returnType, theme),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  request.reason,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: _buildStatusChip(request.status, theme)),
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 20),
                      tooltip: 'View Details',
                      onPressed: () => _openDetailsView(request),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restore,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Returns Found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Returns will appear here once submitted',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Widget _buildReturnTypeChip(String returnType, ThemeData theme) {
    final isStockReturn = returnType == 'stock_return';
    final chipColor = isStockReturn
        ? AppColors.warning
        : theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        _toTitleCase(returnType.replaceAll('_', ' ')),
        style: TextStyle(
          fontSize: 11,
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'approved':
        bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);
        textColor = theme.colorScheme.primary;
        break;
      case 'rejected':
        bgColor = theme.colorScheme.error.withValues(alpha: 0.1);
        textColor = theme.colorScheme.error;
        break;
      default:
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _toTitleCase(status),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _toTitleCase(String value) {
    if (value.isEmpty) return value;
    final normalized = value.trim().toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}
