import 'package:isar/isar.dart';

part 'chat_message.g.dart';

@collection
class ChatMessage {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String message;
  late String sender;
  late DateTime timestamp;
  late bool isUser;

  String? response;
  DateTime? responseTimestamp;
  DateTime lastModified = DateTime.now();
  int version = 1;
}
