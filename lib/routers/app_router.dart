// [HARD LOCKED] - Authentication & Authorization Module
//
// CRITICAL: This file contains core security and access control logic.
// - NO modification allowed without explicit AUTH_LOCK_OVERRIDE.
// - NO refactoring or optimization allowed.
// - ALL changes must be documented for security review.
//
// Strict Contract: Online-only login, Firestore-verified roles.
// Security Source: Firebase Auth & Firestore 'users' collection.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import '../constants/nav_items.dart';
import '../constants/role_access_matrix.dart';
import '../models/types/product_types.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/salesman_dashboard_screen.dart';
import '../screens/sales/sales_history_screen.dart';
import '../screens/inventory/inventory_overview_screen.dart';
import '../screens/inventory/my_stock_screen.dart';
import '../screens/inventory/inventory_reconciliation_screen.dart';
import '../screens/inventory/material_issue_screen.dart';

import '../screens/bhatti/bhatti_dashboard_screen.dart';
import '../screens/bhatti/bhatti_cooking_screen.dart';
import '../screens/bhatti/bhatti_batch_edit_screen.dart';
import '../screens/bhatti/bhatti_consumption_audit_screen.dart';
import '../screens/common/coming_soon_screen.dart';

import '../screens/dev/widget_gallery_screen.dart';
import '../utils/ui_notifier.dart';
import '../widgets/navigation/main_scaffold.dart';
import '../providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/customers_service.dart';
import '../services/permission_service.dart';

import '../screens/fuel/fuel_log_screen.dart';
import '../screens/fuel/fuel_stock_screen.dart';
import '../screens/fuel/fuel_history_screen.dart';
import '../screens/vehicles/vehicle_management_screen.dart';
import '../screens/vehicles/add_vehicle_screen.dart';
import '../screens/vehicles/add_diesel_log_screen.dart';
import '../screens/vehicles/add_maintenance_log_screen.dart';
import '../services/vehicles_service.dart';
import '../screens/vehicles/add_tyre_log_screen.dart';
import '../screens/vehicles/add_tyre_stock_invoice_screen.dart';
import '../screens/vehicles/vehicle_detail_screen.dart';
import '../screens/customers/customer_management_screen.dart';
import '../screens/reports/reports_module_screen.dart';
import '../screens/reports/reporting_hub_screen.dart';
import '../modules/accounting/screens/accounting_dashboard_screen.dart';
import '../modules/accounting/screens/voucher_entry_screen.dart';
import '../modules/accounting/screens/ledger_drilldown_screen.dart';
import '../screens/returns/returns_management_screen.dart';
import '../screens/returns/salesman_returns_screen.dart';
import '../screens/returns/add_return_request_screen.dart';
import '../screens/purchase_orders/purchase_orders_list_screen.dart';
import '../screens/purchase_orders/purchase_order_details_screen.dart';
import '../screens/purchase_orders/purchase_order_form_screen.dart';
import '../screens/purchase_orders/purchase_order_pdf_preview_screen.dart';
import '../screens/gps/gps_tracking_screen.dart';
import '../screens/map/customers_map_screen.dart';
import '../screens/map/route_planner_screen.dart';
import '../screens/settings/settings_module_screen.dart';
import '../screens/settings/audit_logs_screen.dart';
import '../screens/settings/custom_roles_screen.dart';
import '../screens/management/department_management_screen.dart';
import '../screens/settings/currencies_screen.dart';
import '../screens/settings/transaction_series_screen.dart';
import '../screens/settings/fuel_settings_screen.dart';
import '../screens/management/schemes_screen.dart';
import '../screens/settings/general_settings_screen.dart';
import '../screens/settings/incentives_screen.dart';
import '../screens/settings/pdf_templates_screen.dart';
import '../screens/settings/company_profile_screen.dart';
import '../screens/settings/theme_settings_screen.dart';
import '../screens/settings/taxation_screen.dart';
import '../screens/settings/system_data_screen.dart';
import '../screens/settings/user_preferences_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/payments/add_payment_screen.dart';
import '../screens/management/management_module_screen.dart';
import '../screens/management/users_screen.dart';
import '../screens/management/products_list_screen.dart';
import '../screens/management/product_add_edit_screen.dart';
import '../screens/management/formulas_screen.dart';
import '../screens/management/dealers_screen.dart';
import '../screens/management/master_data_screen.dart';
import '../screens/management/sales_targets_screen.dart';
import '../screens/management/route_targets_screen.dart';
import '../screens/reports/salesman_performance_screen.dart';
import '../screens/reports/sales_report_screen.dart';
import '../screens/reports/sales_dispatch_report_screen.dart';
import '../screens/reports/stock_valuation_report_screen.dart';
import '../screens/management/system_masters_screen.dart';

import '../screens/reports/production_report_screen.dart';
import '../screens/reports/bhatti_report_screen.dart';
import '../screens/reports/returns_report_screen.dart';
import '../screens/reports/gst_report_screen.dart';
import '../screens/reports/financial_report_screen.dart';

import '../screens/reports/dealer_report_screen.dart';
import '../screens/reports/salesman_report_screen.dart';
import '../screens/reports/maintenance_report_screen.dart'; // import '../screens/customers/customer_management_screen.dart'; // REMOVED
import '../screens/reports/tyre_report_screen.dart';
import '../screens/reports/diesel_report_screen.dart';
import '../screens/reports/customer_aging_report_screen.dart';
import '../screens/reports/tally_export_report_screen.dart';
import '../screens/business_partners/business_partners_screen.dart';

import '../screens/reports/stock_ledger_screen.dart';
import '../screens/reports/stock_movement_report_screen.dart';
import '../screens/reports/target_achievement_report_screen.dart';
import '../screens/reports/my_performance_screen.dart';
import '../screens/driver/driver_module_screen.dart';
import '../screens/driver/duty_screen.dart';
import '../screens/management/routes_management_screen.dart';
import '../screens/driver/driver_trips_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/tasks/task_history_screen.dart';
import '../screens/driver/vehicle_info_screen.dart';
import '../screens/driver/driver_diesel_log_screen.dart';
import '../screens/driver/vehicle_mileage_screen.dart';
import '../screens/sales/new_sale_screen.dart';
import '../screens/customers/customer_details_screen.dart';
import '../screens/inventory/tanks_list_screen.dart';
import '../screens/inventory/stock_adjustment_screen.dart';
import '../screens/inventory/tank_details_screen.dart';
import '../screens/production/production_dashboard_consolidated_screen.dart';
import '../screens/production/production_stock_screen.dart';
import '../screens/production/batch_details_screen.dart';
import '../screens/production/cutting_batch_entry_screen.dart';
import '../screens/production/cutting_history_screen.dart';
import '../screens/reports/cutting_yield_report_screen.dart';
import '../screens/reports/waste_analysis_report_screen.dart';
import '../screens/dispatch/dispatch_screen.dart';
import '../screens/dispatch/dealer_dispatch_screen.dart';
import '../screens/dispatch/new_trip_screen.dart';
import '../screens/dispatch/trip_details_screen.dart';
import '../screens/management/user_profile_screen.dart';
import '../models/types/user_types.dart';
import '../screens/inventory/opening_stock_setup_screen.dart';
import '../screens/inventory/warehouse_transfer_screen.dart';
import '../screens/analytics/sync_analytics_dashboard_screen.dart';
import '../screens/sync/conflict_list_screen.dart';
import '../screens/management/new_dealer_sale_screen.dart';
import '../screens/dashboard/dealer_dashboard_screen.dart';
import '../screens/dispatch/salesman_dispatch_history_screen.dart'; // NEW
import '../screens/dispatch/admin_dispatch_history_screen.dart'; // NEW
import '../screens/orders/route_order_management_screen.dart';

