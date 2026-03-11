import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/dealer_repository.dart';
import '../../../services/dealers_service.dart'; // Keep for Dealer model
import '../business_partner_form_dialog.dart';
import '../widgets/partner_transaction_history_dialog.dart';
import '../partner_data_cache.dart';
import '../../../widgets/ui/glass_container.dart';
import '../../../widgets/ui/animated_card.dart';
import '../../../widgets/ui/custom_text_field.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class DealersListView extends StatefulWidget {
  const DealersListView({super.key});

  @override
  State<DealersListView> createState() => _DealersListViewState();
}

class _DealersListViewState extends State<DealersListView>
    with AutomaticKeepAliveClientMixin {
  // Uses Repo as per original screen
  List<Dealer> _allDealers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoute = 'All Routes';

  @override
  void initState() {
    super.initState();
    final cachedDealers = BusinessPartnersDataCache.dealers;
    if (cachedDealers != null && cachedDealers.isNotEmpty) {
      _allDealers = cachedDealers;
      _isLoading = false;
    }
    _loadDealers(showLoader: _allDealers.isEmpty);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDealers({bool showLoader = true}) async {
    try {
      if (mounted && showLoader) {
        setState(() => _isLoading = true);
      }
      final dealerRepo = context.read<DealerRepository>();
      final dealerEntities = await dealerRepo.getAllDealers();
      final dealers = dealerEntities
          .map((entity) => entity.toDomain())
          .toList();

      if (mounted) {
        setState(() {
          _allDealers = dealers;
          BusinessPartnersDataCache.dealers = dealers;
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

  Future<void> _showDealerDialog([Dealer? dealer]) async {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    if (isMobile) {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (routeContext) => BusinessPartnerFormDialog(
            initialType: PartnerType.dealer,
            existingPartner: dealer,
            fullScreen: true,
            onSaved: () => Navigator.of(routeContext).pop(true),
          ),
        ),
      );
      if (saved == true && mounted) {
        _loadDealers(showLoader: false);
      }
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => BusinessPartnerFormDialog(
        initialType: PartnerType.dealer,
        existingPartner: dealer,
        onSaved: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (saved == true && mounted) {
      _loadDealers(showLoader: false);
    }
  }

  Future<void> _showDealerHistory(Dealer dealer) async {
    await PartnerTransactionHistoryDialog.showSalesHistory(
      context,
      partnerId: dealer.id,
      partnerName: dealer.name,
      recipientType: 'dealer',
    );
  }

  String _displayRouteForDealer(Dealer dealer) {
    final assignedRoute = dealer.assignedRouteName?.trim();
    if (assignedRoute != null && assignedRoute.isNotEmpty) {
      return assignedRoute;
    }
    final territory = dealer.territory?.trim();
    if (territory != null && territory.isNotEmpty) {
      return territory;
    }
    return 'No Route';
  }

  int _countDealersForRoute(String route) {
    // [LOCKED] Keep route counter independent from search text
    // so selected/total does not fluctuate while typing.
    if (route == 'All Routes') return _allDealers.length;
    return _allDealers
        .where((dealer) => _displayRouteForDealer(dealer) == route)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final routes =
        {
          'All Routes',
          ..._allDealers
              .map(_displayRouteForDealer)
              .where((route) => route != 'No Route'),
        }.toList()..sort((a, b) {
          if (a == 'All Routes') return -1;
          if (b == 'All Routes') return 1;
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
    final effectiveSelectedRoute = routes.contains(_selectedRoute)
        ? _selectedRoute
        : 'All Routes';
    final selectedRouteDealersCount = _countDealersForRoute(
      effectiveSelectedRoute,
    );
    final totalDealers = _allDealers.length;

    // Filter dealers based on search text
    final displayDealers = _allDealers.where((d) {
      final query = _searchController.text.toLowerCase();
      final routeLabel = _displayRouteForDealer(d).toLowerCase();
      return d.name.toLowerCase().contains(query) ||
          d.contactPerson.toLowerCase().contains(query) ||
          d.mobile.contains(query) ||
          routeLabel.contains(query);
    }).toList();
    final routeFilteredDealers = effectiveSelectedRoute == 'All Routes'
        ? displayDealers
        : displayDealers
              .where(
                (dealer) =>
                    _displayRouteForDealer(dealer) == effectiveSelectedRoute,
              )
              .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar Area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 700;
                      final searchField = Expanded(
                        child: CustomTextField(
                          label: '',
                          controller: _searchController,
                          hintText: 'Search dealers...',
                          prefixIcon: Icons.search_rounded,
                          isDense: true,
                          onChanged: (val) => setState(() {}),
                        ),
                      );
                      final routeDropdown = SizedBox(
                        height: 52,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          borderRadius: 20,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: effectiveSelectedRoute,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              items: routes.map((String route) {
                                return DropdownMenuItem<String>(
                                  value: route,
                                  child: Text(
                                    route.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedRoute = value);
                              },
                            ),
                          ),
                        ),
                      );
                      final selectedVsTotalBadge = GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        borderRadius: 14,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        child: Text(
                          '$selectedRouteDealersCount/$totalDealers',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                          ),
                        ),
                      );
                      final addButton = Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.95,
                            ),
                          ),
                        ),
                        child: IconButton(
                          tooltip: 'Add dealer',
                          onPressed: () => _showDealerDialog(),
                          icon: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                searchField,
                                const SizedBox(width: 10),
                                addButton,
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: routeDropdown),
                                const SizedBox(width: 10),
                                selectedVsTotalBadge,
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          searchField,
                          const SizedBox(width: 12),
                          Expanded(child: routeDropdown),
                          const SizedBox(width: 10),
                          selectedVsTotalBadge,
                        ],
                      );
                    },
                  ),
                ),

                // Contact List
                Expanded(
                  child: routeFilteredDealers.isEmpty
                      ? Center(
                          child: Text(
                            'No dealers found',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 80,
                          ),
                          itemCount: routeFilteredDealers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final dealer = routeFilteredDealers[index];
                            final isActive = dealer.status == 'active';

                            return AnimatedCard(
                              onTap: () => _showDealerDialog(dealer),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                borderRadius: 24,
                                color: theme.colorScheme.surface,
                                child: Row(
                                  children: [
                                    // Avatar
                                    InkWell(
                                      borderRadius: BorderRadius.circular(100),
                                      onTap: () => _showDealerHistory(dealer),
                                      child: SortedAvatar(
                                        name: dealer.name,
                                        size: 56,
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dealer.name.toUpperCase(),
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 4,
                                            children: [
                                              _buildInfoTag(
                                                theme,
                                                Icons.phone_iphone_rounded,
                                                dealer.mobile,
                                              ),
                                              if (dealer
                                                  .contactPerson
                                                  .isNotEmpty)
                                                _buildInfoTag(
                                                  theme,
                                                  Icons.person_outline_rounded,
                                                  dealer.contactPerson,
                                                ),
                                              if (dealer.address.isNotEmpty)
                                                _buildInfoTag(
                                                  theme,
                                                  Icons.location_on_outlined,
                                                  dealer.address,
                                                ),
                                              _buildInfoTag(
                                                theme,
                                                Icons.route_rounded,
                                                _displayRouteForDealer(dealer),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Status Indicator
                                    Column(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.success
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (isActive
                                                            ? AppColors.success
                                                            : theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant)
                                                        .withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        IconButton(
                                          tooltip: 'Edit dealer',
                                          onPressed: () =>
                                              _showDealerDialog(dealer),
                                          icon: Icon(
                                            Icons.chevron_right_rounded,
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
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
    );
  }

  Widget _buildInfoTag(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SortedAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;

  const SortedAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    // Deterministic color based on name
    final colorIndex =
        name.codeUnits.fold(0, (p, c) => p + c) % Colors.primaries.length;
    final color = Colors.primaries[colorIndex];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
