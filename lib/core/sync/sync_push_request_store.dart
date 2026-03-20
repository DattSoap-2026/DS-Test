import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sync_request.dart';

/// Persists inbound pull-sync requests so they can survive app restarts.
class SyncPushRequestStore {
  SyncPushRequestStore._();

  static final SyncPushRequestStore instance = SyncPushRequestStore._();

  static const String _prefsKey = 'pending_pull_sync_requests_v1';

  Future<void> enqueue(SyncPullRequest request) async {
    final requests = await loadAll();
    requests.add(request);
    await _save(_mergeRequests(requests));
  }

  Future<List<SyncPullRequest>> loadAll() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_prefsKey);
    if (raw == null || raw.trim().isEmpty) {
      return <SyncPullRequest>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <SyncPullRequest>[];
      }
      return decoded
          .whereType<Map>()
          .map(
            (entry) => SyncPullRequest.fromJson(
              Map<String, dynamic>.from(
                entry.map((key, value) => MapEntry(key.toString(), value)),
              ),
            ),
          )
          .toList(growable: true);
    } catch (_) {
      return <SyncPullRequest>[];
    }
  }

  Future<List<SyncPullRequest>> takeAll() async {
    final requests = await loadAll();
    await clear();
    return requests;
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_prefsKey);
  }

  Future<void> _save(List<SyncPullRequest> requests) async {
    final preferences = await SharedPreferences.getInstance();
    if (requests.isEmpty) {
      await preferences.remove(_prefsKey);
      return;
    }

    await preferences.setString(
      _prefsKey,
      jsonEncode(
        requests.map((request) => request.toJson()).toList(growable: false),
      ),
    );
  }

  List<SyncPullRequest> _mergeRequests(List<SyncPullRequest> requests) {
    final merged = <String, SyncPullRequest>{};
    for (final request in requests) {
      final key = request.changedBy?.trim().toLowerCase() ?? '';
      final existing = merged[key];
      if (existing == null) {
        merged[key] = request;
        continue;
      }

      final mergedModules = <SyncModule>{
        ...existing.modules,
        ...request.modules,
      };
      final latestRequestedAt = existing.requestedAt.isAfter(request.requestedAt)
          ? existing.requestedAt
          : request.requestedAt;
      merged[key] = SyncPullRequest(
        modules: mergedModules,
        requestedAt: latestRequestedAt,
        changedBy: existing.changedBy ?? request.changedBy,
        source: existing.source,
      );
    }

    final values = merged.values.toList(growable: false);
    values.sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
    return values;
  }
}
