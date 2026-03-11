// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAttendanceEntityCollection on Isar {
  IsarCollection<AttendanceEntity> get attendanceEntitys => this.collection();
}

const AttendanceEntitySchema = CollectionSchema(
  name: r'AttendanceEntity',
  id: 5479936569571385882,
  properties: {
    r'auditLog': PropertySchema(
      id: 0,
      name: r'auditLog',
      type: IsarType.string,
    ),
    r'checkInLatitude': PropertySchema(
      id: 1,
      name: r'checkInLatitude',
      type: IsarType.double,
    ),
    r'checkInLongitude': PropertySchema(
      id: 2,
      name: r'checkInLongitude',
      type: IsarType.double,
    ),
    r'checkInTime': PropertySchema(
      id: 3,
      name: r'checkInTime',
      type: IsarType.string,
    ),
    r'checkOutLatitude': PropertySchema(
      id: 4,
      name: r'checkOutLatitude',
      type: IsarType.double,
    ),
    r'checkOutLongitude': PropertySchema(
      id: 5,
      name: r'checkOutLongitude',
      type: IsarType.double,
    ),
    r'checkOutTime': PropertySchema(
      id: 6,
      name: r'checkOutTime',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 7,
      name: r'date',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 8,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'employeeId': PropertySchema(
      id: 9,
      name: r'employeeId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 10,
      name: r'id',
      type: IsarType.string,
    ),
    r'isCorrected': PropertySchema(
      id: 11,
      name: r'isCorrected',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 12,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isManualEntry': PropertySchema(
      id: 13,
      name: r'isManualEntry',
      type: IsarType.bool,
    ),
    r'isOvertime': PropertySchema(
      id: 14,
      name: r'isOvertime',
      type: IsarType.bool,
    ),
    r'markedAt': PropertySchema(
      id: 15,
      name: r'markedAt',
      type: IsarType.dateTime,
    ),
    r'overtimeHours': PropertySchema(
      id: 16,
      name: r'overtimeHours',
      type: IsarType.double,
    ),
    r'remarks': PropertySchema(
      id: 17,
      name: r'remarks',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 18,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 19,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _AttendanceEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 20,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _attendanceEntityEstimateSize,
  serialize: _attendanceEntitySerialize,
  deserialize: _attendanceEntityDeserialize,
  deserializeProp: _attendanceEntityDeserializeProp,
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
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
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
  getId: _attendanceEntityGetId,
  getLinks: _attendanceEntityGetLinks,
  attach: _attendanceEntityAttach,
  version: '3.1.0+1',
);

int _attendanceEntityEstimateSize(
  AttendanceEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.auditLog;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.checkInTime;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.checkOutTime;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.date.length * 3;
  bytesCount += 3 + object.employeeId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.remarks;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _attendanceEntitySerialize(
  AttendanceEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.auditLog);
  writer.writeDouble(offsets[1], object.checkInLatitude);
  writer.writeDouble(offsets[2], object.checkInLongitude);
  writer.writeString(offsets[3], object.checkInTime);
  writer.writeDouble(offsets[4], object.checkOutLatitude);
  writer.writeDouble(offsets[5], object.checkOutLongitude);
  writer.writeString(offsets[6], object.checkOutTime);
  writer.writeString(offsets[7], object.date);
  writer.writeDateTime(offsets[8], object.deletedAt);
  writer.writeString(offsets[9], object.employeeId);
  writer.writeString(offsets[10], object.id);
  writer.writeBool(offsets[11], object.isCorrected);
  writer.writeBool(offsets[12], object.isDeleted);
  writer.writeBool(offsets[13], object.isManualEntry);
  writer.writeBool(offsets[14], object.isOvertime);
  writer.writeDateTime(offsets[15], object.markedAt);
  writer.writeDouble(offsets[16], object.overtimeHours);
  writer.writeString(offsets[17], object.remarks);
  writer.writeString(offsets[18], object.status);
  writer.writeByte(offsets[19], object.syncStatus.index);
  writer.writeDateTime(offsets[20], object.updatedAt);
}

AttendanceEntity _attendanceEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AttendanceEntity();
  object.auditLog = reader.readStringOrNull(offsets[0]);
  object.checkInLatitude = reader.readDoubleOrNull(offsets[1]);
  object.checkInLongitude = reader.readDoubleOrNull(offsets[2]);
  object.checkInTime = reader.readStringOrNull(offsets[3]);
  object.checkOutLatitude = reader.readDoubleOrNull(offsets[4]);
  object.checkOutLongitude = reader.readDoubleOrNull(offsets[5]);
  object.checkOutTime = reader.readStringOrNull(offsets[6]);
  object.date = reader.readString(offsets[7]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[8]);
  object.employeeId = reader.readString(offsets[9]);
  object.id = reader.readString(offsets[10]);
  object.isCorrected = reader.readBool(offsets[11]);
  object.isDeleted = reader.readBool(offsets[12]);
  object.isManualEntry = reader.readBool(offsets[13]);
  object.isOvertime = reader.readBool(offsets[14]);
  object.markedAt = reader.readDateTimeOrNull(offsets[15]);
  object.overtimeHours = reader.readDoubleOrNull(offsets[16]);
  object.remarks = reader.readStringOrNull(offsets[17]);
  object.status = reader.readString(offsets[18]);
  object.syncStatus = _AttendanceEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[19])] ??
      SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[20]);
  return object;
}

