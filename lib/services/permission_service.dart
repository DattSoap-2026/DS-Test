import '../constants/role_access_matrix.dart';
import '../models/types/user_types.dart';

class PermissionService {
  bool canAccessPathLayered(AppUser user, String path) {
    return RoleAccessMatrix.canAccessPath(user.role, path);
  }

  String reportHomePathForRole(UserRole role) {
    return RoleAccessMatrix.reportHomePathForRole(role);
  }

  String landingPathForRole(UserRole role) {
    return RoleAccessMatrix.landingPathForRole(role);
  }

  bool hasCapabilityForRole(UserRole role, RoleCapability capability) {
    return RoleAccessMatrix.hasCapability(role, capability);
  }

  bool canAccessMapPathForRole(UserRole role, String path) {
    return RoleAccessMatrix.canAccessMapPath(role, path);
  }

  bool isLegacyRole(UserRole role) {
    return RoleAccessMatrix.isLegacyRole(role);
  }
}
