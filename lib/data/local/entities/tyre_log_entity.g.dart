// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tyre_log_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTyreLogEntityCollection on Isar {
  IsarCollection<TyreLogEntity> get tyreLogEntitys => this.collection();
}

const TyreLogEntitySchema = CollectionSchema(
  name: r'TyreLogEntity',
  id: 5991833827647983192,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'installationDate': PropertySchema(
      id: 3,
      name: r'installationDate',
      type: IsarType.dateTime,
    ),
    r'isDeleted': PropertySchema(
      id: 4,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'items': PropertySchema(
      id: 5,
      name: r'items',
      type: IsarType.objectList,
      target: r'TyreLogItemEntity',
    ),
    r'reason': PropertySchema(
      id: 6,
      name: r'reason',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 7,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _TyreLogEntitysyncStatusEnumValueMap,
    ),
    r'totalCost': PropertySchema(
      id: 8,
      name: r'totalCost',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vehicleId': PropertySchema(
      id: 10,
      name: r'vehicleId',
      type: IsarType.string,
    ),
    r'vehicleNumber': PropertySchema(
      id: 11,
      name: r'vehicleNumber',
      type: IsarType.string,
    )
  },
  estimateSize: _tyreLogEntityEstimateSize,
  serialize: _tyreLogEntitySerialize,
  deserialize: _tyreLogEntityDeserialize,
  deserializeProp: _tyreLogEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'vehicleId': IndexSchema(
      id: 2011968157433523416,
      name: r'vehicleId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'vehicleId',
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
  embeddedSchemas: {r'TyreLogItemEntity': TyreLogItemEntitySchema},
  getId: _tyreLogEntityGetId,
  getLinks: _tyreLogEntityGetLinks,
  attach: _tyreLogEntityAttach,
  version: '3.1.0+1',
);

int _tyreLogEntityEstimateSize(
  TyreLogEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.createdAt.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final list = object.items;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[TyreLogItemEntity]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              TyreLogItemEntitySchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.vehicleId.length * 3;
  bytesCount += 3 + object.vehicleNumber.length * 3;
  return bytesCount;
}

void _tyreLogEntitySerialize(
  TyreLogEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeString(offsets[2], object.id);
  writer.writeDateTime(offsets[3], object.installationDate);
  writer.writeBool(offsets[4], object.isDeleted);
  writer.writeObjectList<TyreLogItemEntity>(
    offsets[5],
    allOffsets,
    TyreLogItemEntitySchema.serialize,
    object.items,
  );
  writer.writeString(offsets[6], object.reason);
  writer.writeByte(offsets[7], object.syncStatus.index);
  writer.writeDouble(offsets[8], object.totalCost);
  writer.writeDateTime(offsets[9], object.updatedAt);
  writer.writeString(offsets[10], object.vehicleId);
  writer.writeString(offsets[11], object.vehicleNumber);
}

TyreLogEntity _tyreLogEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TyreLogEntity();
  object.createdAt = reader.readString(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = reader.readString(offsets[2]);
  object.installationDate = reader.readDateTime(offsets[3]);
  object.isDeleted = reader.readBool(offsets[4]);
  object.items = reader.readObjectList<TyreLogItemEntity>(
    offsets[5],
    TyreLogItemEntitySchema.deserialize,
    allOffsets,
    TyreLogItemEntity(),
  );
  object.reason = reader.readString(offsets[6]);
  object.syncStatus =
      _TyreLogEntitysyncStatusValueEnumMap[reader.readByteOrNull(offsets[7])] ??
          SyncStatus.pending;
  object.totalCost = reader.readDouble(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  object.vehicleId = reader.readString(offsets[10]);
  object.vehicleNumber = reader.readString(offsets[11]);
  return object;
}

P _tyreLogEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readObjectList<TyreLogItemEntity>(
        offset,
        TyreLogItemEntitySchema.deserialize,
        allOffsets,
        TyreLogItemEntity(),
      )) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_TyreLogEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TyreLogEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _TyreLogEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _tyreLogEntityGetId(TyreLogEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _tyreLogEntityGetLinks(TyreLogEntity object) {
  return [];
}

void _tyreLogEntityAttach(
    IsarCollection<dynamic> col, Id id, TyreLogEntity object) {}

extension TyreLogEntityByIndex on IsarCollection<TyreLogEntity> {
  Future<TyreLogEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  TyreLogEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<TyreLogEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<TyreLogEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(TyreLogEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(TyreLogEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<TyreLogEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<TyreLogEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension TyreLogEntityQueryWhereSort
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QWhere> {
  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TyreLogEntityQueryWhere
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QWhereClause> {
  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause>
      vehicleIdEqualTo(String vehicleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vehicleId',
        value: [vehicleId],
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause>
      vehicleIdNotEqualTo(String vehicleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [],
              upper: [vehicleId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [vehicleId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [vehicleId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [],
              upper: [vehicleId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterWhereClause> idNotEqualTo(
      String id) {
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

extension TyreLogEntityQueryFilter
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QFilterCondition> {
  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      createdAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      installationDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      installationDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      installationDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      installationDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      totalCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      totalCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      totalCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      totalCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
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

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vehicleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vehicleNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      vehicleNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }
}

extension TyreLogEntityQueryObject
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QFilterCondition> {
  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterFilterCondition>
      itemsElement(FilterQuery<TyreLogItemEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension TyreLogEntityQueryLinks
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QFilterCondition> {}

extension TyreLogEntityQuerySortBy
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QSortBy> {
  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByInstallationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installationDate', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByInstallationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installationDate', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      sortByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }
}

extension TyreLogEntityQuerySortThenBy
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QSortThenBy> {
  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByInstallationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installationDate', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByInstallationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installationDate', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy> thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QAfterSortBy>
      thenByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }
}

extension TyreLogEntityQueryWhereDistinct
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> {
  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByCreatedAt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct>
      distinctByInstallationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installationDate');
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCost');
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByVehicleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TyreLogEntity, TyreLogEntity, QDistinct> distinctByVehicleNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleNumber',
          caseSensitive: caseSensitive);
    });
  }
}

extension TyreLogEntityQueryProperty
    on QueryBuilder<TyreLogEntity, TyreLogEntity, QQueryProperty> {
  QueryBuilder<TyreLogEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<TyreLogEntity, String, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TyreLogEntity, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<TyreLogEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TyreLogEntity, DateTime, QQueryOperations>
      installationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installationDate');
    });
  }

  QueryBuilder<TyreLogEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<TyreLogEntity, List<TyreLogItemEntity>?, QQueryOperations>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<TyreLogEntity, String, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<TyreLogEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<TyreLogEntity, double, QQueryOperations> totalCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCost');
    });
  }

  QueryBuilder<TyreLogEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TyreLogEntity, String, QQueryOperations> vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }

  QueryBuilder<TyreLogEntity, String, QQueryOperations>
      vehicleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleNumber');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TyreLogItemEntitySchema = Schema(
  name: r'TyreLogItemEntity',
  id: 789434871415295502,
  properties: {
    r'cost': PropertySchema(
      id: 0,
      name: r'cost',
      type: IsarType.double,
    ),
    r'newTyreType': PropertySchema(
      id: 1,
      name: r'newTyreType',
      type: IsarType.string,
    ),
    r'oldTyreBrand': PropertySchema(
      id: 2,
      name: r'oldTyreBrand',
      type: IsarType.string,
    ),
    r'oldTyreDisposition': PropertySchema(
      id: 3,
      name: r'oldTyreDisposition',
      type: IsarType.string,
    ),
    r'oldTyreNumber': PropertySchema(
      id: 4,
      name: r'oldTyreNumber',
      type: IsarType.string,
    ),
    r'tyreBrand': PropertySchema(
      id: 5,
      name: r'tyreBrand',
      type: IsarType.string,
    ),
    r'tyreItemId': PropertySchema(
      id: 6,
      name: r'tyreItemId',
      type: IsarType.string,
    ),
    r'tyreModel': PropertySchema(
      id: 7,
      name: r'tyreModel',
      type: IsarType.string,
    ),
    r'tyreNumber': PropertySchema(
      id: 8,
      name: r'tyreNumber',
      type: IsarType.string,
    ),
    r'tyrePosition': PropertySchema(
      id: 9,
      name: r'tyrePosition',
      type: IsarType.string,
    )
  },
  estimateSize: _tyreLogItemEntityEstimateSize,
  serialize: _tyreLogItemEntitySerialize,
  deserialize: _tyreLogItemEntityDeserialize,
  deserializeProp: _tyreLogItemEntityDeserializeProp,
);

int _tyreLogItemEntityEstimateSize(
  TyreLogItemEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.newTyreType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.oldTyreBrand;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.oldTyreDisposition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.oldTyreNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tyreBrand;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tyreItemId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tyreModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tyreNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tyrePosition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _tyreLogItemEntitySerialize(
  TyreLogItemEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cost);
  writer.writeString(offsets[1], object.newTyreType);
  writer.writeString(offsets[2], object.oldTyreBrand);
  writer.writeString(offsets[3], object.oldTyreDisposition);
  writer.writeString(offsets[4], object.oldTyreNumber);
  writer.writeString(offsets[5], object.tyreBrand);
  writer.writeString(offsets[6], object.tyreItemId);
  writer.writeString(offsets[7], object.tyreModel);
  writer.writeString(offsets[8], object.tyreNumber);
  writer.writeString(offsets[9], object.tyrePosition);
}

TyreLogItemEntity _tyreLogItemEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TyreLogItemEntity();
  object.cost = reader.readDouble(offsets[0]);
  object.newTyreType = reader.readStringOrNull(offsets[1]);
  object.oldTyreBrand = reader.readStringOrNull(offsets[2]);
  object.oldTyreDisposition = reader.readStringOrNull(offsets[3]);
  object.oldTyreNumber = reader.readStringOrNull(offsets[4]);
  object.tyreBrand = reader.readStringOrNull(offsets[5]);
  object.tyreItemId = reader.readStringOrNull(offsets[6]);
  object.tyreModel = reader.readStringOrNull(offsets[7]);
  object.tyreNumber = reader.readStringOrNull(offsets[8]);
  object.tyrePosition = reader.readStringOrNull(offsets[9]);
  return object;
}

P _tyreLogItemEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TyreLogItemEntityQueryFilter
    on QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QFilterCondition> {
  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      costEqualTo(
    double value, {
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

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      costGreaterThan(
    double value, {
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

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      costLessThan(
    double value, {
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

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      costBetween(
    double lower,
    double upper, {
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

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'newTyreType',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'newTyreType',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newTyreType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newTyreType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newTyreType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newTyreType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'newTyreType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'newTyreType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newTyreType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newTyreType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newTyreType',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      newTyreTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newTyreType',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'oldTyreBrand',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'oldTyreBrand',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldTyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oldTyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oldTyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oldTyreBrand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'oldTyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'oldTyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'oldTyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'oldTyreBrand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldTyreBrand',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreBrandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'oldTyreBrand',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'oldTyreDisposition',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'oldTyreDisposition',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldTyreDisposition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oldTyreDisposition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oldTyreDisposition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oldTyreDisposition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'oldTyreDisposition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'oldTyreDisposition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'oldTyreDisposition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'oldTyreDisposition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldTyreDisposition',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreDispositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'oldTyreDisposition',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'oldTyreNumber',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'oldTyreNumber',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldTyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oldTyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oldTyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oldTyreNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'oldTyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'oldTyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'oldTyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'oldTyreNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldTyreNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      oldTyreNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'oldTyreNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tyreBrand',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tyreBrand',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tyreBrand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tyreBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tyreBrand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreBrand',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreBrandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tyreBrand',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tyreItemId',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tyreItemId',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tyreItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tyreItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tyreItemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tyreItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tyreItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tyreItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tyreItemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tyreItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tyreModel',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tyreModel',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tyreModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tyreModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tyreModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tyreModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tyreModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tyreModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tyreModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreModel',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tyreModel',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tyreNumber',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tyreNumber',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tyreNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tyreNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tyreNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyreNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tyreNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tyrePosition',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tyrePosition',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyrePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tyrePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tyrePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tyrePosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tyrePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tyrePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tyrePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tyrePosition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyrePosition',
        value: '',
      ));
    });
  }

  QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QAfterFilterCondition>
      tyrePositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tyrePosition',
        value: '',
      ));
    });
  }
}

extension TyreLogItemEntityQueryObject
    on QueryBuilder<TyreLogItemEntity, TyreLogItemEntity, QFilterCondition> {}
