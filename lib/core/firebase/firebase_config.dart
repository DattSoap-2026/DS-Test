// [HARD LOCKED] - Authentication & Authorization Module
//
// CRITICAL: This file contains core security and access control logic.
// - NO modification allowed without explicit AUTH_LOCK_OVERRIDE.
// - NO refactoring or optimization allowed.
// - ALL changes must be documented for security review.
//
// Strict Contract: Online-only login, Firestore-verified roles.
// Security Source: Firebase Auth & Firestore 'users' collection.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../services/delegates/firestore_query_delegate.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  // Config logic mostly handled by DefaultFirebaseOptions now
  static bool get isConfigured => true;
  static bool get isMockMode => false;
}

class FirebaseServices {
  static final FirebaseServices _instance = FirebaseServices._internal();
  factory FirebaseServices() => _instance;
  FirebaseServices._internal();

  FirebaseApp? _app;
  FirebaseAuth? _auth;
  FirebaseFirestore? _db;
  FirebaseStorage? _storage;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _auth = FirebaseAuth.instance;
      _db = FirestoreQueryDelegate().firestore;
      _storage = FirebaseStorage.instance;

      debugPrint('Firebase Initialized Successfully with Real SDK');
      _initialized = true;
    } catch (e) {
      debugPrint('Firebase Initialization Failed: $e');
      // Do NOT revert to stubs. Let it fail visibly so we know connection is broken.
      rethrow;
    }
  }

  bool get initialized => _initialized;
  bool get isMockMode => false;

  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get db => _db;
  FirebaseStorage? get storage => _storage;

  FirebaseApp get app {
    if (_app == null) {
      throw UnimplementedError('Firebase App not initialized');
    }
    return _app!;
  }
}

final firebaseServices = FirebaseServices();
