import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/theme_settings_provider.dart';
import '../../constants/nav_items.dart';
import '../../providers/service_providers.dart';
import '../../models/types/user_types.dart';
import '../../models/types/alert_types.dart';

import 'ai_assistant_panel.dart';
import '../../core/theme/app_colors.dart';
import '../../core/shortcuts/shortcuts_core.dart';
import '../../utils/app_logger.dart';
import '../../utils/mobile_header_typography.dart';
import '../../utils/app_toast.dart';
import '../../utils/pdf_generator.dart';
import '../common/key_tip.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/utils/responsive.dart';
import '../../screens/inventory/inventory_overview_screen.dart';
import '../../screens/inventory/tanks_list_screen.dart';
import '../../screens/inventory/stock_adjustment_screen.dart';
import '../../screens/inventory/opening_stock_setup_screen.dart';
import '../../screens/inventory/my_stock_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/dashboard/salesman_dashboard_screen.dart';
import '../../screens/dashboard/dealer_dashboard_screen.dart';
import '../../screens/management/user_profile_screen.dart';
import '../../screens/management/management_module_screen.dart';
import '../../screens/management/products_list_screen.dart';
import '../../screens/management/formulas_screen.dart';
import '../../screens/management/master_data_screen.dart';
import '../../screens/reports/reporting_hub_screen.dart';
import '../../screens/reports/dealer_report_screen.dart';
import '../../screens/reports/target_achievement_report_screen.dart';
import '../../screens/reports/my_performance_screen.dart';
import '../../screens/returns/returns_management_screen.dart';
import '../../screens/returns/salesman_returns_screen.dart';
import '../../screens/purchase_orders/purchase_orders_list_screen.dart';
import '../../screens/fuel/fuel_log_screen.dart';
import '../../screens/fuel/fuel_stock_screen.dart';
import '../../screens/fuel/fuel_history_screen.dart';
import '../../screens/vehicles/vehicle_management_screen.dart';
import '../../screens/dispatch/dispatch_screen.dart';
import '../../screens/dispatch/dealer_dispatch_screen.dart';
import '../../screens/dispatch/new_trip_screen.dart';
import '../../screens/business_partners/business_partners_screen.dart';
import '../../screens/tasks/tasks_screen.dart';
import '../../screens/production/production_dashboard_consolidated_screen.dart';
import '../../screens/sales/sales_history_screen.dart';
import '../../screens/gps/gps_tracking_screen.dart';
import '../../screens/driver/duty_screen.dart';
import '../../screens/driver/driver_trips_screen.dart';
import '../../screens/driver/vehicle_info_screen.dart';
import '../../screens/driver/driver_diesel_log_screen.dart';
import '../../screens/driver/vehicle_mileage_screen.dart';
import '../../screens/management/new_dealer_sale_screen.dart';
import '../../screens/payments/payments_screen.dart';
import '../../screens/business_partners/business_partner_form_dialog.dart';
import '../../screens/orders/route_order_management_screen.dart';
import '../../screens/tasks/task_history_screen.dart';
import '../../screens/production/production_stock_screen.dart';
import '../../screens/production/cutting_history_screen.dart';
import '../../screens/production/cutting_batch_entry_screen.dart';
import '../../screens/bhatti/bhatti_cooking_screen.dart';
import '../../screens/bhatti/bhatti_supervisor_screen.dart';
import '../../screens/bhatti/bhatti_dashboard_screen.dart';
import '../../screens/sales/new_sale_screen.dart';
import '../../screens/map/customers_map_screen.dart';
import '../../screens/map/route_planner_screen.dart';
import '../ui/auto_sync_status_indicator.dart';

class WorkspaceTab {
  String path;
  String title;
  IconData icon;
  String? splitPath;

  WorkspaceTab({
    required this.path,
    required this.title,
    required this.icon,
    this.splitPath,
  });
}

enum SidebarMode { expanded, collapsed, hidden }

