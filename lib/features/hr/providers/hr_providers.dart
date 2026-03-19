import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/advance_entity.dart';
import '../../../data/local/entities/attendance_entity.dart';
import '../../../data/local/entities/employee_entity.dart';
import '../../../data/local/entities/holiday_entity.dart';
import '../../../data/local/entities/leave_request_entity.dart';
import '../../../data/repositories/hr_repository.dart';
import '../../../services/database_service.dart';

export '../../../data/repositories/hr_repository.dart';

final hrRepositoryProvider = Provider<HrRepository>((ref) {
  return HrRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final allEmployeesProvider = StreamProvider<List<EmployeeEntity>>((ref) {
  return ref.watch(hrRepositoryProvider).watchAllEmployees();
});

final pendingLeaveRequestsProvider = StreamProvider<List<LeaveRequestEntity>>((
  ref,
) {
  return ref.watch(hrRepositoryProvider).watchPendingLeaveRequests();
});

final pendingAdvancesProvider = StreamProvider<List<AdvanceEntity>>((ref) {
  return ref.watch(hrRepositoryProvider).watchPendingAdvances();
});

final watchAttendanceProvider =
    StreamProvider.family<List<AttendanceEntity>, String>((ref, employeeId) {
      return ref
          .watch(hrRepositoryProvider)
          .watchAttendanceByEmployee(employeeId);
    });

final allHolidaysProvider = StreamProvider<List<HolidayEntity>>((ref) {
  return ref.watch(hrRepositoryProvider).watchAllHolidays();
});

final pendingHRSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.employees,
    CollectionRegistry.attendances,
    CollectionRegistry.leaveRequests,
    CollectionRegistry.advances,
    CollectionRegistry.payrollRecords,
    CollectionRegistry.performanceReviews,
    CollectionRegistry.employeeDocuments,
    CollectionRegistry.holidays,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
