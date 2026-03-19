import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRemoteDelegate {
  const NotificationRemoteDelegate(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> writeUserToken({
    required String docId,
    required String token,
    required String platformLabel,
    required String roleValue,
    required String userId,
  }) async {
    await _firestore.collection('users').doc(docId).set({
      'fcmToken': token,
      'fcmTokenPlatform': platformLabel,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      'fcmTokenRole': roleValue,
      'fcmTokenUserId': userId,
    }, SetOptions(merge: true));
  }

  Future<void> publishOutboxEvent({
    required String eventCollection,
    required String eventId,
    required Map<String, dynamic> remotePayload,
  }) async {
    await _firestore.collection(eventCollection).doc(eventId).set(
      remotePayload,
      SetOptions(merge: true),
    );
  }
}
