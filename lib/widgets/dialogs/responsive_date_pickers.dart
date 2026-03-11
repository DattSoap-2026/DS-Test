import 'package:flutter/material.dart';

import '../../utils/responsive.dart';

class ResponsiveDatePickers {
  const ResponsiveDatePickers._();

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static Future<DateTimeRange?> pickDateRange({
    required BuildContext context,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTimeRange? initialDateRange,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) {
    return showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
      initialEntryMode: initialEntryMode,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      builder: (pickerContext, child) {
        return _wrapDesktopDialog(
          context: pickerContext,
          child: child,
          maxWidth: 560,
          maxHeightFactor: 0.9,
        );
      },
    );
  }

  static Future<DateTime?> pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    String? helpText,
    String? cancelText,
    String? confirmText,
    SelectableDayPredicate? selectableDayPredicate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: initialEntryMode,
      initialDatePickerMode: initialDatePickerMode,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      selectableDayPredicate: selectableDayPredicate,
      builder: (pickerContext, child) {
        return _wrapDesktopDialog(
          context: pickerContext,
          child: child,
          maxWidth: 420,
          maxHeightFactor: 0.9,
        );
      },
    );
  }

  static Future<DateTime?> pickMonth({
    required BuildContext context,
    required BuildContext anchorContext,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
  }) async {
    final selectedMonth = await _showDropdownMenu<int>(
      context: context,
      anchorContext: anchorContext,
      maxHeight: 280,
      items: List<PopupMenuEntry<int>>.generate(
        _monthNames.length,
        (index) => PopupMenuItem<int>(
          value: index + 1,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(_monthNames[index]),
        ),
      ),
    );

    if (selectedMonth == null) return null;
    final monthStart = DateTime(initialDate.year, selectedMonth, 1);
    return _clampDate(monthStart, firstDate, lastDate);
  }

  static Future<DateTime?> pickYear({
    required BuildContext context,
    required BuildContext anchorContext,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
  }) async {
    final startYear = firstDate.year;
    final endYear = lastDate.year;
    if (endYear < startYear) return null;

    final years = List<int>.generate(
      (endYear - startYear) + 1,
      (index) => endYear - index,
    );

    final selectedYear = await _showDropdownMenu<int>(
      context: context,
      anchorContext: anchorContext,
      maxHeight: 300,
      items: years
          .map(
            (year) => PopupMenuItem<int>(
              value: year,
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('$year'),
            ),
          )
          .toList(),
    );

    if (selectedYear == null) return null;
    final month = initialDate.month.clamp(1, 12);
    final maxDayInMonth = DateUtils.getDaysInMonth(selectedYear, month);
    final day = initialDate.day.clamp(1, maxDayInMonth);
    final candidate = DateTime(selectedYear, month, day);
    return _clampDate(candidate, firstDate, lastDate);
  }

  static Future<T?> _showDropdownMenu<T>({
    required BuildContext context,
    required BuildContext anchorContext,
    required List<PopupMenuEntry<T>> items,
    required double maxHeight,
  }) async {
    final overlay = Overlay.maybeOf(anchorContext);
    final buttonRender = anchorContext.findRenderObject();
    if (overlay == null || buttonRender is! RenderBox) return null;

    final overlayBox = overlay.context.findRenderObject();
    if (overlayBox is! RenderBox) return null;

    final buttonTopLeft = buttonRender.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final buttonBottomRight = buttonRender.localToGlobal(
      buttonRender.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );

    final position = RelativeRect.fromLTRB(
      buttonTopLeft.dx,
      buttonBottomRight.dy + 2,
      overlayBox.size.width - buttonBottomRight.dx,
      overlayBox.size.height - buttonBottomRight.dy,
    );

    return showMenu<T>(
      context: context,
      position: position,
      items: items,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      constraints: BoxConstraints(
        minWidth: buttonRender.size.width,
        maxWidth: buttonRender.size.width,
        maxHeight: maxHeight,
      ),
    );
  }

  static DateTime _clampDate(DateTime value, DateTime firstDate, DateTime lastDate) {
    if (value.isBefore(firstDate)) return firstDate;
    if (value.isAfter(lastDate)) return lastDate;
    return value;
  }

  static Widget _wrapDesktopDialog({
    required BuildContext context,
    required Widget? child,
    required double maxWidth,
    required double maxHeightFactor,
  }) {
    if (child == null) return const SizedBox.shrink();
    if (!Responsive.isDesktop(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: Responsive.dialogConstraints(
          context,
          maxWidth: maxWidth,
          maxHeightFactor: maxHeightFactor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
      ),
    );
  }
}
