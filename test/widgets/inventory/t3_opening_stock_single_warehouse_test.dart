import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/types/product_types.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/providers/auth/auth_provider.dart';
import 'package:flutter_app/screens/inventory/opening_stock_setup_screen.dart';
import 'package:flutter_app/services/opening_stock_service.dart';
import 'package:flutter_app/services/products_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockOpeningStockService extends Mock implements OpeningStockService {}

class _MockProductsService extends Mock implements ProductsService {}

class _MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late _MockOpeningStockService openingStockService;
  late _MockProductsService productsService;
  late _MockAuthProvider authProvider;

  final testProduct = Product(
    id: 'prod-1',
    name: 'Acid Oil',
    sku: 'AO-001',
    itemType: ProductType.rawMaterial,
    type: ProductTypeEnum.raw,
    category: 'Oils',
    stock: 0,
    baseUnit: 'KG',
    conversionFactor: 1,
    price: 0,
    status: 'active',
    createdAt: DateTime(2026, 3, 7).toIso8601String(),
    unitWeightGrams: 0,
  );

  final testUser = AppUser(
    id: 'user-1',
    name: 'Admin',
    email: 'admin@dattsoap.com',
    role: UserRole.admin,
    departments: const [],
    createdAt: DateTime(2026, 3, 7).toIso8601String(),
  );

  Finder qtyField() => find.byType(TextFormField).at(1);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<OpeningStockService>.value(value: openingStockService),
          Provider<ProductsService>.value(value: productsService),
          ListenableProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(home: OpeningStockSetupScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    openingStockService = _MockOpeningStockService();
    productsService = _MockProductsService();
    authProvider = _MockAuthProvider();

    when(
      () => openingStockService.isSystemLocked(),
    ).thenAnswer((_) async => false);
    when(
      () => productsService.getProducts(),
    ).thenAnswer((_) async => [testProduct]);
    when(() => authProvider.currentUser).thenReturn(testUser);
    when(
      () => openingStockService.createOpeningStock(
        productId: any(named: 'productId'),
        productType: any(named: 'productType'),
        warehouseId: any(named: 'warehouseId'),
        quantity: any(named: 'quantity'),
        unit: any(named: 'unit'),
        openingRate: any(named: 'openingRate'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => openingStockService.getOpeningStock(
        productId: any(named: 'productId'),
        warehouseId: any(named: 'warehouseId'),
      ),
    ).thenAnswer((_) async => null);
  });

  testWidgets(
    'hides warehouse selector and always saves opening stock to Main',
    (tester) async {
      await pumpScreen(tester);

      expect(find.text('Select Warehouse'), findsNothing);
      expect(
        find.byWidgetPredicate((widget) => widget is DropdownButtonFormField),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('opening-stock-main-warehouse')),
        findsOneWidget,
      );
      expect(find.text('Main Warehouse'), findsOneWidget);

      await tester.enterText(qtyField(), '25');
      await tester.tap(find.byIcon(Icons.check_rounded).first);
      await tester.pumpAndSettle();

      verify(
        () => openingStockService.createOpeningStock(
          productId: 'prod-1',
          productType: 'Raw Material',
          warehouseId: 'Main',
          quantity: 25,
          unit: 'KG',
          openingRate: null,
          userId: 'user-1',
        ),
      ).called(1);

      await tester.pump(const Duration(seconds: 3));
    },
  );
}
