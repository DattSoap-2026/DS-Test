import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/inventory_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/tank_service.dart';
import '../../../utils/normalized_number_input_formatter.dart';
import '../../../utils/storage_unit_helper.dart';

class PostGrnDistributionProduct {
  final String productId;
  final String productName;
  final double availableQty;
  final String unit;

  const PostGrnDistributionProduct({
    required this.productId,
    required this.productName,
    required this.availableQty,
    required this.unit,
  });
}

class PostGrnDistributionDialog extends StatefulWidget {
  final String referenceId;
  final String referenceNumber;
  final String operatorId;
  final String operatorName;
  final List<PostGrnDistributionProduct> products;
  final List<String>? departments;

  const PostGrnDistributionDialog({
    super.key,
    required this.referenceId,
    required this.referenceNumber,
    required this.operatorId,
    required this.operatorName,
    required this.products,
    this.departments,
  });

  @override
  State<PostGrnDistributionDialog> createState() =>
      _PostGrnDistributionDialogState();
}

class _StorageAllocationDraft {
  String? productId;
  String? storageUnitId;
  final TextEditingController qtyController;

  _StorageAllocationDraft({this.productId, required this.qtyController});

  void dispose() => qtyController.dispose();
}

class _DepartmentAllocationDraft {
  String? productId;
  String? department;
  final TextEditingController qtyController;

  _DepartmentAllocationDraft({
    this.productId,
    this.department,
    required this.qtyController,
  });

  void dispose() => qtyController.dispose();
}

class _PostGrnDistributionDialogState extends State<PostGrnDistributionDialog> {
  static const double _eps = 1e-6;
  static const List<String> _defaultDepartments = <String>[
    'Sona Bhatti',
    'Gita Bhatti',
    'Production',
    'Packing',
  ];

  final List<_StorageAllocationDraft> _storageDrafts =
      <_StorageAllocationDraft>[];
  final List<_DepartmentAllocationDraft> _departmentDrafts =
      <_DepartmentAllocationDraft>[];
  final List<String> _departmentOptions = <String>[];

  final Map<String, PostGrnDistributionProduct> _productsById =
      <String, PostGrnDistributionProduct>{};
  final Map<String, Tank> _storageById = <String, Tank>{};

