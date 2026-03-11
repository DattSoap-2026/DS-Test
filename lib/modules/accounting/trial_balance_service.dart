import 'voucher_repository.dart';

class TrialBalanceLine {
  final String accountCode;
  final String accountName;
  final double totalDebit;
  final double totalCredit;

  TrialBalanceLine({
    required this.accountCode,
    required this.accountName,
    required this.totalDebit,
    required this.totalCredit,
  });
}

class TrialBalanceResult {
  final List<TrialBalanceLine> lines;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;

  TrialBalanceResult({
    required this.lines,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });
}

class TrialBalanceService {
  final VoucherRepository _voucherRepository;

  TrialBalanceService(this._voucherRepository);

  Future<TrialBalanceResult> generateTrialBalance({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final entries = await _voucherRepository.getVoucherEntries(
      fromDate: fromDate,
      toDate: toDate,
    );
    return calculateFromEntries(entries, fromDate: fromDate, toDate: toDate);
  }

  static TrialBalanceResult calculateFromEntries(
    List<Map<String, dynamic>> entries, {
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final map = <String, TrialBalanceLine>{};
    double totalDebit = 0;
    double totalCredit = 0;

    for (final entry in entries) {
      if (entry['isDeleted'] == true) continue;
      final postingDateRaw =
          entry['postingDate']?.toString() ?? entry['date']?.toString();
      if (postingDateRaw != null && postingDateRaw.isNotEmpty) {
        final postingDate = DateTime.tryParse(postingDateRaw);
        if (postingDate != null) {
          if (fromDate != null && postingDate.isBefore(fromDate)) continue;
          if (toDate != null && postingDate.isAfter(toDate)) continue;
        }
      }

      final accountCode = (entry['accountCode'] ?? '').toString();
      if (accountCode.isEmpty) continue;
      final accountName =
          (entry['accountName'] ?? accountCode).toString().trim().isEmpty
          ? accountCode
          : entry['accountName'].toString();

      final debit = _toDouble(entry['debit']);
      final credit = _toDouble(entry['credit']);

      totalDebit += debit;
      totalCredit += credit;

      final current = map[accountCode];
      if (current == null) {
        map[accountCode] = TrialBalanceLine(
          accountCode: accountCode,
          accountName: accountName,
          totalDebit: debit,
          totalCredit: credit,
        );
      } else {
        map[accountCode] = TrialBalanceLine(
          accountCode: current.accountCode,
          accountName: current.accountName,
          totalDebit: current.totalDebit + debit,
          totalCredit: current.totalCredit + credit,
        );
      }
    }

    final lines = map.values.toList()
      ..sort((a, b) => a.accountName.compareTo(b.accountName));

    return TrialBalanceResult(
      lines: lines,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      isBalanced: (totalDebit - totalCredit).abs() <= 0.01,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
