// Stubs for Firebase classes to bypass compilation errors on Windows
import 'dart:io';
import 'dart:async';

class FirebaseApp {}

class FirebaseAuth {
  static FirebaseAuth instanceFor({required FirebaseApp app}) => FirebaseAuth();
  static FirebaseAuth get instance => FirebaseAuth();
  User? get currentUser => null;
  Stream<User?> get authStateChanges => Stream.value(null);
  Future<void> signOut() async {}
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => UserCredential();
  Future<void> sendPasswordResetEmail({required String email}) async {}
}

class FirebaseFirestore {
  static FirebaseFirestore instanceFor({required FirebaseApp app}) =>
      FirebaseFirestore();
  static FirebaseFirestore get instance => FirebaseFirestore();
  late Settings settings;
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      CollectionReference();
  DocumentReference<Map<String, dynamic>> doc(String path) =>
      DocumentReference();
  WriteBatch batch() => WriteBatch();
  Future<T> runTransaction<T>(Future<T> Function(Transaction) handler) async {
    return handler(Transaction());
  }
}

class FirebaseStorage {
  static FirebaseStorage instanceFor({required FirebaseApp app}) =>
      FirebaseStorage();
  static FirebaseStorage get instance => FirebaseStorage();
}

class FirebaseException implements Exception {
  final String code;
  final String? message;
  FirebaseException({required this.code, this.message});
}

class FirebaseAuthException implements Exception {
  final String code;
  final String? message;
  FirebaseAuthException({required this.code, this.message});
}

class DocumentReference<T> {
  String get id => '';
  Future<void> set(T data, [SetOptions? options]) async {}
  Future<void> update(Map<String, dynamic> data) async {}
  Future<void> delete() async {}
  Future<DocumentSnapshot<T>> get() async => DocumentSnapshot();
  Stream<DocumentSnapshot<T>> snapshots() => Stream.value(DocumentSnapshot());
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      CollectionReference();
}

class CollectionReference<T> extends Query<T> {
  DocumentReference<T> doc([String? path]) => DocumentReference();
  Future<DocumentReference<T>> add(T data) async => DocumentReference();
}

class Query<T> {
  Query<T> where(
    dynamic field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) => Query();
  Query<T> orderBy(dynamic field, {bool descending = false}) => Query();
  Query<T> limit(int limit) => Query();
  AggregateQuery count() => AggregateQuery();
  Future<QuerySnapshot<T>> get() async => QuerySnapshot();
  Stream<QuerySnapshot<T>> snapshots() => Stream.value(QuerySnapshot());
}

class AggregateQuery {
  Future<AggregateQuerySnapshot> get() async => AggregateQuerySnapshot();
}

class AggregateQuerySnapshot {
  int get count => 0;
}

class QuerySnapshot<T> {
  List<DocumentSnapshot<T>> get docs => [];
  int get size => 0;
}

class DocumentSnapshot<T> {
  T data() => {} as T;
  String get id => '';
  bool get exists => false;
  DocumentReference<T> get reference => DocumentReference();
  dynamic get(String field) => null;
  dynamic operator [](String field) => null;
}

class FieldValue {
  static FieldValue serverTimestamp() => FieldValue();
  static FieldValue arrayUnion(List<dynamic> elements) => FieldValue();
  static FieldValue arrayRemove(List<dynamic> elements) => FieldValue();
  static FieldValue increment(num value) => FieldValue();
  static FieldValue delete() => FieldValue();
}

class Timestamp {
  final int seconds;
  final int nanoseconds;
  Timestamp(this.seconds, this.nanoseconds);
  static Timestamp now() => Timestamp(0, 0);
  static Timestamp fromDate(DateTime date) => Timestamp(0, 0);
  DateTime toDate() => DateTime.now();
  int get millisecondsSinceEpoch => 0;
}

class UserCredential {
  User? get user => null;
}

class User {
  String get uid => '';
  String? get email => '';
  String? get displayName => '';
  String? get photoURL => '';
}

