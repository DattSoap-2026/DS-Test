import '../models/types/user_types.dart';

enum FinalUserRole {
  admin,
  manager,
  production,
  bhatti,
  salesman,
  dealer,
  accountant,
  fuel,
  vehicleMaintenance,
  legacy,
}

enum MatrixNavPosition { top, bottom }

enum RoleCapability {
  salesMutate,
  productionInventoryView,
  inventoryMutate,
  mapViewAll,
  mapViewSelf,
  mapPlanRoutes,
  routeOrdersView,
  routeOrdersCreate,
  routeOrdersEditOwn,
  routeOrdersCancelOwn,
  routeOrdersDeleteOwn,
  routeOrdersMarkReady,
  routeOrdersDispatch,
  routeOrdersStructuralModify,
  reportsAll,
  reportStockLedgerView,
  reportStockMovementView,
  reportProductionView,
  reportCuttingYieldView,
  reportWasteAnalysisView,
  formulasView,
  formulasCreate,
  formulasEdit,
  formulasDelete,
  paymentsCreate,
  paymentLinksCreate,
  paymentLinksUpdate,
  returnsCreate,
  returnsApproveReject,
  productionLogMutate,
  productionTargetMutate,
}

class _RoleAccessProfile {
  final String landingPath;
  final Set<String> pathRules;
  final Set<String> topNavPaths;
  final Set<String> bottomNavPaths;
  final Set<String> submenuPaths;
  final Set<String> reportPaths;
  final Set<String> productionInventoryViewPaths;
  final Set<RoleCapability> capabilities;

  const _RoleAccessProfile({
    required this.landingPath,
    required this.pathRules,
    required this.topNavPaths,
    required this.bottomNavPaths,
    required this.submenuPaths,
    required this.reportPaths,
    required this.productionInventoryViewPaths,
    required this.capabilities,
  });
}

class RoleAccessMatrix {
  static const Set<UserRole> _adminAliases = {UserRole.admin, UserRole.owner};
  static const Set<UserRole> _managerAliases = {UserRole.storeIncharge};
  static const Set<UserRole> _productionAliases = {
    UserRole.productionManager,
    UserRole.productionSupervisor,
  };
  static const Set<UserRole> _bhattiAliases = {UserRole.bhattiSupervisor};
  static const Set<UserRole> _salesmanAliases = {UserRole.salesman};
  static const Set<UserRole> _dealerAliases = {UserRole.dealerManager};
  static const Set<UserRole> _accountantAliases = {UserRole.accountant};
  static const Set<UserRole> _fuelAliases = {UserRole.fuelIncharge};
  static const Set<UserRole> _vehicleMaintenanceAliases = {
    UserRole.vehicleMaintenanceManager,
  };

  // Firestore-rules-aligned role groups used for service-layer capability checks.
  static const Set<UserRole> _adminOrManagerRulesRoles = {
    UserRole.owner,
    UserRole.admin,
    UserRole.salesManager,
    UserRole.productionManager,
    UserRole.dealerManager,
    UserRole.dispatchManager,
  };
  static const Set<UserRole> _salesTeamRulesRoles = {
    UserRole.owner,
    UserRole.admin,
    UserRole.salesManager,
    UserRole.salesman,
    UserRole.dealerManager,
  };
  static const Set<UserRole> _productionTeamRulesRoles = {
    UserRole.owner,
    UserRole.admin,
    UserRole.productionManager,
    UserRole.productionSupervisor,
    UserRole.bhattiSupervisor,
  };

  static const Set<UserRole> _legacyRoles = {
    UserRole.salesManager,
    UserRole.dispatchManager,
    UserRole.driver,
    UserRole.gateKeeper,
  };

