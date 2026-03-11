import '../models/types/user_types.dart';
import 'role_access_matrix.dart';

enum NavPosition { top, bottom }

class NavItem {
  final String href;
  final String label;
  final String icon;
  // Legacy metadata only; effective RBAC is enforced by RoleAccessMatrix.
  final List<UserRole> roles;
  final DepartmentMain? requiredDepartment;
  final TeamName? requiredTeam;
  final NavPosition? position;
  final String? gradient;
  final List<NavItem>? submenu;
  final bool? comingSoon;
  final String? keyTip;

  NavItem({
    required this.href,
    required this.label,
    required this.icon,
    required this.roles,
    this.requiredDepartment,
    this.requiredTeam,
    this.position,
    this.gradient,
    this.submenu,
    this.comingSoon,
    this.keyTip,
  });

  bool matchesDepartment(DepartmentMain userDepartment) {
    if (requiredDepartment == null) return true;
    return requiredDepartment == userDepartment;
  }

  bool matchesTeam(TeamName? userTeam) {
    if (requiredTeam == null) return true;
    return requiredTeam == userTeam;
  }
}

NavItem _copyNavItemForRole(NavItem item, Set<String> visiblePaths) {
  final filteredSubmenu = item.submenu
      ?.where((sub) => visiblePaths.contains(sub.href))
      .map((sub) => _copyNavItemForRole(sub, visiblePaths))
      .toList();

  return NavItem(
    href: item.href,
    label: item.label,
    icon: item.icon,
    roles: item.roles,
    requiredDepartment: item.requiredDepartment,
    requiredTeam: item.requiredTeam,
    position: item.position,
    gradient: item.gradient,
    submenu: filteredSubmenu == null || filteredSubmenu.isEmpty
        ? null
        : filteredSubmenu,
    comingSoon: item.comingSoon,
    keyTip: item.keyTip,
  );
}

List<NavItem> navItemsForRole(UserRole role, {NavPosition? position}) {
  final matrixPosition = switch (position) {
    NavPosition.top => MatrixNavPosition.top,
    NavPosition.bottom => MatrixNavPosition.bottom,
    null => null,
  };

  final rootPaths = RoleAccessMatrix.navRootPathsForRole(
    role,
    position: matrixPosition,
  );
  final visiblePaths = RoleAccessMatrix.navPathsForRole(
    role,
    position: matrixPosition,
  );

  final candidatesByPath = <String, List<NavItem>>{};
  for (final nav in allNavItems) {
    final matchesPosition = position == null || nav.position == position;
    if (!matchesPosition || !rootPaths.contains(nav.href)) {
      continue;
    }
    candidatesByPath.putIfAbsent(nav.href, () => <NavItem>[]).add(nav);
  }

  final orderedItems = <NavItem>[];
  for (final path in rootPaths) {
    final candidates = candidatesByPath[path];
    if (candidates == null || candidates.isEmpty) {
      continue;
    }
    final preferred = candidates.firstWhere(
      (item) => item.roles.contains(role),
      orElse: () => candidates.first,
    );
    orderedItems.add(_copyNavItemForRole(preferred, visiblePaths));
  }

  return orderedItems;
}

