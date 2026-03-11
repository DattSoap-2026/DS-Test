import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/formulas_service.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart' as p_types;
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/unit_scope_utils.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/material_selector.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

bool canUserViewFormulaInManagement({
  required AppUser user,
  required Formula formula,
}) {
  if (user.role == UserRole.admin ||
      user.role == UserRole.owner ||
      user.role == UserRole.storeIncharge ||
      user.role == UserRole.productionManager) {
    return true;
  }

  if (user.role != UserRole.bhattiSupervisor) {
    return false;
  }

  final formulaScope = normalizeUnitKey(formula.assignedBhatti);
  if (formulaScope.isEmpty || formulaScope == 'all') {
    return true;
  }

  final userScope = resolveUserUnitScope(user);
  return matchesUnitScope(
    scope: userScope,
    tokens: [formula.assignedBhatti],
    defaultIfNoScopeTokens: false,
  );
}

class FormulasManagementScreen extends StatefulWidget {
  final bool isReadOnly;
  final VoidCallback? onBack;
  const FormulasManagementScreen({
    super.key,
    this.isReadOnly = false,
    this.onBack,
  });

  @override
  State<FormulasManagementScreen> createState() =>
      _FormulasManagementScreenState();
}

class _FormulasManagementScreenState extends State<FormulasManagementScreen> {
  late final FormulasService _formulasService;
  late final ProductsService _productsService;
  bool _isLoading = true;
  List<Formula> _formulas = [];
  List<p_types.Product> _allProducts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _formulasService = context.read<FormulasService>();
    _productsService = context.read<ProductsService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      List<Formula> formulas;
      try {
        formulas = await _formulasService.refreshFromCloud();
      } catch (e) {
        debugPrint('Formulas refresh fallback to local cache: $e');
        formulas = await _formulasService.getFormulas();
      }
      final products = await _productsService.getProducts();
      if (mounted) {
        setState(() {
          _formulas = formulas;
          _allProducts = products;
          _isLoading = false;
        });
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

  List<Formula> get _filteredFormulas {
    final userState = context.read<AuthProvider>().state;
    final user = userState.user;
    if (user == null) return [];

    return _formulas.where((f) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          f.productName.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) {
        return false;
      }

      return canUserViewFormulaInManagement(user: user, formula: f);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;
    final theme = Theme.of(context);
    final canEdit =
        !widget.isReadOnly &&
        (user?.role == UserRole.admin ||
            user?.role == UserRole.owner ||
            user?.role == UserRole.productionManager ||
            user?.role == UserRole.bhattiSupervisor);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'FORMULA (BHATTI) MANAGEMENT',
            subtitle: 'Manage production recipes for Semi-Finished goods',
            helperText:
                'Define Raw Materials required to produce 1 Batch of Semi-Finished Soap Base.',
            icon: Icons.science_outlined,
            onBack: widget.onBack,
            isReadOnly: widget.isReadOnly,
            actions: [
              if (canEdit)
                IconButton(
                  onPressed: () => _showAddFormulaDialog(),
                  icon: const Icon(Icons.add_circle_rounded),
                  tooltip: 'Add Recipe',
                ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          // Search Bar Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search recipes by product name...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                filled: true,
                fillColor: theme.dividerColor.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFormulas.isEmpty
                ? _buildEmptyState()
                : _buildFormulaTable(user),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 16),
          Text(
            'No formulas found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaTable(AppUser? user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canEdit =
        !widget.isReadOnly &&
        (user?.role == UserRole.admin ||
            user?.role == UserRole.owner ||
            user?.role == UserRole.productionManager ||
            user?.role == UserRole.bhattiSupervisor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.08,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minWidth = 920.0;
          final tableWidth = constraints.maxWidth < minWidth
              ? minWidth
              : constraints.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  // Header Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'OUTPUT (SEMI-FINISHED)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'CATEGORY',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'BHATTI',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'VERSION',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'STATUS',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: Text(
                            'ACTIONS',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Data List
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredFormulas.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.05,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final formula = _filteredFormulas[index];
                        return InkWell(
                          onTap: canEdit
                              ? () => _showEditFormulaDialog(formula)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      if (canEdit)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 6),
                                          child: Icon(
                                            Icons.edit_note_rounded,
                                            size: 15,
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          formula.productName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: canEdit
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  formula.category ?? 'Uncategorized',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _bhattiBadge(formula.assignedBhatti),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'v${formula.version}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _statusBadge(formula.status),
                              ),
                              SizedBox(
                                width: 140,
                                child: _buildActions(formula, user),
                              ),
                            ],
                          ),
                        ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bhattiBadge(String? bhatti) {
    final theme = Theme.of(context);
    Color badgeColor;
    switch (bhatti) {
      case 'Sona Bhatti':
        badgeColor = AppColors.info;
        break;
      case 'Gita Bhatti':
        badgeColor = AppColors.warning;
        break;
      default:
        badgeColor = theme.colorScheme.primary;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            (bhatti ?? 'Global').toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: badgeColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isCompleted = status.toLowerCase() == 'completed';
    final color = isCompleted ? AppColors.success : AppColors.warning;

    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                status.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(Formula formula, AppUser? user) {
    final theme = Theme.of(context);
    final canEdit =
        user?.role == UserRole.admin ||
        user?.role == UserRole.owner ||
        user?.role == UserRole.productionManager ||
        user?.role == UserRole.bhattiSupervisor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (canEdit)
          Tooltip(
            message: 'Edit Formula',
            child: InkWell(
              onTap: () => _showEditFormulaDialog(formula),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        if (canEdit) ...[
          const SizedBox(width: 12),
          Tooltip(
            message: 'Delete',
            child: InkWell(
              onTap: () => _confirmDelete(formula),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _confirmDelete(Formula formula) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Formula?'),
        content: Text(
          'Are you sure you want to delete the formula for ${formula.productName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _formulasService.deleteFormula(formula.id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFormulaDialog() {
    showDialog(
      context: context,
      builder: (context) => AddFormulaDialog(
        allProducts: _allProducts,
        existingFormulas: _formulas,
        onSaved: () {
          _loadData();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditFormulaDialog(Formula formula) {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    final availableIngredients = _allProducts
        .where(
          (p) => [
            'Raw Material',
            'Oils & Liquids',
            'Chemicals & Additives',
          ].contains(p.itemType.value),
        )
        .toList();

    if (isMobile) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditFormulaDialog(
            formula: formula,
            availableIngredients: availableIngredients,
            isFullScreen: true,
            onSaved: () {
              _loadData();
              Navigator.pop(context);
            },
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => EditFormulaDialog(
        formula: formula,
        availableIngredients: availableIngredients,
        onSaved: () {
          _loadData();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class AddFormulaDialog extends StatefulWidget {
  final List<p_types.Product> allProducts;
  final List<Formula> existingFormulas;
  final VoidCallback onSaved;

  const AddFormulaDialog({
    super.key,
    required this.allProducts,
    required this.existingFormulas,
    required this.onSaved,
  });

  @override
  State<AddFormulaDialog> createState() => _AddFormulaDialogState();
}

class _AddFormulaDialogState extends State<AddFormulaDialog> {
  String? _selectedProductId;
  late final FormulasService _formulasService;
  bool _isSaving = false;
  String _assignedBhatti = 'All';

  @override
  void initState() {
    super.initState();
    _formulasService = context.read<FormulasService>();
  }

  @override
  Widget build(BuildContext context) {
    final availableProducts = widget.allProducts
        .where(
          (p) =>
              p.type == p_types.ProductTypeEnum.semi &&
              !widget.existingFormulas.any((f) => f.productId == p.id),
        )
        .toList();

    return ResponsiveAlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Formula (Bhatti)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
          Text(
            'Formula defines how to produce a Semi-Finished Good.',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            MaterialSelector(
              selectedMaterialId: _selectedProductId,
              materials: availableProducts,
              onChanged: (p) => setState(() => _selectedProductId = p.id),
              label: 'Select Semi-Finished Output',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue:
                  [
                    'All',
                    'Sona Bhatti',
                    'Gita Bhatti',
                  ].contains(_assignedBhatti)
                  ? _assignedBhatti
                  : 'All',
              decoration: const InputDecoration(
                labelText: 'Assign to Bhatti',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All / Global')),
                DropdownMenuItem(
                  value: 'Sona Bhatti',
                  child: Text('Sona Bhatti'),
                ),
                DropdownMenuItem(
                  value: 'Gita Bhatti',
                  child: Text('Gita Bhatti'),
                ),
              ],
              onChanged: (val) => setState(() => _assignedBhatti = val!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final product = widget.allProducts.cast<p_types.Product?>().firstWhere(
        (p) => p?.id == _selectedProductId,
        orElse: () => null,
      );
      if (product == null) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected product not found'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // STRICT GUARD: Check Product Type
      // Formulas are ONLY for creating Semi-Finished Soap Bases (or potentially intermediates)
      // NEVER Finished Goods.
      final invalidTypes = [
        p_types.ProductTypeEnum.finished,
        p_types.ProductTypeEnum.packaging,
        p_types.ProductTypeEnum.traded,
      ];

      if (invalidTypes.contains(product.type) ||
          product.entityType == 'finished') {
        throw 'Strict Guard: Formulas cannot be created for Finished/Packaging/Traded goods. Select a Semi-Finished Soap Base.';
      }

      await _formulasService.addFormula(
        productId: product.id,
        productName: product.name,
        category: product.category,
        items: [],
        status: 'incomplete',
        version: 1,
        assignedBhatti: _assignedBhatti,
      );

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class EditFormulaDialog extends StatefulWidget {
  final Formula formula;
  final List<p_types.Product> availableIngredients;
  final VoidCallback onSaved;
  final bool isFullScreen;

  const EditFormulaDialog({
    super.key,
    required this.formula,
    required this.availableIngredients,
    required this.onSaved,
    this.isFullScreen = false,
  });

  @override
  State<EditFormulaDialog> createState() => _EditFormulaDialogState();
}

class _EditFormulaDialogState extends State<EditFormulaDialog> {
  late final TextEditingController _nameController;
  late List<FormulaItem> _items;
  late String _assignedBhatti;
  bool _isSaving = false;
  late final FormulasService _formulasService;

  @override
  void initState() {
    super.initState();
    _formulasService = context.read<FormulasService>();
    _nameController = TextEditingController(text: widget.formula.productName);
    _items = List.from(widget.formula.items);
    _assignedBhatti = widget.formula.assignedBhatti ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.isFullScreen) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Formula'),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.formula.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Define the ingredients (recipe) for 1 Batch of ${widget.formula.productName}.',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFormContent(theme),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4f46e5),
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Formula'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ResponsiveAlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Formula: ${widget.formula.productName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
          Text(
            'Define the ingredients (recipe) for 1 Batch of ${widget.formula.productName}.',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(child: _buildFormContent(theme)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save Formula'),
        ),
      ],
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: '',
              controller: _nameController,
              hintText: 'Enter product name',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Bhatti',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _assignedBhatti,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                filled: true,
                fillColor: Theme.of(context).dividerColor.withValues(alpha: 0.02),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All / Global'),
                ),
                DropdownMenuItem(
                  value: 'Sona Bhatti',
                  child: Text('Sona Bhatti'),
                ),
                DropdownMenuItem(
                  value: 'Gita Bhatti',
                  child: Text('Gita Bhatti'),
                ),
              ],
              onChanged: (val) => setState(() => _assignedBhatti = val!),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: AppColors.success,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cutting scrap is auto-tracked and reusable in Bhatti batches.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.success.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Text(
              'Ingredients',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Spacer(),
          ],
        ),
        const Divider(),
        ...List.generate(
          _items.length,
          (index) => _buildIngredientRow(index),
        ),
        const SizedBox(height: 12),
        Center(
          child: FilledButton.icon(
            onPressed: () {
              setState(() {
                _items.add(
                  FormulaItem(
                    materialId: '',
                    name: '',
                    quantity: 0,
                    unit: 'kg',
                  ),
                );
              });
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: const Text(
              'Add Ingredient',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              foregroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(int index) {
    final item = _items[index];
    final theme = Theme.of(context);
    final quantityFieldWidth = MediaQuery.of(context).size.width < 380
        ? 90.0
        : 110.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: MaterialSelector(
              selectedMaterialId: item.materialId.isEmpty ? null : item.materialId,
              materials: widget.availableIngredients,
              onChanged: (mat) {
                final exists = _items.asMap().entries.any(
                  (entry) => entry.key != index && entry.value.materialId == mat.id,
                );
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${mat.name} is already added to this formula!',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                final current = _items[index];
                setState(() {
                  _items[index] = FormulaItem(
                    materialId: mat.id,
                    name: mat.name,
                    quantity: current.quantity,
                    unit: mat.baseUnit,
                  );
                });
              },
              label: 'Item Name',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: quantityFieldWidth,
            child: TextFormField(
              initialValue: item.quantity > 0 ? item.quantity.toString() : '0',
              decoration: InputDecoration(
                labelText: 'Qty',
                suffixText: item.unit.isNotEmpty ? item.unit : 'kg',
                suffixStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                NormalizedNumberInputFormatter.decimal(
                  keepZeroWhenEmpty: true,
                ),
              ],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (val) {
                final current = _items[index];
                setState(() {
                  _items[index] = FormulaItem(
                    materialId: current.materialId,
                    name: current.name,
                    quantity: double.tryParse(val) ?? 0,
                    unit: current.unit,
                  );
                });
              },
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
            onPressed: () => setState(() => _items.removeAt(index)),
            tooltip: 'Remove',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final validItems = _items
          .where((i) => i.materialId.isNotEmpty && i.quantity > 0)
          .toList();

      await _formulasService.updateFormula(
        id: widget.formula.id,
        productName: _nameController.text,
        items: validItems,
        assignedBhatti: _assignedBhatti,
        status: validItems.isNotEmpty ? 'completed' : 'incomplete',
        version: widget.formula.version + 1,
      );

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
