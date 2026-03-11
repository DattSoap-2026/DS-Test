import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';

enum SyncStatus { pending, synced, conflict }

abstract class BaseEntity {
  @Index(unique: true, replace: true)
  late String id; // This is the UUID from Firebase/App logic

  /// Isar requires an integer ID. We generate it from the stable UUID.
  Id get isarId => fastHash(id);

  late DateTime updatedAt;

  DateTime? deletedAt;

  @enumerated
  SyncStatus syncStatus = SyncStatus.synced;

  bool isDeleted = false;
}

/// FNV-1a 64-bit hash algorithm optimized for Dart strings
int fastHash(String string) {
  // On Web, large integers (64-bit) lose precision because JS uses doubles (53-bit mantissa).
  // We use a 32-bit FNV-1a variation for Web to ensure stability.
  // We use conditional import logic via kIsWeb.
  if (kIsWeb) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < string.length; i++) {
      hash ^= string.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  } else {
    // 0xcbf29ce484222325 = -3750763034362895579 (signed 64-bit)
    // using int.parse to hide the literal from web compiler which hates >53 bit ints
    var hash = int.parse('-3750763034362895579');
    // 0x1099511628211999 = 1195988083329031065 (signed 64-bit)
    final prime = int.parse('1195988083329031065');

    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= prime;
      hash ^= codeUnit & 0xFF;
      hash *= prime;
    }
    return hash;
  }
}
