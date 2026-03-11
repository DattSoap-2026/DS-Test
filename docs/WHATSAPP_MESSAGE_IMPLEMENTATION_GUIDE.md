# WhatsApp जैसा Message Sync - Quick Implementation Guide
# WhatsApp-like Message Sync - Minimal Implementation

**Target**: 8-13 hours implementation  
**Approach**: Minimal code, maximum reuse

---

## 🚀 Step 1: Message Sync Delegate (2 hours)

### File: `lib/services/delegates/message_sync_delegate.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/data/local/entities/message_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/utils/app_logger.dart';

class MessageSyncDelegate {
  final DatabaseService _dbService;
  final Function(String, Object) _markSyncIssue;
  
  MessageSyncDelegate({
    required DatabaseService dbService,
    required Function(String, Object) markSyncIssue,
  })  : _dbService = dbService,
        _markSyncIssue = markSyncIssue;

  // Push pending messages to Firestore
  Future<void> pushPendingMessages(FirebaseFirestore db, String userId) async {
    try {
      final pending = await _dbService.db.messages
          .filter()
          .senderIdEqualTo(userId)
          .statusEqualTo('pending')
          .findAll();

      for (final msg in pending) {
        try {
          await db.collection('messages').doc(msg.messageId).set({
            'messageId': msg.messageId,
            'conversationId': msg.conversationId,
            'senderId': msg.senderId,
            'senderName': msg.senderName,
            'recipientId': msg.recipientId,
            'recipientName': msg.recipientName,
            'content': msg.content,
            'type': msg.type,
            'timestamp': msg.timestamp.toIso8601String(),
            'status': 'sent',
            'sentAt': DateTime.now().toIso8601String(),
            'attachmentUrl': msg.attachmentUrl,
            'replyToMessageId': msg.replyToMessageId,
            'isDeleted': msg.isDeleted,
          });

          // Update local status
          await _dbService.db.writeTxn(() async {
            msg.status = 'sent';
            msg.sentAt = DateTime.now();
            await _dbService.db.messages.put(msg);
          });

          AppLogger.success('Message ${msg.messageId} synced', tag: 'MessageSync');
        } catch (e) {
          msg.retryCount++;
          if (msg.retryCount >= 3) {
            msg.status = 'failed';
          }
          await _dbService.db.writeTxn(() async {
            await _dbService.db.messages.put(msg);
          });
          _markSyncIssue('push_message', e);
        }
      }
    } catch (e) {
      _markSyncIssue('push_pending_messages', e);
    }
  }

  // Pull new messages from Firestore
  Future<void> pullNewMessages(FirebaseFirestore db, String userId) async {
    try {
      final lastSync = await _getLastMessageSync(userId);
      
      final snapshot = await db
          .collection('messages')
          .where('recipientId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: lastSync.toIso8601String())
          .orderBy('timestamp')
          .limit(50)
          .get();

      await _dbService.db.writeTxn(() async {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final msg = Message()
            ..messageId = data['messageId']
            ..conversationId = data['conversationId']
            ..senderId = data['senderId']
            ..senderName = data['senderName']
            ..recipientId = data['recipientId']
            ..recipientName = data['recipientName']
            ..content = data['content']
            ..type = data['type']
            ..timestamp = DateTime.parse(data['timestamp'])
            ..status = data['status']
            ..retryCount = 0
            ..sentAt = data['sentAt'] != null ? DateTime.parse(data['sentAt']) : null
            ..deliveredAt = data['deliveredAt'] != null ? DateTime.parse(data['deliveredAt']) : null
            ..readAt = data['readAt'] != null ? DateTime.parse(data['readAt']) : null
            ..attachmentUrl = data['attachmentUrl']
            ..attachmentLocalPath = null
            ..replyToMessageId = data['replyToMessageId']
            ..isDeleted = data['isDeleted'] ?? false
            ..createdAt = DateTime.parse(data['timestamp'])
            ..updatedAt = DateTime.now();

          await _dbService.db.messages.put(msg);
        }
      });

      await _setLastMessageSync(userId, DateTime.now());
      AppLogger.success('Pulled ${snapshot.docs.length} new messages', tag: 'MessageSync');
    } catch (e) {
      _markSyncIssue('pull_new_messages', e);
    }
  }

