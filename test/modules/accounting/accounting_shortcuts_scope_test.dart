import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/modules/accounting/widgets/accounting_shortcuts_scope.dart';

void main() {
  testWidgets('activates accountant shortcuts on desktop', (tester) async {
    var dateTriggered = 0;
    var saveTriggered = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AccountingShortcutsScope(
          currentRole: UserRole.accountant,
          desktopOverride: true,
          onChangeDate: () => dateTriggered++,
          onSaveVoucher: () => saveTriggered++,
          child: const Scaffold(body: Text('Accounting')),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pump();
    expect(dateTriggered, 1);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(saveTriggered, 1);
  });

  testWidgets('does not activate shortcuts for non-accountant', (tester) async {
    var dateTriggered = 0;
    var saveTriggered = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AccountingShortcutsScope(
          currentRole: UserRole.admin,
          desktopOverride: true,
          onChangeDate: () => dateTriggered++,
          onSaveVoucher: () => saveTriggered++,
          child: const Scaffold(body: Text('Admin')),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(dateTriggered, 0);
    expect(saveTriggered, 0);
  });
}
