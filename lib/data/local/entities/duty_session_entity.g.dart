// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duty_session_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDutySessionEntityCollection on Isar {
  IsarCollection<DutySessionEntity> get dutySessionEntitys => this.collection();
}

const DutySessionEntitySchema = CollectionSchema(
  name: r'DutySessionEntity',
  id: -540215116800598928,
  properties: {
    r'alerts': PropertySchema(
      id: 0,
      name: r'alerts',
      type: IsarType.stringList,
    ),
    r'autoStopReason': PropertySchema(
      id: 1,
      name: r'autoStopReason',
      type: IsarType.string,
    ),
    r'baseLatitude': PropertySchema(
      id: 2,
      name: r'baseLatitude',
      type: IsarType.double,
    ),
    r'baseLongitude': PropertySchema(
      id: 3,
      name: r'baseLongitude',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 5,
      name: r'date',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 6,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 7,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'dutyEndTime': PropertySchema(
      id: 8,
      name: r'dutyEndTime',
      type: IsarType.string,
    ),
    r'employeeId': PropertySchema(
      id: 9,
      name: r'employeeId',
      type: IsarType.string,
    ),
    r'endOdometer': PropertySchema(
      id: 10,
      name: r'endOdometer',
      type: IsarType.double,
    ),
    r'gpsAutoOff': PropertySchema(
      id: 11,
      name: r'gpsAutoOff',
      type: IsarType.bool,
    ),
    r'gpsEnabled': PropertySchema(
      id: 12,
      name: r'gpsEnabled',
      type: IsarType.bool,
    ),
    r'id': PropertySchema(
      id: 13,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 14,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isOvertime': PropertySchema(
      id: 15,
      name: r'isOvertime',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 16,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastSynced': PropertySchema(
      id: 17,
      name: r'lastSynced',
      type: IsarType.dateTime,
    ),
    r'loginLatitude': PropertySchema(
      id: 18,
      name: r'loginLatitude',
      type: IsarType.double,
    ),
    r'loginLongitude': PropertySchema(
      id: 19,
      name: r'loginLongitude',
      type: IsarType.double,
    ),
    r'loginTime': PropertySchema(
      id: 20,
      name: r'loginTime',
      type: IsarType.string,
    ),
    r'logoutLatitude': PropertySchema(
      id: 21,
      name: r'logoutLatitude',
      type: IsarType.double,
    ),
    r'logoutLongitude': PropertySchema(
      id: 22,
      name: r'logoutLongitude',
      type: IsarType.double,
    ),
    r'logoutTime': PropertySchema(
      id: 23,
      name: r'logoutTime',
      type: IsarType.string,
    ),
    r'overtimeMinutes': PropertySchema(
      id: 24,
      name: r'overtimeMinutes',
      type: IsarType.long,
    ),
    r'routeName': PropertySchema(
      id: 25,
      name: r'routeName',
      type: IsarType.string,
    ),
    r'startOdometer': PropertySchema(
      id: 26,
      name: r'startOdometer',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 27,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 28,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _DutySessionEntitysyncStatusEnumValueMap,
    ),
    r'totalDistanceKm': PropertySchema(
      id: 29,
      name: r'totalDistanceKm',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 30,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 31,
      name: r'userId',
      type: IsarType.string,
    ),
    r'userName': PropertySchema(
      id: 32,
      name: r'userName',
      type: IsarType.string,
    ),
    r'userRole': PropertySchema(
      id: 33,
      name: r'userRole',
      type: IsarType.string,
    ),
    r'vehicleId': PropertySchema(
      id: 34,
      name: r'vehicleId',
      type: IsarType.string,
    ),
    r'vehicleNumber': PropertySchema(
      id: 35,
      name: r'vehicleNumber',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 36,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _dutySessionEntityEstimateSize,
  serialize: _dutySessionEntitySerialize,
  deserialize: _dutySessionEntityDeserialize,
  deserializeProp: _dutySessionEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
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
  getId: _dutySessionEntityGetId,
  getLinks: _dutySessionEntityGetLinks,
  attach: _dutySessionEntityAttach,
  version: '3.1.0+1',
);

int _dutySessionEntityEstimateSize(
  DutySessionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.alerts.length * 3;
  {
    for (var i = 0; i < object.alerts.length; i++) {
      final value = object.alerts[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.autoStopReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.createdAt.length * 3;
  bytesCount += 3 + object.date.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.dutyEndTime;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.employeeId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.loginTime.length * 3;
  {
    final value = object.logoutTime;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.routeName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.userName.length * 3;
  bytesCount += 3 + object.userRole.length * 3;
  {
    final value = object.vehicleId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.vehicleNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _dutySessionEntitySerialize(
  DutySessionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.alerts);
  writer.writeString(offsets[1], object.autoStopReason);
  writer.writeDouble(offsets[2], object.baseLatitude);
  writer.writeDouble(offsets[3], object.baseLongitude);
  writer.writeString(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.date);
  writer.writeDateTime(offsets[6], object.deletedAt);
  writer.writeString(offsets[7], object.deviceId);
  writer.writeString(offsets[8], object.dutyEndTime);
  writer.writeString(offsets[9], object.employeeId);
  writer.writeDouble(offsets[10], object.endOdometer);
  writer.writeBool(offsets[11], object.gpsAutoOff);
  writer.writeBool(offsets[12], object.gpsEnabled);
  writer.writeString(offsets[13], object.id);
  writer.writeBool(offsets[14], object.isDeleted);
  writer.writeBool(offsets[15], object.isOvertime);
  writer.writeBool(offsets[16], object.isSynced);
  writer.writeDateTime(offsets[17], object.lastSynced);
  writer.writeDouble(offsets[18], object.loginLatitude);
  writer.writeDouble(offsets[19], object.loginLongitude);
  writer.writeString(offsets[20], object.loginTime);
  writer.writeDouble(offsets[21], object.logoutLatitude);
  writer.writeDouble(offsets[22], object.logoutLongitude);
  writer.writeString(offsets[23], object.logoutTime);
  writer.writeLong(offsets[24], object.overtimeMinutes);
  writer.writeString(offsets[25], object.routeName);
  writer.writeDouble(offsets[26], object.startOdometer);
  writer.writeString(offsets[27], object.status);
  writer.writeByte(offsets[28], object.syncStatus.index);
  writer.writeDouble(offsets[29], object.totalDistanceKm);
  writer.writeDateTime(offsets[30], object.updatedAt);
  writer.writeString(offsets[31], object.userId);
  writer.writeString(offsets[32], object.userName);
  writer.writeString(offsets[33], object.userRole);
  writer.writeString(offsets[34], object.vehicleId);
  writer.writeString(offsets[35], object.vehicleNumber);
  writer.writeLong(offsets[36], object.version);
}

DutySessionEntity _dutySessionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DutySessionEntity();
  object.alerts = reader.readStringList(offsets[0]) ?? [];
  object.autoStopReason = reader.readStringOrNull(offsets[1]);
  object.baseLatitude = reader.readDoubleOrNull(offsets[2]);
  object.baseLongitude = reader.readDoubleOrNull(offsets[3]);
  object.createdAt = reader.readString(offsets[4]);
  object.date = reader.readString(offsets[5]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[6]);
  object.deviceId = reader.readString(offsets[7]);
  object.dutyEndTime = reader.readStringOrNull(offsets[8]);
  object.employeeId = reader.readStringOrNull(offsets[9]);
  object.endOdometer = reader.readDoubleOrNull(offsets[10]);
  object.gpsAutoOff = reader.readBoolOrNull(offsets[11]);
  object.gpsEnabled = reader.readBool(offsets[12]);
  object.id = reader.readString(offsets[13]);
  object.isDeleted = reader.readBool(offsets[14]);
  object.isOvertime = reader.readBoolOrNull(offsets[15]);
  object.isSynced = reader.readBool(offsets[16]);
  object.lastSynced = reader.readDateTimeOrNull(offsets[17]);
  object.loginLatitude = reader.readDouble(offsets[18]);
  object.loginLongitude = reader.readDouble(offsets[19]);
  object.loginTime = reader.readString(offsets[20]);
  object.logoutLatitude = reader.readDoubleOrNull(offsets[21]);
  object.logoutLongitude = reader.readDoubleOrNull(offsets[22]);
  object.logoutTime = reader.readStringOrNull(offsets[23]);
  object.overtimeMinutes = reader.readLongOrNull(offsets[24]);
  object.routeName = reader.readStringOrNull(offsets[25]);
  object.startOdometer = reader.readDoubleOrNull(offsets[26]);
  object.status = reader.readString(offsets[27]);
  object.syncStatus = _DutySessionEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[28])] ??
      SyncStatus.pending;
  object.totalDistanceKm = reader.readDoubleOrNull(offsets[29]);
  object.updatedAt = reader.readDateTime(offsets[30]);
  object.userId = reader.readString(offsets[31]);
  object.userName = reader.readString(offsets[32]);
  object.userRole = reader.readString(offsets[33]);
  object.vehicleId = reader.readStringOrNull(offsets[34]);
  object.vehicleNumber = reader.readStringOrNull(offsets[35]);
  object.version = reader.readLong(offsets[36]);
  return object;
}

P _dutySessionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBoolOrNull(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDoubleOrNull(offset)) as P;
    case 22:
      return (reader.readDoubleOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readDoubleOrNull(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (_DutySessionEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 29:
      return (reader.readDoubleOrNull(offset)) as P;
    case 30:
      return (reader.readDateTime(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readStringOrNull(offset)) as P;
    case 36:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DutySessionEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _DutySessionEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _dutySessionEntityGetId(DutySessionEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _dutySessionEntityGetLinks(
    DutySessionEntity object) {
  return [];
}

void _dutySessionEntityAttach(
    IsarCollection<dynamic> col, Id id, DutySessionEntity object) {}

extension DutySessionEntityByIndex on IsarCollection<DutySessionEntity> {
  Future<DutySessionEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  DutySessionEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<DutySessionEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<DutySessionEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(DutySessionEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(DutySessionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<DutySessionEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<DutySessionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension DutySessionEntityQueryWhereSort
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QWhere> {
  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DutySessionEntityQueryWhere
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QWhereClause> {
  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      dateEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterWhereClause>
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

extension DutySessionEntityQueryFilter
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QFilterCondition> {
  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alerts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alerts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alerts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alerts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'alerts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'alerts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'alerts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'alerts',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alerts',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'alerts',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alerts',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alerts',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alerts',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alerts',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alerts',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      alertsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alerts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autoStopReason',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autoStopReason',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoStopReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoStopReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoStopReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoStopReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'autoStopReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'autoStopReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'autoStopReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'autoStopReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoStopReason',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      autoStopReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'autoStopReason',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLatitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baseLatitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLatitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baseLatitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLatitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLatitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLatitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLatitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseLatitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLongitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baseLongitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLongitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baseLongitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLongitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLongitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLongitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      baseLongitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseLongitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      createdAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      createdAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      createdAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      createdAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dutyEndTime',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dutyEndTime',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dutyEndTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dutyEndTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dutyEndTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dutyEndTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dutyEndTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dutyEndTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dutyEndTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dutyEndTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dutyEndTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      dutyEndTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dutyEndTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'employeeId',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'employeeId',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdEqualTo(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdGreaterThan(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdLessThan(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      employeeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      endOdometerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endOdometer',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      endOdometerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endOdometer',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      endOdometerEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      endOdometerGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      endOdometerLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      endOdometerBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endOdometer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      gpsAutoOffIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gpsAutoOff',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      gpsAutoOffIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gpsAutoOff',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      gpsAutoOffEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gpsAutoOff',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      gpsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gpsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      isOvertimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isOvertime',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      isOvertimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isOvertime',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      isOvertimeEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOvertime',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      lastSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      lastSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      lastSyncedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLatitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLatitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loginLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLatitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loginLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLatitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loginLatitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLongitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLongitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loginLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLongitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loginLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginLongitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loginLongitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loginTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loginTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loginTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loginTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loginTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loginTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loginTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      loginTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loginTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLatitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logoutLatitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLatitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logoutLatitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLatitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoutLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLatitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logoutLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLatitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logoutLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLatitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logoutLatitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLongitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logoutLongitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLongitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logoutLongitude',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLongitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoutLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLongitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logoutLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLongitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logoutLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutLongitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logoutLongitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logoutTime',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logoutTime',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logoutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logoutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logoutTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logoutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logoutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logoutTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logoutTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoutTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      logoutTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logoutTime',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      overtimeMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'overtimeMinutes',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      overtimeMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'overtimeMinutes',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      overtimeMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overtimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      overtimeMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overtimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      overtimeMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overtimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      overtimeMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overtimeMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'routeName',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'routeName',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'routeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'routeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'routeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'routeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeName',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      routeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'routeName',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      startOdometerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startOdometer',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      startOdometerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startOdometer',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      startOdometerEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      startOdometerGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      startOdometerLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      startOdometerBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startOdometer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      totalDistanceKmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalDistanceKm',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      totalDistanceKmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalDistanceKm',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      totalDistanceKmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDistanceKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      totalDistanceKmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDistanceKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      totalDistanceKmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDistanceKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      totalDistanceKmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDistanceKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userName',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userName',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userRole',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      userRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userRole',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vehicleId',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vehicleId',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdEqualTo(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdGreaterThan(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdLessThan(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vehicleNumber',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vehicleNumber',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberEqualTo(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberGreaterThan(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberLessThan(
    String? value, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      vehicleNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterFilterCondition>
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

extension DutySessionEntityQueryObject
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QFilterCondition> {}

extension DutySessionEntityQueryLinks
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QFilterCondition> {}

extension DutySessionEntityQuerySortBy
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QSortBy> {
  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByAutoStopReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoStopReason', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByAutoStopReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoStopReason', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByBaseLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLatitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByBaseLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLatitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByBaseLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLongitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByBaseLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLongitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDutyEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dutyEndTime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByDutyEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dutyEndTime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByEndOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOdometer', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByEndOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOdometer', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByGpsAutoOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsAutoOff', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByGpsAutoOffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsAutoOff', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByGpsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsEnabled', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByGpsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsEnabled', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByIsOvertime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByIsOvertimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLoginLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLatitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLoginLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLatitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLoginLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLongitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLoginLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLongitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLoginTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLogoutLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLatitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLogoutLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLatitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLogoutLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLongitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLogoutLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLongitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLogoutTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutTime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByLogoutTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutTime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByOvertimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByOvertimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByRouteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByRouteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByStartOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOdometer', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByStartOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOdometer', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByTotalDistanceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceKm', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByTotalDistanceKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceKm', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUserRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userRole', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByUserRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userRole', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension DutySessionEntityQuerySortThenBy
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QSortThenBy> {
  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByAutoStopReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoStopReason', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByAutoStopReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoStopReason', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByBaseLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLatitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByBaseLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLatitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByBaseLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLongitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByBaseLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseLongitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDutyEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dutyEndTime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByDutyEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dutyEndTime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByEndOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOdometer', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByEndOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOdometer', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByGpsAutoOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsAutoOff', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByGpsAutoOffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsAutoOff', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByGpsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsEnabled', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByGpsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpsEnabled', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsOvertime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsOvertimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOvertime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLoginLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLatitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLoginLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLatitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLoginLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLongitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLoginLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginLongitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLoginTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLoginTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginTime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLogoutLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLatitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLogoutLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLatitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLogoutLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLongitude', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLogoutLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutLongitude', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLogoutTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutTime', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByLogoutTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoutTime', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByOvertimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByOvertimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByRouteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByRouteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByStartOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOdometer', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByStartOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOdometer', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByTotalDistanceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceKm', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByTotalDistanceKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceKm', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUserRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userRole', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByUserRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userRole', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension DutySessionEntityQueryWhereDistinct
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct> {
  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alerts');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByAutoStopReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoStopReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByBaseLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseLatitude');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByBaseLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseLongitude');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByCreatedAt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByDutyEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dutyEndTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByEmployeeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByEndOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endOdometer');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByGpsAutoOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gpsAutoOff');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByGpsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gpsEnabled');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByIsOvertime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOvertime');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSynced');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByLoginLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginLatitude');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByLoginLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginLongitude');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByLoginTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByLogoutLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logoutLatitude');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByLogoutLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logoutLongitude');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByLogoutTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logoutTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByOvertimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overtimeMinutes');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByRouteName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByStartOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startOdometer');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByTotalDistanceKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDistanceKm');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByUserName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByUserRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userRole', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByVehicleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByVehicleNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DutySessionEntity, DutySessionEntity, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension DutySessionEntityQueryProperty
    on QueryBuilder<DutySessionEntity, DutySessionEntity, QQueryProperty> {
  QueryBuilder<DutySessionEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DutySessionEntity, List<String>, QQueryOperations>
      alertsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alerts');
    });
  }

  QueryBuilder<DutySessionEntity, String?, QQueryOperations>
      autoStopReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoStopReason');
    });
  }

  QueryBuilder<DutySessionEntity, double?, QQueryOperations>
      baseLatitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseLatitude');
    });
  }

  QueryBuilder<DutySessionEntity, double?, QQueryOperations>
      baseLongitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseLongitude');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DutySessionEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<DutySessionEntity, String?, QQueryOperations>
      dutyEndTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dutyEndTime');
    });
  }

  QueryBuilder<DutySessionEntity, String?, QQueryOperations>
      employeeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeId');
    });
  }

  QueryBuilder<DutySessionEntity, double?, QQueryOperations>
      endOdometerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endOdometer');
    });
  }

  QueryBuilder<DutySessionEntity, bool?, QQueryOperations>
      gpsAutoOffProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gpsAutoOff');
    });
  }

  QueryBuilder<DutySessionEntity, bool, QQueryOperations> gpsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gpsEnabled');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DutySessionEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<DutySessionEntity, bool?, QQueryOperations>
      isOvertimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOvertime');
    });
  }

  QueryBuilder<DutySessionEntity, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<DutySessionEntity, DateTime?, QQueryOperations>
      lastSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSynced');
    });
  }

  QueryBuilder<DutySessionEntity, double, QQueryOperations>
      loginLatitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginLatitude');
    });
  }

  QueryBuilder<DutySessionEntity, double, QQueryOperations>
      loginLongitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginLongitude');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations>
      loginTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginTime');
    });
  }

  QueryBuilder<DutySessionEntity, double?, QQueryOperations>
      logoutLatitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoutLatitude');
    });
  }

  QueryBuilder<DutySessionEntity, double?, QQueryOperations>
      logoutLongitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoutLongitude');
    });
  }

  QueryBuilder<DutySessionEntity, String?, QQueryOperations>
      logoutTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoutTime');
    });
  }

  QueryBuilder<DutySessionEntity, int?, QQueryOperations>
      overtimeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overtimeMinutes');
    });
  }

  QueryBuilder<DutySessionEntity, String?, QQueryOperations>
      routeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeName');
    });
  }

  QueryBuilder<DutySessionEntity, double?, QQueryOperations>
      startOdometerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startOdometer');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DutySessionEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<DutySessionEntity, double?, QQueryOperations>
      totalDistanceKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDistanceKm');
    });
  }

  QueryBuilder<DutySessionEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations> userNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userName');
    });
  }

  QueryBuilder<DutySessionEntity, String, QQueryOperations> userRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userRole');
    });
  }

  QueryBuilder<DutySessionEntity, String?, QQueryOperations>
      vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }

  QueryBuilder<DutySessionEntity, String?, QQueryOperations>
      vehicleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleNumber');
    });
  }

  QueryBuilder<DutySessionEntity, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
