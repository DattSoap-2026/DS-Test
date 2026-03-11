import 'dart:convert';
import 'package:isar/isar.dart';
import '../base_entity.dart';
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
}
