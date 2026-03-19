import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// [HARD LOCKED] - Authentication Provider
// CRITICAL: NO modification allowed without explicit AUTH_LOCK_OVERRIDE.
// Standardized on 3-pass lookup: UID Doc -> Email Doc ID -> Email Field Query.
import '../../core/firebase/firebase_config.dart';
import '../../services/delegates/firestore_query_delegate.dart';
import '../../models/types/user_types.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/local/entities/user_entity.dart';
import '../../services/identity_revalidation_state.dart';
import '../../utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProviderProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  throw UnimplementedError(
    'authProviderProvider must be overridden in ProviderScope',
  );
});

enum AuthStatus { unauthenticated, loading, authenticated }

class AuthState {
  final AppUser? user;
  final bool loading;

  AuthState({this.user, required this.loading});

  AuthStatus get status {
    if (loading) return AuthStatus.loading;
    if (user != null) return AuthStatus.authenticated;
    return AuthStatus.unauthenticated;
  }

  AuthState copyWith({AppUser? user, bool? loading}) {
    return AuthState(user: user ?? this.user, loading: loading ?? this.loading);
  }
}

class AuthProvider with ChangeNotifier {
  final FirebaseServices _firebase;
  final AuthRepository _authRepo;
  AuthState _state = AuthState(loading: true);
  StreamSubscription<User?>? _authSubscription;
  Timer? _windowsAuthPollTimer;
  String? _lastObservedFirebaseUid;
  bool _isSigningOut = false;
  bool _identityValidated = false;

  AuthProvider(this._firebase, this._authRepo);

  AuthState get state => _state;
  bool get isAuthenticated => _state.status == AuthStatus.authenticated;
  bool get isIdentityValidated => _identityValidated;
  bool get isReadOnlyFallback => isAuthenticated && !_identityValidated;

  // Helper for direct user access
  AppUser? get currentUser => _state.user;

  bool get _useWindowsAuthPolling =>
      kDebugMode && !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

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

