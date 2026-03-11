import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/inventory_service.dart';
import '../../data/local/entities/wastage_log_entity.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/custom_states.dart';
import 'package:intl/intl.dart';

import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/unified_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class WastageLogsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const WastageLogsScreen({super.key, this.onBack});

  @override
  State<WastageLogsScreen> createState() => _WastageLogsScreenState();
}

class _WastageLogsScreenState extends State<WastageLogsScreen> {
  late InventoryService _inventoryService;
  List<WastageLogEntity> _logs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<InventoryService>();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      setState(() => _isLoading = true);
      final logs = await _inventoryService.getWastageLogs();
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wastage logs: $e')),
        );
      }
    }
  }

  List<WastageLogEntity> get _filteredLogs {
    if (_searchQuery.isEmpty) return _logs;
    return _logs.where((log) {
      final nameMatches = log.productName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final reasonMatches = log.reason.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return nameMatches || reasonMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Wastage Logs',
            subtitle: 'Tracking damaged goods & stock losses',
            icon: Icons.delete_sweep_rounded,
            color: AppColors.warning,
            onBack: widget.onBack,
            actions: [
              IconButton(
                onPressed: _loadLogs,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: UnifiedCard(
              padding: const EdgeInsets.all(12),
              child: CustomTextField(
                label: 'SEARCH',
                hintText: 'Search by product or reason...',
                prefixIcon: Icons.search_rounded,
                isDense: true,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const CustomLoadingIndicator(
                    message: 'Loading wastage data...',
                  )
                : _filteredLogs.isEmpty
                ? const CustomEmptyState(
                    icon: Icons.delete_sweep_outlined,
                    title: 'No Wastage Found',
                    message:
                        'Items marked as "Bad Stock" during returns will appear here.',
                  )
                : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        final theme = Theme.of(context);

        return UnifiedCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon/Status
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_down_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            log.productName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(log.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.reason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log.reportedBy,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${log.quantity} ${log.unit}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
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
}

