import 'dart:convert';
import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
import '../../../models/types/alert_types.dart';

part 'alert_entity.g.dart';

@Collection()
class AlertEntity extends BaseEntity {
  @Index(unique: true)
  late String alertId;

  late String title;
  late String message;

  @Enumerated(EnumType.ordinal)
  late AlertType type;

  @Enumerated(EnumType.ordinal)
  late AlertSeverity severity;

  late bool isRead;
  late DateTime createdAt;

  @Index()
  String? relatedId;

  String? metadataJson; // Store as JSON string

  Map<String, dynamic>? _decodeMetadata() {
    if (metadataJson == null || metadataJson!.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(metadataJson!);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // Ignore malformed metadata and treat as absent.
    }
    return null;
  }

  SystemAlert toDomain() {
    return SystemAlert(
      id: alertId,
      title: title,
      message: message,
      type: type,
      severity: severity,
      isRead: isRead,
      createdAt: createdAt,
      relatedId: relatedId,
      metadata: _decodeMetadata(),
    );
  }

  static AlertEntity fromDomain(SystemAlert model) {
    return AlertEntity()
      ..id = model.id
      ..alertId = model.id
      ..title = model.title
      ..message = model.message
      ..type = model.type
      ..severity = model.severity
      ..isRead = model.isRead
      ..createdAt = model.createdAt
      ..relatedId = model.relatedId
      ..metadataJson = (model.metadata == null || model.metadata!.isEmpty)
          ? null
          : jsonEncode(model.metadata)
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'alertId': alertId,
      'title': title,
      'message': message,
      'type': type.name,
      'severity': severity.name,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
      'metadataJson': metadataJson,
      'metadata': _decodeMetadata(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static AlertEntity fromJson(Map<String, dynamic> json) {
    final id = parseString(json['id']);
    final alertId = parseString(
      json['alertId'],
      fallback: id,
    ).trim();
    final metadataJson = _normalizeMetadataJson(
      json['metadataJson'] ?? json['metadata'],
    );

    return AlertEntity()
      ..id = id.isEmpty ? alertId : id
      ..alertId = alertId.isEmpty ? id : alertId
      ..title = parseString(json['title'])
      ..message = parseString(json['message'])
      ..type = _parseAlertType(json['type'])
      ..severity = _parseAlertSeverity(json['severity'])
      ..isRead = parseBool(json['isRead'])
      ..createdAt = parseDate(json['createdAt'])
      ..relatedId = _nullableString(json['relatedId'])
      ..metadataJson = metadataJson
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static String? _normalizeMetadataJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final normalized = value.trim();
      return normalized.isEmpty ? null : normalized;
    }
    final metadata = parseJsonMap(value);
    if (metadata == null || metadata.isEmpty) {
      return null;
    }
    return jsonEncode(metadata);
  }

  static String? _nullableString(dynamic value) {
    final normalized = parseString(value).trim();
    return normalized.isEmpty ? null : normalized;
  }

  static AlertType _parseAlertType(dynamic value) {
    final normalized = parseString(value, fallback: AlertType.other.name)
        .trim()
        .toLowerCase()
        .replaceFirst('alerttype.', '');
    for (final candidate in AlertType.values) {
      if (candidate.name.toLowerCase() == normalized) {
        return candidate;
      }
    }
    return AlertType.other;
  }

  static AlertSeverity _parseAlertSeverity(dynamic value) {
    final normalized = parseString(value, fallback: AlertSeverity.info.name)
        .trim()
        .toLowerCase()
        .replaceFirst('alertseverity.', '');
    for (final candidate in AlertSeverity.values) {
      if (candidate.name.toLowerCase() == normalized) {
        return candidate;
      }
    }
    return AlertSeverity.info;
  }
}
