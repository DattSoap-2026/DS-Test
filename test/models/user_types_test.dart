import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/types/user_types.dart';

void main() {
  group('AppUser.isFullyConfigured', () {
    const authEmail = 'test@example.com';

    test('should return true for a fully configured user', () {
      final user = AppUser(
        id: '1',
        name: 'Test User',
        email: authEmail,
        role: UserRole.salesman,
        department: 'Sales',
        departments: [],
        status: 'active',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isTrue);
    });

    test('should return false if name is empty', () {
      final user = AppUser(
        id: '1',
        name: '',
        email: authEmail,
        role: UserRole.salesman,
        department: 'Sales',
        departments: [],
        status: 'active',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isFalse);
    });

    test('should return false if email mismatch', () {
      final user = AppUser(
        id: '1',
        name: 'Test User',
        email: 'wrong@example.com',
        role: UserRole.salesman,
        department: 'Sales',
        departments: [],
        status: 'active',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isFalse);
    });

    test('should return false if status is not active', () {
      final user = AppUser(
        id: '1',
        name: 'Test User',
        email: authEmail,
        role: UserRole.salesman,
        department: 'Sales',
        departments: [],
        status: 'inactive',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isFalse);
    });

    test('should return false if department is missing', () {
      final user = AppUser(
        id: '1',
        name: 'Test User',
        email: authEmail,
        role: UserRole.salesman,
        department: null,
        departments: [],
        status: 'active',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isFalse);
    });

    test('should return true for admin even if department is missing', () {
      final user = AppUser(
        id: '1',
        name: 'Admin User',
        email: authEmail,
        role: UserRole.admin,
        department: null,
        departments: [],
        status: 'pending',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isTrue);
    });

    test('should return true for owner even if department is missing', () {
      final user = AppUser(
        id: '1',
        name: 'Owner User',
        email: authEmail,
        role: UserRole.owner,
        department: null,
        departments: [],
        status: 'active',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isTrue);
    });

    test('should return false if bhatti supervisor has no assigned bhatti', () {
      final user = AppUser(
        id: '1',
        name: 'Bhatti User',
        email: authEmail,
        role: UserRole.bhattiSupervisor,
        department: 'Bhatti',
        departments: [],
        assignedBhatti: null,
        status: 'active',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isFalse);
    });

    test('should return true if bhatti supervisor has assigned bhatti', () {
      final user = AppUser(
        id: '1',
        name: 'Bhatti User',
        email: authEmail,
        role: UserRole.bhattiSupervisor,
        department: 'Bhatti',
        departments: [],
        assignedBhatti: 'Unit A',
        status: 'active',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(user.isFullyConfigured(authEmail), isTrue);
    });
  });
}
