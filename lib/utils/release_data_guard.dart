import 'package:flutter/foundation.dart';

String _normalizeGuardToken(String? value) {
  return (value ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool _isLiveLikeToken(String token) {
  if (token.isEmpty) return false;
  if (token.startsWith('live_') ||
      token.startsWith('live-') ||
      token.startsWith('live ') ||
      token.startsWith('live.') ||
      token.startsWith('live_t')) {
    return true;
  }
  return RegExp(r'(^|[^a-z0-9])live[_\-\s]?t\d').hasMatch(token);
}

bool _isQaLikeToken(String token) {
  if (token.isEmpty) return false;
  if (token.startsWith('qa_') ||
      token.startsWith('qa-') ||
      token.startsWith('qa ') ||
      token == 'qa' ||
      token.startsWith('test_qa') ||
      token.startsWith('qa_test')) {
    return true;
  }
  if (token.contains('@qa.') || token.contains('+qa@') || token.contains('.qa@')) {
    return true;
  }
  return RegExp(r'(^|[^a-z0-9])qa([^a-z0-9]|$)').hasMatch(token);
}

bool shouldHideInRelease({
  String? name,
  String? secondaryName,
  String? id,
  String? sku,
  String? email,
  Iterable<String?> extra = const <String?>[],
}) {
  if (!kReleaseMode) return false;

  final tokens = <String>[
    _normalizeGuardToken(name),
    _normalizeGuardToken(secondaryName),
    _normalizeGuardToken(id),
    _normalizeGuardToken(sku),
    _normalizeGuardToken(email),
    ...extra.map(_normalizeGuardToken),
  ].where((token) => token.isNotEmpty);

  for (final token in tokens) {
    if (_isLiveLikeToken(token) || _isQaLikeToken(token)) {
      return true;
    }
  }
  return false;
}
