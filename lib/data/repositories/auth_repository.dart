// [HARD LOCKED] - Auth Repository
// CRITICAL: NO modification allowed without explicit AUTH_LOCK_OVERRIDE.
// Standardized on 3-pass lookup: UID Doc -> Email Doc ID -> Email Field Query.

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../local/entities/user_entity.dart';
import '../../services/database_service.dart';
import '../../utils/app_logger.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class AuthRepository {
  final DatabaseService _dbService;
  final FirebaseAuth? _firebaseAuth;
  final firestore.FirebaseFirestore? _db;

  AuthRepository(this._dbService, this._firebaseAuth, this._db);

  String _normalizeAccountStatus(
    dynamic rawStatus, {
    required bool fallbackIsActive,
  }) {
    final token = rawStatus?.toString().trim().toLowerCase() ?? '';
    if (token.isEmpty) return fallbackIsActive ? 'active' : 'inactive';
    if (token == 'active' || token == 'enabled' || token == 'approved') {
      return 'active';
    }
    if (token == 'inactive' ||
        token == 'disabled' ||
        token == 'blocked' ||
        token == 'suspended') {
      return 'inactive';
    }
    return token;
  }

  bool _resolveIsActive(dynamic rawIsActive, dynamic rawStatus) {
    if (rawIsActive is bool) return rawIsActive;
    final normalized = _normalizeAccountStatus(
      rawStatus,
      fallbackIsActive: true,
    );
    return normalized == 'active';
  }

  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth?.currentUser;
    if (firebaseUser != null && firebaseUser.email != null) {
      // Primary: Search by Auth UID
      final byId = await _dbService.users
          .filter()
          .idEqualTo(firebaseUser.uid)
          .findFirst();

      if (byId != null) return byId;

      // Fallback: Search by Email (handles legacy ID mismatches)
      return await _dbService.users
          .filter()
          .emailEqualTo(firebaseUser.email!, caseSensitive: false)
          .findFirst();
    }
    return null;
  }

  // [AUTH_LOCK_OVERRIDE] Fast startup restore for warm sessions.
  // Reads the most recently updated local user without requiring Firebase user
  // object to be immediately available.
  Future<UserEntity?> getLastCachedUser() async {
    try {
      final cachedUsers = await _dbService.users.where().findAll();
      if (cachedUsers.isEmpty) return null;

      cachedUsers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      for (final user in cachedUsers) {
        if (user.isActive) return user;
      }
      return cachedUsers.first;
    } catch (e) {
      AppLogger.warning('Failed to read last cached user: $e', tag: 'Auth');
      return null;
    }
  }

  Future<UserEntity> signIn(String email, String password) async {
    if (_firebaseAuth == null) {
      throw FirebaseAuthException(
        code: 'auth-not-available',
        message: 'Security Service Unavailable.',
      );
    }

    try {
      // 1. Force Online Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      final authEmail = credential.user?.email;

      if (uid == null || authEmail == null) {
        await _firebaseAuth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Authentication failed: Missing user profile.',
        );
      }

      // 2. Strict Firestore Verification (Contract enforcement)
      if (_db == null) {
        await _firebaseAuth.signOut();
        throw FirebaseAuthException(
          code: 'service-unavailable',
          message: 'Database connection failed. Please try again online.',
        );
      }

      var doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        final normalizedEmail = authEmail.toLowerCase();
        AppLogger.info(
          'Profile not found by UID: $uid. Attempting email-based fallback for $normalizedEmail',
          tag: 'Auth',
        );

        // Fallback 1: Direct document lookup by normalized email ID
        doc = await _db.collection('users').doc(normalizedEmail).get();

        // Fallback 2: Targeted query by email field (handles mixed-case fields and random IDs)
        if (!doc.exists) {
          AppLogger.info(
            'Direct email doc lookup failed. Attempting targeted query (lowercase/original) for $authEmail',
            tag: 'Auth',
          );
          // Try lowercase first
          var query = await _db
              .collection('users')
              .where('email', isEqualTo: normalizedEmail)
              .limit(1)
              .get();

          // Try original if lowercase failed
          if (query.docs.isEmpty && authEmail != normalizedEmail) {
            query = await _db
                .collection('users')
                .where('email', isEqualTo: authEmail)
                .limit(1)
                .get();
          }

          if (query.docs.isNotEmpty) {
            doc =
                query.docs.first
                    as firestore.DocumentSnapshot<Map<String, dynamic>>;
          }
        }

        if (doc.exists) {
          // [AUTH_LOCK_OVERRIDE] - Identity Linking (best effort)
          // Some Firestore rules intentionally block non-admin users from
          // creating role-bearing /users/{uid} docs. In that case we must
          // continue with the verified legacy doc instead of failing login.
          final legacyData = doc.data() ?? {};
          try {
            await _db.collection('users').doc(uid).set({
              ...legacyData,
              'uid': uid,
              'id': doc.id,
              'updatedAt': firestore.FieldValue.serverTimestamp(),
            }, firestore.SetOptions(merge: true));

            AppLogger.success(
              'Identity Linked: Processed legacy profile (${doc.id}) for $normalizedEmail. Account is now hard-locked to UID: $uid',
              tag: 'Auth',
            );
            doc = await _db.collection('users').doc(uid).get();
          } on firestore.FirebaseException catch (e) {
            if (e.code == 'permission-denied') {
              AppLogger.warning(
                'Identity linking skipped for $normalizedEmail due to Firestore permissions. Continuing with legacy profile (${doc.id}).',
                tag: 'Auth',
              );
            } else {
              rethrow;
            }
          }
        } else {
          await _firebaseAuth.signOut();
          throw FirebaseAuthException(
            code: 'user-not-found',
            message:
                'Access Denied: No profile found for $normalizedEmail. Please contact Admin.',
          );
        }
      }

      final data = doc.data();
      final firestoreEmail = data?['email']?.toString().toLowerCase();
      final firestoreUid = data?['uid']?.toString() ?? data?['id']?.toString();
      final firestoreRole = data?['role']?.toString();
      final isActive = _resolveIsActive(data?['isActive'], data?['status']);
      final normalizedStatus = _normalizeAccountStatus(
        data?['status'],
        fallbackIsActive: isActive,
      );

      // Rule: Identity must be verified by Email (Primary Contract)
      if (firestoreEmail != authEmail) {
        await _firebaseAuth.signOut();
        AppLogger.error(
          'Security Violation: Auth Email ($authEmail) does not match Firestore Email ($firestoreEmail)',
          tag: 'Auth',
        );
        throw FirebaseAuthException(
          code: 'security-violation',
          message: 'Identity mismatch: Email does not match account records.',
        );
      }

      // Check UID but don't block (Legacy Support)
      if (firestoreUid != null && firestoreUid != uid) {
        AppLogger.warning(
          'UID Mismatch detected for $authEmail. Auth: $uid, Firestore: $firestoreUid. Proceeding with Email verified identity.',
          tag: 'Auth',
        );
      }

      // Rule: Email must match (normalized)
      if (firestoreEmail != authEmail.toLowerCase()) {
        await _firebaseAuth.signOut();
        throw FirebaseAuthException(
          code: 'security-violation',
          message: 'Security error: Email mismatch.',
        );
      }

      // Rule: User must be active
      if (!isActive) {
        await _firebaseAuth.signOut();
        throw FirebaseAuthException(
          code: 'access-denied',
          message: 'Access Denied: This account is disabled.',
        );
      }

      // Rule: Valid role required
      if (firestoreRole == null || firestoreRole.isEmpty) {
        await _firebaseAuth.signOut();
        throw FirebaseAuthException(
          code: 'invalid-role',
          message: 'Access Denied: No valid role assigned.',
        );
      }

      // 3. Persist to cache only AFTER verification passes
      final newUser = UserEntity()
        ..id = doc
            .id // Use the ACTUAL Firestore Document ID for future syncs
        ..email = authEmail
        ..name = data?['name'] ?? 'User'
        ..role = firestoreRole
        ..phone = data?['phone'] ?? data?['mobile']
        ..status = normalizedStatus
        ..department = data?['department']
        ..designation = data?['designation']
        ..departmentsJson = jsonEncode(data?['departments'] ?? [])
        ..isActive = isActive
        ..updatedAt = DateTime.now();

      await _dbService.db.writeTxn(() async {
        await _dbService.users.put(newUser);
      });

      return newUser;
    } on FirebaseAuthException {
      rethrow;
    } catch (e, stack) {
      AppLogger.error(
        'Critical Auth failure during sign-in: $e',
        error: e,
        stackTrace: stack,
        tag: 'Auth',
      );
      throw FirebaseAuthException(
        code: 'internal-error',
        message: 'Auth Error: $e',
      );
    }
  }

  Future<void> saveUser(UserEntity user) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.users.put(user);
    });
  }

  Future<void> signOut() async {
    try {
      // 1. Clear Local User Entity (Burn session)
      await _dbService.db.writeTxn(() async {
        await _dbService.users.clear();
      });

      // 2. Clear Firebase Session
      if (_firebaseAuth != null) {
        await _firebaseAuth.signOut().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('AuthRepo: Firebase signOut timed out');
          },
        );
      }
    } catch (e) {
      debugPrint('AuthRepo: Firebase signOut error: $e');
    }
  }
}
