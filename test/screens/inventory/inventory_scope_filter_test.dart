import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/types/product_types.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/screens/inventory/inventory_overview_screen.dart';
import 'package:flutter_app/utils/unit_scope_utils.dart';

Product _buildProduct({
  String id = 'p-1',
  String? departmentId,
  List<String> allowedDepartmentIds = const [],
}) {
  return Product(
    id: id,
    name: 'Test Product',
    sku: 'SKU-$id',
    itemType: ProductType.rawMaterial,
    type: ProductTypeEnum.raw,
    departmentId: departmentId,
    category: 'Raw',
    stock: 10,
    baseUnit: 'kg',
    conversionFactor: 1,
    price: 100,
    status: 'active',
    createdAt: DateTime(2026, 1, 1).toIso8601String(),
    unitWeightGrams: 0,
    allowedDepartmentIds: allowedDepartmentIds,
  );
}

void main() {
  const sonaScope = UserUnitScope(canViewAll: false, keys: {'sona'});

  test(
    'bhatti supervisor includes unscoped legacy product in restricted unit scope',
    () {
      final product = _buildProduct();

      final allowed = shouldIncludeProductForInventoryScope(
        scope: sonaScope,
        product: product,
        userRole: UserRole.bhattiSupervisor,
      );

      expect(allowed, isTrue);
    },
  );

  test('bhatti supervisor still blocks product scoped to another unit', () {
    final product = _buildProduct(departmentId: 'gita');

    final allowed = shouldIncludeProductForInventoryScope(
      scope: sonaScope,
      product: product,
      userRole: UserRole.bhattiSupervisor,
    );

    expect(allowed, isFalse);
  });

  test('non-bhatti role keeps strict block for unscoped product', () {
    final product = _buildProduct();

    final allowed = shouldIncludeProductForInventoryScope(
      scope: sonaScope,
      product: product,
      userRole: UserRole.productionSupervisor,
    );

    expect(allowed, isFalse);
  });
}
