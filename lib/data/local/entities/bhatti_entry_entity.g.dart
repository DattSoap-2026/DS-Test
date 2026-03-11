// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bhatti_entry_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBhattiDailyEntryEntityCollection on Isar {
  IsarCollection<BhattiDailyEntryEntity> get bhattiDailyEntryEntitys =>
      this.collection();
}

const BhattiDailyEntryEntitySchema = CollectionSchema(
  name: r'BhattiDailyEntryEntity',
  id: -4118684437309091737,
  properties: {
    r'batchCount': PropertySchema(
      id: 0,
      name: r'batchCount',
      type: IsarType.long,
    ),
    r'bhattiId': PropertySchema(
      id: 1,
      name: r'bhattiId',
      type: IsarType.string,
    ),
    r'bhattiName': PropertySchema(
      id: 2,
      name: r'bhattiName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdBy': PropertySchema(
      id: 4,
      name: r'createdBy',
      type: IsarType.string,
    ),
    r'createdByName': PropertySchema(
      id: 5,
      name: r'createdByName',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 6,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 7,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'fuelConsumption': PropertySchema(
      id: 8,
      name: r'fuelConsumption',
      type: IsarType.double,
    ),
    r'id': PropertySchema(
      id: 9,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 10,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 11,
      name: r'notes',
      type: IsarType.string,
    ),
    r'outputBoxes': PropertySchema(
      id: 12,
      name: r'outputBoxes',
      type: IsarType.long,
    ),
    r'syncStatus': PropertySchema(
      id: 13,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _BhattiDailyEntryEntitysyncStatusEnumValueMap,
    ),
    r'teamCode': PropertySchema(
      id: 14,
      name: r'teamCode',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _bhattiDailyEntryEntityEstimateSize,
  serialize: _bhattiDailyEntryEntitySerialize,
  deserialize: _bhattiDailyEntryEntityDeserialize,
  deserializeProp: _bhattiDailyEntryEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
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
  getId: _bhattiDailyEntryEntityGetId,
  getLinks: _bhattiDailyEntryEntityGetLinks,
  attach: _bhattiDailyEntryEntityAttach,
  version: '3.1.0+1',
);

int _bhattiDailyEntryEntityEstimateSize(
  BhattiDailyEntryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bhattiId.length * 3;
  bytesCount += 3 + object.bhattiName.length * 3;
  bytesCount += 3 + object.createdBy.length * 3;
  bytesCount += 3 + object.createdByName.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.teamCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _bhattiDailyEntryEntitySerialize(
  BhattiDailyEntryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.batchCount);
  writer.writeString(offsets[1], object.bhattiId);
  writer.writeString(offsets[2], object.bhattiName);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.createdBy);
  writer.writeString(offsets[5], object.createdByName);
  writer.writeDateTime(offsets[6], object.date);
  writer.writeDateTime(offsets[7], object.deletedAt);
  writer.writeDouble(offsets[8], object.fuelConsumption);
  writer.writeString(offsets[9], object.id);
  writer.writeBool(offsets[10], object.isDeleted);
  writer.writeString(offsets[11], object.notes);
  writer.writeLong(offsets[12], object.outputBoxes);
  writer.writeByte(offsets[13], object.syncStatus.index);
  writer.writeString(offsets[14], object.teamCode);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

BhattiDailyEntryEntity _bhattiDailyEntryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BhattiDailyEntryEntity();
  object.batchCount = reader.readLong(offsets[0]);
  object.bhattiId = reader.readString(offsets[1]);
  object.bhattiName = reader.readString(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.createdBy = reader.readString(offsets[4]);
  object.createdByName = reader.readString(offsets[5]);
  object.date = reader.readDateTime(offsets[6]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[7]);
  object.fuelConsumption = reader.readDouble(offsets[8]);
  object.id = reader.readString(offsets[9]);
  object.isDeleted = reader.readBool(offsets[10]);
  object.notes = reader.readStringOrNull(offsets[11]);
  object.outputBoxes = reader.readLong(offsets[12]);
  object.syncStatus = _BhattiDailyEntryEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[13])] ??
      SyncStatus.pending;
  object.teamCode = reader.readStringOrNull(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _bhattiDailyEntryEntityDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (_BhattiDailyEntryEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BhattiDailyEntryEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _BhattiDailyEntryEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _bhattiDailyEntryEntityGetId(BhattiDailyEntryEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _bhattiDailyEntryEntityGetLinks(
    BhattiDailyEntryEntity object) {
  return [];
}

void _bhattiDailyEntryEntityAttach(
    IsarCollection<dynamic> col, Id id, BhattiDailyEntryEntity object) {}

extension BhattiDailyEntryEntityByIndex
    on IsarCollection<BhattiDailyEntryEntity> {
  Future<BhattiDailyEntryEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  BhattiDailyEntryEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<BhattiDailyEntryEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<BhattiDailyEntryEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(BhattiDailyEntryEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(BhattiDailyEntryEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<BhattiDailyEntryEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<BhattiDailyEntryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension BhattiDailyEntryEntityQueryWhereSort
    on QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QWhere> {
  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterWhere>
      anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension BhattiDailyEntryEntityQueryWhere on QueryBuilder<
    BhattiDailyEntryEntity, BhattiDailyEntryEntity, QWhereClause> {
  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

extension BhattiDailyEntryEntityQueryFilter on QueryBuilder<
    BhattiDailyEntryEntity, BhattiDailyEntryEntity, QFilterCondition> {
  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> batchCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> batchCountGreaterThan(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> batchCountLessThan(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> batchCountBetween(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bhattiId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bhattiId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bhattiId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bhattiId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bhattiId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bhattiId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      bhattiIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bhattiId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      bhattiIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bhattiId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bhattiId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bhattiId',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameEqualTo(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameGreaterThan(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameLessThan(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameBetween(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameStartsWith(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameEndsWith(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      bhattiNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bhattiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      bhattiNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bhattiName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bhattiName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> bhattiNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bhattiName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      createdByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      createdByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      createdByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      createdByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> createdByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdByName',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> fuelConsumptionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fuelConsumption',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> fuelConsumptionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fuelConsumption',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> fuelConsumptionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fuelConsumption',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> fuelConsumptionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fuelConsumption',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> outputBoxesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputBoxes',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> outputBoxesGreaterThan(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> outputBoxesLessThan(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> outputBoxesBetween(
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'teamCode',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'teamCode',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teamCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'teamCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'teamCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'teamCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'teamCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'teamCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      teamCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'teamCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
          QAfterFilterCondition>
      teamCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'teamCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teamCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> teamCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'teamCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity,
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

extension BhattiDailyEntryEntityQueryObject on QueryBuilder<
    BhattiDailyEntryEntity, BhattiDailyEntryEntity, QFilterCondition> {}

extension BhattiDailyEntryEntityQueryLinks on QueryBuilder<
    BhattiDailyEntryEntity, BhattiDailyEntryEntity, QFilterCondition> {}

extension BhattiDailyEntryEntityQuerySortBy
    on QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QSortBy> {
  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByBatchCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByBatchCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByBhattiId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiId', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByBhattiIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiId', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByBhattiName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByBhattiNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByFuelConsumption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelConsumption', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByFuelConsumptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelConsumption', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByOutputBoxes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByOutputBoxesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByTeamCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamCode', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByTeamCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamCode', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BhattiDailyEntryEntityQuerySortThenBy on QueryBuilder<
    BhattiDailyEntryEntity, BhattiDailyEntryEntity, QSortThenBy> {
  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByBatchCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByBatchCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchCount', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByBhattiId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiId', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByBhattiIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiId', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByBhattiName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByBhattiNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bhattiName', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByFuelConsumption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelConsumption', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByFuelConsumptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelConsumption', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByOutputBoxes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByOutputBoxesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputBoxes', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByTeamCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamCode', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByTeamCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamCode', Sort.desc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BhattiDailyEntryEntityQueryWhereDistinct
    on QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct> {
  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByBatchCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchCount');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByBhattiId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bhattiId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByBhattiName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bhattiName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByCreatedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByCreatedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByFuelConsumption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fuelConsumption');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByOutputBoxes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputBoxes');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByTeamCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, BhattiDailyEntryEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension BhattiDailyEntryEntityQueryProperty on QueryBuilder<
    BhattiDailyEntryEntity, BhattiDailyEntryEntity, QQueryProperty> {
  QueryBuilder<BhattiDailyEntryEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, int, QQueryOperations>
      batchCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchCount');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, String, QQueryOperations>
      bhattiIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bhattiId');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, String, QQueryOperations>
      bhattiNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bhattiName');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, String, QQueryOperations>
      createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, String, QQueryOperations>
      createdByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByName');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, double, QQueryOperations>
      fuelConsumptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fuelConsumption');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, int, QQueryOperations>
      outputBoxesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputBoxes');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, String?, QQueryOperations>
      teamCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamCode');
    });
  }

  QueryBuilder<BhattiDailyEntryEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
