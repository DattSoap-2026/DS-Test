import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/types/alert_types.dart';
import 'auth/auth_provider.dart';
import 'service_providers.dart';

final alertsFutureProvider = FutureProvider<List<SystemAlert>>((ref) async {
  final authState = ref.watch(authProviderProvider);
  final alertService = ref.watch(alertServiceProvider);

  if (authState.currentUser == null) return [];

  return alertService.getAllAlerts(user: authState.currentUser);
});
