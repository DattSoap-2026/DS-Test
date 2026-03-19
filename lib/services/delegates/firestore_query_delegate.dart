import 'package:cloud_firestore/cloud_firestore.dart';

enum FirestoreQueryOperator {
  isEqualTo,
  whereIn,
  isGreaterThanOrEqualTo,
  isLessThanOrEqualTo,
}

class FirestoreQueryFilter {
  const FirestoreQueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });

  final String field;
  final FirestoreQueryOperator operator;
  final Object? value;
}

class FirestoreQueryDelegate {
  FirestoreQueryDelegate([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  FirebaseFirestore get firestore => _firestore;

  DocumentReference<Map<String, dynamic>> newDocument(String collection) {
    return _firestore.collection(collection).doc();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection({
    required String collection,
    List<FirestoreQueryFilter> filters = const <FirestoreQueryFilter>[],
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    query = _applyFilters(query, filters);
    if (orderBy != null && orderBy.trim().isNotEmpty) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.get();
  }

  Future<int> countCollection({
    required String collection,
    List<FirestoreQueryFilter> filters = const <FirestoreQueryFilter>[],
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    query = _applyFilters(query, filters);
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection({
    required String collection,
    List<FirestoreQueryFilter> filters = const <FirestoreQueryFilter>[],
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    query = _applyFilters(query, filters);
    return query.snapshots();
  }

  Query<Map<String, dynamic>> _applyFilters(
    Query<Map<String, dynamic>> query,
    List<FirestoreQueryFilter> filters,
  ) {
    for (final filter in filters) {
      switch (filter.operator) {
        case FirestoreQueryOperator.isEqualTo:
          query = query.where(filter.field, isEqualTo: filter.value);
          break;
        case FirestoreQueryOperator.whereIn:
          query = query.where(filter.field, whereIn: filter.value as List<Object?>);
          break;
        case FirestoreQueryOperator.isGreaterThanOrEqualTo:
          query = query.where(
            filter.field,
            isGreaterThanOrEqualTo: filter.value,
          );
          break;
        case FirestoreQueryOperator.isLessThanOrEqualTo:
          query = query.where(
            filter.field,
            isLessThanOrEqualTo: filter.value,
          );
          break;
      }
    }
    return query;
  }
}