  static const Set<RoleCapability> _allCapabilities = {
    RoleCapability.salesMutate,
    RoleCapability.productionInventoryView,
    RoleCapability.inventoryMutate,
    RoleCapability.mapViewAll,
    RoleCapability.mapPlanRoutes,
    RoleCapability.routeOrdersView,
    RoleCapability.routeOrdersCreate,
    RoleCapability.routeOrdersEditOwn,
    RoleCapability.routeOrdersCancelOwn,
    RoleCapability.routeOrdersDeleteOwn,
    RoleCapability.routeOrdersMarkReady,
    RoleCapability.routeOrdersDispatch,
    RoleCapability.routeOrdersStructuralModify,
    RoleCapability.reportsAll,
    RoleCapability.reportStockLedgerView,
    RoleCapability.reportStockMovementView,
    RoleCapability.reportProductionView,
    RoleCapability.reportCuttingYieldView,
    RoleCapability.reportWasteAnalysisView,
    RoleCapability.formulasView,
    RoleCapability.formulasCreate,
    RoleCapability.formulasEdit,
    RoleCapability.formulasDelete,
    RoleCapability.paymentsCreate,
    RoleCapability.paymentLinksCreate,
    RoleCapability.paymentLinksUpdate,
    RoleCapability.returnsCreate,
    RoleCapability.returnsApproveReject,
    RoleCapability.productionLogMutate,
    RoleCapability.productionTargetMutate,
  };

  static const _RoleAccessProfile _adminProfile = _RoleAccessProfile(
    landingPath: '/dashboard',
    pathRules: {'/dashboard*'},
    topNavPaths: {
      '/dashboard',
      '/dashboard/inventory/purchase-orders',
      '/dashboard/inventory',
      '/dashboard/fuel',
      '/dashboard/vehicles',
      '/dashboard/dispatch',
      '/dashboard/orders/route-management',
      '/dashboard/business-partners',
      '/dashboard/hr',
      '/dashboard/management',
      '/dashboard/location',
      '/dashboard/reports',
      '/dashboard/returns-management',
      '/dashboard/tasks',
    },
    bottomNavPaths: {'/dashboard/payments'},
    submenuPaths: {
      '/dashboard/inventory/purchase-orders',
      '/dashboard/inventory/purchase-orders/new',
      '/dashboard/fuel/stock',
      '/dashboard/inventory/stock-overview',
      '/dashboard/inventory/tanks',
      '/dashboard/inventory/adjust',
      '/dashboard/inventory/opening-stock',
      '/dashboard/inventory/material-issue',
      '/dashboard/fuel/log',
      '/dashboard/fuel/history',
      '/dashboard/vehicles/all',
      '/dashboard/vehicles/maintenance',
      '/dashboard/vehicles/diesel',
      '/dashboard/vehicles/tyres',
      '/dashboard/dispatch',
      '/dashboard/dispatch/dashboard',
      '/dashboard/dispatch/new-trip',
      '/dashboard/management/products',
      '/dashboard/management/master-data',
      '/dashboard/management/formulas',
      '/dashboard/gps',
      '/dashboard/map-view/customers',
      '/dashboard/map-view/route-planner',
      '/dashboard/reports/dealer',
      '/dashboard/reports/salesman',
      '/dashboard/reports/production',
      '/dashboard/reports/cutting-yield',
      '/dashboard/reports/waste-analysis',
      '/dashboard/reports/financial',
      '/dashboard/reports/stock-ledger',
      '/dashboard/reports/stock-movement',
      '/dashboard/reports/sync-analytics',
    },
    reportPaths: {
      '/dashboard/reports',
      '/dashboard/reports/dealer',
      '/dashboard/reports/salesman',
      '/dashboard/reports/production',
      '/dashboard/reports/cutting-yield',
      '/dashboard/reports/waste-analysis',
      '/dashboard/reports/financial',
      '/dashboard/reports/stock-ledger',
      '/dashboard/reports/stock-movement',
      '/dashboard/reports/sync-analytics',
    },
    productionInventoryViewPaths: {
      '/dashboard/inventory',
      '/dashboard/inventory/stock-overview',
      '/dashboard/inventory/tanks',
      '/dashboard/production/stock',
    },
    capabilities: _allCapabilities,
  );

