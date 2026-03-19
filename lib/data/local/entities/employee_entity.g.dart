// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmployeeEntityCollection on Isar {
  IsarCollection<EmployeeEntity> get employeeEntitys => this.collection();
}

const EmployeeEntitySchema = CollectionSchema(
  name: r'EmployeeEntity',
  id: -565720732203765070,
  properties: {
    r'bankDetails': PropertySchema(
      id: 0,
      name: r'bankDetails',
      type: IsarType.string,
    ),
    r'baseMonthlySalary': PropertySchema(
      id: 1,
      name: r'baseMonthlySalary',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 3,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'department': PropertySchema(
      id: 4,
      name: r'department',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 5,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'employeeId': PropertySchema(
      id: 6,
      name: r'employeeId',
      type: IsarType.string,
    ),
    r'exitDate': PropertySchema(
      id: 7,
      name: r'exitDate',
      type: IsarType.dateTime,
    ),
    r'hourlyRate': PropertySchema(
      id: 8,
      name: r'hourlyRate',
      type: IsarType.double,
    ),
    r'id': PropertySchema(
      id: 9,
      name: r'id',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 10,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 11,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 12,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'joiningDate': PropertySchema(
      id: 13,
      name: r'joiningDate',
      type: IsarType.dateTime,
    ),
    r'lastSynced': PropertySchema(
      id: 14,
      name: r'lastSynced',
      type: IsarType.dateTime,
    ),
    r'linkedUserId': PropertySchema(
      id: 15,
      name: r'linkedUserId',
      type: IsarType.string,
    ),
    r'mobile': PropertySchema(
      id: 16,
      name: r'mobile',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 17,
      name: r'name',
      type: IsarType.string,
    ),
    r'overtimeMultiplier': PropertySchema(
      id: 18,
      name: r'overtimeMultiplier',
      type: IsarType.double,
    ),
    r'paymentMethod': PropertySchema(
      id: 19,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'roleType': PropertySchema(
      id: 20,
      name: r'roleType',
      type: IsarType.string,
    ),
    r'shiftStartHour': PropertySchema(
      id: 21,
      name: r'shiftStartHour',
      type: IsarType.long,
    ),
    r'shiftStartMinute': PropertySchema(
      id: 22,
      name: r'shiftStartMinute',
      type: IsarType.long,
    ),
    r'syncStatus': PropertySchema(
      id: 23,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _EmployeeEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 24,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 25,
      name: r'version',
      type: IsarType.long,
    ),
    r'weeklyOffDay': PropertySchema(
      id: 26,
      name: r'weeklyOffDay',
      type: IsarType.long,
    )
  },
  estimateSize: _employeeEntityEstimateSize,
  serialize: _employeeEntitySerialize,
  deserialize: _employeeEntityDeserialize,
  deserializeProp: _employeeEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'employeeId': IndexSchema(
      id: 1283453093523034672,
      name: r'employeeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'employeeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'roleType': IndexSchema(
      id: 986590105967684657,
      name: r'roleType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'roleType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'linkedUserId': IndexSchema(
      id: -4889812105961105678,
      name: r'linkedUserId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'linkedUserId',
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
  getId: _employeeEntityGetId,
  getLinks: _employeeEntityGetLinks,
  attach: _employeeEntityAttach,
  version: '3.1.0+1',
);

int _employeeEntityEstimateSize(
  EmployeeEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bankDetails;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.department.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.employeeId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.linkedUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.mobile.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.paymentMethod;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.roleType.length * 3;
  return bytesCount;
}

void _employeeEntitySerialize(
  EmployeeEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bankDetails);
  writer.writeDouble(offsets[1], object.baseMonthlySalary);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.deletedAt);
  writer.writeString(offsets[4], object.department);
  writer.writeString(offsets[5], object.deviceId);
  writer.writeString(offsets[6], object.employeeId);
  writer.writeDateTime(offsets[7], object.exitDate);
  writer.writeDouble(offsets[8], object.hourlyRate);
  writer.writeString(offsets[9], object.id);
  writer.writeBool(offsets[10], object.isActive);
  writer.writeBool(offsets[11], object.isDeleted);
  writer.writeBool(offsets[12], object.isSynced);
  writer.writeDateTime(offsets[13], object.joiningDate);
  writer.writeDateTime(offsets[14], object.lastSynced);
  writer.writeString(offsets[15], object.linkedUserId);
  writer.writeString(offsets[16], object.mobile);
  writer.writeString(offsets[17], object.name);
  writer.writeDouble(offsets[18], object.overtimeMultiplier);
  writer.writeString(offsets[19], object.paymentMethod);
  writer.writeString(offsets[20], object.roleType);
  writer.writeLong(offsets[21], object.shiftStartHour);
  writer.writeLong(offsets[22], object.shiftStartMinute);
  writer.writeByte(offsets[23], object.syncStatus.index);
  writer.writeDateTime(offsets[24], object.updatedAt);
  writer.writeLong(offsets[25], object.version);
  writer.writeLong(offsets[26], object.weeklyOffDay);
}

EmployeeEntity _employeeEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmployeeEntity();
  object.bankDetails = reader.readStringOrNull(offsets[0]);
  object.baseMonthlySalary = reader.readDoubleOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.department = reader.readString(offsets[4]);
  object.deviceId = reader.readString(offsets[5]);
  object.employeeId = reader.readString(offsets[6]);
  object.exitDate = reader.readDateTimeOrNull(offsets[7]);
  object.hourlyRate = reader.readDoubleOrNull(offsets[8]);
  object.id = reader.readString(offsets[9]);
  object.isActive = reader.readBool(offsets[10]);
  object.isDeleted = reader.readBool(offsets[11]);
  object.isSynced = reader.readBool(offsets[12]);
  object.joiningDate = reader.readDateTimeOrNull(offsets[13]);
  object.lastSynced = reader.readDateTimeOrNull(offsets[14]);
  object.linkedUserId = reader.readStringOrNull(offsets[15]);
  object.mobile = reader.readString(offsets[16]);
  object.name = reader.readString(offsets[17]);
  object.overtimeMultiplier = reader.readDoubleOrNull(offsets[18]);
  object.paymentMethod = reader.readStringOrNull(offsets[19]);
  object.roleType = reader.readString(offsets[20]);
  object.shiftStartHour = reader.readLongOrNull(offsets[21]);
  object.shiftStartMinute = reader.readLongOrNull(offsets[22]);
  object.syncStatus = _EmployeeEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[23])] ??
      SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[24]);
  object.version = reader.readLong(offsets[25]);
  object.weeklyOffDay = reader.readLong(offsets[26]);
  return object;
}

P _employeeEntityDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readLongOrNull(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (_EmployeeEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 24:
      return (reader.readDateTime(offset)) as P;
    case 25:
      return (reader.readLong(offset)) as P;
    case 26:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EmployeeEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _EmployeeEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _employeeEntityGetId(EmployeeEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _employeeEntityGetLinks(EmployeeEntity object) {
  return [];
}

void _employeeEntityAttach(
    IsarCollection<dynamic> col, Id id, EmployeeEntity object) {}

extension EmployeeEntityByIndex on IsarCollection<EmployeeEntity> {
  Future<EmployeeEntity?> getByEmployeeId(String employeeId) {
    return getByIndex(r'employeeId', [employeeId]);
  }

  EmployeeEntity? getByEmployeeIdSync(String employeeId) {
    return getByIndexSync(r'employeeId', [employeeId]);
  }

  Future<bool> deleteByEmployeeId(String employeeId) {
    return deleteByIndex(r'employeeId', [employeeId]);
  }

  bool deleteByEmployeeIdSync(String employeeId) {
    return deleteByIndexSync(r'employeeId', [employeeId]);
  }

  Future<List<EmployeeEntity?>> getAllByEmployeeId(
      List<String> employeeIdValues) {
    final values = employeeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'employeeId', values);
  }

  List<EmployeeEntity?> getAllByEmployeeIdSync(List<String> employeeIdValues) {
    final values = employeeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'employeeId', values);
  }

  Future<int> deleteAllByEmployeeId(List<String> employeeIdValues) {
    final values = employeeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'employeeId', values);
  }

  int deleteAllByEmployeeIdSync(List<String> employeeIdValues) {
    final values = employeeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'employeeId', values);
  }

  Future<Id> putByEmployeeId(EmployeeEntity object) {
    return putByIndex(r'employeeId', object);
  }

  Id putByEmployeeIdSync(EmployeeEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'employeeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEmployeeId(List<EmployeeEntity> objects) {
    return putAllByIndex(r'employeeId', objects);
  }

  List<Id> putAllByEmployeeIdSync(List<EmployeeEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'employeeId', objects, saveLinks: saveLinks);
  }

  Future<EmployeeEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  EmployeeEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<EmployeeEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<EmployeeEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(EmployeeEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(EmployeeEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<EmployeeEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<EmployeeEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension EmployeeEntityQueryWhereSort
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QWhere> {
  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EmployeeEntityQueryWhere
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QWhereClause> {
  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      employeeIdEqualTo(String employeeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'employeeId',
        value: [employeeId],
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      roleTypeEqualTo(String roleType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'roleType',
        value: [roleType],
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      roleTypeNotEqualTo(String roleType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roleType',
              lower: [],
              upper: [roleType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roleType',
              lower: [roleType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roleType',
              lower: [roleType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roleType',
              lower: [],
              upper: [roleType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      linkedUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkedUserId',
        value: [null],
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      linkedUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'linkedUserId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      linkedUserIdEqualTo(String? linkedUserId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkedUserId',
        value: [linkedUserId],
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause>
      linkedUserIdNotEqualTo(String? linkedUserId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedUserId',
              lower: [],
              upper: [linkedUserId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedUserId',
              lower: [linkedUserId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedUserId',
              lower: [linkedUserId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedUserId',
              lower: [],
              upper: [linkedUserId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterWhereClause> idNotEqualTo(
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

extension EmployeeEntityQueryFilter
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QFilterCondition> {
  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bankDetails',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bankDetails',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bankDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bankDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bankDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bankDetails',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bankDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bankDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bankDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bankDetails',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bankDetails',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      bankDetailsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bankDetails',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      baseMonthlySalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baseMonthlySalary',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      baseMonthlySalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baseMonthlySalary',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      baseMonthlySalaryEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseMonthlySalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      baseMonthlySalaryGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseMonthlySalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      baseMonthlySalaryLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseMonthlySalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      baseMonthlySalaryBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseMonthlySalary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'department',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'department',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      departmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      employeeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      employeeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      employeeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      employeeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      exitDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'exitDate',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      exitDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'exitDate',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      exitDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      exitDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      exitDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      exitDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exitDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      hourlyRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hourlyRate',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      hourlyRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hourlyRate',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      hourlyRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hourlyRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      hourlyRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hourlyRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      hourlyRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hourlyRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      hourlyRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hourlyRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition> idMatches(
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      joiningDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'joiningDate',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      joiningDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'joiningDate',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      joiningDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'joiningDate',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      joiningDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'joiningDate',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      joiningDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'joiningDate',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      joiningDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'joiningDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      lastSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      lastSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      lastSyncedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedUserId',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedUserId',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      linkedUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mobile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mobile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mobile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mobile',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mobile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mobile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mobile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mobile',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mobile',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      mobileIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mobile',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      overtimeMultiplierIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'overtimeMultiplier',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      overtimeMultiplierIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'overtimeMultiplier',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      overtimeMultiplierEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overtimeMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      overtimeMultiplierGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overtimeMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      overtimeMultiplierLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overtimeMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      overtimeMultiplierBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overtimeMultiplier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roleType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roleType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleType',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      roleTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleType',
        value: '',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartHourIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'shiftStartHour',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartHourIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'shiftStartHour',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartHourEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shiftStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartHourGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shiftStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartHourLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shiftStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartHourBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shiftStartHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartMinuteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'shiftStartMinute',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartMinuteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'shiftStartMinute',
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartMinuteEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shiftStartMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartMinuteGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shiftStartMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartMinuteLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shiftStartMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      shiftStartMinuteBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shiftStartMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
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

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      weeklyOffDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyOffDay',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      weeklyOffDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyOffDay',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      weeklyOffDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyOffDay',
        value: value,
      ));
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterFilterCondition>
      weeklyOffDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyOffDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EmployeeEntityQueryObject
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QFilterCondition> {}

extension EmployeeEntityQueryLinks
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QFilterCondition> {}

extension EmployeeEntityQuerySortBy
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QSortBy> {
  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByBankDetails() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankDetails', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByBankDetailsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankDetails', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByBaseMonthlySalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMonthlySalary', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByBaseMonthlySalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMonthlySalary', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByExitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByExitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByHourlyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByHourlyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByJoiningDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joiningDate', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByJoiningDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joiningDate', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByLinkedUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUserId', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByLinkedUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUserId', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByMobile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mobile', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByMobileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mobile', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByOvertimeMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMultiplier', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByOvertimeMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMultiplier', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByRoleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByRoleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByShiftStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartHour', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByShiftStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartHour', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByShiftStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartMinute', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByShiftStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartMinute', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByWeeklyOffDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyOffDay', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      sortByWeeklyOffDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyOffDay', Sort.desc);
    });
  }
}

extension EmployeeEntityQuerySortThenBy
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QSortThenBy> {
  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByBankDetails() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankDetails', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByBankDetailsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankDetails', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByBaseMonthlySalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMonthlySalary', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByBaseMonthlySalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMonthlySalary', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByExitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByExitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByHourlyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByHourlyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hourlyRate', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByJoiningDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joiningDate', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByJoiningDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joiningDate', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByLinkedUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUserId', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByLinkedUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedUserId', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByMobile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mobile', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByMobileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mobile', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByOvertimeMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMultiplier', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByOvertimeMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overtimeMultiplier', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByRoleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByRoleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByShiftStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartHour', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByShiftStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartHour', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByShiftStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartMinute', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByShiftStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStartMinute', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByWeeklyOffDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyOffDay', Sort.asc);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QAfterSortBy>
      thenByWeeklyOffDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyOffDay', Sort.desc);
    });
  }
}

extension EmployeeEntityQueryWhereDistinct
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> {
  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByBankDetails(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bankDetails', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByBaseMonthlySalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseMonthlySalary');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByDepartment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'department', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByEmployeeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByExitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exitDate');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByHourlyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hourlyRate');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByJoiningDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'joiningDate');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSynced');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByLinkedUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByMobile(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mobile', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByOvertimeMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overtimeMultiplier');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByPaymentMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByRoleType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByShiftStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shiftStartHour');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByShiftStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shiftStartMinute');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct> distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }

  QueryBuilder<EmployeeEntity, EmployeeEntity, QDistinct>
      distinctByWeeklyOffDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyOffDay');
    });
  }
}

extension EmployeeEntityQueryProperty
    on QueryBuilder<EmployeeEntity, EmployeeEntity, QQueryProperty> {
  QueryBuilder<EmployeeEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<EmployeeEntity, String?, QQueryOperations>
      bankDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bankDetails');
    });
  }

  QueryBuilder<EmployeeEntity, double?, QQueryOperations>
      baseMonthlySalaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseMonthlySalary');
    });
  }

  QueryBuilder<EmployeeEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EmployeeEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<EmployeeEntity, String, QQueryOperations> departmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'department');
    });
  }

  QueryBuilder<EmployeeEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<EmployeeEntity, String, QQueryOperations> employeeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeId');
    });
  }

  QueryBuilder<EmployeeEntity, DateTime?, QQueryOperations> exitDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exitDate');
    });
  }

  QueryBuilder<EmployeeEntity, double?, QQueryOperations> hourlyRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hourlyRate');
    });
  }

  QueryBuilder<EmployeeEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmployeeEntity, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<EmployeeEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<EmployeeEntity, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<EmployeeEntity, DateTime?, QQueryOperations>
      joiningDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'joiningDate');
    });
  }

  QueryBuilder<EmployeeEntity, DateTime?, QQueryOperations>
      lastSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSynced');
    });
  }

  QueryBuilder<EmployeeEntity, String?, QQueryOperations>
      linkedUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedUserId');
    });
  }

  QueryBuilder<EmployeeEntity, String, QQueryOperations> mobileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mobile');
    });
  }

  QueryBuilder<EmployeeEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<EmployeeEntity, double?, QQueryOperations>
      overtimeMultiplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overtimeMultiplier');
    });
  }

  QueryBuilder<EmployeeEntity, String?, QQueryOperations>
      paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<EmployeeEntity, String, QQueryOperations> roleTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleType');
    });
  }

  QueryBuilder<EmployeeEntity, int?, QQueryOperations>
      shiftStartHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shiftStartHour');
    });
  }

  QueryBuilder<EmployeeEntity, int?, QQueryOperations>
      shiftStartMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shiftStartMinute');
    });
  }

  QueryBuilder<EmployeeEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<EmployeeEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<EmployeeEntity, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }

  QueryBuilder<EmployeeEntity, int, QQueryOperations> weeklyOffDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyOffDay');
    });
  }
}
