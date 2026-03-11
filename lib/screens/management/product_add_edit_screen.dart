import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../models/types/product_types.dart';
import '../../../models/types/user_types.dart';
import '../../../services/products_service.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../services/settings_service.dart';
import '../../../services/master_data_service.dart';
import '../../../services/formulas_service.dart';
import '../../../services/suppliers_service.dart';
import '../../../utils/app_toast.dart';
import '../../../utils/normalized_number_input_formatter.dart';
import '../../../widgets/ui/themed_filter_chip.dart';
import '../../../widgets/ui/themed_tab_bar.dart';
import '../../../constants/role_access_matrix.dart';
import 'dart:io';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProductAddEditScreen extends StatefulWidget {
  final String? productType; // 'Raw Material', 'Finished Good', etc.
  final Product? product; // For Editing
  final String? supplierId;
  final String? supplierName;
  final bool isReadOnly;
  final bool isMasterDataMode;

  const ProductAddEditScreen({
    super.key,
    this.productType,
    this.product,
    this.supplierId,
    this.supplierName,
    this.isReadOnly = false,
    this.isMasterDataMode = false,
  });

  @override
  State<ProductAddEditScreen> createState() => _ProductAddEditScreenState();
}

class _ProductAddEditScreenState extends State<ProductAddEditScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _gstController = TextEditingController();
  final _discountController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _weightController = TextEditingController();
  final _shelfLifeController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _buyQtyController = TextEditingController(text: '0');
  final _getFreeController = TextEditingController(text: '0');
  final _unitsPerBundleController = TextEditingController(text: '10');
  final _standardInputController = TextEditingController();
  final _standardOutputController = TextEditingController();
  final _conversionFactorController = TextEditingController(text: '1.0');
  final _secondaryPriceController = TextEditingController();

  String? _selectedImagePath;

  // Packaging Config
  List<Map<String, dynamic>> _packagingRecipe = [];
  List<Product> _packagingMaterials = [];
  List<Supplier> _allSuppliers = [];
  bool _loadingSuppliers = false;

  // Dropdowns
  String _baseUnit = 'Pcs';
  String? _secondaryUnit;
  PackagingType? _selectedPackagingType;

  // Status state
  bool _isActive = true;
  bool _isSaving = false;
  ProductsService get _productsService => context.read<ProductsService>();
  SettingsService get _settingsService => context.read<SettingsService>();
  MasterDataService get _masterDataService => context.read<MasterDataService>();
  FormulasService get _formulasService => context.read<FormulasService>();
  late String _currentType;
  String _normalizeTypeLabel(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return ProductType.finishedGood.value;

    final normalized = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    bool has(String token) => normalized.contains(token);

    final isSemiLike = has('semi') && (has('finish') || has('finis'));
    if (isSemiLike) return ProductType.semiFinishedGood.value;
    if (has('finished good') || has('finished goods') || has('finish good')) {
      return ProductType.finishedGood.value;
    }
    if (has('raw')) return ProductType.rawMaterial.value;
    if (has('traded')) return ProductType.tradedGood.value;
    if (has('packag')) return ProductType.packagingMaterial.value;
    if (has('oil') || has('liquid')) return ProductType.oilsLiquids.value;
    if (has('chemical') || has('additive')) {
      return ProductType.chemicalsAdditives.value;
    }

    return raw;
  }

  String _normalizeBhattiKey(String? value) {
    final raw = (value ?? '').trim().toLowerCase();
    if (raw.contains('gita') || raw.contains('geeta')) return 'gita';
    if (raw.contains('sona')) return 'sona';
    return 'sona';
  }

  String _bhattiLabelFromKey(String key) =>
      key == 'gita' ? 'Gita Bhatti' : 'Sona Bhatti';

  List<String> _semiAllowedDepartmentIds(String bhattiKey) {
    final normalized = bhattiKey == 'gita' ? 'gita' : 'sona';
    return ['bhatti:$normalized', '${normalized}_bhatti'];
  }

  void _syncSemiDefaultBatchValues() {
    if (!_isSemiFinished) return;

    _baseUnit = 'Kg';

    if (_standardOutputController.text.trim().isEmpty) {
      final key = _normalizeBhattiKey(_semiAssignedBhatti);
      _standardOutputController.text = key == 'gita' ? '7' : '6';
    }
    if (_weightController.text.trim().isEmpty) {
      _weightController.text = '10';
    }
  }

  String get _normalizedCurrentType => _normalizeTypeLabel(_currentType);
  bool get _isFinishedGood =>
      _normalizedCurrentType == ProductType.finishedGood.value;
  bool get _isTradedGood =>
      _normalizedCurrentType == ProductType.tradedGood.value;
  bool get _isSemiFinished =>
      _normalizedCurrentType == ProductType.semiFinishedGood.value;
  bool get _isPackagingMaterial =>
      _normalizedCurrentType == ProductType.packagingMaterial.value;
  bool get _hasPricing =>
      (_isFinishedGood || _isTradedGood) && !widget.isMasterDataMode;
  bool get _supportsSupplierSelection => !_isSemiFinished && !_isFinishedGood;

  int get _calculatedTabLength {
    int length = 1; // Basic always
    if (!_isSemiFinished) length += 1; // Details
    if (_isFinishedGood) length += 2; // Packaging & Production
    if (_isSemiFinished) length += 1; // Formula tab
    if (_hasPricing) length += 2; // Pricing & Scheme
    return length;
  }

  // Configuration Data
  List<Product> _semiFinishedGoods = [];
  List<OrgDepartment> _departments = [];
  List<ProductCategory> _globalCategories = [];
  List<String> _selectedSemiIds = [];
  List<String> _selectedDeptIds = [];
  List<String> _units = [];
  List<DynamicProductType> _allProductTypes = [];
  bool _isLoadingConfig = true;

  // Supplier State
  String? _selectedSupplierId;
  String? _selectedSupplierName;
  String _semiAssignedBhatti = 'Sona Bhatti';

  // Semi-Finished Formula Import State (for SF products)
  List<Formula> _availableFormulas = [];
  String? _selectedFormulaId;

  @override
  void initState() {
    super.initState();
    _currentType = _normalizeTypeLabel(widget.productType);
    if (_isPackagingMaterial) {
      _selectedPackagingType = PackagingType.box;
    }

    // DEBUG LOG:
    debugPrint('Current Type: $_currentType');
    debugPrint('Is FG: $_isFinishedGood');
    debugPrint('Is Semi: $_isSemiFinished');
    _syncSemiDefaultBatchValues();

    // Initialize TabController
    _tabController = TabController(
      length: _calculatedTabLength,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );

    if (widget.product != null) {
      _prefillData();
      _tabController.dispose();
      _tabController = TabController(
        length: _calculatedTabLength,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200),
      );
      _selectedSupplierId = widget.product!.supplierId;
      _selectedSupplierName = widget.product!.supplierName;
    } else {
      // New Product
      if (widget.supplierId != null) {
        _selectedSupplierId = widget.supplierId;
        _selectedSupplierName = widget.supplierName;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreImagePathIfMissing();
      _loadConfigData();
      if (_supportsSupplierSelection) {
        _loadSuppliers();
      } else {
        _selectedSupplierId = null;
        _selectedSupplierName = null;
      }
    });
  }

  Future<void> _loadSuppliers() async {
    setState(() => _loadingSuppliers = true);
    try {
      final service = context.read<SuppliersService>();
      final suppliers = await service.getSuppliers();
      if (mounted) {
        setState(() {
          _allSuppliers = suppliers;
          _loadingSuppliers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading suppliers: $e');
      if (mounted) setState(() => _loadingSuppliers = false);
    }
  }

  Future<void> _restoreImagePathIfMissing() async {
    final product = widget.product;
    if (product == null) return;

    final existingPath = _sanitizeImagePath(_selectedImagePath);
    if (existingPath != null) {
      final isLocalFilePath =
          _isAppDocumentsPath(existingPath) || _isAbsoluteFilePath(existingPath);
      if (!isLocalFilePath) {
        return;
      }

      final existingFile = await _resolveImageFile(existingPath);
      if (existingFile != null) {
        return;
      }

      debugPrint(
        '🖼️ RECOVERY: Existing image path missing on disk, trying recovery: $existingPath',
      );
    }

    final recoveredPath = await _discoverLocalImagePathForProduct(product);
    if (recoveredPath == null || !mounted) return;

    setState(() {
      _selectedImagePath = recoveredPath;
    });

    if (recoveredPath == existingPath) return;

    try {
      final userId = context.read<AuthProvider>().currentUser?.id ?? 'system';
      await _productsService.updateProduct(
        id: product.id,
        userId: userId,
        localImagePath: recoveredPath,
      );
      debugPrint('🖼️ RECOVERY: Restored localImagePath = $recoveredPath');
    } catch (e) {
      debugPrint('🖼️ RECOVERY: Failed to persist localImagePath: $e');
    }
  }

  Future<String?> _discoverLocalImagePathForProduct(Product product) async {
    final productId = product.id.trim();
    if (productId.isEmpty) return null;

    final normalizedType = _normalizeTypeLabel(product.itemType.value);
    final orderedFolders = {
      if (normalizedType == ProductType.finishedGood.value) 'finished',
      if (normalizedType != ProductType.finishedGood.value) 'traded',
      'finished',
      'traded',
    }.toList(growable: false);

    const extensions = ['png', 'jpg', 'jpeg', 'webp'];
    final appDocDir = await getApplicationDocumentsDirectory();

    for (final folder in orderedFolders) {
      for (final ext in extensions) {
        final relativePath = 'app_documents/products/$folder/$productId.$ext';
        final absolutePath =
            '${appDocDir.path}${Platform.pathSeparator}products'
            '${Platform.pathSeparator}$folder${Platform.pathSeparator}$productId.$ext';
        final file = File(absolutePath);
        if (await file.exists()) {
          return relativePath;
        }
      }
    }

    return null;
  }

  void _prefillData() {
    final p = widget.product!;
    final normalizedType = ProductType.fromString(p.itemType.value).value;
    final isSemiType = normalizedType == ProductType.semiFinishedGood.value;
    _nameController.text = p.name;
    _skuController.text = p.sku;
    _categoryController.text = p.category;
    _priceController.text = p.price.toString();
    _mrpController.text = p.mrp?.toString() ?? '';
    _gstController.text = p.gstRate?.toString() ?? (isSemiType ? '' : '18');
    _discountController.text = p.defaultDiscount?.toString() ?? '';
    _reorderLevelController.text = p.reorderLevel?.toString() ?? '';
    _weightController.text = p.unitWeightGrams.toString();
    _shelfLifeController.text = p.shelfLife?.toString() ?? '';
    _baseUnit = p.baseUnit;
    _selectedPackagingType = p.packagingType;
    _isActive = p.status == 'active';
    _selectedImagePath = _sanitizeImagePath(p.localImagePath);
    debugPrint('🖼️ PREFILL: Loading image path: $_selectedImagePath');
    _selectedSemiIds = List.from(p.allowedSemiFinishedIds);
    _selectedDeptIds = List.from(p.allowedDepartmentIds);
    if (p.unitsPerBundle != null) {
      _unitsPerBundleController.text = p.unitsPerBundle.toString();
    }
    if (p.packagingRecipe != null) {
      _packagingRecipe = p.packagingRecipe!
          .map((item) => _normalizePackagingRecipeItem(item))
          .toList(growable: true);
    }
    if (p.standardBatchInputKg != null) {
      _standardInputController.text = p.standardBatchInputKg.toString();
    }
    if (p.standardBatchOutputPcs != null) {
      _standardOutputController.text = p.standardBatchOutputPcs.toString();
    }
    _secondaryUnit = p.secondaryUnit;
    _conversionFactorController.text = p.conversionFactor.toString();
    _secondaryPriceController.text = p.secondaryPrice?.toString() ?? '';
    // Sync current type with product type if editing
    _currentType = _normalizeTypeLabel(p.itemType.value);

    if (_isSemiFinished) {
      _baseUnit = 'Kg';
      final deptValues = <String>[
        if ((p.departmentId ?? '').trim().isNotEmpty) p.departmentId!,
        ...p.allowedDepartmentIds,
      ];
      final bhattiKey = _normalizeBhattiKey(deptValues.join(' '));
      _semiAssignedBhatti = _bhattiLabelFromKey(bhattiKey);

      final configuredBoxes =
          p.boxesPerBatch ?? p.standardBatchOutputPcs?.round();
      if (configuredBoxes != null && configuredBoxes > 0) {
        _standardOutputController.text = configuredBoxes.toString();
      }

      if (p.unitWeightGrams > 0) {
        final boxWeightKg = p.unitWeightGrams / 1000;
        _weightController.text = boxWeightKg
            .toStringAsFixed(3)
            .replaceFirst(RegExp(r'([.]?0+)$'), '');
      } else {
        _weightController.clear();
      }
    }
  }

  double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _resolveRecipeUsageBasis(Map<String, dynamic> item) {
    final raw = (item['usageBasis'] ?? '').toString().trim().toLowerCase();
    if (raw == 'per_unit' || raw == 'per_bundle' || raw == 'per_batch') {
      return raw;
    }
    return item['isPerBundle'] == true ? 'per_bundle' : 'per_unit';
  }

  Map<String, dynamic> _normalizePackagingRecipeItem(Map<String, dynamic> item) {
    final usageBasis = _resolveRecipeUsageBasis(item);
    return {
      'materialId': item['materialId'],
      'name': item['name'],
      'unit': item['unit'],
      'quantity': _asDouble(item['quantity'], fallback: 1.0),
      'usageBasis': usageBasis,
      'isPerBundle': usageBasis == 'per_bundle',
      'wastagePercent': _asDouble(item['wastagePercent'], fallback: 0.0),
    };
  }

  List<Map<String, dynamic>> _buildSanitizedPackagingRecipe() {
    final sanitized = <Map<String, dynamic>>[];
    for (final raw in _packagingRecipe) {
      final normalized = _normalizePackagingRecipeItem(raw);
      final materialId = (normalized['materialId'] ?? '').toString().trim();
      final quantity = _asDouble(normalized['quantity']);
      if (materialId.isEmpty || quantity <= 0) continue;
      final material = _packagingMaterials.cast<Product?>().firstWhere(
        (p) => p?.id == materialId,
        orElse: () => null,
      );
      sanitized.add({
        ...normalized,
        'materialId': materialId,
        'name': (normalized['name'] ?? material?.name ?? '').toString(),
        'unit': (normalized['unit'] ?? material?.baseUnit ?? '').toString(),
        'quantity': quantity,
        'wastagePercent': _asDouble(normalized['wastagePercent']),
      });
    }
    return sanitized;
  }

  Future<void> _loadConfigData() async {
    try {
      final results = await Future.wait([
        _productsService.getProducts(
          itemType: ProductType.semiFinishedGood.value,
        ),
        _settingsService.getDepartments(),
        _masterDataService.getCategories(),
        _masterDataService.getUnits(),
        _masterDataService.getProductTypes(),
        _formulasService.getFormulas(),
      ]);

      final packagingMaterials = await _productsService.getProducts().then(
        (products) =>
            products.where((p) => p.type == ProductTypeEnum.packaging).toList(),
      );

      if (mounted) {
        setState(() {
          _semiFinishedGoods = results[0] as List<Product>;
          _departments = results[1] as List<OrgDepartment>;
          _globalCategories = (results[2] as List<ProductCategory>)
              .where((c) => c.itemType == _currentType)
              .toList();
          _units = results[3] as List<String>;
          _allProductTypes = results[4] as List<DynamicProductType>;
          _availableFormulas = results[5] as List<Formula>;
          final linkedFormula = _latestFormulaForProduct(
            widget.product?.id,
            formulas: _availableFormulas,
          );
          if (linkedFormula != null) {
            _selectedFormulaId = linkedFormula.id;
          }
          _packagingMaterials = packagingMaterials;

          // Ensure baseUnit is in valid list
          if (!_units.contains(_baseUnit)) {
            if (_units.isNotEmpty) _baseUnit = _units.first;
          }
          _isLoadingConfig = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingConfig = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _gstController.dispose();
    _discountController.dispose();
    _reorderLevelController.dispose();
    _weightController.dispose();
    _shelfLifeController.dispose();
    _barcodeController.dispose();
    _buyQtyController.dispose();
    _getFreeController.dispose();
    _unitsPerBundleController.dispose();
    _standardInputController.dispose();
    _standardOutputController.dispose();
    _conversionFactorController.dispose();
    _secondaryPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    if (currentUser == null ||
        RoleAccessMatrix.finalRoleFor(currentUser.role) !=
            FinalUserRole.admin) {
      AppToast.showError(context, 'Only Admins can delete products.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${widget.product!.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await _productsService.deleteProduct(
        widget.product!.id,
        userId: currentUser.id,
        userName: currentUser.name,
      );
      if (mounted) {
        AppToast.showSuccess(context, 'Product deleted successfully');
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to delete product: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty) {
      AppToast.showError(context, 'Product Name is required');
      return;
    }

    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    if (!_canWriteProducts(currentUser)) {
      AppToast.showError(context, 'Your role cannot edit product master data.');
      return;
    }

    // Semi-Finished must import a production formula from Formula Master
    if (_isSemiFinished &&
        (_selectedFormulaId == null || _selectedFormulaId!.trim().isEmpty)) {
      AppToast.showError(
        context,
        'Please import a Formula from Formula Master',
      );
      return;
    }

    final semiBhattiKey = _normalizeBhattiKey(_semiAssignedBhatti);
    final semiBoxesPerBatch =
        int.tryParse(_standardOutputController.text.trim()) ?? 0;
    final semiBoxWeightKg = double.tryParse(_weightController.text.trim()) ?? 0;
    if (_isSemiFinished) {
      if (semiBoxesPerBatch <= 0) {
        AppToast.showError(context, 'Boxes per batch must be greater than 0');
        return;
      }
      if (semiBoxWeightKg <= 0) {
        AppToast.showError(context, 'Box weight must be greater than 0 KG');
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final departmentIdForSave = _isSemiFinished
          ? '${semiBhattiKey}_bhatti'
          : widget.product?.departmentId;
      final allowedDepartmentIdsForSave = _isSemiFinished
          ? _semiAllowedDepartmentIds(semiBhattiKey)
          : _selectedDeptIds;
      final unitWeightGramsForSave = _isSemiFinished
          ? semiBoxWeightKg * 1000
          : (double.tryParse(_weightController.text) ?? 0);
      final supplierIdForSave = _supportsSupplierSelection
          ? _selectedSupplierId
          : '';
      final supplierNameForSave = _supportsSupplierSelection
          ? _selectedSupplierName
          : '';
      final parsedPrice = double.tryParse(_priceController.text) ?? 0;
      final parsedMrp = double.tryParse(_mrpController.text);
      final parsedGst = double.tryParse(_gstController.text);
      final parsedDiscount = double.tryParse(_discountController.text);
      final parsedSecondaryPrice = double.tryParse(
        _secondaryPriceController.text,
      );
      final parsedConversionFactor =
          double.tryParse(_conversionFactorController.text) ?? 1.0;
      final parsedUnitsPerBundle = int.tryParse(_unitsPerBundleController.text);
      final parsedBarcode = _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim();
      final recipeForSave = _isFinishedGood
          ? _buildSanitizedPackagingRecipe()
          : <Map<String, dynamic>>[];
      final packagingTypeForSave = _isPackagingMaterial
          ? _selectedPackagingType?.name
          : '';

      final priceForSave = _isSemiFinished ? 0.0 : parsedPrice;
      final purchasePriceForSave = _isSemiFinished ? 0.0 : parsedPrice;
      final mrpForSave = _isSemiFinished ? null : parsedMrp;
      final gstForSave = _isSemiFinished ? null : parsedGst;
      final discountForSave = _isSemiFinished ? null : parsedDiscount;
      final secondaryUnitForSave = _isSemiFinished ? null : _secondaryUnit;
      final conversionFactorForSave = _isSemiFinished
          ? 1.0
          : parsedConversionFactor;
      final secondaryPriceForSave = _isSemiFinished
          ? null
          : parsedSecondaryPrice;
      final unitsPerBundleForSave = _isSemiFinished
          ? null
          : parsedUnitsPerBundle;
      Product? result;
      if (widget.product != null) {
        // Update
        final updatedProduct = widget.product!.copyWith(
          // Product name is locked after creation to protect data consistency.
          name: widget.product!.name,
          sku: _skuController.text.isEmpty
              ? widget.product!.sku
              : _skuController.text,
          itemType: ProductType.fromString(_currentType),
          type: _getEnumType(_currentType),
          departmentId: departmentIdForSave,
          category: _categoryController.text,
          baseUnit: _baseUnit,
          price: priceForSave,
          purchasePrice: purchasePriceForSave,
          mrp: mrpForSave,
          gstRate: gstForSave,
          defaultDiscount: discountForSave,
          reorderLevel: double.tryParse(_reorderLevelController.text),
          supplierId: supplierIdForSave,
          supplierName: supplierNameForSave,
          unitWeightGrams: unitWeightGramsForSave,
          shelfLife: double.tryParse(_shelfLifeController.text),
          status: _isActive ? 'active' : 'inactive',
          allowedSemiFinishedIds: _selectedSemiIds,
          allowedDepartmentIds: allowedDepartmentIdsForSave,
          boxesPerBatch: _isSemiFinished ? semiBoxesPerBatch : null,
          standardBatchOutputPcs: _isSemiFinished
              ? semiBoxesPerBatch.toDouble()
              : null,
          unitsPerBundle: unitsPerBundleForSave,
          packagingType: _isPackagingMaterial ? _selectedPackagingType : null,
          packagingRecipe: recipeForSave,
          barcode: parsedBarcode,
          secondaryUnit: secondaryUnitForSave,
          conversionFactor: conversionFactorForSave,
          secondaryPrice: secondaryPriceForSave,
        );

        await _productsService.updateProduct(
          id: widget.product!.id,
          userId: auth.currentUser?.id ?? 'system',
          userName: auth.currentUser?.name,
          name: updatedProduct.name,
          sku: updatedProduct.sku,
          itemType: updatedProduct.itemType.value,
          type: updatedProduct.type.name,
          departmentId: updatedProduct.departmentId,
          category: updatedProduct.category,
          baseUnit: updatedProduct.baseUnit,
          secondaryUnit: updatedProduct.secondaryUnit,
          conversionFactor: updatedProduct.conversionFactor,
          price: updatedProduct.price,
          secondaryPrice: updatedProduct.secondaryPrice,
          mrp: updatedProduct.mrp,
          gstRate: updatedProduct.gstRate,
          defaultDiscount: updatedProduct.defaultDiscount,
          reorderLevel: updatedProduct.reorderLevel,
          unitWeightGrams: updatedProduct.unitWeightGrams,
          shelfLife: updatedProduct.shelfLife,
          status: updatedProduct.status,
          allowedSemiFinishedIds: updatedProduct.allowedSemiFinishedIds,
          allowedDepartmentIds: updatedProduct.allowedDepartmentIds,
          boxesPerBatch: updatedProduct.boxesPerBatch,
          standardBatchOutputPcs: updatedProduct.standardBatchOutputPcs,
          unitsPerBundle: updatedProduct.unitsPerBundle,
          packagingType: packagingTypeForSave,
          packagingRecipe: updatedProduct.packagingRecipe,
          barcode: parsedBarcode,
          supplierId: supplierIdForSave,
          supplierName: supplierNameForSave,
          entityType: _determineEntityType(_currentType),
          localImagePath: _selectedImagePath,
        );
        result = updatedProduct.copyWith(
          entityType: _determineEntityType(_currentType),
        );
      } else {
        // Create
        result = await _productsService.createProduct(
          name: _nameController.text,
          sku: _skuController.text.isEmpty
              ? 'AUTO-${DateTime.now().millisecond}'
              : _skuController.text,
          itemType: _currentType,
          type: _getEnumType(_currentType).name,
          departmentId: departmentIdForSave,
          category: _categoryController.text,
          stock: 0,
          baseUnit: _baseUnit,
          secondaryUnit: secondaryUnitForSave,
          conversionFactor: conversionFactorForSave,
          price: priceForSave,
          secondaryPrice: secondaryPriceForSave,
          purchasePrice: purchasePriceForSave,
          mrp: mrpForSave,
          gstRate: gstForSave,
          defaultDiscount: discountForSave,
          status: _isActive ? 'active' : 'inactive',
          unitWeightGrams: unitWeightGramsForSave,
          userId: auth.currentUser?.id ?? 'system',
          userName: auth.currentUser?.name ?? 'System',
          shelfLife: double.tryParse(_shelfLifeController.text),
          supplierId: supplierIdForSave,
          supplierName: supplierNameForSave,
          entityType: _determineEntityType(_currentType),
          allowedSemiFinishedIds: _selectedSemiIds,
          allowedDepartmentIds: allowedDepartmentIdsForSave,
          boxesPerBatch: _isSemiFinished ? semiBoxesPerBatch : null,
          standardBatchOutputPcs: _isSemiFinished
              ? semiBoxesPerBatch.toDouble()
              : null,
          unitsPerBundle: unitsPerBundleForSave,
          packagingType: packagingTypeForSave,
          packagingRecipe: recipeForSave,
          barcode: parsedBarcode,
          localImagePath: _selectedImagePath,
        );

        // Rename temp image file to actual product ID
        if (_selectedImagePath != null &&
            _selectedImagePath!.contains('temp_') &&
            result.id.isNotEmpty) {
          await _renameImageToProductId(result.id);
        }
      }

      if (_isSemiFinished) {
        await _importSelectedFormulaForProduct(result);
      }

      if (mounted) {
        context.pop(result);
        AppToast.showSuccess(
          context,
          widget.product != null ? 'Product Updated' : 'Product Created',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showError(context, 'Error saving product: $e');
      }
    }
  }

  ProductTypeEnum _getEnumType(String typeString) {
    final normalized = _normalizeTypeLabel(typeString);
    if (normalized == ProductType.rawMaterial.value) return ProductTypeEnum.raw;
    if (normalized == ProductType.packagingMaterial.value) {
      return ProductTypeEnum.packaging;
    }
    if (normalized == ProductType.finishedGood.value) {
      return ProductTypeEnum.finished;
    }
    if (normalized == ProductType.semiFinishedGood.value) {
      return ProductTypeEnum.semi;
    }
    if (normalized == ProductType.tradedGood.value) {
      return ProductTypeEnum.traded;
    }
    return ProductTypeEnum.raw; // default
  }

  Formula? _formulaById(String? formulaId, {List<Formula>? formulas}) {
    final id = formulaId?.trim();
    if (id == null || id.isEmpty) return null;
    final source = formulas ?? _availableFormulas;
    for (final formula in source) {
      if (formula.id == id) return formula;
    }
    return null;
  }

  Formula? _latestFormulaForProduct(
    String? productId, {
    List<Formula>? formulas,
  }) {
    final id = productId?.trim();
    if (id == null || id.isEmpty) return null;

    final matches = (formulas ?? _availableFormulas)
        .where((f) => f.productId.trim() == id)
        .toList();
    if (matches.isEmpty) return null;

    matches.sort((a, b) {
      final versionCompare = b.version.compareTo(a.version);
      if (versionCompare != 0) return versionCompare;
      final aUpdated =
          DateTime.tryParse(a.updatedAt) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bUpdated =
          DateTime.tryParse(b.updatedAt) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bUpdated.compareTo(aUpdated);
    });

    return matches.first;
  }

  Future<void> _importSelectedFormulaForProduct(Product product) async {
    final selected = _formulaById(_selectedFormulaId);
    if (selected == null) {
      throw Exception('Selected formula not found. Please reselect formula.');
    }

    final importedItems = selected.items
        .map(
          (item) => FormulaItem(
            materialId: item.materialId,
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            wastagePercent: item.wastagePercent,
          ),
        )
        .toList(growable: false);
    final importedWastageConfig = WastageConfig(
      type: selected.wastageConfig.type,
      value: selected.wastageConfig.value,
      unit: selected.wastageConfig.unit,
      isReusable: selected.wastageConfig.isReusable,
      wastageMaterialId: selected.wastageConfig.wastageMaterialId,
    );

    final existing = _latestFormulaForProduct(product.id);
    if (existing == null) {
      final newFormulaId = await _formulasService.addFormula(
        productId: product.id,
        productName: product.name,
        category: product.category,
        items: importedItems,
        status: importedItems.isNotEmpty ? 'completed' : 'incomplete',
        version: 1,
        assignedBhatti: _semiAssignedBhatti,
        wastageConfig: importedWastageConfig,
      );
      if (newFormulaId == null || newFormulaId.trim().isEmpty) {
        throw Exception('Failed to import formula for this product.');
      }
      _selectedFormulaId = newFormulaId;
    } else if (existing.id != selected.id) {
      await _formulasService.updateFormula(
        id: existing.id,
        productName: product.name,
        category: product.category,
        items: importedItems,
        status: importedItems.isNotEmpty ? 'completed' : 'incomplete',
        version: existing.version + 1,
        assignedBhatti: _semiAssignedBhatti,
        wastageConfig: importedWastageConfig,
      );
      _selectedFormulaId = existing.id;
    } else if (existing.productName != product.name ||
        existing.category != product.category ||
        existing.assignedBhatti != _semiAssignedBhatti) {
      await _formulasService.updateFormula(
        id: existing.id,
        productName: product.name,
        category: product.category,
        assignedBhatti: _semiAssignedBhatti,
        version: existing.version + 1,
      );
      _selectedFormulaId = existing.id;
    }

    final refreshed = await _formulasService.getFormulas();
    if (!mounted) return;
    setState(() {
      _availableFormulas = refreshed;
      final linked = _latestFormulaForProduct(product.id, formulas: refreshed);
      _selectedFormulaId = linked?.id ?? _selectedFormulaId;
    });
  }

  Future<void> _openFormulaMasterAndRefresh() async {
    await context.push('/dashboard/management/formulas');
    final refreshed = await _formulasService.getFormulas();
    if (!mounted) return;
    setState(() {
      _availableFormulas = refreshed;
      final linked = _latestFormulaForProduct(
        widget.product?.id,
        formulas: refreshed,
      );
      _selectedFormulaId = linked?.id ?? _selectedFormulaId;
    });
  }

  String _determineEntityType(String typeString) {
    final normalized = _normalizeTypeLabel(typeString);
    if (normalized == ProductType.semiFinishedGood.value) {
      return 'semi_finished';
    }
    if (normalized == ProductType.finishedGood.value) {
      return 'finished';
    }
    return 'raw';
  }

  bool _canWriteProducts(AppUser? user) {
    final role = user?.role;
    if (role == null) return false;
    return role == UserRole.admin ||
        role == UserRole.owner ||
        role == UserRole.productionManager ||
        role == UserRole.salesManager ||
        role == UserRole.dispatchManager ||
        role == UserRole.dealerManager ||
        role == UserRole.productionSupervisor ||
        role == UserRole.bhattiSupervisor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canEdit = context.select<AuthProvider, bool>(
      (auth) => _canWriteProducts(auth.currentUser),
    );
    final bool effectiveReadOnly = widget.isReadOnly || !canEdit;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          effectiveReadOnly
              ? 'View $_currentType'
              : widget.product != null
              ? 'Edit $_currentType'
              : 'Add New $_currentType',
        ),
        bottom: _isLoadingConfig
            ? null
            : ThemedTabBar(
                controller: _tabController,
                tabs: [
                  const Tab(
                    icon: Icon(Icons.info_outline, size: 16),
                    text: 'Basic',
                  ),
                  if (_hasPricing)
                    const Tab(
                      icon: Icon(Icons.attach_money, size: 16),
                      text: 'Pricing',
                    ),
                  if (_isFinishedGood)
                    const Tab(
                      icon: Icon(Icons.inventory_2_outlined, size: 16),
                      text: 'Packaging',
                    ),
                  if (_isSemiFinished)
                    const Tab(
                      icon: Icon(Icons.science_outlined, size: 16),
                      text: 'Formula',
                    ),
                  if (!_isSemiFinished)
                    const Tab(
                      icon: Icon(Icons.settings, size: 16),
                      text: 'Details',
                    ),
                  if (_isFinishedGood)
                    const Tab(
                      icon: Icon(Icons.factory, size: 16),
                      text: 'Production',
                    ),
                  if (_hasPricing)
                    const Tab(
                      icon: Icon(Icons.local_offer, size: 16),
                      text: 'Scheme',
                    ),
                ],
              ),
        actions: [
          if (widget.product != null && !effectiveReadOnly)
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final isAdmin =
                    auth.currentUser != null &&
                    RoleAccessMatrix.finalRoleFor(auth.currentUser!.role) ==
                        FinalUserRole.admin;
                if (!isAdmin) return const SizedBox.shrink();

                return IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: _isSaving ? null : _handleDelete,
                  tooltip: 'Delete Product',
                );
              },
            ),
          if (!effectiveReadOnly)
            TextButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'SAVE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
        ],
      ),
      body: _isLoadingConfig
          ? const Center(child: CircularProgressIndicator())
          : AbsorbPointer(
              absorbing: effectiveReadOnly,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicTab(),
                  if (_hasPricing) _buildPricingTab(),
                  if (_isFinishedGood) _buildPackagingTab(),
                  if (_isSemiFinished) _buildFormulaTab(),
                  if (!_isSemiFinished) _buildInventoryTab(),
                  if (_isFinishedGood) _buildProductionTab(),
                  if (_hasPricing) _buildSchemeTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final materialNameLabel = _isFinishedGood
        ? 'Final Product Name (e.g. Sona Pure 150g) *'
        : _isPackagingMaterial
        ? 'Packaging Name *'
        : 'Material Name *';
    final materialNameHint = _isFinishedGood
        ? 'e.g. Datt Oil Soap 150g'
        : _isSemiFinished
        ? 'e.g. Soap Base / Noodles'
        : _isPackagingMaterial
        ? 'e.g. Paper Label 100x50, 5-Ply Carton Box'
        : 'e.g. Caustic Soda';
    final categoryLabel = _isPackagingMaterial ? 'Packaging Category' : 'Category';
    final categoryHint = _isPackagingMaterial
        ? 'e.g. Primary, Secondary, Label, Carton'
        : 'Search or type...';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Product Type'),
          const SizedBox(height: 8),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final canWrite = _canWriteProducts(auth.currentUser);
              final isExistingProduct = widget.product != null;
              final canChangeType = !isExistingProduct || canWrite;

              // Build dropdown items list
              final Set<String> typeNames = {};
              if (_allProductTypes.isNotEmpty) {
                typeNames.addAll(_allProductTypes.map((t) => t.name));
              } else {
                typeNames.addAll(ProductType.values.map((e) => e.value));
              }
              typeNames.add(_currentType);
              final List<String> dropdownItems = typeNames.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: canChangeType
                          ? colorScheme.surface
                          : colorScheme.surfaceContainerHighest,
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: colorScheme.surface,
                        value: _currentType,
                        isExpanded: true,
                        // IF existing product AND not admin, disable dropdown
                        onChanged: canChangeType
                            ? (val) {
                                if (val != null) {
                                  final cleanVal = val.trim();
                                  if (cleanVal != _currentType) {
                                    if (isExistingProduct) {
                                      _showTypeChangeConfirmation(cleanVal);
                                    } else {
                                      _updateType(cleanVal);
                                    }
                                  }
                                }
                              }
                            : null,
                        items: dropdownItems.map((typeName) {
                          return DropdownMenuItem(
                            value: typeName,
                            child: Row(
                              children: [
                                Icon(
                                  _getTypeIcon(typeName),
                                  size: 20,
                                  color: canChangeType
                                      ? _getTypeColor(typeName)
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    typeName,
                                    style: TextStyle(
                                      color: canChangeType
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                      fontWeight: typeName == _currentType
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (context) {
                          return dropdownItems.map((typeName) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getTypeIcon(typeName),
                                    size: 20,
                                    color: canChangeType
                                        ? _getTypeColor(typeName)
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      typeName,
                                      style: TextStyle(
                                        color: canChangeType
                                            ? colorScheme.onSurface
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                  if (!canChangeType) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Only Admin/Store Incharge can change type of an existing product.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            materialNameLabel,
            _nameController,
            materialNameHint,
            helperText: widget.product != null
                ? 'Product name is locked after creation.'
                : 'Unique name for this item',
            readOnly: widget.product != null,
          ),
          if (!_isSemiFinished) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildCategoryAutocomplete(
                        label: categoryLabel,
                        hintText: categoryHint,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Code/SKU (Auto if empty)',
                        _skuController,
                        'e.g. RM-001',
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildCategoryAutocomplete(
                        label: categoryLabel,
                        hintText: categoryHint,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Code/SKU (Auto if empty)',
                        _skuController,
                        'e.g. RM-001',
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_isPackagingMaterial) ...[
              const SizedBox(height: 16),
              _buildPackagingTypeSelector(),
            ],
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUnitSelector(),
                      const SizedBox(height: 16),
                      _buildSecondaryUnitSelector(),
                      const SizedBox(height: 16),
                      _buildConversionFactorInput(),
                      const SizedBox(height: 16),
                      _buildStatusSelector(),
                    ],
                  );
                }
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildUnitSelector()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSecondaryUnitSelector()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildConversionFactorInput()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatusSelector()),
                      ],
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            const SizedBox(height: 16),
            _buildStatusSelector(),
          ],
          const SizedBox(height: 16),
          if (_isFinishedGood || _isTradedGood) ...[
            _buildImagePicker(),
            const SizedBox(height: 16),
          ],
          if (!_isSemiFinished && !_isFinishedGood) ...[
            const SizedBox(height: 24),
            Text(
              'Preferred Supplier',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _loadingSuppliers
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    initialValue: _selectedSupplierId,
                    decoration: InputDecoration(
                      labelText: 'Select Supplier',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ..._allSuppliers.map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedSupplierId = val;
                        if (val == null) {
                          _selectedSupplierName = null;
                        } else {
                          final supplier = _allSuppliers
                              .cast<Supplier?>()
                              .firstWhere(
                                (s) => s?.id == val,
                                orElse: () => null,
                              );
                          _selectedSupplierName = supplier?.name;
                        }
                      });
                    },
                  ),
          ],
        ],
      ),
    );
  }

  void _updateType(String val) {
    // Dispose old controller to avoid errors
    try {
      _tabController.dispose();
    } catch (_) {}

    setState(() {
      _currentType = _normalizeTypeLabel(val);
      if (!_supportsSupplierSelection) {
        _selectedSupplierId = null;
        _selectedSupplierName = null;
      }
      if (_isSemiFinished) {
        _syncSemiDefaultBatchValues();
      }
      if (_isPackagingMaterial && _selectedPackagingType == null) {
        _selectedPackagingType = PackagingType.box;
      }
      if (!_isPackagingMaterial) {
        _selectedPackagingType = null;
      }
      _tabController = TabController(
        length: _calculatedTabLength,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200),
      );
      _loadConfigData();
    });
    if (_supportsSupplierSelection && _allSuppliers.isEmpty) {
      _loadSuppliers();
    }
  }

  void _showTypeChangeConfirmation(String newVal) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('CRITICAL: Change Type?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are changing the product type from "$_currentType" to "$newVal".',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              ' WARNING:',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(' All existing category links will be RESET.'),
            const Text(' Pricing & Scheme tabs might be HIDDEN or SHOWN.'),
            const Text(
              ' Production formulas and inventory flow will be DISRUPTED.',
            ),
            const SizedBox(height: 16),
            const Text(
              'This action is only intended for fixing incorrectly added master data. Are you absolutely sure?',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateType(newVal);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('YES, CHANGE IT'),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildTextField(
                      'Price (per $_baseUnit)',
                      _priceController,
                      'e.g. 25.00',
                      numeric: true,
                    ),
                    const SizedBox(height: 16),
                    _buildSecondaryPriceInput(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'MRP',
                      _mrpController,
                      'e.g. 30.00',
                      numeric: true,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Price (per $_baseUnit)',
                      _priceController,
                      'e.g. 25.00',
                      numeric: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSecondaryPriceInput()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'MRP',
                      _mrpController,
                      'e.g. 30.00',
                      numeric: true,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildGstSelector(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Default Discount (%)',
                      _discountController,
                      '0',
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildGstSelector()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Default Discount (%)',
                      _discountController,
                      '0',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.24)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.info),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select materials from Packaging Material master. Define Qty and usage basis per unit/per bundle/per batch.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Units per Bundle',
            _unitsPerBundleController,
            '10',
            helperText:
                'How many units are packed in one bundle? (Default: 10)',
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Packaging Recipe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _packagingRecipe.add({
                      'materialId': null,
                      'quantity': 1.0,
                      'usageBasis': 'per_bundle',
                      'isPerBundle': true,
                      'wastagePercent': 0.0,
                    });
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_packagingRecipe.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Center(
                child: Text(
                  'No packaging items defined.\nAdd wrapper, box, or labels.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _packagingRecipe.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _packagingRecipe[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 450;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildRecipeMaterialSelect(item),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _packagingRecipe.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildRecipeQtyInput(item)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildRecipeTypeToggle(item)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildRecipeWastageInput(item),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildRecipeMaterialSelect(item),
                          ),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: _buildRecipeQtyInput(item)),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildRecipeTypeToggle(item),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildRecipeWastageInput(item),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _packagingRecipe.removeAt(index);
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductionTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Production Configuration (CRITICAL)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Define strict rules for where and how this product is produced.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _buildMultiSelect(
            label: 'Allowed Semi-Finished Input',
            helperText:
                'Select which Semi-Finished Soap Base (from Bhatti) is used to produce this Final Product variant.',
            items: _semiFinishedGoods
                .map((e) => MultiSelectItem(e.id, e.name))
                .toList(),
            selectedIds: _selectedSemiIds,
            onChanged: (ids) => setState(() => _selectedSemiIds = ids),
          ),
          const SizedBox(height: 16),
          _buildMultiSelect(
            label: 'Allowed Production Departments',
            helperText:
                'Select departments OR specific units (Teams) where this product can be produced.\nFor example, select "Production - Sona" to limit visibility to Sona Bhatti only.',
            items: _departments.expand<MultiSelectItem>((dept) {
              final deptOption = MultiSelectItem(dept.id, dept.name);
              if (dept.teams.isNotEmpty) {
                final teamOptions = dept.teams.map((team) {
                  return MultiSelectItem(
                    '${dept.id}:${team.code}',
                    '${dept.name} - ${team.name}',
                  );
                });
                return [deptOption, ...teamOptions];
              }
              return [deptOption];
            }).toList(),
            selectedIds: _selectedDeptIds,
            onChanged: (ids) => setState(() => _selectedDeptIds = ids),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Standard Batch Configuration',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Stock will be deducted from Semi-Finished and added to Finished Goods on production entry based on this ratio.',
                    style: TextStyle(fontSize: 12, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildTextField(
                      'Consumption (SF)',
                      _standardInputController,
                      'e.g. 100',
                      helperText: 'KG of Semi-Finished Input per Batch',
                      numeric: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        Icons.arrow_downward,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    _buildTextField(
                      'Output (FG)',
                      _standardOutputController,
                      'e.g. 1000',
                      helperText: 'Pieces produced per Batch',
                      numeric: true,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Consumption (SF)',
                      _standardInputController,
                      'e.g. 100',
                      helperText: 'KG of Semi-Finished Input per Batch',
                      numeric: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 12,
                      right: 12,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      'Output (FG)',
                      _standardOutputController,
                      'e.g. 1000',
                      helperText: 'Pieces produced per Batch',
                      numeric: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    final reorderLabel = _isPackagingMaterial
        ? 'Reorder Level (Packaging Stock)'
        : 'Reorder Level';
    final weightLabel = _isPackagingMaterial ? 'Pack Weight (Grams)' : 'Weight (Grams)';
    final shelfLifeLabel = _isPackagingMaterial
        ? 'Shelf Life (Days, Optional)'
        : 'Shelf Life (Days)';
    final barcodeLabel = _isPackagingMaterial
        ? 'Barcode / GTIN (Supplier Pack)'
        : 'Barcode / GTIN';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
            reorderLabel,
            _reorderLevelController,
            'e.g. 50',
            helperText: _isPackagingMaterial
                ? 'Minimum on-hand stock before new purchase is triggered.'
                : null,
          ),
          const SizedBox(height: 16),
          if (!_isSemiFinished) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildTextField(
                        weightLabel,
                        _weightController,
                        'e.g. 150',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        shelfLifeLabel,
                        _shelfLifeController,
                        'e.g. 365',
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        weightLabel,
                        _weightController,
                        'e.g. 150',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        shelfLifeLabel,
                        _shelfLifeController,
                        'e.g. 365',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              barcodeLabel,
              _barcodeController,
              'Scan or type',
              suffix: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanBarcode,
              ),
            ),
          ] else ...[
            // Semi-Finished only needs Shelf Life here, Weight is irrelevant (Bulk)
            _buildTextField(
              shelfLifeLabel,
              _shelfLifeController,
              'e.g. 365',
            ),
          ],
        ],
      ),
    );
  }

  /// Formula tab for Semi-Finished products - import only (no inline recipe edit)
  Widget _buildFormulaTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final formulaOptions = List<Formula>.from(_availableFormulas)
      ..sort((a, b) {
        final nameCompare = a.productName.toLowerCase().compareTo(
          b.productName.toLowerCase(),
        );
        if (nameCompare != 0) return nameCompare;
        return b.version.compareTo(a.version);
      });
    final selectedFormulaValue =
        formulaOptions.any((f) => f.id == _selectedFormulaId)
        ? _selectedFormulaId
        : null;
    final selectedFormula = _formulaById(
      selectedFormulaValue,
      formulas: formulaOptions,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.24)),
            ),
            child: Row(
              children: [
                Icon(Icons.science, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select formula from Formula Master. Raw materials are managed only there.',
                    style: TextStyle(color: AppColors.info, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Bhatti Assignment & Batch Output',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _semiAssignedBhatti,
            decoration: const InputDecoration(
              labelText: 'Assigned Bhatti Unit',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Sona Bhatti',
                child: Text('Sona Bhatti'),
              ),
              DropdownMenuItem(
                value: 'Gita Bhatti',
                child: Text('Gita Bhatti'),
              ),
            ],
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _semiAssignedBhatti = val;
                if (_standardOutputController.text.trim().isEmpty) {
                  _syncSemiDefaultBatchValues();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return Column(
                  children: [
                    _buildTextField(
                      'Boxes per Batch *',
                      _standardOutputController,
                      'e.g. 6',
                      helperText: '1 batch me kitne box bante hain',
                      numeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Weight per Box (KG) *',
                      _weightController,
                      'e.g. 10',
                      helperText: '1 box ka total weight (KG)',
                      numeric: true,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Boxes per Batch *',
                      _standardOutputController,
                      'e.g. 6',
                      helperText: '1 batch me kitne box bante hain',
                      numeric: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Weight per Box (KG) *',
                      _weightController,
                      'e.g. 10',
                      helperText: '1 box ka total weight (KG)',
                      numeric: true,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Production Formula Source (MANDATORY)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 8),
          if (formulaOptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No formula found. Create formula in Formula Master first, then select it here.',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: selectedFormulaValue,
              decoration: const InputDecoration(
                labelText: 'Import From Formula Master',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select formula'),
              items: formulaOptions.map((formula) {
                final bhattiLabel =
                    (formula.assignedBhatti ?? '').trim().isEmpty
                    ? 'All'
                    : formula.assignedBhatti!;
                final subtitle =
                    '${formula.productName} [v${formula.version} | $bhattiLabel]';
                return DropdownMenuItem<String>(
                  value: formula.id,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedFormulaId = val);
              },
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _openFormulaMasterAndRefresh,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open Formula Master'),
            ),
          ),
          if (selectedFormula != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.24),
                ),
              ),
              child: Text(
                'Selected: ${selectedFormula.productName} | Status: ${selectedFormula.status}',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchemeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Promotional Scheme Config',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Buy Qty',
                  _buyQtyController,
                  'e.g. 10',
                  numeric: true,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.integer(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Get Free Qty',
                  _getFreeController,
                  'e.g. 1',
                  numeric: true,
                  inputFormatters: [
                    NormalizedNumberInputFormatter.integer(
                      keepZeroWhenEmpty: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    String? helperText,
    bool numeric = false,
    Widget? suffix,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            suffixIcon: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final theme = Theme.of(context);
    final resolvedValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: theme.colorScheme.surface,
          value: resolvedValue,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }

  Widget _buildUnitSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Unit of Measure *'),
        const SizedBox(height: 8),
        _isSemiFinished
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'KG (Fixed)',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : _buildDropdown(
                _baseUnit,
                _units.isEmpty
                    ? ['Pcs', 'Kg', 'Ltr', 'Box', 'Ton', 'Bag']
                    : _units,
                (val) {
                  if (val == null) return;
                  setState(() => _baseUnit = val);
                },
              ),
        const SizedBox(height: 4),
        Text(
          'Base unit for stock tracking',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSecondaryUnitSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Secondary Unit (Optional)'),
        const SizedBox(height: 8),
        _isSemiFinished
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'None',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            : _buildDropdown(
                _secondaryUnit ?? 'None',
                ['None', 'Pcs', 'Kg', 'Ltr', 'Box', 'Ton', 'Bag'],
                (val) {
                  setState(() {
                    if (val == 'None' || val == null) {
                      _secondaryUnit = null;
                      _conversionFactorController.text = '1.0';
                    } else {
                      _secondaryUnit = val;
                    }
                  });
                },
              ),
        const SizedBox(height: 4),
        Text(
          'E.g., Box, Carton, Dozen',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildPackagingTypeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _selectedPackagingType ?? PackagingType.box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Packaging Form *'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PackagingType>(
              dropdownColor: colorScheme.surface,
              value: selected,
              isExpanded: true,
              items: PackagingType.values
                  .map(
                    (type) => DropdownMenuItem<PackagingType>(
                      value: type,
                      child: Text(type.value),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() => _selectedPackagingType = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Used to classify material like Label, Box, Bag, Film, Tape.',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildConversionFactorInput() {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = _secondaryUnit != null && !_isSemiFinished;
    // [LOCKED] Conversion helper must mirror typed factor (e.g. 1 Box = 20 Bdl).
    final parsedFactor = double.tryParse(
      _conversionFactorController.text.trim(),
    );
    final effectiveFactor = (parsedFactor == null || parsedFactor <= 0)
        ? null
        : (parsedFactor % 1 == 0
              ? parsedFactor.toInt().toString()
              : parsedFactor
                    .toStringAsFixed(3)
                    .replaceFirst(RegExp(r'([.]?0+)$'), ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel('Conversion Factor'),
            if (isEnabled) ...[
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: AppColors.info),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _conversionFactorController,
          keyboardType: TextInputType.number,
          readOnly: !isEnabled,
          onChanged: (val) {
            setState(() {}); // trigger rebuild for auto-suggest secondary price
          },
          decoration: InputDecoration(
            hintText: 'e.g. 12',
            helperText: isEnabled
                ? '1 $_secondaryUnit = ${effectiveFactor ?? 'X'} $_baseUnit'
                : 'Requires Secondary Unit',
            helperMaxLines: 2,
            filled: !isEnabled,
            fillColor: !isEnabled ? colorScheme.surfaceContainerHighest : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryPriceInput() {
    final colorScheme = Theme.of(context).colorScheme;
    final conversionFactor =
        double.tryParse(_conversionFactorController.text) ?? 1.0;
    final basePrice = double.tryParse(_priceController.text) ?? 0.0;
    final isEnabled = _secondaryUnit != null && conversionFactor > 1.0;

    // Auto-calculating suggested price if empty
    String hintText = 'e.g. 0.00';
    String? helperText = isEnabled
        ? 'Price for 1 $_secondaryUnit'
        : 'Requires Conversion Factor > 1';

    if (isEnabled && _secondaryPriceController.text.isEmpty && basePrice > 0) {
      final suggestedPrice = basePrice * conversionFactor;
      hintText = 'Auto: ${suggestedPrice.toStringAsFixed(2)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel(
              isEnabled
                  ? 'Secondary Price (per $_secondaryUnit)'
                  : 'Secondary Price',
            ),
            if (isEnabled) ...[
              const SizedBox(width: 4),
              Icon(Icons.lightbulb_outline, size: 14, color: AppColors.warning),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _secondaryPriceController,
          keyboardType: TextInputType.number,
          readOnly: !isEnabled,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            filled: !isEnabled,
            fillColor: !isEnabled ? colorScheme.surfaceContainerHighest : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Status'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SwitchListTile(
            title: Text(
              _isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: _isActive
                    ? AppColors.success
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            value: _isActive,
            activeThumbColor: AppColors.success,
            onChanged: (val) => setState(() => _isActive = val),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildGstSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('GST Rate (%)'),
        const SizedBox(height: 8),
        _buildDropdown(
          _gstController.text.isEmpty ? '18' : _gstController.text,
          ['0', '5', '12', '18', '28'],
          (val) {
            setState(() => _gstController.text = val!);
          },
        ),
      ],
    );
  }

  Widget _buildRecipeMaterialSelect(Map<String, dynamic> item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: colorScheme.surface,
            value: item['materialId'],
            hint: const Text('Select Material', style: TextStyle(fontSize: 13)),
            isExpanded: true,
            isDense: true,
            items: _packagingMaterials.map((p) {
              return DropdownMenuItem(
                value: p.id,
                child: Text(
                  p.name,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                item['materialId'] = val;
                final p = _packagingMaterials.cast<Product?>().firstWhere(
                  (e) => e?.id == val,
                  orElse: () => null,
                );
                if (p != null) {
                  item['name'] = p.name;
                  item['unit'] = p.baseUnit;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeQtyInput(Map<String, dynamic> item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qty',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: (item['quantity'] ?? 0).toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [
            NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
          ],
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            item['quantity'] = double.tryParse(val) ?? 0.0;
          },
        ),
      ],
    );
  }

  Widget _buildRecipeTypeToggle(Map<String, dynamic> item) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _resolveRecipeUsageBasis(item);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage Basis',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: selected,
          isDense: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'per_unit', child: Text('Per Unit')),
            DropdownMenuItem(value: 'per_bundle', child: Text('Per Bundle')),
            DropdownMenuItem(value: 'per_batch', child: Text('Per Batch')),
          ],
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              item['usageBasis'] = val;
              item['isPerBundle'] = val == 'per_bundle';
            });
          },
        ),
      ],
    );
  }

  Widget _buildRecipeWastageInput(Map<String, dynamic> item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extra / Wastage %',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: _asDouble(item['wastagePercent']).toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [
            NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
          ],
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            item['wastagePercent'] = _asDouble(val);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryAutocomplete({
    String label = 'Category',
    String hintText = 'Search or type...',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return _globalCategories.map((e) => e.name);
            }
            return _globalCategories
                .where(
                  (c) => c.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                )
                .map((e) => e.name);
          },
          onSelected: (String selection) {
            _categoryController.text = selection;
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                if (textEditingController.text.isEmpty &&
                    _categoryController.text.isNotEmpty) {
                  textEditingController.text = _categoryController.text;
                }

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (val) => _categoryController.text = val,
                );
              },
        ),
      ],
    );
  }

  Widget _buildMultiSelect({
    required String label,
    required String helperText,
    required List<MultiSelectItem> items,
    required List<String> selectedIds,
    required ValueChanged<List<String>> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedIds.contains(item.id);
            return ThemedFilterChip(
              label: item.name,
              selected: isSelected,
              showCheck: true,
              textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: () {
                final newIds = List<String>.from(selectedIds);
                if (isSelected) {
                  newIds.remove(item.id);
                } else {
                  newIds.add(item.id);
                }
                onChanged(newIds);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getTypeColor([String? type]) {
    final t = (type ?? _currentType).toLowerCase();
    if (t.contains('raw')) return Colors.brown;
    if (t.contains('packaging')) return AppColors.warning;
    if (t.contains('semi')) return Colors.deepOrange;
    if (t.contains('traded')) return AppColors.info;
    if (t.contains('finish')) return AppColors.info;
    if (t.contains('oil') || t.contains('liquid')) return AppColors.info;
    if (t.contains('chemical') || t.contains('add')) {
      return AppColors.lightPrimary;
    }
    return const Color(0xFF4f46e5);
  }

  IconData _getTypeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('raw')) return Icons.auto_awesome_mosaic;
    if (t.contains('packaging')) return Icons.inventory_2;
    if (t.contains('semi')) return Icons.whatshot;
    if (t.contains('traded')) return Icons.store;
    if (t.contains('finish')) return Icons.verified;
    if (t.contains('oil') || t.contains('liquid')) return Icons.opacity;
    if (t.contains('chemical') || t.contains('add')) return Icons.science;
    return Icons.category;
  }

  Widget _buildImagePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    final displayImagePath = _sanitizeImagePath(_selectedImagePath);
    final hasImagePath = displayImagePath != null;
    debugPrint(
      '🖼️ BUILD IMAGE PICKER: _selectedImagePath = $_selectedImagePath',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel('Product Image'),
            const SizedBox(width: 8),
            Icon(Icons.image_outlined, size: 16, color: AppColors.info),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              if (hasImagePath) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      (_isAppDocumentsPath(displayImagePath) ||
                          _isAbsoluteFilePath(displayImagePath))
                      ? FutureBuilder<File?>(
                          future: _resolveImageFile(displayImagePath),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 120,
                                width: 120,
                                color: colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.file(
                                snapshot.data!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
                                    width: 120,
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              );
                            }
                            return Container(
                              height: 120,
                              width: 120,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          displayImagePath,
                          height: 120,
                          width: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayImagePath.split(RegExp(r'[\\\/]+')).last,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ] else ...[
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'No image selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(
                      hasImagePath ? 'Replace Image' : 'Choose Image',
                    ),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (hasImagePath)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _selectedImagePath = null);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Recommended: 500x500px PNG/JPG, < 500KB',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;
      final file = File(filePath);

      // Validate file size
      final fileSize = await file.length();
      if (fileSize > 500 * 1024) {
        if (mounted) {
          AppToast.showError(
            context,
            'Image size should be less than 500KB. Current: ${(fileSize / 1024).toStringAsFixed(0)}KB',
          );
        }
        return;
      }

      // Generate filename: use existing product ID or temp ID for new products
      final ext = filePath.split('.').last.toLowerCase();
      final productIdRaw =
          widget.product?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final safeProductId = _sanitizeFileStem(productIdRaw);
      final fileName = '$safeProductId.$ext';

      final targetFolder = _isFinishedGood ? 'finished' : 'traded';
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${appDocDir.path}/products/$targetFolder');

      // Create directory if not exists
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Delete old image if exists (safe cleanup)
      if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
        try {
          final oldPath = _selectedImagePath!.replaceFirst(
            'app_documents/',
            '${appDocDir.path}/',
          );
          final oldFile = File(oldPath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          debugPrint('Failed to delete old image: $e');
          // Continue anyway - not critical
        }
      }

      // Copy new image
      final targetPath = '${targetDir.path}/$fileName';
      await file.copy(targetPath);

      // Store relative path for DB
      final relativePath = 'app_documents/products/$targetFolder/$fileName';

      if (mounted) {
        setState(() {
          _selectedImagePath = relativePath;
        });
        AppToast.showSuccess(context, 'Image saved: $fileName');
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
      if (mounted) {
        AppToast.showError(context, 'Failed to save image: $e');
      }
    }
  }

  Future<void> _scanBarcode() async {
    if (Platform.isWindows) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Barcode scanning is not supported on Windows Desktop.',
          ),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Scan Barcode')),
        body: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                Navigator.pop(context, barcode.rawValue);
                break;
              }
            }
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _renameImageToProductId(String productId) async {
    if (_selectedImagePath == null || !_selectedImagePath!.contains('temp_')) {
      return;
    }

    // Cache auth provider before async operations
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 'system';

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final oldPath = _selectedImagePath!.replaceFirst(
        'app_documents/',
        '${appDocDir.path}/',
      );
      final oldFile = File(oldPath);

      if (!await oldFile.exists()) return;

      // Extract extension and folder
      final ext = oldPath.split('.').last;
      final targetFolder = _isFinishedGood ? 'finished' : 'traded';
      final safeProductId = _sanitizeFileStem(productId);
      final newFileName = '$safeProductId.$ext';
      final newPath = '${appDocDir.path}/products/$targetFolder/$newFileName';

      // Rename file
      await oldFile.rename(newPath);

      // Update path in memory
      final newRelativePath =
          'app_documents/products/$targetFolder/$newFileName';
      if (mounted) {
        setState(() {
          _selectedImagePath = newRelativePath;
        });
      }

      // Update DB with correct path
      await _productsService.updateProduct(
        id: productId,
        userId: userId,
        localImagePath: newRelativePath,
      );
    } catch (e) {
      debugPrint('Failed to rename temp image: $e');
      // Non-critical error, continue
    }
  }

  String? _sanitizeImagePath(String? rawPath) {
    if (rawPath == null) return null;
    final trimmed = rawPath.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _isAppDocumentsPath(String path) {
    final normalized = path.replaceAll('\\', '/').toLowerCase();
    return normalized.startsWith('app_documents/');
  }

  bool _isAbsoluteFilePath(String path) {
    final normalized = path.trim();
    return normalized.startsWith('/') ||
        normalized.startsWith('\\') ||
        RegExp(r'^[a-zA-Z]:[\\\/]').hasMatch(normalized);
  }

  String _sanitizeFileStem(String raw) {
    final trimmed = raw.trim();
    final collapsed = trimmed.replaceAll(RegExp(r'[\\\/]+'), '_');
    final safe = collapsed.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final normalized = safe.replaceAll(RegExp(r'_+'), '_');
    if (normalized.isEmpty) {
      return 'img_${DateTime.now().millisecondsSinceEpoch}';
    }
    return normalized;
  }

  Future<File?> _resolveImageFile(String imagePath) async {
    final sanitized = _sanitizeImagePath(imagePath);
    if (sanitized == null) return null;
    try {
      String? fullPath;
      if (_isAppDocumentsPath(sanitized)) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final relativePath = sanitized
            .replaceAll('\\', '/')
            .replaceFirst(
              RegExp(r'^app_documents/+', caseSensitive: false),
              '',
            );
        fullPath =
            '${appDocDir.path}${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}';
      } else if (_isAbsoluteFilePath(sanitized)) {
        fullPath = sanitized;
      } else {
        return null;
      }

      final file = File(fullPath);
      if (await file.exists()) {
        return file;
      }
      debugPrint('🖼️ RESOLVE IMAGE: File not found at $fullPath (source: $sanitized)');
    } catch (e) {
      debugPrint('Failed to resolve image: $e');
    }
    return null;
  }
}

class MultiSelectItem {
  final String id;
  final String name;
  MultiSelectItem(this.id, this.name);
}
