import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'fuel_stock_screen.dart';
import 'fuel_log_screen.dart';
import 'fuel_history_screen.dart';

class FuelManagementScreen extends StatefulWidget {
  const FuelManagementScreen({super.key});

  @override
  State<FuelManagementScreen> createState() => _FuelManagementScreenState();
}

class _FuelManagementScreenState extends State<FuelManagementScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }

    if (user.role != UserRole.admin &&
        user.role != UserRole.storeIncharge &&
        user.role != UserRole.fuelIncharge) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'You do not have access to this module',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact your administrator for access',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      animationDuration: const Duration(milliseconds: 200),
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: theme.colorScheme.surface,
              child: ThemedTabBar(
                onTap: (index) => setState(() => _selectedTabIndex = index),
                tabs: const [
                  Tab(text: 'Fuel Stock'),
                  Tab(text: 'Fuel Log'),
                  Tab(text: 'History'),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: const [
                  FuelStockScreen(),
                  FuelLogScreen(),
                  FuelHistoryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
