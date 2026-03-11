import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/gps_service.dart';
import '../../services/duty_service.dart';
import '../../services/visit_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../widgets/ui/themed_segment_control.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/utils/responsive.dart';
import '../../constants/role_access_matrix.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';

class GPSTrackingScreen extends StatefulWidget {
  final Stream<List<LocationData>> Function()? liveLocationStreamFactory;
  final Stream<List<RouteSession>> Function(String date)?
  routeSummaryStreamFactory;
  final Stream<List<DutySession>> Function(String date)?
  dutySummaryStreamFactory;
  final Future<List<LocationHistoryPoint>> Function(
    String userId,
    DateTime startDate,
    DateTime endDate,
  )?
  historyLoader;
  final ValueChanged<String>? lifecycleLogger;

  const GPSTrackingScreen({
    super.key,
    this.liveLocationStreamFactory,
    this.routeSummaryStreamFactory,
    this.dutySummaryStreamFactory,
    this.historyLoader,
    this.lifecycleLogger,
  });

  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final GpsService _gpsService;
  late final DutyService _dutyService;
  late final VisitService _visitService;

  // Live Tracking State
  List<LocationData> _activeUsers = [];
  String _roleFilter = 'All';
  LocationData? _selectedUser;
  final MapController _liveMapController = MapController();
  StreamSubscription? _locationSubscription;

  // Route Replay State
  DateTime _replayDate = DateTime.now();
  LocationData? _replayUser;
  List<LocationHistoryPoint> _history = [];
  int _currentReplayIndex = 0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Timer? _replayTimer;
  final MapController _replayMapController = MapController();

  // Daily Summary State
  DateTime _summaryDate = DateTime.now();
  List<RouteSession> _summarySessions = [];
  List<DutySession> _dutySessions = [];
  StreamSubscription<List<RouteSession>>? _routeSummarySubscription;
  StreamSubscription<List<DutySession>>? _dutySummarySubscription;
  String? _summaryDateSubscriptionKey;

  // Lifecycle diagnostics (used for leak-proofing and tests)
  int _routeSummaryAttachCount = 0;
  int _dutySummaryAttachCount = 0;
  int _routeSummaryCallbackCount = 0;
  int _dutySummaryCallbackCount = 0;

  bool get _isInjectedDataMode {
    return widget.liveLocationStreamFactory != null ||
        widget.routeSummaryStreamFactory != null ||
        widget.dutySummaryStreamFactory != null ||
        widget.historyLoader != null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _tabController.addListener(_handleTabChange);

    if (widget.liveLocationStreamFactory == null ||
        widget.historyLoader == null) {
      _gpsService = context.read<GpsService>();
    }
    if (widget.dutySummaryStreamFactory == null) {
      _dutyService = context.read<DutyService>();
    }
    if (widget.routeSummaryStreamFactory == null) {
      _visitService = context.read<VisitService>();
    }

    _initLiveTracking();
    _loadSummaryData(reason: 'init', force: true);
  }

  void _handleTabChange() {
    if (_tabController.index != 2) return;
    if (_tabController.indexIsChanging) return;
    _loadSummaryData(reason: 'tab_change');
  }

  void _initLiveTracking() {
    final stream =
        widget.liveLocationStreamFactory?.call() ??
        _gpsService.subscribeToLocations();
    _locationSubscription = stream.listen((locations) {
      if (mounted) {
        setState(() {
          _activeUsers = locations;
        });
      }
    });
  }

  Future<void> _loadSummaryData({
    bool force = false,
    String reason = 'manual',
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_summaryDate);
    final alreadyAttachedForDate =
        !force &&
        _summaryDateSubscriptionKey == dateStr &&
        _routeSummarySubscription != null &&
        _dutySummarySubscription != null;
    if (alreadyAttachedForDate) {
      _emitLifecycleLog('summary_attach_skip_same_date:$dateStr:$reason');
      return;
    }

    _emitLifecycleLog('summary_attach_rebind:$dateStr:$reason');
    await _routeSummarySubscription?.cancel();
    await _dutySummarySubscription?.cancel();
    _routeSummarySubscription = null;
    _dutySummarySubscription = null;
    _summaryDateSubscriptionKey = dateStr;

    final routeStream =
        widget.routeSummaryStreamFactory?.call(dateStr) ??
        _visitService.subscribeToDateSessions(dateStr);
    _routeSummaryAttachCount++;
    _routeSummarySubscription = routeStream.listen(
      (sessions) {
        _routeSummaryCallbackCount++;
        if (!mounted) return;
        setState(() => _summarySessions = sessions);
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _summarySessions = []);
      },
    );