  // Update message status (delivered/read)
  Future<void> updateMessageStatus({
    required FirebaseFirestore db,
    required String messageId,
    required String status,
  }) async {
    try {
      final now = DateTime.now();
      await db.collection('messages').doc(messageId).update({
        'status': status,
        '${status}At': now.toIso8601String(),
      });

      await _dbService.db.writeTxn(() async {
        final msg = await _dbService.db.messages
            .filter()
            .messageIdEqualTo(messageId)
            .findFirst();
        
        if (msg != null) {
          msg.status = status;
          if (status == 'delivered') msg.deliveredAt = now;
          if (status == 'read') msg.readAt = now;
          await _dbService.db.messages.put(msg);
        }
      });
    } catch (e) {
      _markSyncIssue('update_message_status', e);
    }
  }

  Future<DateTime> _getLastMessageSync(String userId) async {
    // Get from SharedPreferences or default to 7 days ago
    return DateTime.now().subtract(Duration(days: 7));
  }

  Future<void> _setLastMessageSync(String userId, DateTime time) async {
    // Save to SharedPreferences
  }
}
```

---

## 🔌 Step 2: Integrate with Sync Manager (1 hour)

### File: `lib/services/sync_manager.dart`

Add these changes:

```dart
// 1. Import delegate
import 'package:flutter_app/services/delegates/message_sync_delegate.dart';

// 2. Add delegate instance
MessageSyncDelegate? _messageSyncDelegateInstance;

MessageSyncDelegate get _messageSyncDelegate =>
    _messageSyncDelegateInstance ??= MessageSyncDelegate(
      dbService: _dbService,
      markSyncIssue: _markSyncIssue,
    );

// 3. Add to syncAll() method (around line 1200)
await runStep(
  'messages',
  () async {
    await _messageSyncDelegate.pushPendingMessages(db, effectiveUser.id);
    await _messageSyncDelegate.pullNewMessages(db, effectiveUser.id);
  },
);

// 4. Add message queue method
Future<void> enqueueMessage(Message message) async {
  await enqueueItem(
    collection: 'messages',
    action: 'add',
    data: {
      'messageId': message.messageId,
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'recipientId': message.recipientId,
      'recipientName': message.recipientName,
      'content': message.content,
      'type': message.type,
      'timestamp': message.timestamp.toIso8601String(),
      'status': message.status,
      'attachmentUrl': message.attachmentUrl,
      'replyToMessageId': message.replyToMessageId,
    },
  );
}
```

---

## 📡 Step 3: Real-time Message Listener (2 hours)

### Add to `sync_manager.dart`:

```dart
// 1. Add subscription variable
StreamSubscription<QuerySnapshot>? _messageWatchSubscription;

// 2. Add listener method
void startMessageListener(String userId) {
  final db = _firebase.db;
  if (db == null) return;

  _messageWatchSubscription?.cancel();
  _messageWatchSubscription = db
      .collection('messages')
      .where('recipientId', isEqualTo: userId)
      .where('status', whereIn: ['sent', 'delivered'])
      .orderBy('timestamp', descending: true)
      .limit(20)
      .snapshots()
      .listen(
        (snapshot) async {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added ||
                change.type == DocumentChangeType.modified) {
              final data = change.doc.data();
              if (data == null) continue;

              await _dbService.db.writeTxn(() async {
                final existing = await _dbService.db.messages
                    .filter()
                    .messageIdEqualTo(data['messageId'])
                    .findFirst();

                if (existing == null) {
                  // New message
                  final msg = Message()
                    ..messageId = data['messageId']
                    ..conversationId = data['conversationId']
                    ..senderId = data['senderId']
                    ..senderName = data['senderName']
                    ..recipientId = data['recipientId']
                    ..recipientName = data['recipientName']
                    ..content = data['content']
                    ..type = data['type']
                    ..timestamp = DateTime.parse(data['timestamp'])
                    ..status = 'delivered'
                    ..retryCount = 0
                    ..sentAt = data['sentAt'] != null ? DateTime.parse(data['sentAt']) : null
                    ..deliveredAt = DateTime.now()
                    ..attachmentUrl = data['attachmentUrl']
                    ..replyToMessageId = data['replyToMessageId']
                    ..isDeleted = data['isDeleted'] ?? false
                    ..createdAt = DateTime.parse(data['timestamp'])
                    ..updatedAt = DateTime.now();

                  await _dbService.db.messages.put(msg);

                  // Mark as delivered on server
                  await _messageSyncDelegate.updateMessageStatus(
                    db: db,
                    messageId: data['messageId'],
                    status: 'delivered',
                  );

                  AppLogger.info('New message received: ${data['messageId']}', tag: 'MessageSync');
                }
              });
            }
          }
        },
        onError: (e) => AppLogger.error('Message listener error', error: e, tag: 'MessageSync'),
      );
}

