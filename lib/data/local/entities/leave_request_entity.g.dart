// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLeaveRequestEntityCollection on Isar {
  IsarCollection<LeaveRequestEntity> get leaveRequestEntitys =>
      this.collection();
}

const LeaveRequestEntitySchema = CollectionSchema(
  name: r'LeaveRequestEntity',
  id: -2569807198944259120,
  properties: {
    r'approvedAt': PropertySchema(
      id: 0,
      name: r'approvedAt',
      type: IsarType.string,
    ),
    r'approvedBy': PropertySchema(
      id: 1,
      name: r'approvedBy',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 2,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'employeeId': PropertySchema(
      id: 3,
      name: r'employeeId',
      type: IsarType.string,
    ),
    r'endDate': PropertySchema(
      id: 4,
      name: r'endDate',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 6,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'leaveType': PropertySchema(
      id: 7,
      name: r'leaveType',
      type: IsarType.string,
    ),
    r'reason': PropertySchema(
      id: 8,
      name: r'reason',
      type: IsarType.string,
    ),
    r'rejectionReason': PropertySchema(
      id: 9,
      name: r'rejectionReason',
      type: IsarType.string,
    ),
    r'requestedAt': PropertySchema(
      id: 10,
      name: r'requestedAt',
      type: IsarType.string,
    ),
    r'startDate': PropertySchema(
      id: 11,
      name: r'startDate',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 13,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _LeaveRequestEntitysyncStatusEnumValueMap,
    ),
    r'totalDays': PropertySchema(
      id: 14,
      name: r'totalDays',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _leaveRequestEntityEstimateSize,
  serialize: _leaveRequestEntitySerialize,
  deserialize: _leaveRequestEntityDeserialize,
  deserializeProp: _leaveRequestEntityDeserializeProp,
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
    r'leaveType': IndexSchema(
      id: -349382483217042310,
      name: r'leaveType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'leaveType',
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
  getId: _leaveRequestEntityGetId,
  getLinks: _leaveRequestEntityGetLinks,
  attach: _leaveRequestEntityAttach,
  version: '3.1.0+1',
);

int _leaveRequestEntityEstimateSize(
  LeaveRequestEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.approvedAt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.approvedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.employeeId.length * 3;
  bytesCount += 3 + object.endDate.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.leaveType.length * 3;
  {
    final value = object.reason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rejectionReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.requestedAt.length * 3;
  bytesCount += 3 + object.startDate.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _leaveRequestEntitySerialize(
  LeaveRequestEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.approvedAt);
  writer.writeString(offsets[1], object.approvedBy);
  writer.writeDateTime(offsets[2], object.deletedAt);
  writer.writeString(offsets[3], object.employeeId);
  writer.writeString(offsets[4], object.endDate);
  writer.writeString(offsets[5], object.id);
  writer.writeBool(offsets[6], object.isDeleted);
  writer.writeString(offsets[7], object.leaveType);
  writer.writeString(offsets[8], object.reason);
  writer.writeString(offsets[9], object.rejectionReason);
  writer.writeString(offsets[10], object.requestedAt);
  writer.writeString(offsets[11], object.startDate);
  writer.writeString(offsets[12], object.status);
  writer.writeByte(offsets[13], object.syncStatus.index);
  writer.writeLong(offsets[14], object.totalDays);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

LeaveRequestEntity _leaveRequestEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LeaveRequestEntity();
  object.approvedAt = reader.readStringOrNull(offsets[0]);
  object.approvedBy = reader.readStringOrNull(offsets[1]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[2]);
  object.employeeId = reader.readString(offsets[3]);
  object.endDate = reader.readString(offsets[4]);
  object.id = reader.readString(offsets[5]);
  object.isDeleted = reader.readBool(offsets[6]);
  object.leaveType = reader.readString(offsets[7]);
  object.reason = reader.readStringOrNull(offsets[8]);
  object.rejectionReason = reader.readStringOrNull(offsets[9]);
  object.requestedAt = reader.readString(offsets[10]);
  object.startDate = reader.readString(offsets[11]);
  object.status = reader.readString(offsets[12]);
  object.syncStatus = _LeaveRequestEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[13])] ??
      SyncStatus.pending;
  object.totalDays = reader.readLong(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _leaveRequestEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (_LeaveRequestEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LeaveRequestEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _LeaveRequestEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _leaveRequestEntityGetId(LeaveRequestEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _leaveRequestEntityGetLinks(
    LeaveRequestEntity object) {
  return [];
}

void _leaveRequestEntityAttach(
    IsarCollection<dynamic> col, Id id, LeaveRequestEntity object) {}

extension LeaveRequestEntityByIndex on IsarCollection<LeaveRequestEntity> {
  Future<LeaveRequestEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  LeaveRequestEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<LeaveRequestEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<LeaveRequestEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(LeaveRequestEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(LeaveRequestEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<LeaveRequestEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<LeaveRequestEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension LeaveRequestEntityQueryWhereSort
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QWhere> {
  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LeaveRequestEntityQueryWhere
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QWhereClause> {
  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      employeeIdEqualTo(String employeeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'employeeId',
        value: [employeeId],
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      employeeIdNotEqualTo(String employeeId) {
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      leaveTypeEqualTo(String leaveType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'leaveType',
        value: [leaveType],
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      leaveTypeNotEqualTo(String leaveType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leaveType',
              lower: [],
              upper: [leaveType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leaveType',
              lower: [leaveType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leaveType',
              lower: [leaveType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leaveType',
              lower: [],
              upper: [leaveType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterWhereClause>
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

extension LeaveRequestEntityQueryFilter
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QFilterCondition> {
  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvedAt',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvedAt',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approvedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approvedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approvedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approvedAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approvedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvedBy',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvedBy',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approvedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      approvedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approvedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdEqualTo(
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdGreaterThan(
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdLessThan(
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdBetween(
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdStartsWith(
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdEndsWith(
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      employeeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      endDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endDate',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leaveType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'leaveType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leaveType',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      leaveTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'leaveType',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonEqualTo(
    String? value, {
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonGreaterThan(
    String? value, {
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonLessThan(
    String? value, {
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rejectionReason',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rejectionReason',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectionReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rejectionReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectionReason',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      rejectionReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rejectionReason',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestedAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      requestedAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'startDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'startDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'startDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'startDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      startDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'startDate',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      totalDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      totalDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      totalDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      totalDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterFilterCondition>
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
}

extension LeaveRequestEntityQueryObject
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QFilterCondition> {}

extension LeaveRequestEntityQueryLinks
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QFilterCondition> {}

extension LeaveRequestEntityQuerySortBy
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QSortBy> {
  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByApprovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByLeaveType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByLeaveTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByRejectionReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByRejectionReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByRequestedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByTotalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDays', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByTotalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDays', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LeaveRequestEntityQuerySortThenBy
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QSortThenBy> {
  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByApprovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByLeaveType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByLeaveTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByRejectionReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByRejectionReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByRequestedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByTotalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDays', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByTotalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDays', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LeaveRequestEntityQueryWhereDistinct
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct> {
  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByApprovedAt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByApprovedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByEmployeeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByEndDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByLeaveType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leaveType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByRejectionReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectionReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByRequestedAt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestedAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByStartDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByTotalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDays');
    });
  }

  QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LeaveRequestEntityQueryProperty
    on QueryBuilder<LeaveRequestEntity, LeaveRequestEntity, QQueryProperty> {
  QueryBuilder<LeaveRequestEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<LeaveRequestEntity, String?, QQueryOperations>
      approvedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedAt');
    });
  }

  QueryBuilder<LeaveRequestEntity, String?, QQueryOperations>
      approvedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedBy');
    });
  }

  QueryBuilder<LeaveRequestEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<LeaveRequestEntity, String, QQueryOperations>
      employeeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeId');
    });
  }

  QueryBuilder<LeaveRequestEntity, String, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<LeaveRequestEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LeaveRequestEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<LeaveRequestEntity, String, QQueryOperations>
      leaveTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leaveType');
    });
  }

  QueryBuilder<LeaveRequestEntity, String?, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<LeaveRequestEntity, String?, QQueryOperations>
      rejectionReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectionReason');
    });
  }

  QueryBuilder<LeaveRequestEntity, String, QQueryOperations>
      requestedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestedAt');
    });
  }

  QueryBuilder<LeaveRequestEntity, String, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<LeaveRequestEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LeaveRequestEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<LeaveRequestEntity, int, QQueryOperations> totalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDays');
    });
  }

  QueryBuilder<LeaveRequestEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