    final dutyStream =
        widget.dutySummaryStreamFactory?.call(dateStr) ??
        _dutyService.subscribeToDateDutySessions(dateStr);
    _dutySummaryAttachCount++;
    _dutySummarySubscription = dutyStream.listen(
      (sessions) {
        _dutySummaryCallbackCount++;
        if (!mounted) return;
        setState(() => _dutySessions = sessions);
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _dutySessions = []);
      },
    );

    _emitLifecycleLog('summary_attach_done:$dateStr:$reason');
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _routeSummarySubscription?.cancel();
    _dutySummarySubscription?.cancel();
    _tabController.dispose();
    _locationSubscription?.cancel();
    _replayTimer?.cancel();
    _emitLifecycleLog('dispose');
    super.dispose();
  }

  // --- Replay Logic ---
  Future<void> _loadHistory() async {
    if (_replayUser == null) return;
    setState(() {
      _history = [];
      _currentReplayIndex = 0;
      _isPlaying = false;
    });
    _replayTimer?.cancel();

    final start = DateTime(
      _replayDate.year,
      _replayDate.month,
      _replayDate.day,
      0,
      0,
      0,
    );
    final end = DateTime(
      _replayDate.year,
      _replayDate.month,
      _replayDate.day,
      23,
      59,
      59,
    );

    final history = await _loadHistoryPoints(_replayUser!.userId, start, end);

    if (mounted) {
      setState(() {
        _history = history;
      });
      if (history.isNotEmpty) {
        _replayMapController.move(
          LatLng(history.first.latitude, history.first.longitude),
          15,
        );
      }
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _replayTimer?.cancel();
    } else {
      if (_currentReplayIndex >= _history.length - 1) {
        setState(() => _currentReplayIndex = 0);
      }
      _startPlayback();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _startPlayback() {
    _replayTimer?.cancel();
    _replayTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _playbackSpeed).round()),
      (timer) {
        if (_currentReplayIndex < _history.length - 1) {
          setState(() {
            _currentReplayIndex++;
          });
          final point = _history[_currentReplayIndex];
          _replayMapController.move(
            LatLng(point.latitude, point.longitude),
            _replayMapController.camera.zoom,
          );
        } else {
          timer.cancel();
          setState(() => _isPlaying = false);
        }
      },
    );
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    final authProvider = _tryAuthProvider(listen: true);
    final canViewAll = _hasMapCapability(
      RoleCapability.mapViewAll,
      authProvider: authProvider,
    );
    final canViewSelf = _hasMapCapability(
      RoleCapability.mapViewSelf,
      authProvider: authProvider,
    );
    if (authProvider != null && !canViewAll && !canViewSelf) {
      return _buildMapAccessDenied(
        title: 'GPS Access Restricted',
        message:
            'Your role does not have permission to view live tracking data.',
      );
    }
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom Header Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        'GPS Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh live data',
                      onPressed: _refreshLiveTracking,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ThemedTabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Live Tracking'),
                    Tab(text: 'Route Replay'),
                    Tab(text: 'Daily Summary'),
                  ],
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLiveTrackingTab(),
                _buildRouteReplayTab(),
                _buildDailySummaryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSidebarVisible = true;
  bool _isReplaySidebarVisible = true;
  String _liveSearchQuery = '';
  static const Duration _staleLocationThreshold = Duration(minutes: 5);

  Future<void> _refreshLiveTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _initLiveTracking();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing live locations...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Duration _locationAge(LocationData user) {
    DateTime? updatedAt = DateTime.tryParse(user.lastUpdated);
    if (updatedAt == null && user.timestamp > 0) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(user.timestamp);
    }
    if (updatedAt == null) {
      return const Duration(days: 365);
    }
    final age = DateTime.now().difference(updatedAt.toLocal());
    if (age.isNegative) return Duration.zero;
    return age;
  }

  bool _isLocationStale(LocationData user) {
    return _locationAge(user) > _staleLocationThreshold;
  }

  String _formatRelativeAge(Duration age) {
    if (age.inSeconds < 60) return '${age.inSeconds}s';
    if (age.inMinutes < 60) return '${age.inMinutes}m';
    if (age.inHours < 24) return '${age.inHours}h';
    return '${age.inDays}d';
  }

  bool _isValidCoordinatePair(double latitude, double longitude) {
    if (latitude.abs() > 90 || longitude.abs() > 180) return false;
    if (latitude == 0 && longitude == 0) return false;
    return true;
  }

  bool _hasValidLocation(LocationData user) {
    return _isValidCoordinatePair(user.latitude, user.longitude);
  }

  double _averageSpeed(List<LocationData> users) {
    final moving = users
        .map((u) => u.speed ?? 0)
        .where((speed) => speed > 0)
        .toList(growable: false);
    if (moving.isEmpty) return 0;
    final total = moving.fold<double>(0, (sum, speed) => sum + speed);
    return total / moving.length;
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

  bool _hasMapCapability(
    RoleCapability capability, {
    AuthProvider? authProvider,
  }) {
    final provider = authProvider ?? _tryAuthProvider();
    if (provider == null) {
      // Allow provider-less access only for injected/test harness mode.
      return _isInjectedDataMode;
    }
    final viewer = provider.currentUser;
    if (viewer == null) return false;
    return RoleAccessMatrix.hasCapability(viewer.role, capability);
  }

  List<LocationData> _scopeLocationUsers(List<LocationData> users) {
    if (_hasMapCapability(RoleCapability.mapViewAll)) {
      return users;
    }
    final viewer = _currentViewer();
    if (viewer != null && _hasMapCapability(RoleCapability.mapViewSelf)) {
      return users.where((u) => u.userId == viewer.id).toList(growable: false);
    }
    return const <LocationData>[];
  }

  List<DutySession> _scopeDutySessions(List<DutySession> sessions) {
    if (_hasMapCapability(RoleCapability.mapViewAll)) {
      return sessions;
    }
    final viewer = _currentViewer();
    if (viewer != null && _hasMapCapability(RoleCapability.mapViewSelf)) {
      return sessions
          .where((session) => session.userId == viewer.id)
          .toList(growable: false);
    }
    return const <DutySession>[];
  }

  List<RouteSession> _scopeRouteSessions(List<RouteSession> sessions) {
    if (_hasMapCapability(RoleCapability.mapViewAll)) {
      return sessions;
    }
    final viewer = _currentViewer();
    if (viewer != null && _hasMapCapability(RoleCapability.mapViewSelf)) {
      return sessions
          .where((session) => session.salesmanId == viewer.id)
          .toList(growable: false);
    }
    return const <RouteSession>[];
  }

  Widget _buildMapAccessDenied({
    required String title,
    required String message,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
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

  Widget _buildLiveTrackingTab() {
    if (!_hasMapCapability(RoleCapability.mapViewAll) &&
        !_hasMapCapability(RoleCapability.mapViewSelf)) {
      return const Center(
        child: Text(
          'No location permission for current role.',
          style: TextStyle(fontSize: 13),
        ),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 900;
    final scopedUsers = _scopeLocationUsers(_activeUsers);
    final filtered =
        scopedUsers.where((u) {
          final roleMatch =
              _roleFilter == 'All' ||
              u.role.toLowerCase() == _roleFilter.toLowerCase();
          if (!roleMatch) return false;
          final query = _liveSearchQuery.trim().toLowerCase();
          if (query.isEmpty) return true;
          return u.userName.toLowerCase().contains(query) ||
              u.role.toLowerCase().contains(query);
        }).toList()..sort((a, b) {
          if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
          return b.timestamp.compareTo(a.timestamp);
        });
    final activeCount = filtered.where((u) => u.isOnline).length;
    final staleCount = filtered.where(_isLocationStale).length;
    final movingCount = filtered.where((u) => (u.speed ?? 0) > 1).length;
    final avgSpeed = _averageSpeed(filtered);
    final mapUsers = filtered.where(_hasValidLocation).toList(growable: false);

    final sidebar = Container(
      decoration: BoxDecoration(
        border: isCompact
            ? Border(top: BorderSide(color: Theme.of(context).dividerColor))
            : Border(right: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ThemedSegmentControl<String>(
              segments: const [
                ButtonSegment(
                  value: 'All',
                  label: Text('All'),
                  icon: Icon(Icons.group, size: 16),
                ),
                ButtonSegment(
                  value: 'Driver',
                  label: Text('Driver'),
                  icon: Icon(Icons.local_shipping, size: 16),
                ),
                ButtonSegment(
                  value: 'Salesman',
                  label: Text('Sales'),
                  icon: Icon(Icons.person, size: 16),
                ),
              ],
              selected: {_roleFilter},
              onSelectionChanged: (val) =>
                  setState(() => _roleFilter = val.first),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _liveSearchQuery = value),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Search member',
                prefixIcon: Icon(Icons.search, size: 18),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInlineStatPill(
                  label: 'Active',
                  value: '$activeCount',
                  color: AppColors.success,
                ),
                _buildInlineStatPill(
                  label: 'Moving',
                  value: '$movingCount',
                  color: AppColors.info,
                ),
                _buildInlineStatPill(
                  label: 'Stale',
                  value: '$staleCount',
                  color: AppColors.warning,
                ),
                _buildInlineStatPill(
                  label: 'Avg Speed',
                  value: '${avgSpeed.toStringAsFixed(1)} km/h',
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No members found for current filter',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (c, i) {
                      final user = filtered[i];
                      final isSelected = _selectedUser?.userId == user.userId;
                      final age = _locationAge(user);
                      final isStale = _isLocationStale(user);
                      final statusLabel = isStale
                          ? 'Stale'
                          : (user.isOnline ? 'Live' : 'Offline');
                      final statusColor = isStale
                          ? AppColors.warning
                          : (user.isOnline
                                ? AppColors.success
                                : colorScheme.onSurfaceVariant);
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedTileColor: AppColors.info.withValues(
                          alpha: 0.05,
                        ),
                        leading: Badge(
                          backgroundColor: statusColor,
                          child: CircleAvatar(
                            radius: 16,
                            child: Text(
                              user.userName.isNotEmpty ? user.userName[0] : '?',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        title: Text(
                          user.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${user.role} | $statusLabel | ${_formatRelativeAge(age)} ago',
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: user.speed != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${user.speed!.toStringAsFixed(1)} km/h',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedUser = user);
                          if (!_hasValidLocation(user)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selected user has invalid GPS coordinates.',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          _liveMapController.move(
                            LatLng(user.latitude, user.longitude),
                            15,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    final map = Stack(
      children: [
        FlutterMap(
          mapController: _liveMapController,
          options: const MapOptions(
            initialCenter: LatLng(20.5937, 78.9629),
            initialZoom: 5.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.dattsoap.flutter_app',
            ),
            MarkerLayer(
              markers: mapUsers
                  .map(
                    (u) => Marker(
                      point: LatLng(u.latitude, u.longitude),
                      width: Responsive.clamp(
                        context,
                        min: 48,
                        max: 64,
                        ratio: 0.06,
                      ),
                      height: Responsive.clamp(
                        context,
                        min: 48,
                        max: 64,
                        ratio: 0.06,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedUser = u),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                u.userName,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              color: u.isOnline
                                  ? AppColors.info
                                  : colorScheme.onSurfaceVariant,
                              size: 35,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          child: FloatingActionButton.small(
            heroTag: 'toggleSidebar',
            backgroundColor: colorScheme.surface,
            onPressed: () =>
                setState(() => _isSidebarVisible = !_isSidebarVisible),
            tooltip: _isSidebarVisible
                ? (isCompact ? 'Hide Panel' : 'Full Screen Map')
                : (isCompact ? 'Show Panel' : 'Show List'),
            child: Icon(
              _isSidebarVisible ? Icons.fullscreen : Icons.menu_open,
              color: AppColors.info,
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              _buildStatMiniCard('Active', '$activeCount', AppColors.success),
              const SizedBox(width: 8),
              _buildStatMiniCard('Stale', '$staleCount', AppColors.warning),
              const SizedBox(width: 8),
              _buildStatMiniCard('Total', '${filtered.length}', AppColors.info),
            ],
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              'Data poll: 30s | Map: OpenStreetMap',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        children: [
          Expanded(child: map),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: _isSidebarVisible ? 220 : 0,
            child: ClipRect(child: sidebar),
          ),
        ],
      );
    }

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isSidebarVisible ? 320 : 0,
          curve: Curves.easeInOut,
          child: sidebar,
        ),
        Expanded(child: map),
      ],
    );
  }

  Widget _buildRouteReplayTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 900;
    final visibleReplayUsers = _scopeLocationUsers(_activeUsers);
    final replayUserValue =
        _replayUser != null &&
            visibleReplayUsers.any((u) => u.userId == _replayUser!.userId)
        ? _replayUser
        : null;

    final selectionPanel = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: isCompact
            ? Border(top: BorderSide(color: colorScheme.outlineVariant))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LocationData>(
              initialValue: replayUserValue,
              decoration: const InputDecoration(
                labelText: 'Staff Member',
                border: OutlineInputBorder(),
              ),
              items: visibleReplayUsers
                  .map(
                    (u) => DropdownMenuItem(value: u, child: Text(u.userName)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _replayUser = val),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _replayDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _replayDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(DateFormat('dd MMM yyyy').format(_replayDate)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: replayUserValue == null ? null : _loadHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Load History'),
              ),
            ),
            const Spacer(),
            if (_history.isNotEmpty) ...[
              const Divider(),
              _buildReplayControls(),
            ],
          ],
        ),
      ),
    );

    final mapAndTimeline = Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _replayMapController,
            options: const MapOptions(
              initialCenter: LatLng(20.5937, 78.9629),
              initialZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dattsoap.flutter_app',
              ),
              if (_history.isNotEmpty) ...[
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _history
                          .map((p) => LatLng(p.latitude, p.longitude))
                          .toList(),
                      color: AppColors.info.withValues(alpha: 0.5),
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _history[_currentReplayIndex].latitude,
                        _history[_currentReplayIndex].longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.local_shipping,
                        color: AppColors.info,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (_history.isNotEmpty)
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      _formatDateSafe(
                        _history[_currentReplayIndex].isoTimestamp,
                        pattern: 'HH:mm:ss',
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentReplayIndex.toDouble(),
                        max: (_history.length - 1).toDouble(),
                        onChanged: (val) {
                          setState(() {
                            _currentReplayIndex = val.toInt();
                            final point = _history[_currentReplayIndex];
                            _replayMapController.move(
                              LatLng(point.latitude, point.longitude),
                              _replayMapController.camera.zoom,
                            );
                          });
                        },
                      ),
                    ),
                    Text(
                      _formatDateSafe(
                        _history.last.isoTimestamp,
                        pattern: 'HH:mm:ss',
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _togglePlay,
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 40,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 24),
                    DropdownButton<double>(
                      value: _playbackSpeed,
                      items: [1.0, 2.0, 4.0, 8.0, 16.0]
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text('${s.toInt()}x'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _playbackSpeed = val!);
                        if (_isPlaying) _startPlayback();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );

    if (isCompact) {
      final panelHeight = _history.isNotEmpty ? 300.0 : 230.0;
      return Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: _isReplaySidebarVisible ? panelHeight : 0,
            child: ClipRect(child: selectionPanel),
          ),
          Expanded(
            child: Stack(
              children: [
                mapAndTimeline,
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'toggleReplaySidebar',
                    backgroundColor: colorScheme.surface,
                    onPressed: () => setState(
                      () => _isReplaySidebarVisible = !_isReplaySidebarVisible,
                    ),
                    tooltip: _isReplaySidebarVisible
                        ? 'Hide Panel'
                        : 'Show Selection',
                    child: Icon(
                      _isReplaySidebarVisible
                          ? Icons.fullscreen
                          : Icons.tune_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: Responsive.clamp(context, min: 240, max: 360, ratio: 0.28),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: selectionPanel,
        ),
        Expanded(child: mapAndTimeline),
      ],
    );
  }

  Widget _buildDailySummaryTab() {
    final visibleDutySessions = _scopeDutySessions(_dutySessions);
    final visibleRouteSessions = _scopeRouteSessions(_summarySessions);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Activity for: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(DateFormat('dd MMM yyyy').format(_summaryDate)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _summaryDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    if (DateUtils.isSameDay(picked, _summaryDate)) {
                      _emitLifecycleLog('summary_date_skip_same_day');
                      return;
                    }
                    setState(() => _summaryDate = picked);
                    _loadSummaryData(reason: 'summary_date_changed');
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Member')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Login')),
                DataColumn(label: Text('Logout')),
                DataColumn(label: Text('Distance')),
                DataColumn(label: Text('Stops')),
              ],
              rows: visibleDutySessions.map((s) {
                // Find matching route session for stops
                final routeSess = visibleRouteSessions
                    .where((rs) => rs.salesmanId == s.userId)
                    .firstOrNull;
                return DataRow(
                  cells: [
                    DataCell(Text(s.userName)),
                    DataCell(Text(s.userRole)),
                    DataCell(_buildStatusBadge(s.status)),
                    DataCell(
                      Text(_formatDateSafe(s.loginTime, pattern: 'HH:mm')),
                    ),
                    DataCell(
                      Text(
                        s.logoutTime != null
                            ? _formatDateSafe(s.logoutTime!, pattern: 'HH:mm')
                            : '-',
                      ),
                    ),
                    DataCell(
                      Text(
                        '${s.totalDistanceKm?.toStringAsFixed(1) ?? '0.0'} km',
                      ),
                    ),
                    DataCell(
                      Text(
                        routeSess != null
                            ? '${routeSess.completedStops}/${routeSess.plannedStops}'
                            : '-',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatMiniCard(String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineStatPill({
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

  Widget _buildStatusBadge(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color = colorScheme.onSurfaceVariant;
    if (status == 'active') color = AppColors.success;
    if (status == 'completed') color = AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReplayControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary for ${DateFormat('dd MMM').format(_replayDate)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSummaryItem(Icons.route, 'Points', '${_history.length}'),
        _buildSummaryItem(
          Icons.speed,
          'Avg Speed',
          '${(_history.isNotEmpty ? _history.map((h) => h.speed).reduce((a, b) => a + b) / _history.length : 0).toStringAsFixed(1)} km/h',
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Future<List<LocationHistoryPoint>> _loadHistoryPoints(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final loader = widget.historyLoader;
    if (loader != null) {
      return loader(userId, startDate, endDate);
    }
    return _gpsService.getLocationHistory(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  void _emitLifecycleLog(String event) {
    final message =
        'GPS_SUMMARY_LIFECYCLE event=$event routeAttach=$_routeSummaryAttachCount dutyAttach=$_dutySummaryAttachCount routeCallbacks=$_routeSummaryCallbackCount dutyCallbacks=$_dutySummaryCallbackCount date=$_summaryDateSubscriptionKey';
    widget.lifecycleLogger?.call(message);
  }

  @visibleForTesting
  int get debugRouteSummaryAttachCount => _routeSummaryAttachCount;

  @visibleForTesting
  int get debugDutySummaryAttachCount => _dutySummaryAttachCount;

  @visibleForTesting
  int get debugRouteSummaryCallbackCount => _routeSummaryCallbackCount;

  @visibleForTesting
  int get debugDutySummaryCallbackCount => _dutySummaryCallbackCount;
}
