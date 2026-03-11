import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/custom_button.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AccountPendingScreen extends StatelessWidget {
  const AccountPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: UnifiedCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pending_actions_rounded,
                      size: 80,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Account Pending Configuration',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your account is not fully configured. Please contact Admin to assign your Role, Department, and Team.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (user != null) ...[
                    _buildInfoRow(context, 'Name', user.name),
                    _buildInfoRow(context, 'Email', user.email),
                    _buildInfoRow(context, 'Role', user.role.value),
                    _buildInfoRow(
                      context,
                      'Dept',
                      user.department ?? 'Not Assigned',
                    ),
                  ],
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        onPressed: () => authProvider.signOut(),
                        icon: Icons.logout,
                        label: const String.fromEnvironment(
                          'LOGOUT_LABEL',
                          defaultValue: 'Logout',
                        ),
                        variant: ButtonVariant.outline,
                        isDense: true,
                      ),
                      const SizedBox(width: 16),
                      CustomButton(
                        onPressed: () => authProvider.refreshUser(),
                        icon: Icons.refresh,
                        label: 'Refresh',
                        variant: ButtonVariant.primary,
                        isDense: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value.isEmpty ? 'N/A' : value),
        ],
      ),
    );
  }
}

