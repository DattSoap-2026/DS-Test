import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/types/alert_types.dart';
import 'auth/auth_provider.dart';
import 'service_providers.dart';

final alertsFutureProvider = FutureProvider<List<SystemAlert>>((ref) async {
  final alertService = ref.watch(alertServiceProvider);
  final auth = ref.watch(authProviderProvider);
  return alertService.getAllAlerts(user: auth.currentUser);
});