  static const _RoleAccessProfile _managerProfile = _RoleAccessProfile(
    landingPath: '/dashboard',
    pathRules: {
      '/dashboard',
      '/dashboard/inventory',
      '/dashboard/inventory/stock-overview*',
      '/dashboard/inventory/tanks*',
      '/dashboard/inventory/adjust*',
      '/dashboard/inventory/material-issue*',
      '/dashboard/inventory/purchase-orders*',
      '/dashboard/fuel*',
      '/dashboard/vehicles*',
      '/dashboard/dispatch*',
      '/dashboard/orders/route-management*',
      '/dashboard/business-partners*',
      '/dashboard/management',
      '/dashboard/management/formulas*',
      '/dashboard/reports',
      '/dashboard/reports/stock-ledger*',
      '/dashboard/reports/stock-movement*',
      '/dashboard/returns-management*',
      '/dashboard/tasks*',
      '/dashboard/settings/alerts*',
      '/dashboard/payments*',
      '/dashboard/location*',
      '/dashboard/gps*',
      '/dashboard/map-view*',
    },
    topNavPaths: {
      '/dashboard',
      '/dashboard/inventory/purchase-orders',
      '/dashboard/inventory',
      '/dashboard/fuel',
      '/dashboard/vehicles',
      '/dashboard/dispatch',
      '/dashboard/orders/route-management',
      '/dashboard/business-partners',
      '/dashboard/management',
      '/dashboard/location',
      '/dashboard/reports',
      '/dashboard/returns-management',
      '/dashboard/tasks',
    },
    bottomNavPaths: {'/dashboard/payments'},
    submenuPaths: {
      '/dashboard/inventory/purchase-orders',
      '/dashboard/inventory/purchase-orders/new',
      '/dashboard/fuel/stock',
      '/dashboard/inventory/stock-overview',
      '/dashboard/inventory/tanks',
      '/dashboard/inventory/adjust',
      '/dashboard/inventory/material-issue',
      '/dashboard/fuel/history',
      '/dashboard/vehicles/all',
      '/dashboard/vehicles/maintenance',
      '/dashboard/vehicles/diesel',
      '/dashboard/vehicles/tyres',
      '/dashboard/dispatch',
      '/dashboard/dispatch/dashboard',
      '/dashboard/dispatch/new-trip',
      '/dashboard/management/formulas',
      '/dashboard/gps',
      '/dashboard/map-view/customers',
      '/dashboard/map-view/route-planner',
      '/dashboard/reports/stock-ledger',
      '/dashboard/reports/stock-movement',
    },
    reportPaths: {
      '/dashboard/reports/stock-ledger',
      '/dashboard/reports/stock-movement',
    },
    productionInventoryViewPaths: <String>{},
    capabilities: {
      RoleCapability.salesMutate,
      RoleCapability.inventoryMutate,
      RoleCapability.routeOrdersView,
      RoleCapability.routeOrdersMarkReady,
      RoleCapability.routeOrdersDispatch,
      RoleCapability.reportStockLedgerView,
      RoleCapability.reportStockMovementView,
      RoleCapability.formulasView,
      RoleCapability.formulasCreate,
      RoleCapability.formulasEdit,
    },
  );

  static const _RoleAccessProfile _productionProfile = _RoleAccessProfile(
    landingPath: '/dashboard/production',
    pathRules: {
      '/dashboard',
      '/dashboard/production*',
      '/dashboard/inventory',
      '/dashboard/inventory/stock-overview*',
      '/dashboard/inventory/tanks*',
      '/dashboard/orders/route-management*',
      '/dashboard/tasks*',
      '/dashboard/settings/alerts*',
      '/dashboard/reports/production*',
      '/dashboard/reports/cutting-yield*',
      '/dashboard/reports/waste-analysis*',
    },
    topNavPaths: {
      '/dashboard/production',
      '/dashboard/production/cutting/history',
      '/dashboard/orders/route-management',
      '/dashboard/tasks',
    },
    bottomNavPaths: {
      '/dashboard',
      '/dashboard/production/stock',
      '/dashboard/production/cutting/entry',
      '/dashboard/reports/production',
    },
    submenuPaths: {'/dashboard/reports/production'},
    reportPaths: {
      '/dashboard/reports/production',
      '/dashboard/reports/cutting-yield',
      '/dashboard/reports/waste-analysis',
    },
    productionInventoryViewPaths: {
      '/dashboard/inventory',
      '/dashboard/inventory/stock-overview',
      '/dashboard/inventory/tanks',
      '/dashboard/production/stock',
    },
    capabilities: {
      RoleCapability.productionInventoryView,
      RoleCapability.routeOrdersView,
      RoleCapability.routeOrdersMarkReady,
      RoleCapability.reportProductionView,
      RoleCapability.reportCuttingYieldView,
      RoleCapability.reportWasteAnalysisView,
      RoleCapability.productionLogMutate,
    },
  );