import '../screens/bhatti/bhatti_supervisor_screen.dart';
import '../modules/hr/screens/hr_dashboard_screen.dart';
import '../screens/settings/alerts_screen.dart';
import '../modules/hr/screens/employee_list_screen.dart';
import '../modules/hr/screens/add_edit_employee_screen.dart';
import '../modules/hr/screens/attendance_sheet_screen.dart';
import '../modules/hr/screens/payroll_management_screen.dart';
import '../modules/hr/screens/leave_approval_screen.dart';
import '../modules/hr/screens/leave_request_screen.dart';
import '../modules/hr/screens/leave_history_screen.dart';
import '../modules/hr/screens/advance_approval_screen.dart';
import '../modules/hr/screens/advance_request_screen.dart';
import '../modules/hr/screens/performance_review_list_screen.dart';
import '../modules/hr/screens/document_list_screen.dart';
import '../screens/settings/whatsapp_settings_screen.dart';
import '../modules/hr/screens/holiday_management_screen.dart';

const Set<String> _explicitChildPaths = {
  'sales/new',
  'customers/:customerId',
  'bhatti/cooking',
  'bhatti/overview',
  'inventory/material-issue',
  'inventory/tanks',
  'inventory/tanks/:tankId',
  'inventory/stock-overview',
  'production/batch/:batchId',
  'production/cutting/entry',
  'production/cutting/history',
  'dispatch/trips/:tripId',
  'vehicles/add',
  'vehicles/diesel/add',
  'vehicles/maintenance/add',
  'vehicles/tyres/add',
  'vehicles/tyres/stock',
  'driver/duty',
  'settings/audit-logs',
  'settings/company-profile',
  'settings/departments',
  'settings/custom-roles',
  'settings/currencies',
  'settings/transaction-series',
  'settings/fuel',
  'settings/schemes',
  'settings/gst',
  'settings/data-management',
  'settings/general',
  'settings/preferences',
  'settings/incentives',
  'settings/pdf-templates',
  'settings/theme-appearance',
  'settings/conflicts',
  'driver/route',
  'driver/vehicle',
  'driver/diesel',
  'driver/mileage',
  'returns-management',
  'returns/new',
  'dealer/dashboard',
  'dealer/new-sale',
  'dealer/history',
  'reports/dealer',
  'management/dealers',
  'reports/salesman',
  'reports/customer-aging',
  'reports/stock-ledger',
  'reports/stock-movement',
  'reports/target-achievement',
  'fuel/log',
  'fuel/stock',
  'fuel/history',
  'reports/sales-dispatch',
  'reports/sales',
  'reports/production',
  'reports/cutting-yield',
  'reports/waste-analysis',
  'reports/bhatti',
  'reports/stock-valuation',
  'reports/returns',
  'reports/gst',
  'reports/financial',
  'reports/maintenance',
  'reports/tyre',
  'reports/diesel',
  'reports/tally-export',
  'location',
  'map-view',
  'gps',
  'sales',
  'map-view/customers',
  'map-view/route-planner',
  'payments',
  'payments/add',
  'management',
  'management/users',
  'management/products',
  'management/formulas',
  'management/master-data',
  'management/incentives',
  'management/sales-targets',
  'dispatch/stock-dispatch',
  'business-partners',
  'hr',
  'inventory/purchase-orders',
  'inventory/purchase-orders/new',
  'inventory/purchase-orders/:poId',
  'inventory/purchase-orders/:poId/edit',
  'customers',
  'salesman-sales/new',
  'salesman-sales/history',
  'salesman-inventory',
  'salesman-customers',
  'salesman-target-analysis',
  'salesman-performance',
  'salesman-profile',
  'tasks',
  'production',
  'salesman-dispatches', // NEW
  'dispatch/history', // NEW
  'orders/route-management',
};

const Set<String> _readOnlyRestrictedPathPrefixes = {
  '/dashboard/sales/new',
  '/dashboard/dealer/new-sale',
  '/dashboard/inventory/adjust',
  '/dashboard/inventory/material-issue',
  '/dashboard/dispatch/new-trip',
};

