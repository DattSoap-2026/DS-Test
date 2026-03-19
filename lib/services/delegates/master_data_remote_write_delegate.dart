import 'package:cloud_firestore/cloud_firestore.dart';

class MasterDataRemoteWriteDelegate {
  const MasterDataRemoteWriteDelegate();

  Future<void> updateDocument(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
  ) async {
    await reference.update(data);
  }
}
