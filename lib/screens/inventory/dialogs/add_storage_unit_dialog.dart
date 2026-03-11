import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/tank_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/products_service.dart';
import '../../../data/repositories/tank_repository.dart';
import '../../../models/types/product_types.dart';
import '../../../utils/responsive.dart';
import '../widgets/storage_themes.dart';
import '../widgets/tank_visualization.dart';
import '../widgets/godown_visualization.dart';
import '../../../widgets/ui/glass_container.dart';
import '../../../widgets/ui/custom_text_field.dart';
import '../../../widgets/ui/custom_button.dart';
import '../../../widgets/ui/themed_filter_chip.dart';
import '../../../utils/storage_unit_helper.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AddStorageUnitDialog extends StatefulWidget {
  final TankRepository tankRepo;
  final Tank? initialTank;

  const AddStorageUnitDialog({
    super.key,
    required this.tankRepo,
    this.initialTank,
  });

  // Predefined Bhatti Departments
  static const List<String> bhattiDepartments = [
    'Gita Bhatti',
    'Sona Bhatti',
    'Production',
    'Sales',
    'Vehicle Maintenance',
    'Administration',
  ];

  @override
  State<AddStorageUnitDialog> createState() => _AddStorageUnitDialogState();
}

class _AddStorageUnitDialogState extends State<AddStorageUnitDialog> {
  final _formKey = GlobalKey<FormState>();

  // Storage Type
  String _type = 'tank'; // 'tank' or 'godown'

  // Form Fields
  final _nameController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedUnit; // Team/Sub-unit code
  String? _selectedMaterialId;
  String? _selectedMaterialName;
  final _capacityController = TextEditingController();
  final _currentStockController = TextEditingController(text: '0');
  final _minStockLevelController = TextEditingController();
  final _maxBagsController = TextEditingController();
  String _unit = StorageUnitHelper.tonUnit;
  String _status = 'active';

  // Loading State
  bool _isSubmitting = false;
  bool _isLoadingDepartments = true;
  bool _isLoadingMaterials = true;

  // Services
  late SettingsService _settingsService;
  late ProductsService _productsService;

  // Dynamic departments from master data
  List<OrgDepartment> _departmentsData = [];
  List<String> get _departments {
    final apiDepts = _departmentsData
        .where((d) => d.isActive)
        .map((d) => d.name)
        .toList();
    // Combine API departments with Manual Bhatti Departments and remove duplicates
    return {...apiDepts, ...AddStorageUnitDialog.bhattiDepartments}.toList()
      ..sort();
  }

  // Get units/teams for selected department
  List<DeptTeam> get _availableUnits {
    if (_selectedDepartment == null) return [];
    final dept = _departmentsData.firstWhere(
      (d) => d.name == _selectedDepartment,
      orElse: () => OrgDepartment(
        id: '',
        code: '',
        name: '',
        createdAt: '',
        updatedAt: '',
      ),
    );
    return dept.teams;
  }

  List<Product> _materialOptions = [];
  static const List<String> _statusOptions = <String>[
    'active',
    'low-stock',
    'critical',
    'maintenance',
    'inactive',
  ];

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _productsService = context.read<ProductsService>();
    _loadDepartments();
    _loadMaterials();

    if (widget.initialTank != null) {
      final t = widget.initialTank!;
      _type = t.type;
      _nameController.text = t.name;
      _selectedDepartment = t.department;
      _selectedUnit = t.assignedUnit;
      _selectedMaterialId = t.materialId;
      _selectedMaterialName = t.materialName;
      _capacityController.text = t.capacity.toString();
      _currentStockController.text = t.currentStock.toString();
      _minStockLevelController.text = t.minStockLevel.toString();
      if (t.type == 'godown' && t.maxBags != null) {
        _maxBagsController.text = t.maxBags.toString();
      }
      _unit = StorageUnitHelper.tonUnit;
      _status = t.status;
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final depts = await _settingsService.getDepartments();
      if (mounted) {
        setState(() {
          _departmentsData = depts;
          _isLoadingDepartments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDepartments = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading departments: $e')),
        );
      }
    }
  }

  bool _isEligibleStorageMaterial(Product product) {
    final itemTypeRaw = product.itemType.value.trim();
    if (itemTypeRaw.isEmpty) return false;

    final canonicalItemType = ProductType.fromString(itemTypeRaw).value;

    const allowedTypes = {'Raw Material', 'Oils & Liquids'};

    return allowedTypes.contains(canonicalItemType);
  }

