import 'dart:io';

/// Responsive regression guard.
///
/// Fails with non-zero exit code when architecture rules are violated.
/// Inline suppression (use rarely): add `// ignore-resp-guard` on the line.
void main() {
  final violations = <String>[];

  final mediaQueryAllowed = {'lib/utils/responsive.dart'};
  final alertDialogAllowed = {'lib/widgets/dialogs/responsive_alert_dialog.dart'};

  final allLibFiles = _listDartFiles('lib');

  for (final file in allLibFiles) {
    final lines = File(file).readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('//') || line.contains('ignore-resp-guard')) {
        continue;
      }

      if (line.contains('MediaQuery.of(context)') &&
          !mediaQueryAllowed.contains(file)) {
        violations.add(
          '$file:${i + 1}: Disallowed MediaQuery.of(context). Use Responsive helper.',
        );
      }

      if (RegExp(r'\bAlertDialog\s*\(').hasMatch(line) &&
          !alertDialogAllowed.contains(file)) {
        violations.add(
          '$file:${i + 1}: Raw AlertDialog detected. Use ResponsiveAlertDialog.',
        );
      }
    }
  }

  final fixedSizeTargets = {
    ..._listDartFiles('lib/screens'),
    ..._listDartFiles('lib/widgets'),
    ..._listDartFiles('lib/modules'),
  };

  final fixedSizePattern = RegExp(
    r'(?<![-\w])(width|height)\s*:\s*([0-9]+(?:\.[0-9]+)?)\b',
  );

  for (final file in fixedSizeTargets) {
    final lines = File(file).readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('//') || line.contains('ignore-resp-guard')) {
        continue;
      }

      for (final match in fixedSizePattern.allMatches(line)) {
        final kind = match.group(1)!;
        final rawValue = match.group(2)!;
        final value = double.tryParse(rawValue);
        if (value == null) continue;

        final isViolation =
            (kind == 'width' && value >= 300) ||
            (kind == 'height' && value >= 200);
        if (!isViolation) continue;

        violations.add(
          '$file:${i + 1}: Fixed $kind=$rawValue violates responsive rule. Use ConstrainedBox/Responsive.clamp.',
        );
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Responsive guard failed with ${violations.length} issue(s):');
    for (final v in violations) {
      stderr.writeln(' - $v');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Responsive guard passed: no MediaQuery.of(context), raw AlertDialog, or large fixed sizes detected.',
  );
}

List<String> _listDartFiles(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.replaceAll('\\', '/'))
      .where((p) => p.endsWith('.dart'))
      .toList();
}
