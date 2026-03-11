class SettingsAuditLog {
  final String id;
  final String timestamp;
  final String userId;
  final String module;
  final String settingKey;
  final dynamic oldValue;
  final dynamic newValue;
  final String source;

  const SettingsAuditLog({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.module,
    required this.settingKey,
    required this.oldValue,
    required this.newValue,
    required this.source,
  });

  factory SettingsAuditLog.fromMap(Map<String, dynamic> map) {
    return SettingsAuditLog(
      id: map['id'] as String? ?? '',
      timestamp: map['timestamp'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      module: map['module'] as String? ?? '',
      settingKey: map['setting_key'] as String? ?? '',
      oldValue: map['old_value'],
      newValue: map['new_value'],
      source: map['source'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'user_id': userId,
      'module': module,
      'setting_key': settingKey,
      'old_value': oldValue,
      'new_value': newValue,
      'source': source,
    };
  }
}
