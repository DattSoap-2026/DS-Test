import 'package:isar/isar.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/route_session_entity.dart';
import '../data/local/entities/customer_visit_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'database_service.dart';
import 'base_service.dart';
import 'package:uuid/uuid.dart';
import 'outbox_codec.dart';

const visitsCollection = 'customer_visits';
const sessionsCollection = 'route_sessions';

// Models
class CustomerVisit {
  final String id;
  final String sessionId;
  final String customerId;
  final String customerName;
  final String salesmanId;
  final String salesmanName;
  final String status; // 'in_progress', 'completed', 'skipped'
  final String arrivalTime;
  final String? departureTime;
  final double? visitDuration;
  final String? saleId;
  final double? saleAmount;
  final double? paymentCollected;
  final String? notes;
  final String? photoUrl;
  final String? skipReason;
  final String? skipNote;
  final int sequenceNumber;
  final String createdAt;
  final String? updatedAt;

  CustomerVisit({
    required this.id,
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.salesmanId,
    required this.salesmanName,
    required this.status,
    required this.arrivalTime,
    this.departureTime,
    this.visitDuration,
    this.saleId,
    this.saleAmount,
    this.paymentCollected,
    this.notes,
    this.photoUrl,
    this.skipReason,
    this.skipNote,
    required this.sequenceNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory CustomerVisit.fromJson(Map<String, dynamic> json) {
    return CustomerVisit(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      salesmanId: json['salesmanId'] as String,
      salesmanName: json['salesmanName'] as String,
      status: json['status'] as String,
      arrivalTime: json['arrivalTime'] as String,
      departureTime: json['departureTime'] as String?,
      visitDuration: (json['visitDuration'] as num?)?.toDouble(),
      saleId: json['saleId'] as String?,
      saleAmount: (json['saleAmount'] as num?)?.toDouble(),
      paymentCollected: (json['paymentCollected'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
      skipReason: json['skipReason'] as String?,
      skipNote: json['skipNote'] as String?,
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'customerId': customerId,
      'customerName': customerName,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'status': status,
      'arrivalTime': arrivalTime,
      if (departureTime != null) 'departureTime': departureTime,
      if (visitDuration != null) 'visitDuration': visitDuration,
      if (saleId != null) 'saleId': saleId,
      if (saleAmount != null) 'saleAmount': saleAmount,
      if (paymentCollected != null) 'paymentCollected': paymentCollected,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (skipReason != null) 'skipReason': skipReason,
      if (skipNote != null) 'skipNote': skipNote,
      'sequenceNumber': sequenceNumber,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}

class RouteSession {
  final String id;
  final String salesmanId;
  final String salesmanName;
  final String routeId;
  final String routeName;
  final String date;
  final String startTime;
  final String? endTime;
  final String status; // 'active', 'completed'
  final double totalDistance;
  final int plannedStops;
  final int completedStops;
  final int skippedStops;
  final double totalSales;
  final double totalCollection;
  final String createdAt;
  final String updatedAt;

  RouteSession({
    required this.id,
    required this.salesmanId,
    required this.salesmanName,
    required this.routeId,
    required this.routeName,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.totalDistance,
    required this.plannedStops,
    required this.completedStops,
    required this.skippedStops,
    required this.totalSales,
    required this.totalCollection,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RouteSession.fromJson(Map<String, dynamic> json) {
    return RouteSession(
      id: json['id'] as String? ?? '',
      salesmanId: json['salesmanId'] as String,
      salesmanName: json['salesmanName'] as String,
      routeId: json['routeId'] as String? ?? '',
      routeName: json['routeName'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String?,
      status: json['status'] as String,
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
      plannedStops: (json['plannedStops'] as num?)?.toInt() ?? 0,
      completedStops: (json['completedStops'] as num?)?.toInt() ?? 0,
      skippedStops: (json['skippedStops'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalCollection: (json['totalCollection'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'routeId': routeId,
      'routeName': routeName,
      'date': date,
      'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'status': status,
      'totalDistance': totalDistance,
      'plannedStops': plannedStops,
      'completedStops': completedStops,
      'skippedStops': skippedStops,
      'totalSales': totalSales,
      'totalCollection': totalCollection,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class VisitService extends BaseService {
  final DatabaseService _dbService;

  VisitService(super.firebase, this._dbService);

  Future<void> _enqueueOutbox({
    required String collection,
    required Map<String, dynamic> payload,
    String action = 'set',
    String? explicitRecordKey,
  }) async {
    final queueId = OutboxCodec.buildQueueId(
      collection,
      payload,
      explicitRecordKey: explicitRecordKey,
    );
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;
    final queueEntity = SyncQueueEntity()
      ..id = queueId
      ..collection = collection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(queueEntity);
    });
  }

  Map<String, dynamic> _routePayload(RouteSessionEntity entity) {
    final payload = entity.toDomain().toJson();
    payload['id'] = entity.id;
    payload['updatedAt'] = entity.updatedAt.toIso8601String();
    return payload;
  }

  Map<String, dynamic> _visitPayload(CustomerVisitEntity entity) {
    final payload = entity.toDomain().toJson();
    payload['id'] = entity.id;
    payload['updatedAt'] = entity.updatedAt.toIso8601String();
    return payload;
  }

  Stream<List<RouteSession>> subscribeToDateSessions(String date) {
    return _dbService.routeSessions
        .filter()
        .dateEqualTo(date)
        .sortByStartTime()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  Stream<List<CustomerVisit>> subscribeToSessionVisits(String sessionId) {
    return _dbService.customerVisits
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortBySequenceNumber()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  Future<RouteSession?> getActiveSession(String salesmanId) async {
    try {
      final entity = await _dbService.routeSessions
          .filter()
          .salesmanIdEqualTo(salesmanId)
          .statusEqualTo('active')
          .findFirst();

      return entity?.toDomain();
    } catch (e) {
      handleError(e, 'getActiveSession');
      return null;
    }
  }

  Future<String?> startRouteSession(Map<String, dynamic> sessionData) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final session = RouteSession(
        id: id,
        salesmanId: sessionData['salesmanId'],
        salesmanName: sessionData['salesmanName'],
        routeId: sessionData['routeId'] ?? '',
        routeName: sessionData['routeName'],
        date: sessionData['date'] ?? now.toIso8601String().split('T')[0],
        startTime: sessionData['startTime'] ?? now.toIso8601String(),
        status: 'active',
        totalDistance: 0.0,
        plannedStops: sessionData['plannedStops'] ?? 0,
        completedStops: 0,
        skippedStops: 0,
        totalSales: 0.0,
        totalCollection: 0.0,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      final entity = RouteSessionEntity.fromDomain(session);
      entity.syncStatus = SyncStatus.pending;

      await _dbService.db.writeTxn(() async {
        await _dbService.routeSessions.put(entity);
      });
      await _enqueueOutbox(
        collection: sessionsCollection,
        payload: _routePayload(entity),
        action: 'set',
        explicitRecordKey: entity.id,
      );

      return id;
    } catch (e) {
      handleError(e, 'startRouteSession');
      return null;
    }
  }

  Future<bool> endRouteSession(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    try {
      Map<String, dynamic>? payload;
      final success = await _dbService.db.writeTxn(() async {
        final entity = await _dbService.routeSessions
            .filter()
            .idEqualTo(sessionId)
            .findFirst();
        if (entity == null) return false;

        entity.endTime = data['endTime'] ?? DateTime.now().toIso8601String();
        entity.status = 'completed';
        entity.totalDistance =
            (data['totalDistance'] as num?)?.toDouble() ?? entity.totalDistance;
        entity.totalSales =
            (data['totalSales'] as num?)?.toDouble() ?? entity.totalSales;
        entity.totalCollection =
            (data['totalCollection'] as num?)?.toDouble() ??
            entity.totalCollection;
        entity.updatedAt = DateTime.now();
        entity.syncStatus = SyncStatus.pending;

        await _dbService.routeSessions.put(entity);
        payload = _routePayload(entity);
        return true;
      });
      if (success && payload != null) {
        await _enqueueOutbox(
          collection: sessionsCollection,
          payload: payload!,
          action: 'update',
          explicitRecordKey: payload!['id']?.toString(),
        );
      }
      return success;
    } catch (e) {
      handleError(e, 'endRouteSession');
      return false;
    }
  }

  Future<String?> startCustomerVisit(Map<String, dynamic> visitData) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final visit = CustomerVisit(
        id: id,
        sessionId: visitData['sessionId'],
        customerId: visitData['customerId'],
        customerName: visitData['customerName'],
        salesmanId: visitData['salesmanId'],
        salesmanName: visitData['salesmanName'],
        status: 'in_progress',
        arrivalTime: visitData['arrivalTime'] ?? now.toIso8601String(),
        sequenceNumber: visitData['sequenceNumber'] ?? 0,
        createdAt: now.toIso8601String(),
      );

      final entity = CustomerVisitEntity.fromDomain(visit);
      entity.syncStatus = SyncStatus.pending;

      await _dbService.db.writeTxn(() async {
        await _dbService.customerVisits.put(entity);
      });
      await _enqueueOutbox(
        collection: visitsCollection,
        payload: _visitPayload(entity),
        action: 'set',
        explicitRecordKey: entity.id,
      );

      return id;
    } catch (e) {
      handleError(e, 'startCustomerVisit');
      return null;
    }
  }

  Future<bool> completeCustomerVisit(
    String visitId,
    Map<String, dynamic> data,
  ) async {
    try {
      Map<String, dynamic>? visitSyncPayload;
      Map<String, dynamic>? sessionSyncPayload;
      final success = await _dbService.db.writeTxn(() async {
        final entity = await _dbService.customerVisits
            .filter()
            .idEqualTo(visitId)
            .findFirst();
        if (entity == null) return false;

        entity.status = data['status'] ?? 'completed';
        entity.departureTime =
            data['departureTime'] ?? DateTime.now().toIso8601String();
        entity.visitDuration = (data['visitDuration'] as num?)?.toDouble();
        entity.saleId = data['saleId'];
        entity.saleAmount = (data['saleAmount'] as num?)?.toDouble();
        entity.paymentCollected = (data['paymentCollected'] as num?)
            ?.toDouble();
        entity.notes = data['notes'];
        entity.photoUrl = data['photoUrl'];
        entity.skipReason = data['skipReason'];
        entity.skipNote = data['skipNote'];
        entity.updatedAt = DateTime.now();
        entity.syncStatus = SyncStatus.pending;

        await _dbService.customerVisits.put(entity);
        visitSyncPayload = _visitPayload(entity);

        // Update session stats
        final session = await _dbService.routeSessions
            .filter()
            .idEqualTo(entity.sessionId)
            .findFirst();
        if (session != null) {
          if (entity.status == 'completed') {
            session.completedStops++;
          } else if (entity.status == 'skipped') {
            session.skippedStops++;
          }
          session.totalSales += entity.saleAmount ?? 0.0;
          session.totalCollection += entity.paymentCollected ?? 0.0;
          session.updatedAt = DateTime.now();
          session.syncStatus = SyncStatus.pending;
          await _dbService.routeSessions.put(session);
          sessionSyncPayload = _routePayload(session);
        }

        return true;
      });
      if (success) {
        if (visitSyncPayload != null) {
          await _enqueueOutbox(
            collection: visitsCollection,
            payload: visitSyncPayload!,
            action: 'update',
            explicitRecordKey: visitSyncPayload!['id']?.toString(),
          );
        }
        if (sessionSyncPayload != null) {
          await _enqueueOutbox(
            collection: sessionsCollection,
            payload: sessionSyncPayload!,
            action: 'update',
            explicitRecordKey: sessionSyncPayload!['id']?.toString(),
          );
        }
      }
      return success;
    } catch (e) {
      handleError(e, 'completeCustomerVisit');
      return false;
    }
  }
}
