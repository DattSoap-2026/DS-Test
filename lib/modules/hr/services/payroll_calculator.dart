import '../models/employee_model.dart';
import '../../../services/duty_service.dart';
import '../models/attendance_model.dart';
import '../models/holiday_model.dart';
import 'advance_service.dart';
import 'payroll_constants.dart';

/// Calculates payroll for a single employee based on duty sessions and attendance.
class PayrollCalculator {
  /// Calculates the payroll result for a single employee.
  ///
  /// This method handles:
  /// - Hourly vs Monthly salary calculations
  /// - Holiday work compensation (typically 1.5x-2x rate)
  /// - Overtime calculations
  /// - EMI and TDS deductions
  /// - Absent and half-day adjustments
  ///
  /// Parameters:
  /// - [employee]: The employee to calculate payroll for
  /// - [sessions]: Duty sessions (for drivers/salesmen)
  /// - [attendances]: Attendance records for the month
  /// - [totalDaysInMonth]: Total calendar days in the month
  /// - [month]: The month being calculated
  /// - [holidays]: List of holidays in the month
  /// - [advanceService]: Optional service to fetch EMI deductions
  ///
  /// Returns: [CalculationResult] with all salary components
  ///
  /// Throws:
  /// - [ArgumentError] if totalDaysInMonth <= 0
  /// - [ArgumentError] if work hours exceed 24 hours in a day
  static Future<CalculationResult> calculate({
    required Employee employee,
    required List<DutySession> sessions,
    required List<Attendance> attendances,
    required int totalDaysInMonth,
    required DateTime month,
    required List<Holiday> holidays,
    AdvanceService? advanceService,
  }) async {
    double totalTrackedHours = 0.0;
    double totalOvertimeHours = 0.0;
    double netSalary = 0.0;
    double baseSalarySnapshot = 0.0;

    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month, totalDaysInMonth);

    // 1. Calculate Active Days in Month based on Joining/Exit dates
    DateTime effectiveStart = employee.joiningDate.isAfter(firstDayOfMonth)
        ? employee.joiningDate
        : firstDayOfMonth;
    
    DateTime effectiveEnd = employee.exitDate != null && 
                           employee.exitDate!.isBefore(lastDayOfMonth)
        ? employee.exitDate!
        : lastDayOfMonth;

    // Actual days the employee was employed this month
    int activeDays = 0;
    if (effectiveStart.isBefore(effectiveEnd) || effectiveStart.isAtSameMomentAs(effectiveEnd)) {
      activeDays = effectiveEnd.difference(effectiveStart).inDays + 1;
    }
    
    if (activeDays > totalDaysInMonth) activeDays = totalDaysInMonth;
    if (activeDays < 0) activeDays = 0;

    // 2. Identify Holiday Dates for this month
    final holidayDates = holidays.map((h) => 
      '${h.date.year}-${h.date.month.toString().padLeft(2, '0')}-${h.date.day.toString().padLeft(2, '0')}'
    ).toSet();

    // 3. Process Attendance Metrics
    int absentDays = 0;
    int halfDays = 0;
    
    // Track days worked on holidays for potentially higher pay
    double holidayWorkHours = 0.0;
    
    for (var att in attendances) {
      final dateStr = '${att.date.year}-${att.date.month.toString().padLeft(2, '0')}-${att.date.day.toString().padLeft(2, '0')}';
      final isHoliday = holidayDates.contains(dateStr);

      if (att.checkInTime != null && att.checkOutTime != null) {
        final duration = att.checkOutTime!.difference(att.checkInTime!);
        final worked = duration.inMinutes / 60.0;
        
        if (worked > PayrollConstants.maxHoursPerDay) {
          throw ArgumentError('Work hours cannot exceed ${PayrollConstants.maxHoursPerDay} hours in a day for ${att.date}');
        }
        if (worked < PayrollConstants.minHoursPerSession) {
          throw ArgumentError('Check-out time cannot be before check-in time for ${att.date}');
        }
        
        if (isHoliday) {
          holidayWorkHours += worked;
        } else {
          totalTrackedHours += worked;
        }
      }

      if (att.overtimeHours != null) {
        totalOvertimeHours += att.overtimeHours!;
      }

      // If it's a holiday, we DON'T count it as Absent even if status says so
      if (att.status == 'Absent' && !isHoliday) {
        absentDays++;
      } else if (att.status == 'HalfDay') {
        halfDays++;
      }
    }