  static const _RoleAccessProfile _salesmanProfile = _RoleAccessProfile(
    landingPath: '/dashboard',
    pathRules: {
      '/dashboard',
      '/dashboard/salesman-customers*',
      '/dashboard/salesman-sales*',
      '/dashboard/salesman-inventory*',
      '/dashboard/salesman-target-analysis*',
      '/dashboard/salesman-performance*',
      '/dashboard/salesman-profile*',
      '/dashboard/orders/route-management*',
      '/dashboard/returns-management*',
      '/dashboard/tasks*',
      '/dashboard/settings/alerts*',
    },
    topNavPaths: {
      '/dashboard',
      '/dashboard/orders/route-management',
      '/dashboard/returns-management',
      '/dashboard/tasks',
      '/dashboard/salesman-target-analysis',
      '/dashboard/salesman-sales/history',
      '/dashboard/salesman-performance',
      '/dashboard/salesman-profile',
    },
    bottomNavPaths: {
      '/dashboard',
      '/dashboard/salesman-customers',
      '/dashboard/salesman-sales/new',
      '/dashboard/orders/route-management',
      '/dashboard/salesman-inventory',
    },
    submenuPaths: <String>{},
    reportPaths: <String>{},
    productionInventoryViewPaths: <String>{},
    capabilities: {
      RoleCapability.salesMutate,
      RoleCapability.routeOrdersView,
      RoleCapability.routeOrdersCreate,
      RoleCapability.routeOrdersEditOwn,
      RoleCapability.routeOrdersCancelOwn,
      RoleCapability.routeOrdersDeleteOwn,
      RoleCapability.paymentsCreate,
      RoleCapability.paymentLinksCreate,
      RoleCapability.returnsCreate,
    },
  );

  static const _RoleAccessProfile _bhattiProfile = _RoleAccessProfile(
    landingPath: '/dashboard/bhatti/overview',
    pathRules: {
      '/dashboard',
      '/dashboard/bhatti*',
      '/dashboard/inventory',
      '/dashboard/inventory/tanks*',
      '/dashboard/inventory/stock-overview*',
      '/dashboard/inventory/material-issue*',
      '/dashboard/management/formulas*',
      '/dashboard/reports/bhatti*',
      '/dashboard/settings/alerts*',
    },
    topNavPaths: {
      '/dashboard/bhatti/overview',
      '/dashboard/bhatti/cooking',
      '/dashboard/bhatti/daily-logs',
      '/dashboard/inventory/tanks',
      '/dashboard/management/formulas',
      '/dashboard/inventory/stock-overview',
      '/dashboard/inventory/material-issue',
      '/dashboard/reports/bhatti',
    },
    bottomNavPaths: {
      '/dashboard/bhatti/overview',
      '/dashboard/bhatti/cooking',
      '/dashboard/bhatti/daily-logs',
      '/dashboard/reports/bhatti',
    },
    submenuPaths: <String>{},
    reportPaths: {'/dashboard/reports/bhatti'},
    productionInventoryViewPaths: {
      '/dashboard/inventory',
      '/dashboard/inventory/stock-overview',
      '/dashboard/inventory/tanks',
    },
    capabilities: {
      RoleCapability.productionInventoryView,
      RoleCapability.formulasView,
      RoleCapability.productionLogMutate,
    },
  );

