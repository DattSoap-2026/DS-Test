import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

import '../constants/role_access_matrix.dart';
import '../data/local/entities/user_entity.dart';
import '../models/types/user_types.dart';
import '../utils/app_logger.dart';
import 'database_service.dart';
import 'identity_revalidation_state.dart';

/// Service-layer authorization helper.
/// Resolves current actor from Auth + local Isar and enforces capabilities.
class ServiceCapabilityGuard {
  ServiceCapabilityGuard({
    required FirebaseAuth? auth,
    required DatabaseService dbService,
  }) : _auth = auth,
       _dbService = dbService;

  final FirebaseAuth? _auth;
  final DatabaseService _dbService;

  Future<AppUser> requireValidatedActor({
    required String operation,
    bool requireIdentityRevalidation = true,
  }) async {
    final authUser = _auth?.currentUser;
    if (authUser == null) {
      throw Exception('Authentication required for $operation.');
    }

    if (requireIdentityRevalidation) {
      final validated = await IdentityRevalidationState.isValidatedForUid(
        authUser.uid,
      );
      if (!validated) {
        throw Exception(
          'Identity revalidation pending. $operation is blocked in read-only mode.',
        );
      }
    }

    final actor = await resolveCurrentUser();
    if (actor == null) {
      throw Exception(
        'Authenticated actor could not be resolved locally for $operation.',
      );
    }
    if (!actor.isActive) {
      throw Exception('Inactive actor cannot perform $operation.');
    }
    if (!_isActorBoundToAuth(actor, authUser)) {
      throw Exception(
        'Identity mismatch detected. $operation blocked by fail-closed guard.',
      );
    }
    return actor;
  }

  Future<AppUser> requireCapability(
    RoleCapability capability, {
    required String operation,
    bool requireIdentityRevalidation = true,
  }) async {
    final actor = await requireValidatedActor(
      operation: operation,
      requireIdentityRevalidation: requireIdentityRevalidation,
    );
    if (!RoleAccessMatrix.hasCapability(actor.role, capability)) {
      throw Exception(
        'Access denied for $operation. '
        'Role ${actor.role.value} lacks ${capability.name}.',
      );
    }
    return actor;
  }

  Future<AppUser> requireRoleAccess(
    Set<UserRole> allowedRoles, {
    required String operation,
    bool requireIdentityRevalidation = true,
  }) async {
    final actor = await requireValidatedActor(
      operation: operation,
      requireIdentityRevalidation: requireIdentityRevalidation,
    );
    if (!allowedRoles.contains(actor.role)) {
      throw Exception(
        'Access denied for $operation. Role ${actor.role.value} is not allowed.',
      );
    }
    return actor;
  }

  Future<AppUser> requireCapabilityOrRole({
    required String operation,
    RoleCapability? capability,
    Set<UserRole> allowedRoles = const <UserRole>{},
    bool requireIdentityRevalidation = true,
  }) async {
    final actor = await requireValidatedActor(
      operation: operation,
      requireIdentityRevalidation: requireIdentityRevalidation,
    );

    final hasCapability =
        capability != null &&
        RoleAccessMatrix.hasCapability(actor.role, capability);
    final hasRoleOverride = allowedRoles.contains(actor.role);
    if (!hasCapability && !hasRoleOverride) {
      final capabilityLabel = capability == null ? 'none' : capability.name;
      throw Exception(
        'Access denied for $operation. '
        'Role ${actor.role.value} lacks capability=$capabilityLabel and role override.',
      );
    }
    return actor;
  }

  Future<AppUser?> resolveCurrentUser() async {
    final authUser = _auth?.currentUser;
    if (authUser == null) return null;

    final uid = authUser.uid.trim();
    final normalizedEmail = authUser.email?.trim().toLowerCase();

    try {
      if (uid.isNotEmpty) {
        final byUid = await _dbService.users.filter().idEqualTo(uid).findFirst();
        if (byUid != null) return byUid.toDomain();
      }

      if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
        final byEmailId = await _dbService.users
            .filter()
            .idEqualTo(normalizedEmail)
            .findFirst();
        if (byEmailId != null) return byEmailId.toDomain();

        final byEmailField = await _dbService.users
            .filter()
            .emailEqualTo(normalizedEmail, caseSensitive: false)
            .findFirst();
        if (byEmailField != null) return byEmailField.toDomain();
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to resolve current user for capability guard: $e',
        tag: 'Security',
      );
    }

    return null;
  }

  bool _isActorBoundToAuth(AppUser actor, User authUser) {
    final authUid = authUser.uid.trim();
    final authEmail = authUser.email?.trim().toLowerCase();
    final actorId = actor.id.trim();
    final actorEmail = actor.email.trim().toLowerCase();

    if (actorId.isNotEmpty && actorId == authUid) {
      return true;
    }
    if (authEmail != null && authEmail.isNotEmpty) {
      if (actorId.toLowerCase() == authEmail) {
        return true;
      }
      if (actorEmail == authEmail) {
        return true;
      }
    }
    return false;
  }
}
