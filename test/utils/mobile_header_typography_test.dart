import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/utils/mobile_header_typography.dart';

void main() {
  test('mobile header typography toggles by breakpoint width', () {
    expect(useMobileHeaderTypographyForWidth(320), isTrue);
    expect(useMobileHeaderTypographyForWidth(599), isTrue);
    expect(useMobileHeaderTypographyForWidth(600), isFalse);
    expect(useMobileHeaderTypographyForWidth(900), isFalse);
  });

  test('buildProfessionalMobileHeaderTitleStyle enforces compact size', () {
    const base = TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
    final result = buildProfessionalMobileHeaderTitleStyle(base);

    expect(result.fontSize, mobileHeaderTitleFontSize);
    expect(result.fontWeight, FontWeight.w700);
    expect(result.letterSpacing, -0.1);
    expect(result.height, 1.15);
  });

  test('applyMobileHeaderTheme only updates appbar title style on mobile', () {
    final baseTheme = ThemeData.light().copyWith(
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );

    final mobileTheme = applyMobileHeaderTheme(baseTheme, 390);
    final desktopTheme = applyMobileHeaderTheme(baseTheme, 900);

    expect(
      mobileTheme.appBarTheme.titleTextStyle?.fontSize,
      mobileHeaderTitleFontSize,
    );
    expect(
      desktopTheme.appBarTheme.titleTextStyle?.fontSize,
      baseTheme.appBarTheme.titleTextStyle?.fontSize,
    );
  });
}
