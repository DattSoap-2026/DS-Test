import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/screens/management/formulas_screen.dart';
import 'package:flutter_app/services/formulas_service.dart';

Formula _formulaWithScope(String? assignedBhatti) {
  return Formula(
    id: 'f-1',
    productId: 'p-1',
    productName: 'Semi Base',
    items: const [],
    status: 'completed',
    version: 1,
    wastageConfig: WastageConfig(type: 'qty', value: 0, isReusable: true),
    assignedBhatti: assignedBhatti,
    createdAt: DateTime(2026, 1, 1).toIso8601String(),
    updatedAt: DateTime(2026, 1, 2).toIso8601String(),
  );
}

AppUser _bhattiUser({String? assignedBhatti}) {
  return AppUser(
    id: 'u-1',
    name: 'Bhatti User',
    email: 'bhatti@example.com',
    role: UserRole.bhattiSupervisor,
    assignedBhatti: assignedBhatti,
    departments: const [],
    createdAt: DateTime(2026, 1, 1).toIso8601String(),
  );
}

void main() {
  test('bhatti supervisor sees formula when scope label format differs', () {
    final user = _bhattiUser(assignedBhatti: 'Sona');
    final formula = _formulaWithScope('Sona Bhatti');

    final allowed = canUserViewFormulaInManagement(user: user, formula: formula);

    expect(allowed, isTrue);
  });

  test('bhatti supervisor does not see other bhatti scoped formula', () {
    final user = _bhattiUser(assignedBhatti: 'Sona');
    final formula = _formulaWithScope('Gita Bhatti');

    final allowed = canUserViewFormulaInManagement(user: user, formula: formula);

    expect(allowed, isFalse);
  });

  test('bhatti supervisor sees global and legacy-unscoped formulas', () {
    final user = _bhattiUser(assignedBhatti: 'Gita');

    expect(
      canUserViewFormulaInManagement(
        user: user,
        formula: _formulaWithScope('All'),
      ),
      isTrue,
    );
    expect(
      canUserViewFormulaInManagement(
        user: user,
        formula: _formulaWithScope(null),
      ),
      isTrue,
    );
  });
}
