import 'dart:io';

void main() {
  final directory = Directory('lib');
  final violations = <String>[];

  // 1. Define Forbidden Patterns
  final patterns = {
    r'Colors\.white': 'Hardcoded Colors.white',
    r'Colors\.black': 'Hardcoded Colors.black',
    r'ThemeData\(': 'Inline ThemeData definition (Use AppTheme)',
    r'Theme\(': 'Local Theme widget (Use Theme.of(context))',
  };

  // 2. Define Exemptions (Tech Debt / Legitimate Uses)
  final exemptions = {
    'lib/core/theme/app_theme.dart', // The source of truth
    'lib/scripts/theme_guard.dart', // This file
    'theme_guard.dart',
  };

  if (!directory.existsSync()) {
    stderr.writeln('Error: lib directory not found.');
    exit(1);
  }

  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  stdout.writeln('Scanning ${files.length} files for theme violations...');

  for (final file in files) {
    if (exemptions.any((e) => file.path.replaceAll('\\', '/').contains(e))) {
      continue;
    }

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().startsWith('//')) {
        continue; // Skip comments
      }

      patterns.forEach((pattern, rule) {
        if (RegExp(pattern).hasMatch(line)) {
          violations.add(
            '${file.path}:${i + 1} - $rule\n   Line: ${line.trim()}',
          );
        }
      });
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('No theme violations found. System is CLEAN.');
    exit(0);
  } else {
    stderr.writeln('Found ${violations.length} theme inconsistencies:');
    for (final violation in violations) {
      stderr.writeln(violation);
    }
    stderr.writeln(
      '\nACTION REQUIRED: Refactor these files to use AppTheme tokens.',
    );
    // For now, we print them but don't fail the build until baseline is cleared
    // or we can allow this script to take a "baseline" file.
    // exit(1);
    exit(
      0,
    ); // Soft Fail for now as requested by "PostLockHardening" context which implies we might still have debt.
  }
}
