import 'package:isar/isar.dart';

part 'ai_brain_models.g.dart';

enum MessageRole { user, ai, system }

@collection
class AIChatMessage {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime timestamp = DateTime.now();

  @Enumerated(EnumType.name)
  late MessageRole role;

  late String content;

  String? contextData; // Optional JSON metadata

  bool get isUser => role == MessageRole.user;
}

@collection
class AILearningItem {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String topic;

  late String content;

  DateTime learnedAt = DateTime.now();

  double confidence = 1.0;
}

@collection
class AIInsightCache {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String value; // JSON blob

  DateTime expiresAt = DateTime.now().add(const Duration(days: 7));
}

@collection
class AIBrainSettings {
  Id id = Isar.autoIncrement;

  bool enableLearning = true;
  String? preferredModel;
  double temperature = 0.7;
}
