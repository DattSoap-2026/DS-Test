import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/constants/nav_items.dart';
import 'package:flutter_app/constants/role_access_matrix.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/permission_service.dart';

List<NavItem> _flattenNav(List<NavItem> items) {
  final flat = <NavItem>[];
  for (final item in items) {
    flat.add(item);
    if (item.submenu != null) {
      flat.addAll(_flattenNav(item.submenu!));
    }
  }
  return flat;
}

AppUser _buildUser(UserRole role) {
  return AppUser(
    id: role.name,
    name: role.value,
    email: '${role.name}@test.local',
    role: role,
    departments: const [],
    createdAt: '2026-01-01T00:00:00.000Z',
  );
}

void main() {
  group('Role access matrix', () {
    final permissionService = PermissionService();

    test('each role matrix landing path passes layered permission check', () {
      for (final role in UserRole.values) {
        final user = _buildUser(role);
        final landing = permissionService.landingPathForRole(role);
        final allowed = permissionService.canAccessPathLayered(user, landing);
        expect(
          allowed,
          isTrue,
          reason: 'Landing path blocked for ${role.value}: $landing',
        );
      }
    });

    test('all role-visible nav links pass layered permission check', () {
      for (final role in UserRole.values) {
        final user = _buildUser(role);
        final visibleItems = _flattenNav(navItemsForRole(role));
        final blocked = <String>[];

        for (final item in visibleItems) {
          if (!permissionService.canAccessPathLayered(user, item.href)) {
            blocked.add(item.href);
          }
        }

        expect(
          blocked,
          isEmpty,
          reason:
              'Role ${role.value} has nav links blocked by PermissionService: $blocked',
        );
      }
    });

    test(
      'legacy roles keep coming-soon landing; map access is capability-scoped',
      () {
        const legacyRoles = <UserRole>[
          UserRole.salesManager,
          UserRole.dispatchManager,
          UserRole.driver,
          UserRole.gateKeeper,
        ];

        for (final role in legacyRoles) {
          final user = _buildUser(role);
          expect(
            permissionService.canAccessPathLayered(
              user,
              '/dashboard/coming-soon',
            ),
            isTrue,
          );
          expect(
            permissionService.canAccessPathLayered(
              user,
              '/dashboard/orders/route-management',
            ),
            isFalse,
          );
          expect(
            permissionService.canAccessPathLayered(
              user,
              '/dashboard/production',
            ),
            isFalse,
          );
        }

        expect(
          permissionService.canAccessPathLayered(
            _buildUser(UserRole.dispatchManager),
            '/dashboard/gps',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            _buildUser(UserRole.salesManager),
            '/dashboard/map-view',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            _buildUser(UserRole.salesManager),
            '/dashboard/map-view/route-planner',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            _buildUser(UserRole.driver),
            '/dashboard/gps',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            _buildUser(UserRole.driver),
            '/dashboard/map-view',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            _buildUser(UserRole.driver),
            '/dashboard/map-view/route-planner',
          ),
          isFalse,
        );
        expect(
          permissionService.canAccessPathLayered(
            _buildUser(UserRole.gateKeeper),
            '/dashboard/gps',
          ),
          isFalse,
        );
      },
    );

    test(
      'production/bhatti/fuel/accountant/vehicle roles are active (not legacy)',
      () {
        const activeRoleChecks = <(UserRole, String)>[
          (UserRole.productionManager, '/dashboard/production'),
          (UserRole.bhattiSupervisor, '/dashboard/bhatti/overview'),
          (UserRole.fuelIncharge, '/dashboard/fuel/log'),
          (UserRole.accountant, '/dashboard/accounting'),
          (
            UserRole.vehicleMaintenanceManager,
            '/dashboard/vehicles/maintenance',
          ),
        ];

        for (final (role, activePath) in activeRoleChecks) {
          final user = _buildUser(role);
          expect(
            permissionService.canAccessPathLayered(user, activePath),
            isTrue,
            reason: '$role should access $activePath',
          );
          expect(
            permissionService.canAccessPathLayered(
              user,
              '/dashboard/coming-soon',
            ),
            isFalse,
            reason: '$role should not be locked to coming-soon',
          );
        }
      },
    );

    test(
      'dealer manager routes are accessible and not locked to coming-soon',
      () {
        final dealer = _buildUser(UserRole.dealerManager);

        expect(
          permissionService.canAccessPathLayered(
            dealer,
            '/dashboard/dealer/dashboard',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            dealer,
            '/dashboard/dealer/new-sale',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            dealer,
            '/dashboard/orders/route-management',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            dealer,
            '/dashboard/settings/alerts',
          ),
          isTrue,
        );
        expect(
          permissionService.canAccessPathLayered(
            dealer,
            '/dashboard/coming-soon',
          ),
          isFalse,
        );
      },
    );

    test('production inventory access is explicit and view-only scoped', () {
      final user = _buildUser(UserRole.productionSupervisor);

      const allow = <String>[
        '/dashboard/inventory',
        '/dashboard/inventory/stock-overview',
        '/dashboard/inventory/tanks',
        '/dashboard/production/stock',
      ];
      const deny = <String>[
        '/dashboard/inventory/adjust',
        '/dashboard/inventory/opening-stock',
        '/dashboard/inventory/purchase-orders',
        '/dashboard/inventory/purchase-orders/new',
      ];

      for (final path in allow) {
        expect(
          permissionService.canAccessPathLayered(user, path),
          isTrue,
          reason: 'Production must read inventory path $path',
        );
      }
      for (final path in deny) {
        expect(
          permissionService.canAccessPathLayered(user, path),
          isFalse,
          reason: 'Production must not mutate inventory path $path',
        );
      }
    });

    test('report access is explicitly enumerated per final role', () {
      final admin = _buildUser(UserRole.admin);
      final manager = _buildUser(UserRole.storeIncharge);
      final production = _buildUser(UserRole.productionSupervisor);
      final salesman = _buildUser(UserRole.salesman);

      const reportPaths = <String>[
        '/dashboard/reports',
        '/dashboard/reports/stock-ledger',
        '/dashboard/reports/stock-movement',
        '/dashboard/reports/production',
        '/dashboard/reports/cutting-yield',
        '/dashboard/reports/waste-analysis',
        '/dashboard/reports/financial',
      ];

      for (final path in reportPaths) {
        expect(permissionService.canAccessPathLayered(admin, path), isTrue);
      }

      expect(
        permissionService.canAccessPathLayered(
          manager,
          '/dashboard/reports/stock-ledger',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          manager,
          '/dashboard/reports/stock-movement',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          manager,
          '/dashboard/reports/production',
        ),
        isFalse,
      );
      expect(
        permissionService.canAccessPathLayered(
          manager,
          '/dashboard/reports/financial',
        ),
        isFalse,
      );

      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/reports/production',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/reports/cutting-yield',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/reports/waste-analysis',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/reports/stock-ledger',
        ),
        isFalse,
      );

      for (final path in reportPaths) {
        expect(
          permissionService.canAccessPathLayered(salesman, path),
          isFalse,
          reason: 'Salesman must not access reports path $path',
        );
      }
    });

    test(
      'management formulas capability has explicit edit/delete boundaries',
      () {
        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.admin,
            RoleCapability.formulasView,
          ),
          isTrue,
        );
        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.admin,
            RoleCapability.formulasEdit,
          ),
          isTrue,
        );
        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.admin,
            RoleCapability.formulasDelete,
          ),
          isTrue,
        );

        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.storeIncharge,
            RoleCapability.formulasView,
          ),
          isTrue,
        );
        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.storeIncharge,
            RoleCapability.formulasEdit,
          ),
          isTrue,
        );
        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.storeIncharge,
            RoleCapability.formulasDelete,
          ),
          isFalse,
        );

        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.productionSupervisor,
            RoleCapability.formulasView,
          ),
          isFalse,
        );
        expect(
          RoleAccessMatrix.hasCapability(
            UserRole.salesman,
            RoleCapability.formulasView,
          ),
          isFalse,
        );
      },
    );
  });
}
