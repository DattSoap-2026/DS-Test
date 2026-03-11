import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../models/types/user_types.dart';

class AccountingShortcutsScope extends StatelessWidget {
  final UserRole currentRole;
  final Widget child;
  final VoidCallback? onChangeDate;
  final VoidCallback? onSaveVoucher;
  final VoidCallback? onCancel;
  final bool? desktopOverride;

  const AccountingShortcutsScope({
    super.key,
    required this.currentRole,
    required this.child,
    this.onChangeDate,
    this.onSaveVoucher,
    this.onCancel,
    this.desktopOverride,
  });

  bool get _isDesktop {
    if (desktopOverride != null) return desktopOverride!;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    if (currentRole != UserRole.accountant || !_isDesktop) {
      return child;
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): () {
          onChangeDate?.call();
        },
        const SingleActivator(LogicalKeyboardKey.f4): () {
          context.go('/dashboard/accounting/vouchers/contra');
        },
        const SingleActivator(LogicalKeyboardKey.f5): () {
          context.go('/dashboard/accounting/vouchers/payment');
        },
        const SingleActivator(LogicalKeyboardKey.f6): () {
          context.go('/dashboard/accounting/vouchers/receipt');
        },
        const SingleActivator(LogicalKeyboardKey.f7): () {
          context.go('/dashboard/accounting/vouchers/journal');
        },
        const SingleActivator(LogicalKeyboardKey.f8): () {
          context.go('/dashboard/accounting/vouchers/sales');
        },
        const SingleActivator(LogicalKeyboardKey.f9): () {
          context.go('/dashboard/accounting/vouchers/purchase');
        },
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          onSaveVoucher?.call();
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          onCancel?.call();
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
