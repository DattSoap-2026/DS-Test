import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth/auth_provider.dart';
import '../models/types/user_types.dart';
import 'ui_notifier.dart';

/// Access Guard - Role-based screen access control
/// 
/// Usage in screen initState:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   AccessGuard.checkBhattiAccess(context);
/// }
/// ```
class AccessGuard {
  static void checkAccess(
    BuildContext context, {
    required bool Function(UserRole) hasAccess,
    required String deniedMessage,
  }) {
    final user = context.read<AuthProvider>().currentUser;
    
    if (user == null || !hasAccess(user.role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pop();
          UINotifier.showError(deniedMessage);
        }
      });
    }
  }

  static void checkBhattiAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessBhatti,
      deniedMessage: 'Access Denied: Bhatti operations only',
    );
  }

  static void checkProductionAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessProduction,
      deniedMessage: 'Access Denied: Production operations only',
    );
  }

  static void checkRawMaterialsAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessRawMaterials,
      deniedMessage: 'Access Denied: Raw materials access only',
    );
  }

  static void checkFinishedGoodsAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessFinishedGoods,
      deniedMessage: 'Access Denied: Finished goods access only',
    );
  }
}
