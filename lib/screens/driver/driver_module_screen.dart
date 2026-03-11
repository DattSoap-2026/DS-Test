import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class DriverModuleScreen extends StatefulWidget {
  const DriverModuleScreen({super.key});

  @override
  State<DriverModuleScreen> createState() => _DriverModuleScreenState();
}

class _DriverModuleScreenState extends State<DriverModuleScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;
    final colorScheme = Theme.of(context).colorScheme;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }

    if (user.role != UserRole.driver && user.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: const Color(0xFF4f46e5),
          foregroundColor: colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Driver access required for this module',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Module'),
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: colorScheme.onPrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 520 ? 1 : 2;
          final childAspectRatio = constraints.maxWidth < 520 ? 1.45 : 1.05;
          return GridView.count(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildDriverCard(
                'My Duty',
                Icons.work,
                AppColors.info,
                'View your assigned duty for today',
                '/dashboard/driver/duty',
                user.role == UserRole.driver,
              ),
              _buildDriverCard(
                'My Route',
                Icons.map,
                AppColors.success,
                'View your delivery route and stops',
                '/dashboard/driver/route',
                user.role == UserRole.driver,
              ),
              _buildDriverCard(
                'My Diesel Log',
                Icons.local_gas_station,
                AppColors.warning,
                'Log diesel consumption for your vehicle',
                '/dashboard/driver/diesel',
                user.role == UserRole.driver,
              ),
              _buildDriverCard(
                'Trip History',
                Icons.history,
                AppColors.info,
                'View your past trips and deliveries',
                '/dashboard/driver/trips',
                user.role == UserRole.driver,
              ),
              _buildDriverCard(
                'My Vehicle',
                Icons.directions_car,
                AppColors.lightPrimary,
                'View your assigned vehicle details',
                '/dashboard/driver/vehicle',
                user.role == UserRole.driver,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDriverCard(
    String title,
    IconData icon,
    Color color,
    String description,
    String route,
    bool isAccessible,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: isAccessible ? 1.0 : 0.5,
      child: Card(
        elevation: isAccessible ? 8 : 1,
        child: InkWell(
        onTap: isAccessible
            ? () => context.push(route)
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Driver access required for $title')),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isAccessible)
                const SizedBox(height: 8),
              if (!isAccessible)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
                  ),
                  child: Text(
                    'Driver Only',
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
        ),
    );
  }
}