  List<Tank> _allStorageUnits = <Tank>[];
  bool _isLoadingStorage = true;
  bool _isLoadingDepartments = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final p in widget.products) {
      _productsById[p.productId] = p;
    }
    _loadDepartmentOptions();
    _loadStorageUnits();
    _addStorageDraft();
  }

  @override
  void dispose() {
    for (final row in _storageDrafts) {
      row.dispose();
    }
    for (final row in _departmentDrafts) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDepartmentOptions() async {
    final provided = (widget.departments ?? const <String>[])
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    if (provided.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _departmentOptions
          ..clear()
          ..addAll(provided);
        _isLoadingDepartments = false;
      });
      return;
    }

    try {
      final service = context.read<SettingsService>();
      final departments = await service.getDepartments();
      final options = departments
          .where((dept) => dept.isActive)
          .map((dept) => dept.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      if (options.isEmpty) {
        options.addAll(_defaultDepartments);
      }

      if (!mounted) return;
      setState(() {
        _departmentOptions
          ..clear()
          ..addAll(options);
        _isLoadingDepartments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _departmentOptions
          ..clear()
          ..addAll(_defaultDepartments);
        _isLoadingDepartments = false;
      });
    }
  }

  Future<void> _loadStorageUnits() async {
    try {
      final service = context.read<TankService>();
      final units = await service.getTanks();
      if (!mounted) return;
      units.sort(Tank.compareByDisplayOrder);
      setState(() {
        _allStorageUnits = units;
        _storageById
          ..clear()
          ..addEntries(units.map((t) => MapEntry(t.id, t)));
        _isLoadingStorage = false;
        _normalizeStorageSelections();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingStorage = false);
    }
  }

  void _normalizeStorageSelections() {
    for (final draft in _storageDrafts) {
      final options = _storageOptionsForProduct(draft.productId);
      if (options.isEmpty) {
        draft.storageUnitId = null;
        continue;
      }
      if (draft.storageUnitId == null ||
          !options.any((u) => u.id == draft.storageUnitId)) {
        draft.storageUnitId = options.first.id;
      }
    }
  }

  void _addStorageDraft() {
    final firstProductId = widget.products.isNotEmpty
        ? widget.products.first.productId
        : null;
    final draft = _StorageAllocationDraft(
      productId: firstProductId,
      qtyController: TextEditingController(text: '0'),
    );
    final options = _storageOptionsForProduct(firstProductId);
    if (options.isNotEmpty) {
      draft.storageUnitId = options.first.id;
    }
    setState(() => _storageDrafts.add(draft));
  }

  void _addDepartmentDraft() {
    final firstProductId = widget.products.isNotEmpty
        ? widget.products.first.productId
        : null;
    final firstDepartment = _departmentOptions.isNotEmpty
        ? _departmentOptions.first
        : null;
    setState(() {
      _departmentDrafts.add(
        _DepartmentAllocationDraft(
          productId: firstProductId,
          department: firstDepartment,
          qtyController: TextEditingController(text: '0'),
        ),
      );
    });
  }

  void _removeStorageDraft(int index) {
    final draft = _storageDrafts.removeAt(index);
    draft.dispose();
    setState(() {});
  }

  void _removeDepartmentDraft(int index) {
    final draft = _departmentDrafts.removeAt(index);
    draft.dispose();
    setState(() {});
  }

  double _readQty(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0.0;
  }

  void _replaceStorageDrafts(List<_StorageAllocationDraft> drafts) {
    for (final existing in _storageDrafts) {
      existing.dispose();
    }
    _storageDrafts
      ..clear()
      ..addAll(drafts);
  }

  void _autoAllocateStorage() {
    if (_isSubmitting) return;
    if (_allStorageUnits.isEmpty) {
      _showError('No tank/godown units available for allocation.');
      return;
    }
    if (widget.products.isEmpty) {
      _showError('No received products available for allocation.');
      return;
    }

    final departmentAllocated = <String, double>{};
    for (final row in _departmentDrafts) {
      final productId = row.productId;
      if (productId == null || !_productsById.containsKey(productId)) continue;
      final qty = _readQty(row.qtyController);
      if (qty <= _eps) continue;
      departmentAllocated[productId] =
          (departmentAllocated[productId] ?? 0) + qty;
    }

    final newDrafts = <_StorageAllocationDraft>[];
    final leftovers = <String>[];

    for (final product in widget.products) {
      var remainingQty =
          product.availableQty - (departmentAllocated[product.productId] ?? 0);
      if (remainingQty <= _eps) continue;

      final compatibleUnits =
          _storageOptionsForProduct(product.productId)
              .where(
                (unit) =>
                    (unit.capacity - unit.currentStock)
                        .clamp(0.0, double.infinity)
                        .toDouble() >
                    _eps,
              )
              .toList()
            ..sort(Tank.compareByDisplayOrder);

      for (final unit in compatibleUnits) {
        if (remainingQty <= _eps) break;
        final freeCapacity = (unit.capacity - unit.currentStock)
            .clamp(0.0, double.infinity)
            .toDouble();
        if (freeCapacity <= _eps) continue;

        final allocatedQty = remainingQty < freeCapacity
            ? remainingQty
            : freeCapacity;
        if (allocatedQty <= _eps) continue;

        final draft = _StorageAllocationDraft(
          productId: product.productId,
          qtyController: TextEditingController(text: _toQtyText(allocatedQty)),
        )..storageUnitId = unit.id;
        newDrafts.add(draft);
        remainingQty -= allocatedQty;
      }

      if (remainingQty > _eps) {
        leftovers.add(
          '${product.productName}: ${_toQtyText(remainingQty)} ${product.unit}',
        );
      }
    }

    if (newDrafts.isEmpty) {
      _showError(
        'Auto allocation could not find capacity in compatible tanks/godowns.',
      );
      return;
    }

    setState(() {
      _replaceStorageDrafts(newDrafts);
      _normalizeStorageSelections();
    });

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (leftovers.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Auto allocation applied successfully.')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Auto allocation partial. Unallocated: ${leftovers.join(' | ')}',
        ),
      ),
    );
  }

  List<Tank> _storageOptionsForProduct(String? productId) {
    if (productId == null) return _allStorageUnits;
    final strict = _allStorageUnits
        .where((unit) => unit.materialId == productId)
        .toList();
    return strict;
  }

  String _toQtyText(double value) {
    if ((value - value.roundToDouble()).abs() < 0.000001) {
      return value.round().toString();
    }
    return value.toStringAsFixed(3);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final storageOps = <Map<String, dynamic>>[];
    final departmentOps = <Map<String, dynamic>>[];
    final allocatedByProduct = <String, double>{};
    final allocatedByStorage = <String, double>{};

    for (var i = 0; i < _storageDrafts.length; i++) {
      final row = _storageDrafts[i];
      final rowNo = i + 1;
      final productId = row.productId;
      final storageId = row.storageUnitId;
      final qty = double.tryParse(row.qtyController.text) ?? 0;

      if (qty <= _eps) continue;
      if (productId == null || !_productsById.containsKey(productId)) {
        _showError('Storage row $rowNo: select a valid product.');
        return;
      }
      if (storageId == null || !_storageById.containsKey(storageId)) {
        _showError('Storage row $rowNo: select a valid tank/godown.');
        return;
      }

      final storage = _storageById[storageId]!;
      if (storage.materialId != productId) {
        _showError(
          'Storage row $rowNo: ${storage.name} is mapped to ${storage.materialName}.',
        );
        return;
      }

      storageOps.add({
        'productId': productId,
        'storageId': storageId,
        'quantity': qty,
      });
      allocatedByProduct[productId] =
          (allocatedByProduct[productId] ?? 0) + qty;
      allocatedByStorage[storageId] =
          (allocatedByStorage[storageId] ?? 0) + qty;
    }

    for (var i = 0; i < _departmentDrafts.length; i++) {
      final row = _departmentDrafts[i];
      final rowNo = i + 1;
      final productId = row.productId;
      final dept = row.department;
      final qty = double.tryParse(row.qtyController.text) ?? 0;

      if (qty <= _eps) continue;
      if (productId == null || !_productsById.containsKey(productId)) {
        _showError('Department row $rowNo: select a valid product.');
        return;
      }
      if (dept == null || dept.trim().isEmpty) {
        _showError('Department row $rowNo: select a department.');
        return;
      }

      departmentOps.add({
        'productId': productId,
        'department': dept.trim(),
        'quantity': qty,
      });
      allocatedByProduct[productId] =
          (allocatedByProduct[productId] ?? 0) + qty;
    }

    if (storageOps.isEmpty && departmentOps.isEmpty) {
      _showError('Enter at least one allocation quantity greater than 0.');
      return;
    }

    for (final entry in allocatedByProduct.entries) {
      final product = _productsById[entry.key]!;
      if (entry.value > product.availableQty + _eps) {
        _showError(
          'Over allocation for ${product.productName}. '
          'Allocated: ${_toQtyText(entry.value)} ${product.unit}, '
          'Available: ${_toQtyText(product.availableQty)} ${product.unit}.',
        );
        return;
      }
    }

    for (final entry in allocatedByStorage.entries) {
      final storage = _storageById[entry.key]!;
      final remaining = (storage.capacity - storage.currentStock)
          .clamp(0.0, double.infinity)
          .toDouble();
      if (entry.value > remaining + _eps) {
        _showError(
          'Exceeds capacity for ${storage.name}. '
          'Requested: ${_toQtyText(entry.value)} ${StorageUnitHelper.tankDisplayUnit(storage.unit)}, '
          'Remaining: ${_toQtyText(remaining)} ${StorageUnitHelper.tankDisplayUnit(storage.unit)}.',
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final tankService = context.read<TankService>();
      final inventoryService = context.read<InventoryService>();

      var storageSuccess = 0;
      for (final op in storageOps) {
        final storage = _storageById[op['storageId'] as String]!;
        final quantity = (op['quantity'] as num).toDouble();
        final ok = await tankService.transferToTank(
          sourceProductId: op['productId'] as String,
          destinationTankId: storage.id,
          destinationTankName: storage.name,
          quantity: quantity,
          operatorId: widget.operatorId,
          operatorName: widget.operatorName,
          unit: storage.unit,
          purchaseOrderId: widget.referenceId,
          supplierId: 'purchase_order',
          supplierName: widget.referenceNumber,
        );
        if (!ok) {
          throw Exception('Transfer failed for ${storage.name}');
        }
        storageSuccess++;
      }

      var departmentSuccess = 0;
      final byDepartment = <String, List<Map<String, dynamic>>>{};
      for (final op in departmentOps) {
        final dept = op['department'] as String;
        final productId = op['productId'] as String;
        final product = _productsById[productId]!;
        byDepartment.putIfAbsent(dept, () => <Map<String, dynamic>>[]);
        byDepartment[dept]!.add({
          'productId': productId,
          'productName': product.productName,
          'quantity': (op['quantity'] as num).toDouble(),
          'unit': product.unit,
        });
      }

      for (final entry in byDepartment.entries) {
        final ok = await inventoryService.transferToDepartment(
          departmentName: entry.key,
          items: entry.value,
          issuedByUserId: widget.operatorId,
          issuedByUserName: widget.operatorName,
          referenceId: widget.referenceId,
          notes: 'GRN Distribution: ${widget.referenceNumber}',
        );
        if (!ok) {
          throw Exception('Department issue failed for ${entry.key}');
        }
        departmentSuccess++;
      }

      if (!mounted) return;
      Navigator.of(context).pop({
        'storageTransfers': storageSuccess,
        'departmentTransfers': departmentSuccess,
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Distribution failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height * 0.9;
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width > 980 ? 940.0 : width * 0.95;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SizedBox(
        width: dialogWidth,
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.alt_route_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distribute Received Stock',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reference: ${widget.referenceNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoadingStorage
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReceivedSummary(theme),
                          const SizedBox(height: 16),
                          _buildStorageSection(theme),
                          const SizedBox(height: 16),
                          _buildDepartmentSection(theme),
                        ],
                      ),
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Skip'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _isSubmitting ? 'Applying...' : 'Apply Distribution',
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

  Widget _buildReceivedSummary(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Received Quantities',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.products.map((p) {
                return Chip(
                  label: Text(
                    '${p.productName}: ${_toQtyText(p.availableQty)} ${p.unit}',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Tank / Godown Allocation',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _autoAllocateStorage,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: const Text('Auto Allocate'),
                ),
                TextButton.icon(
                  onPressed: _addStorageDraft,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_storageDrafts.isEmpty)
              Text(
                'No storage allocation rows.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ..._storageDrafts.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;
              final options = _storageOptionsForProduct(row.productId);
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: row.productId,
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: widget.products
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p.productId,
                                child: Text(p.productName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            row.productId = value;
                            final nextOptions = _storageOptionsForProduct(
                              value,
                            );
                            row.storageUnitId = nextOptions.isNotEmpty
                                ? nextOptions.first.id
                                : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: row.storageUnitId,
                        decoration: const InputDecoration(
                          labelText: 'Tank / Godown',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: options
                            .map(
                              (u) => DropdownMenuItem<String>(
                                value: u.id,
                                child: Text(
                                  '${u.name} (${u.type.toUpperCase()} • ${u.department})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => row.storageUnitId = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: row.qtyController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          NormalizedNumberInputFormatter.decimal(
                            keepZeroWhenEmpty: true,
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove row',
                      onPressed: () => _removeStorageDraft(idx),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                      ),
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

  Widget _buildDepartmentSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Department Issue (Optional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isLoadingDepartments ? null : _addDepartmentDraft,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_departmentDrafts.isEmpty)
              Text(
                'No department allocation rows.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (_isLoadingDepartments)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ..._departmentDrafts.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;
              final selectedDepartment = _departmentOptions.contains(
                row.department,
              )
                  ? row.department
                  : null;
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: row.productId,
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: widget.products
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p.productId,
                                child: Text(p.productName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => row.productId = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _departmentOptions
                            .map(
                              (d) => DropdownMenuItem<String>(
                                value: d,
                                child: Text(d),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => row.department = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: row.qtyController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          NormalizedNumberInputFormatter.decimal(
                            keepZeroWhenEmpty: true,
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove row',
                      onPressed: () => _removeDepartmentDraft(idx),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                      ),
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
