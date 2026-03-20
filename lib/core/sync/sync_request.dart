import 'package:flutter/foundation.dart';

enum SyncModule {
  inventory,
  sales,
  masterData,
  customers,
  users,
  dealers,
  attendance,
  core,
  all,
}

extension SyncModuleWireName on SyncModule {
  String get wireName {
    switch (this) {
      case SyncModule.inventory:
        return 'inventory';
      case SyncModule.sales:
        return 'sales';
      case SyncModule.masterData:
        return 'master_data';
      case SyncModule.customers:
        return 'customers';
      case SyncModule.users:
        return 'users';
      case SyncModule.dealers:
        return 'dealers';
      case SyncModule.attendance:
        return 'attendance';
      case SyncModule.core:
        return 'core';
      case SyncModule.all:
        return 'all';
    }
  }

  static SyncModule? fromWireName(String? value) {
    final normalized = value?.trim().toLowerCase();
    switch (normalized) {
      case 'inventory':
        return SyncModule.inventory;
      case 'sales':
        return SyncModule.sales;
      case 'master_data':
        return SyncModule.masterData;
      case 'customers':
        return SyncModule.customers;
      case 'users':
        return SyncModule.users;
      case 'dealers':
        return SyncModule.dealers;
      case 'attendance':
        return SyncModule.attendance;
      case 'core':
        return SyncModule.core;
      case 'all':
        return SyncModule.all;
    }
    return null;
  }
}

@immutable
class SyncPullRequest {
  const SyncPullRequest({
    required this.modules,
    required this.requestedAt,
    this.changedBy,
    this.source = 'unknown',
  });

  final Set<SyncModule> modules;
  final DateTime requestedAt;
  final String? changedBy;
  final String source;

  static const Set<SyncModule> _allSpecificModules = <SyncModule>{
    SyncModule.inventory,
    SyncModule.sales,
    SyncModule.masterData,
    SyncModule.customers,
    SyncModule.users,
    SyncModule.dealers,
    SyncModule.attendance,
    SyncModule.core,
  };

  Set<SyncModule> get expandedModules {
    if (modules.contains(SyncModule.all)) {
      return _allSpecificModules;
    }
    return Set<SyncModule>.from(modules);
  }

  bool shouldSkipForCurrentUser({
    String? appUserId,
    String? authUid,
  }) {
    final actor = changedBy?.trim();
    if (actor == null || actor.isEmpty) {
      return false;
    }

    final normalizedActor = actor.toLowerCase();
    final normalizedAppUserId = appUserId?.trim().toLowerCase();
    final normalizedAuthUid = authUid?.trim().toLowerCase();
    return normalizedActor == normalizedAppUserId ||
        normalizedActor == normalizedAuthUid;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'modules': modules
          .map((module) => module.wireName)
          .toList(growable: false)
        ..sort(),
      'changedBy': changedBy,
      'requestedAt': requestedAt.millisecondsSinceEpoch,
      'source': source,
    };
  }

  factory SyncPullRequest.fromJson(Map<String, dynamic> json) {
    final rawModules = json['modules'];
    final parsedModules = <SyncModule>{};
    if (rawModules is List) {
      for (final raw in rawModules) {
        final parsed = SyncModuleWireName.fromWireName(raw?.toString());
        if (parsed != null) {
          parsedModules.add(parsed);
        }
      }
    }

    final requestedAtMs = switch (json['requestedAt']) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch,
      _ => DateTime.now().millisecondsSinceEpoch,
    };

    return SyncPullRequest(
      modules: parsedModules.isEmpty
          ? const <SyncModule>{SyncModule.all}
          : parsedModules,
      requestedAt: DateTime.fromMillisecondsSinceEpoch(requestedAtMs),
      changedBy: json['changedBy']?.toString(),
      source: json['source']?.toString() ?? 'stored_request',
    );
  }

  factory SyncPullRequest.fromFcmPayload(Map<String, dynamic> payload) {
    final parsedModule = SyncModuleWireName.fromWireName(
      payload['module']?.toString(),
    );
    final timestampMs = switch (payload['timestamp']) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch,
      _ => DateTime.now().millisecondsSinceEpoch,
    };

    return SyncPullRequest(
      modules: <SyncModule>{parsedModule ?? SyncModule.all},
      requestedAt: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      changedBy: payload['changed_by']?.toString(),
      source: 'fcm',
    );
  }
}

Set<SyncModule> unionSyncModules(Iterable<SyncPullRequest> requests) {
  final union = <SyncModule>{};
  for (final request in requests) {
    union.addAll(request.expandedModules);
  }
  if (union.isEmpty) {
    union.add(SyncModule.all);
  }
  return union;
}
