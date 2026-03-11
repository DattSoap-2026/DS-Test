import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/bhatti/bhatti_dashboard_screen.dart';

void main() {
  test('bhatti dashboard keeps two KPI cards per row on mobile widths', () {
    expect(bhattiDashboardKpiColumnsForWidth(320), 2);
    expect(bhattiDashboardKpiColumnsForWidth(480), 2);
    expect(bhattiDashboardKpiColumnsForWidth(768), 2);
  });

  test('bhatti dashboard switches to four KPI cards per row on desktop', () {
    expect(bhattiDashboardKpiColumnsForWidth(900), 4);
    expect(bhattiDashboardKpiColumnsForWidth(1200), 4);
  });

  test('bhatti dashboard uses compact aspect ratio on mobile', () {
    expect(bhattiDashboardKpiAspectRatioForWidth(320), 1.6);
    expect(bhattiDashboardKpiAspectRatioForWidth(400), 1.7);
    expect(bhattiDashboardKpiAspectRatioForWidth(700), 1.8);
  });
}