  void _syncMaterialSelectionWithOptions() {
    if (_materialOptions.isEmpty) return;

    Product? matched;
    final selectedId = _selectedMaterialId;
    final selectedName = _selectedMaterialName;

    if (selectedId != null && selectedId.isNotEmpty) {
      for (final product in _materialOptions) {
        if (product.id == selectedId) {
          matched = product;
          break;
        }
      }
    }

    if (matched == null &&
        selectedName != null &&
        selectedName.trim().isNotEmpty) {
      final needle = selectedName.trim().toLowerCase();
      for (final product in _materialOptions) {
        if (product.name.trim().toLowerCase() == needle) {
          matched = product;
          break;
        }
      }
    }

    if (matched != null) {
      _selectedMaterialId = matched.id;
      _selectedMaterialName = matched.name;
      return;
    }

    // Strict mode: clear any disallowed legacy material selection.
    _selectedMaterialId = null;
    _selectedMaterialName = null;
  }

  List<DropdownMenuItem<String>> _buildMaterialDropdownItems() {
    return _materialOptions
        .map(
          (product) => DropdownMenuItem<String>(
            value: product.id,
            child: Text(product.name),
          ),
        )
        .toList();
  }

  Future<void> _loadMaterials() async {
    try {
      final products = await _productsService.getProducts(status: 'active');
      final filtered = products.where(_isEligibleStorageMaterial).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final seen = <String>{};
      final unique = <Product>[];
      for (final product in filtered) {
        if (seen.add(product.id)) {
          unique.add(product);
        }
      }

      if (!mounted) return;
      setState(() {
        _materialOptions = unique;
        _syncMaterialSelectionWithOptions();
        _isLoadingMaterials = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMaterials = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading materials: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _currentStockController.dispose();
    _minStockLevelController.dispose();
    _maxBagsController.dispose();
    super.dispose();
  }

  Widget _buildPreview() {
    final theme = getThemeForDepartment(_selectedDepartment);
    final capacity = double.tryParse(_capacityController.text) ?? 100.0;
    final current = double.tryParse(_currentStockController.text) ?? 0.0;
    final fillLevel = capacity > 0
        ? (current / capacity * 100.0).clamp(0.0, 100.0)
        : 0.0;
    final maxBags = int.tryParse(_maxBagsController.text) ?? 100;
    final bags = maxBags > 0 ? (current / (capacity / maxBags)).round() : 0;
    final usagePercent = maxBags > 0 ? (bags / maxBags * 100.0) : 0.0;
    final appTheme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      color: theme.primary.withValues(alpha: 0.05),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'UNIT PREVIEW'
                          : _nameController.text.toUpperCase(),
                      style: appTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _selectedMaterialName?.toUpperCase() ?? 'NO MATERIAL',
                      style: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _status == 'active'
                      ? AppColors.success.withValues(alpha: 0.1)
                      : appTheme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _status.toUpperCase(),
                  style: TextStyle(
                    color: _status == 'active'
                        ? AppColors.success
                        : appTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: Responsive.clamp(
                context,
                min: 160,
                max: 220,
                ratio: 0.22,
              ),
              maxHeight: Responsive.clamp(
                context,
                min: 180,
                max: 260,
                ratio: 0.26,
              ),
            ),
            child: _type == 'tank'
                ? TankVisualization(
                    fillLevel: fillLevel,
                    liquidColor: theme.liquidColor,
                    label: current.toStringAsFixed(1),
                    unitLabel: StorageUnitHelper.tankDisplayUnit(_unit),
                  )
                : GodownVisualization(
                    usagePercent: usagePercent,
                    bagColor: theme.primary,
                  ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _previewMetric(
                'CAPACITY',
                '${capacity.toStringAsFixed(2)} ${StorageUnitHelper.tonUnit}',
              ),
              _previewMetric(
                'INITIAL',
                '${current.toStringAsFixed(2)} ${StorageUnitHelper.tonUnit}',
              ),
              _previewMetric(
                'FILL',
                '${fillLevel.toStringAsFixed(0)}%',
                isAccent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewMetric(String label, String value, {bool isAccent = false}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: isAccent ? AppColors.success : theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (_selectedMaterialId == null ||
          _selectedMaterialName == null ||
          _selectedDepartment == null) {
        throw Exception('Please select material and department');
      }

      final capacity = double.tryParse(_capacityController.text);
      if (capacity == null || capacity <= 0) {
        throw Exception('Invalid capacity');
      }
      final currentStock =
          double.tryParse(
            _currentStockController.text.isEmpty
                ? '0'
                : _currentStockController.text,
          ) ??
          0.0;
      final fillLevel = capacity > 0 ? (currentStock / capacity * 100) : 0.0;
      final parsedMaxBags = int.tryParse(_maxBagsController.text);
      final maxBags =
          (_type == 'godown' && parsedMaxBags != null && parsedMaxBags > 0)
          ? parsedMaxBags
          : null;
      final bags = (_type == 'godown' && maxBags != null)
          ? ((currentStock / capacity) * maxBags).round().clamp(0, maxBags)
          : null;

      final tankData = Tank(
        id: widget.initialTank?.id ?? '',
        name: _nameController.text,
        materialId: _selectedMaterialId!,
        materialName: _selectedMaterialName!,
        capacity: capacity,
        currentStock: currentStock,
        fillLevel: fillLevel,
        status: _status,
        unit: StorageUnitHelper.tonUnit,
        updatedAt: '',
        createdAt: widget.initialTank?.createdAt ?? '',
        department: _selectedDepartment!,
        assignedUnit: _selectedUnit,
        type: _type,
        bags: bags,
        maxBags: maxBags,
        minStockLevel: double.tryParse(_minStockLevelController.text) ?? 0.0,
        isBhattiSourced: widget.initialTank?.isBhattiSourced ?? false,
      );

      if (widget.initialTank != null) {
        await widget.tankRepo.updateTank(tankData);
      } else {
        await widget.tankRepo.saveTank(tankData);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialTank != null
                  ? 'Storage Unit Updated Successfully'
                  : 'Storage Unit Created Successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating unit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: Responsive.dialogInsetPadding(context),
      child: ConstrainedBox(
        constraints: Responsive.dialogConstraints(
          context,
          maxWidth: 980,
          maxHeightFactor: 0.92,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 780;
            final isNarrowDialog = constraints.maxWidth < 500;
            return GlassContainer(
              width: double.infinity,
              borderRadius: 32,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.initialTank != null
                                    ? 'Edit Storage Unit'
                                    : 'Add Storage Unit',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Configure storage parameters and material',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: theme
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildForm(isNarrow: false),
                                ),
                                const SizedBox(width: 32),
                                const VerticalDivider(),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Text(
                                        'LIVE PREVIEW',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildPreview(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildForm(isNarrow: isNarrowDialog),
                                const SizedBox(height: 32),
                                const Divider(),
                                const SizedBox(height: 24),
                                Text(
                                  'LIVE PREVIEW',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildPreview(),
                              ],
                            ),
                    ),
                  ),

                  // Footer actions
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        CustomButton(
                          label: 'CANCEL',
                          onPressed: () => Navigator.of(context).pop(),
                          variant: ButtonVariant.outline,
                        ),
                        CustomButton(
                          label: widget.initialTank != null
                              ? 'UPDATE UNIT'
                              : 'CREATE UNIT',
                          onPressed: _submit,
                          isLoading: _isSubmitting,
                          isDense: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm({required bool isNarrow}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selector
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTypeChip('tank', Icons.water_drop_rounded, 'Liquid Tank'),
                _buildTypeChip('godown', Icons.warehouse_rounded, 'Dry Godown'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Basic Info
          CustomTextField(
            label: 'Unit Name',
            hintText: 'e.g., Tank A1',
            controller: _nameController,
            prefixIcon: Icons.badge_outlined,
            onChanged: (v) => setState(() {}),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          // Department & Unit
          _buildAdaptiveTwoColumn(
            isNarrow: isNarrow,
            first: _buildGlassDropdown<String>(
              label: 'Department',
              value: _selectedDepartment,
              items: _departments.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              onChanged: _isLoadingDepartments
                  ? (String? v) {}
                  : (String? v) {
                      setState(() {
                        _selectedDepartment = v;
                        _selectedUnit = null;
                      });
                    },
              icon: Icons.business_rounded,
            ),
            second: _selectedDepartment != null && _availableUnits.isNotEmpty
                ? _buildGlassDropdown<String>(
                    label: 'Unit / Team',
                    value: _selectedUnit,
                    items: _availableUnits.map((team) {
                      return DropdownMenuItem<String>(
                        value: team.code,
                        child: Text(team.name),
                      );
                    }).toList(),
                    onChanged: (v) {
                      final team = _availableUnits.cast<DeptTeam?>().firstWhere(
                        (u) => u?.code == v,
                        orElse: () => null,
                      );
                      if (team == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unit not found')),
                        );
                        return;
                      }
                      setState(() => _selectedUnit = team.code);
                    },
                    icon: Icons.group_rounded,
                  )
                : const SizedBox.shrink(),
            allowSecondCollapse: true,
          ),
          const SizedBox(height: 24),

          // Material & Status
          _buildAdaptiveTwoColumn(
            isNarrow: isNarrow,
            first: _buildGlassDropdown<String>(
              label: 'Material',
              value: _selectedMaterialId,
              items: _buildMaterialDropdownItems(),
              hint: _isLoadingMaterials
                  ? 'Loading materials...'
                  : (_materialOptions.isEmpty
                        ? 'No oils/raw materials found'
                        : 'Select material'),
              onChanged: _isLoadingMaterials
                  ? (_) {}
                  : (v) {
                      Product? selected;
                      for (final product in _materialOptions) {
                        if (product.id == v) {
                          selected = product;
                          break;
                        }
                      }
                      setState(() {
                        _selectedMaterialId = v;
                        _selectedMaterialName =
                            selected?.name ?? _selectedMaterialName;
                      });
                    },
              icon: Icons.category_rounded,
            ),
            second: _buildGlassDropdown<String>(
              label: 'Status',
              value: _status,
              items: _statusOptions.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              onChanged: (v) => setState(() => _status = v!),
              icon: Icons.info_outline_rounded,
            ),
          ),
          const SizedBox(height: 24),

          // Capacity & Stock
          _buildAdaptiveTwoColumn(
            isNarrow: isNarrow,
            first: CustomTextField(
              label: 'Total Capacity',
              controller: _capacityController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.straighten_rounded,
              onChanged: (v) => setState(() {}),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            second: _buildGlassDropdown<String>(
              label: 'Unit',
              value: _unit,
              items: const [
                DropdownMenuItem<String>(
                  value: StorageUnitHelper.tonUnit,
                  child: Text(StorageUnitHelper.tonUnit),
                ),
              ],
              onChanged: (_) {},
              icon: Icons.scale_rounded,
            ),
          ),
          const SizedBox(height: 24),

          _buildAdaptiveTwoColumn(
            isNarrow: isNarrow,
            first: CustomTextField(
              label: 'Initial Stock',
              controller: _currentStockController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.inventory_rounded,
              readOnly: widget.initialTank != null,
              onChanged: (v) => setState(() {}),
            ),
            second: CustomTextField(
              label: 'Min Alert level',
              controller: _minStockLevelController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.warning_amber_rounded,
              onChanged: (v) => setState(() {}),
            ),
          ),

          if (_type == 'godown') ...[
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Max Bags Capacity',
              controller: _maxBagsController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.apps_rounded,
              onChanged: (v) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdaptiveTwoColumn({
    required bool isNarrow,
    required Widget first,
    required Widget second,
    bool allowSecondCollapse = false,
  }) {
    if (allowSecondCollapse && second is SizedBox) {
      return first;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = isNarrow || constraints.maxWidth < 760;
        if (stack) {
          return Column(
            children: [
              first,
              const SizedBox(height: 16),
              second,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Widget _buildTypeChip(String value, IconData icon, String label) {
    final isSelected = _type == value;
    final theme = Theme.of(context);
    return ThemedFilterChip(
      label: label,
      selected: isSelected,
      onSelected: () {
        if (!isSelected) {
          setState(() {
            _type = value;
            _unit = StorageUnitHelper.tonUnit;
          });
        }
      },
      leadingIcon: icon,
      leadingIconSize: 16,
      textStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildGlassDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
    String? hint,
  }) {
    final theme = Theme.of(context);
    final dedupedItems = <DropdownMenuItem<T>>[];
    for (final item in items) {
      final alreadyExists = dedupedItems.any(
        (existing) => existing.value == item.value,
      );
      if (!alreadyExists) {
        dedupedItems.add(item);
      }
    }
    final hasSelectedValue =
        value != null && dedupedItems.any((item) => item.value == value);
    final T? safeValue = hasSelectedValue ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: 16,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: safeValue,
              isExpanded: true,
              icon: Icon(icon, size: 20, color: theme.colorScheme.primary),
              hint: hint == null ? null : Text(hint),
              items: dedupedItems,
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: theme.colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }
}
