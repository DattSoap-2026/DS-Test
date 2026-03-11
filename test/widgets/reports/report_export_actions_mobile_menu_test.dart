import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/widgets/reports/report_export_actions.dart';

void main() {
  testWidgets('mobile view shows overflow menu with refresh/pdf/print', (
    tester,
  ) async {
    var refreshed = 0;
    var exported = 0;
    var printed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(
            appBar: AppBar(
              actions: [
                ReportExportActions(
                  isLoading: false,
                  onExport: () => exported++,
                  onPrint: () => printed++,
                  onRefresh: () => refreshed++,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Refresh'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(refreshed, 1);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();
    expect(exported, 1);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Print'));
    await tester.pumpAndSettle();
    expect(printed, 1);
  });

  testWidgets('refresh option hidden when callback is absent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(
            appBar: AppBar(
              actions: [
                ReportExportActions(
                  isLoading: false,
                  onExport: () {},
                  onPrint: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Refresh'), findsNothing);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
  });
}
