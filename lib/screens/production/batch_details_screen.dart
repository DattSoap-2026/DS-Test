import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/production_types.dart';
import '../../services/production_batch_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class BatchDetailsScreen extends StatefulWidget {
  final String batchId;
  const BatchDetailsScreen({super.key, required this.batchId});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  late final ProductionBatchService _batchService;
  bool _isLoading = true;
  ProductionBatch? _batch;

  @override
  void initState() {
    super.initState();
    _batchService = context.read<ProductionBatchService>();
    _loadBatch();
  }

  Future<void> _loadBatch() async {
    setState(() => _isLoading = true);
    final batch = await _batchService.getProductionBatch(widget.batchId);
    if (mounted) {
      setState(() {
        _batch = batch;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_batch != null ? 'Batch #${_batch!.batchNumber}' : 'Batch Details'),
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batch == null
              ? const Center(child: Text('Batch not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildProgressTimeline(),
                      const SizedBox(height: 24),
                      _buildMassBalanceSection(),
                      const SizedBox(height: 24),
                      if (_batch!.qc != null) _buildQCSection(),
                      if (_batch!.packing != null) _buildPackingSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_batch!.finishedGoodName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildStageChip(_batch!.stage),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Source: ${_batch!.semiFinishedProductName} (${_batch!.departmentName})',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Planned', '${_batch!.plannedQty} units'),
                _buildInfoItem('Actual', '${_batch!.physicalFinishedQty} units'),
                _buildInfoItem('Eff.', '${_batch!.efficiencyPercent.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStageChip(ProductionStage stage) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color = colorScheme.outlineVariant;
    switch (stage) {
      case ProductionStage.cutting: color = AppColors.info; break;
      case ProductionStage.qc: color = AppColors.warning; break;
      case ProductionStage.packing: color = AppColors.info; break;
      case ProductionStage.ready: color = AppColors.success; break;
      case ProductionStage.dispatched: color = AppColors.lightPrimary; break;
      default: break;
    }
    return Chip(
      label: Text(
        stage.value,
        style: TextStyle(color: colorScheme.onPrimary, fontSize: 10),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildProgressTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Production Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTimelineTile('Cutting Started', _batch!.cuttingStartedAt, true),
        _buildTimelineTile('Cutting Completed', _batch!.cuttingCompletedAt, _batch!.cuttingCompletedAt != null),
        _buildTimelineTile('QC Started', _batch!.qcStartedAt, _batch!.qcStartedAt != null),
        _buildTimelineTile('QC Completed', _batch!.qcCompletedAt, _batch!.qcCompletedAt != null),
        _buildTimelineTile('Packing Started', _batch!.packingStartedAt, _batch!.packingStartedAt != null),
        _buildTimelineTile('Packing Completed', _batch!.packingCompletedAt, _batch!.packingCompletedAt != null),
        _buildTimelineTile('Ready for Dispatch', _batch!.readyAt, _batch!.readyAt != null),
      ],
    );
  }

  Widget _buildTimelineTile(String label, String? timestamp, bool isDone) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppColors.success : colorScheme.outlineVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
                if (timestamp != null)
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMassBalanceSection() {
    return Card(
      color: AppColors.infoBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mass Balance Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildBalanceRow('Batch Input Weight', '${_batch!.batchTotalKg.toStringAsFixed(2)} kg'),
            _buildBalanceRow('Net Output Weight', '${_batch!.actualOutputKg.toStringAsFixed(2)} kg'),
            _buildBalanceRow('Process Loss', '${_batch!.lossKg.toStringAsFixed(2)} kg', color: AppColors.error),
            const Divider(),
            _buildBalanceRow('Production Efficiency', '${_batch!.efficiencyPercent.toStringAsFixed(1)}%', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  Widget _buildQCSection() {
    final qc = _batch!.qc!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Quality Control Inspection', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildBalanceRow('Status', qc.status.value, color: qc.status == QCStatus.approved ? AppColors.success : AppColors.error),
            _buildBalanceRow('Sample Size', '${qc.sampleSize} units'),
            _buildBalanceRow('Defects Found', '${qc.defectCount} units'),
            if (qc.remarks != null) ...[
              const SizedBox(height: 8),
              Text(
                'Remarks: ${qc.remarks}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackingSection() {
    final packing = _batch!.packing!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.info),
                SizedBox(width: 8),
                Text('Packing Information', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildBalanceRow('Boxes Packed', '${packing.boxesPacked}'),
            _buildBalanceRow('Units per Box', '${packing.unitsPerBox}'),
            _buildBalanceRow('Total Boxes Planned', '${packing.totalBoxes}'),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String ts) {
    try {
      final date = DateTime.parse(ts);
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return ts;
    }
  }
}


