import 'package:shared_preferences/shared_preferences.dart';

/// Stores whether the current Firebase-authenticated identity has been
/// revalidated against authoritative user profile data.
///
/// Security contract:
/// - `validated=false` means mutation services must fail closed (read-only).
/// - `validated=true` is scoped to a specific Firebase UID.
class IdentityRevalidationState {
  static const String _validatedKey = 'security.identity_revalidated';
  static const String _uidKey = 'security.identity_revalidated_uid';
  static const String _reasonKey = 'security.identity_revalidation_reason';
  static const String _updatedAtKey = 'security.identity_revalidated_at';

  static bool _loaded = false;
  static bool _validated = false;
  static String? _uid;
  static String? _reason;
  static String? _updatedAtIso;

  static Future<void> _loadIfNeeded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _validated = prefs.getBool(_validatedKey) ?? false;
    _uid = prefs.getString(_uidKey)?.trim();
    _reason = prefs.getString(_reasonKey);
    _updatedAtIso = prefs.getString(_updatedAtKey);
    _loaded = true;
  }

  static Future<void> markPending({
    String? uid,
    String reason = 'pending_revalidation',
  }) async {
    await _loadIfNeeded();
    _validated = false;
    _uid = uid?.trim().isEmpty == true ? null : uid?.trim();
    _reason = reason;
    _updatedAtIso = DateTime.now().toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_validatedKey, false);
    if (_uid == null) {
      await prefs.remove(_uidKey);
    } else {
      await prefs.setString(_uidKey, _uid!);
    }
    await prefs.setString(_reasonKey, _reason!);
    await prefs.setString(_updatedAtKey, _updatedAtIso!);
  }

  static Future<void> markValidated({
    required String uid,
    String reason = 'online_identity_verified',
  }) async {
    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) {
      await markPending(reason: 'invalid_uid');
      return;
    }

    await _loadIfNeeded();
    _validated = true;
    _uid = normalizedUid;
    _reason = reason;
    _updatedAtIso = DateTime.now().toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_validatedKey, true);
    await prefs.setString(_uidKey, _uid!);
    await prefs.setString(_reasonKey, _reason!);
    await prefs.setString(_updatedAtKey, _updatedAtIso!);
  }

  static Future<void> clear({String reason = 'session_cleared'}) async {
    await _loadIfNeeded();
    _validated = false;
    _uid = null;
    _reason = reason;
    _updatedAtIso = DateTime.now().toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_validatedKey, false);
    await prefs.remove(_uidKey);
    await prefs.setString(_reasonKey, _reason!);
    await prefs.setString(_updatedAtKey, _updatedAtIso!);
  }

  static Future<bool> isValidatedForUid(String uid) async {
    final normalizedUid = uid.trim();
    if (normalizedUid.isEmpty) return false;
    await _loadIfNeeded();
    return _validated && _uid == normalizedUid;
  }

  static Future<Map<String, dynamic>> snapshot() async {
    await _loadIfNeeded();
    return <String, dynamic>{
      'validated': _validated,
      'uid': _uid,
      'reason': _reason,
      'updatedAt': _updatedAtIso,
    };
  }
}