P _attendanceEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (_AttendanceEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 20:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AttendanceEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _AttendanceEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _attendanceEntityGetId(AttendanceEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _attendanceEntityGetLinks(AttendanceEntity object) {
  return [];
}

void _attendanceEntityAttach(
    IsarCollection<dynamic> col, Id id, AttendanceEntity object) {}

extension AttendanceEntityByIndex on IsarCollection<AttendanceEntity> {
  Future<AttendanceEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  AttendanceEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<AttendanceEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<AttendanceEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(AttendanceEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(AttendanceEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<AttendanceEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<AttendanceEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension AttendanceEntityQueryWhereSort
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QWhere> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AttendanceEntityQueryWhere
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QWhereClause> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
      employeeIdEqualTo(String employeeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'employeeId',
        value: [employeeId],
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
      dateEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
      dateNotEqualTo(String date) {
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterWhereClause>
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

extension AttendanceEntityQueryFilter
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QFilterCondition> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'auditLog',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'auditLog',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auditLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'auditLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'auditLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'auditLog',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'auditLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'auditLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'auditLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'auditLog',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'auditLog',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      auditLogIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'auditLog',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLatitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkInLatitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLatitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkInLatitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLatitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkInLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLatitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkInLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLatitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkInLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLatitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkInLatitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLongitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkInLongitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLongitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkInLongitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLongitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkInLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLongitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkInLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLongitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkInLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInLongitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkInLongitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkInTime',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkInTime',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkInTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkInTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkInTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkInTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'checkInTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'checkInTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'checkInTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'checkInTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkInTime',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkInTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'checkInTime',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLatitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkOutLatitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLatitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkOutLatitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLatitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkOutLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLatitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkOutLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLatitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkOutLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLatitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkOutLatitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLongitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkOutLongitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLongitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkOutLongitude',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLongitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkOutLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLongitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkOutLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLongitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkOutLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutLongitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkOutLongitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkOutTime',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkOutTime',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkOutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkOutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkOutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkOutTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'checkOutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'checkOutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'checkOutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'checkOutTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkOutTime',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      checkOutTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'checkOutTime',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      employeeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      employeeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      employeeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      employeeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      isCorrectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCorrected',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      isManualEntryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isManualEntry',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      isOvertimeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOvertime',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      markedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'markedAt',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      markedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'markedAt',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      markedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      markedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      markedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      markedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      overtimeHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'overtimeHours',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      overtimeHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'overtimeHours',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      overtimeHoursEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overtimeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      overtimeHoursGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overtimeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      overtimeHoursLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overtimeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      overtimeHoursBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overtimeHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remarks',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remarks',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remarks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remarks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remarks',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remarks',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      remarksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remarks',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterFilterCondition>
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

extension AttendanceEntityQueryObject
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QFilterCondition> {}

extension AttendanceEntityQueryLinks
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QFilterCondition> {}

extension AttendanceEntityQuerySortBy
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QSortBy> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByAuditLog() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auditLog', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByAuditLogDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auditLog', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckInLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLatitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckInLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLatitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckInLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLongitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckInLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLongitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckInTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInTime', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckInTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInTime', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckOutLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLatitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckOutLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLatitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckOutLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLongitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckOutLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLongitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckOutTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutTime', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByCheckOutTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutTime', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsCorrected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrected', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsCorrectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrected', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsManualEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsOvertime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByIsOvertimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByMarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByMarkedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByOvertimeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeHours', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByOvertimeHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeHours', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByRemarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByRemarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AttendanceEntityQuerySortThenBy
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QSortThenBy> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByAuditLog() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auditLog', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByAuditLogDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'auditLog', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckInLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLatitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckInLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLatitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckInLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLongitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckInLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInLongitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckInTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInTime', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckInTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInTime', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckOutLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLatitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckOutLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLatitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckOutLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLongitude', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckOutLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutLongitude', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckOutTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutTime', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByCheckOutTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkOutTime', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsCorrected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrected', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsCorrectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrected', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsManualEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsOvertime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsOvertimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByMarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByMarkedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByOvertimeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeHours', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByOvertimeHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeHours', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByRemarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByRemarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remarks', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AttendanceEntityQueryWhereDistinct
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> {
  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByAuditLog({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'auditLog', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByCheckInLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkInLatitude');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByCheckInLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkInLongitude');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByCheckInTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkInTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByCheckOutLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkOutLatitude');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByCheckOutLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkOutLongitude');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByCheckOutTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkOutTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByEmployeeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByIsCorrected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCorrected');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isManualEntry');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByIsOvertime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOvertime');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByMarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markedAt');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByOvertimeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overtimeHours');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByRemarks(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remarks', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<AttendanceEntity, AttendanceEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AttendanceEntityQueryProperty
    on QueryBuilder<AttendanceEntity, AttendanceEntity, QQueryProperty> {
  QueryBuilder<AttendanceEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<AttendanceEntity, String?, QQueryOperations> auditLogProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'auditLog');
    });
  }

  QueryBuilder<AttendanceEntity, double?, QQueryOperations>
      checkInLatitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkInLatitude');
    });
  }

  QueryBuilder<AttendanceEntity, double?, QQueryOperations>
      checkInLongitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkInLongitude');
    });
  }

  QueryBuilder<AttendanceEntity, String?, QQueryOperations>
      checkInTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkInTime');
    });
  }

  QueryBuilder<AttendanceEntity, double?, QQueryOperations>
      checkOutLatitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkOutLatitude');
    });
  }

  QueryBuilder<AttendanceEntity, double?, QQueryOperations>
      checkOutLongitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkOutLongitude');
    });
  }

  QueryBuilder<AttendanceEntity, String?, QQueryOperations>
      checkOutTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkOutTime');
    });
  }

  QueryBuilder<AttendanceEntity, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<AttendanceEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<AttendanceEntity, String, QQueryOperations>
      employeeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeId');
    });
  }

  QueryBuilder<AttendanceEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AttendanceEntity, bool, QQueryOperations> isCorrectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCorrected');
    });
  }

  QueryBuilder<AttendanceEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<AttendanceEntity, bool, QQueryOperations>
      isManualEntryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isManualEntry');
    });
  }

  QueryBuilder<AttendanceEntity, bool, QQueryOperations> isOvertimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOvertime');
    });
  }

  QueryBuilder<AttendanceEntity, DateTime?, QQueryOperations>
      markedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markedAt');
    });
  }

  QueryBuilder<AttendanceEntity, double?, QQueryOperations>
      overtimeHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overtimeHours');
    });
  }

  QueryBuilder<AttendanceEntity, String?, QQueryOperations> remarksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remarks');
    });
  }

  QueryBuilder<AttendanceEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AttendanceEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<AttendanceEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
