import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../services/tank_service.dart';
import '../../data/repositories/tank_repository.dart';
import '../../utils/responsive.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/themed_filter_chip.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';

import 'tank_details_screen.dart';
import 'dialogs/add_storage_unit_dialog.dart';
import 'dialogs/refill_tank_dialog.dart';
import 'widgets/storage_themes.dart';
import 'widgets/tank_visualization.dart';
import 'widgets/godown_visualization.dart';

import '../../widgets/ui/custom_button.dart';
import '../../utils/storage_unit_helper.dart';

// Desktop layout policy:
// - Auto-adapt columns by available width
// - Cap at 6 columns on wide screens
// - Keep compact 3-row viewport target on large screens
const int kLockedTankDesktopColumns = 6;
const int kLockedTankDesktopVisibleRows = 3;
const double kTankGridSpacing = 10;

int tankGridColumnCountForWidth(double width) {
  if (width >= 900) {
    final adaptiveDesktopColumns = (width / 250).floor().clamp(
      3,
      kLockedTankDesktopColumns,
    );
    return adaptiveDesktopColumns;
  }
  if (width >= 680) return 3;
  if (width >= 460) return 2;
  return 1;
}

double tankGridMainAxisExtentForWidth(double width, double viewportHeight) {
  if (width >= 1200) {
    final usableHeight = (viewportHeight - 300).clamp(560.0, 860.0).toDouble();
    final rows = kLockedTankDesktopVisibleRows;
    return ((usableHeight - ((rows - 1) * kTankGridSpacing)) / rows)
        .clamp(220.0, 280.0)
        .toDouble();
  }
  if (width >= 900) return 250;
  if (width >= 680) return 270;
  if (width >= 460) return 300;
  return 330;
}

class TanksListScreen extends StatefulWidget {
  final bool isReadOnly;
  final VoidCallback? onBack;
  const TanksListScreen({super.key, this.isReadOnly = false, this.onBack});

  @override
  State<TanksListScreen> createState() => _TanksListScreenState();
}

class _TanksListScreenState extends State<TanksListScreen> {
  late TankRepository _tankRepo;
  late TankService _tankService;
  List<Tank> _tanks = [];
  Map<String, TankLot?> _latestLotsByTankId = {};
  bool _isLoading = true;
  String _selectedUnit = 'all'; // 'all', 'sona', 'gita'
  String _selectedType = 'all'; // 'all', 'tank', 'godown'
  bool _isManageMode = false;

  @override
  void initState() {
    super.initState();
    _tankRepo = context.read<TankRepository>();
    _tankService = context.read<TankService>();
    _loadTanks();
    _tankRepo.fetchAndCacheTanks().then((_) => _loadTanks());
  }

