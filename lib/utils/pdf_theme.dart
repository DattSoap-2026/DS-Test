import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class PdfThemeColors {
  static PdfColor get primary => _from(AppColors.lightPrimary);
  static PdfColor get onPrimary => _from(AppColors.lightSurface);
  static PdfColor get surface => _from(AppColors.lightSurface);
  static PdfColor get surfaceMuted => _from(AppColors.lightBackground);
  static PdfColor get border => _from(AppColors.lightBorder);
  static PdfColor get textPrimary => _from(AppColors.lightTextPrimary);
  static PdfColor get textSecondary => _from(AppColors.lightTextSecondary);
  static PdfColor get textMuted => _from(AppColors.lightTextMuted);

  static PdfColor get success => _from(AppColors.success);
  static PdfColor get warning => _from(AppColors.warning);
  static PdfColor get error => _from(AppColors.error);
  static PdfColor get info => _from(AppColors.info);

  static PdfColor get primarySoft => _tint(AppColors.lightPrimary, 0.88);

  static PdfColor _from(Color color) {
    return PdfColor.fromInt(color.toARGB32() & 0xFFFFFF);
  }

  static PdfColor _tint(Color color, double amount) {
    final r = _channel(color.r + (1.0 - color.r) * amount);
    final g = _channel(color.g + (1.0 - color.g) * amount);
    final b = _channel(color.b + (1.0 - color.b) * amount);
    return PdfColor.fromInt((r << 16) | (g << 8) | b);
  }

  static int _channel(double v) {
    return (v * 255.0).round().clamp(0, 255).toInt();
  }
}
