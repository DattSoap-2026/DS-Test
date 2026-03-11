import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/constants/nav_items.dart';
import 'package:flutter_app/models/types/user_types.dart';

void main() {
  group('navItemsForRole RBAC filtering', () {
    test(
      'legacy roles keep coming-soon, map visibility is capability-scoped',
      () {
        final driverTop = navItemsForRole(
          UserRole.driver,
          position: NavPosition.top,
        ).map((e) => e.href).toSet();
        expect(
          driverTop,
          containsAll(<String>{
            '/dashboard/coming-soon',
            '/dashboard/location',
          }),
        );

        final salesManagerTop = navItemsForRole(
          UserRole.salesManager,
          position: NavPosition.top,
        ).map((e) => e.href).toSet();
        expect(
          salesManagerTop,
          containsAll(<String>{
            '/dashboard/coming-soon',
            '/dashboard/location',
          }),
        );

        final dispatchManagerTop = navItemsForRole(
          UserRole.dispatchManager,
          position: NavPosition.top,
        ).map((e) => e.href).toSet();
        expect(
          dispatchManagerTop,
          containsAll(<String>{
            '/dashboard/coming-soon',
            '/dashboard/location',
          }),
        );

        final gateKeeperTop = navItemsForRole(
          UserRole.gateKeeper,
          position: NavPosition.top,
        );
        expect(gateKeeperTop, hasLength(1));
        expect(gateKeeperTop.first.href, '/dashboard/coming-soon');
      },
    );

    test('bhatti supervisor sees bhatti workflow and not coming-soon', () {
      final items = navItemsForRole(
        UserRole.bhattiSupervisor,
        position: NavPosition.top,
      );
      final hrefs = items.map((item) => item.href).toSet();

      expect(
        hrefs,
        containsAll(<String>{
          '/dashboard/bhatti/overview',
          '/dashboard/bhatti/cooking',
          '/dashboard/reports/bhatti',
        }),
      );
      expect(hrefs.contains('/dashboard/coming-soon'), isFalse);
    });

    test('specialist roles get active navigation roots', () {
      final accountantTop = navItemsForRole(
        UserRole.accountant,
        position: NavPosition.top,
      ).map((e) => e.href).toSet();
      expect(accountantTop, equals(<String>{'/dashboard/accounting'}));

      final fuelTop = navItemsForRole(
        UserRole.fuelIncharge,
        position: NavPosition.top,
      ).map((e) => e.href).toSet();
      expect(
        fuelTop,
        containsAll(<String>{
          '/dashboard',
          '/dashboard/fuel',
          '/dashboard/reports/diesel',
        }),
      );

      final vehicleTop = navItemsForRole(
        UserRole.vehicleMaintenanceManager,
        position: NavPosition.top,
      ).map((e) => e.href).toSet();
      expect(vehicleTop, equals(<String>{'/dashboard/vehicles'}));

      final productionManagerTop = navItemsForRole(
        UserRole.productionManager,
        position: NavPosition.top,
      ).map((e) => e.href).toSet();
      expect(
        productionManagerTop,
        containsAll(<String>{
          '/dashboard/production',
          '/dashboard/orders/route-management',
        }),
      );
    });

    test(
      'dealer manager navigation exposes dealer workflow (top + bottom)',
      () {
        final topItems = navItemsForRole(
          UserRole.dealerManager,
          position: NavPosition.top,
        );
        final topHrefs = topItems.map((item) => item.href).toSet();
        expect(
          topHrefs,
          containsAll(<String>{
            '/dashboard/dealer/dashboard',
            '/dashboard/dealer/new-sale',
            '/dashboard/dealer/history',
            '/dashboard/business-partners',
            '/dashboard/orders/route-management',
            '/dashboard/reports/dealer',
          }),
        );
        expect(topHrefs.contains('/dashboard/coming-soon'), isFalse);

        final bottomItems = navItemsForRole(
          UserRole.dealerManager,
          position: NavPosition.bottom,
        );
        final bottomHrefs = bottomItems.map((item) => item.href).toSet();
        expect(
          bottomHrefs,
          equals(<String>{
            '/dashboard/dealer/dashboard',
            '/dashboard/dealer/new-sale',
            '/dashboard/business-partners',
            '/dashboard/orders/route-management',
          }),
        );
      },
    );

    test('manager management submenu excludes admin-only entries', () {
      final items = navItemsForRole(
        UserRole.storeIncharge,
        position: NavPosition.top,
      );
      final management = items.firstWhere(
        (item) => item.href == '/dashboard/management',
      );
      final submenuHrefs =
          management.submenu?.map((sub) => sub.href).toList() ?? [];

      expect(submenuHrefs.contains('/dashboard/management/formulas'), isTrue);
      expect(submenuHrefs.contains('/dashboard/management/products'), isFalse);
      expect(
        submenuHrefs.contains('/dashboard/management/master-data'),
        isFalse,
      );
    });

    test('production nav excludes inventory mutate routes', () {
      final items = navItemsForRole(
        UserRole.productionSupervisor,
        position: NavPosition.top,
      );
      final hrefs = <String>{
        for (final item in items) item.href,
        for (final item in items) ...?item.submenu?.map((sub) => sub.href),
      };

      expect(hrefs.contains('/dashboard/inventory/adjust'), isFalse);
      expect(hrefs.contains('/dashboard/inventory/opening-stock'), isFalse);
      expect(hrefs.contains('/dashboard/inventory/purchase-orders'), isFalse);
    });

    test('salesman top navigation does not include reports hub', () {
      final items = navItemsForRole(
        UserRole.salesman,
        position: NavPosition.top,
      );
      expect(items.any((item) => item.href == '/dashboard/reports'), isFalse);
      expect(
        items.any((item) => item.href == '/dashboard/salesman-target-analysis'),
        isTrue,
      );
    });

    test('salesman bottom navigation has no duplicate home/orders links', () {
      final items = navItemsForRole(
        UserRole.salesman,
        position: NavPosition.bottom,
      );
      final hrefs = items.map((item) => item.href).toList(growable: false);
      final uniqueHrefs = hrefs.toSet();

      expect(hrefs.length, uniqueHrefs.length);
      expect(
        uniqueHrefs,
        equals(<String>{
          '/dashboard',
          '/dashboard/salesman-customers',
          '/dashboard/salesman-sales/new',
          '/dashboard/orders/route-management',
          '/dashboard/salesman-inventory',
        }),
      );
    });
  });
}
