import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/responsive/responsive_layout.dart';
import '../../widgets/ui/master_screen_header.dart';

class ReportsModuleScreen extends StatefulWidget {
  const ReportsModuleScreen({super.key});

  @override
  State<ReportsModuleScreen> createState() => _ReportsModuleScreenState();
}

class _ReportsModuleScreenState extends State<ReportsModuleScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;
    final colorScheme = Theme.of(context).colorScheme;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }

    // Check if user has access to production/cutting reports
    final hasAccess =
        user.role == UserRole.admin ||
        user.role == UserRole.productionSupervisor;

    if (!hasAccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You do not have access to this module',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact your administrator for access',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final config = Responsive.configOf(context);

    return Scaffold(
      body: Column(
        children: [
          const MasterScreenHeader(
            title: 'Production Reports',
            subtitle: 'Cutting, waste, and production analytics',
            icon: Icons.summarize_rounded,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(config.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cutting & Finished Goods',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  AdaptiveGrid(
                    minTileWidth: config.isMobile ? 280 : 340,
                    maxColumns: 2,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildReportCard(
                        'Cutting Yield',
                        Icons.trending_up,
                        AppColors.info,
                        'Track production yield',
                        '/dashboard/reports/cutting-yield',
                      ),
                      _buildReportCard(
                        'Waste Analysis',
                        Icons.delete,
                        AppColors.error,
                        'Analyze waste patterns',
                        '/dashboard/reports/waste-analysis',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Production',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  AdaptiveGrid(
                    minTileWidth: config.isMobile ? 280 : 340,
                    maxColumns: 2,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildReportCard(
                        'Production Report',
                        Icons.factory,
                        AppColors.warning,
                        'View production statistics',
                        '/dashboard/reports/production',
                      ),
                      _buildReportCard(
                        'Tally Export',
                        Icons.file_download,
                        AppColors.success,
                        'Export data to Tally',
                        '/dashboard/reports/tally-export',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    String route,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.go(route),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 32, color: color),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward, color: color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


