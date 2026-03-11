// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_command_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryCommandEntityCollection on Isar {
  IsarCollection<InventoryCommandEntity> get inventoryCommandEntitys =>
      this.collection();
}

const InventoryCommandEntitySchema = CollectionSchema(
  name: r'InventoryCommandEntity',
  id: -3604265516443447152,
  properties: {
    r'actorLegacyAppUserId': PropertySchema(
      id: 0,
      name: r'actorLegacyAppUserId',
      type: IsarType.string,
    ),
    r'actorUid': PropertySchema(
      id: 1,
      name: r'actorUid',
      type: IsarType.string,
    ),
    r'appliedLocally': PropertySchema(
      id: 2,
      name: r'appliedLocally',
      type: IsarType.bool,
    ),
    r'appliedRemotely': PropertySchema(
      id: 3,
      name: r'appliedRemotely',
      type: IsarType.bool,
    ),
    r'commandId': PropertySchema(
      id: 4,
      name: r'commandId',
      type: IsarType.string,
    ),
    r'commandType': PropertySchema(
      id: 5,
      name: r'commandType',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 7,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 8,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 9,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'payload': PropertySchema(
      id: 10,
      name: r'payload',
      type: IsarType.string,
    ),
    r'retryMeta': PropertySchema(
      id: 11,
      name: r'retryMeta',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 12,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _InventoryCommandEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _inventoryCommandEntityEstimateSize,
  serialize: _inventoryCommandEntitySerialize,
  deserialize: _inventoryCommandEntityDeserialize,
  deserializeProp: _inventoryCommandEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'commandType': IndexSchema(
      id: 9093429669538910327,
      name: r'commandType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'commandType',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'actorUid': IndexSchema(
      id: 2911305686087963256,
      name: r'actorUid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'actorUid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'commandId': IndexSchema(
      id: -4064098501468219660,
      name: r'commandId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'commandId',
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
  embeddedSchemas: {},
  getId: _inventoryCommandEntityGetId,
  getLinks: _inventoryCommandEntityGetLinks,
  attach: _inventoryCommandEntityAttach,
  version: '3.1.0+1',
);

int _inventoryCommandEntityEstimateSize(
  InventoryCommandEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.actorLegacyAppUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.actorUid.length * 3;
  bytesCount += 3 + object.commandId.length * 3;
  bytesCount += 3 + object.commandType.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  {
    final value = object.retryMeta;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _inventoryCommandEntitySerialize(
  InventoryCommandEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actorLegacyAppUserId);
  writer.writeString(offsets[1], object.actorUid);
  writer.writeBool(offsets[2], object.appliedLocally);
  writer.writeBool(offsets[3], object.appliedRemotely);
  writer.writeString(offsets[4], object.commandId);
  writer.writeString(offsets[5], object.commandType);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeDateTime(offsets[7], object.deletedAt);
  writer.writeString(offsets[8], object.id);
  writer.writeBool(offsets[9], object.isDeleted);
  writer.writeString(offsets[10], object.payload);
  writer.writeString(offsets[11], object.retryMeta);
  writer.writeByte(offsets[12], object.syncStatus.index);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

InventoryCommandEntity _inventoryCommandEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryCommandEntity();
  object.actorLegacyAppUserId = reader.readStringOrNull(offsets[0]);
  object.actorUid = reader.readString(offsets[1]);
  object.appliedLocally = reader.readBool(offsets[2]);
  object.appliedRemotely = reader.readBool(offsets[3]);
  object.commandId = reader.readString(offsets[4]);
  object.commandType = reader.readString(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[7]);
  object.id = reader.readString(offsets[8]);
  object.isDeleted = reader.readBool(offsets[9]);
  object.payload = reader.readString(offsets[10]);
  object.retryMeta = reader.readStringOrNull(offsets[11]);
  object.syncStatus = _InventoryCommandEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[12])] ??
      SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _inventoryCommandEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (_InventoryCommandEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _InventoryCommandEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _InventoryCommandEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _inventoryCommandEntityGetId(InventoryCommandEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _inventoryCommandEntityGetLinks(
    InventoryCommandEntity object) {
  return [];
}

void _inventoryCommandEntityAttach(
    IsarCollection<dynamic> col, Id id, InventoryCommandEntity object) {}

extension InventoryCommandEntityByIndex
    on IsarCollection<InventoryCommandEntity> {
  Future<InventoryCommandEntity?> getByCommandId(String commandId) {
    return getByIndex(r'commandId', [commandId]);
  }

  InventoryCommandEntity? getByCommandIdSync(String commandId) {
    return getByIndexSync(r'commandId', [commandId]);
  }

  Future<bool> deleteByCommandId(String commandId) {
    return deleteByIndex(r'commandId', [commandId]);
  }

  bool deleteByCommandIdSync(String commandId) {
    return deleteByIndexSync(r'commandId', [commandId]);
  }

  Future<List<InventoryCommandEntity?>> getAllByCommandId(
      List<String> commandIdValues) {
    final values = commandIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'commandId', values);
  }

  List<InventoryCommandEntity?> getAllByCommandIdSync(
      List<String> commandIdValues) {
    final values = commandIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'commandId', values);
  }

  Future<int> deleteAllByCommandId(List<String> commandIdValues) {
    final values = commandIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'commandId', values);
  }

  int deleteAllByCommandIdSync(List<String> commandIdValues) {
    final values = commandIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'commandId', values);
  }

  Future<Id> putByCommandId(InventoryCommandEntity object) {
    return putByIndex(r'commandId', object);
  }

  Id putByCommandIdSync(InventoryCommandEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'commandId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCommandId(List<InventoryCommandEntity> objects) {
    return putAllByIndex(r'commandId', objects);
  }

  List<Id> putAllByCommandIdSync(List<InventoryCommandEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'commandId', objects, saveLinks: saveLinks);
  }

  Future<InventoryCommandEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  InventoryCommandEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<InventoryCommandEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<InventoryCommandEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(InventoryCommandEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(InventoryCommandEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<InventoryCommandEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<InventoryCommandEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension InventoryCommandEntityQueryWhereSort
    on QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QWhere> {
  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventoryCommandEntityQueryWhere on QueryBuilder<
    InventoryCommandEntity, InventoryCommandEntity, QWhereClause> {
  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> commandTypeEqualTo(String commandType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'commandType',
        value: [commandType],
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> commandTypeNotEqualTo(String commandType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandType',
              lower: [],
              upper: [commandType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandType',
              lower: [commandType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandType',
              lower: [commandType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandType',
              lower: [],
              upper: [commandType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> actorUidEqualTo(String actorUid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'actorUid',
        value: [actorUid],
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> actorUidNotEqualTo(String actorUid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorUid',
              lower: [],
              upper: [actorUid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorUid',
              lower: [actorUid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorUid',
              lower: [actorUid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorUid',
              lower: [],
              upper: [actorUid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> commandIdEqualTo(String commandId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'commandId',
        value: [commandId],
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> commandIdNotEqualTo(String commandId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandId',
              lower: [],
              upper: [commandId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandId',
              lower: [commandId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandId',
              lower: [commandId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'commandId',
              lower: [],
              upper: [commandId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterWhereClause> idNotEqualTo(String id) {
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

extension InventoryCommandEntityQueryFilter on QueryBuilder<
    InventoryCommandEntity, InventoryCommandEntity, QFilterCondition> {
  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actorLegacyAppUserId',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actorLegacyAppUserId',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorLegacyAppUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actorLegacyAppUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actorLegacyAppUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actorLegacyAppUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actorLegacyAppUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actorLegacyAppUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      actorLegacyAppUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actorLegacyAppUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      actorLegacyAppUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actorLegacyAppUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorLegacyAppUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorLegacyAppUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actorLegacyAppUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actorUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actorUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actorUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actorUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actorUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      actorUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actorUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      actorUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actorUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorUid',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> actorUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actorUid',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> appliedLocallyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appliedLocally',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> appliedRemotelyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appliedRemotely',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commandId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commandId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commandId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commandId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'commandId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'commandId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      commandIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'commandId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      commandIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'commandId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commandId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'commandId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commandType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commandType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commandType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commandType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'commandType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'commandType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      commandTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'commandType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      commandTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'commandType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commandType',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> commandTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'commandType',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> deletedAtGreaterThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> deletedAtLessThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> deletedAtBetween(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      payloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      payloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'retryMeta',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'retryMeta',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryMeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryMeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryMeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryMeta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'retryMeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'retryMeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      retryMetaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'retryMeta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
          QAfterFilterCondition>
      retryMetaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'retryMeta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryMeta',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> retryMetaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'retryMeta',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> syncStatusGreaterThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> syncStatusLessThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> syncStatusBetween(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity,
      QAfterFilterCondition> updatedAtBetween(
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
}

extension InventoryCommandEntityQueryObject on QueryBuilder<
    InventoryCommandEntity, InventoryCommandEntity, QFilterCondition> {}

extension InventoryCommandEntityQueryLinks on QueryBuilder<
    InventoryCommandEntity, InventoryCommandEntity, QFilterCondition> {}

extension InventoryCommandEntityQuerySortBy
    on QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QSortBy> {
  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByActorLegacyAppUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorLegacyAppUserId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByActorLegacyAppUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorLegacyAppUserId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByActorUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUid', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByActorUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUid', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByAppliedLocally() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedLocally', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByAppliedLocallyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedLocally', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByAppliedRemotely() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedRemotely', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByAppliedRemotelyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedRemotely', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByCommandId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByCommandIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByCommandType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandType', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByCommandTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandType', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByRetryMeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryMeta', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByRetryMetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryMeta', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InventoryCommandEntityQuerySortThenBy on QueryBuilder<
    InventoryCommandEntity, InventoryCommandEntity, QSortThenBy> {
  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByActorLegacyAppUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorLegacyAppUserId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByActorLegacyAppUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorLegacyAppUserId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByActorUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUid', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByActorUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorUid', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByAppliedLocally() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedLocally', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByAppliedLocallyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedLocally', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByAppliedRemotely() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedRemotely', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByAppliedRemotelyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedRemotely', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByCommandId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByCommandIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByCommandType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandType', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByCommandTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commandType', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByRetryMeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryMeta', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByRetryMetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryMeta', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InventoryCommandEntityQueryWhereDistinct
    on QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct> {
  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByActorLegacyAppUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorLegacyAppUserId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByActorUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByAppliedLocally() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appliedLocally');
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByAppliedRemotely() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appliedRemotely');
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByCommandId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commandId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByCommandType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commandType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByRetryMeta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryMeta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<InventoryCommandEntity, InventoryCommandEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension InventoryCommandEntityQueryProperty on QueryBuilder<
    InventoryCommandEntity, InventoryCommandEntity, QQueryProperty> {
  QueryBuilder<InventoryCommandEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<InventoryCommandEntity, String?, QQueryOperations>
      actorLegacyAppUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorLegacyAppUserId');
    });
  }

  QueryBuilder<InventoryCommandEntity, String, QQueryOperations>
      actorUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorUid');
    });
  }

  QueryBuilder<InventoryCommandEntity, bool, QQueryOperations>
      appliedLocallyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appliedLocally');
    });
  }

  QueryBuilder<InventoryCommandEntity, bool, QQueryOperations>
      appliedRemotelyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appliedRemotely');
    });
  }

  QueryBuilder<InventoryCommandEntity, String, QQueryOperations>
      commandIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commandId');
    });
  }

  QueryBuilder<InventoryCommandEntity, String, QQueryOperations>
      commandTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commandType');
    });
  }

  QueryBuilder<InventoryCommandEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InventoryCommandEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<InventoryCommandEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventoryCommandEntity, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<InventoryCommandEntity, String, QQueryOperations>
      payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<InventoryCommandEntity, String?, QQueryOperations>
      retryMetaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryMeta');
    });
  }

  QueryBuilder<InventoryCommandEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<InventoryCommandEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
