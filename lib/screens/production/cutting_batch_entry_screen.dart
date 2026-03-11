import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/cutting_types.dart';
import '../../models/types/product_types.dart';
import '../../services/cutting_batch_service.dart';
import '../../services/products_service.dart';
import '../../services/users_service.dart';
import '../../services/formulas_service.dart';
import '../../models/types/user_types.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../utils/access_guard.dart';
import '../../utils/unit_scope_utils.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';

class CuttingBatchEntryScreen extends StatefulWidget {
  const CuttingBatchEntryScreen({super.key});

  @override
  State<CuttingBatchEntryScreen> createState() =>
      _CuttingBatchEntryScreenState();
}

class _CuttingBatchEntryScreenState extends State<CuttingBatchEntryScreen> {
  static final _formKey = GlobalKey<FormState>();
  late final CuttingBatchService _cuttingBatchService;
  late final ProductsService _productsService;
  late final UsersService _usersService;
  late final FormulasService _formulasService;

  @override
  void initState() {
    super.initState();
    AccessGuard.checkProductionAccess(context);
    _cuttingBatchService = context.read<CuttingBatchService>();
    _productsService = context.read<ProductsService>();
    _usersService = context.read<UsersService>();
    _formulasService = context.read<FormulasService>();
    _checkAccess();
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.role.canAccessProduction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied: Production operations restricted to authorized roles')),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    _loadInitialData();
  }

  // Users Cache
  List<AppUser> _allUsers = [];

  List<String> _availableDepartments = [];

  // Date
  late DateTime _selectedDate = DateTime.now();
  // Shift removed as per requirement

  // Department & Operator
  String _selectedDepartment = '';
  bool _isDepartmentLocked = false;
  String? _selectedOperatorId;
  String? _selectedOperatorName;
  bool _isOperatorLocked = false;
  List<Map<String, String>> _operators = [];
  final _operatorDisplayController = TextEditingController();

  // Semi-Finished Input
  Product? _selectedSemiProduct;
  List<Product> _semiProducts = [];
  final _batchCountController = TextEditingController(text: '0');
  int _batchCount = 0;
  final _totalBatchWeightController = TextEditingController(text: '0');
  final _boxesCountController = TextEditingController(text: '0');
  int _boxesPerBatch = 0;
  Map<String, int> _outputRules = const {'sona': 6, 'gita': 7};
  double? _avgBoxWeight;

  // Resolved stock plan from service
  Map<String, dynamic>? _resolvedStockPlan;

  // Finished Goods Config
  Product? _selectedFinishedProduct;
  List<Product> _allFinishedProducts = []; // Department-scoped master list
  List<Product> _allSemiProductsMaster = [];
  List<Product> _allFinishedProductsMaster = [];
  List<Product> _allPackagingProductsMaster = [];
  List<Product> _finishedProducts = []; // Filtered list
  double _standardWeightGm = 0;
  final _actualAvgWeightController = TextEditingController(text: '0');
  double _tolerancePercent = 5.0;

  // Production Output
  final _unitsProducedController = TextEditingController(text: '0');
  double _totalFinishedWeightKg = 0;
  WeightValidation? _weightValidation;
  bool _isOverweight = false;
  String _overweightRemark = '';

  // Waste
  final _cuttingWasteController = TextEditingController(text: '0');
  WasteType _wasteType = WasteType.scrap;
  final _wasteRemarkController = TextEditingController();

  // Packaging
  List<Product> _packagingProducts = [];
  final List<Map<String, dynamic>> _packagingItems = [];

  // Summary
  Map<String, dynamic> _weightBalance = {};
  bool _weightBalanceValid = false;

