import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/responsive/responsive_layout.dart';

class ManagementModuleScreen extends StatelessWidget {
  const ManagementModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;

    final allowedRoles = [
      UserRole.admin,
      UserRole.owner,
      UserRole.bhattiSupervisor,
      UserRole.productionManager,
    ];

    // Basic Access Control
    if (user == null || !allowedRoles.contains(user.role)) {
      return const Scaffold(
        body: Center(child: Text('Management access required.')),
      );
    }

    final config = Responsive.configOf(context);

    return Scaffold(
      body: Column(
        children: [
          const MasterScreenHeader(
            title: 'Management',
            subtitle: 'Define core masters and production configurations',
            icon: Icons.settings_applications_rounded,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(config.horizontalPadding),
              child: AdaptiveGrid(
                minTileWidth: config.isMobile ? 280 : 320,
                maxColumns: config.isLargeDesktop ? 4 : 3,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildManagementCard(
                    context,
                    'Product Catalog',
                    Icons.inventory_2,
                    AppColors.success,
                    '/dashboard/management/products',
                  ),
                  _buildManagementCard(
                    context,
                    'Production Config',
                    Icons.science,
                    AppColors.info,
                    '/dashboard/management/formulas',
                  ),
                  _buildManagementCard(
                    context,
                    'Master Data',
                    Icons.settings_applications,
                    AppColors.info,
                    '/dashboard/management/master-data',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

