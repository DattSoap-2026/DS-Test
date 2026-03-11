import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/diesel_service.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class DriverDieselLogScreen extends StatefulWidget {
  const DriverDieselLogScreen({super.key});

  @override
  State<DriverDieselLogScreen> createState() => _DriverDieselLogScreenState();
}

class _DriverDieselLogScreenState extends State<DriverDieselLogScreen> {
  late final DieselService _dieselService;
  bool _isLoading = true;
  List<DieselLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      // We need a method to fetch logs by driver
      final logs = await _dieselService.getDieselLogsByDriver(user.name);
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diesel Logs'),
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return _buildLogCard(log);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'diesel_log_fab',
        onPressed: () async {
          final refresh = await context.push('/dashboard/vehicles/diesel/add');
          if (refresh == true) _loadLogs();
        },
        backgroundColor: const Color(0xFF4f46e5),
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_gas_station,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          const Text(
            'No diesel logs found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Tap + to log fuel consumption'),
        ],
      ),
    );
  }

  Widget _buildLogCard(DieselLog log) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${log.liters} Liters',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '₹${log.rate}/L | Total: ₹${log.totalCost.toStringAsFixed(2)}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                _buildMileageBadge(log.mileage),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconDetail(Icons.speed, '${log.odometer} km'),
                Text(
                  _formatDate(log.date),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMileageBadge(double? mileage) {
    if (mileage == null) return const SizedBox();
    final isGood = mileage > 4.0; // Example threshold
    return Column(
      children: [
        Text(
          '${mileage.toStringAsFixed(2)} kmpl',
          style: TextStyle(
            color: isGood ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          isGood ? 'Good' : 'Low',
          style: TextStyle(
            color: isGood ? AppColors.success : AppColors.error,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _iconDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.info),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatDate(String ts) {
    final date = DateTime.tryParse(ts);
    if (date == null) return ts;
    return '${date.day}/${date.month}/${date.year}';
  }
}

