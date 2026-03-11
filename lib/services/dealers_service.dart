// LOCKED: DealersService offline-first caching - 2026-02-05
import 'package:isar/isar.dart';
import 'offline_first_service.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/dealer_entity.dart';
import '../data/local/entities/route_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'outbox_codec.dart';

const dealersCollection = 'dealers';

// Dealer model matching React TypeScript Dealer interface
class Dealer {
  final String id;
  final String name;
  final String contactPerson;
  final String mobile;
  final String? alternateMobile;
  final String? email;
  final String address;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstin;
  final String? pan;
  final String? status; // 'active' or 'inactive'
  final double? commissionPercentage;
  final String? paymentTerms;
  final String? territory;
  final String? assignedRouteId;
  final String? assignedRouteName;
  final double? latitude;
  final double? longitude;
  final String createdAt;
  final String? updatedAt;

  Dealer({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.mobile,
    this.alternateMobile,
    this.email,
    required this.address,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.gstin,
    this.pan,
    this.status,
    this.commissionPercentage,
    this.paymentTerms,
    this.territory,
    this.assignedRouteId,
    this.assignedRouteName,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      contactPerson: json['contactPerson'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      alternateMobile: json['alternateMobile'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      gstin: json['gstin'] as String?,
      pan: json['pan'] as String?,
      status: json['status'] as String? ?? 'active',
      commissionPercentage: json['commissionPercentage'] != null
          ? (json['commissionPercentage'] as num).toDouble()
          : null,
      paymentTerms: json['paymentTerms'] as String?,
      territory: json['territory'] as String?,
      assignedRouteId:
          json['assignedRouteId'] as String? ?? json['routeId'] as String?,
      assignedRouteName:
          json['assignedRouteName'] as String? ??
          json['routeName'] as String? ??
          json['territory'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'mobile': mobile,
      if (alternateMobile != null) 'alternateMobile': alternateMobile,
      if (email != null) 'email': email,
      'address': address,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      'status': status,
      if (commissionPercentage != null)
        'commissionPercentage': commissionPercentage,
      if (paymentTerms != null) 'paymentTerms': paymentTerms,
      if (territory != null) 'territory': territory,
      if (assignedRouteId != null) 'assignedRouteId': assignedRouteId,
      if (assignedRouteName != null) 'assignedRouteName': assignedRouteName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}

class DealersService extends OfflineFirstService {
  DealersService(super.firebase, [super.dbService]);

  static const String _outboxCollection = 'dealers';

  @override
  String get localStorageKey => 'local_dealers';

  @override
  bool get useIsar => true;

  String _queueId(String id) => 'outbox_${_outboxCollection}_$id';

  Future<void> _upsertOutboxInTxn(
    DealerEntity entity, {
    required String action,
  }) async {
    final queueId = _queueId(entity.id);
    final existing = await dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final payload = {
      ...entity.toDomain().toJson(),
      'contactNumber': entity.mobile,
      'updatedAt': entity.updatedAt.toIso8601String(),
      'isDeleted': entity.isDeleted,
    };
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;

    final queue = SyncQueueEntity()
      ..id = queueId
      ..collection = _outboxCollection
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

    await dbService.syncQueue.put(queue);
  }

  Future<List<Dealer>> _fetchDealersFromFirebase({
    String? status,
    int? limitCount,
  }) async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      var query = firestore.collection(dealersCollection).orderBy('name');

      if (status != null) {
        query = firestore
            .collection(dealersCollection)
            .where('status', isEqualTo: status)
            .orderBy('name');
      }

      if (limitCount != null) {
        query = query.limit(limitCount);
      }

      final snapshot = await query.get();
      final dealers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        data['id'] = doc.id;
        return Dealer.fromJson(data);
      }).toList();

      return deduplicate(dealers, (d) => d.id);
    } catch (e) {
      handleError(e, '_fetchDealersFromFirebase');
      return [];
    }
  }

  Future<void> _cacheDealers(List<Dealer> dealers) async {
    if (dealers.isEmpty) return;
    await dbService.db.writeTxn(() async {
      for (final dealer in dealers) {
        await dbService.dealers.put(DealerEntity.fromDomain(dealer));
      }
    });
  }

  String? _normalizeRouteToken(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return normalized.isEmpty ? null : normalized;
  }

  Future<Map<String, Map<String, String>>> _buildRouteLookup() async {
    final routes = await dbService.routes
        .filter()
        .isDeletedEqualTo(false)
        .findAll();

    final lookup = <String, Map<String, String>>{};
    for (final route in routes) {
      final routeId = route.id.trim();
      final routeName = route.name.trim();
      if (routeId.isEmpty || routeName.isEmpty) {
        continue;
      }

      final payload = <String, String>{'id': routeId, 'name': routeName};
      final idToken = _normalizeRouteToken(routeId);
      final nameToken = _normalizeRouteToken(routeName);
      if (idToken != null) {
        lookup[idToken] = payload;
      }
      if (nameToken != null) {
        lookup[nameToken] = payload;
      }
    }
    return lookup;
  }

  Map<String, String>? _resolveDealerRouteMatch(
    DealerEntity dealer,
    Map<String, Map<String, String>> routeLookup,
  ) {
    final tokens = <String>{};
    final assignedRouteIdToken = _normalizeRouteToken(dealer.assignedRouteId);
    final assignedRouteNameToken = _normalizeRouteToken(
      dealer.assignedRouteName,
    );
    final territoryToken = _normalizeRouteToken(dealer.territory);

    if (assignedRouteIdToken != null) tokens.add(assignedRouteIdToken);
    if (assignedRouteNameToken != null) tokens.add(assignedRouteNameToken);
    if (territoryToken != null) tokens.add(territoryToken);

    for (final token in tokens) {
      final match = routeLookup[token];
      if (match != null) {
        return match;
      }
    }
    return null;
  }

  Future<void> _backfillDealerRouteAssignments(
    List<DealerEntity> entities,
  ) async {
    if (entities.isEmpty) return;

    final routeLookup = await _buildRouteLookup();
    if (routeLookup.isEmpty) return;

    final now = DateTime.now();
    final toUpdate = <DealerEntity>[];
    for (final dealer in entities) {
      final match = _resolveDealerRouteMatch(dealer, routeLookup);
      if (match == null) {
        continue;
      }

      final matchedRouteId = match['id'];
      final matchedRouteName = match['name'];
      if (matchedRouteId == null || matchedRouteName == null) {
        continue;
      }

      final hasSameId = dealer.assignedRouteId == matchedRouteId;
      final hasSameName = dealer.assignedRouteName == matchedRouteName;
      if (hasSameId && hasSameName) {
        continue;
      }

      dealer
        ..assignedRouteId = matchedRouteId
        ..assignedRouteName = matchedRouteName
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending;
      toUpdate.add(dealer);
    }

    if (toUpdate.isEmpty) return;

    await dbService.db.writeTxn(() async {
      for (final dealer in toUpdate) {
        await dbService.dealers.put(dealer);
        await _upsertOutboxInTxn(dealer, action: 'set');
      }
    });
  }

  // Get dealers with filters (same logic as React getDealersClient)
  Future<List<Dealer>> getDealers({String? status, int? limitCount}) async {
    try {
      // 1. Read from ISAR first
      var query = dbService.dealers.filter().isDeletedEqualTo(false);
      if (status != null) {
        query = query.statusEqualTo(status);
      }

      var entities = await query.findAll();

      // 2. Fallback to Firebase if local empty (read-through cache)
      if (entities.isEmpty) {
        final remote = await _fetchDealersFromFirebase(
          status: status,
          limitCount: limitCount,
        );
        if (remote.isNotEmpty) {
          await _cacheDealers(remote);
          entities = await query.findAll();
        }
      }

      if (entities.isNotEmpty) {
        await _backfillDealerRouteAssignments(entities);
        entities = await query.findAll();
      }

      // 3. Sort by name (UI parity)
      entities.sort((a, b) => a.name.compareTo(b.name));

      // 4. Limit
      if (limitCount != null && entities.length > limitCount) {
        entities = entities.take(limitCount).toList();
      }

      final dealers = entities.map((e) => e.toDomain()).toList();
      // DEDUPLICATE to prevent duplicate dealers in UI
      return deduplicate(dealers, (d) => d.id);
    } catch (e) {
      throw handleError(e, 'getDealers');
    }
  }

  // Get single dealer by ID (same logic as React getDealerClient)
  Future<Dealer?> getDealerById(String id) async {
    try {
      // 1. Local Isar
      final entity = await dbService.dealers.filter().idEqualTo(id).findFirst();
      if (entity != null && !entity.isDeleted) {
        await _backfillDealerRouteAssignments([entity]);
        return entity.toDomain();
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return null;

      final dealerRef = firestore.collection(dealersCollection).doc(id);
      final docSnap = await dealerRef.get();

      if (docSnap.exists) {
        final data = Map<String, dynamic>.from(docSnap.data() as Map);
        data['id'] = docSnap.id;
        final dealer = Dealer.fromJson(data);

        // Cache locally
        await dbService.db.writeTxn(() async {
          await dbService.dealers.put(DealerEntity.fromDomain(dealer));
        });

        return dealer;
      }

      return null;
    } catch (e) {
      throw handleError(e, 'getDealerById');
    }
  }

  // Add dealer (same logic as React addDealerClient)
  Future<String?> addDealer({
    required String name,
    required String contactPerson,
    required String mobile,
    String? alternateMobile,
    String? email,
    required String address,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? pan,
    String status = 'active',
    double? commissionPercentage,
    String? paymentTerms,
    String? territory,
    String? assignedRouteId,
    String? assignedRouteName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final currentUser = auth?.currentUser;
      if (currentUser == null) {
        throw Exception(
          'Authentication Error: You must be logged in to add a dealer.',
        );
      }

      final dealerId = generateId();
      final now = getCurrentTimestamp();

      final dealer = Dealer(
        id: dealerId,
        name: name,
        contactPerson: contactPerson,
        mobile: mobile,
        alternateMobile: alternateMobile,
        email: email,
        address: address,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pincode: pincode,
        gstin: gstin,
        pan: pan,
        status: status,
        commissionPercentage: commissionPercentage,
        paymentTerms: paymentTerms,
        territory: territory,
        assignedRouteId: assignedRouteId,
        assignedRouteName: assignedRouteName,
        latitude: latitude,
        longitude: longitude,
        createdAt: now,
        updatedAt: null,
      );

      final entity = DealerEntity.fromDomain(dealer)
        ..syncStatus = SyncStatus.pending;

      // 1. Save to Local ISAR first
      await dbService.db.writeTxn(() async {
        await dbService.dealers.put(entity);
        await _upsertOutboxInTxn(entity, action: 'set');
      });

      return dealerId;
    } catch (e) {
      throw handleError(e, 'addDealer');
    }
  }

  // Update dealer (same logic as React updateDealerClient)
  Future<bool> updateDealer({
    required String id,
    String? name,
    String? contactPerson,
    String? mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? pan,
    String? status,
    double? commissionPercentage,
    String? paymentTerms,
    String? territory,
    String? assignedRouteId,
    String? assignedRouteName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final currentUser = auth?.currentUser;
      if (currentUser == null) {
        throw Exception(
          'Authentication Error: You must be logged in to update a dealer.',
        );
      }

      final entity = await dbService.dealers.filter().idEqualTo(id).findFirst();
      if (entity == null) {
        throw Exception('Dealer not found in local storage.');
      }

      // Update fields (local-first)
      if (name != null) entity.name = name;
      if (contactPerson != null) entity.contactPerson = contactPerson;
      if (mobile != null) entity.mobile = mobile;
      if (alternateMobile != null) entity.alternateMobile = alternateMobile;
      if (email != null) entity.email = email;
      if (address != null) entity.address = address;
      if (addressLine2 != null) entity.addressLine2 = addressLine2;
      if (city != null) entity.city = city;
      if (state != null) entity.state = state;
      if (pincode != null) entity.pincode = pincode;
      if (gstin != null) entity.gstin = gstin;
      if (pan != null) entity.pan = pan;
      if (status != null) entity.status = status;
      if (commissionPercentage != null) {
        entity.commissionPercentage = commissionPercentage;
      }
      if (paymentTerms != null) entity.paymentTerms = paymentTerms;
      if (territory != null) entity.territory = territory;
      if (assignedRouteId != null) {
        final normalized = assignedRouteId.trim();
        entity.assignedRouteId = normalized.isEmpty ? null : normalized;
      }
      if (assignedRouteName != null) {
        final normalized = assignedRouteName.trim();
        entity.assignedRouteName = normalized.isEmpty ? null : normalized;
      }
      if (latitude != null) entity.latitude = latitude;
      if (longitude != null) entity.longitude = longitude;

      entity.updatedAt = DateTime.now();
      entity.syncStatus = SyncStatus.pending;

      // 1. Save local
      await dbService.db.writeTxn(() async {
        await dbService.dealers.put(entity);
        await _upsertOutboxInTxn(entity, action: 'set');
      });

      return true;
    } catch (e) {
      throw handleError(e, 'updateDealer');
    }
  }

  // Bulk update dealer status (same logic as React bulkUpdateDealerStatusClient)
  Future<bool> bulkUpdateDealerStatus(
    List<String> dealerIds,
    String status, // 'active' or 'inactive'
  ) async {
    try {
      await dbService.db.writeTxn(() async {
        for (final id in dealerIds) {
          final entity = await dbService.dealers
              .filter()
              .idEqualTo(id)
              .findFirst();
          if (entity != null) {
            entity.status = status;
            entity.updatedAt = DateTime.now();
            entity.syncStatus = SyncStatus.pending;
            await dbService.dealers.put(entity);
            await _upsertOutboxInTxn(entity, action: 'set');
          }
        }
      });
      return true;
    } catch (e) {
      throw handleError(e, 'bulkUpdateDealerStatus');
    }
  }

  // Export dealers (same logic as React exportDealersClient)
  Future<List<Dealer>> exportDealers() async {
    try {
      var entities = await dbService.dealers
          .filter()
          .isDeletedEqualTo(false)
          .findAll();

      if (entities.isEmpty) {
        final remote = await _fetchDealersFromFirebase();
        if (remote.isNotEmpty) {
          await _cacheDealers(remote);
          return remote;
        }
        return [];
      }

      await _backfillDealerRouteAssignments(entities);
      entities = await dbService.dealers
          .filter()
          .isDeletedEqualTo(false)
          .findAll();

      entities.sort((a, b) => a.name.compareTo(b.name));
      final dealers = entities.map((e) => e.toDomain()).toList();
      return deduplicate(dealers, (d) => d.id);
    } catch (e) {
      throw handleError(e, 'exportDealers');
    }
  }
}
