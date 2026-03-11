import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/bhatti_service.dart';
import '../../utils/normalized_number_input_formatter.dart';

import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/shared/app_card.dart';
import '../../widgets/ui/shared/app_button.dart';
import '../../widgets/ui/shared/app_input.dart';
import '../../widgets/ui/shared/app_select.dart';
import '../../widgets/ui/shared/app_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class BhattiBatchEditScreen extends StatefulWidget {
  final String batchId;

  const BhattiBatchEditScreen({super.key, required this.batchId});

  @override
  State<BhattiBatchEditScreen> createState() => _BhattiBatchEditScreenState();
}

class _BhattiBatchEditScreenState extends State<BhattiBatchEditScreen> {
  late final BhattiService _bhattiService;

  bool _isLoading = true;
  bool _isSaving = false;
  BhattiBatch? _batch;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _outputController;

  List<Map<String, dynamic>> _rawMaterials = [];
  List<DepartmentStock> _availableMaterials = [];

  String _newRowId() => const Uuid().v4();

  @override
  void initState() {
    super.initState();
    _bhattiService = context.read<BhattiService>();
    _outputController = TextEditingController();
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
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Batch
      _batch = await _bhattiService.getBhattiBatchById(widget.batchId);

      if (_batch == null) {
        throw Exception("Batch not found");
      }

      // 2. Fetch Available Materials for Dropdowns
      final stocks = await _bhattiService.getDepartmentStocks(
        _batch!.bhattiName,
      );
      // Filter for Raw Materials only?
      // Theoretically, they can consume anything in stock.

      _availableMaterials = stocks;

      // 3. Pre-fill Form
      _outputController.text = _batch!.outputBoxes.toString();
      _rawMaterials = _batch!.rawMaterialsConsumed
          .map(
            (e) => {
              'uid': _newRowId(),
              'materialId': e['materialId'],
              'materialName':
                  e['name'] ??
                  e['materialName'], // handled safely in service now
              'quantity': e['quantity'],
              'unit': e['unit'],
            },
          )
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        AppDialog.show(
          context,
          title: 'Error',
          content: Text('Error loading data: $e'),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text('OK')),
          ],
        );
      }
    }
  }

  void _addMaterial() {
    setState(() {
      _rawMaterials.add({
        'uid': _newRowId(),
        'materialId': null,
        'quantity': 0.0,
        'unit': 'KG',
      });
    });
  }

  void _removeMaterial(int index) {
    setState(() {
      _rawMaterials.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Materials
    if (_rawMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one material")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await _bhattiService.updateBhattiBatch(
        batchId: widget.batchId,
        newRawMaterials: _rawMaterials,
        newOutputBoxes: int.tryParse(_outputController.text) ?? 0,
        newFuelConsumption: 0.0, // Ignoring for now as it's daily
      );
      if (!updated) {
        throw Exception('Batch update failed');
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch updated successfully')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppDialog.show(
          context,
          title: 'Error',
          content: Text('Error updating batch: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }
    }
  }

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Edit Batch',
            subtitle: 'Batch #${_batch?.batchNumber}',
            onBack: () => context.pop(),
            actions: [
              IconButton(
                onPressed: () => context.push(
                  '/dashboard/bhatti/batch/${widget.batchId}/audit',
                ),
                icon: const Icon(Icons.fact_check_outlined),
                tooltip: 'View Consumption Audit',
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Batch Info
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Product: ${_batch?.targetProductName}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          AppInput(
                            label: "Output (Boxes)",
                            controller: _outputController,
                            keyboardType: TextInputType.number,
                            hintText: '0',
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Materials
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Raw Materials",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : null,
                          child: AppButton(
                            label: "Add Material",
                            icon: Icons.add,
                            variant: ButtonVariant.secondary,
                            onPressed: _addMaterial,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._rawMaterials.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return AppCard(
                        key: ValueKey(item['uid'] ?? index),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: AppSelect<String>(
                                    label: 'Material',
                                    value: item['materialId'],
                                    items: _availableMaterials
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s.productId,
                                            child: Text(
                                              s.productName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        item['materialId'] = val;
                                        item['materialName'] =
                                            _availableMaterials
                                                .firstWhere(
                                                  (s) => s.productId == val,
                                                )
                                                .productName;
                                      });
                                    },
                                    validator: (val) =>
                                        val == null ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () => _removeMaterial(index),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.error,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppInput(
                              label: 'Qty (KG)',
                              initialValue: item['quantity']?.toString(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                NormalizedNumberInputFormatter.decimal(
                                  keepZeroWhenEmpty: true,
                                ),
                              ],
                              onChanged: (val) => item['quantity'] =
                                  double.tryParse(val) ?? 0.0,
                              validator: (val) =>
                                  (val == null ||
                                      val.isEmpty ||
                                      double.tryParse(val) == 0)
                                  ? 'Invalid'
                                  : null,
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    AppButton(
                      label: "Save Changes",
                      onPressed: _save,
                      isLoading: _isSaving,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 48), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