// 3. Stop listener
void stopMessageListener() {
  _messageWatchSubscription?.cancel();
  _messageWatchSubscription = null;
}

// 4. Add to cleanup()
@override
void cleanup({bool notify = true}) {
  stopMessageListener();
  // ... existing cleanup code
}

// 5. Call in setCurrentUser()
void setCurrentUser(AppUser user, {bool triggerBootstrap = true}) {
  _currentUser = user;
  startMessageListener(user.id); // Add this line
  // ... existing code
}
```

---

## 💬 Step 4: Message Service (2 hours)

### File: `lib/services/message_service.dart`

```dart
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/sync_manager.dart';
import 'package:uuid/uuid.dart';

class MessageService {
  final DatabaseService _dbService;
  final SyncManager _syncManager;

  MessageService(this._dbService, this._syncManager);

  // Send message
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String content,
    String type = 'text',
    String? attachmentUrl,
    String? replyToMessageId,
  }) async {
    final msg = Message()
      ..messageId = Uuid().v4()
      ..conversationId = conversationId
      ..senderId = senderId
      ..senderName = senderName
      ..recipientId = recipientId
      ..recipientName = recipientName
      ..content = content
      ..type = type
      ..timestamp = DateTime.now()
      ..status = 'pending'
      ..retryCount = 0
      ..attachmentUrl = attachmentUrl
      ..replyToMessageId = replyToMessageId
      ..isDeleted = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    // Save locally first (WhatsApp Rule 1)
    await _dbService.db.writeTxn(() async {
      await _dbService.db.messages.put(msg);
    });

    // Queue for sync (WhatsApp Rule 2)
    await _syncManager.enqueueMessage(msg);

    // Trigger debounced sync (WhatsApp Rule 2)
    _syncManager.scheduleDebouncedSync();

    return msg;
  }

  // Get conversation messages
  Future<List<Message>> getConversationMessages(String conversationId) async {
    return await _dbService.db.messages
        .filter()
        .conversationIdEqualTo(conversationId)
        .isDeletedEqualTo(false)
        .sortByTimestamp()
        .findAll();
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    await _dbService.db.writeTxn(() async {
      final msg = await _dbService.db.messages
          .filter()
          .messageIdEqualTo(messageId)
          .findFirst();
      
      if (msg != null && msg.status != 'read') {
        msg.status = 'read';
        msg.readAt = DateTime.now();
        await _dbService.db.messages.put(msg);

        // Update on server
        final db = _syncManager._firebase.db;
        if (db != null) {
          await _syncManager._messageSyncDelegate.updateMessageStatus(
            db: db,
            messageId: messageId,
            status: 'read',
          );
        }
      }
    });
  }

  // Delete message (soft delete)
  Future<void> deleteMessage(String messageId) async {
    await _dbService.db.writeTxn(() async {
      final msg = await _dbService.db.messages
          .filter()
          .messageIdEqualTo(messageId)
          .findFirst();
      
      if (msg != null) {
        msg.isDeleted = true;
        msg.deletedAt = DateTime.now();
        await _dbService.db.messages.put(msg);
      }
    });
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    return await _dbService.db.messages
        .filter()
        .recipientIdEqualTo(userId)
        .statusEqualTo('delivered')
        .isDeletedEqualTo(false)
        .count();
  }
}
```

---

## 🎨 Step 5: UI Integration (2 hours)

### File: `lib/screens/messages/chat_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/services/message_service.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String recipientId;
  final String recipientName;

  const ChatScreen({
    required this.conversationId,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late MessageService _messageService;

  @override
  void initState() {
    super.initState();
    _messageService = context.read<MessageService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipientName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageService._dbService.db.messages
                  .filter()
                  .conversationIdEqualTo(widget.conversationId)
                  .isDeletedEqualTo(false)
                  .watch(fireImmediately: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg) {
    final isMe = msg.senderId == context.read<AppUser>().id;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.content),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (isMe) ...[
                  SizedBox(width: 4),
                  _buildStatusIcon(msg.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icon(Icons.access_time, size: 12, color: Colors.grey);
      case 'sent':
        return Icon(Icons.check, size: 12, color: Colors.grey);
      case 'delivered':
        return Icon(Icons.done_all, size: 12, color: Colors.grey);
      case 'read':
        return Icon(Icons.done_all, size: 12, color: Colors.blue);
      case 'failed':
        return Icon(Icons.error, size: 12, color: Colors.red);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final currentUser = context.read<AppUser>();
    await _messageService.sendMessage(
      conversationId: widget.conversationId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      recipientId: widget.recipientId,
      recipientName: widget.recipientName,
      content: _controller.text.trim(),
    );

    _controller.clear();
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
```

---

## 🔥 Step 6: Firestore Rules (30 minutes)

### File: `firestore.rules`

Add these rules:

```javascript
// Messages collection
match /messages/{messageId} {
  allow read: if request.auth != null && (
    resource.data.senderId == request.auth.uid ||
    resource.data.recipientId == request.auth.uid
  );
  
  allow create: if request.auth != null &&
    request.resource.data.senderId == request.auth.uid;
  
  allow update: if request.auth != null && (
    resource.data.senderId == request.auth.uid ||
    (resource.data.recipientId == request.auth.uid &&
     request.resource.data.diff(resource.data).affectedKeys()
       .hasOnly(['status', 'deliveredAt', 'readAt']))
  );
  
  allow delete: if request.auth != null &&
    resource.data.senderId == request.auth.uid;
}

// Conversations collection
match /conversations/{conversationId} {
  allow read, write: if request.auth != null &&
    request.auth.uid in resource.data.participants;
}
```

---

## 🧪 Step 7: Testing (1 hour)

### File: `test/services/message_sync_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/message_service.dart';

void main() {
  group('Message Sync Tests', () {
    test('send message offline → queues for sync', () async {
      // Test offline message queuing
    });

    test('network restore → auto-sync pending messages', () async {
      // Test auto-sync on network restore
    });

    test('receive message → real-time update', () async {
      // Test real-time message receive
    });

    test('status update → ticks change', () async {
      // Test status indicator updates
    });

    test('retry failed message → works after 3 attempts', () async {
      // Test retry logic
    });
  });
}
```

---

## ✅ Deployment Checklist

- [ ] Create `message_sync_delegate.dart`
- [ ] Integrate with `sync_manager.dart`
- [ ] Add real-time listener
- [ ] Create `message_service.dart`
- [ ] Build chat UI
- [ ] Add Firestore rules
- [ ] Run tests
- [ ] Deploy to Firebase

---

## 📊 Estimated Timeline

| Task | Time | Status |
|------|------|--------|
| Message Sync Delegate | 2 hours | ⏳ Pending |
| Sync Manager Integration | 1 hour | ⏳ Pending |
| Real-time Listener | 2 hours | ⏳ Pending |
| Message Service | 2 hours | ⏳ Pending |
| UI Integration | 2 hours | ⏳ Pending |
| Firestore Rules | 30 min | ⏳ Pending |
| Testing | 1 hour | ⏳ Pending |
| **Total** | **10.5 hours** | ⏳ Pending |

---

**Implementation Strategy**: Minimal code, maximum reuse of existing infrastructure (70% already ready)
