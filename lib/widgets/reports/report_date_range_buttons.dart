import 'package:flutter/material.dart';

import '../dialogs/responsive_date_pickers.dart';

class ReportDateRangeButtons extends StatelessWidget {
  final DateTimeRange value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTimeRange> onChanged;
  final EdgeInsetsGeometry? margin;

  const ReportDateRangeButtons({
    super.key,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.margin,
  });

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _clampDate(DateTime d) {
    final day = _dateOnly(d);
    final min = _dateOnly(firstDate);
    final max = _dateOnly(lastDate);
    if (day.isBefore(min)) return min;
    if (day.isAfter(max)) return max;
    return day;
  }

  DateTimeRange _normalizeRange(DateTime start, DateTime end) {
    var s = _clampDate(start);
    var e = _clampDate(end);
    if (e.isBefore(s)) {
      e = s;
    }
    return DateTimeRange(start: s, end: e);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localValue = _normalizeRange(value.start, value.end);

    Widget buildButton({
      required String label,
      required Future<void> Function(BuildContext anchorContext) onPressed,
    }) {
      return SizedBox(
        height: 34,
        child: Builder(
          builder: (buttonContext) => OutlinedButton(
            onPressed: () => onPressed(buttonContext),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              textStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(top: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 430;

          final fromButton = buildButton(
            label: 'From',
            onPressed: (_) async {
              final picked = await ResponsiveDatePickers.pickDate(
                context: context,
                initialDate: localValue.start,
                firstDate: firstDate,
                lastDate: localValue.end.isAfter(lastDate)
                    ? lastDate
                    : localValue.end,
                helpText: 'Select From Date',
                confirmText: 'Apply',
              );
              if (picked == null) return;
              onChanged(_normalizeRange(picked, localValue.end));
            },
          );

          final toButton = buildButton(
            label: 'To',
            onPressed: (_) async {
              final picked = await ResponsiveDatePickers.pickDate(
                context: context,
                initialDate: localValue.end,
                firstDate: localValue.start.isBefore(firstDate)
                    ? firstDate
                    : localValue.start,
                lastDate: lastDate,
                helpText: 'Select To Date',
                confirmText: 'Apply',
              );
              if (picked == null) return;
              onChanged(_normalizeRange(localValue.start, picked));
            },
          );

          final monthButton = buildButton(
            label: 'Month',
            onPressed: (anchorContext) async {
              final picked = await ResponsiveDatePickers.pickMonth(
                context: context,
                anchorContext: anchorContext,
                initialDate: localValue.start,
                firstDate: firstDate,
                lastDate: lastDate,
                helpText: 'Select Month',
              );
              if (picked == null) return;
              final monthStart = DateTime(picked.year, picked.month, 1);
              final monthEnd = DateTime(picked.year, picked.month + 1, 0);
              onChanged(_normalizeRange(monthStart, monthEnd));
            },
          );

          final yearButton = buildButton(
            label: 'Year',
            onPressed: (anchorContext) async {
              final picked = await ResponsiveDatePickers.pickYear(
                context: context,
                anchorContext: anchorContext,
                initialDate: localValue.start,
                firstDate: firstDate,
                lastDate: lastDate,
                helpText: 'Select Year',
              );
              if (picked == null) return;
              final yearStart = DateTime(picked.year, 1, 1);
              final yearEnd = DateTime(picked.year, 12, 31);
              onChanged(_normalizeRange(yearStart, yearEnd));
            },
          );

          if (isCompact) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: fromButton),
                    const SizedBox(width: 6),
                    Expanded(child: toButton),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: monthButton),
                    const SizedBox(width: 6),
                    Expanded(child: yearButton),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: fromButton),
              const SizedBox(width: 6),
              Expanded(child: toButton),
              const SizedBox(width: 6),
              Expanded(child: monthButton),
              const SizedBox(width: 6),
              Expanded(child: yearButton),
            ],
          );
        },
      ),
    );
  }
}
