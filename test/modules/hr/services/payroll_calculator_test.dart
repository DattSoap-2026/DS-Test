import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/modules/hr/services/payroll_calculator.dart';
import 'package:flutter_app/modules/hr/models/employee_model.dart';
import 'package:flutter_app/services/duty_service.dart';

void main() {
  group('PayrollCalculator Tests', () {
    test('Calculates hourly salary correctly', () async {
      final employee = Employee(
        employeeId: '1',
        name: 'Test',
        roleType: 'Worker',
        hourlyRate: 100,
        department: 'Production',
        mobile: '1234567890',
        createdAt: DateTime.now(),
        joiningDate: DateTime(2024, 2, 1),
      );

      final session1 = DutySession(
        id: '1',
        userId: 'user1',
        userName: 'Test',
        userRole: 'Worker',
        status: 'completed',
        date: '2024-02-01',
        loginTime: '2024-02-01T09:00:00',
        loginLatitude: 0.0,
        loginLongitude: 0.0,
        gpsEnabled: true,
        alerts: [],
        createdAt: '2024-02-01T09:00:00',
        updatedAt: '2024-02-01T17:00:00',
        logoutTime: '2024-02-01T17:00:00', // 8 hours
      );

      final session2 = DutySession(
        id: '2',
        userId: 'user1',
        userName: 'Test',
        userRole: 'Worker',
        status: 'completed',
        date: '2024-02-02',
        loginTime: '2024-02-02T09:00:00',
        loginLatitude: 0.0,
        loginLongitude: 0.0,
        gpsEnabled: true,
        alerts: [],
        createdAt: '2024-02-02T09:00:00',
        updatedAt: '2024-02-02T13:00:00',
        logoutTime: '2024-02-02T13:00:00', // 4 hours
      );

      final result = await PayrollCalculator.calculate(
        employee: employee,
        sessions: [session1, session2],
        attendances: [],
        totalDaysInMonth: 30,
        month: DateTime(2024, 2),
        holidays: [],
      );

      expect(result.totalHours, 12.0);
      expect(result.netSalary, 1200.0);
      expect(result.baseSalarySnapshot, 100.0);
    });

    test('Calculates monthly salary correctly', () async {
      final employee = Employee(
        employeeId: '2',
        name: 'Manager',
        roleType: 'Manager',
        baseMonthlySalary: 50000,
        department: 'Management',
        mobile: '9876543210',
        createdAt: DateTime.now(),
        joiningDate: DateTime(2024, 2, 1),
      );

      final session1 = DutySession(
        id: '1',
        userId: 'user2',
        userName: 'Manager',
        userRole: 'Manager',
        status: 'completed',
        date: '2024-02-01',
        loginTime: '2024-02-01T09:00:00',
        loginLatitude: 0.0,
        loginLongitude: 0.0,
        gpsEnabled: true,
        alerts: [],
        createdAt: '2024-02-01T09:00:00',
        updatedAt: '2024-02-01T17:00:00',
        logoutTime: '2024-02-01T17:00:00', // 8 hours
      );

      final result = await PayrollCalculator.calculate(
        employee: employee,
        sessions: [session1],
        attendances: [],
        totalDaysInMonth: 30,
        month: DateTime(2024, 2),
        holidays: [],
      );

      expect(result.totalHours, 8.0);
      expect(result.netSalary, 50000.0);
      expect(result.baseSalarySnapshot, 50000.0);
    });

    test('Calculates zero if no rate/salary set', () async {
      final employee = Employee(
        employeeId: '3',
        name: 'Intern',
        roleType: 'Intern',
        department: 'HR',
        mobile: '5555555555',
        createdAt: DateTime.now(),
        joiningDate: DateTime(2024, 2, 1),
      );

      final session1 = DutySession(
        id: '1',
        userId: 'user3',
        userName: 'Intern',
        userRole: 'Intern',
        status: 'completed',
        date: '2024-02-01',
        loginTime: '2024-02-01T09:00:00',
        loginLatitude: 0.0,
        loginLongitude: 0.0,
        gpsEnabled: true,
        alerts: [],
        createdAt: '2024-02-01T09:00:00',
        updatedAt: '2024-02-01T17:00:00',
        logoutTime: '2024-02-01T17:00:00', // 8 hours
      );

      final result = await PayrollCalculator.calculate(
        employee: employee,
        sessions: [session1],
        attendances: [],
        totalDaysInMonth: 30,
        month: DateTime(2024, 2),
        holidays: [],
      );

      expect(result.totalHours, 8.0);
      expect(result.netSalary, 0.0);
    });

    test('Handles null logout time gracefully', () async {
      final employee = Employee(
        employeeId: '1',
        name: 'Test',
        hourlyRate: 100,
        roleType: 'Worker',
        department: 'Production',
        mobile: '1234567890',
        createdAt: DateTime.now(),
        joiningDate: DateTime(2024, 2, 1),
      );

      final session1 = DutySession(
        id: '1',
        userId: 'user1',
        userName: 'Test',
        userRole: 'Worker',
        status: 'active',
        date: '2024-02-01',
        loginTime: '2024-02-01T09:00:00',
        loginLatitude: 0.0,
        loginLongitude: 0.0,
        gpsEnabled: true,
        alerts: [],
        createdAt: '2024-02-01T09:00:00',
        updatedAt: '2024-02-01T09:00:00',
        logoutTime: null,
      );

      final result = await PayrollCalculator.calculate(
        employee: employee,
        sessions: [session1],
        attendances: [],
        totalDaysInMonth: 30,
        month: DateTime(2024, 2),
        holidays: [],
      );

      expect(result.totalHours, 0.0);
      expect(result.netSalary, 0.0);
    });
  });
}
