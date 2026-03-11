import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/bhatti_service.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class BhattiConsumptionAuditScreen extends StatefulWidget {
  final String batchId;

  const BhattiConsumptionAuditScreen({super.key, required this.batchId});

  @override
  State<BhattiConsumptionAuditScreen> createState() =>
      _BhattiConsumptionAuditScreenState();
}

class _BhattiConsumptionAuditScreenState
    extends State<BhattiConsumptionAuditScreen> {
  bool _isLoading = true;
  BhattiBatch? _batch;
  Map<String, double> _actualQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<BhattiService>();
      final batch = await service.getBhattiBatchById(widget.batchId);

      if (batch != null) {
        // Calculate actual consumption
        final actual = <String, double>{};
        for (var item in batch.rawMaterialsConsumed) {
          final name = item['name'] ?? item['materialName'] ?? 'Unknown';
          final qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
          actual[name] = (actual[name] ?? 0.0) + qty;
        }

        setState(() {
          _batch = batch;
          _actualQuantities = actual;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_batch == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Batch not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Consumption Audit',
            subtitle: 'Batch #${_batch!.batchNumber}',
            icon: Icons.fact_check_outlined,
            color: theme.colorScheme.primary,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBatchInfo(),
                  const SizedBox(height: 24),
                  _buildTankConsumption(),
                  const SizedBox(height: 24),
                  _buildMaterialComparison(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchInfo() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BATCH INFORMATION',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Bhatti', _batch!.bhattiName),
            _buildInfoRow('Product', _batch!.targetProductName),
            _buildInfoRow('Batch Count', '${_batch!.batchCount}'),
            _buildInfoRow('Output Boxes', '${_batch!.outputBoxes}'),
            _buildInfoRow('Supervisor', _batch!.supervisorName),
            _buildInfoRow('Status', _batch!.status.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTankConsumption() {
    final theme = Theme.of(context);
    final tankConsumptions = _batch!.tankConsumptions;

    if (tankConsumptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TANK CONSUMPTION DETAILS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            ...tankConsumptions.map((tc) {
              final tankName = tc['tankName'] ?? 'Unknown Tank';
              final qty = (tc['quantity'] as num?)?.toDouble() ?? 0.0;
              final lots = tc['lots'] as List? ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tankName.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${qty.toStringAsFixed(2)} KG',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (lots.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...lots.map((lot) {
                        final lotQty =
                            (lot['quantity'] as num?)?.toDouble() ?? 0.0;
                        final lotId = lot['lotId'] ?? 'Unknown';
                        return Padding(
                          padding: const EdgeInsets.only(left: 24, top: 4),
                          child: Text(
                            'Lot: $lotId → ${lotQty.toStringAsFixed(2)} KG',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialComparison() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MATERIAL CONSUMPTION',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            ..._actualQuantities.entries.map((entry) {
              final name = entry.key;
              final actualQty = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Actual Consumed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${actualQty.toStringAsFixed(2)} KG',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
