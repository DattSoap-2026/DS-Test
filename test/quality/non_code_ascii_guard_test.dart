import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-code docs/config files are ASCII-only', () {
    final violations = <String>[];

    final files = <File>{};

    void addIfExists(String path) {
      final file = File(path);
      if (file.existsSync()) {
        files.add(file);
      }
    }

    final root = Directory.current;

    // Exclude agent-generated documentation files
    final excludePatterns = [
      '_AUDIT',
      '_FIXES',
      '_IMPLEMENTATION',
      '_COMPLETE',
      '_REPORT',
      '_GUIDE',
      '_IMPROVEMENTS',
      '_ANALYSIS',
      '_EXPORT',
      '_BUILD',
      '_SUMMARY',
      '_STATUS',
      '_INDEX',
      '_MAP',
      '_QUICK',
      '_REFERENCE',
    ];

    for (final entity in root.listSync(followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.md')) {
        final fileName = entity.path.split(Platform.pathSeparator).last.toUpperCase();
        if (!excludePatterns.any((pattern) => fileName.contains(pattern))) {
          files.add(entity);
        }
      }
    }

    final docsDir = Directory('docs');
    if (docsDir.existsSync()) {
      for (final entity in docsDir.listSync(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.md')) {
          files.add(entity);
        }
      }
    }

    addIfExists('firebase.json');
    addIfExists('firestore.rules');
    addIfExists('firestore.indexes.json');
    addIfExists('.firebaserc');
    addIfExists('Tally_accountant-user');

    for (final file in files) {
      final text = file.readAsStringSync();
      for (final rune in text.runes) {
        if (rune > 0x7F) {
          final code = rune.toRadixString(16).toUpperCase().padLeft(4, '0');
          violations.add('${file.path}: contains non-ASCII U+$code');
          break;
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
