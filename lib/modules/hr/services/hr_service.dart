import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/employee_model.dart';
import '../../../data/local/entities/employee_entity.dart';
import '../../../data/local/base_entity.dart';
import '../../../services/offline_first_service.dart';

class HrService extends OfflineFirstService with ChangeNotifier {
  @override
  String get localStorageKey => 'local_employees';

  @override
  bool get useIsar => true;

  HrService(super.firebase, super.dbService);

  Map<String, dynamic> _toSyncPayload(EmployeeEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'name': entity.name,
      'roleType': entity.roleType,
      'linkedUserId': entity.linkedUserId,
      'department': entity.department,
      'mobile': entity.mobile,
      'isActive': entity.isActive,
      'createdAt': entity.createdAt.toIso8601String(),
      'weeklyOffDay': entity.weeklyOffDay,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
      'baseMonthlySalary': entity.baseMonthlySalary,
      'hourlyRate': entity.hourlyRate,
      'paymentMethod': entity.paymentMethod,
      'bankDetails': entity.bankDetails,
      'shiftStartHour': entity.shiftStartHour ?? 9,
      'shiftStartMinute': entity.shiftStartMinute ?? 0,
    };
  }

  Future<void> createEmployee(Employee employee) async {
    try {
      final entity = EmployeeEntity.fromDomain(employee);
      entity.syncStatus = SyncStatus.pending;
      entity.updatedAt = DateTime.now();

      await dbService.db.writeTxn(() async {
        await dbService.employees.put(entity);
      });

      await syncToFirebase('set', _toSyncPayload(entity),
          collectionName: 'employees');
      notifyListeners();
    } catch (e) {
      handleError(e, 'createEmployee');
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      final entity = EmployeeEntity.fromDomain(employee);
      entity.updatedAt = DateTime.now();
      entity.syncStatus = SyncStatus.pending;

      await dbService.db.writeTxn(() async {
        await dbService.employees.put(entity);
      });

      await syncToFirebase('update', _toSyncPayload(entity),
          collectionName: 'employees');
      notifyListeners();
    } catch (e) {
      handleError(e, 'updateEmployee');
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      final local = await dbService.employees
          .filter()
          .employeeIdEqualTo(employeeId)
          .findFirst();

      if (local != null) {
        await dbService.db.writeTxn(() async {
          local.isDeleted = true;
          local.updatedAt = DateTime.now();
          local.syncStatus = SyncStatus.pending;
          await dbService.employees.put(local);
        });

        await syncToFirebase('delete', {'id': employeeId},
            collectionName: 'employees');
        notifyListeners();
      }
    } catch (e) {
      handleError(e, 'deleteEmployee');
    }
  }

  Future<Employee?> getEmployee(String id) async {
    try {
      final local = await dbService.employees
          .filter()
          .employeeIdEqualTo(id)
          .findFirst();
      if (local != null && !local.isDeleted) return local.toDomain();

      // In Offline-First, we don't fetch from remote on single GET if missing
      // unless it's a critical path. Usually we rely on bulk sync.
      return null;
    } catch (e) {
      handleError(e, 'getEmployee');
      return null;
    }
  }

  Future<Employee?> getEmployeeByUserId(String userId) async {
    try {
      final local = await dbService.employees
          .filter()
          .linkedUserIdEqualTo(userId)
          .findFirst();
      if (local != null && !local.isDeleted) return local.toDomain();

      return null;
    } catch (e) {
      handleError(e, 'getEmployeeByUserId');
      return null;
    }
  }

  Future<List<Employee>> getAllEmployees({bool forceRefresh = false}) async {
    try {
      final locals = await dbService.employees.where().findAll();
      final activeLocals = locals.where((e) => !e.isDeleted).toList();

      if (activeLocals.isNotEmpty && !forceRefresh) {
        return activeLocals.map((e) => e.toDomain()).toList();
      }

      // If forceRefresh or empty local, we bootstrap but non-blocking usually.
      // For ERP, we can do a blocking fetch if explicitly requested.
      if (forceRefresh) {
        final items =
            await bootstrapFromFirebase(collectionName: 'employees');
        if (items.isNotEmpty) {
          await dbService.db.writeTxn(() async {
            for (var item in items) {
              final model = Employee.fromMap(item);
              final entity = EmployeeEntity.fromDomain(model);
              entity.syncStatus = SyncStatus.synced;
              await dbService.employees.put(entity);
            }
          });
          // Re-fetch formatted locals
          final reLocals = await dbService.employees.where().findAll();
          return reLocals
              .where((e) => !e.isDeleted)
              .map((e) => e.toDomain())
              .toList();
        }
      }

      return activeLocals.map((e) => e.toDomain()).toList();
    } catch (e) {
      handleError(e, 'getAllEmployees');
      return [];
    }
  }
}
