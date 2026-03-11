import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/utils/mobile_header_typography.dart';
import 'package:flutter_app/widgets/ui/master_screen_header.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    bool isDashboardHeader = false,
    double width = 390,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 844)),
          child: Scaffold(
            body: MasterScreenHeader(
              title: 'Test Header',
              subtitle: 'Subtitle',
              isDashboardHeader: isDashboardHeader,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows auto back arrow on mobile non-dashboard headers', (
    tester,
  ) async {
    await pumpHeader(tester);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('hides auto back arrow on dashboard headers', (tester) async {
    await pumpHeader(tester, isDashboardHeader: true);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('applies compact professional header typography on mobile', (
    tester,
  ) async {
    await pumpHeader(tester, width: 390);
    final title = tester.widget<Text>(find.text('Test Header'));
    final subtitle = tester.widget<Text>(find.text('Subtitle'));

    expect(title.style?.fontSize, mobileHeaderTitleFontSize);
    expect(subtitle.style?.fontSize, mobileHeaderSubtitleFontSize);
  });

  testWidgets('keeps larger header title style on desktop width', (tester) async {
    await pumpHeader(tester, width: 900);
    final title = tester.widget<Text>(find.text('Test Header'));
    final desktopSize = title.style?.fontSize ?? 0;

    expect(desktopSize, greaterThan(mobileHeaderTitleFontSize));
  });
}
