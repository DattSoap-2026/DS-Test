import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'bhatti_entry_entity.g.dart';

/// Represents a daily Bhatti entry for batch production and fuel consumption
/// This is an ONLINE-FIRST entity with automatic local caching
@Collection()
class BhattiDailyEntryEntity extends BaseEntity {
  /// Date of the entry (indexed for efficient queries)
  @Index()
  late DateTime date;

  /// Bhatti ID (e.g., 'gita', 'sona')
  late String bhattiId;

  /// Bhatti display name (e.g., 'Gita Bhatti', 'Sona Bhatti')
  late String bhattiName;

  /// Team code (e.g., 'sona', 'gita')
  String? teamCode;

  /// Number of batches produced
  late int batchCount;

  /// Total boxes produced
  late int outputBoxes;

  /// Fuel consumed in liters
  late double fuelConsumption;

  /// User ID who created the entry
  late String createdBy;

  /// User name who created the entry
  late String createdByName;

  /// Creation timestamp
  late DateTime createdAt;

  /// Notes or additional comments
  String? notes;

  /// Convert to Firebase JSON format
  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'bhattiId': bhattiId,
      'bhattiName': bhattiName,
      if (teamCode != null) 'teamCode': teamCode,
      'batchCount': batchCount,
      'outputBoxes': outputBoxes,
      'fuelConsumption': fuelConsumption,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  /// Create from Firebase JSON
  static BhattiDailyEntryEntity fromFirebaseJson(Map<String, dynamic> json) {
    final entity = BhattiDailyEntryEntity()
      ..id = json['id'] as String
      ..date = DateTime.parse(json['date'] as String)
      ..bhattiId = json['bhattiId'] as String
      ..bhattiName = json['bhattiName'] as String
      ..teamCode = json['teamCode'] as String?
      ..batchCount = (json['batchCount'] as num).toInt()
      ..outputBoxes = (json['outputBoxes'] as num?)?.toInt() ?? 0
      ..fuelConsumption = (json['fuelConsumption'] as num).toDouble()
      ..createdBy = json['createdBy'] as String
      ..createdByName = json['createdByName'] as String? ?? 'Unknown'
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      )
      ..notes = json['notes'] as String?
      ..syncStatus = SyncStatus
          .synced // Auto-cached entries are always synced
      ..isDeleted = json['isDeleted'] == true
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '');

    return entity;
  }
}
