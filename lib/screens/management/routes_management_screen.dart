import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/vehicles_service.dart';
import '../../utils/app_toast.dart';
import 'dialogs/add_route_dialog.dart';
import 'dialogs/edit_route_dialog.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import '../../constants/maharashtra_zones.dart';

class RoutesManagementScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isReadOnly;
  const RoutesManagementScreen({
    super.key,
    this.onBack,
    this.isReadOnly = false,
  });

  @override
  State<RoutesManagementScreen> createState() => _RoutesManagementScreenState();
}

class _RoutesManagementScreenState extends State<RoutesManagementScreen> {
  late final VehiclesService _vehiclesService;
  bool _isLoading = true;
  List<RouteData> _routes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _loadRoutes();
  }

  Future<void> _loadRoutes({bool refreshRemote = false}) async {
    setState(() => _isLoading = true);
    try {
      final routes = await _vehiclesService.getRoutes(
        refreshRemote: refreshRemote,
      );
      if (mounted) {
        setState(() {
          _routes = routes
              .map((r) => RouteData.fromMap(r, (r['id'] ?? '').toString()))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading routes: $e');
      }
    }
  }

  List<RouteData> get _filteredRoutes {
    if (_searchQuery.isEmpty) return _routes;
    final query = _searchQuery.toLowerCase();
    return _routes
        .where(
          (r) =>
              r.name.toLowerCase().contains(query) ||
              r.zone.toLowerCase().contains(query) ||
              r.district.toLowerCase().contains(query) ||
              r.area.toLowerCase().contains(query), // Backward compat
        )
        .toList();
  }

  Future<void> _deleteRoute(String routeId) async {
    if (widget.isReadOnly) {
      AppToast.showWarning(context, 'Read-only mode: changes are disabled');
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _vehiclesService.deleteRoute(routeId);
        _loadRoutes();
        if (mounted) {
          AppToast.showSuccess(context, 'Route deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, 'Error deleting route: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      backgroundColor: surface,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(surface, surfaceVariant, onSurface),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRoutes.isEmpty
                ? _buildEmptyState()
                : _buildRoutesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return MasterScreenHeader(
      title: 'Routes & Vehicles',
      subtitle: 'Logistics & dispatch configuration',
      helperText:
          'Vehicle usage is tracked in dispatch. Configuration is managed here.',
      color: Colors.cyan,
      icon: Icons.local_shipping,
      onBack: widget.onBack,
      actions: [
        ElevatedButton.icon(
          onPressed: widget.isReadOnly
              ? null
              : () async {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => const AddRouteDialog(),
                  );
                  if (result == true) {
                    _loadRoutes();
                  }
                },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Route'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
          onPressed: () => _loadRoutes(refreshRemote: true),
          tooltip: 'Refresh from cloud',
        ),
      ],
    );
  }

  Widget _buildSearchBar(Color surface, Color surfaceVariant, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: surface,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search routes by name or area...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: surfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: surfaceVariant.withValues(alpha: 0.3),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
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
            Icons.route,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Routes Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first delivery route to get started',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: widget.isReadOnly
                ? null
                : () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => const AddRouteDialog(),
                    );
                    if (result == true) {
                      _loadRoutes();
                    }
                  },
            icon: const Icon(Icons.add),
            label: const Text('Add Route'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4f46e5),
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRoutes.length,
      itemBuilder: (context, index) {
        final route = _filteredRoutes[index];
        return _buildRouteCard(route);
      },
    );
  }

  Widget _buildRouteCard(RouteData route) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.route, color: primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.displayLocation,
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  if (route.salesmanName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: muted),
                        const SizedBox(width: 4),
                        Text(
                          route.salesmanName,
                          style: TextStyle(color: onSurface, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: route.status == 'active'
                    ? AppColors.success.withValues(alpha: 0.12)
                    : muted.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                route.status.toUpperCase(),
                style: TextStyle(
                  color: route.status == 'active' ? AppColors.success : muted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              enabled: !widget.isReadOnly,
              onSelected: (value) async {
                if (widget.isReadOnly) return;
                if (value == 'edit') {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => EditRouteDialog(route: route),
                  );
                  if (result == true) {
                    _loadRoutes();
                  }
                } else if (value == 'delete') {
                  _deleteRoute(route.id);
                }
              },
              itemBuilder: (context) => widget.isReadOnly
                  ? const [
                      PopupMenuItem(
                        enabled: false,
                        child: Text('Read-only'),
                      ),
                    ]
                  : const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

class RouteData {
  final String id;
  final String name;
  final String zone; // New: Zone (Division)
  final String district; // New: District (replaces area)
  final String area; // Deprecated: Kept for backward compatibility
  final String description;
  final String salesmanId;
  final String salesmanName;
  final String status;

  RouteData({
    required this.id,
    required this.name,
    this.zone = '',
    this.district = '',
    this.area = '', // Backward compat
    this.description = '',
    this.salesmanId = '',
    this.salesmanName = '',
    this.status = 'active',
  });

  factory RouteData.fromMap(Map<String, dynamic> map, String id) {
    final district = _readString(map, const ['district', 'area']);
    final zone = _readString(map, const ['zone']);
    final isActive = map['isActive'] == true;
    final status = _readString(map, const ['status']).toLowerCase();

    return RouteData(
      id: id,
      name: _readString(map, const ['name']),
      zone: zone.isNotEmpty
          ? zone
          : (district.isNotEmpty
                ? (MaharashtraZones.getZoneForDistrict(district) ?? '')
                : ''),
      district: district,
      area: _readString(map, const ['area']),
      description: _readString(map, const ['description']),
      salesmanId: _readString(map, const ['salesmanId']),
      salesmanName: _readString(map, const ['salesmanName']),
      status: status.isNotEmpty ? status : (isActive ? 'active' : 'inactive'),
    );
  }

  static String _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      final normalized = value.toString().trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'zone': zone,
      'district': district,
      'area': district.isNotEmpty ? district : area,
      'description': description,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'status': status,
      'isActive': status == 'active',
    };
  }

  /// Alias for `toMap()` for compatibility with service calls
  Map<String, dynamic> toJson() => toMap();

  // Display helper: zone + district or fallback to area
  String get displayLocation {
    if (zone.isNotEmpty && district.isNotEmpty) {
      return '$district, $zone';
    }
    return area.isNotEmpty ? area : district;
  }
}
