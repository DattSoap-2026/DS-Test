import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/bhatti_service.dart';
import '../../services/tank_service.dart';
import '../../services/formulas_service.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart';
import '../../models/types/user_types.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../utils/access_guard.dart';
import '../../utils/mobile_header_typography.dart';
import '../../utils/storage_unit_helper.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import '../../widgets/reports/report_export_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

String normalizeBhattiMaterialToken(String? value) {
  final normalized = (value ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return normalized;
}

Set<String> bhattiMaterialKeys({String? id, String? name}) {
  final keys = <String>{};
  final normalizedId = (id ?? '').trim().toLowerCase();
  final normalizedName = normalizeBhattiMaterialToken(name);
  if (normalizedId.isNotEmpty) keys.add('id:$normalizedId');
  if (normalizedName.isNotEmpty) keys.add('name:$normalizedName');
  return keys;
}

bool bhattiMaterialsOverlap({
  String? firstId,
  String? firstName,
  String? secondId,
  String? secondName,
}) {
  final first = bhattiMaterialKeys(id: firstId, name: firstName);
  final second = bhattiMaterialKeys(id: secondId, name: secondName);
  return first.any(second.contains);
}

bool useInlineFormulaMaterialRowLayoutForWidth(double width) {
  return width < 650;
}

class BhattiCookingScreen extends StatefulWidget {
  const BhattiCookingScreen({super.key});

  @override
  State<BhattiCookingScreen> createState() => _BhattiCookingScreenState();
}

class _BhattiCookingScreenState extends State<BhattiCookingScreen>
    with ReportPdfMixin<BhattiCookingScreen> {
  late final BhattiService _bhattiService;
  late final TankService _tankService;
  late final FormulasService _formulasService;
  late final ProductsService _productsService;

  bool _isLoading = true;
  List<Formula> _formulas = [];
  List<Tank> _tanks = [];
  Map<String, TankLot?> _latestLotsByTankId = {};
  List<Product> _products = [];
  static const Map<String, int> _lockedOutputBoxRules = {'sona': 6, 'gita': 7};

  // UI State
  String _selectedDept = 'Sona'; // 'Sona' or 'Gita'
  bool _shouldShowDeptToggle = true; // Show toggle only if user can access both

  // Consumption Form State
  Formula? _selectedFormula;
  int _batchCount = 1;
  bool _isUpdatingFormula = false;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _tankControllers = {};
  final List<IngredientEntry> _extraIngredients = [];
  final List<Formula> _recentFormulas = [];

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
    _tankService = context.read<TankService>();
    _bhattiService = context.read<BhattiService>();
    _formulasService = context.read<FormulasService>();
    _productsService = context.read<ProductsService>();
    _checkAccess();
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.role.canAccessBhatti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Access Denied: Bhatti operations restricted to authorized roles',
              ),
            ),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    
    // Set department based on user's assigned bhatti or department
    final assignedBhatti = user.assignedBhatti?.toLowerCase().trim() ?? '';
    final department = user.department?.toLowerCase().trim() ?? '';
    
    // Determine which bhatti the user is assigned to
    if (assignedBhatti.contains('gita') || assignedBhatti.contains('geeta') || 
        department.contains('gita') || department.contains('geeta')) {
      _selectedDept = 'Gita';
      _shouldShowDeptToggle = false;
    } else if (assignedBhatti.contains('sona') || department.contains('sona')) {
      _selectedDept = 'Sona';
      _shouldShowDeptToggle = false;
    } else if (user.role == UserRole.admin || user.role == UserRole.owner || 
               user.role == UserRole.productionManager) {
      // Admin, Owner, and Production Manager can see both
      _shouldShowDeptToggle = true;
    } else {
      // Default to Sona if no specific assignment
      _selectedDept = 'Sona';
      _shouldShowDeptToggle = false;
    }
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final formulas = await _formulasService.getFormulas();
      final localTanks = await _tankService.getTanks();
      List<Tank> remoteTanks = const [];
      try {
        remoteTanks = await _tankService.fetchRemoteTanks();
      } catch (_) {
        remoteTanks = const [];
      }
      final tanks = _mergeTanks(local: localTanks, remote: remoteTanks);
      final latestLots = await _loadLatestLotsForTanks(tanks);
      final products = await _productsService.getProducts();
      if (mounted) {
        setState(() {
          _formulas = formulas;
          _tanks = tanks;
          _latestLotsByTankId = latestLots;
          _products = products;
          _isLoading = false;
        });
        if (_selectedFormula != null) {
          _seedTankControllersForFormula();
        }
        _loadRecentFormulas();
        
        // Auto-select formula if only one is available
        _autoSelectFormulaIfSingle();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Tank> _mergeTanks({
    required List<Tank> local,
    required List<Tank> remote,
  }) {
    final mergedById = <String, Tank>{};
    for (final tank in local) {
      mergedById[tank.id] = tank;
    }
    for (final tank in remote) {
      mergedById[tank.id] = tank;
    }
    final merged = mergedById.values.toList();
    merged.sort(Tank.compareByDisplayOrder);
    return merged;
  }

  Future<Map<String, TankLot?>> _loadLatestLotsForTanks(
    List<Tank> tanks,
  ) async {
    final liquidTanks = tanks.where((tank) => tank.type == 'tank').toList();
    if (liquidTanks.isEmpty) return {};

    final entries = await Future.wait(
      liquidTanks.map((tank) async {
        try {
          final lot = await _tankService.getLatestLotForTank(tank.id);
          return MapEntry(tank.id, lot);
        } catch (_) {
          return MapEntry(tank.id, null);
        }
      }),
    );
    return Map<String, TankLot?>.fromEntries(entries);
  }

  Product? get _selectedFormulaProduct {
    final formula = _selectedFormula;
    if (formula == null) return null;
    return _products.cast<Product?>().firstWhere(
      (p) => p?.id == formula.productId,
      orElse: () => null,
    );
  }

  int? get _configuredBoxesPerBatchFromProduct {
    final product = _selectedFormulaProduct;
    if (product == null) return null;
    final configured =
        product.boxesPerBatch ?? product.standardBatchOutputPcs?.round();
    if (configured == null || configured <= 0) return null;
    return configured;
  }

  double? get _configuredBoxWeightKgFromProduct {
    final product = _selectedFormulaProduct;
    if (product == null) return null;
    if (product.unitWeightGrams <= 0) return null;
    return product.unitWeightGrams / 1000;
  }

  int get _selectedBoxesPerBatch {
    final configured = _configuredBoxesPerBatchFromProduct;
    if (configured != null) return configured;
    final key = _selectedDept.toLowerCase() == 'gita' ? 'gita' : 'sona';
    return _lockedOutputBoxRules[key]!;
  }

  int get _calculatedOutputBoxes => _selectedBoxesPerBatch * _batchCount;

  void _onFormulaSelected(Formula? formula) {
    if (formula != null) HapticFeedback.lightImpact();
    setState(() {
      _selectedFormula = formula;
      _resetFormulaControllers();
      _resetTankControllers();
      if (formula != null) {
        for (var item in formula.items) {
          _controllers[item.materialId] = TextEditingController(
            text: (item.quantity * _batchCount).toStringAsFixed(2),
          );
        }
        _seedTankControllersForFormula();
        _saveRecentFormula(formula);
      }
    });
  }

  void _loadRecentFormulas() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((p) {
      final recent =
          p.getStringList('recent_formulas_${_selectedDept.toLowerCase()}') ??
          [];
      final recentFormulas = recent
          .map(
            (id) => _formulas.cast<Formula?>().firstWhere(
              (f) => f?.id == id,
              orElse: () => null,
            ),
          )
          .whereType<Formula>()
          .take(3)
          .toList();
      if (mounted) {
        setState(
          () => _recentFormulas
            ..clear()
            ..addAll(recentFormulas),
        );
      }
    });
  }

  void _saveRecentFormula(Formula formula) {
    SharedPreferences.getInstance().then((prefs) {
      final key = 'recent_formulas_${_selectedDept.toLowerCase()}';
      final recent = prefs.getStringList(key) ?? [];
      recent.remove(formula.id);
      recent.insert(0, formula.id);
      prefs.setStringList(key, recent.take(3).toList());
    });
  }

  Future<void> _copyLastBatch() async {
    try {
      final lastBatch = await _bhattiService.getLastBatch(_selectedDept);
      if (lastBatch == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No previous batch found')),
        );
        return;
      }

      final formula = _formulas.cast<Formula?>().firstWhere(
        (f) => f?.productId == lastBatch.targetProductId,
        orElse: () => null,
      );

      if (formula == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formula not found for last batch')),
        );
        return;
      }

      setState(() {
        _selectedFormula = formula;
        _batchCount = lastBatch.batchCount;
        _resetFormulaControllers();
        _resetTankControllers();

        for (var item in formula.items) {
          _controllers[item.materialId] = TextEditingController(
            text: (item.quantity * _batchCount).toStringAsFixed(2),
          );
        }

        for (var tc in lastBatch.tankConsumptions) {
          final tankId = tc['tankId']?.toString();
          final qty = (tc['quantity'] as num?)?.toDouble() ?? 0.0;
          if (tankId != null && qty > 0) {
            _tankControllers[tankId] = TextEditingController(
              text: qty.toStringAsFixed(2),
            );
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Last batch copied successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _resetFormulaControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  void _resetTankControllers() {
    for (final controller in _tankControllers.values) {
      controller.dispose();
    }
    _tankControllers.clear();
  }

  void _seedTankControllersForFormula() {
    _resetTankControllers();
    final formula = _selectedFormula;
    if (formula == null) return;

    final requiredKgByGroup = <String, double>{};
    final tanksByGroup = <String, List<Tank>>{};
    for (final item in formula.items) {
      final materialTanks = _tanksForFormulaItem(item, includeEmptyStock: true);
      if (materialTanks.isEmpty) continue;
      final groupKey = _tankMaterialGroupingKey(materialTanks.first);
      requiredKgByGroup[groupKey] =
          (requiredKgByGroup[groupKey] ?? 0) + (item.quantity * _batchCount);
      tanksByGroup.putIfAbsent(groupKey, () => materialTanks);
    }

    requiredKgByGroup.forEach((groupKey, requiredKg) {
      final materialTanks = tanksByGroup[groupKey] ?? const <Tank>[];
      var remainingKg = requiredKg;

      for (final tank in materialTanks) {
        final availableKg = StorageUnitHelper.storageQuantityToKg(
          tank.currentStock,
          storageUnit: tank.unit,
        );
        final consumeKg = remainingKg > 0
            ? (remainingKg <= availableKg ? remainingKg : availableKg)
            : 0.0;
        _tankControllers[tank.id] = TextEditingController(
          text: consumeKg > 0 ? consumeKg.toStringAsFixed(2) : '',
        );
        remainingKg -= consumeKg;
      }
    });
  }

  void _clearExtraIngredients({bool disposeControllers = true}) {
    if (disposeControllers) {
      for (final extra in _extraIngredients) {
        extra.controller.dispose();
      }
    }
    _extraIngredients.clear();
  }

  void _removeExtraIngredient(IngredientEntry extra) {
    extra.controller.dispose();
    _extraIngredients.remove(extra);
  }

  void _updateBatchCount(int delta) {
    HapticFeedback.lightImpact();
    setState(() {
      final newCount = _batchCount + delta;
      if (newCount >= 1) {
        _batchCount = newCount;
        if (_selectedFormula != null) {
          for (var item in _selectedFormula!.items) {
            _controllers[item.materialId]?.text = (item.quantity * _batchCount)
                .toStringAsFixed(2);
          }
          _seedTankControllersForFormula();
        }
      }
    });
  }

  _PreparedConsumptionData _prepareConsumptionPayload() {
    if (_selectedFormula == null) {
      throw Exception('Please select formula first');
    }

    final Map<String, Map<String, dynamic>> consumedByMaterial = {};
    final List<Map<String, dynamic>> tankConsumptions = [];
    final List<TankConsumptionPreviewItem> tankPreview = [];
    final tanksById = <String, Tank>{};
    for (final tank in _assignedBhattiTanks) {
      tanksById[tank.id] = tank;
    }
    for (final tank in _tanks) {
      tanksById.putIfAbsent(tank.id, () => tank);
    }

    void addMaterialConsumption({
      required String materialId,
      required String name,
      required double quantity,
      required String unit,
    }) {
      if (quantity <= 0) return;
      final existing = consumedByMaterial[materialId];
      if (existing == null) {
        consumedByMaterial[materialId] = {
          'materialId': materialId,
          'name': name,
          'quantity': quantity,
          'unit': unit,
        };
      } else {
        existing['quantity'] =
            ((existing['quantity'] as num).toDouble()) + quantity;
      }
    }

    for (final entry in _tankControllers.entries) {
      final enteredKg = double.tryParse(entry.value.text) ?? 0;
      if (enteredKg <= 0) continue;

      final tank = tanksById[entry.key];
      if (tank == null) continue;

      final enteredStorageQty = StorageUnitHelper.kgToStorageQuantity(
        enteredKg,
        storageUnit: tank.unit,
      );
      if (enteredStorageQty > tank.currentStock + 0.0001) {
        throw Exception(
          'Insufficient stock in ${tank.name}. Required ${enteredStorageQty.toStringAsFixed(2)} ${StorageUnitHelper.normalizeStorageUnit(tank.unit)}, available ${tank.currentStock.toStringAsFixed(2)}.',
        );
      }

      tankConsumptions.add({
        'tankId': tank.id,
        'tankName': tank.name,
        'materialId': tank.materialId,
        'quantity': enteredStorageQty,
      });

      tankPreview.add(
        TankConsumptionPreviewItem(
          tankName: tank.name,
          ingredientName: tank.materialName,
          quantityKg: enteredKg,
          quantityStorage: enteredStorageQty,
          storageUnit: StorageUnitHelper.normalizeStorageUnit(tank.unit),
        ),
      );

      addMaterialConsumption(
        materialId: tank.materialId,
        name: tank.materialName,
        quantity: enteredKg,
        unit: StorageUnitHelper.kgUnit,
      );
    }

    final processedNonTankMaterials = <String>{};
    for (final item in _selectedFormula!.items) {
      if (_formulaItemHasTankSource(item, includeEmptyStock: true)) continue;
      final itemKeys = _formulaItemMaterialKeys(item).toList()..sort();
      final dedupeKey = itemKeys.isEmpty
          ? 'name:${normalizeBhattiMaterialToken(item.name)}'
          : itemKeys.first;
      if (!processedNonTankMaterials.add(dedupeKey)) continue;
      final qty =
          double.tryParse(_controllers[item.materialId]?.text ?? '0') ?? 0;
      addMaterialConsumption(
        materialId: item.materialId,
        name: item.name,
        quantity: qty,
        unit: item.unit,
      );
    }

    for (var extra in _extraIngredients) {
      final qty = double.tryParse(extra.controller.text) ?? 0;
      addMaterialConsumption(
        materialId: extra.id,
        name: extra.name,
        quantity: qty,
        unit: extra.unit,
      );
    }

    final consumed = consumedByMaterial.values.toList();
    if (consumed.isEmpty) {
      throw Exception('Please enter consumption quantity');
    }

    return _PreparedConsumptionData(
      consumed: consumed,
      tankConsumptions: tankConsumptions,
      tankPreview: tankPreview,
    );
  }

  Future<void> _onSubmitPressed() async {
    if (_selectedFormula == null || _isLoading) return;
    HapticFeedback.mediumImpact();

    final configuredBoxes = _configuredBoxesPerBatchFromProduct;
    if (configuredBoxes == null || configuredBoxes <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set "Boxes per Batch" in Semi-Finished Product Master first.',
          ),
        ),
      );
      return;
    }
    final boxWeightKg = _configuredBoxWeightKgFromProduct;
    if (boxWeightKg == null || boxWeightKg <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set "Weight per Box (KG)" in Semi-Finished Product Master first.',
          ),
        ),
      );
      return;
    }

    try {
      final payload = _prepareConsumptionPayload();
      final confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => _ConfirmConsumptionPage(
            bhattiName: '$_selectedDept Bhatti',
            formulaName: _selectedFormula!.productName,
            batchCount: _batchCount,
            boxesPerBatch: _selectedBoxesPerBatch,
            expectedBoxes: _calculatedOutputBoxes,
            tankPreview: payload.tankPreview,
            totalConsumed: payload.consumed,
          ),
        ),
      );

      if (confirmed != true) return;
      await _submitConsumption(payload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitConsumption(_PreparedConsumptionData payload) async {
    if (_selectedFormula == null) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();

      final created = await _bhattiService.createBhattiBatch(
        bhattiName: '$_selectedDept Bhatti',
        targetProductId: _selectedFormula!.productId,
        targetProductName: _selectedFormula!.productName,
        batchCount: _batchCount,
        outputBoxes: _calculatedOutputBoxes,
        supervisorId: auth.state.user!.id,
        supervisorName: auth.state.user!.name,
        rawMaterialsConsumed: payload.consumed,
        tankConsumptions: payload.tankConsumptions,
      );
      if (!created) {
        throw Exception('Failed to record production batch');
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Production batch recorded successfully'),
          ),
        );
        _onFormulaSelected(null);
        _batchCount = 1;
        _clearExtraIngredients();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  List<FormulaItem> _buildUpdatedFormulaItems() {
    final selected = _selectedFormula;
    if (selected == null) return const <FormulaItem>[];

    final aggregated = <String, _FormulaDraftItem>{};
    final tanksById = <String, Tank>{};
    for (final tank in _assignedBhattiTanks) {
      tanksById[tank.id] = tank;
    }
    for (final tank in _tanks) {
      tanksById.putIfAbsent(tank.id, () => tank);
    }

    void upsert({
      required String materialId,
      required String name,
      required String unit,
      required double perBatchQty,
      bool keepIfZero = false,
    }) {
      final qty = perBatchQty < 0 ? 0.0 : perBatchQty;
      if (qty <= 0 && !keepIfZero) return;

      final existing = aggregated[materialId];
      if (existing == null) {
        aggregated[materialId] = _FormulaDraftItem(
          materialId: materialId,
          name: name,
          unit: unit,
          quantity: qty,
        );
      } else {
        existing.quantity += qty;
      }
    }

    for (final entry in _tankControllers.entries) {
      final qtyKg = double.tryParse(entry.value.text) ?? 0;
      if (qtyKg <= 0) continue;

      final tank = tanksById[entry.key];
      if (tank == null) continue;

      upsert(
        materialId: tank.materialId,
        name: tank.materialName,
        unit: StorageUnitHelper.kgUnit,
        perBatchQty: qtyKg / _batchCount,
      );
    }

    final seenNonTankMaterials = <String>{};
    for (final item in selected.items) {
      if (_formulaItemHasTankSource(item, includeEmptyStock: true)) continue;
      final itemKeys = _formulaItemMaterialKeys(item).toList()..sort();
      final dedupeKey = itemKeys.isEmpty
          ? 'name:${normalizeBhattiMaterialToken(item.name)}'
          : itemKeys.first;
      if (!seenNonTankMaterials.add(dedupeKey)) continue;

      final qty =
          double.tryParse(_controllers[item.materialId]?.text ?? '0') ?? 0;
      final perBatchQty = qty > 0 ? qty / _batchCount : item.quantity;
      upsert(
        materialId: item.materialId,
        name: item.name,
        unit: item.unit,
        perBatchQty: perBatchQty,
        keepIfZero: true,
      );
    }

    for (final extra in _extraIngredients) {
      final qty = double.tryParse(extra.controller.text) ?? 0;
      if (qty <= 0) continue;
      upsert(
        materialId: extra.id,
        name: extra.name,
        unit: extra.unit,
        perBatchQty: qty / _batchCount,
      );
    }

    return aggregated.values
        .map(
          (entry) => FormulaItem(
            materialId: entry.materialId,
            name: entry.name,
            quantity: double.parse(entry.quantity.toStringAsFixed(4)),
            unit: entry.unit,
          ),
        )
        .toList();
  }

  Future<void> _updateSelectedFormula() async {
    final selected = _selectedFormula;
    if (selected == null || _isUpdatingFormula) return;

    final updatedItems = _buildUpdatedFormulaItems();
    if (updatedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No formula items to update')),
      );
      return;
    }

    setState(() => _isUpdatingFormula = true);
    try {
      final nextVersion = selected.version + 1;
      final updated = await _formulasService.updateFormula(
        id: selected.id,
        items: updatedItems,
        version: nextVersion,
        status: 'completed',
      );

      if (!mounted) return;
      if (!updated) {
        setState(() => _isUpdatingFormula = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update formula')),
        );
        return;
      }

      final refreshedFormula = Formula(
        id: selected.id,
        productId: selected.productId,
        productName: selected.productName,
        category: selected.category,
        items: updatedItems,
        status: 'completed',
        version: nextVersion,
        wastageConfig: selected.wastageConfig,
        assignedBhatti: selected.assignedBhatti,
        createdAt: selected.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      setState(() {
        _selectedFormula = refreshedFormula;
        _formulas = _formulas
            .map((f) => f.id == refreshedFormula.id ? refreshedFormula : f)
            .toList();
        _isUpdatingFormula = false;
      });
      _onFormulaSelected(refreshedFormula);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formula updated and saved')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdatingFormula = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating formula: $e')));
    }
  }

  @override
  void dispose() {
    _resetFormulaControllers();
    _resetTankControllers();
    _clearExtraIngredients();
    super.dispose();
  }

  List<Tank> get _consumptionFilteredTanks {
    final tanks = _assignedBhattiTanks
        .where((tank) => tank.currentStock > 0)
        .toList();
    tanks.sort((a, b) {
      if (a.type != b.type) {
        if (a.type == 'tank') return -1;
        if (b.type == 'tank') return 1;
      }
      return Tank.compareAlphaNumericText(a.name, b.name);
    });
    return tanks;
  }

  List<Tank> get _assignedBhattiTanks {
    final selected = _selectedDept.toLowerCase();
    return _tanks.where((tank) {
      final assignedUnit = (tank.assignedUnit ?? '').trim().toLowerCase();
      final department = tank.department.trim().toLowerCase();
      final name = tank.name.trim().toLowerCase();
      final legacyPrefix = selected == 'sona' ? 's-' : 'g-';

      bool containsSelected(String value) =>
          value.contains(selected) || value.contains(legacyPrefix);

      if (assignedUnit.isNotEmpty) {
        if (assignedUnit.contains('all') || assignedUnit.contains('both')) {
          return true;
        }
        return containsSelected(assignedUnit);
      }

      return containsSelected(department) || containsSelected(name);
    }).toList();
  }

  Set<String> _tankMaterialKeys(Tank tank) =>
      bhattiMaterialKeys(id: tank.materialId, name: tank.materialName);

  Set<String> _formulaItemMaterialKeys(FormulaItem item) =>
      bhattiMaterialKeys(id: item.materialId, name: item.name);

  Set<String> _productMaterialKeys(Product product) =>
      bhattiMaterialKeys(id: product.id, name: product.name);

  String _tankMaterialGroupingKey(Tank tank) {
    final normalizedName = normalizeBhattiMaterialToken(tank.materialName);
    if (normalizedName.isNotEmpty) return 'name:$normalizedName';
    return 'id:${tank.materialId.trim().toLowerCase()}';
  }

  List<Tank> _tanksForFormulaItem(
    FormulaItem item, {
    bool includeEmptyStock = false,
  }) {
    final source = includeEmptyStock
        ? _assignedBhattiTanks
        : _consumptionFilteredTanks;
    final itemKeys = _formulaItemMaterialKeys(item);
    if (itemKeys.isEmpty) return const <Tank>[];

    final matched = source
        .where((tank) => _tankMaterialKeys(tank).any(itemKeys.contains))
        .toList();
    matched.sort((a, b) => b.currentStock.compareTo(a.currentStock));
    return matched;
  }

  bool _formulaItemHasTankSource(
    FormulaItem item, {
    bool includeEmptyStock = false,
  }) {
    return _tanksForFormulaItem(
      item,
      includeEmptyStock: includeEmptyStock,
    ).isNotEmpty;
  }

  String _supplierLabelForTank(Tank tank) {
    final latestLot = _latestLotsByTankId[tank.id];
    final supplier = latestLot?.supplierName.trim() ?? '';
    if (supplier.isNotEmpty) return supplier;
    return 'Unknown Supplier';
  }

  String _normalizeBhattiKey(String? value) {
    final raw = (value ?? '').trim().toLowerCase();
    if (raw.isEmpty) return '';
    if (raw == 'all' || raw.contains('all')) return 'all';
    if (raw.contains('gita') || raw.contains('geeta')) return 'gita';
    if (raw.contains('sona')) return 'sona';
    return raw;
  }

  bool _isProductAssignedToBhatti(Product product, String selectedBhattiKey) {
    final scopeTokens = <String>[
      if ((product.departmentId ?? '').trim().isNotEmpty) product.departmentId!,
      ...product.allowedDepartmentIds.where((e) => e.trim().isNotEmpty),
    ].map((e) => e.toLowerCase()).toList();

    if (scopeTokens.isEmpty) return true;

    bool hasKey(String key) => scopeTokens.any((token) => token.contains(key));
    if (selectedBhattiKey == 'gita') {
      return hasKey('gita') || hasKey('geeta');
    }
    if (selectedBhattiKey == 'sona') {
      if (hasKey('gita') || hasKey('geeta')) return false;
      return hasKey('sona') || hasKey('bhatti');
    }
    return true;
  }

  bool _isTradedProduct(Product product) {
    final normalizedItemType = ProductType.fromString(
      product.itemType.value,
    ).value.toLowerCase();
    final category = product.category.toLowerCase();
    final entityType = (product.entityType ?? '').toLowerCase();
    return normalizedItemType == ProductType.tradedGood.value.toLowerCase() ||
        product.type == ProductTypeEnum.traded ||
        category.contains('traded') ||
        entityType.contains('traded');
  }

  bool _isEligibleExtraIngredient(Product product) {
    if (_isTradedProduct(product)) return false;
    final normalizedItemType = ProductType.fromString(
      product.itemType.value,
    ).value;
    return normalizedItemType == ProductType.rawMaterial.value ||
        normalizedItemType == ProductType.oilsLiquids.value ||
        product.type == ProductTypeEnum.raw;
  }

  int _formulaPriorityForSelected(Formula formula, String selectedBhattiKey) {
    final formulaBhattiKey = _normalizeBhattiKey(formula.assignedBhatti);
    if (formulaBhattiKey == selectedBhattiKey) return 3;
    if (formulaBhattiKey == 'all') return 2;
    if (formulaBhattiKey.isEmpty) return 1;
    return 0;
  }

  DateTime _formulaUpdatedAt(Formula formula) {
    return DateTime.tryParse(formula.updatedAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formulaScopeLabel(Formula formula) {
    final key = _normalizeBhattiKey(formula.assignedBhatti);
    switch (key) {
      case 'sona':
        return 'Sona';
      case 'gita':
        return 'Gita';
      case 'all':
        return 'All';
      default:
        return 'Legacy';
    }
  }

  List<Formula> get _filteredFormulas {
    final selectedBhattiKey = _normalizeBhattiKey(_selectedDept);
    final matching = _formulas.where((formula) {
      final priority = _formulaPriorityForSelected(formula, selectedBhattiKey);
      if (priority <= 0) {
        return false;
      }

      // If explicitly assigned to this exact bhatti or 'all', bypass product-level department checks
      if (priority >= 2) {
        return true;
      }

      final product = _products.cast<Product?>().firstWhere(
        (p) => p?.id == formula.productId,
        orElse: () => null,
      );
      if (product == null) return true;
      return _isProductAssignedToBhatti(product, selectedBhattiKey);
    });

    final deduped = <String, Formula>{};
    for (final formula in matching) {
      final productId = formula.productId.trim().toLowerCase();
      final normalizedName = formula.productName
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final key = productId.isNotEmpty
          ? 'product:$productId'
          : 'name:$normalizedName';
      final existing = deduped[key];
      if (existing == null) {
        deduped[key] = formula;
        continue;
      }

      final existingPriority = _formulaPriorityForSelected(
        existing,
        selectedBhattiKey,
      );
      final candidatePriority = _formulaPriorityForSelected(
        formula,
        selectedBhattiKey,
      );

      final shouldReplace =
          candidatePriority > existingPriority ||
          (candidatePriority == existingPriority &&
              (formula.version > existing.version ||
                  (formula.version == existing.version &&
                      _formulaUpdatedAt(
                        formula,
                      ).isAfter(_formulaUpdatedAt(existing)))));

      if (shouldReplace) {
        deduped[key] = formula;
      }
    }

    final result =
        deduped.values
            .where((formula) => formula.productName.trim().isNotEmpty)
            .toList()
          ..sort(
            (a, b) => a.productName.toLowerCase().compareTo(
              b.productName.toLowerCase(),
            ),
          );
    return result;
  }

  void _onDeptChanged(String dept) {
    if (_selectedDept == dept) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedDept = dept;
      _selectedFormula = null;
      _resetFormulaControllers();
      _resetTankControllers();
      _clearExtraIngredients();
    });
    // Auto-select formula if only one is available after department change
    _autoSelectFormulaIfSingle();
  }
  
  void _autoSelectFormulaIfSingle() {
    if (_selectedFormula != null) return; // Already selected
    
    final availableFormulas = _filteredFormulas;
    if (availableFormulas.length == 1) {
      // Auto-select the only available formula
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onFormulaSelected(availableFormulas.first);
        }
      });
    }
  }

  _PreparedConsumptionData? _buildPreparedDataForExport() {
    if (_selectedFormula == null) return null;
    try {
      return _prepareConsumptionPayload();
    } catch (_) {
      return null;
    }
  }

  @override
  bool get hasExportData => _buildPreparedDataForExport() != null;

  @override
  List<String> buildPdfHeaders() {
    return ['Material', 'Quantity', 'Unit', 'Source'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    final prepared = _buildPreparedDataForExport();
    if (prepared == null) return const <List<dynamic>>[];

    final tankMaterialIds = prepared.tankConsumptions
        .map((e) => e['materialId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    return prepared.consumed.map((item) {
      final materialId = item['materialId']?.toString() ?? '';
      final materialName = item['name']?.toString() ?? 'Unknown';
      final qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
      final unit = item['unit']?.toString() ?? 'Kg';
      final source = tankMaterialIds.contains(materialId)
          ? 'Tank'
          : 'Formula/Other';
      return [materialName, qty.toStringAsFixed(2), unit, source];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    final formula = _selectedFormula;
    return {
      'Bhatti': '$_selectedDept Bhatti',
      'Formula': formula?.productName ?? 'N/A',
      'Batch Count': _batchCount.toString(),
      'Boxes/Batch': _selectedBoxesPerBatch.toString(),
      'Expected Output': '$_calculatedOutputBoxes boxes',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = Responsive.width(context);
    final isMobile = width < Responsive.mobileBreakpoint;
    final useMobileTypography = useMobileHeaderTypographyForWidth(width);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 10, 6),
            child: Row(
              children: [
                if (isMobile)
                  IconButton(
                    onPressed: _handleBackNavigation,
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Consumption & Batch Entry',
                        maxLines: 1,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: useMobileTypography
                              ? mobileHeaderTitleFontSize
                              : null,
                          fontWeight: FontWeight.w800,
                          letterSpacing: useMobileTypography ? -0.1 : 0,
                        ),
                      ),
                    ),
                  ),
                ),
                ReportExportActions(
                  isLoading: isExporting,
                  onExport: () => exportReport('Bhatti Consumption Snapshot'),
                  onPrint: () => printReport('Bhatti Consumption Snapshot'),
                  onRefresh: _loadData,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      if (_shouldShowDeptToggle)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 360;
                              if (compact) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _buildDeptToggle('Sona')),
                                        const SizedBox(width: 12),
                                        Expanded(child: _buildDeptToggle('Gita')),
                                      ],
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: _buildDeptToggle('Sona')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildDeptToggle('Gita')),
                                ],
                              );
                            },
                          ),
                        ),
                      Expanded(child: _buildConsumptionView()),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedFormula != null && isMobile
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmitPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFFF0B307),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text(
                          'SUBMIT BATCH',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDeptToggle(String dept) {
    final theme = Theme.of(context);
    final isSelected = _selectedDept == dept;
    return GestureDetector(
      onTap: () => _onDeptChanged(dept),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          '${dept.toUpperCase()} BHATTI',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            fontSize: 11,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildConsumptionView() {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final tanks = _consumptionFilteredTanks;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final nonTankItems = _selectedFormula == null
        ? const <FormulaItem>[]
        : _selectedFormula!.items
              .where(
                (item) =>
                    !_formulaItemHasTankSource(item, includeEmptyStock: true),
              )
              .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        (Responsive.width(context) < Responsive.mobileBreakpoint &&
                _selectedFormula != null)
            ? 16
            : 40 + bottomInset + 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BATCH FORMULA',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          if (_recentFormulas.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _recentFormulas
                  .map(
                    (f) => GestureDetector(
                      onTap: () => _onFormulaSelected(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              f.productName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: _buildDropdown<Formula>(
                  label: 'SELECT SEMI-FINISH FORMULA',
                  value: _selectedFormula,
                  helperText: null,
                  items: _filteredFormulas
                      .map(
                        (f) => DropdownMenuItem(
                          value: f,
                          child: Text(
                            '${f.productName} [${_formulaScopeLabel(f)}]',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _onFormulaSelected,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _copyLastBatch,
                icon: const Icon(Icons.copy_all, size: 20),
                tooltip: 'Copy Last Batch',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_selectedFormula != null) ...[
            _buildGroupedTankInventory(tanks),
            if (nonTankItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'OTHER MATERIALS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              ...nonTankItems.map((item) {
                final controller = _controllers.putIfAbsent(
                  item.materialId,
                  () => TextEditingController(
                    text: (item.quantity * _batchCount).toStringAsFixed(2),
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildFormulaMaterialInputRow(
                    item: item,
                    controller: controller,
                  ),
                );
              }),
            ],
            const SizedBox(height: 10),
            Text(
              'Other Ingredients (Warehouse)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                if (_extraIngredients.isNotEmpty)
                  ..._extraIngredients.map(
                    (extra) => _buildExtraIngredientItem(extra),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showAddExtraIngredientDialog,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '+ Add Ingredient',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            (_selectedFormula == null || _isUpdatingFormula)
                            ? null
                            : _updateSelectedFormula,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isUpdatingFormula
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Update Formula',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 390;

                Widget batchCounter = SizedBox(
                  width: compact ? 170 : 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _updateBatchCount(-1),
                        icon: const Icon(Icons.remove, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_batchCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Batches',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _updateBatchCount(1),
                        icon: const Icon(Icons.add, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );

                Widget submitButton =
                    (Responsive.width(context) < Responsive.mobileBreakpoint)
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 56,
                        width: compact ? double.infinity : null,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _onSubmitPressed,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_outlined, size: 18),
                          label: Text(
                            _isLoading ? 'PROCESSING...' : 'Submit',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 0.2,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0B307),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      );

                if (Responsive.width(context) < Responsive.mobileBreakpoint) {
                  return Align(
                    alignment: Alignment.center,
                    child: batchCounter,
                  );
                }

                if (compact) {
                  return Column(
                    children: [
                      Align(alignment: Alignment.center, child: batchCounter),
                      const SizedBox(height: 10),
                      submitButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    batchCounter,
                    const SizedBox(width: 10),
                    Expanded(child: submitButton),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Boxes/Batch: $_selectedBoxesPerBatch | 1 Box: ${(_configuredBoxWeightKgFromProduct ?? 0).toStringAsFixed(2)} KG | Expected: $_calculatedOutputBoxes boxes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupedTankInventory(List<Tank> tanks) {
    final theme = Theme.of(context);
    if (tanks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'No assigned tanks with stock available for ${_selectedDept.toUpperCase()} bhatti.',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final grouped = <String, List<Tank>>{};
    for (final tank in tanks) {
      final key = _groupTitleForTank(tank);
      grouped.putIfAbsent(key, () => []).add(tank);
    }

    final preferredOrder = <String>[
      'Caustic Tanks',
      'Oil Tanks',
      'Silicate Tanks',
      'Godowns',
      'Other Tanks',
    ];

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final ia = preferredOrder.indexOf(a);
        final ib = preferredOrder.indexOf(b);
        final pa = ia == -1 ? 999 : ia;
        final pb = ib == -1 ? 999 : ib;
        if (pa != pb) return pa.compareTo(pb);
        return Tank.compareAlphaNumericText(a, b);
      });

    return Column(
      children: sortedKeys.map((key) {
        final sectionTanks = grouped[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 8),
            ...sectionTanks.map(_buildTankInventoryCard),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  String _groupTitleForTank(Tank tank) {
    if (tank.type == 'godown') return 'Godowns';

    final material = tank.materialName.toLowerCase();
    final name = tank.name.toLowerCase();
    if (material.contains('caustic') || name.contains('caustic')) {
      return 'Caustic Tanks';
    }
    if (material.contains('silicate') || name.contains('silicate')) {
      return 'Silicate Tanks';
    }
    if (material.contains('oil') || name.contains('oil')) {
      return 'Oil Tanks';
    }
    return 'Other Tanks';
  }

  Widget _buildTankInventoryCard(Tank tank) {
    final theme = Theme.of(context);
    final supplier = _supplierLabelForTank(tank);
    final capacity = tank.capacity <= 0 ? 1.0 : tank.capacity;
    final progress = (tank.currentStock / capacity).clamp(0.0, 1.0);
    final lowThreshold = tank.minStockLevel > 0 ? tank.minStockLevel : 0.5;
    final isLow = tank.currentStock <= lowThreshold;
    final displayUnit = StorageUnitHelper.tankDisplayUnit(tank.unit);
    final displayCapacity = StorageUnitHelper.tankDisplayQuantity(
      tank.capacity,
      storageUnit: tank.unit,
    );
    final displayCurrentStock = StorageUnitHelper.tankDisplayQuantity(
      tank.currentStock,
      storageUnit: tank.unit,
    );
    final qtyController = _tankControllers.putIfAbsent(
      tank.id,
      () => TextEditingController(text: '0'),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tank.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'C:${displayCapacity.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'A:${displayCurrentStock.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: isLow ? AppColors.error : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      displayUnit,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${tank.materialName} • $supplier',
                  style: TextStyle(
                    fontSize: 7,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      isLow ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Qty (Kg)',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    NormalizedNumberInputFormatter.decimal(
                      keepZeroWhenEmpty: true,
                      maxDecimalPlaces: 4,
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraIngredientItem(IngredientEntry extra) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 340;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            extra.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            extra.unit.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _removeExtraIngredient(extra)),
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(controller: extra.controller, label: 'QTY'),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extra.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      extra.unit.toUpperCase(),
                      style: TextStyle(fontSize: 9, color: onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: extra.controller,
                  label: 'QTY',
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _removeExtraIngredient(extra)),
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormulaMaterialInputRow({
    required FormulaItem item,
    required TextEditingController controller,
  }) {
    final label = '${item.name.toUpperCase()} (${item.unit.toUpperCase()})';
    final shouldUseInline = useInlineFormulaMaterialRowLayoutForWidth(
      Responsive.width(context),
    );
    if (!shouldUseInline) {
      return _buildTextField(controller: controller, label: label);
    }

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                NormalizedNumberInputFormatter.decimal(
                  keepZeroWhenEmpty: true,
                  maxDecimalPlaces: 4,
                ),
              ],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '0.00',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isDense = false,
    Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    final isMobile = Responsive.width(context) < Responsive.mobileBreakpoint;
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType:
          keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        NormalizedNumberInputFormatter.decimal(
          keepZeroWhenEmpty: true,
          maxDecimalPlaces: 4,
        ),
      ],
      style: TextStyle(
        fontSize: isMobile ? 18 : 14,
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: isMobile ? 12 : 10,
          fontWeight: FontWeight.w900,
        ),
        filled: true,
        isDense: isDense && !isMobile,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 14,
          vertical: isMobile ? 16 : (isDense ? 10 : 12),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? helperText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.28),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 10, color: AppColors.info),
      ),
    );
  }

  void _showAddExtraIngredientDialog() {
    final tankMaterialKeys = _assignedBhattiTanks
        .expand(_tankMaterialKeys)
        .toSet();
    final selectedExtraKeys = _extraIngredients
        .expand((e) => bhattiMaterialKeys(id: e.id, name: e.name))
        .toSet();
    final formulaMaterialKeys =
        (_selectedFormula?.items ?? const <FormulaItem>[])
            .expand(_formulaItemMaterialKeys)
            .toSet();
    final rawMaterials = _products.where((p) {
      if (!_isEligibleExtraIngredient(p)) return false;
      final productKeys = _productMaterialKeys(p);
      if (productKeys.isEmpty) return false;
      if (productKeys.any(tankMaterialKeys.contains)) return false;
      if (productKeys.any(selectedExtraKeys.contains)) return false;
      if (productKeys.any(formulaMaterialKeys.contains)) return false;
      return true;
    }).toList();
    showDialog(
      context: context,
      builder: (context) => _AddIngredientDialog(
        products: rawMaterials,
        onAdd: (name, id, unit) {
          setState(() {
            _extraIngredients.add(
              IngredientEntry(
                id: id,
                name: name,
                baseQuantity: 1.0,
                unit: unit,
                controller: TextEditingController(text: '0'),
              ),
            );
          });
        },
      ),
    );
  }
}

class _PreparedConsumptionData {
  final List<Map<String, dynamic>> consumed;
  final List<Map<String, dynamic>> tankConsumptions;
  final List<TankConsumptionPreviewItem> tankPreview;

  const _PreparedConsumptionData({
    required this.consumed,
    required this.tankConsumptions,
    required this.tankPreview,
  });
}

class _FormulaDraftItem {
  final String materialId;
  final String name;
  final String unit;
  double quantity;

  _FormulaDraftItem({
    required this.materialId,
    required this.name,
    required this.unit,
    required this.quantity,
  });
}

class TankConsumptionPreviewItem {
  final String tankName;
  final String ingredientName;
  final double quantityKg;
  final double quantityStorage;
  final String storageUnit;

  const TankConsumptionPreviewItem({
    required this.tankName,
    required this.ingredientName,
    required this.quantityKg,
    required this.quantityStorage,
    required this.storageUnit,
  });
}

class _ConfirmConsumptionPage extends StatelessWidget {
  final String bhattiName;
  final String formulaName;
  final int batchCount;
  final int boxesPerBatch;
  final int expectedBoxes;
  final List<TankConsumptionPreviewItem> tankPreview;
  final List<Map<String, dynamic>> totalConsumed;

  const _ConfirmConsumptionPage({
    required this.bhattiName,
    required this.formulaName,
    required this.batchCount,
    required this.boxesPerBatch,
    required this.expectedBoxes,
    required this.tankPreview,
    required this.totalConsumed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.1,
      ),
      appBar: AppBar(
        title: const Text(
          'Confirm Consumption',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bhatti: $bhattiName',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Formula: $formulaName',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Batches: $batchCount | Output: $boxesPerBatch/batch | Expected: $expectedBoxes boxes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'TANK CONSUMPTION',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            if (tankPreview.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No tank consumption entries.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceVariant,
                  ),
                ),
              )
            else
              ...tankPreview.map(
                (row) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '${row.tankName} → ${row.ingredientName}: ${row.quantityKg.toStringAsFixed(2)} Kg (${row.quantityStorage.toStringAsFixed(2)} ${row.storageUnit})',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'TOTAL INGREDIENTS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...totalConsumed.map((item) {
              final qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
              final name = item['name']?.toString() ?? 'Unknown';
              final unit = item['unit']?.toString() ?? 'Kg';
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  '$name: ${qty.toStringAsFixed(2)} $unit',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFFF0B307),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm & Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IngredientEntry {
  final String id, name, unit;
  final double baseQuantity;
  final TextEditingController controller;
  IngredientEntry({
    required this.id,
    required this.name,
    required this.baseQuantity,
    required this.unit,
    required this.controller,
  });
}

class _AddIngredientDialog extends StatefulWidget {
  final List<Product> products;
  final Function(String name, String id, String unit) onAdd;
  const _AddIngredientDialog({required this.products, required this.onAdd});
  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = widget.products
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    return ResponsiveAlertDialog(
      title: const Text(
        'ADD EXTRA INGREDIENT',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'SEARCH MATERIAL...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: Responsive.clamp(context, min: 220, max: 320, ratio: 0.5),
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return ListTile(
                    title: Text(
                      item.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      item.unit ?? 'KG',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                    onTap: () {
                      widget.onAdd(item.name, item.id, item.unit ?? 'KG');
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
