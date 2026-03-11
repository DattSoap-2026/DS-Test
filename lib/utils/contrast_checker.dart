import 'package:flutter/material.dart';

enum ContrastGrade { fail, aa, aaa }

class ContrastResult {
  final double ratio;
  final ContrastGrade grade;

  const ContrastResult({required this.ratio, required this.grade});

  bool get passes => grade != ContrastGrade.fail;
}

class ContrastChecker {
  static ContrastResult evaluate(Color fg, Color bg) {
    final ratio = contrastRatio(fg, bg);
    if (ratio >= 7.0) {
      return ContrastResult(ratio: ratio, grade: ContrastGrade.aaa);
    }
    if (ratio >= 4.5) {
      return ContrastResult(ratio: ratio, grade: ContrastGrade.aa);
    }
    return ContrastResult(ratio: ratio, grade: ContrastGrade.fail);
  }

  static double contrastRatio(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final brightest = l1 > l2 ? l1 : l2;
    final darkest = l1 > l2 ? l2 : l1;
    return (brightest + 0.05) / (darkest + 0.05);
  }
}
