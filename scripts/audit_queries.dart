// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.contains('test'))
      .toList();

  final collections = <String>{};
  final wheres = <String>{};
  final orderBys = <String>{};

  final colRegex = RegExp(r'''\.collection\(\s*['"]([^'"]+)['"]\)''');
  final regRegex = RegExp(
    r'''\.collection\(\s*([a-zA-Z0-9_]+Collection)\s*\)''',
  );
  final regRegex2 = RegExp(
    r'''\.collection\(\s*CollectionRegistry\.([a-zA-Z0-9_]+)\s*\)''',
  );

  final whereRegex = RegExp(r'''\.where\(\s*['"]([^'"]+)['"]''');
  final orderByRegex = RegExp(r'''\.orderBy\(\s*['"]([^'"]+)['"]''');

  for (final f in dartFiles) {
    final content = f.readAsStringSync();

    for (final m in colRegex.allMatches(content)) {
      collections.add(m.group(1)!);
    }
    for (final m in regRegex.allMatches(content)) {
      collections.add(m.group(1)!);
    }
    for (final m in regRegex2.allMatches(content)) {
      collections.add('CollectionRegistry.${m.group(1)!}');
    }

    for (final m in whereRegex.allMatches(content)) {
      wheres.add(m.group(1)!);
    }
    for (final m in orderByRegex.allMatches(content)) {
      orderBys.add(m.group(1)!);
    }
  }

  print('--- COLLECTIONS FOUND ---');
  for (var c in collections.toList()..sort()) {
    print(c);
  }
  print('--- WHERE FIELDS FOUND ---');
  for (var w in wheres.toList()..sort()) {
    print(w);
  }
  print('--- ORDERBY FIELDS FOUND ---');
  for (var o in orderBys.toList()..sort()) {
    print(o);
  }
}