  static const _RoleAccessProfile _dealerProfile = _RoleAccessProfile(
    landingPath: '/dashboard/dealer/dashboard',
    pathRules: {
      '/dashboard',
      '/dashboard/dealer*',
      '/dashboard/reports/dealer*',
      '/dashboard/business-partners*',
      '/dashboard/orders/route-management*',
      '/dashboard/tasks*',
      '/dashboard/settings/alerts*',
      '/dashboard/management/dealers*',
    },
    topNavPaths: {
      '/dashboard/dealer/dashboard',
      '/dashboard/dealer/new-sale',
      '/dashboard/dealer/history',
      '/dashboard/business-partners',
      '/dashboard/orders/route-management',
      '/dashboard/reports/dealer',
      '/dashboard/tasks',
    },
    bottomNavPaths: {
      '/dashboard/dealer/dashboard',
      '/dashboard/dealer/new-sale',
      '/dashboard/business-partners',
      '/dashboard/orders/route-management',
    },
    submenuPaths: <String>{},
    reportPaths: {'/dashboard/reports/dealer'},
    productionInventoryViewPaths: <String>{},
    capabilities: {
      RoleCapability.salesMutate,
      RoleCapability.routeOrdersView,
      RoleCapability.routeOrdersCreate,
      RoleCapability.routeOrdersEditOwn,
      RoleCapability.routeOrdersCancelOwn,
      RoleCapability.routeOrdersDeleteOwn,
      RoleCapability.paymentsCreate,
      RoleCapability.paymentLinksCreate,
      RoleCapability.returnsCreate,
    },
  );

  static const _RoleAccessProfile _accountantProfile = _RoleAccessProfile(
    landingPath: '/dashboard/accounting',
    pathRules: {
      '/dashboard',
      '/dashboard/accounting*',
      '/dashboard/payments*',
      '/dashboard/settings/alerts*',
    },
    topNavPaths: {'/dashboard/accounting'},
    bottomNavPaths: <String>{},
    submenuPaths: <String>{},
    reportPaths: <String>{},
    productionInventoryViewPaths: <String>{},
    capabilities: {
      RoleCapability.paymentsCreate,
      RoleCapability.paymentLinksCreate,
      RoleCapability.paymentLinksUpdate,
    },
  );

  static const _RoleAccessProfile _fuelProfile = _RoleAccessProfile(
    landingPath: '/dashboard',
    pathRules: {
      '/dashboard',
      '/dashboard/fuel*',
      '/dashboard/reports/diesel*',
      '/dashboard/settings/alerts*',
    },
    topNavPaths: {'/dashboard', '/dashboard/fuel', '/dashboard/reports/diesel'},
    bottomNavPaths: {
      '/dashboard',
      '/dashboard/fuel/log',
      '/dashboard/fuel/history',
    },
    submenuPaths: {
      '/dashboard/fuel/stock',
      '/dashboard/fuel/log',
      '/dashboard/fuel/history',
    },
    reportPaths: {'/dashboard/reports/diesel'},
    productionInventoryViewPaths: <String>{},
    capabilities: <RoleCapability>{},
  );

  static const _RoleAccessProfile _vehicleMaintenanceProfile =
      _RoleAccessProfile(
        landingPath: '/dashboard/vehicles',
        pathRules: {
          '/dashboard',
          '/dashboard/vehicles*',
          '/dashboard/settings/alerts*',
        },
        topNavPaths: {'/dashboard/vehicles'},
        bottomNavPaths: <String>{},
        submenuPaths: {
          '/dashboard/vehicles/all',
          '/dashboard/vehicles/maintenance',
          '/dashboard/vehicles/diesel',
          '/dashboard/vehicles/tyres',
        },
        reportPaths: <String>{},
        productionInventoryViewPaths: <String>{},
        capabilities: <RoleCapability>{},
      );

  static const _RoleAccessProfile _legacyProfile = _RoleAccessProfile(
    landingPath: '/dashboard/coming-soon',
    pathRules: {'/dashboard/coming-soon*'},
    topNavPaths: {'/dashboard/coming-soon'},
    bottomNavPaths: <String>{},
    submenuPaths: <String>{},
    reportPaths: <String>{},
    productionInventoryViewPaths: <String>{},
    capabilities: <RoleCapability>{},
  );

  static FinalUserRole finalRoleFor(UserRole role) {
    if (_adminAliases.contains(role)) return FinalUserRole.admin;
    if (_managerAliases.contains(role)) return FinalUserRole.manager;
    if (_productionAliases.contains(role)) return FinalUserRole.production;
    if (_bhattiAliases.contains(role)) return FinalUserRole.bhatti;
    if (_salesmanAliases.contains(role)) return FinalUserRole.salesman;
    if (_dealerAliases.contains(role)) return FinalUserRole.dealer;
    if (_accountantAliases.contains(role)) return FinalUserRole.accountant;
    if (_fuelAliases.contains(role)) return FinalUserRole.fuel;
    if (_vehicleMaintenanceAliases.contains(role)) {
      return FinalUserRole.vehicleMaintenance;
    }
    if (_legacyRoles.contains(role)) return FinalUserRole.legacy;
    return FinalUserRole.legacy;
  }

