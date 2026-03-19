// [HARD LOCKED] - Auth Repository
// CRITICAL: NO modification allowed without explicit AUTH_LOCK_OVERRIDE.
// Standardized on 3-pass lookup: UID Doc -> Email Doc ID -> Email Field Query.

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/user_entity.dart';
import '../../services/database_service.dart';
import '../../utils/app_logger.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class AuthRepository {
  final DatabaseService _dbService;
  final FirebaseAuth? _firebaseAuth;
  final firestore.FirebaseFirestore? _db;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  AuthRepository(
    this._dbService,
    this._firebaseAuth,
    this._db, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

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
          .and()
          .isDeletedEqualTo(false)
          .findFirst();

      if (byId != null) return byId;

      // Fallback: Search by Email (handles legacy ID mismatches)
      return await _dbService.users
          .filter()
          .emailEqualTo(firebaseUser.email!, caseSensitive: false)
          .and()
          .isDeletedEqualTo(false)
          .findFirst();
    }
    return null;
  }

  // [AUTH_LOCK_OVERRIDE] Fast startup restore for warm sessions.
  // Reads the most recently updated local user without requiring Firebase user
  // object to be immediately available.
  // LOCKED: Prioritises the Firebase-authed user so bootstrap/system accounts
  //         (e.g. accountant@dattsoap.local) cannot hijack the session.
  Future<UserEntity?> getLastCachedUser() async {
    try {
      final cachedUsers = (await _dbService.users.where().findAll())
          .where((user) => !user.isDeleted)
          .toList();
      if (cachedUsers.isEmpty) return null;

      // Try to match the current Firebase Auth identity first.
      final firebaseUser = _firebaseAuth?.currentUser;
      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        final email = firebaseUser.email?.toLowerCase();

        // 1. Match by UID (doc ID)
        for (final user in cachedUsers) {
          if (user.id == uid && user.isActive) return user;
        }
        // 2. Match by email
        if (email != null) {
          for (final user in cachedUsers) {
            if (user.email?.toLowerCase() == email && user.isActive) {
              return user;
            }
          }
        }
      }

      // Fallback: most recently updated active user (legacy behaviour).
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
          AppLogger.info(
            'Using verified legacy profile (${doc.id}) for $normalizedEmail without client-side identity linking write.',
            tag: 'Auth',
          );
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
      final existingLocal = await _dbService.users.getById(doc.id);
      final deviceId = await _deviceIdService.getDeviceId();
      final now = DateTime.now();
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
        ..updatedAt = now
        ..syncStatus = SyncStatus.synced
        ..isSynced = true
        ..lastSynced = now
        ..version = (data?['version'] as num?)?.toInt() ??
            existingLocal?.version ??
            1
        ..deviceId = deviceId;

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

  Future<void> saveUser(
    UserEntity user, {
    bool queueForSync = false,
    String operation = 'update',
  }) async {
    final now = DateTime.now();
    final existing = await _dbService.users.getById(user.id);
    user.updatedAt = now;
    user.deviceId = user.deviceId.isEmpty
        ? await _deviceIdService.getDeviceId()
        : user.deviceId;
    user.version = existing == null ? user.version : existing.version + 1;
    user.isSynced = !queueForSync;
    user.lastSynced = queueForSync ? null : now;
    user.syncStatus = queueForSync ? SyncStatus.pending : SyncStatus.synced;

    await _dbService.db.writeTxn(() async {
      await _dbService.users.put(user);
    });

    if (!queueForSync) {
      return;
    }

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.users,
      documentId: user.id,
      operation: operation,
      payload: user.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
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
            AppLogger.warning(
              'Firebase signOut timed out in AuthRepository.',
              tag: 'Auth',
            );
          },
        );
      }
    } catch (e) {
      AppLogger.warning('Firebase signOut error: $e', tag: 'Auth');
    }
  }
}
