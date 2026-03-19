import 'delegates/firestore_query_delegate.dart';
import 'delegates/firestore_migration_delegate.dart';
import '../utils/app_logger.dart';

/// Firestore Schema Migration Script
/// Version: 2.7
/// Date: March 2026

class FirestoreMigration {
  final FirestoreQueryDelegate _queryDelegate = FirestoreQueryDelegate();
  late final FirestoreMigrationDelegate _delegate =
      FirestoreMigrationDelegate();
  
  static const int currentSchemaVersion = 3;
  static const String schemaVersionDoc = 'schema_version';
  
  /// Run all pending migrations
  Future<void> runMigrations() async {
    final currentVersion = await _getCurrentVersion();
    AppLogger.info('Current schema version: $currentVersion', tag: 'Migration');
    
    if (currentVersion < currentSchemaVersion) {
      AppLogger.info(
        'Running migrations from v$currentVersion to v$currentSchemaVersion',
        tag: 'Migration',
      );
      
      for (int version = currentVersion + 1; version <= currentSchemaVersion; version++) {
        await _runMigration(version);
      }
      
      await _setVersion(currentSchemaVersion);
      AppLogger.info('Migration complete!', tag: 'Migration');
    } else {
      AppLogger.info('Schema is up to date', tag: 'Migration');
    }
  }
  
  /// Get current schema version
  Future<int> _getCurrentVersion() async {
    try {
      final doc = await _queryDelegate.getDocument(
        collection: 'settings',
        documentId: schemaVersionDoc,
      );
      return doc.data()?['version'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  /// Set schema version
  Future<void> _setVersion(int version) async {
    await _delegate.setVersion(schemaVersionDoc, version);
  }
  
  /// Run specific migration
  Future<void> _runMigration(int version) async {
    AppLogger.info('Running migration v$version...', tag: 'Migration');
    
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
        AppLogger.warning('No migration for version $version', tag: 'Migration');
    }
  }
  
  /// Migration V1: Add isDeleted field to all collections
  Future<void> _migrateV1() async {
    final collections = ['sales', 'products', 'customers', 'route_orders'];
    final updated = await _delegate.migrateAddIsDeleted(collections);
    AppLogger.info(
      'Updated $updated documents with isDeleted defaults',
      tag: 'Migration',
    );
  }
  
  /// Migration V2: Canonical Firebase UID for sales
  Future<void> _migrateV2() async {
    final updated = await _delegate.migrateSalesmanUid();
    AppLogger.info(
      'Migrated $updated sales to use Firebase UID',
      tag: 'Migration',
    );
  }
  
  /// Migration V3: Add syncStatus to transaction collections
  Future<void> _migrateV3() async {
    final collections = ['sales', 'dispatches', 'returns', 'payments'];
    final updated = await _delegate.migrateSyncStatus(collections);
    AppLogger.info(
      'Added syncStatus to $updated transaction documents',
      tag: 'Migration',
    );
  }
}

/// Run migration from command line
void main() async {
  AppLogger.info('=== Firestore Schema Migration ===', tag: 'Migration');
  
  final migration = FirestoreMigration();
  await migration.runMigrations();
  
  AppLogger.info('=== Migration Complete ===', tag: 'Migration');
}
