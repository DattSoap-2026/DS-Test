import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/sync/sync_queue_service.dart';
import '../../../services/database_service.dart';
import '../../../data/local/entities/employee_document_entity.dart';
import '../../../data/local/base_entity.dart';
import '../models/employee_document_model.dart';

class DocumentService with ChangeNotifier {
  final DatabaseService _dbService;
  static const String _collection = 'employee_documents';

  DocumentService(this._dbService);

  Future<void> _enqueueOutbox(
    Map<String, dynamic> payload, {
    String action = 'set',
  }) async {
    final documentId = payload['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) {
      return;
    }
    await SyncQueueService.instance.addToQueue(
      collectionName: _collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
  }

  Map<String, dynamic> _toSyncPayload(EmployeeDocumentEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'employeeId': entity.employeeId,
      'documentType': entity.documentType,
      'documentName': entity.documentName,
      'documentNumber': entity.documentNumber,
      'filePath': entity.filePath,
      'cloudUrl': entity.cloudUrl,
      'expiryDate': entity.expiryDate,
      'isVerified': entity.isVerified,
      'verifiedBy': entity.verifiedBy,
      'verifiedDate': entity.verifiedDate,
      'remarks': entity.remarks,
      'isDeleted': entity.isDeleted,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  /// Add a new document
  Future<EmployeeDocument> addDocument({
    required String employeeId,
    required String documentType,
    required String documentName,
    required String sourceFilePath,
    String? documentNumber,
    DateTime? expiryDate,
    String? remarks,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    // Copy file to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(
      path.join(appDir.path, 'employee_docs', employeeId),
    );
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }

    final ext = path.extension(sourceFilePath);
    final destPath = path.join(docsDir.path, '$id$ext');
    await File(sourceFilePath).copy(destPath);

    final entity = EmployeeDocumentEntity()
      ..id = id
      ..employeeId = employeeId
      ..documentType = documentType
      ..documentName = documentName
      ..documentNumber = documentNumber
      ..filePath = destPath
      ..expiryDate = expiryDate?.toIso8601String()
      ..remarks = remarks
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.employeeDocuments.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'set');

    notifyListeners();
    return _toDomain(entity);
  }

  /// Verify a document
  Future<void> verifyDocument(String id, String verifiedBy) async {
    final entity = await _dbService.employeeDocuments
        .filter()
        .idEqualTo(id)
        .findFirst();
    if (entity == null) throw Exception('Document not found');

    entity
      ..isVerified = true
      ..verifiedBy = verifiedBy
      ..verifiedDate = DateTime.now().toIso8601String()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.employeeDocuments.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'update');

    notifyListeners();
  }

  /// Get all documents for an employee
  Future<List<EmployeeDocument>> getEmployeeDocuments(String employeeId) async {
    final entities = await _dbService.employeeDocuments
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();
    return entities.where((e) => !e.isDeleted).map(_toDomain).toList();
  }

  /// Get documents by type
  Future<List<EmployeeDocument>> getDocumentsByType(
    String employeeId,
    String type,
  ) async {
    final entities = await _dbService.employeeDocuments
        .filter()
        .employeeIdEqualTo(employeeId)
        .documentTypeEqualTo(type)
        .findAll();
    return entities.where((e) => !e.isDeleted).map(_toDomain).toList();
  }

  /// Get expiring documents (within 30 days)
  Future<List<EmployeeDocument>> getExpiringDocuments() async {
    final entities = await _dbService.employeeDocuments.where().findAll();
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));

    return entities
        .where((e) {
          if (e.isDeleted) return false;
          if (e.expiryDate == null) return false;
          final expiry = DateTime.parse(e.expiryDate!);
          return expiry.isAfter(now) && expiry.isBefore(threshold);
        })
        .map(_toDomain)
        .toList();
  }

  /// Get expired documents
  Future<List<EmployeeDocument>> getExpiredDocuments() async {
    final entities = await _dbService.employeeDocuments.where().findAll();
    final now = DateTime.now();

    return entities
        .where((e) {
          if (e.isDeleted) return false;
          if (e.expiryDate == null) return false;
          return DateTime.parse(e.expiryDate!).isBefore(now);
        })
        .map(_toDomain)
        .toList();
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    final entity = await _dbService.employeeDocuments
        .filter()
        .idEqualTo(id)
        .findFirst();
    if (entity == null) return;

    await _dbService.db.writeTxn(() async {
      entity
        ..isDeleted = true
        ..syncStatus = SyncStatus.pending
        ..updatedAt = DateTime.now();
      await _dbService.employeeDocuments.put(entity);
    });
    await _enqueueOutbox(_toSyncPayload(entity), action: 'delete');

    notifyListeners();
  }

  /// Get document file
  File? getDocumentFile(EmployeeDocument doc) {
    final file = File(doc.filePath);
    return file.existsSync() ? file : null;
  }

  EmployeeDocument _toDomain(EmployeeDocumentEntity e) {
    return EmployeeDocument(
      id: e.id,
      employeeId: e.employeeId,
      documentType: e.documentType,
      documentName: e.documentName,
      documentNumber: e.documentNumber,
      filePath: e.filePath,
      cloudUrl: e.cloudUrl,
      expiryDate: e.expiryDate != null ? DateTime.parse(e.expiryDate!) : null,
      isVerified: e.isVerified,
      verifiedBy: e.verifiedBy,
      verifiedDate: e.verifiedDate != null
          ? DateTime.parse(e.verifiedDate!)
          : null,
      remarks: e.remarks,
    );
  }
}