  Future<void> _loadTanks() async {
    try {
      setState(() => _isLoading = true);
      final tanks = await _tankRepo.getTanks();
      final latestLots = await _loadLatestLotsForTanks(tanks);
      if (mounted) {
        setState(() {
          _tanks = tanks;
          _latestLotsByTankId = latestLots;
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

  bool _isUnitMatch(Tank tank, String unitKeyword) {
    final department = tank.department.trim().toLowerCase();
    final assignedUnit = (tank.assignedUnit ?? '').trim().toLowerCase();
    return department.contains(unitKeyword) ||
        assignedUnit.contains(unitKeyword);
  }

  List<Tank> get _filteredTanks {
    final filtered = _tanks.where((tank) {
      final matchesUnit =
          _selectedUnit == 'all' ||
          (_selectedUnit == 'sona' && _isUnitMatch(tank, 'sona')) ||
          (_selectedUnit == 'gita' && _isUnitMatch(tank, 'gita'));
      bool matchesType =
          _selectedType == 'all' ||
          (_selectedType == 'tank' && tank.type == 'tank') ||
          (_selectedType == 'godown' && tank.type == 'godown');
      return matchesUnit && matchesType;
    }).toList();
    filtered.sort(Tank.compareByDisplayOrder);
    return filtered;
  }

  Map<String, List<Tank>> get _groupedTanks {
    final grouped = <String, List<Tank>>{};
    for (final tank in _filteredTanks) {
      grouped.putIfAbsent(tank.department, () => []).add(tank);
    }
    return grouped;
  }

  Color _getStatusColor(BuildContext context, double fillLevel) {
    final theme = Theme.of(context);
    if (fillLevel < 5) return theme.colorScheme.error;
    if (fillLevel < 15) return theme.colorScheme.tertiary;
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canManage =
        !widget.isReadOnly &&
        context.read<AuthProvider>().currentUser?.role !=
            UserRole.bhattiSupervisor;
    final isCompactHeader = Responsive.width(context) < 1100;

    final titleSection = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.storage_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Tanks & Storage',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            'Oil & chemical storage configuration',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );

    final filterSection = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactFilterChip('ALL', 'all'),
          _buildCompactFilterChip('TANKS', 'tank'),
          _buildCompactFilterChip('GODOWNS', 'godown'),
          const SizedBox(width: 4),
          Container(
            width: 1,
            height: 16,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 4),
          _buildUnitFilterChip('SONA', 'sona'),
          _buildUnitFilterChip('GITA', 'gita'),
        ],
      ),
    );

    final actionsSection = isCompactHeader
        ? Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (canManage)
                CustomButton(
                  label: _isManageMode ? 'DASHBOARD' : 'MANAGE',
                  icon: _isManageMode
                      ? Icons.dashboard_rounded
                      : Icons.settings_rounded,
                  isDense: true,
                  variant: ButtonVariant.outline,
                  onPressed: () =>
                      setState(() => _isManageMode = !_isManageMode),
                ),
              if (canManage)
                CustomButton(
                  label: 'REFILL',
                  icon: Icons.add_circle_outline_rounded,
                  variant: ButtonVariant.primary,
                  isDense: true,
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) =>
                          RefillTankDialog(initialTank: null, allTanks: _tanks),
                    );
                    if (result == true) {
                      _loadTanks();
                    }
                  },
                ),
              IconButton(
                onPressed: _loadTanks,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Data',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canManage) ...[
                CustomButton(
                  label: _isManageMode ? 'DASHBOARD' : 'MANAGE',
                  icon: _isManageMode
                      ? Icons.dashboard_rounded
                      : Icons.settings_rounded,
                  isDense: true,
                  variant: ButtonVariant.outline,
                  onPressed: () =>
                      setState(() => _isManageMode = !_isManageMode),
                ),
                const SizedBox(width: 8),
                CustomButton(
                  label: 'REFILL',
                  icon: Icons.add_circle_outline_rounded,
                  variant: ButtonVariant.primary,
                  isDense: true,
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) =>
                          RefillTankDialog(initialTank: null, allTanks: _tanks),
                    );
                    if (result == true) {
                      _loadTanks();
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: _loadTanks,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Data',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
              ),
            ],
          );
    return Column(
      children: [
        // Header Section
        // Consolidated Header
        Container(
          constraints: isCompactHeader
              ? null
              : BoxConstraints(
                  minHeight: Responsive.clamp(
                    context,
                    min: 68,
                    max: 88,
                    ratio: 0.08,
                  ),
                ),
          padding: EdgeInsets.symmetric(
            horizontal: isCompactHeader ? 12 : 24,
            vertical: isCompactHeader ? 10 : 0,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: isCompactHeader
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: filterSection,
                    ),
                    const SizedBox(height: 10),
                    actionsSection,
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 3, child: titleSection),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: filterSection,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: actionsSection,
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        // Expanded List content
        Expanded(
          child: _isManageMode
              ? _buildManagementView()
              : (_isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Builder(
                        builder: (context) {
                          final groupedTanks = _groupedTanks;
                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: groupedTanks.length,
                            itemBuilder: (context, index) {
                              final dept = groupedTanks.keys.elementAt(index);
                              final tanks = groupedTanks[dept]!;
                              final departmentTheme = getThemeForDepartment(
                                dept,
                              );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Department Header
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 16,
                                      top: index > 0 ? 32 : 12,
                                      left: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: departmentTheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          dept.toUpperCase(),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.0,
                                                color: departmentTheme.primary,
                                              ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${tanks.length} UNITS',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Tank/Godown Cards Grid
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final columns =
                                          tankGridColumnCountForWidth(
                                            constraints.maxWidth,
                                          );
                                      final mainAxisExtent =
                                          tankGridMainAxisExtentForWidth(
                                            constraints.maxWidth,
                                            MediaQuery.sizeOf(context).height,
                                          );

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              // Adaptive desktop layout with max 6 columns.
                                              crossAxisCount: columns,
                                              mainAxisExtent: mainAxisExtent,
                                              crossAxisSpacing:
                                                  kTankGridSpacing,
                                              mainAxisSpacing: kTankGridSpacing,
                                            ),
                                        itemCount: tanks.length,
                                        itemBuilder: (context, tankIndex) {
                                          final tank = tanks[tankIndex];
                                          return tank.type == 'godown'
                                              ? _buildGodownCard(tank)
                                              : _buildTankCard(tank);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )),
        ),
      ],
    );
  }

  Widget _buildTankCard(Tank tank) {
    final theme = getThemeForDepartment(tank.department);
    final statusColor = _getStatusColor(context, tank.fillLevel);
    final storageUnit = StorageUnitHelper.tankDisplayUnit(tank.unit);
    final capacityValue = StorageUnitHelper.tankDisplayQuantity(
      tank.capacity,
      storageUnit: tank.unit,
    );
    final availableValue = StorageUnitHelper.tankDisplayQuantity(
      tank.currentStock,
      storageUnit: tank.unit,
    );
    final latestLot = _latestLotsByTankId[tank.id];
    final isDenseDesktop = Responsive.width(context) >= 1200;
    final cardPadding = isDenseDesktop ? 10.0 : 16.0;
    final sectionGap = isDenseDesktop ? 8.0 : 12.0;

    return UnifiedCard(
      disableScroll: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TankDetailsScreen(tankId: tank.id),
          ),
        );
      },
      padding: EdgeInsets.all(cardPadding),
      border: Border.all(color: theme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(theme.icon, size: 14, color: theme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tank.name,
                            style: TextStyle(
                              fontSize: isDenseDesktop ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      tank.materialName.toUpperCase(),
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: isDenseDesktop ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Show unit/team if assigned
                    if (tank.assignedUnit != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Unit: ${tank.assignedUnit}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tank.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: sectionGap),

          // Tank Visualization
          Expanded(
            child: Center(
              child: TankVisualization(
                fillLevel: tank.fillLevel,
                liquidColor: theme.liquidColor,
                label: availableValue.toStringAsFixed(2),
                unitLabel: storageUnit,
              ),
            ),
          ),

          SizedBox(height: sectionGap),

          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildCardMetric(
                  'CAP',
                  '${capacityValue.toStringAsFixed(1)} $storageUnit',
                ),
              ),
              SizedBox(width: isDenseDesktop ? 6 : 8),
              Expanded(
                child: _buildCardMetric(
                  'AVL',
                  '${availableValue.toStringAsFixed(1)} $storageUnit',
                ),
              ),
              SizedBox(width: isDenseDesktop ? 6 : 8),
              Expanded(
                child: _buildCardMetric(
                  'FILL',
                  '${tank.fillLevel.toStringAsFixed(0)}%',
                  color: statusColor,
                ),
              ),
            ],
          ),
          SizedBox(height: isDenseDesktop ? 4 : 6),
          Text(
            'LAST PURCHASE: ${latestLot?.supplierName ?? "N/A"}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: isDenseDesktop ? 9 : 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMetric(String label, String value, {Color? color}) {
    final isDenseDesktop = Responsive.width(context) >= 1200;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: isDenseDesktop ? 8 : 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDenseDesktop ? 12 : 13,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGodownCard(Tank tank) {
    final theme = getThemeForDepartment(tank.department);
    final appTheme = Theme.of(context);
    final bags = tank.bags ?? 0;
    final maxBags = tank.maxBags ?? 100;
    final usagePercent = maxBags > 0 ? (bags / maxBags * 100.0) : 0.0;
    final isDenseDesktop = Responsive.width(context) >= 1200;
    final cardPadding = isDenseDesktop ? 12.0 : 20.0;

    return UnifiedCard(
      disableScroll: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TankDetailsScreen(tankId: tank.id),
          ),
        );
      },
      padding: EdgeInsets.all(cardPadding),
      border: Border.all(color: theme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warehouse_rounded,
                          size: 16,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tank.name,
                            style: appTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isDenseDesktop ? 14 : null,
                              color: appTheme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      tank.materialName.toUpperCase(),
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: appTheme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: appTheme.colorScheme.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isDenseDesktop ? 10 : 16),

          // Godown Visualization
          Expanded(
            child: GodownVisualization(
              usagePercent: usagePercent,
              bagColor: theme.primary,
            ),
          ),

          SizedBox(height: isDenseDesktop ? 10 : 16),

          // Stock info
          Row(
            children: [
              Expanded(child: _buildCardMetric('BAGS', '$bags')),
              SizedBox(width: isDenseDesktop ? 6 : 10),
              Expanded(
                child: _buildCardMetric(
                  'STOCK',
                  '${tank.currentStock.toStringAsFixed(1)} ${StorageUnitHelper.tonUnit}',
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterChip(String label, String value) {
    final isSelected = _selectedType == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ThemedFilterChip(
        label: label,
        selected: isSelected,
        onSelected: () => setState(() => _selectedType = value),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        textStyle: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _buildUnitFilterChip(String label, String value) {
    final isSelected = _selectedUnit == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ThemedFilterChip(
        label: label,
        selected: isSelected,
        onSelected: () =>
            setState(() => _selectedUnit = isSelected ? 'all' : value),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _buildManagementView() {
    // Flatten the grouped tanks for table view
    List<Tank> flatTanks = [];
    for (var list in _groupedTanks.values) {
      flatTanks.addAll(list);
    }
    final canManageStorage =
        context.read<AuthProvider>().state.user?.role !=
        UserRole.bhattiSupervisor;

    Future<void> openAddStorageDialog() async {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AddStorageUnitDialog(tankRepo: _tankRepo),
      );
      if (result == true) {
        _loadTanks();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: UnifiedCard(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompactHeader = constraints.maxWidth < 560;
                final overviewDetails = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Management Overview',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Configure and manage storage units',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );

                final addStorageButton = CustomButton(
                  label: 'ADD STORAGE UNIT',
                  onPressed: openAddStorageDialog,
                  icon: Icons.add_business_rounded,
                  width: isCompactHeader
                      ? double.infinity
                      : Responsive.clamp(
                          context,
                          min: 180,
                          max: 280,
                          ratio: 0.24,
                        ),
                );

                if (isCompactHeader) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      overviewDetails,
                      if (canManageStorage) ...[
                        const SizedBox(height: 12),
                        addStorageButton,
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: overviewDetails),
                    if (canManageStorage) ...[
                      const SizedBox(width: 12),
                      addStorageButton,
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            itemCount: flatTanks.length,
            itemBuilder: (context, index) {
              final tank = flatTanks[index];
              final statusColor = _getStatusColor(context, tank.fillLevel);

              return UnifiedCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tank.type == 'tank'
                            ? Icons.water_drop_rounded
                            : Icons.warehouse_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tank.name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${tank.department} • ${tank.assignedUnit ?? "No Unit"}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MATERIAL',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                  letterSpacing: 0.5,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            tank.materialName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STOCK',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                  letterSpacing: 0.5,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            tank.type == 'godown'
                                ? '${tank.bags ?? 0} Bags'
                                : '${StorageUnitHelper.tankDisplayQuantity(tank.currentStock, storageUnit: tank.unit).toStringAsFixed(1)} ${StorageUnitHelper.tankDisplayUnit(tank.unit)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        tank.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (context.read<AuthProvider>().currentUser?.role !=
                        UserRole.bhattiSupervisor)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => AddStorageUnitDialog(
                                  tankRepo: _tankRepo,
                                  initialTank: tank,
                                ),
                              );
                              if (result == true) _loadTanks();
                            },
                            style: IconButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => ResponsiveAlertDialog(
                                  title: const Text('Delete Unit'),
                                  content: Text(
                                    'Are you sure you want to delete ${tank.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('CANCEL'),
                                    ),
                                    CustomButton(
                                      label: 'DELETE',
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      variant: ButtonVariant.danger,
                                      isDense: true,
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _tankRepo.deleteTank(tank.id);
                                _loadTanks();
                              }
                            },
                            style: IconButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
