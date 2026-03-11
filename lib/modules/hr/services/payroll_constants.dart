/// Constants used in payroll calculations.
class PayrollConstants {
  PayrollConstants._();

  /// Standard hours in a working day
  static const double hoursPerDay = 8.0;

  /// Factor for half-day calculation (0.5 = 50%)
  static const double halfDayFactor = 0.5;

  /// Maximum hours that can be worked in a single day
  static const double maxHoursPerDay = 24.0;

  /// Minimum hours for a valid work session
  static const double minHoursPerSession = 0.0;
}
