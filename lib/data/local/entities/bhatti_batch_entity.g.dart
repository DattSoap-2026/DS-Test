// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bhatti_batch_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBhattiBatchEntityCollection on Isar {
  IsarCollection<BhattiBatchEntity> get bhattiBatchEntitys => this.collection();
}

const BhattiBatchEntitySchema = CollectionSchema(
  name: r'BhattiBatchEntity',
  id: -7369350672140991869,
  properties: {
    r'batchCount': PropertySchema(
      id: 0,
      name: r'batchCount',
      type: IsarType.long,
    ),
    r'batchNumber': PropertySchema(
      id: 1,
      name: r'batchNumber',
      type: IsarType.string,
    ),
    r'bhattiName': PropertySchema(
      id: 2,
      name: r'bhattiName',
      type: IsarType.string,
    ),
    r'costPerBox': PropertySchema(
      id: 3,
      name: r'costPerBox',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 5,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 6,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 7,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 8,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 9,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'issueId': PropertySchema(
      id: 10,
      name: r'issueId',
      type: IsarType.string,
    ),
    r'lastSynced': PropertySchema(
      id: 11,
      name: r'lastSynced',
      type: IsarType.dateTime,
    ),
    r'outputBoxes': PropertySchema(
      id: 12,
      name: r'outputBoxes',
      type: IsarType.long,
    ),
    r'rawMaterialsConsumed': PropertySchema(
      id: 13,
      name: r'rawMaterialsConsumed',
      type: IsarType.objectList,
      target: r'ConsumedItem',
    ),
    r'status': PropertySchema(
      id: 14,
      name: r'status',
      type: IsarType.string,
    ),
    r'supervisorId': PropertySchema(
      id: 15,
      name: r'supervisorId',
      type: IsarType.string,
    ),
    r'supervisorName': PropertySchema(
      id: 16,
      name: r'supervisorName',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 17,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _BhattiBatchEntitysyncStatusEnumValueMap,
    ),
    r'tankConsumptions': PropertySchema(
      id: 18,
      name: r'tankConsumptions',
      type: IsarType.objectList,
      target: r'TankConsumptionItem',
    ),
    r'targetProductId': PropertySchema(
      id: 19,
      name: r'targetProductId',
      type: IsarType.string,
    ),
    r'targetProductName': PropertySchema(
      id: 20,
      name: r'targetProductName',
      type: IsarType.string,
    ),
    r'totalBatchCost': PropertySchema(
      id: 21,
      name: r'totalBatchCost',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 22,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 23,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _bhattiBatchEntityEstimateSize,
  serialize: _bhattiBatchEntitySerialize,
  deserialize: _bhattiBatchEntityDeserialize,
  deserializeProp: _bhattiBatchEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'bhattiName': IndexSchema(
      id: -6905949480009022675,
      name: r'bhattiName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bhattiName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'batchNumber': IndexSchema(
      id: -5361927408577734280,
      name: r'batchNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'batchNumber',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'targetProductId': IndexSchema(
      id: -8319801364029792,
      name: r'targetProductId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetProductId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'ConsumedItem': ConsumedItemSchema,
    r'TankConsumptionItem': TankConsumptionItemSchema,
    r'LotConsumptionItem': LotConsumptionItemSchema
  },
  getId: _bhattiBatchEntityGetId,
  getLinks: _bhattiBatchEntityGetLinks,
  attach: _bhattiBatchEntityAttach,
  version: '3.1.0+1',
);

int _bhattiBatchEntityEstimateSize(
  BhattiBatchEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.batchNumber.length * 3;
  bytesCount += 3 + object.bhattiName.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.issueId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawMaterialsConsumed.length * 3;
  {
    final offsets = allOffsets[ConsumedItem]!;
    for (var i = 0; i < object.rawMaterialsConsumed.length; i++) {
      final value = object.rawMaterialsConsumed[i];
      bytesCount += ConsumedItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.supervisorId.length * 3;
  bytesCount += 3 + object.supervisorName.length * 3;
  bytesCount += 3 + object.tankConsumptions.length * 3;
  {
    final offsets = allOffsets[TankConsumptionItem]!;
    for (var i = 0; i < object.tankConsumptions.length; i++) {
      final value = object.tankConsumptions[i];
      bytesCount +=
          TankConsumptionItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.targetProductId.length * 3;
  bytesCount += 3 + object.targetProductName.length * 3;
  return bytesCount;
}

void _bhattiBatchEntitySerialize(
  BhattiBatchEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.batchCount);
  writer.writeString(offsets[1], object.batchNumber);
  writer.writeString(offsets[2], object.bhattiName);
  writer.writeDouble(offsets[3], object.costPerBox);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeDateTime(offsets[5], object.deletedAt);
  writer.writeString(offsets[6], object.deviceId);
  writer.writeString(offsets[7], object.id);
  writer.writeBool(offsets[8], object.isDeleted);
  writer.writeBool(offsets[9], object.isSynced);
  writer.writeString(offsets[10], object.issueId);
  writer.writeDateTime(offsets[11], object.lastSynced);
  writer.writeLong(offsets[12], object.outputBoxes);
  writer.writeObjectList<ConsumedItem>(
    offsets[13],
    allOffsets,
    ConsumedItemSchema.serialize,
    object.rawMaterialsConsumed,
  );
  writer.writeString(offsets[14], object.status);
  writer.writeString(offsets[15], object.supervisorId);
  writer.writeString(offsets[16], object.supervisorName);
  writer.writeByte(offsets[17], object.syncStatus.index);
  writer.writeObjectList<TankConsumptionItem>(
    offsets[18],
    allOffsets,
    TankConsumptionItemSchema.serialize,
    object.tankConsumptions,
  );
  writer.writeString(offsets[19], object.targetProductId);
  writer.writeString(offsets[20], object.targetProductName);
  writer.writeDouble(offsets[21], object.totalBatchCost);
  writer.writeDateTime(offsets[22], object.updatedAt);
  writer.writeLong(offsets[23], object.version);
}

BhattiBatchEntity _bhattiBatchEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BhattiBatchEntity();
  object.batchCount = reader.readLong(offsets[0]);
  object.batchNumber = reader.readString(offsets[1]);
  object.bhattiName = reader.readString(offsets[2]);
  object.costPerBox = reader.readDouble(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[5]);
  object.deviceId = reader.readString(offsets[6]);
  object.id = reader.readString(offsets[7]);
  object.isDeleted = reader.readBool(offsets[8]);
  object.isSynced = reader.readBool(offsets[9]);
  object.issueId = reader.readStringOrNull(offsets[10]);
  object.lastSynced = reader.readDateTimeOrNull(offsets[11]);
  object.outputBoxes = reader.readLong(offsets[12]);
  object.rawMaterialsConsumed = reader.readObjectList<ConsumedItem>(
        offsets[13],
        ConsumedItemSchema.deserialize,
        allOffsets,
        ConsumedItem(),
      ) ??
      [];
  object.status = reader.readString(offsets[14]);
  object.supervisorId = reader.readString(offsets[15]);
  object.supervisorName = reader.readString(offsets[16]);
  object.syncStatus = _BhattiBatchEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[17])] ??
      SyncStatus.pending;
  object.tankConsumptions = reader.readObjectList<TankConsumptionItem>(
        offsets[18],
        TankConsumptionItemSchema.deserialize,
        allOffsets,
        TankConsumptionItem(),
      ) ??
      [];
  object.targetProductId = reader.readString(offsets[19]);
  object.targetProductName = reader.readString(offsets[20]);
  object.totalBatchCost = reader.readDouble(offsets[21]);
  object.updatedAt = reader.readDateTime(offsets[22]);
  object.version = reader.readLong(offsets[23]);
  return object;
}

P _bhattiBatchEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readObjectList<ConsumedItem>(
            offset,
            ConsumedItemSchema.deserialize,
            allOffsets,
            ConsumedItem(),
          ) ??
          []) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (_BhattiBatchEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 18:
      return (reader.readObjectList<TankConsumptionItem>(
            offset,
            TankConsumptionItemSchema.deserialize,
            allOffsets,
            TankConsumptionItem(),
          ) ??
          []) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDouble(offset)) as P;
    case 22:
      return (reader.readDateTime(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BhattiBatchEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _BhattiBatchEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _bhattiBatchEntityGetId(BhattiBatchEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _bhattiBatchEntityGetLinks(
    BhattiBatchEntity object) {
  return [];
}

void _bhattiBatchEntityAttach(
    IsarCollection<dynamic> col, Id id, BhattiBatchEntity object) {}

extension BhattiBatchEntityByIndex on IsarCollection<BhattiBatchEntity> {
  Future<BhattiBatchEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  BhattiBatchEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<BhattiBatchEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<BhattiBatchEntity?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(BhattiBatchEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(BhattiBatchEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<BhattiBatchEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<BhattiBatchEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension BhattiBatchEntityQueryWhereSort
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QWhere> {
  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BhattiBatchEntityQueryWhere
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QWhereClause> {
  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      bhattiNameEqualTo(String bhattiName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bhattiName',
        value: [bhattiName],
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      bhattiNameNotEqualTo(String bhattiName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bhattiName',
              lower: [],
              upper: [bhattiName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bhattiName',
              lower: [bhattiName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bhattiName',
              lower: [bhattiName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bhattiName',
              lower: [],
              upper: [bhattiName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      batchNumberEqualTo(String batchNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'batchNumber',
        value: [batchNumber],
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      batchNumberNotEqualTo(String batchNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [],
              upper: [batchNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [batchNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [batchNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [],
              upper: [batchNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      targetProductIdEqualTo(String targetProductId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetProductId',
        value: [targetProductId],
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      targetProductIdNotEqualTo(String targetProductId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetProductId',
              lower: [],
              upper: [targetProductId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetProductId',
              lower: [targetProductId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetProductId',
              lower: [targetProductId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetProductId',
              lower: [],
              upper: [targetProductId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterWhereClause>
      idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BhattiBatchEntityQueryFilter
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QFilterCondition> {
  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      batchNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bhattiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bhattiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bhattiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bhattiName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bhattiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bhattiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bhattiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bhattiName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bhattiName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      bhattiNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bhattiName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      costPerBoxEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costPerBox',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      costPerBoxGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costPerBox',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      costPerBoxLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costPerBox',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      costPerBoxBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costPerBox',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'issueId',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'issueId',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issueId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issueId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issueId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      issueIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issueId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      lastSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      lastSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      lastSyncedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      lastSyncedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      lastSyncedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      lastSyncedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSynced',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      outputBoxesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputBoxes',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      outputBoxesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outputBoxes',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      outputBoxesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outputBoxes',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      outputBoxesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outputBoxes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      rawMaterialsConsumedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rawMaterialsConsumed',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      rawMaterialsConsumedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rawMaterialsConsumed',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      rawMaterialsConsumedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rawMaterialsConsumed',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      rawMaterialsConsumedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rawMaterialsConsumed',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      rawMaterialsConsumedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rawMaterialsConsumed',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      rawMaterialsConsumedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rawMaterialsConsumed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supervisorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supervisorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supervisorId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supervisorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supervisorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      supervisorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supervisorName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      syncStatusGreaterThan(
    SyncStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      syncStatusLessThan(
    SyncStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      syncStatusBetween(
    SyncStatus lower,
    SyncStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      tankConsumptionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tankConsumptions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      tankConsumptionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tankConsumptions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      tankConsumptionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tankConsumptions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      tankConsumptionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tankConsumptions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      tankConsumptionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tankConsumptions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      tankConsumptionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tankConsumptions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetProductId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetProductId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetProductName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetProductName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetProductName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      targetProductNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetProductName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      totalBatchCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBatchCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      totalBatchCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBatchCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      totalBatchCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBatchCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      totalBatchCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBatchCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BhattiBatchEntityQueryObject
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QFilterCondition> {
  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      rawMaterialsConsumedElement(FilterQuery<ConsumedItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'rawMaterialsConsumed');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterFilterCondition>
      tankConsumptionsElement(FilterQuery<TankConsumptionItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'tankConsumptions');
    });
  }
}

extension BhattiBatchEntityQueryLinks
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QFilterCondition> {}

extension BhattiBatchEntityQuerySortBy
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QSortBy> {
  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByBatchCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByBatchCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByBatchNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByBatchNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByBhattiName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByBhattiNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByCostPerBox() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerBox', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByCostPerBoxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerBox', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByIssueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByIssueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByOutputBoxes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByOutputBoxesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortBySupervisorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortBySupervisorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByTargetProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByTargetProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByTargetProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductName', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByTargetProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductName', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByTotalBatchCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByTotalBatchCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension BhattiBatchEntityQuerySortThenBy
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QSortThenBy> {
  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByBatchCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByBatchCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByBatchNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByBatchNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByBhattiName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByBhattiNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByCostPerBox() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerBox', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByCostPerBoxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerBox', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIssueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByIssueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByOutputBoxes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByOutputBoxesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenBySupervisorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenBySupervisorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByTargetProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByTargetProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByTargetProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductName', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByTargetProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductName', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByTotalBatchCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByTotalBatchCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension BhattiBatchEntityQueryWhereDistinct
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct> {
  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByBatchCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchCount');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByBatchNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByBhattiName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bhattiName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByCostPerBox() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costPerBox');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByIssueId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issueId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSynced');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByOutputBoxes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputBoxes');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctBySupervisorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctBySupervisorName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisorName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByTargetProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetProductId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByTargetProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetProductName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByTotalBatchCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBatchCost');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension BhattiBatchEntityQueryProperty
    on QueryBuilder<BhattiBatchEntity, BhattiBatchEntity, QQueryProperty> {
  QueryBuilder<BhattiBatchEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<BhattiBatchEntity, int, QQueryOperations> batchCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchCount');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations>
      batchNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchNumber');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations>
      bhattiNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bhattiName');
    });
  }

  QueryBuilder<BhattiBatchEntity, double, QQueryOperations>
      costPerBoxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costPerBox');
    });
  }

  QueryBuilder<BhattiBatchEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BhattiBatchEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BhattiBatchEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<BhattiBatchEntity, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<BhattiBatchEntity, String?, QQueryOperations> issueIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issueId');
    });
  }

  QueryBuilder<BhattiBatchEntity, DateTime?, QQueryOperations>
      lastSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSynced');
    });
  }

  QueryBuilder<BhattiBatchEntity, int, QQueryOperations> outputBoxesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputBoxes');
    });
  }

  QueryBuilder<BhattiBatchEntity, List<ConsumedItem>, QQueryOperations>
      rawMaterialsConsumedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawMaterialsConsumed');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations>
      supervisorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisorId');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations>
      supervisorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisorName');
    });
  }

  QueryBuilder<BhattiBatchEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<BhattiBatchEntity, List<TankConsumptionItem>, QQueryOperations>
      tankConsumptionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tankConsumptions');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations>
      targetProductIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetProductId');
    });
  }

  QueryBuilder<BhattiBatchEntity, String, QQueryOperations>
      targetProductNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetProductName');
    });
  }

  QueryBuilder<BhattiBatchEntity, double, QQueryOperations>
      totalBatchCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBatchCost');
    });
  }

  QueryBuilder<BhattiBatchEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BhattiBatchEntity, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ConsumedItemSchema = Schema(
  name: r'ConsumedItem',
  id: 8945468772131641824,
  properties: {
    r'cost': PropertySchema(
      id: 0,
      name: r'cost',
      type: IsarType.double,
    ),
    r'materialId': PropertySchema(
      id: 1,
      name: r'materialId',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'unit': PropertySchema(
      id: 4,
      name: r'unit',
      type: IsarType.string,
    )
  },
  estimateSize: _consumedItemEstimateSize,
  serialize: _consumedItemSerialize,
  deserialize: _consumedItemDeserialize,
  deserializeProp: _consumedItemDeserializeProp,
);

int _consumedItemEstimateSize(
  ConsumedItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.materialId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.unit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _consumedItemSerialize(
  ConsumedItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cost);
  writer.writeString(offsets[1], object.materialId);
  writer.writeString(offsets[2], object.name);
  writer.writeDouble(offsets[3], object.quantity);
  writer.writeString(offsets[4], object.unit);
}

ConsumedItem _consumedItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConsumedItem();
  object.cost = reader.readDoubleOrNull(offsets[0]);
  object.materialId = reader.readStringOrNull(offsets[1]);
  object.name = reader.readStringOrNull(offsets[2]);
  object.quantity = reader.readDoubleOrNull(offsets[3]);
  object.unit = reader.readStringOrNull(offsets[4]);
  return object;
}

P _consumedItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ConsumedItemQueryFilter
    on QueryBuilder<ConsumedItem, ConsumedItem, QFilterCondition> {
  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> costIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cost',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      costIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cost',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> costEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      costGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> costLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> costBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'materialId',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'materialId',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'materialId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'materialId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      materialIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'materialId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      quantityEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      quantityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      quantityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      quantityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> unitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      unitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> unitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      unitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> unitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> unitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> unitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition> unitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<ConsumedItem, ConsumedItem, QAfterFilterCondition>
      unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }
}

extension ConsumedItemQueryObject
    on QueryBuilder<ConsumedItem, ConsumedItem, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TankConsumptionItemSchema = Schema(
  name: r'TankConsumptionItem',
  id: 631754633279154553,
  properties: {
    r'lots': PropertySchema(
      id: 0,
      name: r'lots',
      type: IsarType.objectList,
      target: r'LotConsumptionItem',
    ),
    r'materialId': PropertySchema(
      id: 1,
      name: r'materialId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 2,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'tankId': PropertySchema(
      id: 3,
      name: r'tankId',
      type: IsarType.string,
    ),
    r'tankName': PropertySchema(
      id: 4,
      name: r'tankName',
      type: IsarType.string,
    )
  },
  estimateSize: _tankConsumptionItemEstimateSize,
  serialize: _tankConsumptionItemSerialize,
  deserialize: _tankConsumptionItemDeserialize,
  deserializeProp: _tankConsumptionItemDeserializeProp,
);

int _tankConsumptionItemEstimateSize(
  TankConsumptionItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.lots;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[LotConsumptionItem]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              LotConsumptionItemSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.materialId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tankId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tankName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _tankConsumptionItemSerialize(
  TankConsumptionItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<LotConsumptionItem>(
    offsets[0],
    allOffsets,
    LotConsumptionItemSchema.serialize,
    object.lots,
  );
  writer.writeString(offsets[1], object.materialId);
  writer.writeDouble(offsets[2], object.quantity);
  writer.writeString(offsets[3], object.tankId);
  writer.writeString(offsets[4], object.tankName);
}

TankConsumptionItem _tankConsumptionItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TankConsumptionItem();
  object.lots = reader.readObjectList<LotConsumptionItem>(
    offsets[0],
    LotConsumptionItemSchema.deserialize,
    allOffsets,
    LotConsumptionItem(),
  );
  object.materialId = reader.readStringOrNull(offsets[1]);
  object.quantity = reader.readDoubleOrNull(offsets[2]);
  object.tankId = reader.readStringOrNull(offsets[3]);
  object.tankName = reader.readStringOrNull(offsets[4]);
  return object;
}

P _tankConsumptionItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<LotConsumptionItem>(
        offset,
        LotConsumptionItemSchema.deserialize,
        allOffsets,
        LotConsumptionItem(),
      )) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TankConsumptionItemQueryFilter on QueryBuilder<TankConsumptionItem,
    TankConsumptionItem, QFilterCondition> {
  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lots',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lots',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lots',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lots',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lots',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lots',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lots',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lots',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'materialId',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'materialId',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'materialId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'materialId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      materialIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'materialId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      quantityEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      quantityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      quantityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      quantityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tankId',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tankId',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tankId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tankId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tankId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tankId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tankName',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tankName',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tankName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tankName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tankName',
        value: '',
      ));
    });
  }

  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      tankNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tankName',
        value: '',
      ));
    });
  }
}

