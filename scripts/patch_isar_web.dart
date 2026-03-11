// ignore_for_file: avoid_print
import 'dart:io';

const int maxSafeInteger = 9007199254740991; // 2^53 - 1

void main() async {
  final dir = Directory(
    r'e:\Flutter Project\DattSoap-main\flutter_app\lib\data\local\entities',
  );

  if (!await dir.exists()) {
    print('Directory not found: ${dir.path}');
    return;
  }

  final files = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.g.dart'),
  );

  print('Found ${files.length} .g.dart files.');

  for (final file in files) {
    await patchFile(file);
  }
}

Future<void> patchFile(File file) async {
  String content = await file.readAsString();
  bool changed = false;

  // 1. Convert 'const' to 'final' for schema declarations to allow non-const int.parse()
  final oldContent = content;
  content = content.replaceAllMapped(
    RegExp(
      r'(const|final)\s+(\w+Schema)\s*=\s*(CollectionSchema|EmbeddedSchema|Schema|SchemaSchema)\(',
    ),
    (match) {
      final type = match.group(3) == 'SchemaSchema' ? 'Schema' : match.group(3);
      return 'final ${match.group(2)} = $type(';
    },
  );
  if (content != oldContent) changed = true;

  // Regex to find id assignments: id: <number>,
  // Matches "id: 123456," or "id: -123456,"
  final regex = RegExp(r'id:\s*(-?\d+),');

  // 2. Patch large IDs
  String newContent = content.replaceAllMapped(regex, (match) {
    final originalStr = match.group(1)!;
    try {
      final val = BigInt.parse(originalStr);
      final maxSafe = BigInt.from(maxSafeInteger);

      if (val.abs() > maxSafe) {
        // Check if we are already inside an int.parse (to avoid double wrapping)
        if (match.group(0)!.contains('int.parse')) return match.group(0)!;
        changed = true;
        return "id: int.parse('$originalStr'),";
      }
    } catch (e) {
      // Ignore parsing errors for small ints or non-numbers
    }
    return match.group(0)!;
  });

  if (changed) {
    print('Patched: ${file.path.split(Platform.pathSeparator).last}');
    await file.writeAsString(newContent);
  }
}