    // Include sessions (mostly for drivers/salesmen)
    for (var session in sessions) {
      if (session.logoutTime != null) {
        final login = DateTime.parse(session.loginTime);
        final logout = DateTime.parse(session.logoutTime!);
        final duration = logout.difference(login);
        final hours = duration.inMinutes / 60.0;
        
        final dateStr = session.date;
        if (holidayDates.contains(dateStr)) {
          holidayWorkHours += hours;
        } else {
          totalTrackedHours += hours;
        }
      }
    }

    // 4. Calculate Salary
    if (employee.isHourly) {
      baseSalarySnapshot = employee.hourlyRate!;
      // Normal hours
      netSalary = totalTrackedHours * employee.hourlyRate!;
      // Holiday hours (Usually paid 1.5x or 2x, let's use multiplier)
      netSalary += (holidayWorkHours * employee.hourlyRate! * employee.overtimeMultiplier);
      
      // Separate OT (if any tracked via fields)
      if (totalOvertimeHours > 0 && employee.overtimeMultiplier > 1.0) {
        netSalary += (employee.hourlyRate! * totalOvertimeHours * (employee.overtimeMultiplier - 1.0));
      }
    } else if (employee.isMonthly) {
      baseSalarySnapshot = employee.baseMonthlySalary!;
      
      if (totalDaysInMonth <= 0) {
        throw ArgumentError('Invalid totalDaysInMonth: $totalDaysInMonth');
      }
      double dayRate = employee.baseMonthlySalary! / totalDaysInMonth;
      double activeBaseSalary = dayRate * activeDays;
      
      double unpaidDays = absentDays.toDouble() + (halfDays * PayrollConstants.halfDayFactor);
      netSalary = activeBaseSalary - (dayRate * unpaidDays);

      // Add Overtime (normal OT + Holiday Work)
      // For monthly, holiday work is considered extra/overtime
      double baseOtRate = employee.hourlyRate ?? (dayRate / PayrollConstants.hoursPerDay);
      double totalPayableOTHours = totalOvertimeHours + holidayWorkHours;
      
      if (totalPayableOTHours > 0) {
        netSalary += (totalPayableOTHours * baseOtRate * employee.overtimeMultiplier);
      }
    }

    // 5. Deduct EMI
    double emiDeduction = 0.0;
    if (advanceService != null) {
      emiDeduction = await advanceService.getMonthlyEmiDeduction(employee.employeeId);
    }

    // 6. Calculate TDS
    double tdsDeduction = 0.0;
    if (employee.isTdsApplicable && employee.tdsPercentage > 0) {
      tdsDeduction = (netSalary * employee.tdsPercentage) / 100;
    }

    // 7. Final Net Salary
    double finalNetSalary = netSalary - emiDeduction - tdsDeduction;

    return CalculationResult(
      totalHours: totalTrackedHours + holidayWorkHours,
      totalOvertimeHours: totalOvertimeHours,
      grossSalary: netSalary,
      emiDeduction: emiDeduction,
      tdsDeduction: tdsDeduction,
      netSalary: finalNetSalary,
      baseSalarySnapshot: baseSalarySnapshot,
    );
  }
}

class CalculationResult {
  final double totalHours;
  final double totalOvertimeHours;
  final double grossSalary;
  final double emiDeduction;
  final double tdsDeduction;
  final double netSalary;
  final double baseSalarySnapshot;

  const CalculationResult({
    required this.totalHours,
    this.totalOvertimeHours = 0.0,
    required this.grossSalary,
    this.emiDeduction = 0.0,
    this.tdsDeduction = 0.0,
    required this.netSalary,
    required this.baseSalarySnapshot,
  });
}

