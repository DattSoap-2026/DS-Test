import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Schema Migration Script
/// Version: 2.7
/// Date: March 2026

class FirestoreMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const int currentSchemaVersion = 3;
  static const String schemaVersionDoc = 'schema_version';
  
  /// Run all pending migrations
  Future<void> runMigrations() async {
    final currentVersion = await _getCurrentVersion();
    // ignore: avoid_print
    print('Current schema version: $currentVersion');
    
    if (currentVersion < currentSchemaVersion) {
      // ignore: avoid_print
      print('Running migrations from v$currentVersion to v$currentSchemaVersion');
      
      for (int version = currentVersion + 1; version <= currentSchemaVersion; version++) {
        await _runMigration(version);
      }
      
      await _setVersion(currentSchemaVersion);
      // ignore: avoid_print
      print('Migration complete!');
    } else {
      // ignore: avoid_print
      print('Schema is up to date');
    }
  }
  
  /// Get current schema version
  Future<int> _getCurrentVersion() async {
    try {
      final doc = await _firestore.collection('settings').doc(schemaVersionDoc).get();
      return doc.data()?['version'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  /// Set schema version
  Future<void> _setVersion(int version) async {
    await _firestore.collection('settings').doc(schemaVersionDoc).set({
      'version': version,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Run specific migration
  Future<void> _runMigration(int version) async {
    // ignore: avoid_print
    print('Running migration v$version...');
    
    switch (version) {
      case 1:
        await _migrateV1();
        break;
      case 2:
        await _migrateV2();
        break;
      case 3:
        await _migrateV3();
        break;
      default:
        // ignore: avoid_print
        print('No migration for version $version');
    }
  }
  
  /// Migration V1: Add isDeleted field to all collections
  Future<void> _migrateV1() async {
    final collections = ['sales', 'products', 'customers', 'route_orders'];
    
    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection)
          .where('isDeleted', isNull: true)
          .limit(500)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDeleted': false});
      }
      await batch.commit();
      // ignore: avoid_print
      print('  - Updated ${snapshot.docs.length} documents in $collection');
    }
  }
  
  /// Migration V2: Canonical Firebase UID for sales
  Future<void> _migrateV2() async {
    final snapshot = await _firestore.collection('sales')
        .where('salesmanId', isNull: false)
        .limit(500)
        .get();
    
    final batch = _firestore.batch();
    int updated = 0;
    
    for (final doc in snapshot.docs) {
      final salesmanId = doc.data()['salesmanId'];
      if (salesmanId != null && !salesmanId.toString().contains('@')) {
        // Already using UID, skip
        continue;
      }
      
      // Get user by email to find UID
      final userSnapshot = await _firestore.collection('users')
          .where('email', isEqualTo: salesmanId)
          .limit(1)
          .get();
      
      if (userSnapshot.docs.isNotEmpty) {
        final uid = userSnapshot.docs.first.id;
        batch.update(doc.reference, {
          'salesmanId': uid,
          'migratedToUid': true,
        });
        updated++;
      }
    }
    
    await batch.commit();
    // ignore: avoid_print
    print('  - Migrated $updated sales to use Firebase UID');
  }
  
  /// Migration V3: Add syncStatus to transaction collections
  Future<void> _migrateV3() async {
    final collections = ['sales', 'dispatches', 'returns', 'payments'];
    
    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection)
          .where('syncStatus', isNull: true)
          .limit(500)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'syncStatus': 'synced',
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      // ignore: avoid_print
      print('  - Added syncStatus to ${snapshot.docs.length} documents in $collection');
    }
  }
}

/// Run migration from command line
void main() async {
  // ignore: avoid_print
  print('=== Firestore Schema Migration ===');
  
  final migration = FirestoreMigration();
  await migration.runMigrations();
  
  // ignore: avoid_print
  print('=== Migration Complete ===');
}
