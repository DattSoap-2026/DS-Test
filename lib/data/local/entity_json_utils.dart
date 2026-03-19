import 'dart:convert';

import 'base_entity.dart';

/// Parses a JSON value into a string with a null-safe fallback.
String parseString(dynamic value, {String fallback = ''}) {
  final normalized = value?.toString();
  if (normalized == null) {
    return fallback;
  }
  return normalized;
}

/// Parses a JSON value into a boolean with a null-safe fallback.
bool parseBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
  }
  return fallback;
}

/// Parses a JSON value into a double with a null-safe fallback.
double parseDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

/// Parses a JSON value into an int with a null-safe fallback.
int parseInt(dynamic value, {int fallback = 0}) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

/// Parses a JSON value into a required [DateTime].
DateTime parseDate(dynamic value, {DateTime? fallback}) {
  return parseDateOrNull(value) ?? fallback ?? DateTime.now();
}

/// Parses a JSON value into an optional [DateTime].
DateTime? parseDateOrNull(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return DateTime.tryParse(value.toString());
}

/// Parses a JSON value into a string list with a null-safe fallback.
List<String>? parseStringList(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(normalized);
      if (decoded is List) {
        return decoded
            .map((item) => item.toString())
            .toList(growable: false);
      }
    } catch (_) {
      return <String>[normalized];
    }
  }
  return null;
}

/// Parses a JSON value into a list with a null-safe fallback.
List<dynamic> parseJsonList(dynamic value) {
  if (value == null) {
    return const <dynamic>[];
  }
  if (value is List) {
    return value;
  }
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return const <dynamic>[];
    }
    try {
      final decoded = jsonDecode(normalized);
      if (decoded is List) {
        return decoded;
      }
    } catch (_) {
      return const <dynamic>[];
    }
  }
  return const <dynamic>[];
}

/// Parses a JSON value into a list of maps with a null-safe fallback.
List<Map<String, dynamic>> parseMapList(dynamic value) {
  return parseJsonList(value)
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

/// Parses a JSON value into a map with a null-safe fallback.
Map<String, dynamic>? parseJsonMap(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(normalized);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Parses a JSON value into a [SyncStatus] with a null-safe fallback.
SyncStatus parseSyncStatus(
  dynamic value, {
  SyncStatus fallback = SyncStatus.synced,
}) {
  if (value is SyncStatus) {
    return value;
  }
  final normalized = value?.toString().trim().toLowerCase();
  switch (normalized) {
    case 'pending':
      return SyncStatus.pending;
    case 'synced':
      return SyncStatus.synced;
    case 'conflict':
      return SyncStatus.conflict;
    default:
      return fallback;
  }
}