class MainScaffold extends rp.ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  rp.ConsumerState<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends rp.ConsumerState<MainScaffold>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _lastUserId;
  String? _lastAuthUid;
  String _appVersion = '';
  StreamSubscription<int>? _unreadTaskSubscription;

  // Workspace State
  final List<WorkspaceTab> _tabs = [
    WorkspaceTab(
      path: '/dashboard',
      title: 'ERP Dashboard',
      icon: Icons.dashboard_outlined,
    ),
  ];
  int _activeTabIndex = 0;
  // Sidebar State
  SidebarMode _sidebarMode = SidebarMode.expanded; // Default start state
  int _unreadTaskCount = 0;
  bool _isOnline = true;
  bool _isReportExporting = false;
  bool _isProfileHovered = false;
  int _businessPartnersRefreshTick = 0;
  final GlobalKey _reportPrintBoundaryKey = GlobalKey();
  final List<String> _routeHistory = <String>[];
  late StreamSubscription<ConnectivityResult> _connectivitySub;
  Timer? _routeOrderFlashTimer;
  final Random _routeOrderFlashRandom = Random();
  List<String> _routeOrderFlashSequence = const [];
  int _routeOrderFlashSequenceIndex = 0;
  static const Duration _routeOrderFlashRotateInterval = Duration(seconds: 6);

  // Public methods for children to use
  void openNewTab(String path) {
    setState(() {
      _tabs.add(
        WorkspaceTab(
          path: path,
          title: _getPageTitle(path),
          icon: _getIconForPath(path),
        ),
      );
      _activeTabIndex = _tabs.length - 1;
    });
    context.go(path);
  }

  void openSplitView(String path) {
    setState(() {
      _tabs[_activeTabIndex].splitPath = path;
    });
  }

  void _navigateFromMenu(String path) {
    final isDesktop = Responsive.width(context) > 600;
    final isMobile = !isDesktop;
    final normalizedPath = _normalizedPath(path);
    final isSettingsRoute =
        normalizedPath == '/dashboard/settings' ||
        normalizedPath.startsWith('/dashboard/settings/');

    if (isMobile && (_scaffoldKey.currentState?.isDrawerOpen ?? false)) {
      _scaffoldKey.currentState?.closeDrawer();
    }

    if (isDesktop && isSettingsRoute) {
      openNewTab(path);
      return;
    }

    context.go(path);
  }

  String _normalizedPath(String path) => path.split('?').first;

  String _normalizedPathNoTrailingSlash(String path) {
    final normalized = _normalizedPath(path);
    if (normalized.length > 1 && normalized.endsWith('/')) {
      return normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  bool _isHomeRouteForRole(String path, UserRole role) {
    final normalized = _normalizedPathNoTrailingSlash(path);
    if (normalized == '/dashboard') return true;
    if (normalized.endsWith('/dashboard')) return true;
    if (role == UserRole.productionSupervisor &&
        normalized == '/dashboard/production') {
      return true;
    }
    if (role == UserRole.bhattiSupervisor &&
        normalized == '/dashboard/bhatti/overview') {
      return true;
    }
    if (role == UserRole.fuelIncharge && normalized == '/dashboard/fuel') {
      return true;
    }
    if (role == UserRole.accountant && normalized == '/dashboard/accounting') {
      return true;
    }
    return false;
  }

  bool _matchesPathPrefix(String currentPath, String candidatePath) {
    final current = _normalizedPathNoTrailingSlash(currentPath);
    final candidate = _normalizedPathNoTrailingSlash(candidatePath);
    return current == candidate || current.startsWith('$candidate/');
  }

  List<String> _navPathAliases(String path) {
    final normalized = _normalizedPathNoTrailingSlash(path);
    switch (normalized) {
      // [LOCKED] Salesman/customer links may land on Business Partners via redirects.
      case '/dashboard/salesman-customers':
      case '/dashboard/customers':
      case '/dashboard/management/dealers':
      case '/dashboard/procurement/suppliers':
        return const ['/dashboard/business-partners'];
      case '/dashboard/business-partners':
        return const [
          '/dashboard/salesman-customers',
          '/dashboard/customers',
          '/dashboard/management/dealers',
          '/dashboard/procurement/suppliers',
        ];
      default:
        return const [];
    }
  }

  int _navMatchScore({
    required String currentPath,
    required String itemPath,
    required UserRole role,
  }) {
    final normalizedCurrent = _normalizedPathNoTrailingSlash(currentPath);
    final normalizedItem = _normalizedPathNoTrailingSlash(itemPath);
    final candidates = <String>{normalizedItem, ..._navPathAliases(itemPath)};
    var bestScore = -1;

    for (final candidate in candidates) {
      final isMatch = candidate == '/dashboard'
          ? _isHomeRouteForRole(normalizedCurrent, role)
          : _matchesPathPrefix(normalizedCurrent, candidate);
      if (!isMatch) continue;
      if (candidate.length > bestScore) {
        bestScore = candidate.length;
      }
    }
    return bestScore;
  }

  NavItem? _bestMatchingSiblingItem({
    required String currentPath,
    required List<NavItem> siblingItems,
    required UserRole role,
  }) {
    NavItem? bestItem;
    var bestScore = -1;
    for (final sibling in siblingItems) {
      final score = _navMatchScore(
        currentPath: currentPath,
        itemPath: sibling.href,
        role: role,
      );
      if (score > bestScore) {
        bestScore = score;
        bestItem = sibling;
      }
    }
    return bestScore >= 0 ? bestItem : null;
  }

  bool _isReportsRoute(String path) {
    final normalizedPath = _normalizedPath(path);
    return normalizedPath == '/dashboard/reports' ||
        normalizedPath.startsWith('/dashboard/reports/');
  }

  bool _isDealerManagerMobileRoute(String path) {
    final normalizedPath = _normalizedPathNoTrailingSlash(path);
    return normalizedPath == '/dashboard' ||
        normalizedPath == '/dashboard/business-partners' ||
        normalizedPath == '/dashboard/orders/route-management' ||
        normalizedPath == '/dashboard/reports/dealer' ||
        normalizedPath.startsWith('/dashboard/dealer/');
  }

  bool _isReportDetailRoute(String path) {
    return _isReportsRoute(path) &&
        _normalizedPath(path) != '/dashboard/reports';
  }

  bool _isRoleEligibleForRouteOrderFlash(UserRole role) {
    // Dashboard-level order card now handles admin/store/production supervisor.
    if (role == UserRole.owner ||
        role == UserRole.admin ||
        role == UserRole.storeIncharge ||
        role == UserRole.productionSupervisor) {
      return false;
    }
    return role == UserRole.productionManager ||
        role == UserRole.bhattiSupervisor;
  }

  bool _isDashboardHomeForFlash(UserRole role, String path) {
    final normalized = _normalizedPathNoTrailingSlash(path);
    if (normalized == '/dashboard') return true;
    if (role == UserRole.productionManager ||
        role == UserRole.productionSupervisor) {
      return normalized == '/dashboard/production' ||
          normalized == '/dashboard/coming-soon' ||
          normalized.startsWith('/dashboard/production/');
    }
    if (role == UserRole.bhattiSupervisor) {
      return normalized == '/dashboard/bhatti/overview' ||
          normalized.startsWith('/dashboard/bhatti/');
    }
    return false;
  }

  String _reportsLandingPathForUser(AppUser? user) {
    if (user == null) return '/dashboard/reports';
    switch (user.role) {
      case UserRole.dealerManager:
        return '/dashboard/reports/dealer';
      case UserRole.productionSupervisor:
        return '/dashboard/reports/production';
      case UserRole.bhattiSupervisor:
        return '/dashboard/reports/bhatti';
      case UserRole.fuelIncharge:
        return '/dashboard/reports/diesel';
      default:
        return '/dashboard/reports';
    }
  }

  void _recordRouteVisit(String path) {
    if (_routeHistory.isEmpty) {
      _routeHistory.add(path);
      return;
    }

    final lastPath = _routeHistory.last;
    final sameRoute =
        _normalizedPathNoTrailingSlash(lastPath) ==
        _normalizedPathNoTrailingSlash(path);

    if (sameRoute) {
      _routeHistory[_routeHistory.length - 1] = path;
      return;
    }

    _routeHistory.add(path);
    const maxHistoryLength = 80;
    if (_routeHistory.length > maxHistoryLength) {
      _routeHistory.removeRange(0, _routeHistory.length - maxHistoryLength);
    }
  }

  bool _goBackToPreviousRoute(String currentPath) {
    final currentNormalized = _normalizedPathNoTrailingSlash(currentPath);
    while (_routeHistory.isNotEmpty &&
        _normalizedPathNoTrailingSlash(_routeHistory.last) ==
            currentNormalized) {
      _routeHistory.removeLast();
    }

    if (_routeHistory.isEmpty) return false;

    final previousPath = _routeHistory.last;
    context.go(previousPath);
    return true;
  }

  void _handleBackNavigation(String currentPath) {
    if (_goBackToPreviousRoute(currentPath)) {
      return;
    }

    if (_isReportDetailRoute(currentPath)) {
      final user = ref.read(authProviderProvider).state.user;
      final landingPath = _reportsLandingPathForUser(user);
      final normalizedCurrent = _normalizedPathNoTrailingSlash(currentPath);
      final normalizedLanding = _normalizedPathNoTrailingSlash(landingPath);
      if (normalizedCurrent == normalizedLanding) {
        context.go('/dashboard');
      } else {
        context.go(landingPath);
      }
      return;
    }
    context.go('/dashboard');
  }

  Future<void> _handleMobileBackNavigation(String currentPath) async {
    final navigator = Navigator.of(context);
    final didPop = await navigator.maybePop();
    if (didPop) {
      return;
    }
    if (!mounted) return;
    _handleBackNavigation(currentPath);
  }

  Future<void> _openMobilePartnerCreateFlow(PartnerType type) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (routeContext) => BusinessPartnerFormDialog(
          initialType: type,
          fullScreen: true,
          onSaved: () => Navigator.of(routeContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() {
        _businessPartnersRefreshTick++;
      });
    }
  }

  Future<void> _printCurrentReportPage(String currentPath) async {
    if (_isReportExporting) return;
    final pixelRatio = Responsive.devicePixelRatio(context).clamp(1.0, 3.0);
    final pageTitle = _getPageTitle(currentPath);

    try {
      setState(() => _isReportExporting = true);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      final renderObject = _reportPrintBoundaryKey.currentContext
          ?.findRenderObject();
      if (renderObject == null) {
        AppToast.showError(
          context,
          'Unable to capture current page for print.',
        );
        return;
      }

      if (renderObject is! RenderRepaintBoundary) {
        AppToast.showError(context, 'Print capture is not ready on this page.');
        return;
      }

      final boundary = renderObject;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to generate page image.');
      }

      await PdfGenerator.generateAndPrintPageSnapshot(
        byteData.buffer.asUint8List(),
        title: pageTitle,
      );
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Print Failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isReportExporting = false);
      }
    }
  }

  void openNewWindow(String path) {
    _spawnNewWindow(path);
  }

  void _toggleSidebar() {
    setState(() {
      switch (_sidebarMode) {
        case SidebarMode.expanded:
          _sidebarMode = SidebarMode.collapsed;
          break;
        case SidebarMode.collapsed:
          _sidebarMode = SidebarMode.hidden;
          break;
        case SidebarMode.hidden:
          _sidebarMode = SidebarMode.expanded;
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() => _isOnline = result != ConnectivityResult.none);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartListener();
      // Initialize with current route if tabs are empty
      if (_tabs.isEmpty) {
        final path = GoRouterState.of(context).uri.toString();
        setState(() {
          _tabs.add(
            WorkspaceTab(
              path: path,
              title: _getPageTitle(path),
              icon: _getIconForPath(path),
            ),
          );
        });
      }
      _initPackageInfo();
    });
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${info.version} (Build ${info.buildNumber})';
        });
      }
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    _unreadTaskSubscription?.cancel();
    _routeOrderFlashTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndStartListener();
  }

  void _checkAndStartListener() {
    final user = ref.read(authProviderProvider).state.user;
    final authUser = fb_auth.FirebaseAuth.instance.currentUser;
    final appSyncCoordinator = ref.read(appSyncCoordinatorProvider);
    if (user == null || authUser == null) {
      _stopUserSessionListeners();
      return;
    }
    appSyncCoordinator.setCurrentUser(user, triggerBootstrap: true);
    if (user.id != _lastUserId || authUser.uid != _lastAuthUid) {
      _lastUserId = user.id;
      _lastAuthUid = authUser.uid;
      appSyncCoordinator.fetchUserLiveUpdates(user.id);

      // Start listening to unread task count
      _listenToUnreadTasks(user.id);
    }
  }

  void _stopUserSessionListeners() {
    ref.read(appSyncCoordinatorProvider).stopUserListener();
    _unreadTaskSubscription?.cancel();
    _unreadTaskSubscription = null;
    _lastUserId = null;
    _lastAuthUid = null;
    if (mounted) {
      setState(() => _unreadTaskCount = 0);
    } else {
      _unreadTaskCount = 0;
    }
  }

  void _listenToUnreadTasks(String userId) {
    final tasksService = ref.read(tasksServiceProvider);
    _unreadTaskSubscription?.cancel();
    _unreadTaskSubscription = tasksService
        .getUnreadTaskCount(userId)
        .listen(
          (count) {
            if (mounted) {
              setState(() => _unreadTaskCount = count);
            } else {
              _unreadTaskCount = count;
            }
          },
          onError: (e) {
            AppLogger.warning('Unread task stream error: $e', tag: 'Tasks');
            if (mounted) {
              setState(() => _unreadTaskCount = 0);
            } else {
              _unreadTaskCount = 0;
            }
          },
        );
  }

  List<NavItem> get _topNavItems {
    final userRole = ref.watch(authProviderProvider).state.user?.role;
    if (userRole == null) return [];
    return navItemsForRole(userRole, position: NavPosition.top);
  }

  List<NavItem> get _bottomNavItems {
    final userRole = ref.read(authProviderProvider).state.user?.role;
    if (userRole == null) return [];
    return navItemsForRole(userRole, position: NavPosition.bottom);
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    AppLogger.info(
      'MainScaffold: Logout Dialog Confirmed: $confirmed',
      tag: 'Auth',
    );
    if (confirmed == true && mounted) {
      // Show persistent loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              SizedBox(width: 16),
              Text('Logging out safely...'),
            ],
          ),
          duration: Duration(seconds: 10), // Long enough to cover async op
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Stop live listeners first to avoid permission errors during signOut
      _stopUserSessionListeners();

      await ref.read(authProviderProvider).signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    }
  }

  void _spawnNewWindow(String path) {
    // Basic spawn. Passing arguments to open specific route is complex without Deep Linking support in main.dart.
    // For now, just open new instance.
    Process.run(Platform.resolvedExecutable, [], runInShell: true);
  }

  void _handleContextMenu(String path, TapDownDetails details) {
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(details.globalPosition, details.globalPosition),
      Offset.zero & Size(Responsive.width(context), Responsive.height(context)),
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'new_tab',
          child: const Row(
            children: [
              Icon(Icons.tab, size: 18),
              SizedBox(width: 8),
              Text('Open in New Tab'),
            ],
          ),
          onTap: () {
            // Handle after menu closes to avoid conflict?
            // Usually safe.
          },
        ),
        PopupMenuItem(
          value: 'split_view',
          child: const Row(
            children: [
              Icon(Icons.vertical_split, size: 18),
              SizedBox(width: 8),
              Text('Open in Split View'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'new_window',
          child: const Row(
            children: [
              Icon(Icons.open_in_new, size: 18),
              SizedBox(width: 8),
              Text('Open in New Window'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!mounted) {
        return;
      }
      if (value == 'new_tab') {
        setState(() {
          _tabs.add(
            WorkspaceTab(
              path: path,
              title: _getPageTitle(path),
              icon: _getIconForPath(path),
            ),
          );
          _activeTabIndex = _tabs.length - 1;
        });
        context.go(path);
      } else if (value == 'split_view') {
        setState(() {
          _tabs[_activeTabIndex].splitPath = path;
        });
      } else if (value == 'new_window') {
        _spawnNewWindow(path);
      }
    });
  }

  void _handleAddTab() {
    setState(() {
      _tabs.add(
        WorkspaceTab(
          path: '/dashboard',
          title: 'ERP Dashboard',
          icon: Icons.dashboard_outlined,
        ),
      );
      _activeTabIndex = _tabs.length - 1;
    });
    context.go('/dashboard');
  }

  void handleCloseTab(int index) {
    if (_tabs.length <= 1) {
      return; // Don't close last tab
    }
    setState(() {
      _tabs.removeAt(index);
      if (_activeTabIndex >= index && _activeTabIndex > 0) {
        _activeTabIndex--;
      }
    });
    context.go(_tabs[_activeTabIndex].path);
  }

  void closeActiveTab() {
    handleCloseTab(_activeTabIndex);
  }

  void _handleSwitchTab(int index) {
    if (index == _activeTabIndex) {
      return;
    }
    setState(() {
      _activeTabIndex = index;
    });
    context.go(_tabs[index].path);
  }

  Widget _buildTabBar(BuildContext context, bool isDesktop) {
    if (!isDesktop) {
      return const SizedBox.shrink(); // Mobile checks done in AppBar
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final addButtonWidth = 40.0;
          final availableWidth = (constraints.maxWidth - addButtonWidth).clamp(
            0.0,
            double.infinity,
          );

          // Dynamic width calculation
          double tabWidth = 220.0; // Default max width
          if (_tabs.isNotEmpty) {
            tabWidth = availableWidth / _tabs.length;
            // Clamp between min and max
            if (tabWidth > 220.0) tabWidth = 220.0;
            if (tabWidth < 90.0) tabWidth = 90.0;
          }

          return Row(
            children: [
              // Tabs Area
              Flexible(
                child: ClipRect(
                  child: SingleChildScrollView(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable user scroll
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        final isActive = index == _activeTabIndex;

                        return _TabItem(
                          tab: tab,
                          isActive: isActive,
                          width: tabWidth,
                          onTap: () => _handleSwitchTab(index),
                          onClose: () => handleCloseTab(index),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              // Add Button
              SizedBox(
                width: addButtonWidth,
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _handleAddTab,
                  tooltip: 'New Tab',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getIconForPath(String path) {
    final normalizedPath = _normalizedPathNoTrailingSlash(path);

    // [LOCKED] Sidebar icon map: keep route-specific and professional icons.
    switch (normalizedPath) {
      case '/dashboard':
        return Icons.dashboard_outlined;
      case '/dashboard/accounting':
        return Icons.account_balance_wallet_outlined;
      case '/dashboard/profile':
      case '/dashboard/salesman-profile':
        return Icons.person_outline;

      // Inventory
      case '/dashboard/inventory':
        return Icons.inventory_2_outlined;
      case '/dashboard/inventory/stock-overview':
      case '/dashboard/inventory/stock':
      case '/dashboard/salesman-inventory':
        return Icons.warehouse_outlined;
      case '/dashboard/inventory/tanks':
        return Icons.water_drop_outlined;
      case '/dashboard/inventory/adjust':
        return Icons.tune_outlined;
      case '/dashboard/inventory/opening-stock':
        return Icons.inventory_outlined;
      case '/dashboard/inventory/purchase-orders':
        return Icons.assignment_outlined;
      case '/dashboard/inventory/purchase-orders/new':
        return Icons.post_add_outlined;

      // Fuel
      case '/dashboard/fuel':
        return Icons.local_gas_station_outlined;
      case '/dashboard/fuel/stock':
        return Icons.storage_outlined;
      case '/dashboard/fuel/log':
        return Icons.receipt_long_outlined;
      case '/dashboard/fuel/history':
        return Icons.history_outlined;

      // Vehicles
      case '/dashboard/vehicles':
      case '/dashboard/vehicles/all':
        return Icons.directions_car_outlined;
      case '/dashboard/vehicles/maintenance':
        return Icons.build_circle_outlined;
      case '/dashboard/vehicles/diesel':
        return Icons.local_gas_station_outlined;
      case '/dashboard/vehicles/tyres':
        return Icons.trip_origin_outlined;

      // Dispatch
      case '/dashboard/dispatch':
        return Icons.local_shipping_outlined;
      case '/dashboard/dispatch/dashboard':
        return Icons.dashboard_customize_outlined;
      case '/dashboard/dispatch/new-trip':
        return Icons.alt_route_outlined;
      case '/dashboard/orders/route-management':
        return Icons.receipt_long_outlined;

      case '/dashboard/business-partners':
        return Icons.groups_outlined;
      case '/dashboard/hr':
        return Icons.badge_outlined;
      case '/dashboard/management':
        return Icons.admin_panel_settings_outlined;
      case '/dashboard/management/products':
        return Icons.category_outlined;
      case '/dashboard/management/master-data':
        return Icons.table_chart_outlined;
      case '/dashboard/management/formulas':
        return Icons.science_outlined;

      // Location
      case '/dashboard/location':
        return Icons.map_outlined;
      case '/dashboard/gps':
        return Icons.my_location_outlined;
      case '/dashboard/map-view/customers':
        return Icons.place_outlined;
      case '/dashboard/map-view/route-planner':
        return Icons.route_outlined;

      // Reports
      case '/dashboard/reports':
      case '/dashboard/reports/bhatti':
      case '/dashboard/reports/diesel':
        return Icons.bar_chart_outlined;
      case '/dashboard/reports/dealer':
        return Icons.storefront_outlined;
      case '/dashboard/reports/salesman':
      case '/dashboard/salesman-performance':
      case '/dashboard/salesman-target-analysis':
        return Icons.insights_outlined;
      case '/dashboard/reports/production':
        return Icons.analytics_outlined;
      case '/dashboard/reports/financial':
        return Icons.account_balance_outlined;
      case '/dashboard/reports/stock-ledger':
        return Icons.menu_book_outlined;
      case '/dashboard/reports/stock-movement':
        return Icons.swap_horiz_outlined;
      case '/dashboard/reports/sync-analytics':
        return Icons.sync_outlined;
      case '/dashboard/reports/tally-export':
        return Icons.upload_file_outlined;

      // Returns + Tasks + Payments
      case '/dashboard/returns':
      case '/dashboard/returns-management':
        return Icons.assignment_return_outlined;
      case '/dashboard/tasks':
      case '/dashboard/tasks/history':
        return Icons.task_alt_outlined;
      case '/dashboard/payments':
        return Icons.payments_outlined;

      // Production + Bhatti
      case '/dashboard/production':
        return Icons.precision_manufacturing_outlined;
      case '/dashboard/production/stock':
        return Icons.inventory_2_outlined;
      case '/dashboard/production/cutting/entry':
        return Icons.content_cut_outlined;
      case '/dashboard/production/cutting/history':
        return Icons.history_outlined;
      case '/dashboard/bhatti/overview':
        return Icons.local_fire_department_outlined;
      case '/dashboard/bhatti/cooking':
        return Icons.soup_kitchen_outlined;
      case '/dashboard/bhatti/daily-logs':
        return Icons.history_outlined;

      // Sales + Dealer
      case '/dashboard/sales':
      case '/dashboard/sales/new':
      case '/dashboard/salesman-sales/new':
      case '/dashboard/dealer/new-sale':
        return Icons.point_of_sale_outlined;
      case '/dashboard/sales/history':
      case '/dashboard/salesman-sales/history':
      case '/dashboard/dealer/history':
        return Icons.receipt_long_outlined;
      case '/dashboard/salesman-customers':
        return Icons.people_outline;
      case '/dashboard/dealer/dashboard':
        return Icons.store_outlined;

      // Driver
      case '/dashboard/driver/duty':
        return Icons.assignment_ind_outlined;
      case '/dashboard/driver/trips':
        return Icons.route_outlined;
      case '/dashboard/driver/vehicle':
        return Icons.directions_car_outlined;
      case '/dashboard/driver/diesel':
        return Icons.local_gas_station_outlined;
      case '/dashboard/driver/mileage':
        return Icons.speed_outlined;
    }

    if (normalizedPath.contains('purchase-orders')) {
      return Icons.assignment_outlined;
    }
    if (normalizedPath.contains('inventory')) return Icons.inventory_2_outlined;
    if (normalizedPath.contains('fuel')) {
      return Icons.local_gas_station_outlined;
    }
    if (normalizedPath.contains('vehicle')) {
      return Icons.directions_car_outlined;
    }
    if (normalizedPath.contains('order')) return Icons.receipt_long_outlined;
    if (normalizedPath.contains('report')) return Icons.bar_chart_outlined;
    if (normalizedPath.contains('management')) {
      return Icons.admin_panel_settings_outlined;
    }
    if (normalizedPath.contains('return')) {
      return Icons.assignment_return_outlined;
    }
    if (normalizedPath.contains('task')) return Icons.task_alt_outlined;
    if (normalizedPath.contains('setting')) return Icons.settings_outlined;
    if (normalizedPath.contains('sales')) return Icons.point_of_sale_outlined;
    return Icons.dashboard_outlined;
  }

  String _getEmojiForPath(String path) {
    final normalizedPath = _normalizedPathNoTrailingSlash(path);

    // [LOCKED] Sidebar emoji set approved by user.
    switch (normalizedPath) {
      case '/dashboard':
        return '📊';
      case '/dashboard/accounting':
        return '💼';
      case '/dashboard/profile':
      case '/dashboard/salesman-profile':
        return '👤';

      case '/dashboard/inventory':
        return '📦';
      case '/dashboard/inventory/stock-overview':
      case '/dashboard/inventory/stock':
      case '/dashboard/salesman-inventory':
        return '🏬';
      case '/dashboard/inventory/tanks':
        return '🛢️';
      case '/dashboard/inventory/adjust':
        return '⚖️';
      case '/dashboard/inventory/opening-stock':
        return '🧾';
      case '/dashboard/inventory/purchase-orders':
        return '📑';
      case '/dashboard/inventory/purchase-orders/new':
        return '📝';

      case '/dashboard/fuel':
        return '⛽';
      case '/dashboard/fuel/stock':
        return '🛢️';
      case '/dashboard/fuel/log':
        return '📋';
      case '/dashboard/fuel/history':
        return '🕒';

      case '/dashboard/vehicles':
      case '/dashboard/vehicles/all':
        return '🚗';
      case '/dashboard/vehicles/maintenance':
        return '🔧';
      case '/dashboard/vehicles/diesel':
        return '⛽';
      case '/dashboard/vehicles/tyres':
        return '🛞';

      case '/dashboard/dispatch':
        return '\u{1F69A}';
      case '/dashboard/dispatch/dashboard':
        return '\u{1F4CD}';
      case '/dashboard/dispatch/new-trip':
        return '\u{1F6E3}';
      case '/dashboard/orders/route-management':
        return '';

      case '/dashboard/business-partners':
        return '🤝';
      case '/dashboard/hr':
        return '👥';
      case '/dashboard/management':
        return '🧠';
      case '/dashboard/management/products':
        return '🏷️';
      case '/dashboard/management/master-data':
        return '🗂️';
      case '/dashboard/management/formulas':
        return '🧪';

      case '/dashboard/location':
        return '🗺️';
      case '/dashboard/gps':
        return '📡';
      case '/dashboard/map-view/customers':
        return '📌';
      case '/dashboard/map-view/route-planner':
        return '🧭';

      case '/dashboard/reports':
      case '/dashboard/reports/bhatti':
      case '/dashboard/reports/diesel':
        return '📈';
      case '/dashboard/reports/dealer':
        return '🏪';
      case '/dashboard/reports/salesman':
      case '/dashboard/salesman-performance':
      case '/dashboard/salesman-target-analysis':
        return '📉';
      case '/dashboard/reports/production':
        return '🏭';
      case '/dashboard/reports/financial':
        return '💰';
      case '/dashboard/reports/stock-ledger':
        return '📚';
      case '/dashboard/reports/stock-movement':
        return '🔄';
      case '/dashboard/reports/sync-analytics':
        return '🔁';
      case '/dashboard/reports/tally-export':
        return '📤';

      case '/dashboard/returns':
      case '/dashboard/returns-management':
        return '↩️';
      case '/dashboard/tasks':
      case '/dashboard/tasks/history':
        return '✅';
      case '/dashboard/payments':
        return '💳';

      case '/dashboard/production':
      case '/dashboard/production/stock':
        return '🏭';
      case '/dashboard/production/cutting/entry':
        return '✂️';
      case '/dashboard/production/cutting/history':
        return '🕓';
      case '/dashboard/bhatti/overview':
        return '🔥';
      case '/dashboard/bhatti/cooking':
        return '🍲';
      case '/dashboard/bhatti/daily-logs':
        return '📒';

      case '/dashboard/sales':
      case '/dashboard/sales/new':
      case '/dashboard/salesman-sales/new':
      case '/dashboard/dealer/new-sale':
        return '🛒';
      case '/dashboard/sales/history':
      case '/dashboard/salesman-sales/history':
      case '/dashboard/dealer/history':
        return '🧾';
      case '/dashboard/salesman-customers':
        return '👥';
      case '/dashboard/dealer/dashboard':
        return '🏬';

      case '/dashboard/driver/duty':
        return '🧑‍✈️';
      case '/dashboard/driver/trips':
        return '🛣️';
      case '/dashboard/driver/vehicle':
        return '🚘';
      case '/dashboard/driver/diesel':
        return '⛽';
      case '/dashboard/driver/mileage':
        return '📏';
    }

    if (normalizedPath.contains('purchase-orders')) return '📑';
    if (normalizedPath.contains('inventory')) return '📦';
    if (normalizedPath.contains('fuel')) return '⛽';
    if (normalizedPath.contains('vehicle')) return '🚗';
    if (normalizedPath.contains('order')) return '\u{1F4E6}';
    if (normalizedPath.contains('report')) return '📈';
    if (normalizedPath.contains('management')) return '🧠';
    if (normalizedPath.contains('return')) return '↩️';
    if (normalizedPath.contains('task')) return '✅';
    if (normalizedPath.contains('sales')) return '🛒';
    return '📌';
  }

  Widget _buildSidebarEmojiIcon(String path, {required double size}) {
    final emoji = _getEmojiForPath(path);
    if (emoji.trim().isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(_getIconForPath(path), size: size * 0.9),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: size, height: 1.0),
        ),
      ),
    );
  }

  String? _emojiOrNullForPath(String path) {
    final emoji = _getEmojiForPath(path).trim();
    return emoji.isEmpty ? null : emoji;
  }

  String _getPageTitle(String path) {
    final normalizedPath = _normalizedPathNoTrailingSlash(path);
    switch (normalizedPath) {
      case '/dashboard/dealer/dashboard':
        return 'Dashboard';
      case '/dashboard/dealer/new-sale':
        return 'New Sale';
      case '/dashboard/dealer/history':
        return 'Sales History';
      case '/dashboard/reports/dealer':
        return 'Dealer Performance';
      case '/dashboard/business-partners':
        return 'Dealers';
      case '/dashboard/orders/route-management':
        return 'Route Orders';
    }
    if (normalizedPath == '/dashboard') return 'ERP Dashboard';
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length > 1) {
      final last = segments.last;
      return last
          .split(RegExp(r'[-_]'))
          .map(
            (word) => word.isEmpty
                ? ''
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' ');
    }
    return 'DattSoap ERP';
  }

  Widget _getWidgetForPath(String path) {
    final normalizedPath = _normalizedPathNoTrailingSlash(path);
    final uri = Uri.tryParse(path);
    final isLowStockOnly = uri?.queryParameters['filter'] == 'low-stock';

    switch (normalizedPath) {
      case '/dashboard':
        final authUser = ref.read(authProviderProvider).state.user;
        if (authUser?.role == UserRole.salesman) {
          return const SalesmanDashboardScreen();
        }
        if (authUser?.role == UserRole.dealerManager) {
          return const DealerDashboardScreen();
        }
        return const DashboardScreen();
      case '/dashboard/profile':
      case '/dashboard/salesman-profile':
        return const UserProfileScreen();
      case '/dashboard/inventory':
      case '/dashboard/inventory/stock-overview':
        return const InventoryOverviewScreen();
      case '/dashboard/inventory/tanks':
        return const TanksListScreen();
      case '/dashboard/inventory/adjust':
        return const StockAdjustmentScreen();
      case '/dashboard/inventory/opening-stock':
        return const OpeningStockSetupScreen();
      case '/dashboard/inventory/purchase-orders':
        return const PurchaseOrdersListScreen();
      case '/dashboard/fuel':
      case '/dashboard/fuel/log':
        return const FuelLogScreen();
      case '/dashboard/fuel/stock':
        return const FuelStockScreen();
      case '/dashboard/fuel/history':
        return const FuelHistoryScreen();
      case '/dashboard/vehicles':
      case '/dashboard/vehicles/all':
        return const VehicleManagementScreen(initialTabIndex: 0);
      case '/dashboard/vehicles/maintenance':
        return const VehicleManagementScreen(initialTabIndex: 1);
      case '/dashboard/vehicles/diesel':
        return const VehicleManagementScreen(initialTabIndex: 2);
      case '/dashboard/vehicles/tyres':
        return const VehicleManagementScreen(initialTabIndex: 3);
      case '/dashboard/dispatch':
        return const DispatchScreen();
      case '/dashboard/dispatch/dashboard':
        return const DealerDispatchScreen();
      case '/dashboard/dispatch/new-trip':
        return const NewTripScreen();
      case '/dashboard/orders/route-management':
        return const RouteOrderManagementScreen();

      case '/dashboard/business-partners':
        return BusinessPartnersScreen(
          key: ValueKey(
            'partners_${_businessPartnersRefreshTick}_$normalizedPath',
          ),
        );
      case '/dashboard/management':
        return const ManagementModuleScreen();
      case '/dashboard/management/products':
        return const ProductsManagementScreen(isMasterDataMode: true);
      case '/dashboard/management/formulas':
        return const FormulasManagementScreen();
      case '/dashboard/management/master-data':
        return const MasterDataScreen();
      case '/dashboard/reports':
        return const ReportingHubScreen();
      case '/dashboard/reports/dealer':
        return const DealerReportScreen();
      case '/dashboard/returns':
      case '/dashboard/returns-management':
        final authUser = ref.read(authProviderProvider).state.user;
        if (authUser?.role == UserRole.salesman) {
          return const SalesmanReturnsScreen();
        }
        return const ReturnsManagementScreen();
      case '/dashboard/tasks':
        return const TasksScreen();
      case '/dashboard/tasks/history':
        return const TaskHistoryScreen();
      case '/dashboard/production':
        return const ProductionDashboardConsolidatedScreen();
      case '/dashboard/production/stock':
        return ProductionStockScreen(showLowStockOnly: isLowStockOnly);
      case '/dashboard/production/cutting/entry':
        return const CuttingBatchEntryScreen();
      case '/dashboard/production/cutting/history':
        return const CuttingHistoryScreen();
      case '/dashboard/bhatti/overview':
        return const BhattiDashboardScreen();
      case '/dashboard/bhatti/cooking':
        return const BhattiCookingScreen();
      case '/dashboard/bhatti/daily-logs':
        return const BhattiSupervisorScreen();
      case '/dashboard/sales':
      case '/dashboard/sales/history':
      case '/dashboard/salesman-sales/history':
        return const SalesHistoryScreen();
      case '/dashboard/sales/new':
      case '/dashboard/salesman-sales/new':
        return const NewSaleScreen();
      case '/dashboard/salesman-inventory':
        return const MyStockScreen();
      case '/dashboard/salesman-target-analysis':
        return const TargetAchievementReportScreen();
      case '/dashboard/salesman-performance':
        return const MyPerformanceScreen();
      case '/dashboard/location':
      case '/dashboard/gps':
        return const GPSTrackingScreen();
      case '/dashboard/map-view/customers':
        return const CustomersMapScreen();
      case '/dashboard/map-view/route-planner':
        return const RoutePlannerScreen();
      case '/dashboard/driver/duty':
        return const DutyScreen();
      case '/dashboard/driver/trips':
        return const DriverTripsScreen();
      case '/dashboard/driver/vehicle':
        return const VehicleInfoScreen();
      case '/dashboard/driver/diesel':
        return const DriverDieselLogScreen();
      case '/dashboard/driver/mileage':
        return const VehicleMileageScreen();
      case '/dashboard/dealer/dashboard':
        return const DealerDashboardScreen();
      case '/dashboard/dealer/new-sale':
        return const NewDealerSaleScreen();
      case '/dashboard/dealer/history':
        return const SalesHistoryScreen();
      case '/dashboard/payments':
        return const PaymentsScreen();
    }

    if (normalizedPath.startsWith('/dashboard/reports/')) {
      return const ReportingHubScreen();
    }
    if (normalizedPath.startsWith('/dashboard/inventory/purchase-orders/')) {
      return const PurchaseOrdersListScreen();
    }
    if (normalizedPath.startsWith('/dashboard/dispatch/trips/')) {
      return const NewTripScreen();
    }
    if (normalizedPath.startsWith('/dashboard/settings')) {
      return const Center(child: Text('Settings preview opens in full tab.'));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('Preview not available for $normalizedPath'),
        ],
      ),
    );
  }

  Widget _buildBodyWithSplitView(bool isDesktop) {
    if (!isDesktop || _tabs.isEmpty || _activeTabIndex >= _tabs.length) {
      return widget.child;
    }

    final currentTab = _tabs[_activeTabIndex];
    if (currentTab.splitPath == null) {
      return widget.child;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: widget.child), // Left Pane (Active Router)
        Container(
          width: 1,
          color: Theme.of(context).dividerColor, // Divider
        ),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                _getPageTitle(currentTab.splitPath!),
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _tabs[_activeTabIndex].splitPath = null;
                    });
                  },
                ),
              ],
            ),
            body: _getWidgetForPath(currentTab.splitPath!),
          ),
        ),
      ],
    );
  }

  TextStyle _pageHeaderTitleStyle(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle =
        theme.appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        );

    if (useMobileHeaderTypographyForWidth(Responsive.width(context))) {
      return buildProfessionalMobileHeaderTitleStyle(baseStyle);
    }

    return baseStyle.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3);
  }

  ButtonStyle _topBarIconButtonStyle(BuildContext context, {Color? baseColor}) {
    final defaultColor = baseColor ?? Theme.of(context).colorScheme.onSurface;
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return AppColors.success;
        }
        return defaultColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.success.withValues(alpha: 0.18);
        }
        if (states.contains(WidgetState.pressed)) {
          return AppColors.success.withValues(alpha: 0.25);
        }
        return Colors.transparent;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.success.withValues(alpha: 0.08);
        }
        return Colors.transparent;
      }),
      shape: const WidgetStatePropertyAll(CircleBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderProvider).state;
    final user = authState.user;

    if (user == null && _lastUserId != null) {
      // Defensive cleanup: sign-out can be triggered from multiple entry points.
      ref.read(appSyncCoordinatorProvider).stopUserListener();
      _unreadTaskSubscription?.cancel();
      _unreadTaskSubscription = null;
      _lastUserId = null;
      _unreadTaskCount = 0;
      _routeHistory.clear();
    }

    // Keep rendering when a valid session exists; auth refresh/sync continues in background.
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // [UI LOCK] Do not change this breakpoint value (> 600).
    // It strictly governs whether the top tabs (new/split tab) and left sidebar are shown
    // vs the bottom mobile navigation bar. Changing this to > 1100 breaks the tablet/small
    // desktop UI by incorrectly dropping into the mobile layout.
    final isDesktop = Responsive.width(context) > 600;
    final currentPath = GoRouterState.of(context).uri.toString();
    final normalizedCurrentPath = _normalizedPath(currentPath);
    _recordRouteVisit(currentPath);

    // SYNC ROUTER STATE TO TABS
    if (isDesktop && _tabs.isNotEmpty && _activeTabIndex < _tabs.length) {
      // Only update if it's a real navigation change (not just query params if we want strictly path)
      // For now, sync exactly.
      if (_tabs[_activeTabIndex].path != currentPath) {
        // Update the tab's path validation
        // Avoid set state during build?
        // Post-frame callback or simple mutation since it's just local state sync?
        // Optimistic update:
        _tabs[_activeTabIndex].path = currentPath;
        _tabs[_activeTabIndex].title = _getPageTitle(currentPath);
        _tabs[_activeTabIndex].icon = _getIconForPath(currentPath);
      }
    }

    // [LOCKED] Unified mobile home-route behavior across all roles.
    final isDashboard = _isHomeRouteForRole(normalizedCurrentPath, user.role);
    final isReportRoute = _isReportsRoute(currentPath);
    final isDealerManagerMobileRoute =
        !isDesktop &&
        user.role == UserRole.dealerManager &&
        _isDealerManagerMobileRoute(currentPath);
    final isDealerManagerMobileHomeRoute =
        !isDesktop && user.role == UserRole.dealerManager && isDashboard;
    final isBusinessPartnersRoute =
        _normalizedPathNoTrailingSlash(currentPath) ==
        '/dashboard/business-partners';

    // [LOCKED] Mobile top navbar should be visible only on dashboard/home.
    final showMainAppBar = isDesktop || isDashboard;

    // [LOCKED] Mobile bottom navbar should be visible only on dashboard/home.
    final showBottomNavBar = !isDesktop && isDashboard;

    return Actions(
      actions: {
        NewTabIntent: CallbackAction<NewTabIntent>(
          onInvoke: (_) {
            _handleAddTab();
            return null;
          },
        ),
        CloseTabIntent: CallbackAction<CloseTabIntent>(
          onInvoke: (_) {
            closeActiveTab();
            return null;
          },
        ),
        NewWindowIntent: CallbackAction<NewWindowIntent>(
          onInvoke: (_) {
            _spawnNewWindow(currentPath);
            return null;
          },
        ),
        // SplitViewIntent requires a target, defaulting to current tab?
        // Maybe better left to specific context or just omitted if no obvious target.
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: showMainAppBar
            ? AppBar(
                toolbarHeight: isDesktop ? 48 : 52,
                titleSpacing: 0,
                title: isDesktop
                    ? _buildTabBar(context, isDesktop)
                    : isDealerManagerMobileRoute && !isDashboard
                    ? SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _getPageTitle(currentPath),
                              style: _pageHeaderTitleStyle(context),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, titleConstraints) {
                          final showInlineBackButton =
                              !isDashboard && titleConstraints.maxWidth >= 84;

                          return Row(
                            children: [
                              if (showInlineBackButton)
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  onPressed: () =>
                                      _handleBackNavigation(currentPath),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: _isReportDetailRoute(currentPath)
                                      ? 'Back to Reports'
                                      : 'Back to Dashboard',
                                ),
                              if (showInlineBackButton)
                                const SizedBox(width: 4),
                              Expanded(
                                child: isDealerManagerMobileHomeRoute
                                    ? const SizedBox.shrink()
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _getPageTitle(currentPath),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                centerTitle: false,
                // flexibleSpace: Removed to allow Theme to control background
                // backgroundColor: Colors.transparent, // Removed
                // foregroundColor: Colors.white, // Removed
                leading: isDesktop
                    ? IconButton(
                        icon: Icon(
                          _sidebarMode == SidebarMode.collapsed ||
                                  _sidebarMode == SidebarMode.hidden
                              ? Icons.menu
                              : Icons.menu_open,
                        ),
                        style: _topBarIconButtonStyle(context),
                        onPressed: _toggleSidebar,
                        tooltip: _sidebarMode == SidebarMode.expanded
                            ? 'Collapse Sidebar'
                            : _sidebarMode == SidebarMode.collapsed
                            ? 'Hide Sidebar'
                            : 'Expand Sidebar',
                      )
                    : isDealerManagerMobileRoute && !isDashboard
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        style: _topBarIconButtonStyle(context),
                        tooltip: 'Back',
                        onPressed: () async {
                          if (isDashboard) {
                            context.go('/dashboard');
                            return;
                          }
                          await _handleMobileBackNavigation(currentPath);
                        },
                      )
                    : Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          style: _topBarIconButtonStyle(context),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                actions: isDealerManagerMobileRoute && !isDashboard
                    ? <Widget>[
                        if (isBusinessPartnersRoute)
                          IconButton(
                            tooltip: 'Add Dealer',
                            style: _topBarIconButtonStyle(
                              context,
                              baseColor: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => _openMobilePartnerCreateFlow(
                              PartnerType.dealer,
                            ),
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                          ),
                      ]
                    : [
                        if (isDesktop && !isDashboard)
                          IconButton(
                            onPressed: () => _handleBackNavigation(currentPath),
                            tooltip: _isReportDetailRoute(currentPath)
                                ? 'Back to Reports'
                                : 'Back to Dashboard',
                            icon: const Icon(Icons.arrow_back),
                            style: _topBarIconButtonStyle(context),
                          ),
                        if (isReportRoute && isDesktop)
                          _isReportExporting
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 10,
                                  ),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  tooltip: 'Print Current Page',
                                  icon: const Icon(Icons.print_outlined),
                                  style: _topBarIconButtonStyle(context),
                                  onPressed: () =>
                                      _printCurrentReportPage(currentPath),
                                ),
                        if (isDesktop) _buildConnectionStatusChip(),
                        const AutoSyncStatusIndicator(),
                        if (isDesktop)
                          Builder(
                            builder: (context) => IconButton(
                              onPressed: () =>
                                  Scaffold.of(context).openEndDrawer(),
                              tooltip: 'AI Agent (Offline)',
                              style: _topBarIconButtonStyle(context),
                              icon: const Icon(Icons.auto_awesome_rounded),
                            ),
                          ),
                        if (isDesktop)
                          _buildThemeToggleButton(isDesktop: isDesktop),
                        _buildNotificationBadge(),
                        _buildUserMenu(user, isDesktop: isDesktop),
                      ],
              )
            : null,
        drawer: isDesktop ? null : _buildDrawer(user),
        endDrawer: const AIAssistantPanel(),
        body: SafeArea(
          top: !showMainAppBar,
          bottom: true,
          left: false,
          right: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop && _sidebarMode != SidebarMode.hidden)
                    _buildSidebar(user, height: constraints.maxHeight),
                  Expanded(
                    child: _buildBodyWithRouteOrderFlash(
                      child: isReportRoute
                          ? RepaintBoundary(
                              key: _reportPrintBoundaryKey,
                              child: _buildBodyWithSplitView(isDesktop),
                            )
                          : _buildBodyWithSplitView(isDesktop),
                      user: user,
                      currentPath: currentPath,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: null,
        bottomNavigationBar: showBottomNavBar ? _buildBottomNavBar() : null,
      ),
    );
  }

  Widget _buildThemeToggleButton({required bool isDesktop}) {
    return rp.Consumer(
      builder: (context, ref, child) {
        final themeState = ref.watch(themeSettingsProvider);
        final mode = themeState.settings.themeMode;
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final resolved = mode == ThemeMode.system
            ? platformBrightness
            : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
        final isDark = resolved == Brightness.dark;

        return IconButton(
          visualDensity: isDesktop
              ? VisualDensity.standard
              : VisualDensity.compact,
          style: _topBarIconButtonStyle(context),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: isDesktop ? 24 : 20,
          ),
          onPressed: () => ref
              .read(themeSettingsProvider.notifier)
              .toggleQuickMode(platformBrightness),
          tooltip: 'Toggle Theme',
        );
      },
    );
  }

  Widget _buildConnectionStatusChip() {
    final isDesktop = Responsive.width(context) > 600;

    // On mobile, only show text if Offline. If Online, show only icon to save space.
    final showText = isDesktop || !_isOnline;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: EdgeInsets.symmetric(horizontal: showText ? 8 : 6, vertical: 2),
      decoration: BoxDecoration(
        color: (_isOnline ? AppColors.success : AppColors.warning).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_isOnline ? AppColors.success : AppColors.warning).withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            size: 14,
            color: _isOnline ? AppColors.success : AppColors.warning,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              _isOnline ? 'LIVE' : 'OFFLINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _isOnline ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationBadge() {
    final alertService = ref.watch(alertServiceProvider);
    final currentUser = ref.watch(authProviderProvider).currentUser;

    return FutureBuilder<int>(
      future: alertService.getUnreadCount(user: currentUser),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              style: _topBarIconButtonStyle(context),
              onPressed: () => context.pushNamed('system_alerts'),
              tooltip: 'System Alerts',
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRouteOrdersMenuBadge({required bool isActive}) {
    final alertService = ref.watch(alertServiceProvider);
    final currentUser = ref.watch(authProviderProvider).currentUser;

    return FutureBuilder<int>(
      future: alertService.getUnreadRouteOrderCount(user: currentUser),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count <= 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count > 99 ? '99+' : '$count',
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onError,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyWithRouteOrderFlash({
    required Widget child,
    required AppUser user,
    required String currentPath,
  }) {
    if (!_isRoleEligibleForRouteOrderFlash(user.role) ||
        !_isDashboardHomeForFlash(user.role, currentPath)) {
      _stopRouteOrderFlashRotation(clearSequence: true);
      return child;
    }

    final alertService = ref.watch(alertServiceProvider);

    return FutureBuilder<List<SystemAlert>>(
      future: alertService.getUnreadRouteOrderAlerts(user: user),
      builder: (context, snapshot) {
        final routeOrderAlerts = snapshot.data ?? const <SystemAlert>[];
        if (routeOrderAlerts.isEmpty) {
          _stopRouteOrderFlashRotation(clearSequence: true);
          return child;
        }

        final alert = _selectRouteOrderFlashAlert(routeOrderAlerts);
        final isRotating = routeOrderAlerts.length > 1;
        final currentSequencePosition =
            (_routeOrderFlashSequenceIndex %
                (isRotating ? _routeOrderFlashSequence.length : 1)) +
            1;

        final metadata = alert.metadata ?? const <String, dynamic>{};
        final orderNo = (metadata['orderNo'] ?? '').toString().trim();
        final routeName = (metadata['routeName'] ?? '').toString().trim();
        final salesmanName = (metadata['salesmanName'] ?? '').toString().trim();
        final amountRaw = metadata['totalAmount'];
        final amount = amountRaw is num
            ? amountRaw.toDouble()
            : double.tryParse('$amountRaw') ?? 0;

        final title = orderNo.isNotEmpty
            ? 'New Route Order #$orderNo'
            : 'New Route Order';
        final detailParts = <String>[
          if (routeName.isNotEmpty) routeName,
          if (salesmanName.isNotEmpty) salesmanName,
          if (amount > 0) 'Rs ${amount.toStringAsFixed(0)}',
        ];
        final detailText = detailParts.isEmpty
            ? alert.message
            : detailParts.join('  |  ');
        final headline =
            '$title${detailText.isNotEmpty ? '  -  $detailText' : ''}';

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await alertService.markAsRead(alert.id, user: user);
                  if (!mounted) return;
                  _navigateFromMenu('/dashboard/orders/route-management');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.26),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'BREAKING',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isRotating) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$currentSequencePosition/${routeOrderAlerts.length}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }

  List<String> _buildRouteOrderFlashSequence(Iterable<String> alertIds) {
    final sequence = alertIds.toSet().toList();
    sequence.shuffle(_routeOrderFlashRandom);
    return sequence;
  }

  bool _hasSameRouteOrderFlashMembership(Set<String> activeIds) {
    if (_routeOrderFlashSequence.length != activeIds.length) return false;
    final existing = _routeOrderFlashSequence.toSet();
    return existing.length == activeIds.length &&
        existing.containsAll(activeIds);
  }

  void _startRouteOrderFlashRotationIfNeeded() {
    // LOCKED: when multiple route-order alerts are unread, rotate one-by-one
    // so every pending order gets visibility in the breaking strip.
    if (_routeOrderFlashTimer != null) return;
    if (_routeOrderFlashSequence.length <= 1) return;

    _routeOrderFlashTimer = Timer.periodic(_routeOrderFlashRotateInterval, (_) {
      if (!mounted || _routeOrderFlashSequence.length <= 1) return;
      setState(() {
        _routeOrderFlashSequenceIndex =
            (_routeOrderFlashSequenceIndex + 1) %
            _routeOrderFlashSequence.length;
        if (_routeOrderFlashSequenceIndex == 0) {
          _routeOrderFlashSequence = _buildRouteOrderFlashSequence(
            _routeOrderFlashSequence,
          );
        }
      });
    });
  }

  void _stopRouteOrderFlashRotation({bool clearSequence = false}) {
    _routeOrderFlashTimer?.cancel();
    _routeOrderFlashTimer = null;
    if (clearSequence) {
      _routeOrderFlashSequence = const [];
      _routeOrderFlashSequenceIndex = 0;
    }
  }

  SystemAlert _selectRouteOrderFlashAlert(List<SystemAlert> alerts) {
    if (alerts.length <= 1) {
      _stopRouteOrderFlashRotation(clearSequence: true);
      return alerts.first;
    }

    final activeIds = alerts.map((alert) => alert.id).toSet();
    if (!_hasSameRouteOrderFlashMembership(activeIds)) {
      _routeOrderFlashSequence = _buildRouteOrderFlashSequence(activeIds);
      _routeOrderFlashSequenceIndex = 0;
    }

    _startRouteOrderFlashRotationIfNeeded();

    if (_routeOrderFlashSequence.isEmpty) {
      return alerts.first;
    }

    final activeById = {for (final alert in alerts) alert.id: alert};
    final safeIndex =
        _routeOrderFlashSequenceIndex % _routeOrderFlashSequence.length;
    final activeId = _routeOrderFlashSequence[safeIndex];
    return activeById[activeId] ?? alerts.first;
  }

  Widget _buildUserMenu(AppUser user, {required bool isDesktop}) {
    return Builder(
      builder: (menuContext) => Padding(
        padding: EdgeInsets.only(
          right: isDesktop ? 16 : 8,
          left: isDesktop ? 8 : 4,
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (val) {
            if (val == 'logout') {
              _handleLogout();
              return;
            }
            if (val == 'profile') {
              menuContext.go('/dashboard/profile');
              return;
            }
            if (val == 'settings') {
              _navigateFromMenu('/dashboard/settings');
              return;
            }
            if (val == 'assistant') {
              Scaffold.of(menuContext).openEndDrawer();
              return;
            }
            if (val == 'theme') {
              final platformBrightness = MediaQuery.platformBrightnessOf(
                menuContext,
              );
              ref
                  .read(themeSettingsProvider.notifier)
                  .toggleQuickMode(platformBrightness);
            }
          },
          child: MouseRegion(
            onEnter: (_) {
              if (mounted && !_isProfileHovered) {
                setState(() => _isProfileHovered = true);
              }
            },
            onExit: (_) {
              if (mounted && _isProfileHovered) {
                setState(() => _isProfileHovered = false);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.all(isDesktop ? 2 : 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isProfileHovered
                    ? AppColors.success.withValues(alpha: 0.14)
                    : Theme.of(menuContext).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                border: Border.all(
                  color: _isProfileHovered
                      ? AppColors.success.withValues(alpha: 0.75)
                      : Theme.of(
                          menuContext,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isProfileHovered
                                ? AppColors.success
                                : Theme.of(menuContext).colorScheme.primary)
                            .withValues(alpha: _isProfileHovered ? 0.42 : 0.22),
                    blurRadius: _isProfileHovered ? 12 : 7,
                    spreadRadius: _isProfileHovered ? 1 : 0,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isDesktop ? 16 : 14,
                backgroundColor: Theme.of(menuContext).colorScheme.surface,
                child: Text(
                  user.name
                      .substring(0, user.name.length > 2 ? 2 : user.name.length)
                      .toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(menuContext).colorScheme.onSurface,
                    fontSize: isDesktop ? 10 : 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          itemBuilder: (popupContext) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        popupContext,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 18),
                  SizedBox(width: 12),
                  Text('Profile'),
                ],
              ),
            ),
            if (user.role == UserRole.admin)
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            if (!isDesktop)
              const PopupMenuItem(
                value: 'assistant',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18),
                    SizedBox(width: 12),
                    Text('AI Assistant'),
                  ],
                ),
              ),
            if (!isDesktop)
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Toggle Theme'),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: 18,
                    color: Theme.of(popupContext).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Log out',
                    style: TextStyle(
                      color: Theme.of(popupContext).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(AppUser user, {double? height}) {
    final double sidebarWidth = _sidebarMode == SidebarMode.collapsed
        ? 72
        : 250;
    final bottomSidebarItems = _bottomNavItems.where((item) {
      if (user.role != UserRole.fuelIncharge) return true;
      return item.href != '/dashboard' &&
          item.href != '/dashboard/fuel/log' &&
          item.href != '/dashboard/fuel/history';
    }).toList();

    // Safety check for infinite height
    final double safeHeight = (height == null || height.isInfinite)
        ? Responsive.height(context)
        : height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      height: safeHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ..._topNavItems.map(
                  (item) => _buildNavItem(item, siblingItems: _topNavItems),
                ),
                if (_sidebarMode != SidebarMode.collapsed &&
                    bottomSidebarItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      "SYSTEM",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
                if (_sidebarMode == SidebarMode.collapsed &&
                    bottomSidebarItems.isNotEmpty)
                  const SizedBox(height: 16),
                ...bottomSidebarItems.map(
                  (item) =>
                      _buildNavItem(item, siblingItems: bottomSidebarItems),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* Widget _buildNavItem(NavItem item, {bool isSubItem = false}) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final hasSubmenu = item.submenu != null && item.submenu!.isNotEmpty;
    // Check if any child is active to highlight parent
    final isSelected =
        currentPath.startsWith(item.href) ||
        (hasSubmenu &&
            item.submenu!.any((sub) => currentPath.startsWith(sub.href)));

    // COLLAPSED MODE
    if (_sidebarMode == SidebarMode.collapsed && !isSubItem) {
      if (hasSubmenu) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: PopupMenuButton<String>(
            tooltip: item.label,
            offset: const Offset(60, 0),
            icon: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForNavItem(item),
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onSelected: (path) => context.go(path),
            itemBuilder: (context) => item.submenu!.map((sub) {
              return PopupMenuItem(value: sub.href, child: Text(sub.label));
            }).toList(),
          ),
        );
      } else {
        return Tooltip(
          message: item.label,
          waitDuration: const Duration(milliseconds: 500),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go(item.href),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _getIconForNavItem(item),
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
        );
    }
  } */

  Widget _buildNavItem(
    NavItem item, {
    bool isSubItem = false,
    List<NavItem>? siblingItems,
  }) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final isDesktop = Responsive.width(context) > 600;
    final userRole = ref.read(authProviderProvider).state.user?.role;

    // Leaf active state: prefer the most specific matching sibling route.
    bool isExactMatch = false;
    if (item.submenu == null && userRole != null) {
      final ownScore = _navMatchScore(
        currentPath: currentPath,
        itemPath: item.href,
        role: userRole,
      );
      if (ownScore >= 0 && siblingItems != null && siblingItems.isNotEmpty) {
        final best = _bestMatchingSiblingItem(
          currentPath: currentPath,
          siblingItems: siblingItems,
          role: userRole,
        );
        isExactMatch = best?.href == item.href;
      } else {
        isExactMatch = ownScore >= 0;
      }
    }

    // Check if any child is active
    final hasSubmenu = item.submenu != null && item.submenu!.isNotEmpty;
    final bool isChildActive =
        hasSubmenu &&
        userRole != null &&
        item.submenu!.any(
          (sub) =>
              _navMatchScore(
                currentPath: currentPath,
                itemPath: sub.href,
                role: userRole,
              ) >=
              0,
        );

    // A parent is "active" if it's an exact match OR a child is active (but behavior specific to expansion tile)
    final bool isActive = isExactMatch || (isSubItem && isExactMatch);

    // COLLAPSED MODE (Only on Desktop)
    if (_sidebarMode == SidebarMode.collapsed && isDesktop) {
      if (!isSubItem) {
        if (hasSubmenu) {
          return PopupMenuButton<String>(
            tooltip: item.label,
            offset: const Offset(60, 0),
            position: PopupMenuPosition.over,
            itemBuilder: (context) => item.submenu!
                .map(
                  (sub) => PopupMenuItem(
                    value: sub.href,
                    child: Row(
                      children: [
                        _buildSidebarEmojiIcon(sub.href, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onSelected: (href) => _navigateFromMenu(href),
            child: Container(
              height: 48,
              width: 48,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: (isActive || isChildActive)
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: _buildSidebarEmojiIcon(item.href, size: 20),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: (item.keyTip != null)
              ? KeyTip(
                  label: item.keyTip!,
                  description: item.label,
                  onTrigger: () => _navigateFromMenu(item.href),
                  child: IconButton(
                    icon: _buildSidebarEmojiIcon(item.href, size: 20),
                    tooltip: '${item.label} (Alt + ${item.keyTip})',
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                    onPressed: () => _navigateFromMenu(item.href),
                  ),
                )
              : IconButton(
                  icon: _buildSidebarEmojiIcon(item.href, size: 20),
                  tooltip: item.label,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                  onPressed: () => _navigateFromMenu(item.href),
                ),
        );
      }
    }

    // EXPANDED MODE
    if (hasSubmenu) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: isChildActive,
          shape: const Border(),
          collapsedShape: const Border(),

          title: _HoverableSidebarItem(
            title: item.label,
            icon: _getIconForPath(item.href),
            emoji: _emojiOrNullForPath(item.href),
            isActive: false,
            onTap: null, // ExpansionTile handles tap
            trailing: isChildActive
                ? Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          leading: null,
          trailing: Icon(
            isChildActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 16,
            color: isChildActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),

          children: item.submenu!
              .map(
                (sub) => _buildNavItem(
                  sub,
                  isSubItem: true,
                  siblingItems: item.submenu,
                ),
              )
              .toList(),
        ),
      );
    }

    // Regular Item (Leaf Node)
    Widget? badge;
    if (item.href == '/dashboard/orders/route-management') {
      badge = _buildRouteOrdersMenuBadge(isActive: isActive);
    } else if (item.href == '/dashboard/tasks' && _unreadTaskCount > 0) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _unreadTaskCount > 99 ? '99+' : '$_unreadTaskCount',
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onError,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget content = GestureDetector(
      onSecondaryTapDown: (details) => _handleContextMenu(item.href, details),
      child: _HoverableSidebarItem(
        title: item.label,
        icon: _getIconForPath(item.href),
        emoji: _emojiOrNullForPath(item.href),
        isActive: isActive,
        isSubItem: isSubItem,
        trailing: badge,
        onTap: () => _navigateFromMenu(item.href),
      ),
    );

    if (item.keyTip != null) {
      return KeyTip(
        label: item.keyTip!,
        description: item.label,
        onTrigger: () => _navigateFromMenu(item.href),
        child: content,
      );
    }
    return content;
  }

  Widget _buildDrawer(AppUser user) {
    final navItems = navItemsForRole(user.role, position: NavPosition.top);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topInset = MediaQuery.paddingOf(context).top;
    final availableHeight = (screenHeight - topInset).clamp(
      220.0,
      screenHeight,
    );
    final estimatedHeaderHeight = 8.0;
    final estimatedLogoutHeight = 48.0;
    final estimatedItemHeight = 44.0;
    final estimatedPanelHeight =
        estimatedHeaderHeight +
        estimatedLogoutHeight +
        (navItems.length * estimatedItemHeight) +
        12;
    final panelHeight = estimatedPanelHeight.clamp(
      200.0,
      availableHeight * 0.86,
    );

    return SizedBox(
      width: Responsive.clamp(context, min: 176, max: 220, ratio: 0.22),
      child: SafeArea(
        bottom: false,
        child: Drawer(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: panelHeight.toDouble(),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 4,
                      ),
                      children: [
                        ...navItems.map((item) => _buildNavItem(item)),
                      ],
                    ),
                  ),
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                    minLeadingWidth: 22,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: _handleLogout,
                  ),
                  if (_appVersion.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                      child: Text(
                        _appVersion,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final userRole = ref.read(authProviderProvider).state.user?.role;
    if (userRole == null) return const SizedBox.shrink();
    final navItems = navItemsForRole(
      userRole,
      position: NavPosition.bottom,
    ).where((item) => item.href != '/dashboard/payments').toList();

    if (navItems.isEmpty) return const SizedBox.shrink();
    final currentPath = GoRouterState.of(context).uri.toString();
    final bestMatch = _bestMatchingSiblingItem(
      currentPath: currentPath,
      siblingItems: navItems,
      role: userRole,
    );

    Color bottomNavIconColor(NavItem item, {required bool isSelected}) {
      if (isSelected) {
        return Theme.of(context).colorScheme.primary;
      }
      // Keep Orders icon shape same; only tint the color for better visibility.
      if (item.href == '/dashboard/orders/route-management') {
        return AppColors.warning;
      }
      return Theme.of(context).disabledColor;
    }

    Widget buildBottomNavIcon(NavItem item, {required bool isSelected}) {
      final iconColor = bottomNavIconColor(item, isSelected: isSelected);
      final rawIcon = item.icon.trim();
      if (rawIcon.isNotEmpty) {
        return Opacity(
          opacity: isSelected ? 1.0 : 0.9,
          child: Text(
            rawIcon,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21, height: 1.0, color: iconColor),
          ),
        );
      }
      final emoji = _getEmojiForPath(item.href).trim();
      if (emoji.isNotEmpty) {
        return Opacity(
          opacity: isSelected ? 1.0 : 0.9,
          child: Text(
            emoji,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21, height: 1.0, color: iconColor),
          ),
        );
      }
      return Opacity(
        opacity: isSelected ? 1.0 : 0.9,
        child: Icon(_getIconForPath(item.href), size: 21, color: iconColor),
      );
    }

    // [LOCKED] Mobile bottom nav style: icon + label only, no card background.
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Row(
          children: navItems.map((item) {
            final isSelected = bestMatch?.href == item.href;
            return Expanded(
              child: InkWell(
                onTap: () => _navigateFromMenu(item.href),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildBottomNavIcon(item, isSelected: isSelected),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // _getIconForNavItem removed
}

class _TabItem extends StatefulWidget {
  final WorkspaceTab tab;
  final bool isActive;
  final double width;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.width,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Show close button if active OR hovering (if width permits)
    final showClose = (widget.isActive || _isHovering) && widget.width > 60;

    return MouseRegion(
      onEnter: (_) {
        if (mounted && !_isHovering) {
          setState(() => _isHovering = true);
        }
      },
      onExit: (_) {
        if (mounted && _isHovering) {
          setState(() => _isHovering = false);
        }
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: 32.0, // FIXED HEIGHT
          margin: const EdgeInsets.only(right: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: widget.isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.isActive || _isHovering
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.tab.icon,
                size: 14,
                color: widget.isActive
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.tab.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isActive
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showClose) ...[
                const SizedBox(width: 4),
                _TabCloseButton(
                  isActive: widget.isActive,
                  onPressed: widget.onClose,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabCloseButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const _TabCloseButton({required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      hoverColor: Theme.of(context).colorScheme.errorContainer,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent, // hover handled by InkWell or parent
        ),
        child: Icon(
          Icons.close,
          size: 14,
          color: isActive
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _HoverableSidebarItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? emoji;
  final bool isActive;
  final bool isSubItem;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _HoverableSidebarItem({
    required this.title,
    required this.icon,
    this.emoji,
    required this.isActive,
    this.onTap,
    this.isSubItem = false,
    this.trailing,
  });

  @override
  State<_HoverableSidebarItem> createState() => _HoverableSidebarItemState();
}

class _HoverableSidebarItemState extends State<_HoverableSidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = Responsive.width(context) <= 600;
    final horizontalMargin = isMobile ? 4.0 : 8.0;
    final horizontalPadding = widget.isSubItem
        ? (isMobile ? 10.0 : 16.0)
        : (isMobile ? 8.0 : 12.0);
    final verticalPadding = isMobile ? 8.0 : 10.0;
    final iconRightPadding = widget.isSubItem
        ? (isMobile ? 4.0 : 10.0)
        : (isMobile ? 4.0 : 12.0);

    // 1. Determine Colors based on Priority: Active > Hover > Default

    // Background Color
    final backgroundColor = widget.isActive
        ? colorScheme
              .primary // Active: Strong Primary
        : _isHovered
        ? colorScheme.primary.withValues(alpha: 0.1) // Hover: Soft Primary
        : Colors.transparent; // Default: Transparent

    // Foreground (Icon/Text) Color
    final foregroundColor = widget.isActive
        ? colorScheme
              .onPrimary // Active: White/OnPrimary
        : _isHovered
        ? colorScheme
              .primary // Hover: Primary
        : colorScheme.onSurface.withValues(alpha: 0.7); // Default: Greyish

    // Icon Color (Specific override if needed, but usually same as foreground)
    final iconColor = foregroundColor;

    return MouseRegion(
      onEnter: (_) {
        if (mounted && !_isHovered) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (mounted && _isHovered) {
          setState(() => _isHovered = false);
        }
      },
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            vertical: 2,
            horizontal: horizontalMargin,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icon
              Padding(
                padding: EdgeInsets.only(
                  right: iconRightPadding,
                  left: widget.isSubItem ? 2 : 0,
                ),
                child: widget.emoji != null
                    ? Text(
                        widget.emoji!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: widget.isSubItem ? 17 : 20,
                          height: 1.0,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        size: widget.isSubItem ? 17 : 20,
                        color: iconColor,
                      ),
              ),

              // Label
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 14,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