extension TankConsumptionItemQueryObject on QueryBuilder<TankConsumptionItem,
    TankConsumptionItem, QFilterCondition> {
  QueryBuilder<TankConsumptionItem, TankConsumptionItem, QAfterFilterCondition>
      lotsElement(FilterQuery<LotConsumptionItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'lots');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const LotConsumptionItemSchema = Schema(
  name: r'LotConsumptionItem',
  id: -8203302221308783228,
  properties: {
    r'cost': PropertySchema(
      id: 0,
      name: r'cost',
      type: IsarType.double,
    ),
    r'lotId': PropertySchema(
      id: 1,
      name: r'lotId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 2,
      name: r'quantity',
      type: IsarType.double,
    )
  },
  estimateSize: _lotConsumptionItemEstimateSize,
  serialize: _lotConsumptionItemSerialize,
  deserialize: _lotConsumptionItemDeserialize,
  deserializeProp: _lotConsumptionItemDeserializeProp,
);

int _lotConsumptionItemEstimateSize(
  LotConsumptionItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lotId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _lotConsumptionItemSerialize(
  LotConsumptionItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cost);
  writer.writeString(offsets[1], object.lotId);
  writer.writeDouble(offsets[2], object.quantity);
}

LotConsumptionItem _lotConsumptionItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LotConsumptionItem();
  object.cost = reader.readDoubleOrNull(offsets[0]);
  object.lotId = reader.readStringOrNull(offsets[1]);
  object.quantity = reader.readDoubleOrNull(offsets[2]);
  return object;
}

P _lotConsumptionItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension LotConsumptionItemQueryFilter
    on QueryBuilder<LotConsumptionItem, LotConsumptionItem, QFilterCondition> {
  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      costIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cost',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      costIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cost',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      costEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      costGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      costLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      costBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lotId',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lotId',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lotId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lotId',
        value: '',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      lotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lotId',
        value: '',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      quantityEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      quantityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      quantityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LotConsumptionItem, LotConsumptionItem, QAfterFilterCondition>
      quantityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension LotConsumptionItemQueryObject
    on QueryBuilder<LotConsumptionItem, LotConsumptionItem, QFilterCondition> {}
