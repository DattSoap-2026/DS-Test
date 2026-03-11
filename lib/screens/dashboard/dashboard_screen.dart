import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import 'admin_dashboard_screen.dart'; // Added for premium dashboard
import '../bhatti/bhatti_dashboard_screen.dart';
import 'salesman_dashboard_screen.dart';
import 'dealer_dashboard_screen.dart';
import 'fuel_incharge_dashboard_screen.dart';
import '../production/production_dashboard_consolidated_screen.dart';
import '../../modules/accounting/screens/accounting_dashboard_screen.dart';
import '../../widgets/dashboard/target_analysis_widget.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/master_screen_header.dart'; // Replaced PremiumHeader
import '../../widgets/responsive/responsive_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().state;
    final user = authState.user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text('User not found. Please log in again.'));
    }

    if (user.role == UserRole.admin ||
        user.role == UserRole.owner ||
        user.role == UserRole.storeIncharge) {
      return const AdminDashboardScreen();
    }

    if (user.role == UserRole.bhattiSupervisor) {
      return const BhattiDashboardScreen();
    }

    if (user.role == UserRole.productionSupervisor) {
      return const ProductionDashboardConsolidatedScreen();
    }

    if (user.role == UserRole.salesman) {
      return const SalesmanDashboardScreen();
    }

    if (user.role == UserRole.fuelIncharge) {
      return const FuelInchargeDashboardScreen();
    }

    if (user.role == UserRole.dealerManager) {
      return const DealerDashboardScreen();
    }

    if (user.role == UserRole.accountant) {
      return const AccountingDashboardScreen();
    }

    return Column(
      children: [
        MasterScreenHeader(
          title: 'Welcome, ${user.name}!',
          subtitle: 'Performance overview',
          isDashboardHeader: true,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Removed redundant SizedBox(height) since header has padding
                const TargetAnalysisWidget(showDailyBreakdown: false),
                const SizedBox(height: 32),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                AdaptiveGrid(
                  minTileWidth: 220,
                  maxColumns: 3,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildQuickAction(
                      context,
                      'New Sale',
                      Icons.shopping_cart_outlined,
                      theme.colorScheme.primary,
                      '/dashboard/sales/new',
                    ),
                    _buildQuickAction(
                      context,
                      'Customer Map',
                      Icons.map_outlined,
                      theme.colorScheme.secondary,
                      '/dashboard/map-view/customers',
                    ),
                    _buildQuickAction(
                      context,
                      'My Stock',
                      Icons.inventory_2_outlined,
                      theme.colorScheme.tertiary,
                      '/dashboard/inventory/stock-overview',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    return UnifiedCard(
      onTap: () => context.go(route),
      backgroundColor: color.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