  Future<void> _applyFirebaseUser(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        final appUser = await _fetchUserDetails(firebaseUser.uid);
        _identityValidated =
            appUser != null &&
            await IdentityRevalidationState.isValidatedForUid(firebaseUser.uid);
        _state = _state.copyWith(user: appUser, loading: false);
      } else {
        _identityValidated = false;
        await IdentityRevalidationState.clear(
          reason: 'auth_user_missing_or_signed_out',
        );
        _state = _state.copyWith(user: null, loading: false);
      }
    } catch (e) {
      AppLogger.error('Auth state processing error', error: e, tag: 'Auth');
      _identityValidated = false;
      await IdentityRevalidationState.markPending(
        uid: firebaseUser?.uid,
        reason: 'apply_firebase_user_failed',
      );
      _state = _state.copyWith(loading: false);
    }
    notifyListeners();
  }

  void _startWindowsAuthPolling() {
    _windowsAuthPollTimer?.cancel();
    _lastObservedFirebaseUid = _firebase.auth?.currentUser?.uid;

    unawaited(_pollWindowsAuthState());
    _windowsAuthPollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_pollWindowsAuthState());
    });
  }

  Future<void> _pollWindowsAuthState() async {
    final currentUid = _firebase.auth?.currentUser?.uid;
    if (currentUid == _lastObservedFirebaseUid) {
      return;
    }
    _lastObservedFirebaseUid = currentUid;
    await _applyFirebaseUser(_firebase.auth?.currentUser);
  }

  Future<User?> _waitForWindowsFirebaseUser({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    var firebaseUser = _firebase.auth?.currentUser;
    while (firebaseUser == null && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      firebaseUser = _firebase.auth?.currentUser;
    }
    return firebaseUser;
  }

  Future<bool> _restoreCachedSessionFast() async {
    try {
      final localUser = await _authRepo.getLastCachedUser();
      if (localUser == null || !localUser.isActive) return false;
      await IdentityRevalidationState.markPending(
        uid: _firebase.auth?.currentUser?.uid,
        reason: 'cached_session_restored',
      );
      _identityValidated = false;

      _state = _state.copyWith(
        user: _mapUserEntityToAppUser(localUser),
        loading: false,
      );
      notifyListeners();
      AppLogger.success(
        'Fast session restored from cache for ${localUser.email}',
        tag: 'Auth',
      );
      return true;
    } catch (e) {
      AppLogger.warning('Fast session restore failed: $e', tag: 'Auth');
      return false;
    }
  }

  Future<void> _verifyWindowsSessionInBackground() async {
    try {
      final firebaseUser = await _waitForWindowsFirebaseUser(
        timeout: const Duration(seconds: 4),
      );
      if (firebaseUser != null) {
        await _applyFirebaseUser(firebaseUser);
      }
    } catch (e) {
      AppLogger.error('Background auth verify failed: $e', tag: 'Auth');
    }
  }

  Future<void> initialize() async {
    try {
      await IdentityRevalidationState.markPending(
        uid: _firebase.auth?.currentUser?.uid,
        reason: 'auth_initialize_start',
      );
      _identityValidated = false;
      if (_useWindowsAuthPolling) {
        // [AUTH_LOCK_OVERRIDE] Warm-start: restore local user first for
        // instant dashboard access; verify Firebase session in background.
        final restoredFromCache = await _restoreCachedSessionFast();
        if (restoredFromCache) {
          _startWindowsAuthPolling();
          unawaited(_verifyWindowsSessionInBackground());
          return;
        }

        final firebaseUser = await _waitForWindowsFirebaseUser(
          timeout: const Duration(seconds: 2),
        );
        await _applyFirebaseUser(firebaseUser);
        _startWindowsAuthPolling();
        return;
      }

      final authStream = _firebase.auth?.authStateChanges();

      if (authStream != null) {
        _authSubscription = authStream.listen(
          (firebaseUser) async {
            await _applyFirebaseUser(firebaseUser);
          },
          onError: (error) {
            AppLogger.error('Auth state error', error: error, tag: 'Auth');
            _state = _state.copyWith(loading: false);
            notifyListeners();
          },
        );
      } else {
        // Auth not available
        _state = _state.copyWith(loading: false);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Auth initialization error', error: e, tag: 'Auth');
      _identityValidated = false;
      _state = _state.copyWith(loading: false);
      notifyListeners();
    }
  }

  AppUser _mapUserEntityToAppUser(UserEntity entity) {
    final user = entity.toDomain();
    AppLogger.info(
      'Mapped user ${user.email} to role: ${user.role.value}',
      tag: 'Auth',
    );
    return user;
  }

  Future<AppUser?> _fetchUserDetails(String uid) async {
    try {
      final authUser = _firebase.auth?.currentUser;
      final firestoreDb = _firebase.db;
      final remote = firestoreDb == null
          ? null
          : FirestoreQueryDelegate(firestoreDb);

      // Rule: Identity must be verified online at every startup/refresh
      if (remote != null && authUser != null && authUser.email != null) {
        try {
          var docSnapshot = await remote.getDocument(
            collection: 'users',
            documentId: uid,
          );
          final authEmail = authUser.email?.toLowerCase();

          // Multi-pass lookup for legacy compatibility
          if (!docSnapshot.exists) {
            AppLogger.info(
              'User profile not found by UID ($uid), attempting fallback lookups for $authEmail',
              tag: 'Auth',
            );

            // 1. Direct email document lookup
            docSnapshot = await remote.getDocument(
              collection: 'users',
              documentId: authEmail ?? '',
            );

            // 2. Targeted query by email field (for legacy/mixed-case IDs)
            if (!docSnapshot.exists) {
              var query = await remote.getCollection(
                collection: 'users',
                filters: <FirestoreQueryFilter>[
                  FirestoreQueryFilter(
                    field: 'email',
                    operator: FirestoreQueryOperator.isEqualTo,
                    value: authEmail,
                  ),
                ],
                limit: 1,
              );

              // Fallback for mixed-case in Firestore
              if (query.docs.isEmpty && authUser.email != null) {
                query = await remote.getCollection(
                  collection: 'users',
                  filters: <FirestoreQueryFilter>[
                    FirestoreQueryFilter(
                      field: 'email',
                      operator: FirestoreQueryOperator.isEqualTo,
                      value: authUser.email,
                    ),
                  ],
                  limit: 1,
                );
              }

              if (query.docs.isNotEmpty) {
                docSnapshot = query.docs.first;
              }
            }
          }

          if (docSnapshot.exists) {
            final data = docSnapshot.data();
            final isActive = _resolveIsActive(data?['isActive'], data?['status']);
            final normalizedStatus = _normalizeAccountStatus(
              data?['status'],
              fallbackIsActive: isActive,
            );
            final firestoreEmail = data?['email']?.toString().toLowerCase();

            // Strict Validation
            if (isActive && firestoreEmail == authEmail) {
              await IdentityRevalidationState.markValidated(
                uid: authUser.uid,
                reason: 'firestore_profile_verified',
              );
              final updatedEntity = UserEntity()
                ..id = docSnapshot
                    .id // Use the ACTUAL Firestore Document ID
                ..email = authUser.email ?? ''
                ..name = data?['name'] ?? 'User'
                ..role = data?['role']
                ..phone = data?['phone'] ?? data?['mobile']
                ..department = data?['department']
                ..designation = data?['designation']
                ..departmentsJson = jsonEncode(data?['departments'] ?? [])
                ..assignedRoutes = data?['assignedRoutes'] != null
                    ? List<String>.from(data?['assignedRoutes'])
                    : null
                ..allocatedStockJson = data?['allocatedStock'] != null
                    ? jsonEncode(data?['allocatedStock'])
                    : null
                ..assignedBhatti = data?['assignedBhatti']
                ..assignedBaseProductId = data?['assignedBaseProductId']
                ..assignedBaseProductName = data?['assignedBaseProductName']
                ..assignedVehicleId = data?['assignedVehicleId']
                ..assignedVehicleName = data?['assignedVehicleName']
                ..assignedVehicleNumber = data?['assignedVehicleNumber']
                ..assignedDeliveryRoute = data?['assignedDeliveryRoute']
                ..assignedSalesRoute = data?['assignedSalesRoute']
                ..status = normalizedStatus
                ..isActive = isActive
                ..updatedAt = DateTime.now();

              await _authRepo.saveUser(updatedEntity);
              return _mapUserEntityToAppUser(updatedEntity);
            } else {
              AppLogger.warning(
                'Security check failed for $uid: active=$isActive, email_match=${firestoreEmail == authEmail}',
                tag: 'Auth',
              );
              // Force sign out if security check fails online
              await signOut();
              return null;
            }
          } else {
            AppLogger.warning(
              'User profile missing in Firestore: $uid (Email: ${authUser.email})',
              tag: 'Auth',
            );
            await _firebase.auth?.signOut();
            throw FirebaseAuthException(
              code: 'user-not-found',
              message:
                  'Access Denied: No Firestore profile found for this user.',
            );
          }
        } catch (e) {
          AppLogger.error(
            'Firestore verification failed during refresh: $e',
            tag: 'Auth',
          );

          // [AUTH_LOCK_OVERRIDE] - Enabling Offline Session Restoration
          AppLogger.info(
            'Attempting offline session restoration...',
            tag: 'Auth',
          );
          await IdentityRevalidationState.markPending(
            uid: authUser.uid,
            reason: 'offline_restore_without_revalidation',
          );
          try {
            final localUser = await _authRepo.getCurrentUser();
            if (localUser != null && localUser.isActive) {
              AppLogger.success(
                'Offline session restored for ${localUser.email}',
                tag: 'Auth',
              );
              return _mapUserEntityToAppUser(localUser);
            }
          } catch (offlineError) {
            AppLogger.error(
              'Offline restoration failed: $offlineError',
              tag: 'Auth',
            );
          }

          // If really dead/invalid, return null
          await IdentityRevalidationState.markPending(
            uid: authUser.uid,
            reason: 'identity_verification_failed',
          );
          return null;
        }
      }

      // 2. Strict Online Policy: If we can't reach Firestore, we don't grant authenticated status
      await IdentityRevalidationState.markPending(
        uid: authUser?.uid,
        reason: 'missing_firestore_or_auth_context',
      );
      return null;
    } catch (e) {
      AppLogger.error('Error fetching user details', error: e, tag: 'Auth');
      await IdentityRevalidationState.markPending(
        uid: _firebase.auth?.currentUser?.uid,
        reason: 'fetch_user_details_exception',
      );
      return null;
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _state = _state.copyWith(loading: true);
      notifyListeners();

      final userEntity = await _authRepo.signIn(email, password);
      final appUser = _mapUserEntityToAppUser(userEntity);
      final authUid = _firebase.auth?.currentUser?.uid;
      if (authUid != null && authUid.trim().isNotEmpty) {
        await IdentityRevalidationState.markValidated(
          uid: authUid,
          reason: 'online_sign_in_success',
        );
        _identityValidated = true;
      } else {
        _identityValidated = false;
      }

      _state = _state.copyWith(user: appUser, loading: false);
      notifyListeners();
    } catch (e) {
      AppLogger.error('SignIn error in Provider', error: e, tag: 'Auth');
      _identityValidated = false;
      await IdentityRevalidationState.markPending(
        uid: _firebase.auth?.currentUser?.uid,
        reason: 'sign_in_failed',
      );
      _state = _state.copyWith(loading: false);
      notifyListeners();
      rethrow;
    }
  }

  // [AUTH_LOCK_OVERRIDE] - Adding cleanup callback for logout
  FutureOr<void> Function()? _onSignOut;
  void setOnSignOut(FutureOr<void> Function() callback) =>
      _onSignOut = callback;

  Future<void> signOut() async {
    if (_isSigningOut) {
      AppLogger.info(
        'SignOut already in progress. Skipping duplicate call.',
        tag: 'Auth',
      );
      return;
    }
    _isSigningOut = true;
    try {
      // CRITICAL FIX: Stop all listeners FIRST before clearing auth
      // This prevents permission-denied errors during logout
      await _authSubscription?.cancel();
      _authSubscription = null;
      _windowsAuthPollTimer?.cancel();
      _windowsAuthPollTimer = null;
      _lastObservedFirebaseUid = null;

      // Clear user state so UI/services can stop role-scoped operations
      _state = AuthState(user: null, loading: true);
      notifyListeners();

      Future<void> runBestEffortStep(
        String label,
        Future<void> Function() step, {
        Duration? timeout,
      }) async {
        try {
          final operation = step();
          if (timeout == null) {
            await operation;
            return;
          }
          await operation.timeout(
            timeout,
            onTimeout: () {
              AppLogger.warning(
                '$label timed out after ${timeout.inSeconds}s',
                tag: 'Auth',
              );
            },
          );
        } catch (e) {
          AppLogger.warning('$label failed: $e', tag: 'Auth');
        }
      }

      // Execute cleanup callback (stops sync manager)
      await runBestEffortStep('Logout cleanup', () async {
        final callback = _onSignOut;
        if (callback == null) return;
        await Future<void>.value(callback());
      }, timeout: const Duration(seconds: 4));

      // Perform Repo signOut (Isar + Firebase)
      await runBestEffortStep(
        'Repository signOut',
        () => _authRepo.signOut(),
        timeout: const Duration(seconds: 6),
      );

      // Update state to unauthenticated
      _state = AuthState(user: null, loading: false);
      _identityValidated = false;
      await IdentityRevalidationState.clear(reason: 'sign_out');
      AppLogger.info('SignOut complete. State reset.', tag: 'Auth');
    } catch (e) {
      AppLogger.error('Sign out error', error: e, tag: 'Auth');
      _identityValidated = false;
      _state = _state.copyWith(loading: false);
    } finally {
      _isSigningOut = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebase.auth?.sendPasswordResetEmail(email: email);
  }

  Future<void> refreshUser() async {
    final currentUser = _firebase.auth?.currentUser;
    if (currentUser != null) {
      final appUser = await _fetchUserDetails(currentUser.uid);
      _identityValidated =
          appUser != null &&
          await IdentityRevalidationState.isValidatedForUid(currentUser.uid);
      _state = _state.copyWith(user: appUser, loading: false);
      notifyListeners();
    } else {
      _identityValidated = false;
      await IdentityRevalidationState.clear(reason: 'refresh_without_auth_user');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _windowsAuthPollTimer?.cancel();
    super.dispose();
  }
}
