import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/inventory/tanks_list_screen.dart';

void main() {
  test('tank grid auto-adapts columns on desktop widths', () {
    expect(tankGridColumnCountForWidth(900), 3);
    expect(tankGridColumnCountForWidth(1200), 4);
    expect(tankGridColumnCountForWidth(1400), 5);
    expect(tankGridColumnCountForWidth(1600), kLockedTankDesktopColumns);
    expect(tankGridColumnCountForWidth(2200), kLockedTankDesktopColumns);
  });

  test('tank grid uses compact fallback columns on smaller widths', () {
    expect(tankGridColumnCountForWidth(800), 3);
    expect(tankGridColumnCountForWidth(520), 2);
    expect(tankGridColumnCountForWidth(420), 1);
  });
}
