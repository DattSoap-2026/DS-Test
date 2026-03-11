import 'package:uuid/uuid.dart';

enum MessageStatus {
  pending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String body;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.body,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
  });

  factory ChatMessage.create({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required String body,
  }) {
    return ChatMessage(
      id: const Uuid().v4(),
      conversationId: conversationId,
      senderId: senderId,
      recipientId: recipientId,
      body: body,
      status: MessageStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'recipientId': recipientId,
        'body': body,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        conversationId: json['conversationId'],
        senderId: json['senderId'],
        recipientId: json['recipientId'],
        body: json['body'],
        status: MessageStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => MessageStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
        deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
        readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      );

  ChatMessage copyWith({
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) =>
      ChatMessage(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        recipientId: recipientId,
        body: body,
        status: status ?? this.status,
        createdAt: createdAt,
        sentAt: sentAt ?? this.sentAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        readAt: readAt ?? this.readAt,
      );
}