bool _isReadOnlyRestrictedPath(String path) {
  final normalized = path.trim();
  for (final prefix in _readOnlyRestrictedPathPrefixes) {
    if (normalized == prefix || normalized.startsWith('$prefix/')) {
      return true;
    }
  }
  return false;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authProvider = ref.read(authProviderProvider);
  final permissionService = PermissionService();

  final router = GoRouter(
    navigatorKey: UINotifier.navigatorKey,
    refreshListenable: authProvider,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';

      final isSplash = state.uri.toString() == '/splash';
      final path = state.uri.path;
      final isDashboardTarget =
          path == '/dashboard' || path.startsWith('/dashboard/');

      debugPrint(
        'Router Redirect: Authenticated=$isAuthenticated, Status=${authProvider.state.status}, Target=${state.uri}',
      );

      // 1. Loading State
      if (authProvider.state.status == AuthStatus.loading) {
        // Overlay handles splash; router stays on target or login
        if (isLoggingIn || isDashboardTarget) return null;
        return '/login';
      }

      // 2. Not Authenticated -> Login
      if (!isAuthenticated) {
        // Hot-restart/session-restore guard: keep dashboard route while provider
        // is still hydrating user profile from Firebase user session.
        final hasFirebaseSession = FirebaseAuth.instance.currentUser != null;
        if (hasFirebaseSession && isDashboardTarget) {
          return null;
        }
        return isLoggingIn ? null : '/login';
      }

      // 3. Authenticated -> Prevent Login/Splash access or root
      if (isLoggingIn || isSplash || state.uri.toString() == '/') {
        final user = authProvider.currentUser;
        if (user != null) {
          final landingPath = permissionService.landingPathForRole(user.role);
          if (state.uri.toString() != landingPath) {
            debugPrint(
              'Routing User ${user.name} (${user.role.value}) to $landingPath',
            );
            return landingPath;
          }
          return null;
        }
        return '/dashboard';
      }

      // 4. Role-Based Route Guards (Matrix-driven)
      final user = authProvider.currentUser;

      if (user != null && path.startsWith('/dashboard')) {
        if (authProvider.isReadOnlyFallback &&
            _isReadOnlyRestrictedPath(path)) {
          final fallbackPath = permissionService.landingPathForRole(user.role);
          if (path != fallbackPath) {
            debugPrint(
              'Read-only fallback active. Blocking mutation route: $path',
            );
            return fallbackPath;
          }
        }
        final landingPath = permissionService.landingPathForRole(user.role);
        if (!permissionService.canAccessPathLayered(user, path)) {
          debugPrint('Access Denied (Matrix): ${user.role.value} -> $path');
          if (path == landingPath) {
            return '/dashboard/coming-soon';
          }
          return landingPath;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) => '/dashboard',
      ),
      GoRoute(
        path: '/dev/gallery',
        name: 'widget_gallery',
        builder: (context, state) => const WidgetGalleryScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MainScaffold(key: UINotifier.mainScaffoldKey, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'reports',
                name: 'reporting_hub',
                builder: (context, state) => const ReportingHubScreen(),
              ),
              GoRoute(
                path: 'accounting',
                name: 'accounting_dashboard',
                builder: (context, state) => const AccountingDashboardScreen(),
              ),
              GoRoute(
                path: 'accounting/vouchers/:voucherType',
                name: 'accounting_voucher_entry',
                builder: (context, state) {
                  final voucherType =
                      state.pathParameters['voucherType'] ?? 'journal';
                  return VoucherEntryScreen(voucherType: voucherType);
                },
              ),
              GoRoute(
                path: 'accounting/ledger/:ledgerId',
                name: 'accounting_ledger_drilldown',
                builder: (context, state) {
                  final ledgerId = state.pathParameters['ledgerId'] ?? '';
                  return LedgerDrilldownScreen(accountCode: ledgerId);
                },
              ),
              GoRoute(
                path: 'sales/new',
                name: 'sales_new',
                builder: (context, state) {
                  final customer = state.extra as Customer?;
                  return NewSaleScreen(preSelectedCustomer: customer);
                },
              ),
              GoRoute(
                path: 'customers/:customerId',
                name: 'customer_details',
                builder: (context, state) {
                  final customerId = state.pathParameters['customerId']!;
                  return CustomerDetailsScreen(customerId: customerId);
                },
              ),
              // Salesman Sales Routes
              GoRoute(
                path: 'salesman-sales/new',
                name: 'salesman_sales_new',
                builder: (context, state) {
                  final customer = state.extra as Customer?;
                  return NewSaleScreen(preSelectedCustomer: customer);
                },
              ),
              GoRoute(
                path: 'salesman-sales/history',
                name: 'salesman_sales_history',
                builder: (context, state) => const SalesHistoryScreen(),
              ),
              GoRoute(
                path: 'salesman-dispatches',
                name: 'salesman_dispatches',
                builder: (context, state) =>
                    const SalesmanDispatchHistoryScreen(), // NEW
              ),
              GoRoute(
                path: 'orders/route-management',
                name: 'route_orders_management',
                builder: (context, state) => const RouteOrderManagementScreen(),
              ),
              GoRoute(
                path: 'inventory/stock-overview',
                name: 'inventory_stock_overview',
                builder: (context, state) => const InventoryOverviewScreen(),
              ),
              GoRoute(
                path: 'inventory/tanks',
                name: 'inventory_tanks',
                builder: (context, state) => const TanksListScreen(),
              ),
              GoRoute(
                path: 'inventory/reconciliation',
                name: 'inventory_reconciliation',
                builder: (context, state) =>
                    const InventoryReconciliationScreen(),
              ),
              GoRoute(
                path: 'inventory/material-issue',
                name: 'inventory_material_issue',
                builder: (context, state) => const MaterialIssueScreen(),
              ),
              // Purchase Order Routes
              GoRoute(
                path: 'inventory/purchase-orders',
                name: 'purchase_orders_list',
                builder: (context, state) => const PurchaseOrdersListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'purchase_order_new',
                    builder: (context, state) =>
                        const PurchaseOrderFormScreen(),
                  ),
                  GoRoute(
                    path: ':poId',
                    name: 'purchase_order_details',
                    builder: (context, state) {
                      final poId = state.pathParameters['poId']!;
                      return PurchaseOrderDetailsScreen(poId: poId);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'purchase_order_edit',
                        builder: (context, state) {
                          final poId = state.pathParameters['poId']!;
                          return PurchaseOrderFormScreen(poId: poId);
                        },
                      ),
                      GoRoute(
                        path: 'preview',
                        name: 'purchase_order_preview',
                        builder: (context, state) {
                          final poId = state.pathParameters['poId']!;
                          return PurchaseOrderPdfPreviewScreen(poId: poId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'bhatti/overview',
                name: 'bhatti_overview',
                builder: (context, state) => const BhattiDashboardScreen(),
              ),
              GoRoute(
                path: 'bhatti/cooking',
                name: 'bhatti_cooking',
                builder: (context, state) => const BhattiCookingScreen(),
              ),
              GoRoute(
                path: 'bhatti/batch/:batchId/edit',
                name: 'bhatti_batch_edit',
                builder: (context, state) {
                  final batchId = state.pathParameters['batchId']!;
                  return BhattiBatchEditScreen(batchId: batchId);
                },
              ),
              GoRoute(
                path: 'bhatti/batch/:batchId/audit',
                name: 'bhatti_batch_audit',
                builder: (context, state) {
                  final batchId = state.pathParameters['batchId']!;
                  return BhattiConsumptionAuditScreen(batchId: batchId);
                },
              ),
              GoRoute(
                path: 'bhatti/daily-logs',
                name: 'bhatti_daily_logs',
                builder: (context, state) => const BhattiSupervisorScreen(),
              ),
              // Backward compatibility for legacy deep-links used by older KPI taps.
              GoRoute(
                path: 'bhatti/supervisor',
                redirect: (context, state) => '/dashboard/bhatti/daily-logs',
              ),
              GoRoute(
                path: 'inventory/tanks/:tankId',
                name: 'inventory_tank_details',
                builder: (context, state) {
                  final tankId = state.pathParameters['tankId']!;
                  return TankDetailsScreen(tankId: tankId);
                },
              ),
              GoRoute(
                path: 'production/batch/:batchId',
                name: 'production_batch_details',
                builder: (context, state) {
                  final batchId = state.pathParameters['batchId']!;
                  return BatchDetailsScreen(batchId: batchId);
                },
              ),
              GoRoute(
                path: 'production/cutting/entry',
                name: 'production_cutting_entry',
                builder: (context, state) => const CuttingBatchEntryScreen(),
              ),
              GoRoute(
                path: 'production/cutting/history',
                name: 'production_cutting_history',
                builder: (context, state) => const CuttingHistoryScreen(),
              ),

              GoRoute(
                path: 'dispatch/history', // NEW: Admin History
                name: 'admin_dispatch_history',
                builder: (context, state) => const AdminDispatchHistoryScreen(),
              ),

              GoRoute(
                path: 'dispatch/trips/:tripId',
                name: 'dispatch_trip_details',
                builder: (context, state) {
                  final tripId = state.pathParameters['tripId']!;
                  return TripDetailsScreen(tripId: tripId);
                },
              ),
              GoRoute(
                path: 'vehicles/add',
                name: 'vehicles_add',
                builder: (context, state) => const AddVehicleScreen(),
              ),
              GoRoute(
                path: 'vehicles/diesel/add',
                name: 'vehicles_diesel_add',
                builder: (context, state) => const AddDieselLogScreen(),
              ),
              GoRoute(
                path: 'vehicles/maintenance/add',
                name: 'vehicles_maintenance_add',
                builder: (context, state) => const AddMaintenanceLogScreen(),
              ),
              GoRoute(
                path: 'vehicles/tyres/add',
                name: 'vehicles_tyre_add',
                builder: (context, state) => const AddTyreLogScreen(),
              ),
              GoRoute(
                path: 'vehicles/tyres/stock',
                name: 'vehicles_tyre_stock_add',
                builder: (context, state) => const AddTyreStockInvoiceScreen(),
              ),

              GoRoute(
                path: 'driver/duty',
                name: 'driver_duty',
                builder: (context, state) => const DutyScreen(),
              ),
              GoRoute(
                path: 'profile',
                name: 'user_profile',
                builder: (context, state) {
                  final user = authProvider.state.user;
                  return UserProfileScreen(user: user);
                },
              ),
              GoRoute(
                path: 'settings',
                name: 'settings_module',
                builder: (context, state) => const SettingsModuleScreen(),
              ),
              GoRoute(
                path: 'settings/alerts',
                name: 'system_alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
              GoRoute(
                path: 'settings/audit-logs',
                name: 'audit_logs',
                builder: (context, state) => const AuditLogsScreen(),
              ),
              GoRoute(
                path: 'settings/company-profile',
                name: 'company_profile',
                builder: (context, state) => const CompanyProfileScreen(),
              ),
              GoRoute(
                path: 'settings/custom-roles',
                name: 'custom_roles',
                builder: (context, state) => const CustomRolesScreen(),
              ),
              GoRoute(
                path: 'settings/currencies',
                name: 'currencies_management',
                builder: (context, state) => const CurrenciesScreen(),
              ),
              GoRoute(
                path: 'settings/transaction-series',
                name: 'transaction_series_management',
                builder: (context, state) => const TransactionSeriesScreen(),
              ),
              GoRoute(
                path: 'settings/fuel',
                name: 'fuel_settings_management',
                builder: (context, state) => const FuelSettingsScreen(),
              ),
              GoRoute(
                path: 'settings/schemes',
                name: 'schemes_management',
                builder: (context, state) => const SchemesScreen(),
              ),
              GoRoute(
                path: 'settings/gst',
                name: 'gst_settings_management',
                builder: (context, state) => const TaxationScreen(),
              ),
              GoRoute(
                path: 'settings/data-management',
                name: 'settings_data_management',
                builder: (context, state) => const SystemDataScreen(),
              ),
              GoRoute(
                path: 'settings/general',
                name: 'settings_general',
                builder: (context, state) => const GeneralSettingsScreen(),
              ),
              GoRoute(
                path: 'settings/preferences',
                name: 'settings_preferences',
                builder: (context, state) => const UserPreferencesScreen(),
              ),
              GoRoute(
                path: 'settings/theme-appearance',
                name: 'settings_theme_appearance',
                builder: (context, state) => const ThemeSettingsScreen(),
              ),
              GoRoute(
                path: 'settings/incentives',
                name: 'settings_incentives',
                builder: (context, state) => const IncentivesScreen(),
              ),
              GoRoute(
                path: 'settings/pdf-templates',
                name: 'settings_pdf_templates',
                builder: (context, state) => const PdfTemplatesScreen(),
              ),
              GoRoute(
                path: 'settings/conflicts',
                name: 'sync_conflicts',
                builder: (context, state) => const ConflictListScreen(),
              ),
              GoRoute(
                path: 'settings/whatsapp',
                name: 'whatsapp_settings',
                builder: (context, state) => const WhatsAppSettingsScreen(),
              ),
              // New Relocated Settings Routes
              GoRoute(
                path: 'settings/users',
                name: 'settings_users',
                builder: (context, state) => const UsersScreen(),
                routes: [
                  GoRoute(
                    path: ':userId',
                    name: 'user_settings_profile_view',
                    builder: (context, state) {
                      final user = state.extra as AppUser?;
                      return UserProfileScreen(user: user);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'settings/departments',
                name: 'settings_departments',
                builder: (context, state) => const DepartmentManagementScreen(),
              ),
              GoRoute(
                path: 'settings/sales-targets',
                name: 'settings_sales_targets',
                builder: (context, state) => const SalesTargetsScreen(),
              ),
              GoRoute(
                path: 'settings/route-targets',
                name: 'settings_route_targets',
                builder: (context, state) => const RouteTargetsScreen(),
              ),
              GoRoute(
                path: 'driver/route',
                name: 'driver_route',
                builder: (context, state) => const RoutesManagementScreen(),
              ),
              GoRoute(
                path: 'driver/vehicle',
                name: 'driver_vehicle',
                builder: (context, state) => const VehicleInfoScreen(),
              ),
              GoRoute(
                path: 'driver/diesel',
                name: 'driver_diesel',
                builder: (context, state) => const DriverDieselLogScreen(),
              ),
              GoRoute(
                path: 'driver/mileage',
                name: 'driver_mileage',
                builder: (context, state) => const VehicleMileageScreen(),
              ),
              GoRoute(
                path: 'returns-management',
                name: 'returns_management',
                builder: (context, state) {
                  final user = authProvider.state.user;
                  if (user != null &&
                      RoleAccessMatrix.finalRoleFor(user.role) ==
                          FinalUserRole.salesman) {
                    return const SalesmanReturnsScreen();
                  }
                  return const ReturnsManagementScreen();
                },
              ),
              GoRoute(
                path: 'returns/new',
                name: 'returns_new',
                builder: (context, state) => const AddReturnRequestScreen(),
              ),
              GoRoute(
                path: 'reports/salesman',
                name: 'reports_salesman_performance_admin',
                builder: (context, state) => const SalesmanPerformanceScreen(),
              ),
              GoRoute(
                path: 'reports/customer-aging',
                name: 'reports_customer_aging',
                builder: (context, state) => const CustomerAgingReportScreen(),
              ),
              GoRoute(
                path: 'reports/stock-ledger',
                name: 'reports_stock_ledger',
                builder: (context, state) => const StockLedgerScreen(),
              ),
              GoRoute(
                path: 'reports/stock-movement',
                name: 'reports_stock_movement',
                builder: (context, state) => const StockMovementReportScreen(),
              ),
              GoRoute(
                path: 'reports/target-achievement',
                name: 'reports_target_achievement',
                builder: (context, state) =>
                    const TargetAchievementReportScreen(),
              ),
              GoRoute(
                path: 'inventory/opening-stock',
                name: 'inventory_opening_stock',
                builder: (context, state) => const OpeningStockSetupScreen(),
              ),
              GoRoute(
                path: 'inventory/warehouse-transfer',
                name: 'inventory_warehouse_transfer',
                builder: (context, state) => const WarehouseTransferScreen(),
              ),
              GoRoute(
                path: 'fuel/log',
                name: 'fuel_log',
                builder: (context, state) => const FuelLogScreen(),
              ),
              GoRoute(
                path: 'fuel/stock',
                name: 'fuel_stock',
                builder: (context, state) => const FuelStockScreen(),
              ),
              GoRoute(
                path: 'fuel/history',
                name: 'fuel_history',
                builder: (context, state) => const FuelHistoryScreen(),
              ),
              GoRoute(
                path: 'reports/sales-dispatch',
                name: 'reports_sales_dispatch',
                builder: (context, state) => const SalesDispatchReportScreen(),
              ),
              GoRoute(
                path: 'reports/sales',
                name: 'reports_sales',
                builder: (context, state) => const SalesReportScreen(),
              ),
              GoRoute(
                path: 'reports/sync-analytics',
                name: 'reports_sync_analytics',
                builder: (context, state) =>
                    const SyncAnalyticsDashboardScreen(),
              ),
              GoRoute(
                path: 'reports/production',
                name: 'reports_production',
                builder: (context, state) => const ProductionReportScreen(),
              ),
              GoRoute(
                path: 'reports/cutting-yield',
                name: 'reports_cutting_yield',
                builder: (context, state) => const CuttingYieldReportScreen(),
              ),
              GoRoute(
                path: 'reports/waste-analysis',
                name: 'reports_waste_analysis',
                builder: (context, state) => const WasteAnalysisReportScreen(),
              ),
              GoRoute(
                path: 'reports/bhatti',
                name: 'reports_bhatti',
                builder: (context, state) => const BhattiReportScreen(),
              ),
              GoRoute(
                path: 'reports/stock-valuation',
                name: 'reports_stock_valuation',
                builder: (context, state) => const StockValuationReportScreen(),
              ),
              GoRoute(
                path: 'reports/returns',
                name: 'reports_returns',
                builder: (context, state) => const ReturnsReportScreen(),
              ),
              GoRoute(
                path: 'reports/gst',
                name: 'reports_gst',
                builder: (context, state) => const GstReportScreen(),
              ),
              GoRoute(
                path: 'reports/financial',
                name: 'reports_financial',
                builder: (context, state) => const FinancialReportScreen(),
              ),

              GoRoute(
                path: 'reports/salesman',
                name: 'reports_salesman',
                builder: (context, state) => const SalesmanReportScreen(),
              ),
              GoRoute(
                path: 'reports/maintenance',
                name: 'reports_maintenance',
                builder: (context, state) => const MaintenanceReportScreen(),
              ),
              GoRoute(
                path: 'reports/tyre',
                name: 'reports_tyre',
                builder: (context, state) => const TyreReportScreen(),
              ),
              GoRoute(
                path: 'reports/diesel',
                name: 'reports_diesel',
                builder: (context, state) => const DieselReportScreen(),
              ),
              GoRoute(
                path: 'reports/tally-export',
                name: 'reports_tally_export',
                builder: (context, state) => const TallyExportReportScreen(),
              ),
              GoRoute(
                path: 'location',
                name: 'location_maps',
                redirect: (context, state) {
                  final user = authProvider.currentUser;
                  if (user == null) {
                    return '/dashboard/coming-soon';
                  }
                  final role = user.role;
                  if (permissionService.canAccessMapPathForRole(
                    role,
                    '/dashboard/map-view/route-planner',
                  )) {
                    return '/dashboard/map-view/route-planner';
                  }
                  if (permissionService.canAccessMapPathForRole(
                    role,
                    '/dashboard/gps',
                  )) {
                    return '/dashboard/gps';
                  }
                  if (permissionService.canAccessMapPathForRole(
                    role,
                    '/dashboard/map-view/customers',
                  )) {
                    return '/dashboard/map-view/customers';
                  }
                  return '/dashboard/coming-soon';
                },
              ),
              GoRoute(
                path: 'map-view',
                name: 'map_view_root',
                redirect: (context, state) {
                  final user = authProvider.currentUser;
                  if (user == null) {
                    return '/dashboard/coming-soon';
                  }
                  final role = user.role;
                  if (permissionService.canAccessMapPathForRole(
                    role,
                    '/dashboard/map-view/route-planner',
                  )) {
                    return '/dashboard/map-view/route-planner';
                  }
                  if (permissionService.canAccessMapPathForRole(
                    role,
                    '/dashboard/gps',
                  )) {
                    return '/dashboard/gps';
                  }
                  if (permissionService.canAccessMapPathForRole(
                    role,
                    '/dashboard/map-view/customers',
                  )) {
                    return '/dashboard/map-view/customers';
                  }
                  return '/dashboard/coming-soon';
                },
              ),
              GoRoute(
                path: 'gps',
                name: 'gps_tracking',
                builder: (context, state) => const GPSTrackingScreen(),
              ),
              GoRoute(
                path: 'sales',
                name: 'sales_history',
                builder: (context, state) => const SalesHistoryScreen(),
              ),
              GoRoute(
                path: 'map-view/customers',
                name: 'customers_map',
                builder: (context, state) => const CustomersMapScreen(),
              ),
              GoRoute(
                path: 'map-view/route-planner',
                name: 'route_planner',
                builder: (context, state) => const RoutePlannerScreen(),
              ),
              GoRoute(
                path: 'payments',
                name: 'payments',
                builder: (context, state) => const PaymentsScreen(),
              ),
              GoRoute(
                path: 'payments/add',
                name: 'payments_add',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return AddPaymentScreen(
                    initialCustomerId: extra?['customerId'],
                    initialCustomerName: extra?['customerName'],
                  );
                },
              ),
              GoRoute(
                path: 'salesman-inventory',
                name: 'salesman_inventory',
                builder: (context, state) => const MyStockScreen(),
              ),
              GoRoute(
                path: 'salesman-target-analysis',
                name: 'salesman_target_analysis',
                builder: (context, state) =>
                    const TargetAchievementReportScreen(),
              ),
              GoRoute(
                path: 'salesman-performance',
                name: 'salesman_performance',
                builder: (context, state) => const MyPerformanceScreen(),
              ),

              GoRoute(
                path: 'salesman-profile',
                name: 'salesman_profile',
                builder: (context, state) {
                  final user = authProvider.state.user;
                  return UserProfileScreen(user: user);
                },
              ),
              GoRoute(
                path: 'salesman-customers',
                redirect: (context, state) =>
                    '/dashboard/business-partners?tab=1',
              ),
              GoRoute(
                path: 'management',
                name: 'management',
                builder: (context, state) => const ManagementModuleScreen(),
              ),
              // Moved to Settings
              GoRoute(
                path: 'management/users',
                redirect: (context, state) => '/dashboard/settings/users',
              ),
              GoRoute(
                path: 'management/products',
                name: 'management_products',
                builder: (context, state) {
                  final type = state.uri.queryParameters['type'];
                  return ProductsManagementScreen(
                    initialTypeFilter: type,
                    isMasterDataMode: true,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'management_product_new',
                    builder: (context, state) {
                      final type = state.uri.queryParameters['type'];
                      final supplierId =
                          state.uri.queryParameters['supplierId'];
                      final supplierName =
                          state.uri.queryParameters['supplierName'];

                      Product? product;
                      if (state.extra is Product) {
                        product = state.extra as Product;
                      }

                      final readOnly =
                          state.uri.queryParameters['readOnly'] == 'true';
                      return ProductAddEditScreen(
                        productType: type,
                        product: product,
                        supplierId: supplierId,
                        supplierName: supplierName,
                        isReadOnly: readOnly,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'management/formulas',
                name: 'management_formulas',
                builder: (context, state) => const FormulasManagementScreen(),
              ),

              GoRoute(
                path: 'management/master-data',
                name: 'management_master_data',
                builder: (context, state) => const MasterDataScreen(),
              ),
              GoRoute(
                path: 'management/system-masters',
                name: 'management_system_masters',
                builder: (context, state) => const SystemMastersScreen(),
              ),
              GoRoute(
                path: 'management/incentives',
                redirect: (context, state) => '/dashboard/settings/incentives',
              ),
              GoRoute(
                path: 'management/sales-targets',
                redirect: (context, state) =>
                    '/dashboard/settings/sales-targets',
              ),
              GoRoute(
                path: 'management/departments',
                redirect: (context, state) => '/dashboard/settings/departments',
              ),
              GoRoute(
                path: 'business-partners',
                name: 'business_partners',
                builder: (context, state) {
                  final tab = state.uri.queryParameters['tab'];
                  int index = 0;
                  if (tab != null) index = int.tryParse(tab) ?? 0;
                  return BusinessPartnersScreen(initialTabIndex: index);
                },
              ),
              GoRoute(
                path: 'hr',
                name: 'hr_dashboard',
                builder: (context, state) => const HrDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'employees',
                    name: 'hr_employee_list',
                    builder: (context, state) => const EmployeeListScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: 'hr_employee_add',
                        builder: (context, state) =>
                            const AddEditEmployeeScreen(),
                      ),
                      GoRoute(
                        path: ':employeeId/edit',
                        name: 'hr_employee_edit',
                        builder: (context, state) {
                          final id = state.pathParameters['employeeId'];
                          return AddEditEmployeeScreen(employeeId: id);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'attendance',
                    name: 'hr_attendance',
                    builder: (context, state) => const AttendanceSheetScreen(),
                  ),
                  GoRoute(
                    path: 'payroll',
                    name: 'hr_payroll',
                    builder: (context, state) =>
                        const PayrollManagementScreen(),
                  ),
                  GoRoute(
                    path: 'leave-approval',
                    name: 'hr_leave_approval',
                    builder: (context, state) => const LeaveApprovalScreen(),
                  ),
                  GoRoute(
                    path: 'leave-request',
                    name: 'hr_leave_request',
                    builder: (context, state) {
                      final employeeId =
                          (state.uri.queryParameters['employeeId'] ??
                                  authProvider.currentUser?.id ??
                                  '')
                              .trim();
                      if (employeeId.isEmpty) {
                        return const HrDashboardScreen();
                      }
                      return LeaveRequestScreen(employeeId: employeeId);
                    },
                  ),
                  GoRoute(
                    path: 'leave-history',
                    name: 'hr_leave_history',
                    builder: (context, state) {
                      final employeeId =
                          (state.uri.queryParameters['employeeId'] ??
                                  authProvider.currentUser?.id ??
                                  '')
                              .trim();
                      if (employeeId.isEmpty) {
                        return const HrDashboardScreen();
                      }
                      return LeaveHistoryScreen(employeeId: employeeId);
                    },
                  ),
                  GoRoute(
                    path: 'advance-approval',
                    name: 'hr_advance_approval',
                    builder: (context, state) => const AdvanceApprovalScreen(),
                  ),
                  GoRoute(
                    path: 'advance-request',
                    name: 'hr_advance_request',
                    builder: (context, state) {
                      final empId = state.uri.queryParameters['employeeId'];
                      return AdvanceRequestScreen(employeeId: empId);
                    },
                  ),
                  GoRoute(
                    path: 'performance-reviews',
                    name: 'hr_performance_list',
                    builder: (context, state) =>
                        const PerformanceReviewListScreen(),
                  ),
                  GoRoute(
                    path: 'documents',
                    name: 'hr_document_list',
                    builder: (context, state) => const DocumentListScreen(),
                  ),
                  GoRoute(
                    path: 'holidays',
                    name: 'hr_holidays',
                    builder: (context, state) =>
                        const HolidayManagementScreen(),
                  ),
                ],
              ),
              // Redirects
              GoRoute(
                path: 'customers',
                redirect: (context, state) =>
                    '/dashboard/business-partners?tab=1',
              ),
              GoRoute(
                path: 'procurement/suppliers',
                redirect: (context, state) =>
                    '/dashboard/business-partners?tab=3',
              ),
              GoRoute(
                path: 'procurement/purchase-orders',
                redirect: (context, state) =>
                    '/dashboard/inventory/purchase-orders',
              ),
              GoRoute(
                path: 'management/dealers',
                redirect: (context, state) =>
                    '/dashboard/business-partners?tab=2',
              ),
              GoRoute(
                path: 'inventory',
                redirect: (context, state) =>
                    '/dashboard/inventory/stock-overview',
              ),
              // Manual Vehicle Routes
              GoRoute(
                path: 'vehicles/maintenance/add',
                builder: (context, state) => const AddMaintenanceLogScreen(),
              ),
              GoRoute(
                path: 'vehicles/maintenance/edit',
                builder: (context, state) {
                  final log = state.extra as MaintenanceLog;
                  return AddMaintenanceLogScreen(logToEdit: log);
                },
              ),
              GoRoute(
                path: 'vehicles/add',
                builder: (context, state) => const AddVehicleScreen(),
              ),
              GoRoute(
                path: 'vehicles/detail/:vehicleId',
                builder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId'] ?? '';
                  final vehicle = state.extra as Vehicle?;
                  if (vehicleId.isEmpty) {
                    return const Scaffold(
                      body: Center(child: Text('Error: Invalid Vehicle ID')),
                    );
                  }
                  return VehicleDetailScreen(
                    vehicleId: vehicleId,
                    vehicle: vehicle,
                  );
                },
              ),
              GoRoute(
                path: 'vehicles/diesel/add',
                builder: (context, state) => const AddDieselLogScreen(),
              ),
              GoRoute(
                path: 'vehicles/tyres/add',
                builder: (context, state) => const AddTyreLogScreen(),
              ),
              GoRoute(
                path: 'vehicles/tyres/stock',
                builder: (context, state) => const AddTyreStockInvoiceScreen(),
              ),

              GoRoute(
                path: 'production',
                name: 'production_dashboard',
                builder: (context, state) =>
                    const ProductionDashboardConsolidatedScreen(),
              ),
              GoRoute(
                path: 'tasks',
                name: 'dashboard_tasks_list',
                builder: (context, state) => const TasksScreen(),
                routes: [
                  GoRoute(
                    path: 'history',
                    name: 'dashboard_tasks_history',
                    // LOCKED: Added task history route - 2026-02-02
                    builder: (context, state) => const TaskHistoryScreen(),
                  ),
                ],
              ),
              ...{for (var item in allNavItems) item.href: item}.values
                  .where((item) => item.href != '/dashboard')
                  .where(
                    (item) => !_explicitChildPaths.contains(
                      item.href.replaceAll('/dashboard/', ''),
                    ),
                  )
                  .map((navItem) {
                    return GoRoute(
                      path: navItem.href.replaceAll('/dashboard/', ''),
                      name: navItem.href.substring(1).replaceAll('/', '_'),
                      builder: (context, state) {
                        if (navItem.href == '/dashboard') {
                          final authState = authProvider.state;
                          if (authState.user != null &&
                              RoleAccessMatrix.finalRoleFor(
                                    authState.user!.role,
                                  ) ==
                                  FinalUserRole.salesman) {
                            return const SalesmanDashboardScreen();
                          }
                          return const DashboardScreen();
                        }
                        if (navItem.href == '/dashboard/sales/history') {
                          return const SalesHistoryScreen();
                        }
                        if (navItem.href == '/dashboard/sales/new') {
                          return const NewSaleScreen();
                        }
                        // Removed inventory/stock-overview check as it is now manual
                        if (navItem.href == '/dashboard/reports/production') {
                          return const ReportsModuleScreen();
                        }
                        if (navItem.href == '/dashboard/bhatti') {
                          return const BhattiDashboardScreen();
                        }
                        // Removed bhatti/overview as it is now manual
                        // Removed bhatti/cooking as it is now manual
                        if (navItem.href == '/dashboard/reports/bhatti') {
                          return const BhattiReportScreen();
                        }
                        if (navItem.href ==
                            '/dashboard/inventory/purchase-orders') {
                          return const PurchaseOrdersListScreen();
                        }
                        if (navItem.href == '/dashboard/fuel') {
                          return const FuelLogScreen();
                        }
                        if (navItem.href == '/dashboard/inventory') {
                          return const InventoryOverviewScreen();
                        }
                        if (navItem.href == '/dashboard/vehicles') {
                          return const VehicleManagementScreen();
                        }
                        if (navItem.href == '/dashboard/dispatch') {
                          return DispatchScreen(prefillExtra: state.extra);
                        }
                        if (navItem.href == '/dashboard/customers') {
                          return const CustomerManagementScreen();
                        }
                        if (navItem.href == '/dashboard/returns') {
                          return const ReturnsManagementScreen();
                        }
                        if (navItem.href == '/dashboard/settings') {
                          return const SettingsModuleScreen();
                        }
                        if (navItem.href == '/dashboard/profile') {
                          return const UserProfileScreen();
                        }
                        if (navItem.href == '/dashboard/driver/duty') {
                          return const DriverModuleScreen();
                        }
                        if (navItem.href == '/dashboard/driver/trips') {
                          return const DriverTripsScreen();
                        }
                        if (navItem.href == '/dashboard/production') {
                          return const ProductionDashboardConsolidatedScreen();
                        }
                        if (navItem.href == '/dashboard/production/stock') {
                          final isLowStockOnly =
                              state.uri.queryParameters['filter'] ==
                              'low-stock';
                          return ProductionStockScreen(
                            showLowStockOnly: isLowStockOnly,
                          );
                        }

                        return ComingSoonScreen(
                          title: navItem.label,
                          icon: _getIconForNavItem(navItem),
                          color: _parseGradient(navItem.gradient),
                        );
                      },
                      routes:
                          navItem.submenu
                              ?.where(
                                (subItem) =>
                                    subItem.href.startsWith('${navItem.href}/'),
                              )
                              .where(
                                (subItem) => !_explicitChildPaths.contains(
                                  subItem.href.replaceAll('/dashboard/', ''),
                                ),
                              )
                              .map((subItem) {
                                return GoRoute(
                                  path: subItem.href.replaceFirst(
                                    '${navItem.href}/',
                                    '',
                                  ),
                                  name: subItem.href
                                      .substring(1)
                                      .replaceAll('/', '_'),
                                  builder: (context, state) {
                                    if (subItem.href ==
                                        '/dashboard/inventory/purchase-orders') {
                                      return const PurchaseOrdersListScreen();
                                    }
                                    // Removed inventory checks as they are now manual
                                    if (subItem.href ==
                                        '/dashboard/inventory/adjust') {
                                      return const StockAdjustmentScreen();
                                    }
                                    if (subItem.href ==
                                        '/dashboard/production') {
                                      return const ProductionDashboardConsolidatedScreen();
                                    }
                                    if (subItem.href ==
                                        '/dashboard/production/cutting/entry') {
                                      return const CuttingBatchEntryScreen();
                                    }
                                    if (subItem.href ==
                                        '/dashboard/production/cutting/history') {
                                      return const CuttingHistoryScreen();
                                    }
                                    if (subItem.href ==
                                        '/dashboard/production/stock') {
                                      final isLowStockOnly =
                                          state.uri.queryParameters['filter'] ==
                                          'low-stock';
                                      return ProductionStockScreen(
                                        showLowStockOnly: isLowStockOnly,
                                      );
                                    }
                                    if (subItem.href ==
                                        '/dashboard/dispatch/dashboard') {
                                      return DealerDispatchScreen(
                                        prefillExtra: state.extra,
                                      );
                                    }
                                    if (subItem.href ==
                                        '/dashboard/dispatch/new-trip') {
                                      return const NewTripScreen();
                                    }
                                    if (state.uri.path.startsWith(
                                      '/dashboard/dispatch/trips/',
                                    )) {
                                      final tripId =
                                          state.pathParameters['tripId'] ?? '';
                                      return TripDetailsScreen(tripId: tripId);
                                    }
                                    if (state.uri.path.startsWith(
                                      '/dashboard/production/batch/',
                                    )) {
                                      final batchId =
                                          state.pathParameters['batchId'] ?? '';
                                      return BatchDetailsScreen(
                                        batchId: batchId,
                                      );
                                    }
                                    if (subItem.href ==
                                        '/dashboard/bhatti/daily-logs') {
                                      return const BhattiSupervisorScreen();
                                    }
                                    if (subItem.href ==
                                        '/dashboard/reports/dealer') {
                                      return const DealerReportScreen();
                                    }

                                    // Vehicle Management Routes
                                    if (subItem.href ==
                                        '/dashboard/vehicles/all') {
                                      return const VehicleManagementScreen(
                                        initialTabIndex: 0,
                                      );
                                    }
                                    if (subItem.href ==
                                        '/dashboard/vehicles/maintenance') {
                                      return const VehicleManagementScreen(
                                        initialTabIndex: 1,
                                      );
                                    }
                                    if (subItem.href ==
                                        '/dashboard/vehicles/diesel') {
                                      return const VehicleManagementScreen(
                                        initialTabIndex: 2,
                                      );
                                    }
                                    if (subItem.href ==
                                        '/dashboard/vehicles/tyres') {
                                      return const VehicleManagementScreen(
                                        initialTabIndex: 3,
                                      );
                                    }

                                    return ComingSoonScreen(
                                      title: subItem.label,
                                      icon: _getIconForNavItem(subItem),
                                      color: _parseGradient(subItem.gradient),
                                    );
                                  },
                                );
                              })
                              .toList() ??
                          [],
                    );
                  }),
            ],
          ),
          GoRoute(
            path: '/dashboard/dealer/dashboard',
            name: 'dealer_dashboard',
            builder: (context, state) => const DealerDashboardScreen(),
          ),
          GoRoute(
            path: '/dashboard/dealer/new-sale',
            name: 'dealer_new_sale',
            builder: (context, state) => const NewDealerSaleScreen(),
          ),
          GoRoute(
            path: '/dashboard/dealer/history',
            name: 'dealer_history',
            builder: (context, state) => const SalesHistoryScreen(),
          ),
          GoRoute(
            path: '/dashboard/reports/dealer',
            name: 'dealer_reports',
            builder: (context, state) => const DealerReportScreen(),
          ),
          GoRoute(
            path: '/dashboard/management/dealers',
            name: 'management_dealers',
            builder: (context, state) => const DealersManagementScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

Color? _parseGradient(String? gradient) {
  if (gradient == null) return null;
  if (gradient.contains('blue')) return Colors.blue;
  if (gradient.contains('green')) return Colors.green;
  if (gradient.contains('teal')) return Colors.teal;
  if (gradient.contains('cyan')) return Colors.cyan;
  if (gradient.contains('orange')) return Colors.orange;
  if (gradient.contains('red')) return Colors.red;
  if (gradient.contains('rose')) return Colors.red;
  if (gradient.contains('amber')) return Colors.amber;
  if (gradient.contains('purple')) return Colors.purple;
  if (gradient.contains('indigo')) return Colors.indigo;
  if (gradient.contains('pink')) return Colors.pink;
  if (gradient.contains('slate')) return Colors.blueGrey;
  if (gradient.contains('gray')) return Colors.grey;
  if (gradient.contains('yellow')) return Colors.yellow;
  if (gradient.contains('emerald')) return Colors.green;
  return null;
}

IconData _getIconForNavItem(NavItem navItem) {
  final label = navItem.label.toLowerCase();
  if (label.contains('dashboard')) return Icons.dashboard;
  if (label.contains('procurement') || label.contains('purchase')) {
    return Icons.shopping_cart;
  }
  if (label.contains('inventory')) return Icons.inventory_2;
  if (label.contains('bhatti')) return Icons.local_fire_department;
  if (label.contains('fuel')) return Icons.local_gas_station;
  if (label.contains('vehicle')) return Icons.directions_car;
  if (label.contains('dispatch')) return Icons.local_shipping;
  if (label.contains('customer')) return Icons.people;
  if (label.contains('management')) return Icons.business;
  if (label.contains('report')) return Icons.assessment;
  if (label.contains('return')) return Icons.restore;
  if (label.contains('profile')) return Icons.person;
  if (label.contains('setting')) return Icons.settings;
  if (label.contains('admin')) return Icons.admin_panel_settings;
  if (label.contains('sale')) return Icons.point_of_sale;
  if (label.contains('stock')) return Icons.inventory;
  if (label.contains('task')) return Icons.task;
  if (label.contains('duty')) return Icons.work;
  if (label.contains('route')) return Icons.map;
  if (label.contains('diesel')) return Icons.local_gas_station;
  if (label.contains('trip')) return Icons.history;
  if (label.contains('gps')) return Icons.location_on;
  if (label.contains('payment')) return Icons.payment;
  if (label.contains('mobile')) return Icons.phone_android;
  return Icons.dashboard;
}