List<NavItem> allNavItems = [
  NavItem(
    href: "/dashboard/dealer/dashboard",
    label: "Dashboard",
    icon: "",
    roles: [UserRole.dealerManager],
    position: NavPosition.top,
    gradient: "from-blue-500 to-indigo-600",
    keyTip: "H",
  ),
  NavItem(
    href: "/dashboard/dealer/new-sale",
    label: "New Sale",
    icon: "",
    roles: [UserRole.dealerManager],
    position: NavPosition.top,
    gradient: "from-green-500 to-teal-600",
    keyTip: "N",
  ),
  NavItem(
    href: "/dashboard/coming-soon",
    label: "Coming Soon",
    icon: "",
    roles: [
      UserRole.driver,
      UserRole.productionManager,
      UserRole.salesManager,
      UserRole.dispatchManager,
      UserRole.gateKeeper,
    ],
    position: NavPosition.top,
    gradient: "from-slate-500 to-gray-600",
    keyTip: "H",
  ),
  NavItem(
    href: "/dashboard",
    label: "Dashboard", // Keep for others
    icon: "",
    // ...
    roles: [
      UserRole.admin,
      UserRole.storeIncharge,
      UserRole.salesman,
      UserRole.fuelIncharge,
      UserRole.owner, // [NEW] Owner Access
    ],
    position: NavPosition.top,
    gradient: "from-blue-500 to-indigo-600",
    keyTip: "H",
  ),
  NavItem(
    href: "/dashboard/accounting",
    label: "Accounting",
    icon: "",
    roles: [UserRole.accountant],
    position: NavPosition.top,
    gradient: "from-emerald-500 to-teal-600",
    keyTip: "A",
  ),
  NavItem(
    href: "/dashboard/inventory/purchase-orders",
    label: "Purchase Orders",
    icon: "",
    roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
    position: NavPosition.top,
    gradient: "from-cyan-500 to-sky-600",
    keyTip: "P",
    submenu: [
      NavItem(
        href: "/dashboard/inventory/purchase-orders",
        label: "Order History",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "H",
      ),
      NavItem(
        href: "/dashboard/inventory/purchase-orders/new",
        label: "Create New PO",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge],
        keyTip: "C",
      ),
      NavItem(
        href: "/dashboard/fuel/stock",
        label: "Fuel Stock",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.fuelIncharge],
        keyTip: "F",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/inventory",
    label: "Inventory",
    icon: "",
    roles: [
      UserRole.admin,
      UserRole.storeIncharge,
      UserRole.owner,
    ], // [NEW] Owner
    position: NavPosition.top,
    gradient: "from-green-500 to-teal-600",
    keyTip: "I",
    submenu: [
      NavItem(
        href: "/dashboard/inventory/stock-overview",
        label: "Stock Inventory",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "S",
      ),
      NavItem(
        href: "/dashboard/inventory/tanks",
        label: "Liquid Tanks",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "T",
      ),
      NavItem(
        href: "/dashboard/inventory/adjust",
        label: "Stock Adjustments",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge],
        keyTip: "A",
      ),
      NavItem(
        href: "/dashboard/inventory/opening-stock",
        label: "Opening Stock",
        icon: "",
        roles: [UserRole.admin],
        keyTip: "O",
      ),
      NavItem(
        href: "/dashboard/inventory/warehouse-transfer",
        label: "Warehouse Transfer",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge],
        keyTip: "W",
      ),
      NavItem(
        href: "/dashboard/inventory/material-issue",
        label: "Issue to Dept.",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge],
        keyTip: "M",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/production",
    label: "Dashboard",
    icon: "",
    roles: [UserRole.productionSupervisor], // Only for Production Supervisor
    position: NavPosition.top,
    gradient: "from-indigo-500 to-purple-600",
    keyTip: "H",
  ),

  NavItem(
    href: "/dashboard/production/cutting/history",
    label: "History",
    icon: "",
    roles: [UserRole.productionSupervisor],
    position: NavPosition.top,
    gradient: "from-indigo-500 to-purple-600",
    keyTip: "Y",
  ),

  NavItem(
    href: "/dashboard/fuel",
    label: "Fuel Mgmt",
    icon: "",
    roles: [
      UserRole.admin,
      UserRole.storeIncharge,
      UserRole.fuelIncharge,
      UserRole.owner,
    ],
    position: NavPosition.top,
    gradient: "from-orange-500 to-amber-600",
    keyTip: "F",
    submenu: [
      NavItem(
        href: "/dashboard/fuel/stock",
        label: "Current Fuel Stock",
        icon: "",
        roles: [
          UserRole.admin,
          UserRole.storeIncharge,
          UserRole.fuelIncharge,
          UserRole.owner,
        ], // [NEW] Fuel Incharge, Owner
        keyTip: "S",
      ),
      NavItem(
        href: "/dashboard/fuel/log",
        label: "Add Fuel Log",
        icon: "",
        roles: [UserRole.admin, UserRole.fuelIncharge],
        keyTip: "L",
      ),
      NavItem(
        href: "/dashboard/fuel/history",
        label: "Fuel History",
        icon: "",
        roles: [
          UserRole.admin,
          UserRole.storeIncharge,
          UserRole.fuelIncharge,
          UserRole.owner,
        ], // [NEW] Fuel Incharge, Owner
        keyTip: "H",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/vehicles",
    label: "Vehicle Mgmt",
    icon: "",
    roles: [
      UserRole.admin,
      UserRole.storeIncharge,
      UserRole.vehicleMaintenanceManager,
    ], // [NEW] Vehicle Manager
    position: NavPosition.top,
    gradient: "from-red-500 to-orange-600",
    keyTip: "V",
    submenu: [
      NavItem(
        href: "/dashboard/vehicles/all",
        label: "Vehicle Fleet",
        icon: "",
        roles: [
          UserRole.admin,
          UserRole.storeIncharge,
          UserRole.vehicleMaintenanceManager,
        ], // [NEW]
        keyTip: "F",
      ),
      NavItem(
        href: "/dashboard/vehicles/maintenance",
        label: "Maintenance Logs",
        icon: "",
        roles: [
          UserRole.admin,
          UserRole.storeIncharge,
          UserRole.vehicleMaintenanceManager,
        ], // [NEW]
        keyTip: "M",
      ),
      NavItem(
        href: "/dashboard/vehicles/diesel",
        label: "Diesel Tracking",
        icon: "",
        roles: [
          UserRole.admin,
          UserRole.storeIncharge,
          UserRole.vehicleMaintenanceManager,
        ], // [NEW]
        keyTip: "D",
      ),
      NavItem(
        href: "/dashboard/vehicles/tyres",
        label: "Tyre Management",
        icon: "",
        roles: [
          UserRole.admin,
          UserRole.storeIncharge,
          UserRole.vehicleMaintenanceManager,
        ], // [NEW]
        keyTip: "T",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/dispatch",
    label: "Dispatch",
    icon: "",
    roles: [
      UserRole.admin,
      UserRole.storeIncharge,
      UserRole.owner,
    ], // [NEW] Owner
    position: NavPosition.top,
    gradient: "from-orange-500 to-amber-600",
    keyTip: "D",
    submenu: [
      NavItem(
        href: "/dashboard/dispatch",
        label: "Stock Dispatch",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "S",
      ),
      NavItem(
        href: "/dashboard/dispatch/dashboard",
        label: "Dealer Dispatch",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "D",
      ),
      NavItem(
        href: "/dashboard/dispatch/new-trip",
        label: "Create Trip",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge],
        keyTip: "C",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/orders/route-management",
    label: "Route Orders",
    icon: "",
    roles: [
      UserRole.owner,
      UserRole.admin,
      UserRole.productionManager,
      UserRole.salesManager,
      UserRole.accountant,
      UserRole.dispatchManager,
      UserRole.bhattiSupervisor,
      UserRole.driver,
      UserRole.salesman,
      UserRole.gateKeeper,
      UserRole.storeIncharge,
      UserRole.productionSupervisor,
      UserRole.fuelIncharge,
      UserRole.vehicleMaintenanceManager,
      UserRole.dealerManager,
    ],
    position: NavPosition.top,
    gradient: "from-cyan-500 to-blue-600",
    keyTip: "O",
  ),
  NavItem(
    href: "/dashboard/business-partners",
    label: "Business Partners",
    icon: "",
    roles: [
      UserRole.admin,
      UserRole.storeIncharge,
      UserRole.owner,
    ], // [NEW] Owner
    position: NavPosition.top,
    gradient: "from-indigo-500 to-purple-600",
    keyTip: "B",
  ),
  NavItem(
    href: "/dashboard/hr",
    label: "HR & Payroll",
    icon: "",
    roles: [UserRole.admin],
    position: NavPosition.top,
    gradient: "from-pink-500 to-rose-600",
    keyTip: "E",
  ),
  NavItem(
    href: "/dashboard/management",
    label: "Management",
    icon: "",
    roles: [UserRole.admin, UserRole.storeIncharge],
    position: NavPosition.top,
    gradient: "from-gray-500 to-slate-600",
    keyTip: "M",
    submenu: [
      NavItem(
        href: "/dashboard/management/products",
        label: "Product Catalog",
        icon: "",
        roles: [UserRole.admin],
        keyTip: "P",
      ),
      NavItem(
        href: "/dashboard/management/master-data",
        label: "Master Data",
        icon: "",
        roles: [UserRole.admin],
        keyTip: "M",
      ),
      NavItem(
        href: "/dashboard/management/formulas",
        label: "Formulas",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge],
        keyTip: "F",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/location",
    label: "Location & Maps",
    icon: "",
    roles: [
      UserRole.admin,
      UserRole.storeIncharge,
      UserRole.owner,
    ], // [NEW] Owner
    position: NavPosition.top,
    gradient: "from-indigo-500 to-blue-600",
    keyTip: "L",
    submenu: [
      NavItem(
        href: "/dashboard/gps",
        label: "Real-time Tracking",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "T",
      ),
      NavItem(
        href: "/dashboard/map-view/customers",
        label: "Customers Map",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "C",
      ),
      NavItem(
        href: "/dashboard/map-view/route-planner",
        label: "Route Planning",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "R",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/reports",
    label: "Reports",
    icon: "",
    roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
    position: NavPosition.top,
    gradient: "from-amber-500 to-yellow-600",
    keyTip: "R",
    submenu: [
      NavItem(
        href: "/dashboard/reports/dealer",
        label: "Dealer Report",
        icon: "",
        roles: [UserRole.admin, UserRole.dealerManager, UserRole.owner],
        keyTip: "D",
      ),
      NavItem(
        href: "/dashboard/reports/salesman",
        label: "Salesman Perf.", // Renamed for clarity vs Dealer
        icon: "",
        roles: [UserRole.admin, UserRole.owner],
        keyTip: "S",
      ),
      NavItem(
        href: "/dashboard/reports/production",
        label: "Production",
        icon: "",
        roles: [
          UserRole.admin,
          UserRole.productionSupervisor,
          UserRole.owner,
        ], // [NEW] Owner
        keyTip: "P",
      ),
      NavItem(
        href: "/dashboard/reports/financial",
        label: "Financials",
        icon: "",
        roles: [UserRole.admin, UserRole.owner], // [NEW] Owner
        keyTip: "F",
      ),
      NavItem(
        href: "/dashboard/reports/stock-ledger",
        label: "Stock Ledger",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "L",
      ),
      NavItem(
        href: "/dashboard/reports/stock-movement",
        label: "Stock Movement",
        icon: "",
        roles: [UserRole.admin, UserRole.storeIncharge, UserRole.owner],
        keyTip: "M",
      ),
      NavItem(
        href: "/dashboard/reports/sync-analytics",
        label: "Sync Analytics",
        icon: "",
        roles: [UserRole.admin],
        keyTip: "Y",
      ),
      NavItem(
        href: "/dashboard/reports/tally-export",
        label: "Tally Export",
        icon: "",
        roles: [UserRole.admin, UserRole.owner],
        keyTip: "T",
      ),
    ],
  ),
  NavItem(
    href: "/dashboard/reports/dealer",
    label: "Dealer Report",
    icon: "",
    roles: [UserRole.dealerManager],
    position: NavPosition.top,
    gradient: "from-amber-500 to-yellow-600",
    keyTip: "R",
  ),
  NavItem(
    href: "/dashboard/reports/diesel",
    label: "Fuel Report",
    icon: "",
    roles: [UserRole.fuelIncharge],
    position: NavPosition.top,
    gradient: "from-amber-500 to-yellow-600",
    keyTip: "R",
  ),
  NavItem(
    href: "/dashboard/returns-management",
    label: "Returns",
    icon: "",
    roles: [UserRole.salesman, UserRole.admin, UserRole.storeIncharge],
    position: NavPosition.top,
    gradient: "from-red-500 to-rose-600",
    keyTip: "U",
  ),
  NavItem(
    href: "/dashboard/dealer/history",
    label: "Sales History",
    icon: "",
    roles: [UserRole.dealerManager],
    position: NavPosition.top,
    gradient: "from-purple-500 to-pink-500",
    keyTip: "Y",
  ),

  NavItem(
    href: "/dashboard/tasks",
    label: "Tasks",
    icon: "",
    roles: [
      UserRole.admin,
      UserRole.salesman,
      UserRole.storeIncharge,
      UserRole.productionSupervisor,
      UserRole.dealerManager, // Added
    ],
    position: NavPosition.top,
    gradient: "from-rose-400 to-red-500",
    keyTip: "T",
  ),
  // Dealer Manager Bottom Navigation (mobile)
  NavItem(
    href: "/dashboard/dealer/dashboard",
    label: "Home",
    icon: "🏡",
    roles: [UserRole.dealerManager],
    position: NavPosition.bottom,
    gradient: "from-blue-500 to-indigo-600",
  ),
  NavItem(
    href: "/dashboard/dealer/new-sale",
    label: "Sale",
    icon: "💰",
    roles: [UserRole.dealerManager],
    position: NavPosition.bottom,
    gradient: "from-green-500 to-teal-600",
  ),
  NavItem(
    href: "/dashboard/business-partners",
    label: "Dealer",
    icon: "🤝",
    roles: [UserRole.dealerManager],
    position: NavPosition.bottom,
    gradient: "from-indigo-500 to-purple-600",
  ),
  NavItem(
    href: "/dashboard/orders/route-management",
    label: "Orders",
    icon: "",
    roles: [UserRole.dealerManager],
    position: NavPosition.bottom,
    gradient: "from-cyan-500 to-blue-600",
  ),
  NavItem(
    href: "/dashboard/payments",
    label: "Payment Links",
    icon: "",
    roles: [UserRole.admin, UserRole.storeIncharge], // Added
    position: NavPosition.bottom,
    gradient: "from-emerald-500 to-green-600",
    keyTip: "K",
  ),
  /*
  // Setting link hidden from sidebar as per user request (accessible via Avatar menu)
  NavItem(
    href: "/dashboard/settings",
    label: "Settings",
    icon: "",
    roles: [UserRole.admin],
    position: NavPosition.bottom,
    gradient: "from-gray-600 to-slate-700",
    submenu: [
      NavItem(
        href:
            "/dashboard/management/users", // Temporarily keeping old href for safety, will update in router next
        label: "User Access",
        icon: "",
        roles: [UserRole.admin],
      ),
      NavItem(
        href: "/dashboard/settings/users",
        label: "User Access",
        icon: "",
        roles: [UserRole.admin],
      ),
      NavItem(
        href: "/dashboard/settings/departments",
        label: "Departments",
        icon: "",
        roles: [UserRole.admin],
      ),
      NavItem(
        href: "/dashboard/settings/sales-targets",
        label: "Sales Targets",
        icon: "",
        roles: [UserRole.admin],
      ),
      NavItem(
        href: "/dashboard/settings/incentives",
        label: "Incentives",
        icon: "",
        roles: [UserRole.admin],
      ),
    ],
  ),
  */
  // Bhatti Supervisor Flat Navigation Items (Sidebar/Drawer Only)
  NavItem(
    href: "/dashboard/bhatti/overview",
    label: "Dashboard",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-blue-500 to-indigo-600",
  ),
  NavItem(
    href: "/dashboard/bhatti/cooking",
    label: "Batch Mgmt",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-orange-600 to-red-600",
  ),
  NavItem(
    href: "/dashboard/bhatti/daily-logs",
    label: "Batch History",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-emerald-500 to-teal-600",
  ),
  NavItem(
    href: "/dashboard/inventory/tanks",
    label: "Liquid Tanks",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-blue-500 to-cyan-600",
  ),
  NavItem(
    href: "/dashboard/management/formulas",
    label: "Formulas",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-purple-500 to-indigo-600",
  ),
  NavItem(
    href: "/dashboard/inventory/stock-overview",
    label: "Stock Inventory",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-green-500 to-teal-600",
  ),
  NavItem(
    href: "/dashboard/inventory/material-issue",
    label: "Issue Material",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-cyan-500 to-blue-600",
  ),
  NavItem(
    href: "/dashboard/reports/bhatti",
    label: "Bhatti Reports",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.top,
    gradient: "from-amber-500 to-orange-600",
  ),
  NavItem(
    href: "/dashboard/bhatti/overview",
    label: "Home",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.bottom,
    gradient: "from-blue-500 to-indigo-600",
  ),
  NavItem(
    href: "/dashboard/inventory/material-issue",
    label: "Issue Material",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.bottom,
    gradient: "from-cyan-500 to-blue-600",
  ),
  NavItem(
    href: "/dashboard/bhatti/daily-logs",
    label: "Batch History",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.bottom,
    gradient: "from-emerald-500 to-teal-600",
  ),
  NavItem(
    href: "/dashboard/reports/bhatti",
    label: "Reports",
    icon: "",
    roles: [UserRole.bhattiSupervisor],
    position: NavPosition.bottom,
    gradient: "from-amber-500 to-orange-600",
  ),
  NavItem(
    href: "/dashboard",
    label: "Home",
    icon: "",
    roles: [UserRole.fuelIncharge],
    position: NavPosition.bottom,
    gradient: "from-blue-500 to-indigo-600",
  ),
  NavItem(
    href: "/dashboard/fuel/log",
    label: "Fuel Log",
    icon: "",
    roles: [UserRole.fuelIncharge],
    position: NavPosition.bottom,
    gradient: "from-green-500 to-teal-600",
  ),
  NavItem(
    href: "/dashboard/fuel/history",
    label: "History",
    icon: "",
    roles: [UserRole.fuelIncharge],
    position: NavPosition.bottom,
    gradient: "from-blue-500 to-cyan-600",
  ),
  // Salesman Specific Navigation Items (non-conflicting routes only)
  // Salesman Specific Navigation Items
  NavItem(
    href: "/dashboard",
    label: "Home",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.bottom,
    gradient: "from-blue-500 to-indigo-600",
  ),
  NavItem(
    href: "/dashboard/salesman-customers",
    label: "Customers",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.bottom,
    gradient: "from-indigo-500 to-purple-600",
  ),
  NavItem(
    href: "/dashboard/salesman-sales/new",
    label: "New Sale",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.bottom,
    gradient: "from-blue-400 to-cyan-500",
  ),
  // Production Supervisor Bottom Nav
  NavItem(
    href: "/dashboard",
    label: "Home",
    icon: "🏠",
    roles: [UserRole.productionSupervisor],
    position: NavPosition.bottom,
    gradient: "from-blue-500 to-indigo-600",
  ),
  NavItem(
    href: "/dashboard/production/stock",
    label: "Stock",
    icon: "📦",
    roles: [UserRole.productionSupervisor],
    position: NavPosition.bottom,
    gradient: "from-green-500 to-teal-600",
  ),
  NavItem(
    href: "/dashboard/production/cutting/entry",
    label: "Start Cutting",
    icon: "✂️",
    roles: [UserRole.productionSupervisor],
    position: NavPosition.bottom,
    gradient: "from-indigo-500 to-purple-600",
  ),
  NavItem(
    href: "/dashboard/reports/production",
    label: "Reports",
    icon: "📊",
    roles: [UserRole.productionSupervisor],
    position: NavPosition.bottom,
    gradient: "from-amber-500 to-orange-600",
  ),
  NavItem(
    href: "/dashboard/orders/route-management",
    label: "Orders",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.bottom,
    gradient: "from-cyan-500 to-blue-600",
  ),
  NavItem(
    href: "/dashboard/salesman-inventory",
    label: "My Stock",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.bottom,
    gradient: "from-orange-400 to-red-500",
  ),
  // [LOCKED] Salesman report shortcut in sidebar (top)
  NavItem(
    href: "/dashboard/salesman-target-analysis",
    label: "Reports",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.top,
    gradient: "from-amber-500 to-yellow-600",
    keyTip: "R",
  ),
  // Side Drawer Items for Salesman
  NavItem(
    href: "/dashboard/salesman-sales/history",
    label: "Sales History",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.top,
    gradient: "from-purple-500 to-pink-500",
  ),
  NavItem(
    href: "/dashboard/salesman-performance",
    label: "My Performance",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.top,
    gradient: "from-emerald-400 to-teal-500",
  ),
  NavItem(
    href: "/dashboard/salesman-profile",
    label: "My Profile",
    icon: "",
    roles: [UserRole.salesman],
    position: NavPosition.top,
    gradient: "from-gray-600 to-slate-700",
  ),
];
