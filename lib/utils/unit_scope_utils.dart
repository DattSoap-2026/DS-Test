import '../models/types/user_types.dart';

class UserUnitScope {
  final bool canViewAll;
  final Set<String> keys;

  const UserUnitScope({required this.canViewAll, required this.keys});

  String get label {
    if (canViewAll) {
      return 'All Units';
    }
    if (keys.isEmpty) {
      return 'No Assigned Unit';
    }
    final labels = <String>[];
    if (keys.contains('sona')) labels.add('Sona');
    if (keys.contains('gita')) labels.add('Gita');
    if (labels.isEmpty) {
      return 'Department Scoped';
    }
    return labels.join(', ');
  }
}

String normalizeUnitKey(String? value) {
  final raw = (value ?? '').trim().toLowerCase();
  if (raw.isEmpty) return '';

  final compact = raw
      .replaceAll(RegExp(r'[_:\-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (compact == 'all' || compact == 'all units' || compact == 'all unit') {
    return 'all';
  }
  if (compact.contains('gita') || compact.contains('geeta')) return 'gita';
  if (compact.contains('sona')) return 'sona';
  // Keep generic bhatti as neutral scope; do not force it to Sona.
  if (compact.contains('bhatti')) return 'bhatti';
  if (compact.contains('production') || compact.contains('prod')) {
    return 'production';
  }
  return compact;
}

UserUnitScope resolveUserUnitScope(AppUser? user) {
  if (user == null) {
    return const UserUnitScope(canViewAll: true, keys: {});
  }

  final fullAccess =
      user.isAdmin ||
      user.isStoreIncharge ||
      user.role == UserRole.productionManager;
  if (fullAccess) {
    return const UserUnitScope(canViewAll: true, keys: {});
  }

  final keys = <String>{};

  void addKey(String? value) {
    final normalized = normalizeUnitKey(value);
    if (normalized.isNotEmpty) keys.add(normalized);
  }

  addKey(user.assignedBhatti);
  addKey(user.department);

  bool hasTeamAssignment = false;
  bool hasProductionWithoutTeam = false;
  for (final dept in user.departments) {
    addKey(dept.main);
    addKey(dept.team);
    if ((dept.team ?? '').trim().isNotEmpty) {
      hasTeamAssignment = true;
    }
    final main = dept.main.trim().toLowerCase();
    final isProductionMain =
        main.contains('production') || main.contains('bhatti');
    if (isProductionMain && (dept.team == null || dept.team!.trim().isEmpty)) {
      hasProductionWithoutTeam = true;
    }
  }

  if (keys.contains('all') ||
      (hasProductionWithoutTeam && !hasTeamAssignment)) {
    return const UserUnitScope(canViewAll: true, keys: {});
  }

  // If a user has explicit unit assignment, avoid broad generic keys.
  if (keys.contains('gita') || keys.contains('sona')) {
    keys.remove('bhatti');
    keys.remove('production');
  }

  if (keys.isEmpty) {
    return const UserUnitScope(canViewAll: false, keys: {});
  }

  return UserUnitScope(canViewAll: false, keys: keys);
}

bool matchesUnitScope({
  required UserUnitScope scope,
  required Iterable<String?> tokens,
  bool defaultIfNoScopeTokens = true,
}) {
  if (scope.canViewAll) return true;
  if (scope.keys.isEmpty) return false;

  final normalizedTokens = tokens
      .map(normalizeUnitKey)
      .where((token) => token.isNotEmpty)
      .toSet();

  if (normalizedTokens.isEmpty) return defaultIfNoScopeTokens;
  if (normalizedTokens.any(scope.keys.contains)) return true;

  bool hasKey(String key) =>
      normalizedTokens.any((token) => token.contains(key));

  // Generic bhatti scope can view both bhatti lines.
  if (scope.keys.contains('bhatti') &&
      (hasKey('bhatti') || hasKey('gita') || hasKey('sona'))) {
    return true;
  }

  if (scope.keys.contains('gita') && (hasKey('gita') || hasKey('bhatti'))) {
    return true;
  }
  if (scope.keys.contains('sona') && (hasKey('sona') || hasKey('bhatti'))) {
    return true;
  }
  if (scope.keys.contains('production') && hasKey('production')) return true;

  return false;
}