  static bool isLegacyRole(UserRole role) {
    return finalRoleFor(role) == FinalUserRole.legacy;
  }

  static _RoleAccessProfile _profileFor(UserRole role) {
    switch (finalRoleFor(role)) {
      case FinalUserRole.admin:
        return _adminProfile;
      case FinalUserRole.manager:
        return _managerProfile;
      case FinalUserRole.production:
        return _productionProfile;
      case FinalUserRole.bhatti:
        return _bhattiProfile;
      case FinalUserRole.salesman:
        return _salesmanProfile;
      case FinalUserRole.dealer:
        return _dealerProfile;
      case FinalUserRole.accountant:
        return _accountantProfile;
      case FinalUserRole.fuel:
        return _fuelProfile;
      case FinalUserRole.vehicleMaintenance:
        return _vehicleMaintenanceProfile;
      case FinalUserRole.legacy:
        return _legacyProfile;
    }
  }

  static String landingPathForRole(UserRole role) {
    return _profileFor(role).landingPath;
  }

  static bool canAccessPath(UserRole role, String path) {
    if (!path.startsWith('/dashboard')) return true;
    final normalized = _normalizePath(path);
    final profile = _profileFor(role);
    for (final rule in profile.pathRules) {
      if (_matchesRule(normalized, rule)) return true;
    }
    if (_isMapPath(normalized)) {
      return canAccessMapPath(role, normalized);
    }
    return false;
  }

  static bool canAccessMapPath(UserRole role, String path) {
    final normalized = _normalizePath(path);
    final canViewAll = hasCapability(role, RoleCapability.mapViewAll);
    final canViewSelf = hasCapability(role, RoleCapability.mapViewSelf);
    final canPlanRoutes = hasCapability(role, RoleCapability.mapPlanRoutes);

    if (normalized == '/dashboard/map-view') {
      return canViewAll || canPlanRoutes || canViewSelf;
    }
    if (normalized == '/dashboard/location') {
      return canViewAll || canPlanRoutes || canViewSelf;
    }
    if (normalized.startsWith('/dashboard/gps')) {
      return canViewAll || canViewSelf;
    }
    if (normalized.startsWith('/dashboard/map-view/customers')) {
      return canViewAll || canPlanRoutes;
    }
    if (normalized.startsWith('/dashboard/map-view/route-planner')) {
      return canViewAll || canPlanRoutes;
    }
    return false;
  }

  static bool hasCapability(UserRole role, RoleCapability capability) {
    final profile = _profileFor(role);
    if (profile.capabilities.contains(RoleCapability.reportsAll) &&
        capability.name.startsWith('report')) {
      return true;
    }
    if (profile.capabilities.contains(capability)) {
      return true;
    }

    switch (capability) {
      case RoleCapability.paymentsCreate:
      case RoleCapability.paymentLinksCreate:
        return _salesTeamRulesRoles.contains(role) ||
            role == UserRole.accountant;
      case RoleCapability.paymentLinksUpdate:
        return _adminOrManagerRulesRoles.contains(role) ||
            role == UserRole.accountant;
      case RoleCapability.returnsCreate:
        return _salesTeamRulesRoles.contains(role);
      case RoleCapability.returnsApproveReject:
      case RoleCapability.productionTargetMutate:
        return _adminOrManagerRulesRoles.contains(role);
      case RoleCapability.productionLogMutate:
        return _productionTeamRulesRoles.contains(role);
      case RoleCapability.mapViewAll:
        return role == UserRole.owner ||
            role == UserRole.admin ||
            role == UserRole.dispatchManager;
      case RoleCapability.mapViewSelf:
        return role == UserRole.salesman || role == UserRole.driver;
      case RoleCapability.mapPlanRoutes:
        return role == UserRole.owner ||
            role == UserRole.admin ||
            role == UserRole.storeIncharge ||
            role == UserRole.salesManager ||
            role == UserRole.dispatchManager;
      default:
        return false;
    }
  }