  bool _isLoading = false;
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});
  Map<String, Set<String>> _formulaUnitKeysByProductId = {};

  String _departmentScopeKey(String? value) {
    final normalized = normalizeUnitKey(value);
    if (normalized.contains('gita')) return 'gita';
    if (normalized.contains('sona') || normalized.contains('bhatti')) {
      return 'sona';
    }
    return normalized;
  }

  bool _isAdminLikeUser(AppUser? user) {
    if (user == null) return false;
    return user.isAdmin || user.role == UserRole.productionManager;
  }

  String _unitLabelFromKey(String key) {
    return key == 'gita' ? 'Gita' : 'Sona';
  }

  String? _unitKeyFromToken(String? token) {
    if (token == null || token.trim().isEmpty) return null;
    final normalized = normalizeUnitKey(token);
    if (normalized.contains('gita')) return 'gita';
    if (normalized.contains('sona') || normalized.contains('bhatti')) {
      return 'sona';
    }
    return null;
  }

  String? _resolveUserAssignedUnitKey(AppUser? user) {
    if (user == null) return null;

    final direct = <String?>[
      user.assignedBhatti,
      user.department,
      for (final d in user.departments) d.team,
      for (final d in user.departments) d.main,
    ];

    for (final token in direct) {
      final key = _unitKeyFromToken(token);
      if (key != null) return key;
    }
    return null;
  }

  bool _matchesUserScope(Product product) {
    return matchesUnitScope(
      scope: _unitScope,
      tokens: _productScopeTokens(product),
      defaultIfNoScopeTokens: false,
    );
  }

  bool _matchesDepartmentScope(Product product, String scopeKey) {
    if (scopeKey.isEmpty) return true;
    return matchesUnitScope(
      scope: UserUnitScope(canViewAll: false, keys: {scopeKey}),
      tokens: _productScopeTokens(product),
      defaultIfNoScopeTokens: false,
    );
  }

  String? _normalizeAssignedBhattiKey(String? value) {
    final normalized = normalizeUnitKey(value);
    if (normalized == 'gita' || normalized == 'sona') {
      return normalized;
    }
    if (normalized == 'all') {
      return 'all';
    }
    return null;
  }

  Map<String, Set<String>> _buildFormulaUnitMap(List<Formula> formulas) {
    final sorted = [...formulas]
      ..sort((a, b) {
        final aTime = DateTime.tryParse(a.updatedAt) ?? DateTime(1970);
        final bTime = DateTime.tryParse(b.updatedAt) ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    final map = <String, Set<String>>{};
    for (final formula in sorted) {
      final productId = formula.productId.trim();
      if (productId.isEmpty) continue;
      final bhattiKey = _normalizeAssignedBhattiKey(formula.assignedBhatti);
      if (bhattiKey == null) continue;
      final keys = map.putIfAbsent(productId, () => <String>{});
      if (bhattiKey == 'all') {
        keys.addAll(const {'sona', 'gita'});
      } else {
        keys.add(bhattiKey);
      }
    }
    return map;
  }

  Iterable<String?> _productScopeTokens(Product product) sync* {
    yield product.name;
    yield product.sku;
    yield product.departmentId;
    for (final token in product.allowedDepartmentIds) {
      yield token;
    }

    final formulaKeys = _formulaUnitKeysByProductId[product.id];
    if (formulaKeys == null || formulaKeys.isEmpty) return;

    for (final key in formulaKeys) {
      yield key;
      yield '${key}_bhatti';
      yield 'bhatti:$key';
      yield '$key unit';
    }
  }

  String _entityTypeKey(Product product) {
    return (product.entityType ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  bool _isSemiProduct(Product product) {
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    final entityType = _entityTypeKey(product);
    return product.type == ProductTypeEnum.semi ||
        normalizedType == ProductType.semiFinishedGood.value ||
        entityType == 'semi_finished' ||
        entityType == 'semi' ||
        entityType == 'formula_output';
  }

  bool _isFinishedProduct(Product product) {
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    final entityType = _entityTypeKey(product);
    return product.type == ProductTypeEnum.finished ||
        normalizedType == ProductType.finishedGood.value ||
        entityType == 'finished' ||
        entityType == 'finished_good' ||
        entityType == 'final_product';
  }

  bool _isPackagingProduct(Product product) {
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    return product.type == ProductTypeEnum.packaging ||
        normalizedType == ProductType.packagingMaterial.value;
  }

  void _applyDepartmentProductFilters() {
    final scopeKey = _departmentScopeKey(_selectedDepartment);

    final strictScopedSemi = _allSemiProductsMaster
        .where((p) => _matchesDepartmentScope(p, scopeKey))
        .toList();
    final strictScopedFinished = _allFinishedProductsMaster
        .where((p) => _matchesDepartmentScope(p, scopeKey))
        .toList();
    final strictScopedPackaging = _allPackagingProductsMaster
        .where((p) => _matchesDepartmentScope(p, scopeKey))
        .toList();
    final scopedSemiByDepartment = strictScopedSemi.isNotEmpty
        ? strictScopedSemi
        : _allSemiProductsMaster;
    final scopedFinished = strictScopedFinished.isNotEmpty
        ? strictScopedFinished
        : _allFinishedProductsMaster;
    final scopedPackaging = strictScopedPackaging.isNotEmpty
        ? strictScopedPackaging
        : _allPackagingProductsMaster;

    // Backward-compatibility bridge:
    // Some legacy semi-finished products may not carry reliable unit-scope
    // tokens, but are still valid via finished-good mapping.
    final mappedSemiIds = scopedFinished
        .expand((p) => p.allowedSemiFinishedIds)
        .where((id) => id.trim().isNotEmpty)
        .toSet();
    final scopedSemiByMapping = _allSemiProductsMaster
        .where((p) => mappedSemiIds.contains(p.id))
        .toList();
    final scopedSemiById = <String, Product>{
      for (final semi in scopedSemiByDepartment) semi.id: semi,
      for (final semi in scopedSemiByMapping) semi.id: semi,
    };
    final scopedSemi = scopedSemiById.values.toList();

    Product? selectedSemi = _selectedSemiProduct;
    if (selectedSemi != null &&
        !scopedSemi.any((p) => p.id == selectedSemi!.id)) {
      selectedSemi = null;
    }

    final finishedBySemi = selectedSemi == null
        ? <Product>[]
        : scopedFinished
              .where((p) => p.allowedSemiFinishedIds.contains(selectedSemi!.id))
              .toList();

    Product? selectedFinished = _selectedFinishedProduct;
    if (selectedFinished != null &&
        !finishedBySemi.any((p) => p.id == selectedFinished!.id)) {
      selectedFinished = null;
    }

    setState(() {
      _semiProducts = scopedSemi;
      _allFinishedProducts = scopedFinished;
      _packagingProducts = scopedPackaging;
      _selectedSemiProduct = selectedSemi;
      _finishedProducts = finishedBySemi;
      _selectedFinishedProduct = selectedFinished;
      if (selectedFinished == null) {
        _standardWeightGm = 0;
        _weightValidation = null;
        _actualAvgWeightController.text = '0';
        _unitsProducedController.text = '0';
        _totalFinishedWeightKg = 0;
        _packagingItems.clear();
      }
    });

    _calculatePackaging();
  }

  String _formatStock(double stock) {
    return stock == stock.toInt() 
      ? stock.toInt().toString() 
      : stock.toStringAsFixed(1);
  }

  bool _canEditBoxes() {
    // Always allow editing if semi-product is selected
    // User may need to reduce boxes if stock is low
    return _selectedSemiProduct != null;
  }

  double _calculateExpectedScrap() {
    final input = double.tryParse(_totalBatchWeightController.text) ?? 0;
    final output = _totalFinishedWeightKg;
    return input - output;
  }

  bool _hasLowStock() {
    if (_selectedSemiProduct == null) return false;
    final required = int.tryParse(_boxesCountController.text) ?? 0;
    final available = _selectedSemiProduct!.stock;
    return required > available;
  }

  int _resolveBoxesPerBatch() {
    final productBoxes = _selectedSemiProduct?.boxesPerBatch;
    if (productBoxes != null && productBoxes > 0) {
      return productBoxes;
    }
    final key = _departmentScopeKey(_selectedDepartment);
    if (key == 'gita') return _outputRules['gita'] ?? 7;
    return _outputRules['sona'] ?? 6;
  }

  double _resolveSemiBoxWeightKg() {
    final product = _selectedSemiProduct;
    if (product == null) return 0.0;
    
    final weightGrams = product.unitWeightGrams;
    if (weightGrams > 0) {
      return weightGrams / 1000.0; // Convert grams → KG
    }
    
    return 0.0;
  }

  void _refreshBatchDerivedValues() {
    final perBatch = _resolveBoxesPerBatch();
    final totalBoxes = perBatch > 0 ? perBatch * _batchCount : 0;
    final boxWeightKg = _resolveSemiBoxWeightKg();
    final inputWeightKg = totalBoxes * boxWeightKg;

    setState(() {
      _boxesPerBatch = perBatch;
      _boxesCountController.text = totalBoxes.toString();
      _totalBatchWeightController.text = inputWeightKg > 0
          ? inputWeightKg.toStringAsFixed(3)
          : '0';
    });

    _onBoxesCountChanged(_boxesCountController.text);
    final currentUnits =
        int.tryParse(_unitsProducedController.text.trim()) ?? 0;
    if (currentUnits <= 0 && totalBoxes > 0) {
      _unitsProducedController.text = totalBoxes.toString();
      _onUnitsProducedChanged(_unitsProducedController.text);
    }
    _calculateWeightBalance();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _productsService.getProducts(),
        _usersService.getUsers(),
        _formulasService.getFormulas(),
        _cuttingBatchService.getOutputBoxesRules(),
      ]);
      final products = results[0] as List<Product>;
      final allUsers = results[1] as List<AppUser>;
      final formulas = results[2] as List<Formula>;
      final outputRules = results[3] as Map<String, int>;
      final formulaUnitMap = _buildFormulaUnitMap(formulas);
      _formulaUnitKeysByProductId = formulaUnitMap;
      final detectedSemi = products.where(_isSemiProduct).toList();
      final detectedFinished = products.where(_isFinishedProduct).toList();
      final semiFiltered = detectedSemi.isNotEmpty
          ? detectedSemi
          : products.where((p) {
              final entityType = _entityTypeKey(p);
              return entityType == 'semi_finished' ||
                  entityType == 'formula_output' ||
                  entityType == 'semi';
            }).toList();
      final finishedFiltered = detectedFinished.isNotEmpty
          ? detectedFinished
          : products.where((p) {
              final entityType = _entityTypeKey(p);
              return entityType == 'finished' ||
                  entityType == 'finished_good' ||
                  entityType == 'final_product';
            }).toList();
      final packagingFiltered = products.where(_isPackagingProduct).toList();
      if (!mounted) return;
      final loggedInUser = context.read<AuthProvider>().currentUser;
      final adminLike = _isAdminLikeUser(loggedInUser);
      _unitScope = resolveUserUnitScope(loggedInUser);

      final strictUserScopedSemi = semiFiltered
          .where(_matchesUserScope)
          .toList();
      final strictUserScopedFinished = finishedFiltered
          .where(_matchesUserScope)
          .toList();
      final strictUserScopedPackaging = packagingFiltered
          .where(_matchesUserScope)
          .toList();
      final userScopedSemi = _unitScope.canViewAll
          ? semiFiltered
          : (strictUserScopedSemi.isNotEmpty
                ? strictUserScopedSemi
                : semiFiltered);
      final userScopedFinished = _unitScope.canViewAll
          ? finishedFiltered
          : (strictUserScopedFinished.isNotEmpty
                ? strictUserScopedFinished
                : finishedFiltered);
      final userScopedPackaging = _unitScope.canViewAll
          ? packagingFiltered
          : (strictUserScopedPackaging.isNotEmpty
                ? strictUserScopedPackaging
                : packagingFiltered);

      List<String> validDepts = adminLike ? ['Sona', 'Gita'] : [];
      if (!adminLike) {
        final assignedKey = _resolveUserAssignedUnitKey(loggedInUser);
        if (assignedKey != null) {
          validDepts = [_unitLabelFromKey(assignedKey)];
        }
      }
      if (validDepts.isEmpty) {
        validDepts = ['Sona'];
      }

      if (mounted) {
        setState(() {
          _allSemiProductsMaster = userScopedSemi;
          _allFinishedProductsMaster = userScopedFinished;
          _allPackagingProductsMaster = userScopedPackaging;
          _semiProducts = [];
          _allFinishedProducts = [];
          _finishedProducts = [];
          _packagingProducts = [];
          _allUsers = allUsers;
          _formulaUnitKeysByProductId = formulaUnitMap;
          _outputRules = outputRules;
          _availableDepartments = validDepts;
          _selectedDepartment = validDepts.isNotEmpty ? validDepts.first : '';
          _isDepartmentLocked = !adminLike;
          _isOperatorLocked = !adminLike;
          if (_isOperatorLocked && loggedInUser != null) {
            _selectedOperatorId = loggedInUser.id;
            _selectedOperatorName = loggedInUser.name;
            _operatorDisplayController.text = loggedInUser.name.toUpperCase();
          }
          _isLoading = false;
        });
        _updateOperatorsList();
        _applyDepartmentProductFilters();
        _refreshBatchDerivedValues();
        _autoSelectSemiProductIfSingle();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load data: $e');
      }
    }
  }

  void _autoSelectSemiProductIfSingle() {
    if (_semiProducts.length == 1) {
      _onSemiProductChanged(_semiProducts.first);
    }
  }

  void _updateOperatorsList() {
    if (_isOperatorLocked) {
      final authUser = context.read<AuthProvider>().currentUser;
      if (authUser != null) {
        setState(() {
          _operators = [
            {'id': authUser.id, 'name': authUser.name},
          ];
          _selectedOperatorId = authUser.id;
          _selectedOperatorName = authUser.name;
          _operatorDisplayController.text = authUser.name.toUpperCase();
        });
      } else {
        setState(() {
          _operators = [];
          _selectedOperatorId = null;
          _selectedOperatorName = null;
          _operatorDisplayController.clear();
        });
      }
      return;
    }

    if (_selectedDepartment.isEmpty) {
      setState(() {
        _operators = [];
        _selectedOperatorId = null;
        _selectedOperatorName = null;
        _operatorDisplayController.clear();
      });
      return;
    }

    final deptLower = _selectedDepartment.toLowerCase();

    // Filter users
    final filteredUsers = _allUsers.where((u) {
      final userBhatti = u.assignedBhatti?.toLowerCase() ?? '';

      // 1. Keyword matching
      if (deptLower.contains('gita')) {
        if (userBhatti.contains('gita')) return true;
        if (u.departments.any((d) => d.team?.toLowerCase() == 'gita')) {
          return true;
        }
      } else if (deptLower.contains('bhatti') || deptLower.contains('sona')) {
        if (userBhatti.contains('bhatti') || userBhatti.contains('sona')) {
          return true;
        }
        if (u.departments.any((d) => d.team?.toLowerCase() == 'sona')) {
          return true;
        }
      }

      // 2. Exact match fallback
      if (userBhatti == deptLower) return true;

      // 3. Include Supervisors/Managers if they don't have specific assignments but are production roles
      if ((u.role == UserRole.productionManager ||
              u.role == UserRole.bhattiSupervisor) &&
          u.assignedBhatti == null) {
        return true;
      }

      return false;
    }).toList();

    setState(() {
      _operators = filteredUsers
          .map((u) => {'id': u.id, 'name': u.name})
          .toList();

      // Reset selected operator if not in list
      if (_selectedOperatorId != null &&
          !_operators.any((op) => op['id'] == _selectedOperatorId)) {
        _selectedOperatorId = null;
        _selectedOperatorName = null;
        _operatorDisplayController.clear();
      }
    });
  }

  void _onSemiProductChanged(Product? product) {
    setState(() {
      _selectedSemiProduct = product;
      _selectedFinishedProduct = null;
      _avgBoxWeight = null;
      _standardWeightGm = 0;
      _weightValidation = null;
      _actualAvgWeightController.text = '0';
      _unitsProducedController.text = '0';
      _totalFinishedWeightKg = 0;
      _cuttingWasteController.text = '0';
      _packagingItems.clear();
      _weightBalance = {};
      _weightBalanceValid = false;
      _isOverweight = false;
      _overweightRemark = '';

      if (product == null) {
        _finishedProducts = [];
      } else {
        _finishedProducts = _allFinishedProducts.where((p) {
          return p.allowedSemiFinishedIds.contains(product.id);
        }).toList();
      }
    });

    if (_finishedProducts.isEmpty && product != null) {
      _showWarning(
        'No Finished Goods are linked to ${product.name}. Check Product Configuration.',
      );
    }

    _refreshBatchDerivedValues();
  }

  void _onBatchCountChanged(String value) {
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);
    final normalized = parsed == null ? 0 : (parsed < 0 ? 0 : parsed);

    setState(() {
      _batchCount = normalized;
    });
    _refreshBatchDerivedValues();
  }

  void _onFinishedProductChanged(Product? product) {
    setState(() {
      _selectedFinishedProduct = product;
      _standardWeightGm = product?.unitWeightGrams ?? 0;
      _tolerancePercent = 5.0;
      _actualAvgWeightController.text = '0';
      _weightValidation = null;
      _unitsProducedController.text = '0';
      _totalFinishedWeightKg = 0;
      _cuttingWasteController.text = '0';
      _packagingItems.clear();
      _weightBalance = {};
      _weightBalanceValid = false;
      _isOverweight = false;
      _overweightRemark = '';
    });
    _calculateWeightBalance();
  }

  void _onBoxesCountChanged(String value) async {
    final boxCount = int.tryParse(value) ?? 0;
    final boxWeightKg = _resolveSemiBoxWeightKg();
    
    // Recalculate total weight based on boxes × standard box weight
    if (boxCount > 0 && boxWeightKg > 0) {
      final totalWeight = boxCount * boxWeightKg;
      _totalBatchWeightController.text = totalWeight.toStringAsFixed(3);
    } else {
      _totalBatchWeightController.text = '0';
    }

    setState(() {
      // Always show standard box weight from master data
      _avgBoxWeight = boxWeightKg > 0 ? boxWeightKg : null;
    });
    
    // Resolve stock plan from service
    if (_selectedSemiProduct != null && boxCount > 0) {
      final plan = await _cuttingBatchService.resolveStockPlan(
        semiFinishedProductId: _selectedSemiProduct!.id,
        departmentName: _selectedDepartment,
        batchCount: _batchCount,
        boxesCount: boxCount,
      );
      setState(() {
        _resolvedStockPlan = plan;
      });
    } else {
      setState(() {
        _resolvedStockPlan = null;
      });
    }
    
    _calculateWeightBalance();
  }

  void _onActualAvgWeightChanged(String value) {
    final actual = double.tryParse(value) ?? 0;
    if (_selectedFinishedProduct != null && actual > 0) {
      final maxWeight = _selectedFinishedProduct!.maxWeightGrams ?? 
                       (_standardWeightGm + 100);
      
      final isOverweight = actual > maxWeight;
      final overweightAmount = isOverweight ? actual - _standardWeightGm : 0;
      
      setState(() {
        _weightValidation = _cuttingBatchService.validateWeight(
          actual,
          _standardWeightGm,
          _tolerancePercent,
        );
        _isOverweight = isOverweight;
        _overweightRemark = isOverweight 
          ? 'EXTRA WEIGHT BATCH (+${overweightAmount.toStringAsFixed(1)} GM)'
          : '';
      });
    }
    _onUnitsProducedChanged(_unitsProducedController.text);
  }

  void _onUnitsProducedChanged(String value) {
    final units = int.tryParse(value) ?? 0;
    final avgWeight = double.tryParse(_actualAvgWeightController.text) ?? 0;

    if (units > 0 && avgWeight > 0) {
      setState(() {
        _totalFinishedWeightKg = (units * avgWeight) / 1000;
      });
    } else {
      setState(() => _totalFinishedWeightKg = 0);
    }
    _calculatePackaging();
    _calculateWeightBalance();
  }

  void _calculatePackaging() {
    if (_selectedFinishedProduct == null) return;

    final unitsProduced = int.tryParse(_unitsProducedController.text) ?? 0;
    if (unitsProduced <= 0) {
      setState(() => _packagingItems.clear());
      return;
    }

    final recipe = _selectedFinishedProduct!.packagingRecipe;
    if (recipe == null || recipe.isEmpty) {
      setState(() => _packagingItems.clear());
      return;
    }

    final unitsPerBundle =
        _selectedFinishedProduct!.unitsPerBundle ?? 10; // Default 10 if not set
    final safeUnitsPerBundle = unitsPerBundle <= 0 ? 10 : unitsPerBundle;
    final safeBatchCount = _batchCount > 0 ? _batchCount : 1;

    final newPackagingItems = <Map<String, dynamic>>[];

    for (var item in recipe) {
      final materialId = item['materialId'];
      if (materialId == null || materialId.toString().trim().isEmpty) {
        continue;
      }
      final qtyPerRule = (item['quantity'] as num?)?.toDouble() ?? 0.0;
      if (qtyPerRule <= 0) continue;
      final rawBasis = (item['usageBasis'] ?? '').toString().trim();
      final usageBasis = rawBasis == 'per_unit' ||
              rawBasis == 'per_bundle' ||
              rawBasis == 'per_batch'
          ? rawBasis
          : (item['isPerBundle'] == true ? 'per_bundle' : 'per_unit');
      final wastagePercent = (item['wastagePercent'] as num?)?.toDouble() ?? 0.0;

      double requiredQty = 0;
      switch (usageBasis) {
        case 'per_bundle':
          final bundles = (unitsProduced / safeUnitsPerBundle).ceilToDouble();
          requiredQty = bundles * qtyPerRule;
          break;
        case 'per_batch':
          requiredQty = safeBatchCount * qtyPerRule;
          break;
        case 'per_unit':
        default:
          requiredQty = unitsProduced * qtyPerRule;
          break;
      }
      if (wastagePercent > 0) {
        requiredQty = requiredQty * (1 + (wastagePercent / 100));
      }

      final packagingProduct = _packagingProducts.cast<Product?>().firstWhere(
        (p) => p?.id == materialId,
        orElse: () => null,
      );

      if (requiredQty > 0) {
        newPackagingItems.add({
          'materialId': materialId,
          'quantity': requiredQty,
          'materialName': item['name'] ?? packagingProduct?.name,
          'unit': item['unit'] ?? packagingProduct?.baseUnit,
          'usageBasis': usageBasis,
        });
      }
    }

    setState(() {
      _packagingItems.clear();
      _packagingItems.addAll(newPackagingItems);
    });
  }

  void _onCuttingWasteChanged(String value) {
    setState(() {});
    _calculateWeightBalance();
  }

  void _calculateWeightBalance() {
    final inputWeight = double.tryParse(_totalBatchWeightController.text) ?? 0;
    final outputWeight = _totalFinishedWeightKg;

    final actualScrapText = _cuttingWasteController.text.trim();
    final actualScrap = actualScrapText.isEmpty 
      ? 0.0 
      : (double.tryParse(actualScrapText) ?? 0.0);
    
    final expectedScrap = inputWeight - outputWeight;
    final wasteWeight = actualScrap > 0 ? actualScrap : expectedScrap;

    if (inputWeight > 0) {
      final balance = _cuttingBatchService.calculateWeightBalance(
        inputWeightKg: inputWeight,
        outputWeightKg: outputWeight,
        wasteWeightKg: wasteWeight,
      );

      setState(() {
        _weightBalance = balance;
        _weightBalanceValid = balance['weightBalanceValid'] as bool;
      });
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_batchCount <= 0) {
      _showError('Batch count must be at least 1');
      return false;
    }

    final boxesCount = int.tryParse(_boxesCountController.text) ?? 0;
    if (boxesCount <= 0) {
      _showError('Unable to calculate output boxes. Check unit rule setup.');
      return false;
    }

    if (_selectedSemiProduct == null) {
      _showError('Please select semi-finished product');
      return false;
    }

    // Validate semi-finished stock availability using resolved plan
    if (_resolvedStockPlan != null) {
      final isAvailable = _resolvedStockPlan!['isAvailable'] as bool? ?? false;
      if (!isAvailable) {
        final required = _resolvedStockPlan!['consumptionQuantity'] as double? ?? 0.0;
        final available = _resolvedStockPlan!['availableStock'] as double? ?? 0.0;
        final unit = _resolvedStockPlan!['consumptionUnit'] as String? ?? 'BOX';
        _showError(
          'Insufficient stock! Required: ${required.toStringAsFixed(1)} $unit, Available: ${available.toStringAsFixed(1)} $unit',
        );
        return false;
      }
    } else {
      // Fallback to BOX validation if plan not resolved
      final requiredBoxes = boxesCount;
      final availableStock = _selectedSemiProduct!.stock;
      if (requiredBoxes > availableStock) {
        _showError(
          'Insufficient stock! Required: $requiredBoxes BOX, Available: ${availableStock.toStringAsFixed(1)} BOX',
        );
        return false;
      }
    }

    if (_resolveSemiBoxWeightKg() <= 0) {
      _showError(
        'Semi-finished box weight is missing. Set box weight in Product Master.',
      );
      return false;
    }

    if (_selectedFinishedProduct == null) {
      _showError('Please select finished product');
      return false;
    }

    // STRICT GUARD: Data-Level Validation
    // Ensure the selected Finished Good is explicitly linked to the selected Semi-Finished Input.
    if (_selectedFinishedProduct!.allowedSemiFinishedIds.isEmpty ||
        !_selectedFinishedProduct!.allowedSemiFinishedIds.contains(
          _selectedSemiProduct!.id,
        )) {
      _showError(
        'GUARD VIOLATION: "${_selectedFinishedProduct!.name}" is not configured to be produced from "${_selectedSemiProduct!.name}". Please update Product Master.',
      );
      return false;
    }

    if (_selectedOperatorId == null) {
      _showError('Please select operator');
      return false;
    }

    if (_weightValidation == null || !_weightValidation!.isValid) {
      _showError('Weight validation failed. Check actual average weight.');
      return false;
    }

    final wasteWeight = double.tryParse(_cuttingWasteController.text) ?? 0;
    final expectedScrap = _calculateExpectedScrap();
    
    if (wasteWeight <= 0 && expectedScrap <= 0) {
      _showError('Scrap weight cannot be zero');
      return false;
    }

    if (!_weightBalanceValid) {
      // Show warning but allow submission
      _showWarning(
        'Weight balance difference exceeds 0.5%. '
        'Difference: ${(_weightBalance['weightDifferencePercent'] as double).toStringAsFixed(2)}%',
      );
    }

    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final authUser = context.read<AuthProvider>().currentUser;
      final operatorId = _selectedOperatorId ?? authUser?.id;
      final operatorName = _selectedOperatorName ?? authUser?.name;
      if (operatorId == null || operatorName == null) {
        setState(() => _isLoading = false);
        _showError('Operator details missing. Please re-open this page.');
        return;
      }

      final remarkText = _wasteRemarkController.text.trim();
      final finalRemark = _isOverweight
          ? (remarkText.isEmpty ? _overweightRemark : '$remarkText | $_overweightRemark')
          : remarkText;

      final success = await _cuttingBatchService.createCuttingBatch(
        semiFinishedProductId: _selectedSemiProduct!.id,
        semiFinishedProductName: _selectedSemiProduct!.name,
        finishedGoodId: _selectedFinishedProduct!.id,
        finishedGoodName: _selectedFinishedProduct!.name,
        departmentId: _selectedDepartment,
        departmentName: _selectedDepartment,
        operatorId: operatorId,
        operatorName: operatorName,
        supervisorId: authUser?.id ?? '',
        supervisorName: authUser?.name ?? 'Unknown',
        shift: ShiftType.day, // Defaulting as UI removed
        totalBatchWeightKg:
            double.tryParse(_totalBatchWeightController.text) ?? 0,
        standardWeightGm: _standardWeightGm,
        actualAvgWeightGm:
            double.tryParse(_actualAvgWeightController.text) ?? 0,
        tolerancePercent: _tolerancePercent,
        batchCount: _batchCount,
        unitsProduced: int.tryParse(_unitsProducedController.text) ?? 0,
        cuttingWasteKg: double.tryParse(_cuttingWasteController.text) ?? 0,
        wasteType: _wasteType,
        boxesCount: int.tryParse(_boxesCountController.text),
        packagingConsumptions: _packagingItems
            .where((i) => i['materialId'] != null && (i['quantity'] ?? 0) > 0)
            .toList(),
        wasteRemark: finalRemark.isNotEmpty ? finalRemark : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _showSuccess('Cutting batch created successfully');
          _resetForm();
          Navigator.pop(context, true);
        } else {
          final error =
              _cuttingBatchService.lastCreateBatchError?.trim().isNotEmpty ==
                  true
              ? _cuttingBatchService.lastCreateBatchError!
              : 'Failed to create cutting batch';
          _showError(error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error: $e');
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _selectedDate = DateTime.now();
    // _selectedShift = ShiftType.day; // Removed
    // Restore default dept
    if (_availableDepartments.isNotEmpty) {
      _selectedDepartment = _availableDepartments.first;
      _updateOperatorsList();
      _applyDepartmentProductFilters();
    }
    if (_isOperatorLocked) {
      final authUser = context.read<AuthProvider>().currentUser;
      _selectedOperatorId = authUser?.id;
      _selectedOperatorName = authUser?.name;
      _operatorDisplayController.text = (authUser?.name ?? '').toUpperCase();
    } else {
      _selectedOperatorId = null;
      _selectedOperatorName = null;
      _operatorDisplayController.clear();
    }
    _selectedSemiProduct = null;
    _selectedFinishedProduct = null;
    _batchCount = 0;
    _batchCountController.text = '0';
    _totalBatchWeightController.text = '0';
    _boxesCountController.text = '0';
    _boxesPerBatch = 0;
    _avgBoxWeight = null;
    _standardWeightGm = 0;
    _tolerancePercent = 5.0;
    _actualAvgWeightController.text = '0';
    _unitsProducedController.text = '0';
    _totalFinishedWeightKg = 0;
    _cuttingWasteController.text = '0';
    _wasteType = WasteType.scrap;
    _wasteRemarkController.clear();
    _weightValidation = null;
    _packagingItems.clear(); // Clear packaging
    _weightBalance = {};
    _weightBalanceValid = false;
    _refreshBatchDerivedValues();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.warning),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = Responsive.width(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.1,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCompactHeader(),
            Expanded(
              child: _isLoading && _semiProducts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (screenWidth > 900)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        _buildSessionCard(),
                                        const SizedBox(height: 16),
                                        _buildInputCard(),
                                        const SizedBox(height: 16),
                                        _buildOutputCard(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        _buildProgressCard(),
                                        const SizedBox(height: 16),
                                        _buildPackagingCard(),
                                        const SizedBox(height: 16),
                                        _buildWasteCard(),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildSessionCard(),
                                  const SizedBox(height: 16),
                                  _buildInputCard(),
                                  const SizedBox(height: 16),
                                  _buildOutputCard(),
                                  const SizedBox(height: 16),
                                  _buildProgressCard(),
                                  const SizedBox(height: 16),
                                  _buildPackagingCard(),
                                  const SizedBox(height: 16),
                                  _buildWasteCard(),
                                ],
                              ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _submitForm,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: Text(
                                  _isLoading
                                      ? 'PROCESSING...'
                                      : 'CONFIRM & SAVE BATCH',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              'New Cutting Batch',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.2,
              ),
            ),
          ),
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check_circle_rounded),
            tooltip: 'Save Batch',
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard() {
    return _buildEntryCard(
      title: 'SESSION DETAILS',
      icon: Icons.access_time_filled_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Batch Date',
                  value: _selectedDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<String>(
                  label: 'Production Unit',
                  value: _selectedDepartment,
                  items: _availableDepartments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: _isDepartmentLocked
                      ? null
                      : (v) {
                          if (v == null) return;
                          setState(() {
                            _selectedDepartment = v;
                          });
                          _updateOperatorsList();
                          _applyDepartmentProductFilters();
                          _refreshBatchDerivedValues();
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _isOperatorLocked
                    ? _buildTextField(
                        controller: _operatorDisplayController,
                        label: 'Team / Operator',
                        readOnly: true,
                      )
                    : _buildDropdown<String>(
                        label: 'Team / Operator',
                        value: _selectedOperatorId,
                        items: _operators
                            .map(
                              (op) => DropdownMenuItem(
                                value: op['id'],
                                child: Text(op['name']?.toUpperCase() ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          final op = _operators
                              .cast<Map<String, dynamic>?>()
                              .firstWhere(
                                (o) => o?['id'] == v,
                                orElse: () => null,
                              );
                          if (op == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selected operator not found'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _selectedOperatorId = v;
                            _selectedOperatorName = op['name'];
                            _operatorDisplayController.text = (op['name'] ?? '')
                                .toUpperCase();
                          });
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return _buildEntryCard(
      title: 'MATERIAL INPUT',
      icon: Icons.download_rounded,
      child: Column(
        children: [
          _buildDropdown<Product>(
            label: 'Semi-Finished Soap Base (INPUT)',
            value: _selectedSemiProduct,
            items: _semiProducts
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(
                      '${p.name} (${_formatStock(p.stock)} BOX)',
                    ),
                  ),
                )
                .toList(),
            onChanged: _onSemiProductChanged,
          ),
          if (_semiProducts.isEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No Semi-Finished product mapped for ${_selectedDepartment.isEmpty ? 'this unit' : _selectedDepartment}.',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _batchCountController,
                  label: 'Batch Count',
                  onChanged: _onBatchCountChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.integer(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _boxesCountController,
                  label: 'Boxes',
                  readOnly: !_canEditBoxes(),
                  onChanged: (value) {
                    _onBoxesCountChanged(value);
                    _calculateWeightBalance();
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.integer(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Output Rule: $_boxesPerBatch boxes per batch',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (_hasLowStock()) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _resolvedStockPlan != null
                          ? 'INSUFFICIENT STOCK! Required: ${(_resolvedStockPlan!['consumptionQuantity'] as double).toStringAsFixed(1)} ${_resolvedStockPlan!['consumptionUnit']}, Available: ${(_resolvedStockPlan!['availableStock'] as double).toStringAsFixed(1)} ${_resolvedStockPlan!['consumptionUnit']}'
                          : 'INSUFFICIENT STOCK! Required: ${_boxesCountController.text} BOX, Available: ${_formatStock(_selectedSemiProduct!.stock)} BOX',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_avgBoxWeight != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AVG BOX WEIGHT: ${_avgBoxWeight!.toStringAsFixed(2)} KG',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.info,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutputCard() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return _buildEntryCard(
      title: 'OUTPUT CONFIGURATION',
      icon: Icons.settings_rounded,
      child: Column(
        children: [
          _buildDropdown<Product>(
            label: 'Final Product Variant (OUTPUT)',
            value: _selectedFinishedProduct,
            items: _finishedProducts
                .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                .toList(),
            onChanged: _onFinishedProductChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STD WEIGHT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_standardWeightGm.toStringAsFixed(1)} GM',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _actualAvgWeightController,
                  label: 'Actual Avg Weight',
                  suffix: 'GM',
                  onChanged: _onActualAvgWeightChanged,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    NormalizedNumberInputFormatter.decimal(
                      keepZeroWhenEmpty: true,
                      maxDecimalPlaces: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_weightValidation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _weightValidation!.isValid
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _weightValidation!.isValid
                      ? AppColors.success
                      : AppColors.error,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _weightValidation!.isValid
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    size: 16,
                    color: _weightValidation!.isValid
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _weightValidation!.message.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _weightValidation!.isValid
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isOverweight) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _overweightRemark.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return _buildEntryCard(
      title: 'PRODUCTION PROGRESS',
      icon: Icons.speed_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _unitsProducedController,
                  label: 'Units Produced',
                  suffix: 'PCS',
                  onChanged: _onUnitsProducedChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.integer(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL FINISHED WEIGHT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_totalFinishedWeightKg.toStringAsFixed(3)} KG',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_weightBalance.isNotEmpty) ...[
            Text(
              'WEIGHT RECONCILIATION',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildReconciliationItem(
              'INPUT (SF)',
              '${(double.tryParse(_totalBatchWeightController.text) ?? 0).toStringAsFixed(2)} KG',
            ),
            _buildReconciliationItem(
              'OUTPUT (FG)',
              '${_totalFinishedWeightKg.toStringAsFixed(2)} KG',
            ),
            _buildReconciliationItem(
              'CUTTING SCRAP',
              '${(double.tryParse(_cuttingWasteController.text) ?? 0).toStringAsFixed(2)} KG',
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DIFFERENCE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
                Text(
                  '${(_weightBalance['weightDifferenceKg'] as double).toStringAsFixed(3)} KG (${(_weightBalance['weightDifferencePercent'] as double).toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _weightBalanceValid
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReconciliationItem(String label, String val) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: onSurfaceVariant,
            ),
          ),
          Text(
            val,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteCard() {
    final expectedScrap = _calculateExpectedScrap();
    return _buildEntryCard(
      title: 'WASTAGE & REMARKS',
      icon: Icons.delete_sweep_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EXPECTED SCRAP (AUTO)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.info,
                  ),
                ),
                Text(
                  '${expectedScrap.toStringAsFixed(2)} KG',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cuttingWasteController,
                  label: 'Actual Scrap Weight (Optional)',
                  suffix: 'KG',
                  onChanged: _onCuttingWasteChanged,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    NormalizedNumberInputFormatter.decimal(
                      keepZeroWhenEmpty: true,
                      maxDecimalPlaces: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Leave empty to use auto-calculated scrap weight',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Waste Type: CUTTING SCRAP (LOCKED)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _wasteRemarkController,
            label: 'Process Remarks',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingCard() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return _buildEntryCard(
      title: 'ANCILLARY CONSUMPTION',
      icon: Icons.inventory_2_rounded,
      child: Column(
        children: [
          if (_packagingItems.isEmpty)
            Text(
              'NO PACKAGING RULES DEFINED',
              style: TextStyle(
                fontSize: 10,
                color: onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _packagingItems.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _packagingItems[index];
                final product = _packagingProducts.firstWhere(
                  (p) => p.id == item['materialId'],
                  orElse: () => Product(
                    id: '',
                    name: 'Unknown',
                    sku: '',
                    itemType: ProductType.finishedGood,
                    type: ProductTypeEnum.finished,
                    category: '',
                    stock: 0,
                    baseUnit: '',
                    conversionFactor: 1,
                    price: 0,
                    status: '',
                    unitWeightGrams: 0,
                    createdAt: '',
                  ),
                );
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_rounded,
                        size: 16,
                        color: onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${(item['quantity'] as double).toStringAsFixed(1)} ${product.baseUnit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEntryCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    int maxLines = 1,
    Function(String)? onChanged,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        child: Text(
          DateFormat('dd MMM yyyy').format(value),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _operatorDisplayController.dispose();
    _batchCountController.dispose();
    _totalBatchWeightController.dispose();
    _boxesCountController.dispose();
    _actualAvgWeightController.dispose();
    _unitsProducedController.dispose();
    _cuttingWasteController.dispose();
    _wasteRemarkController.dispose();
    super.dispose();
  }
}
