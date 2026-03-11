import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/constants/role_access_matrix.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/permission_service.dart';

void main() {
  group('PermissionService baseline enforcement', () {
    final service = PermissionService();

    test('admin can access accounting path', () {
      final user = AppUser(
        id: 'u1',
        name: 'Admin',
        email: 'admin@test.com',
        role: UserRole.admin,
        departments: const [],
        createdAt: '2026-01-01T00:00:00.000Z',
      );
      expect(
        service.canAccessPathLayered(user, '/dashboard/accounting'),
        isTrue,
      );
    });

    test('salesman cannot access accounting path', () {
      final user = AppUser(
        id: 'u2',
        name: 'Salesman',
        email: 's@test.com',
        role: UserRole.salesman,
        departments: const [],
        createdAt: '2026-01-01T00:00:00.000Z',
      );
      expect(
        service.canAccessPathLayered(
          user,
          '/dashboard/accounting/vouchers/sales',
        ),
        isFalse,
      );
    });
  });

  group('PermissionService role scope hardening', () {
    final service = PermissionService();

    AppUser buildUser(UserRole role) => AppUser(
      id: role.name,
      name: role.value,
      email: '${role.name}@test.com',
      role: role,
      departments: const [],
      createdAt: '2026-01-01T00:00:00.000Z',
    );

    test('legacy roles cannot access operational modules', () {
      const roles = [
        UserRole.driver,
        UserRole.salesManager,
        UserRole.dispatchManager,
        UserRole.gateKeeper,
      ];

      for (final role in roles) {
        final user = buildUser(role);
        expect(
          service.canAccessPathLayered(user, '/dashboard/production'),
          isFalse,
          reason: '$role should not access production',
        );
        expect(
          service.canAccessPathLayered(user, '/dashboard/dispatch'),
          isFalse,
          reason: '$role should not access dispatch',
        );
        expect(
          service.canAccessPathLayered(user, '/dashboard/coming-soon'),
          isTrue,
          reason: '$role should access coming-soon',
        );
      }
    });

    test(
      'specialist roles have active module access and no coming-soon lock',
      () {
        const activeRoles = <(UserRole, String)>[
          (UserRole.productionManager, '/dashboard/production'),
          (UserRole.bhattiSupervisor, '/dashboard/bhatti/cooking'),
          (UserRole.fuelIncharge, '/dashboard/fuel/history'),
          (UserRole.accountant, '/dashboard/accounting'),
          (
            UserRole.vehicleMaintenanceManager,
            '/dashboard/vehicles/maintenance',
          ),
        ];

        for (final (role, activePath) in activeRoles) {
          final user = buildUser(role);
          expect(
            service.canAccessPathLayered(user, activePath),
            isTrue,
            reason: '$role should access $activePath',
          );
          expect(
            service.canAccessPathLayered(user, '/dashboard/coming-soon'),
            isFalse,
            reason: '$role should not access coming-soon',
          );
        }
      },
    );

    test('production report and inventory restrictions are enforced', () {
      final user = buildUser(UserRole.productionSupervisor);
      expect(
        service.canAccessPathLayered(user, '/dashboard/reports/production'),
        isTrue,
      );
      expect(
        service.canAccessPathLayered(user, '/dashboard/reports/stock-ledger'),
        isFalse,
      );
      expect(
        service.canAccessPathLayered(
          user,
          '/dashboard/inventory/stock-overview',
        ),
        isTrue,
      );
      expect(
        service.canAccessPathLayered(user, '/dashboard/inventory/adjust'),
        isFalse,
      );
    });

    test(
      'manager formulas access allows edit but blocks delete capability',
      () {
        expect(
          service.hasCapabilityForRole(
            UserRole.storeIncharge,
            RoleCapability.formulasView,
          ),
          isTrue,
        );
        expect(
          service.hasCapabilityForRole(
            UserRole.storeIncharge,
            RoleCapability.formulasEdit,
          ),
          isTrue,
        );
        expect(
          service.hasCapabilityForRole(
            UserRole.storeIncharge,
            RoleCapability.formulasDelete,
          ),
          isFalse,
        );
      },
    );

    test('route order capability split is explicit', () {
      expect(
        service.hasCapabilityForRole(
          UserRole.admin,
          RoleCapability.routeOrdersStructuralModify,
        ),
        isTrue,
      );
      expect(
        service.hasCapabilityForRole(
          UserRole.storeIncharge,
          RoleCapability.routeOrdersStructuralModify,
        ),
        isFalse,
      );
      expect(
        service.hasCapabilityForRole(
          UserRole.productionSupervisor,
          RoleCapability.routeOrdersMarkReady,
        ),
        isTrue,
      );
      expect(
        service.hasCapabilityForRole(
          UserRole.salesman,
          RoleCapability.routeOrdersCreate,
        ),
        isTrue,
      );
    });

    test('report home path mapping follows frozen final roles', () {
      expect(
        service.reportHomePathForRole(UserRole.admin),
        '/dashboard/reports',
      );
      expect(
        service.reportHomePathForRole(UserRole.owner),
        '/dashboard/reports',
      );
      expect(
        service.reportHomePathForRole(UserRole.storeIncharge),
        '/dashboard/reports/stock-ledger',
      );
      expect(
        service.reportHomePathForRole(UserRole.productionSupervisor),
        '/dashboard/reports/production',
      );
      expect(
        service.reportHomePathForRole(UserRole.productionManager),
        '/dashboard/reports/production',
      );
      expect(
        service.reportHomePathForRole(UserRole.bhattiSupervisor),
        '/dashboard/reports/bhatti',
      );
      expect(service.reportHomePathForRole(UserRole.salesman), '/dashboard');
      expect(
        service.reportHomePathForRole(UserRole.dealerManager),
        '/dashboard/reports/dealer',
      );
      expect(
        service.reportHomePathForRole(UserRole.accountant),
        '/dashboard/accounting',
      );
      expect(
        service.reportHomePathForRole(UserRole.fuelIncharge),
        '/dashboard/reports/diesel',
      );
      expect(
        service.reportHomePathForRole(UserRole.vehicleMaintenanceManager),
        '/dashboard/vehicles',
      );
      expect(
        service.reportHomePathForRole(UserRole.driver),
        '/dashboard/coming-soon',
      );
    });
  });
}
