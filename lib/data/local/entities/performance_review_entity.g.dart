// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_review_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPerformanceReviewEntityCollection on Isar {
  IsarCollection<PerformanceReviewEntity> get performanceReviewEntitys =>
      this.collection();
}

const PerformanceReviewEntitySchema = CollectionSchema(
  name: r'PerformanceReviewEntity',
  id: -272259243012318555,
  properties: {
    r'attendanceScore': PropertySchema(
      id: 0,
      name: r'attendanceScore',
      type: IsarType.long,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 2,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'employeeComments': PropertySchema(
      id: 3,
      name: r'employeeComments',
      type: IsarType.string,
    ),
    r'employeeId': PropertySchema(
      id: 4,
      name: r'employeeId',
      type: IsarType.string,
    ),
    r'goals': PropertySchema(
      id: 5,
      name: r'goals',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 6,
      name: r'id',
      type: IsarType.string,
    ),
    r'improvements': PropertySchema(
      id: 7,
      name: r'improvements',
      type: IsarType.string,
    ),
    r'initiativeScore': PropertySchema(
      id: 8,
      name: r'initiativeScore',
      type: IsarType.long,
    ),
    r'isDeleted': PropertySchema(
      id: 9,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 10,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastSynced': PropertySchema(
      id: 11,
      name: r'lastSynced',
      type: IsarType.dateTime,
    ),
    r'managerComments': PropertySchema(
      id: 12,
      name: r'managerComments',
      type: IsarType.string,
    ),
    r'overallRating': PropertySchema(
      id: 13,
      name: r'overallRating',
      type: IsarType.double,
    ),
    r'productivityScore': PropertySchema(
      id: 14,
      name: r'productivityScore',
      type: IsarType.long,
    ),
    r'qualityScore': PropertySchema(
      id: 15,
      name: r'qualityScore',
      type: IsarType.long,
    ),
    r'reviewDate': PropertySchema(
      id: 16,
      name: r'reviewDate',
      type: IsarType.string,
    ),
    r'reviewPeriod': PropertySchema(
      id: 17,
      name: r'reviewPeriod',
      type: IsarType.string,
    ),
    r'reviewerId': PropertySchema(
      id: 18,
      name: r'reviewerId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 19,
      name: r'status',
      type: IsarType.string,
    ),
    r'strengths': PropertySchema(
      id: 20,
      name: r'strengths',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 21,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _PerformanceReviewEntitysyncStatusEnumValueMap,
    ),
    r'teamworkScore': PropertySchema(
      id: 22,
      name: r'teamworkScore',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 23,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 24,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _performanceReviewEntityEstimateSize,
  serialize: _performanceReviewEntitySerialize,
  deserialize: _performanceReviewEntityDeserialize,
  deserializeProp: _performanceReviewEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'employeeId': IndexSchema(
      id: 1283453093523034672,
      name: r'employeeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'employeeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'reviewerId': IndexSchema(
      id: -5615909340623123218,
      name: r'reviewerId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reviewerId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'reviewPeriod': IndexSchema(
      id: -7949118950112834996,
      name: r'reviewPeriod',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reviewPeriod',
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
  embeddedSchemas: {},
  getId: _performanceReviewEntityGetId,
  getLinks: _performanceReviewEntityGetLinks,
  attach: _performanceReviewEntityAttach,
  version: '3.1.0+1',
);

int _performanceReviewEntityEstimateSize(
  PerformanceReviewEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.employeeComments;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.employeeId.length * 3;
  {
    final value = object.goals;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.improvements;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.managerComments;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reviewDate.length * 3;
  bytesCount += 3 + object.reviewPeriod.length * 3;
  bytesCount += 3 + object.reviewerId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.strengths;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _performanceReviewEntitySerialize(
  PerformanceReviewEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attendanceScore);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeString(offsets[2], object.deviceId);
  writer.writeString(offsets[3], object.employeeComments);
  writer.writeString(offsets[4], object.employeeId);
  writer.writeString(offsets[5], object.goals);
  writer.writeString(offsets[6], object.id);
  writer.writeString(offsets[7], object.improvements);
  writer.writeLong(offsets[8], object.initiativeScore);
  writer.writeBool(offsets[9], object.isDeleted);
  writer.writeBool(offsets[10], object.isSynced);
  writer.writeDateTime(offsets[11], object.lastSynced);
  writer.writeString(offsets[12], object.managerComments);
  writer.writeDouble(offsets[13], object.overallRating);
  writer.writeLong(offsets[14], object.productivityScore);
  writer.writeLong(offsets[15], object.qualityScore);
  writer.writeString(offsets[16], object.reviewDate);
  writer.writeString(offsets[17], object.reviewPeriod);
  writer.writeString(offsets[18], object.reviewerId);
  writer.writeString(offsets[19], object.status);
  writer.writeString(offsets[20], object.strengths);
  writer.writeByte(offsets[21], object.syncStatus.index);
  writer.writeLong(offsets[22], object.teamworkScore);
  writer.writeDateTime(offsets[23], object.updatedAt);
  writer.writeLong(offsets[24], object.version);
}

PerformanceReviewEntity _performanceReviewEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PerformanceReviewEntity();
  object.attendanceScore = reader.readLongOrNull(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.deviceId = reader.readString(offsets[2]);
  object.employeeComments = reader.readStringOrNull(offsets[3]);
  object.employeeId = reader.readString(offsets[4]);
  object.goals = reader.readStringOrNull(offsets[5]);
  object.id = reader.readString(offsets[6]);
  object.improvements = reader.readStringOrNull(offsets[7]);
  object.initiativeScore = reader.readLongOrNull(offsets[8]);
  object.isDeleted = reader.readBool(offsets[9]);
  object.isSynced = reader.readBool(offsets[10]);
  object.lastSynced = reader.readDateTimeOrNull(offsets[11]);
  object.managerComments = reader.readStringOrNull(offsets[12]);
  object.overallRating = reader.readDoubleOrNull(offsets[13]);
  object.productivityScore = reader.readLongOrNull(offsets[14]);
  object.qualityScore = reader.readLongOrNull(offsets[15]);
  object.reviewDate = reader.readString(offsets[16]);
  object.reviewPeriod = reader.readString(offsets[17]);
  object.reviewerId = reader.readString(offsets[18]);
  object.status = reader.readString(offsets[19]);
  object.strengths = reader.readStringOrNull(offsets[20]);
  object.syncStatus = _PerformanceReviewEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[21])] ??
      SyncStatus.pending;
  object.teamworkScore = reader.readLongOrNull(offsets[22]);
  object.updatedAt = reader.readDateTime(offsets[23]);
  object.version = reader.readLong(offsets[24]);
  return object;
}

P _performanceReviewEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (_PerformanceReviewEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readDateTime(offset)) as P;
    case 24:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PerformanceReviewEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _PerformanceReviewEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _performanceReviewEntityGetId(PerformanceReviewEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _performanceReviewEntityGetLinks(
    PerformanceReviewEntity object) {
  return [];
}

void _performanceReviewEntityAttach(
    IsarCollection<dynamic> col, Id id, PerformanceReviewEntity object) {}

extension PerformanceReviewEntityByIndex
    on IsarCollection<PerformanceReviewEntity> {
  Future<PerformanceReviewEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  PerformanceReviewEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<PerformanceReviewEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<PerformanceReviewEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(PerformanceReviewEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(PerformanceReviewEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<PerformanceReviewEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<PerformanceReviewEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension PerformanceReviewEntityQueryWhereSort
    on QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QWhere> {
  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PerformanceReviewEntityQueryWhere on QueryBuilder<
    PerformanceReviewEntity, PerformanceReviewEntity, QWhereClause> {
  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> employeeIdEqualTo(String employeeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'employeeId',
        value: [employeeId],
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> employeeIdNotEqualTo(String employeeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [],
              upper: [employeeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [employeeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [employeeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [],
              upper: [employeeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> reviewerIdEqualTo(String reviewerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reviewerId',
        value: [reviewerId],
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> reviewerIdNotEqualTo(String reviewerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewerId',
              lower: [],
              upper: [reviewerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewerId',
              lower: [reviewerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewerId',
              lower: [reviewerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewerId',
              lower: [],
              upper: [reviewerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> reviewPeriodEqualTo(String reviewPeriod) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reviewPeriod',
        value: [reviewPeriod],
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> reviewPeriodNotEqualTo(String reviewPeriod) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewPeriod',
              lower: [],
              upper: [reviewPeriod],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewPeriod',
              lower: [reviewPeriod],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewPeriod',
              lower: [reviewPeriod],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reviewPeriod',
              lower: [],
              upper: [reviewPeriod],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> statusNotEqualTo(String status) {
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

extension PerformanceReviewEntityQueryFilter on QueryBuilder<
    PerformanceReviewEntity, PerformanceReviewEntity, QFilterCondition> {
  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> attendanceScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'attendanceScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> attendanceScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'attendanceScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> attendanceScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attendanceScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> attendanceScoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attendanceScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> attendanceScoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attendanceScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> attendanceScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attendanceScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdEqualTo(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdGreaterThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdLessThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdBetween(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdStartsWith(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdEndsWith(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'employeeComments',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'employeeComments',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'employeeComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'employeeComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'employeeComments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'employeeComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'employeeComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      employeeCommentsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      employeeCommentsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeComments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeComments',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeCommentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeComments',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'employeeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      employeeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      employeeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> employeeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goals',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goals',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goals',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      goalsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      goalsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goals',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goals',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> goalsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goals',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'improvements',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'improvements',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'improvements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'improvements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'improvements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'improvements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'improvements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'improvements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      improvementsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'improvements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      improvementsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'improvements',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'improvements',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> improvementsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'improvements',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> initiativeScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'initiativeScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> initiativeScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'initiativeScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> initiativeScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiativeScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> initiativeScoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initiativeScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> initiativeScoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initiativeScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> initiativeScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initiativeScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> lastSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> lastSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> lastSyncedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> lastSyncedGreaterThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> lastSyncedLessThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> lastSyncedBetween(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'managerComments',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'managerComments',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'managerComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'managerComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'managerComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'managerComments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'managerComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'managerComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      managerCommentsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'managerComments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      managerCommentsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'managerComments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'managerComments',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> managerCommentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'managerComments',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> overallRatingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'overallRating',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> overallRatingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'overallRating',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> overallRatingEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overallRating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> overallRatingGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overallRating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> overallRatingLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overallRating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> overallRatingBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overallRating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> productivityScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productivityScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> productivityScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productivityScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> productivityScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productivityScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> productivityScoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productivityScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> productivityScoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productivityScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> productivityScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productivityScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> qualityScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'qualityScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> qualityScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'qualityScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> qualityScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qualityScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> qualityScoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qualityScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> qualityScoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qualityScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> qualityScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qualityScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      reviewDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      reviewDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewDate',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewDate',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewPeriod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewPeriod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewPeriod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewPeriod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewPeriod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewPeriod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      reviewPeriodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewPeriod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      reviewPeriodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewPeriod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewPeriod',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewPeriodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewPeriod',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      reviewerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      reviewerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewerId',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> reviewerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewerId',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusGreaterThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusLessThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusBetween(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'strengths',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'strengths',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'strengths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      strengthsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'strengths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
          QAfterFilterCondition>
      strengthsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'strengths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'strengths',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> strengthsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'strengths',
        value: '',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> teamworkScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'teamworkScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> teamworkScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'teamworkScore',
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> teamworkScoreEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teamworkScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> teamworkScoreGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'teamworkScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> teamworkScoreLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'teamworkScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> teamworkScoreBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'teamworkScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> versionGreaterThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> versionLessThan(
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

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity,
      QAfterFilterCondition> versionBetween(
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

extension PerformanceReviewEntityQueryObject on QueryBuilder<
    PerformanceReviewEntity, PerformanceReviewEntity, QFilterCondition> {}

extension PerformanceReviewEntityQueryLinks on QueryBuilder<
    PerformanceReviewEntity, PerformanceReviewEntity, QFilterCondition> {}

extension PerformanceReviewEntityQuerySortBy
    on QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QSortBy> {
  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByAttendanceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByAttendanceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByEmployeeComments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeComments', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByEmployeeCommentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeComments', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goals', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByGoalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goals', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByImprovements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'improvements', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByImprovementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'improvements', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByInitiativeScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiativeScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByInitiativeScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiativeScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByManagerComments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'managerComments', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByManagerCommentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'managerComments', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByOverallRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRating', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByOverallRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRating', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByProductivityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByProductivityScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByQualityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByQualityScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewDate', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewDate', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByReviewPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPeriod', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByReviewPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPeriod', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByReviewerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerId', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByReviewerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerId', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByStrengths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strengths', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByStrengthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strengths', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByTeamworkScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamworkScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByTeamworkScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamworkScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension PerformanceReviewEntityQuerySortThenBy on QueryBuilder<
    PerformanceReviewEntity, PerformanceReviewEntity, QSortThenBy> {
  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByAttendanceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByAttendanceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByEmployeeComments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeComments', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByEmployeeCommentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeComments', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goals', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByGoalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goals', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByImprovements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'improvements', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByImprovementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'improvements', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByInitiativeScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiativeScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByInitiativeScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiativeScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByManagerComments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'managerComments', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByManagerCommentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'managerComments', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByOverallRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRating', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByOverallRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallRating', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByProductivityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByProductivityScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByQualityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByQualityScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewDate', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewDate', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByReviewPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPeriod', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByReviewPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPeriod', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByReviewerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerId', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByReviewerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerId', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByStrengths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strengths', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByStrengthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strengths', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByTeamworkScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamworkScore', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByTeamworkScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamworkScore', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension PerformanceReviewEntityQueryWhereDistinct on QueryBuilder<
    PerformanceReviewEntity, PerformanceReviewEntity, QDistinct> {
  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByAttendanceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attendanceScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByEmployeeComments({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeComments',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByEmployeeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByGoals({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goals', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByImprovements({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'improvements', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByInitiativeScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initiativeScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSynced');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByManagerComments({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'managerComments',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByOverallRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overallRating');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByProductivityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productivityScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByQualityScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qualityScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByReviewDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByReviewPeriod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewPeriod', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByReviewerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByStrengths({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strengths', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByTeamworkScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamworkScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<PerformanceReviewEntity, PerformanceReviewEntity, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension PerformanceReviewEntityQueryProperty on QueryBuilder<
    PerformanceReviewEntity, PerformanceReviewEntity, QQueryProperty> {
  QueryBuilder<PerformanceReviewEntity, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<PerformanceReviewEntity, int?, QQueryOperations>
      attendanceScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attendanceScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String?, QQueryOperations>
      employeeCommentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeComments');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String, QQueryOperations>
      employeeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeId');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String?, QQueryOperations>
      goalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goals');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String?, QQueryOperations>
      improvementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'improvements');
    });
  }

  QueryBuilder<PerformanceReviewEntity, int?, QQueryOperations>
      initiativeScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initiativeScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<PerformanceReviewEntity, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<PerformanceReviewEntity, DateTime?, QQueryOperations>
      lastSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSynced');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String?, QQueryOperations>
      managerCommentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'managerComments');
    });
  }

  QueryBuilder<PerformanceReviewEntity, double?, QQueryOperations>
      overallRatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overallRating');
    });
  }

  QueryBuilder<PerformanceReviewEntity, int?, QQueryOperations>
      productivityScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productivityScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, int?, QQueryOperations>
      qualityScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qualityScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String, QQueryOperations>
      reviewDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewDate');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String, QQueryOperations>
      reviewPeriodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewPeriod');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String, QQueryOperations>
      reviewerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewerId');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PerformanceReviewEntity, String?, QQueryOperations>
      strengthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strengths');
    });
  }

  QueryBuilder<PerformanceReviewEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<PerformanceReviewEntity, int?, QQueryOperations>
      teamworkScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamworkScore');
    });
  }

  QueryBuilder<PerformanceReviewEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PerformanceReviewEntity, int, QQueryOperations>
      versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