  static Set<String> navPathsForRole(
    UserRole role, {
    MatrixNavPosition? position,
  }) {
    final profile = _profileFor(role);
    final mapPaths = _mapNavPathsForRole(role, position: position);
    switch (position) {
      case MatrixNavPosition.top:
        return {...profile.topNavPaths, ...profile.submenuPaths, ...mapPaths};
      case MatrixNavPosition.bottom:
        return {...profile.bottomNavPaths};
      case null:
        return {
          ...profile.topNavPaths,
          ...profile.bottomNavPaths,
          ...profile.submenuPaths,
          ...mapPaths,
        };
    }
  }

  static Set<String> navRootPathsForRole(
    UserRole role, {
    MatrixNavPosition? position,
  }) {
    final profile = _profileFor(role);
    final mapRoots = _mapRootPathsForRole(role, position: position);
    switch (position) {
      case MatrixNavPosition.top:
        return {...profile.topNavPaths, ...mapRoots};
      case MatrixNavPosition.bottom:
        return profile.bottomNavPaths;
      case null:
        return {...profile.topNavPaths, ...profile.bottomNavPaths, ...mapRoots};
    }
  }

  static Set<String> reportPathsForRole(UserRole role) {
    return _profileFor(role).reportPaths;
  }

  static Set<String> productionInventoryViewPaths(UserRole role) {
    return _profileFor(role).productionInventoryViewPaths;
  }

  static String reportHomePathForRole(UserRole role) {
    switch (finalRoleFor(role)) {
      case FinalUserRole.admin:
        return '/dashboard/reports';
      case FinalUserRole.manager:
        return '/dashboard/reports/stock-ledger';
      case FinalUserRole.production:
        return '/dashboard/reports/production';
      case FinalUserRole.bhatti:
        return '/dashboard/reports/bhatti';
      case FinalUserRole.salesman:
        return landingPathForRole(role);
      case FinalUserRole.dealer:
        return '/dashboard/reports/dealer';
      case FinalUserRole.accountant:
        return '/dashboard/accounting';
      case FinalUserRole.fuel:
        return '/dashboard/reports/diesel';
      case FinalUserRole.vehicleMaintenance:
        return '/dashboard/vehicles';
      case FinalUserRole.legacy:
        return landingPathForRole(role);
    }
  }

  static String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  static bool _matchesRule(String path, String rule) {
    if (rule.endsWith('*')) {
      final prefix = rule.substring(0, rule.length - 1);
      return path.startsWith(prefix);
    }
    return path == rule;
  }

  static bool _isMapPath(String path) {
    return path == '/dashboard/location' ||
        path.startsWith('/dashboard/gps') ||
        path.startsWith('/dashboard/map-view');
  }

  static Set<String> _mapRootPathsForRole(
    UserRole role, {
    MatrixNavPosition? position,
  }) {
    if (position == MatrixNavPosition.bottom) {
      return const <String>{};
    }
    final canViewAll = hasCapability(role, RoleCapability.mapViewAll);
    final canViewSelf = hasCapability(role, RoleCapability.mapViewSelf);
    final canPlanRoutes = hasCapability(role, RoleCapability.mapPlanRoutes);
    if (!canViewAll && !canViewSelf && !canPlanRoutes) {
      return const <String>{};
    }
    return const <String>{'/dashboard/location'};
  }

  static Set<String> _mapNavPathsForRole(
    UserRole role, {
    MatrixNavPosition? position,
  }) {
    if (position == MatrixNavPosition.bottom) {
      return const <String>{};
    }
    final canViewAll = hasCapability(role, RoleCapability.mapViewAll);
    final canViewSelf = hasCapability(role, RoleCapability.mapViewSelf);
    final canPlanRoutes = hasCapability(role, RoleCapability.mapPlanRoutes);

    final paths = <String>{};
    if (canViewAll || canViewSelf || canPlanRoutes) {
      paths.add('/dashboard/location');
    }
    if (canViewAll || canViewSelf) {
      paths.add('/dashboard/gps');
    }
    if (canViewAll || canPlanRoutes) {
      paths
        ..add('/dashboard/map-view/customers')
        ..add('/dashboard/map-view/route-planner');
    }
    return paths;
  }
}
