import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/types/user_types.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../widgets/ui/master_screen_header.dart';
import '../../../widgets/ui/unified_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../widgets/accounting_shortcuts_scope.dart';
import '../accounting_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountingDashboardScreen extends ConsumerStatefulWidget {
  const AccountingDashboardScreen({super.key});

  @override
  ConsumerState<AccountingDashboardScreen> createState() =>
      _AccountingDashboardScreenState();
}

class _AccountingDashboardScreenState
    extends ConsumerState<AccountingDashboardScreen> {
  void _refresh() {
    ref.invalidate(accountingDashboardDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProviderProvider).state.user;
    if (auth == null) {
      return const Center(child: Text('User not found'));
    }

    final canView =
        auth.role == UserRole.accountant ||
        auth.role == UserRole.admin ||
        auth.role == UserRole.owner;
    if (!canView) {
      return const Center(
        child: Text('Accounting dashboard is available for accountant users.'),
      );
    }

    final accountantMode = auth.role == UserRole.accountant;
    final dashboardDataAsync = ref.watch(accountingDashboardDataProvider);

    return AccountingShortcutsScope(
      currentRole: auth.role,
      onChangeDate: _refresh,
      child: Scaffold(
        body: dashboardDataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Failed to load accounting data: $err')),
          data: (data) {
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: MasterScreenHeader(
                      title: 'Accounting',
                      subtitle: accountantMode
                          ? 'Financial Overview & Entry'
                          : 'Financial Overview',
                      icon: Icons.account_balance_wallet_outlined,
                      color: theme.colorScheme.primary,
                      isDashboardHeader: true,
                      helperText:
                          'Manage vouchers, ledgers, and view financial summaries.',
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFinancialOverview(context, data),
                          const SizedBox(height: 24),
                          if (accountantMode) ...[
                            Text(
                              'Quick Actions',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActions(context),
                            const SizedBox(height: 24),
                          ],
                          Text(
                            'Ledger Drill-down',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final account = data.accounts[index];
                        final code = (account['code'] ?? '').toString();
                        final name = (account['name'] ?? code).toString();
                        if (code.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: UnifiedCard(
                            onTap: () => context.go(
                              '/dashboard/accounting/ledger/$code',
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  code.substring(0, 1),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(code),
                              trailing: const Icon(
                                Icons.chevron_right,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      }, childCount: data.accounts.take(20).length),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(
    BuildContext context,
    AccountingDashboardData data,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final cashColor = AppColors.success;
    final bankColor = AppColors.info;
    final receivablesColor = AppColors.warning;
    final payablesColor = AppColors.error;
    final outputGstColor = scheme.tertiary;
    final inputGstColor = scheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final double cardWidth = isWide
            ? (constraints.maxWidth - 32) / 3
            : (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _metricCard(
              'Cash Balance',
              data.cashBalance,
              Icons.attach_money,
              cashColor,
              width: cardWidth,
            ),
            _metricCard(
              'Bank Balance',
              data.bankBalance,
              Icons.account_balance,
              bankColor,
              width: cardWidth,
            ),
            _metricCard(
              'Receivables',
              data.outstandingReceivables,
              Icons.arrow_circle_down,
              receivablesColor,
              width: cardWidth,
            ),
            _metricCard(
              'Payables',
              data.outstandingPayables,
              Icons.arrow_circle_up,
              payablesColor,
              width: cardWidth,
            ),
            _metricCard(
              'Output GST',
              data.outputGst,
              Icons.trending_up,
              outputGstColor,
              width: cardWidth,
            ),
            _metricCard(
              'Input GST',
              data.inputGst,
              Icons.trending_down,
              inputGstColor,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(
    String label,
    double amount,
    IconData icon,
    Color color, {
    double? width,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: UnifiedCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: amount < 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _VoucherActionButton(
          type: 'sales',
          icon: Icons.shopping_cart,
          label: 'Sales',
          color: AppColors.success,
        ),
        _VoucherActionButton(
          type: 'purchase',
          icon: Icons.shopping_bag,
          label: 'Purchase',
          color: AppColors.info,
        ),
        _VoucherActionButton(
          type: 'payment',
          icon: Icons.payment,
          label: 'Payment',
          color: AppColors.error,
        ),
        _VoucherActionButton(
          type: 'receipt',
          icon: Icons.receipt,
          label: 'Receipt',
          color: AppColors.warning,
        ),
        _VoucherActionButton(
          type: 'journal',
          icon: Icons.book,
          label: 'Journal',
          color: scheme.tertiary,
        ),
        _VoucherActionButton(
          type: 'contra',
          icon: Icons.swap_horiz,
          label: 'Contra',
          color: scheme.primary,
        ),
      ],
    );
  }
}

class _VoucherActionButton extends StatelessWidget {
  final String type;
  final IconData icon;
  final String label;
  final Color color;

  const _VoucherActionButton({
    required this.type,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/dashboard/accounting/vouchers/$type'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
