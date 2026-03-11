import 'dart:async';
import '../core/firebase/firebase_config.dart';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/error/failures.dart';
import '../utils/app_logger.dart';
import '../utils/ui_notifier.dart';

class BaseService {
  final FirebaseServices firebaseServices;

  BaseService(this.firebaseServices);

  FirebaseFirestore? get db => firebaseServices.db;
  FirebaseAuth? get auth => firebaseServices.auth;
  FirebaseStorage? get storage => firebaseServices.storage;

  /// Logs and handles errors, converting them to Domain Failures.
  Failure handleError(
    dynamic error,
    String operation, {
    bool notifyUser = false,
  }) {
    AppLogger.error('$operation failed', error: error, tag: 'Service');

    if (notifyUser) {
      UINotifier.showError('Operation failed: $operation');
    }

    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return AuthFailure(
          'You do not have permission to perform this action.',
          error: error,
        );
      }
      if (error.code == 'unavailable') {
        return const ConnectionFailure(
          'Server is currently unavailable. Please check your connection.',
        );
      }
      return ServerFailure(
        error.message ?? 'An unexpected database error occurred.',
        error: error,
      );
    }

    if (error is TimeoutException) {
      return const ConnectionFailure(
        'The operation timed out. Please try again.',
      );
    }

    return ServerFailure(
      'Unexpected error during $operation: $error',
      error: error,
    );
  }

  Future<void> createAuditLog({
    required String collectionName,
    required String docId,
    required String action,
    required Map<String, dynamic> changes,
    required String userId,
    String? userName,
  }) async {
    final auditData = {
      'collectionName': collectionName,
      'docId': docId,
      'action': action,
      'changes': changes,
      'userId': userId,
      'userName': userName ?? 'System',
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // 1. Log to Firestore (Try direct, if fails, it's NOT critical enough to queue)
      // Actually, audit logs ARE critical for ERP.
      // But we don't want to bloat the main sync queue with thousands of minor audit events.
      // Strategy: Fire and forget if online, skip if offline.
      if (db != null) {
        db!.collection('audit_logs').add(auditData);
      }
    } catch (e) {
      developer.log('Audit log creation failed: $e');
    }
  }

  /// Convenience method to notify user of success from services.
  void notifySuccess(String message) {
    UINotifier.showSuccess(message);
  }

  /// Convenience method to notify user of error from services.
  void notifyError(String message) {
    UINotifier.showError(message);
  }

  /// **DEDUPLICATION HELPER**
  /// Removes duplicate items from a list based on their ID field.
  /// This ensures that only ONE item per unique ID is returned.
  ///
  /// Usage:
  /// ```dart
  /// final users = await query.findAll();
  /// final uniqueUsers = deduplicate(users.map((e) => e.toDomain()).toList());
  /// ```
  ///
  /// **Why needed**: Isar hash collisions or sync issues can create duplicates.
  /// This method guarantees clean, unique data in all screens.
  List<T> deduplicate<T>(List<T> items, String Function(T) getId) {
    if (items.isEmpty) return items;

    final uniqueMap = <String, T>{};
    for (final item in items) {
      final id = getId(item);
      uniqueMap[id] = item; // Last occurrence wins (most recent)
    }
    return uniqueMap.values.toList();
  }
}
