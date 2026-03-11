import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib sources do not contain mojibake markers', () {
    final root = Directory('lib');
    final violations = <String>[];
    const mojibakeMarkers = <String>[
      '\u00E2',
      '\u00F0\u0178',
      '\u00C3\u00A2\u00E2\u20AC\u0161\u00C2\u00B9',
      '\u00E2\u201A\u00B9',
      '\u00E2\u20AC\u00A2',
      '\\\\u20B9',
    ];

    final files = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final text = file.readAsStringSync();

      for (final marker in mojibakeMarkers) {
        if (text.contains(marker)) {
          violations.add('${file.path}: contains "$marker"');
          break;
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
