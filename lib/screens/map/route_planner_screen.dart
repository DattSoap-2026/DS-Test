import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/gps_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../../models/customer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../constants/role_access_matrix.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  static const LatLng _companyHub = LatLng(19.85724, 75.31584);
  static const String _companyHubName = 'Datt Soap Industry';
  static const LatLng _defaultMapCenter = _companyHub;
  static const double _defaultMapZoom = 5.0;
  static const double _singleStopZoom = 13.0;
  static const double _routeStopsZoom = 11.5;
  static const List<double> _mileageOptions = [7, 8, 9, 10, 12, 14];
  static const List<double> _dieselRateOptions = [90, 92, 94, 96, 98, 100];

  late final GpsService _gpsService;

  List<String> _routes = [];
  Map<String, _RouteInsight> _routeInsights = {};
  String? _selectedRoute;
  List<Customer> _allCustomers = []; // Cache all for offline routes/filtering
  List<Customer> _routeCustomers = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRefreshingRoutes = false;
  bool _hasUnsavedChanges = false;
  double _oneWayDistanceKm = 0;
  double _roundTripDistanceKm = 0;
  double _assumedMileageKmPerLiter = 10;
  double _dieselRatePerLiter = 94;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _gpsService = context.read<GpsService>();
    if (_canPlanRoute(_currentViewer())) {
      _loadData();
    } else {
      _isLoading = false;
    }
  }

  AuthProvider? _tryAuthProvider({bool listen = false}) {
    try {
      return Provider.of<AuthProvider>(context, listen: listen);
    } catch (_) {
      return null;
    }
  }

  AppUser? _currentViewer({AuthProvider? authProvider}) {
    return (authProvider ?? _tryAuthProvider())?.currentUser;
  }

  bool _canPlanRoute(AppUser? viewer) {
    if (viewer == null) return false;
    return RoleAccessMatrix.hasCapability(
          viewer.role,
          RoleCapability.mapViewAll,
        ) ||
        RoleAccessMatrix.hasCapability(
          viewer.role,
          RoleCapability.mapPlanRoutes,
        );
  }

  Widget _buildAccessDenied() {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 44,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Route Planning Restricted',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your role does not have route planning access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      final customerRepo = context.read<CustomerRepository>();
      final entities = await customerRepo.getAllCustomers();
      if (mounted) {
        final customers = entities.map((e) => e.toDomain()).toList();

        final insights = _buildRouteInsights(customers);
        final sortedRoutes = insights.keys.toList()
          ..sort((a, b) {
            final aInsight = insights[a]!;
            final bInsight = insights[b]!;
            final aHasGps = aInsight.mappedStops > 0;
            final bHasGps = bInsight.mappedStops > 0;
            if (aHasGps != bHasGps) {
              return aHasGps ? -1 : 1;
            }
            final cmpKm = aInsight.roundTripKm.compareTo(bInsight.roundTripKm);
            if (cmpKm != 0) return cmpKm;
            return a.compareTo(b);
          });

        setState(() {
          _allCustomers = customers;
          _routes = sortedRoutes;
          _routeInsights = insights;
          if (_selectedRoute != null && !_routes.contains(_selectedRoute)) {
            _selectedRoute = null;
            _routeCustomers = const <Customer>[];
            _oneWayDistanceKm = 0;
            _roundTripDistanceKm = 0;
            _hasUnsavedChanges = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRouteSelected(String? route) async {
    if (route == null) return;
    setState(() => _isLoading = true);
    try {
      final customers = _getCustomersForRoute(route);
      final stats = _computeJourneyStats(customers);

      if (mounted) {
        setState(() {
          _selectedRoute = route;
          _routeCustomers = customers;
          _oneWayDistanceKm = stats.oneWayKm;
          _roundTripDistanceKm = stats.roundTripKm;
          _isLoading = false;
          _hasUnsavedChanges = false;
        });
        _fitMap();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Customer> _getCustomersForRoute(String route) {
    final customers = _allCustomers
        .where(
          (c) => c.route.trim().toLowerCase() == route.trim().toLowerCase(),
        )
        .toList();
    customers.sort(
      (a, b) => (a.routeSequence ?? 999).compareTo(b.routeSequence ?? 999),
    );
    return customers;
  }

  void _fitMap() {
    final journeyPoints = <LatLng>[_companyHub, ..._routePoints];
    if (journeyPoints.length == 1) {
      _mapController.move(_companyHub, _singleStopZoom);
      return;
    }

    try {
      final bounds = LatLngBounds.fromPoints(journeyPoints);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
          minZoom: 5.0,
          maxZoom: 15.5,
        ),
      );
    } catch (_) {
      final zoom = journeyPoints.length == 2
          ? _singleStopZoom
          : _routeStopsZoom;
      _mapController.move(journeyPoints.first, zoom);
    }
  }

  // --- Optimization Algorithm ---
  void _smartOptimize() {
    if (_routeCustomers.length < 3) return;

    final validStops = _routeCustomers.where(_hasValidCoordinates).toList();
    final invalidStops = _routeCustomers
        .where((c) => !_hasValidCoordinates(c))
        .toList();
    if (validStops.length < 2) return;

    final List<Customer> unvisited = List.from(validStops);
    final List<Customer> optimized = [];
    LatLng currentPoint = _companyHub;

    while (unvisited.isNotEmpty) {
      int nearestIndex = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < unvisited.length; i++) {
        final candidate = unvisited[i];
        final dist = _gpsService.calculateDistance(
          currentPoint.latitude,
          currentPoint.longitude,
          candidate.latitude!,
          candidate.longitude!,
        );
        if (dist < minDistance) {
          minDistance = dist;
          nearestIndex = i;
        }
      }

      final next = unvisited.removeAt(nearestIndex);
      optimized.add(next);
      currentPoint = LatLng(next.latitude!, next.longitude!);
    }

    optimized.addAll(invalidStops);
    final stats = _computeJourneyStats(optimized);

    final selectedRoute = _selectedRoute;
    setState(() {
      _routeCustomers = optimized;
      _hasUnsavedChanges = true;
      _oneWayDistanceKm = stats.oneWayKm;
      _roundTripDistanceKm = stats.roundTripKm;
      if (selectedRoute != null) {
        _routeInsights[selectedRoute] = _RouteInsight(
          totalStops: optimized.length,
          mappedStops: stats.mappedStops,
          oneWayKm: stats.oneWayKm,
          roundTripKm: stats.roundTripKm,
        );
      }
    });
    _fitMap();
  }

  Future<void> _saveSequence() async {
    setState(() => _isSaving = true);
    try {
      final updates = _routeCustomers
          .asMap()
          .entries
          .map((e) => {'customerId': e.value.id, 'sequence': e.key + 1})
          .toList();

      final customerRepo = context.read<CustomerRepository>();
      await customerRepo.updateRouteSequence(updates);

      final success =
          true; // Repository throws on error, so if we get here it's success
      if (success && mounted) {
        setState(() => _hasUnsavedChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route sequence saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _isSidebarVisible = true;

  double get _estimatedDieselLiters {
    if (_assumedMileageKmPerLiter <= 0) return 0;
    return _roundTripDistanceKm / _assumedMileageKmPerLiter;
  }

  double get _estimatedDieselCost =>
      _estimatedDieselLiters * _dieselRatePerLiter;

  Map<String, _RouteInsight> _buildRouteInsights(List<Customer> customers) {
    final groupedByRoute = <String, List<Customer>>{};
    for (final customer in customers) {
      final route = customer.route.trim();
      if (route.isEmpty) continue;
      groupedByRoute.putIfAbsent(route, () => []).add(customer);
    }

    final insights = <String, _RouteInsight>{};
    for (final entry in groupedByRoute.entries) {
      final sorted = List<Customer>.from(entry.value)
        ..sort(
          (a, b) => (a.routeSequence ?? 999).compareTo(b.routeSequence ?? 999),
        );
      final stats = _computeJourneyStats(sorted);
      insights[entry.key] = _RouteInsight(
        totalStops: sorted.length,
        mappedStops: stats.mappedStops,
        oneWayKm: stats.oneWayKm,
        roundTripKm: stats.roundTripKm,
      );
    }
    return insights;
  }

  _JourneyStats _computeJourneyStats(List<Customer> customers) {
    final points = customers
        .where(_hasValidCoordinates)
        .map((c) => LatLng(c.latitude!, c.longitude!))
        .toList(growable: false);
    if (points.isEmpty) {
      return const _JourneyStats(oneWayKm: 0, roundTripKm: 0, mappedStops: 0);
    }

    double oneWay = 0;
    var current = _companyHub;
    for (final point in points) {
      oneWay += _gpsService.calculateDistance(
        current.latitude,
        current.longitude,
        point.latitude,
        point.longitude,
      );
      current = point;
    }

    final returnLeg = _gpsService.calculateDistance(
      current.latitude,
      current.longitude,
      _companyHub.latitude,
      _companyHub.longitude,
    );

    return _JourneyStats(
      oneWayKm: oneWay,
      roundTripKm: oneWay + returnLeg,
      mappedStops: points.length,
    );
  }

  bool _hasValidCoordinates(Customer customer) {
    final lat = customer.latitude;
    final lng = customer.longitude;
    if (lat == null || lng == null) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    if (lat == 0 && lng == 0) return false;
    return true;
  }

  List<LatLng> get _routePoints {
    return _routeCustomers
        .where(_hasValidCoordinates)
        .map((c) => LatLng(c.latitude!, c.longitude!))
        .toList(growable: false);
  }

  List<LatLng> get _journeyPolylinePoints {
    final points = _routePoints;
    if (points.isEmpty) return const <LatLng>[];
    return <LatLng>[_companyHub, ...points, _companyHub];
  }

  int get _missingGpsCount {
    if (_routeCustomers.isEmpty) return 0;
    return _routeCustomers.length - _routePoints.length;
  }

  String _extractVillageLabel(Customer customer) {
    final city = (customer.city ?? '').trim();
    if (city.isNotEmpty) return city;
    final tokens = customer.shopName.trim().split(RegExp(r'\s+'));
    if (tokens.isEmpty) return 'Village Unknown';
    return tokens.last;
  }

  double? _segmentDistanceKmAt(int index) {
    if (index < 0 || index >= _routeCustomers.length) return null;
    final current = _routeCustomers[index];
    if (!_hasValidCoordinates(current)) return null;
    if (index == 0) {
      return _gpsService.calculateDistance(
        _companyHub.latitude,
        _companyHub.longitude,
        current.latitude!,
        current.longitude!,
      );
    }

    for (int i = index - 1; i >= 0; i--) {
      final previous = _routeCustomers[i];
      if (_hasValidCoordinates(previous)) {
        return _gpsService.calculateDistance(
          previous.latitude!,
          previous.longitude!,
          current.latitude!,
          current.longitude!,
        );
      }
    }

    return _gpsService.calculateDistance(
      _companyHub.latitude,
      _companyHub.longitude,
      current.latitude!,
      current.longitude!,
    );
  }

  String _buildStopSubtitle(Customer customer, int index) {
    final village = _extractVillageLabel(customer);
    final segment = _segmentDistanceKmAt(index);
    final gpsTag = _hasValidCoordinates(customer) ? '' : ' [GPS missing]';
    if (segment == null) return '$village$gpsTag';
    return '$village$gpsTag • +${segment.toStringAsFixed(1)} km';
  }

  double get _gpsCoveragePercent {
    if (_routeCustomers.isEmpty) return 0;
    return (_routePoints.length / _routeCustomers.length) * 100;
  }

  String get _routeHealthLabel {
    if (_selectedRoute == null) return 'Select route';
    if (_missingGpsCount > 0) return 'Needs GPS cleanup';
    if (_hasUnsavedChanges) return 'Unsaved changes';
    return 'Ready for dispatch';
  }

  Color _routeHealthColor(ColorScheme colorScheme) {
    if (_selectedRoute == null) return colorScheme.onSurfaceVariant;
    if (_missingGpsCount > 0) return AppColors.warning;
    if (_hasUnsavedChanges) return AppColors.info;
    return AppColors.success;
  }

  Future<void> _refreshRoutes() async {
    if (_isRefreshingRoutes) return;
    final prevSelected = _selectedRoute;
    setState(() => _isRefreshingRoutes = true);
    await _loadData();
    if (mounted && prevSelected != null && _routes.contains(prevSelected)) {
      await _onRouteSelected(prevSelected);
    }
    if (mounted) {
      setState(() => _isRefreshingRoutes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Routes refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewer = _currentViewer(authProvider: _tryAuthProvider(listen: true));
    if (!_canPlanRoute(viewer)) {
      return _buildAccessDenied();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 900;
    final routePoints = _routePoints;
    final journeyPolylinePoints = _journeyPolylinePoints;
    final selectedInsight = _selectedRoute == null
        ? null
        : _routeInsights[_selectedRoute!];
    final selectedRouteRank = _selectedRoute == null
        ? null
        : (_routes.indexOf(_selectedRoute!) + 1);
    final selectedRouteValue =
        _selectedRoute != null && _routes.contains(_selectedRoute)
        ? _selectedRoute
        : null;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Custom Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Route Planner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh routes',
                        onPressed: _isRefreshingRoutes ? null : _refreshRoutes,
                        icon: _isRefreshingRoutes
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                      ),
                      if (_hasUnsavedChanges)
                        TextButton.icon(
                          onPressed: _isSaving ? null : _saveSequence,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_rounded, size: 18),
                          label: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_hasUnsavedChanges)
                  Container(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'You have unsaved changes to the sequence',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _onRouteSelected(_selectedRoute),
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: Flex(
                    direction: isCompact ? Axis.vertical : Axis.horizontal,
                    children: [
                      // List of stops (Collapsible)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCompact
                            ? double.infinity
                            : (_isSidebarVisible ? 350 : 0),
                        height: isCompact
                            ? (_isSidebarVisible ? 280 : 0)
                            : null,
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          border: Border(
                            right: isCompact
                                ? BorderSide.none
                                : BorderSide(color: theme.dividerColor),
                            top: isCompact
                                ? BorderSide(color: theme.dividerColor)
                                : BorderSide.none,
                          ),
                          color: theme.cardColor,
                        ),
                        child: Column(
                          children: [
                            if (_isSidebarVisible) ...[
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      key: ValueKey(selectedRouteValue),
                                      initialValue: selectedRouteValue,
                                      decoration: const InputDecoration(
                                        labelText: 'Select Route',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                      items: _routes
                                          .map(
                                            (r) => DropdownMenuItem(
                                              value: r,
                                              child: Text(
                                                '${_routes.indexOf(r) + 1}. $r',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        _onRouteSelected(val);
                                      },
                                    ),
                                    if (selectedInsight != null) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Priority #${selectedRouteRank ?? 0} • ${selectedInsight.totalStops} stops • ${selectedInsight.roundTripKm.toStringAsFixed(1)} km round trip',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (_selectedRoute != null) ...[
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildRouteMetricPill(
                                            label: 'Stops',
                                            value: '${_routeCustomers.length}',
                                            color: colorScheme.primary,
                                          ),
                                          _buildRouteMetricPill(
                                            label: 'GPS',
                                            value:
                                                '${_gpsCoveragePercent.toStringAsFixed(0)}%',
                                            color: _missingGpsCount > 0
                                                ? AppColors.warning
                                                : AppColors.success,
                                          ),
                                          _buildRouteMetricPill(
                                            label: 'Round Trip',
                                            value:
                                                '${_roundTripDistanceKm.toStringAsFixed(1)} km',
                                            color: AppColors.info,
                                          ),
                                          _buildRouteMetricPill(
                                            label: 'Health',
                                            value: _routeHealthLabel,
                                            color: _routeHealthColor(
                                              colorScheme,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (_missingGpsCount > 0)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.warning
                                                  .withValues(alpha: 0.35),
                                            ),
                                          ),
                                          child: Text(
                                            '$_missingGpsCount stop(s) need latitude/longitude before final dispatch planning.',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ),
                                    ],
                                    if (_selectedRoute != null) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _smartOptimize();
                                          },
                                          icon: const Icon(
                                            Icons.auto_fix_high,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Auto Optimize Order',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.info,
                                            foregroundColor:
                                                colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        childrenPadding: EdgeInsets.zero,
                                        shape: const Border(),
                                        collapsedShape: const Border(),
                                        title: const Text(
                                          'Journey Summary',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'RT ${_roundTripDistanceKm.toStringAsFixed(1)} km • Diesel ${_estimatedDieselLiters.toStringAsFixed(1)} L',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: DropdownButtonFormField<double>(
                                                  initialValue:
                                                      _assumedMileageKmPerLiter,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'Mileage (km/L)',
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                  items: _mileageOptions
                                                      .map(
                                                        (
                                                          kmpl,
                                                        ) => DropdownMenuItem(
                                                          value: kmpl,
                                                          child: Text(
                                                            kmpl.toStringAsFixed(
                                                              0,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (value) {
                                                    if (value == null) {
                                                      return;
                                                    }
                                                    setState(
                                                      () =>
                                                          _assumedMileageKmPerLiter =
                                                              value,
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: DropdownButtonFormField<double>(
                                                  initialValue:
                                                      _dieselRatePerLiter,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'Diesel (Rs/L)',
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                  items: _dieselRateOptions
                                                      .map(
                                                        (
                                                          rate,
                                                        ) => DropdownMenuItem(
                                                          value: rate,
                                                          child: Text(
                                                            rate.toStringAsFixed(
                                                              0,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (value) {
                                                    if (value == null) {
                                                      return;
                                                    }
                                                    setState(
                                                      () =>
                                                          _dieselRatePerLiter =
                                                              value,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'One-way: ${_oneWayDistanceKm.toStringAsFixed(1)} km',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Round-trip: ${_roundTripDistanceKm.toStringAsFixed(1)} km',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Diesel needed: ${_estimatedDieselLiters.toStringAsFixed(1)} L',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Estimated fuel cost: Rs ${_estimatedDieselCost.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: _selectedRoute == null
                                    ? const Center(
                                        child: Text(
                                          'Please select a route to plan',
                                        ),
                                      )
                                    : ReorderableListView(
                                        padding: const EdgeInsets.all(16),
                                        onReorder: (oldIndex, newIndex) {
                                          setState(() {
                                            if (newIndex > oldIndex) {
                                              newIndex -= 1;
                                            }
                                            final item = _routeCustomers
                                                .removeAt(oldIndex);
                                            _routeCustomers.insert(
                                              newIndex,
                                              item,
                                            );
                                            _hasUnsavedChanges = true;
                                            final stats = _computeJourneyStats(
                                              _routeCustomers,
                                            );
                                            _oneWayDistanceKm = stats.oneWayKm;
                                            _roundTripDistanceKm =
                                                stats.roundTripKm;
                                            final selectedRoute =
                                                _selectedRoute;
                                            if (selectedRoute != null) {
                                              _routeInsights[selectedRoute] =
                                                  _RouteInsight(
                                                    totalStops:
                                                        _routeCustomers.length,
                                                    mappedStops:
                                                        stats.mappedStops,
                                                    oneWayKm: stats.oneWayKm,
                                                    roundTripKm:
                                                        stats.roundTripKm,
                                                  );
                                            }
                                          });
                                        },
                                        children: List.generate(
                                          _routeCustomers.length,
                                          (index) {
                                            final c = _routeCustomers[index];
                                            final segmentKm =
                                                _segmentDistanceKmAt(index);
                                            return Card(
                                              key: ValueKey(c.id),
                                              elevation: 2,
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: ListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                dense: true,
                                                leading: CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: AppColors
                                                      .info
                                                      .withValues(alpha: 0.16),
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  c.shopName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  _buildStopSubtitle(c, index),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (segmentKm != null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 6,
                                                            ),
                                                        child: Text(
                                                          '${segmentKm.toStringAsFixed(1)} km',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ),
                                                    Icon(
                                                      Icons.drag_handle,
                                                      size: 20,
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Map view
                      Expanded(
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: const MapOptions(
                                initialCenter: _defaultMapCenter,
                                initialZoom: _defaultMapZoom,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.dattsoap.flutter_app',
                                ),
                                if (journeyPolylinePoints.isNotEmpty)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: journeyPolylinePoints,
                                        color: AppColors.info.withValues(
                                          alpha: 0.6,
                                        ),
                                        strokeWidth: 4,
                                      ),
                                    ],
                                  ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _companyHub,
                                      width: 150,
                                      height: 46,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: AppColors.warning,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.factory,
                                              size: 14,
                                              color: AppColors.warning,
                                            ),
                                            SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                _companyHubName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ..._routeCustomers
                                        .asMap()
                                        .entries
                                        .where(
                                          (entry) =>
                                              _hasValidCoordinates(entry.value),
                                        )
                                        .map(
                                          (entry) => Marker(
                                            point: LatLng(
                                              entry.value.latitude!,
                                              entry.value.longitude!,
                                            ),
                                            width: 30,
                                            height: 30,
                                            child: CircleAvatar(
                                              backgroundColor: AppColors.info,
                                              child: Text(
                                                '${entry.key + 1}',
                                                style: TextStyle(
                                                  color: colorScheme.onPrimary,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ],
                            ),

                            // Map Controls Overlay
                            Positioned(
                              top: 16,
                              left: 16,
                              child: FloatingActionButton.small(
                                heroTag: 'toggleRouteSidebar',
                                backgroundColor: colorScheme.surface,
                                onPressed: () => setState(
                                  () => _isSidebarVisible = !_isSidebarVisible,
                                ),
                                tooltip: _isSidebarVisible
                                    ? (isCompact
                                          ? 'Hide Panel'
                                          : 'Full Screen Map')
                                    : (isCompact ? 'Show Panel' : 'Show List'),
                                child: Icon(
                                  _isSidebarVisible
                                      ? Icons.fullscreen
                                      : Icons.menu_open,
                                  color: AppColors.info,
                                ),
                              ),
                            ),

                            // Route Stats Overlay
                            if (_selectedRoute != null)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isCompact ? 220 : 320,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.shadow.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _selectedRoute!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (isCompact)
                                          Text(
                                            '${routePoints.length}/${_routeCustomers.length} GPS | RT ${_roundTripDistanceKm.toStringAsFixed(1)} km',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          )
                                        else
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.store,
                                                size: 14,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${routePoints.length}/${_routeCustomers.length} GPS',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.straighten,
                                                size: 14,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'RT ${_roundTripDistanceKm.toStringAsFixed(1)} km',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.local_gas_station,
                                                size: 14,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_estimatedDieselLiters.toStringAsFixed(1)} L',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.health_and_safety_outlined,
                                              size: 14,
                                              color: _routeHealthColor(
                                                colorScheme,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _routeHealthLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: _routeHealthColor(
                                                  colorScheme,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (_selectedRoute != null && _missingGpsCount > 0)
                              Positioned(
                                top: 84,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '$_missingGpsCount stop(s) missing GPS',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(
                                    alpha: 0.92,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  'Map: OpenStreetMap | Plan before dispatch',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRouteMetricPill({
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _JourneyStats {
  final double oneWayKm;
  final double roundTripKm;
  final int mappedStops;

  const _JourneyStats({
    required this.oneWayKm,
    required this.roundTripKm,
    required this.mappedStops,
  });
}

class _RouteInsight {
  final int totalStops;
  final int mappedStops;
  final double oneWayKm;
  final double roundTripKm;

  const _RouteInsight({
    required this.totalStops,
    required this.mappedStops,
    required this.oneWayKm,
    required this.roundTripKm,
  });
}
