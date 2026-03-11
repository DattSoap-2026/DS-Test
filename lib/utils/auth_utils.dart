import 'package:isar/isar.dart';

import 'package:flutter_app/data/local/entities/user_entity.dart';

Future<UserEntity?> findUserByFirebaseUid(
  IsarCollection<UserEntity> users,
  String uid, {
  String? fallbackEmail,
}) async {
  final normalizedUid = uid.trim();
  if (normalizedUid.isEmpty) return null;

  final byUid = await users.filter().idEqualTo(normalizedUid).findFirst();
  if (byUid != null) return byUid;

  final normalizedEmail = fallbackEmail?.trim().toLowerCase();
  if (normalizedEmail == null || normalizedEmail.isEmpty) {
    return null;
  }

  final byEmailId = await users.filter().idEqualTo(normalizedEmail).findFirst();
  if (byEmailId != null) return byEmailId;

  return await users
      .filter()
      .emailEqualTo(normalizedEmail, caseSensitive: false)
      .findFirst();
}