class Settings {
  // ignore: constant_identifier_names
  static const int CACHE_SIZE_UNLIMITED = -1;
  final bool persistenceEnabled;
  final int cacheSizeBytes;
  const Settings({
    this.persistenceEnabled = true,
    this.cacheSizeBytes = CACHE_SIZE_UNLIMITED,
  });
}

class FirebaseOptions {
  final String apiKey;
  final String authDomain;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;
  const FirebaseOptions({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
  });
}

class Firebase {
  static Future<FirebaseApp> initializeApp({dynamic options}) async {
    return FirebaseApp();
  }

  static FirebaseApp app([String name = 'DEFAULT']) => FirebaseApp();
}

class FirebaseMessaging {
  static FirebaseMessaging get instance => FirebaseMessaging();
  Future<String?> getToken({String? vapidKey}) async => null;
  Future<RemoteMessage?> getInitialMessage() async => null;
  Stream<String> get onTokenRefresh => Stream.empty();
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async => NotificationSettings();
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {}
  static Stream<RemoteMessage> get onMessage => Stream.empty();
  static Stream<RemoteMessage> get onMessageOpenedApp => Stream.empty();
  static Future<void> onBackgroundMessage(
    Future<void> Function(RemoteMessage) handler,
  ) async {}
  Future<void> subscribeToTopic(String topic) async {}
  Future<void> unsubscribeFromTopic(String topic) async {}
}

class NotificationSettings {
  AuthorizationStatus get authorizationStatus => AuthorizationStatus.authorized;
}

enum AuthorizationStatus { authorized, denied, notDetermined, provisional }

class RemoteMessage {
  final RemoteNotification? notification;
  final Map<String, dynamic> data;
  RemoteMessage({this.notification, this.data = const {}});
}

class RemoteNotification {
  final String? title;
  final String? body;
  RemoteNotification({this.title, this.body});
}

// Additional classes for core functionality
class WriteBatch {
  void set(
    DocumentReference doc,
    Map<String, dynamic> data, [
    SetOptions? options,
  ]) {}
  void update(DocumentReference doc, Map<String, dynamic> data) {}
  void delete(DocumentReference doc) {}
  Future<void> commit() async {}
}

class Transaction {
  Future<DocumentSnapshot> get(DocumentReference ref) async =>
      DocumentSnapshot();
  void set(
    DocumentReference ref,
    Map<String, dynamic> data, [
    SetOptions? options,
  ]) {}
  void update(DocumentReference ref, Map<String, dynamic> data) {}
  void delete(DocumentReference ref) {}
}

class SetOptions {
  final bool? merge;
  final List<String>? mergeFields;
  const SetOptions({this.merge, this.mergeFields});
  static SetOptions withMerge() => const SetOptions(merge: true);
}

class FieldPath {
  static FieldPath get documentId => FieldPath();
}

class FirebaseFunctions {
  static final FirebaseFunctions instance = FirebaseFunctions();
  HttpsCallable httpsCallable(String name) => HttpsCallable();
}

class HttpsCallable {
  Future<HttpsCallableResult> call([dynamic data]) async =>
      HttpsCallableResult();
}

class HttpsCallableResult {
  final dynamic data = null;
}

// Extension to add ref methods to classes that need it but can't be modified easily
extension FirebaseStorageExtension on FirebaseStorage {
  Reference ref([String? path]) => Reference();
}

class Reference {
  Reference child(String path) => Reference();
  Future<String> getDownloadURL() async => '';
  Future<void> delete() async {}
  Future<void> putData(dynamic data) async {}
  UploadTask putFile(File file) => UploadTask();
}

class UploadTask implements Future<TaskSnapshot> {
  Future<TaskSnapshot> get onComplete async => TaskSnapshot();
  Stream<TaskSnapshot> get snapshotEvents => Stream.empty();

  @override
  Stream<TaskSnapshot> asStream() => Stream.value(TaskSnapshot());

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) => Future.value(TaskSnapshot());

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) => Future.value(TaskSnapshot()).then(onValue, onError: onError);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) =>
      Future.value(TaskSnapshot()).whenComplete(action);

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) => Future.value(TaskSnapshot());
}

class TaskSnapshot {
  Reference get ref => Reference();
}
