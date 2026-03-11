import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'base_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../data/local/base_entity.dart';
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/sales_target_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'database_service.dart';
import 'outbox_codec.dart';

const targetsCollection = 'sales_targets';

class SalesTarget {
  final String id;
  final String salesmanId;
  final String salesmanName;
  final int month;
  final int year;
  final double targetAmount;
  final double achievedAmount;
  final Map<String, dynamic>? routeTargets;
  final String? createdAt;

  SalesTarget({
    required this.id,
    required this.salesmanId,
    required this.salesmanName,
    required this.month,
    required this.year,
    required this.targetAmount,
    required this.achievedAmount,
    this.routeTargets,
    this.createdAt,
  });

  factory SalesTarget.fromJson(Map<String, dynamic> json) {
    return SalesTarget(
      id: json['id'] as String,
      salesmanId: json['salesmanId'] as String,
      salesmanName: json['salesmanName'] as String,
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      achievedAmount: (json['achievedAmount'] as num).toDouble(),
      routeTargets: json['routeTargets'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class AddSalesTargetPayload {
  final String salesmanId;
  final String salesmanName;
  final int month;
  final int year;
  final double targetAmount;
  final Map<String, dynamic>? routeTargets;

  AddSalesTargetPayload({
    required this.salesmanId,
    required this.salesmanName,
    required this.month,
    required this.year,
    required this.targetAmount,
    this.routeTargets,
  });
}

class SalesTargetsService extends BaseService {
  final DatabaseService _dbService;
  Future<void> Function()? _centralQueueSync;

  SalesTargetsService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  void bindCentralQueueSync(Future<void> Function() callback) {
    _centralQueueSync = callback;
  }

  Future<void> _enqueueTargetForSync(SalesTargetEntity target) async {
    final data = target.toFirebaseJson();
    if (target.routeTargetsJson != null) {
      data['routeTargets'] = _decodeRouteTargets(target.routeTargetsJson);
    }
    data['updatedAt'] = target.updatedAt.toIso8601String();

    final queueId = OutboxCodec.buildQueueId(targetsCollection, data);
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = targetsCollection
      ..action = target.isDeleted ? 'delete' : 'set'
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: data,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(entity);
    });
  }

  Map<String, dynamic>? _decodeRouteTargets(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? _encodeRouteTargets(Map<String, dynamic>? map) {
    if (map == null) return null;
    return jsonEncode(map);
  }

  SalesTarget _entityToDomain(SalesTargetEntity entity) {
    return SalesTarget(
      id: entity.id,
      salesmanId: entity.salesmanId,
      salesmanName: entity.salesmanName,
      month: entity.month,
      year: entity.year,
      targetAmount: entity.targetAmount,
      achievedAmount: entity.achievedAmount,
      routeTargets: _decodeRouteTargets(entity.routeTargetsJson),
      createdAt: entity.createdAt,
    );
  }

  Future<void> syncPendingTargets() async {
    await _syncPendingTargetsLegacy();
  }

  Future<void> _syncPendingTargetsLegacy() async {
    if (_centralQueueSync != null) {
      final pending = await _dbService.salesTargets
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      if (pending.isEmpty) return;

      for (final target in pending) {
        await _enqueueTargetForSync(target);
      }
      await _centralQueueSync!.call();
      return;
    }

    final firestoreDb = db;
    if (firestoreDb == null) return;

    final pending = await _dbService.salesTargets
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    if (pending.isEmpty) return;

    for (final target in pending) {
      try {
        final data = target.toFirebaseJson();
        if (target.routeTargetsJson != null) {
          data['routeTargets'] = _decodeRouteTargets(target.routeTargetsJson);
        }
        data['updatedAt'] = target.updatedAt.toIso8601String();
        await firestoreDb
            .collection(targetsCollection)
            .doc(target.id)
            .set(data, firestore.SetOptions(merge: true));

        target.syncStatus = SyncStatus.synced;
        await _dbService.db.writeTxn(() async {
          await _dbService.salesTargets.put(target);
        });
      } catch (_) {
        // Keep pending; will retry on next call
      }
    }
  }

  Future<List<SalesTarget>> getSalesTargets(String? salesmanId) async {
    try {
      // 1. Local-first (Isar)
      var locals = await _dbService.salesTargets
          .filter()
          .isDeletedEqualTo(false)
          .findAll();

      if (salesmanId != null) {
        locals = locals.where((e) => e.salesmanId == salesmanId).toList();
      }

      if (locals.isNotEmpty) {
        locals.sort((a, b) {
          final yearCmp = b.year.compareTo(a.year);
          if (yearCmp != 0) return yearCmp;
          return b.month.compareTo(a.month);
        });
        return locals.map(_entityToDomain).toList();
      }

      // 2. Fallback to Firestore (bootstrap)
      final firestoreDb = db;
      if (firestoreDb == null) return [];

      firestore.Query q = firestoreDb
          .collection(targetsCollection)
          .orderBy('year', descending: true)
          .orderBy('month', descending: true);

      if (salesmanId != null) {
        q = q.where('salesmanId', isEqualTo: salesmanId);
      }

      final snapshot = await q.get().timeout(const Duration(seconds: 3));
      if (snapshot.docs.isEmpty) return [];

      final entities = <SalesTargetEntity>[];
      final targets = <SalesTarget>[];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        final entity = SalesTargetEntity.fromFirebaseJson(data);
        if (data['routeTargets'] != null) {
          entity.routeTargetsJson = _encodeRouteTargets(
            Map<String, dynamic>.from(data['routeTargets'] as Map),
          );
        }
        entities.add(entity);
        targets.add(_entityToDomain(entity));
      }

      await _dbService.db.writeTxn(() async {
        await _dbService.salesTargets.putAll(entities);
      });

      return targets;
    } catch (e) {
      handleError(e, 'getSalesTargets');
      return [];
    }
  }

  Future<bool> setSalesTarget(AddSalesTargetPayload target) async {
    try {
      final now = DateTime.now();
      final firestoreDb = db;
      SalesTargetEntity? existingLocal = await _dbService.salesTargets
          .filter()
          .salesmanIdEqualTo(target.salesmanId)
          .and()
          .monthEqualTo(target.month)
          .and()
          .yearEqualTo(target.year)
          .and()
          .isDeletedEqualTo(false)
          .findFirst();

      String? docId;
      double achievedAmount =
          existingLocal?.achievedAmount ?? 0; // Default if new
      bool remoteSynced = false;

      if (firestoreDb != null) {
        final q = firestoreDb
            .collection(targetsCollection)
            .where('salesmanId', isEqualTo: target.salesmanId)
            .where('month', isEqualTo: target.month)
            .where('year', isEqualTo: target.year);

        final existing = await q.get();
        if (existing.docs.isNotEmpty) {
          final doc = existing.docs.first;
          docId = doc.id;
          achievedAmount =
              (doc.data()['achievedAmount'] as num? ?? achievedAmount)
                  .toDouble();
          await doc.reference.update({
            'targetAmount': target.targetAmount,
            'routeTargets': target.routeTargets,
            'updatedAt': now.toIso8601String(),
          });
          remoteSynced = true;
        } else {
          final docRef = firestoreDb.collection(targetsCollection).doc();
          docId = docRef.id;
          await docRef.set({
            'salesmanId': target.salesmanId,
            'salesmanName': target.salesmanName,
            'month': target.month,
            'year': target.year,
            'targetAmount': target.targetAmount,
            'routeTargets': target.routeTargets,
            'achievedAmount': 0,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          });
          achievedAmount = 0;
          remoteSynced = true;
        }
      }

      // Ensure we have a stable local ID (for offline use)
      docId ??= existingLocal?.id ?? const Uuid().v4();

      final entity = existingLocal ?? SalesTargetEntity();
      entity.id = docId;
      entity.salesmanId = target.salesmanId;
      entity.salesmanName = target.salesmanName;
      entity.month = target.month;
      entity.year = target.year;
      entity.targetAmount = target.targetAmount;
      entity.achievedAmount = achievedAmount;
      entity.routeTargetsJson = _encodeRouteTargets(target.routeTargets);
      entity.createdAt = entity.createdAt ?? now.toIso8601String();
      entity.updatedAt = now;
      entity.isDeleted = false;
      entity.syncStatus = remoteSynced ? SyncStatus.synced : SyncStatus.pending;

      await _dbService.db.writeTxn(() async {
        await _dbService.salesTargets.put(entity);
      });

      // If we couldn't sync now, try to push pending later when online
      if (!remoteSynced) {
        await syncPendingTargets();
      }

      return true;
    } catch (e) {
      handleError(e, 'setSalesTarget');
      return false;
    }
  }

  Future<double> getLastMonthSales(String salesmanId) async {
    try {
      final now = DateTime.now();
      // First day of current month -> subtract 1 day = last day of prev month
      final lastMonthDate = DateTime(now.year, now.month, 0);
      final lastMonth = lastMonthDate.month;
      final lastMonthYear = lastMonthDate.year;

      // Note: This relies on 'month'/'year' fields being present in Sales collection.
      // If not, we must query by date range.
      // The TS code used `where('month', '==', lastMonth)`.
      // Ensure Sales service adds these fields or query by range.
      // Assuming Sales documents have 'month' and 'year' fields logic as per React legacy logic.
      // If not, we might need to change this query to:
      // createdAt >= StartOfLastMonth AND createdAt <= EndOfLastMonth

      // Let's stick to TS parity: querying 'month' and 'year' fields.
      // If these fields are missing in Flutter created sales, this breaks.
      // If these fields are missing in Flutter created sales, this breaks.
      // But we must assume data schema parity.

      // Local-first from Isar sales
      final locals = await _dbService.sales
          .filter()
          .salesmanIdEqualTo(salesmanId)
          .and()
          .monthEqualTo(lastMonth)
          .and()
          .yearEqualTo(lastMonthYear)
          .findAll();

      double total = 0;
      for (final sale in locals) {
        total += (sale.totalAmount ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      handleError(e, 'getLastMonthSales');
      return 0;
    }
  }
}
