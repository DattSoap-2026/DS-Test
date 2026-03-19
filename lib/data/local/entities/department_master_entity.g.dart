// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_master_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDepartmentMasterEntityCollection on Isar {
  IsarCollection<DepartmentMasterEntity> get departmentMasterEntitys =>
      this.collection();
}

const DepartmentMasterEntitySchema = CollectionSchema(
  name: r'DepartmentMasterEntity',
  id: -2157774430008979992,
  properties: {
    r'deletedAt': PropertySchema(
      id: 0,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'departmentCode': PropertySchema(
      id: 1,
      name: r'departmentCode',
      type: IsarType.string,
    ),
    r'departmentId': PropertySchema(
      id: 2,
      name: r'departmentId',
      type: IsarType.string,
    ),
    r'departmentName': PropertySchema(
      id: 3,
      name: r'departmentName',
      type: IsarType.string,
    ),
    r'departmentType': PropertySchema(
      id: 4,
      name: r'departmentType',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 5,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 6,
      name: r'id',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 7,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 8,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isProductionDepartment': PropertySchema(
      id: 9,
      name: r'isProductionDepartment',
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
    r'sourceWarehouseId': PropertySchema(
      id: 12,
      name: r'sourceWarehouseId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 13,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _DepartmentMasterEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 15,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _departmentMasterEntityEstimateSize,
  serialize: _departmentMasterEntitySerialize,
  deserialize: _departmentMasterEntityDeserialize,
  deserializeProp: _departmentMasterEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'departmentCode': IndexSchema(
      id: 8798453152404992556,
      name: r'departmentCode',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'departmentCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'departmentName': IndexSchema(
      id: -4995946204002413617,
      name: r'departmentName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'departmentName',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'departmentType': IndexSchema(
      id: 3710025811377095739,
      name: r'departmentType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'departmentType',
          type: IndexType.hash,
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
  getId: _departmentMasterEntityGetId,
  getLinks: _departmentMasterEntityGetLinks,
  attach: _departmentMasterEntityAttach,
  version: '3.1.0+1',
);

int _departmentMasterEntityEstimateSize(
  DepartmentMasterEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.departmentCode.length * 3;
  bytesCount += 3 + object.departmentId.length * 3;
  bytesCount += 3 + object.departmentName.length * 3;
  bytesCount += 3 + object.departmentType.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.sourceWarehouseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _departmentMasterEntitySerialize(
  DepartmentMasterEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.deletedAt);
  writer.writeString(offsets[1], object.departmentCode);
  writer.writeString(offsets[2], object.departmentId);
  writer.writeString(offsets[3], object.departmentName);
  writer.writeString(offsets[4], object.departmentType);
  writer.writeString(offsets[5], object.deviceId);
  writer.writeString(offsets[6], object.id);
  writer.writeBool(offsets[7], object.isActive);
  writer.writeBool(offsets[8], object.isDeleted);
  writer.writeBool(offsets[9], object.isProductionDepartment);
  writer.writeBool(offsets[10], object.isSynced);
  writer.writeDateTime(offsets[11], object.lastSynced);
  writer.writeString(offsets[12], object.sourceWarehouseId);
  writer.writeByte(offsets[13], object.syncStatus.index);
  writer.writeDateTime(offsets[14], object.updatedAt);
  writer.writeLong(offsets[15], object.version);
}

DepartmentMasterEntity _departmentMasterEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DepartmentMasterEntity();
  object.deletedAt = reader.readDateTimeOrNull(offsets[0]);
  object.departmentCode = reader.readString(offsets[1]);
  object.departmentId = reader.readString(offsets[2]);
  object.departmentName = reader.readString(offsets[3]);
  object.departmentType = reader.readString(offsets[4]);
  object.deviceId = reader.readString(offsets[5]);
  object.id = reader.readString(offsets[6]);
  object.isActive = reader.readBool(offsets[7]);
  object.isDeleted = reader.readBool(offsets[8]);
  object.isProductionDepartment = reader.readBool(offsets[9]);
  object.isSynced = reader.readBool(offsets[10]);
  object.lastSynced = reader.readDateTimeOrNull(offsets[11]);
  object.sourceWarehouseId = reader.readStringOrNull(offsets[12]);
  object.syncStatus = _DepartmentMasterEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[13])] ??
      SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[14]);
  object.version = reader.readLong(offsets[15]);
  return object;
}

P _departmentMasterEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (_DepartmentMasterEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DepartmentMasterEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _DepartmentMasterEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _departmentMasterEntityGetId(DepartmentMasterEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _departmentMasterEntityGetLinks(
    DepartmentMasterEntity object) {
  return [];
}

void _departmentMasterEntityAttach(
    IsarCollection<dynamic> col, Id id, DepartmentMasterEntity object) {}

extension DepartmentMasterEntityByIndex
    on IsarCollection<DepartmentMasterEntity> {
  Future<DepartmentMasterEntity?> getByDepartmentCode(String departmentCode) {
    return getByIndex(r'departmentCode', [departmentCode]);
  }

  DepartmentMasterEntity? getByDepartmentCodeSync(String departmentCode) {
    return getByIndexSync(r'departmentCode', [departmentCode]);
  }

  Future<bool> deleteByDepartmentCode(String departmentCode) {
    return deleteByIndex(r'departmentCode', [departmentCode]);
  }

  bool deleteByDepartmentCodeSync(String departmentCode) {
    return deleteByIndexSync(r'departmentCode', [departmentCode]);
  }

  Future<List<DepartmentMasterEntity?>> getAllByDepartmentCode(
      List<String> departmentCodeValues) {
    final values = departmentCodeValues.map((e) => [e]).toList();
    return getAllByIndex(r'departmentCode', values);
  }

  List<DepartmentMasterEntity?> getAllByDepartmentCodeSync(
      List<String> departmentCodeValues) {
    final values = departmentCodeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'departmentCode', values);
  }

  Future<int> deleteAllByDepartmentCode(List<String> departmentCodeValues) {
    final values = departmentCodeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'departmentCode', values);
  }

  int deleteAllByDepartmentCodeSync(List<String> departmentCodeValues) {
    final values = departmentCodeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'departmentCode', values);
  }

  Future<Id> putByDepartmentCode(DepartmentMasterEntity object) {
    return putByIndex(r'departmentCode', object);
  }

  Id putByDepartmentCodeSync(DepartmentMasterEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'departmentCode', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDepartmentCode(
      List<DepartmentMasterEntity> objects) {
    return putAllByIndex(r'departmentCode', objects);
  }

  List<Id> putAllByDepartmentCodeSync(List<DepartmentMasterEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'departmentCode', objects, saveLinks: saveLinks);
  }

  Future<DepartmentMasterEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  DepartmentMasterEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<DepartmentMasterEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<DepartmentMasterEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(DepartmentMasterEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(DepartmentMasterEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<DepartmentMasterEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<DepartmentMasterEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension DepartmentMasterEntityQueryWhereSort
    on QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QWhere> {
  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DepartmentMasterEntityQueryWhere on QueryBuilder<
    DepartmentMasterEntity, DepartmentMasterEntity, QWhereClause> {
  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> departmentCodeEqualTo(String departmentCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'departmentCode',
        value: [departmentCode],
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> departmentCodeNotEqualTo(String departmentCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentCode',
              lower: [],
              upper: [departmentCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentCode',
              lower: [departmentCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentCode',
              lower: [departmentCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentCode',
              lower: [],
              upper: [departmentCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> departmentNameEqualTo(String departmentName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'departmentName',
        value: [departmentName],
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> departmentNameNotEqualTo(String departmentName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentName',
              lower: [],
              upper: [departmentName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentName',
              lower: [departmentName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentName',
              lower: [departmentName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentName',
              lower: [],
              upper: [departmentName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> departmentTypeEqualTo(String departmentType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'departmentType',
        value: [departmentType],
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> departmentTypeNotEqualTo(String departmentType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentType',
              lower: [],
              upper: [departmentType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentType',
              lower: [departmentType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentType',
              lower: [departmentType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'departmentType',
              lower: [],
              upper: [departmentType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

extension DepartmentMasterEntityQueryFilter on QueryBuilder<
    DepartmentMasterEntity, DepartmentMasterEntity, QFilterCondition> {
  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentCode',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentCode',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentName',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentName',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      departmentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentType',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> departmentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentType',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> isProductionDepartmentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isProductionDepartment',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> lastSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> lastSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> lastSyncedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceWarehouseId',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceWarehouseId',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceWarehouseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      sourceWarehouseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
          QAfterFilterCondition>
      sourceWarehouseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceWarehouseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceWarehouseId',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> sourceWarehouseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceWarehouseId',
        value: '',
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
      QAfterFilterCondition> versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity,
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

extension DepartmentMasterEntityQueryObject on QueryBuilder<
    DepartmentMasterEntity, DepartmentMasterEntity, QFilterCondition> {}

extension DepartmentMasterEntityQueryLinks on QueryBuilder<
    DepartmentMasterEntity, DepartmentMasterEntity, QFilterCondition> {}

extension DepartmentMasterEntityQuerySortBy
    on QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QSortBy> {
  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentCode', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentCode', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentType', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDepartmentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentType', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsProductionDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProductionDepartment', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsProductionDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProductionDepartment', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortBySourceWarehouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceWarehouseId', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortBySourceWarehouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceWarehouseId', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension DepartmentMasterEntityQuerySortThenBy on QueryBuilder<
    DepartmentMasterEntity, DepartmentMasterEntity, QSortThenBy> {
  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentCode', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentCode', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentType', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDepartmentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentType', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsProductionDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProductionDepartment', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsProductionDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProductionDepartment', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenBySourceWarehouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceWarehouseId', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenBySourceWarehouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceWarehouseId', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension DepartmentMasterEntityQueryWhereDistinct
    on QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct> {
  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByDepartmentCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentCode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByDepartmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByDepartmentName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByDepartmentType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByIsProductionDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isProductionDepartment');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSynced');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctBySourceWarehouseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceWarehouseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DepartmentMasterEntity, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension DepartmentMasterEntityQueryProperty on QueryBuilder<
    DepartmentMasterEntity, DepartmentMasterEntity, QQueryProperty> {
  QueryBuilder<DepartmentMasterEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<DepartmentMasterEntity, String, QQueryOperations>
      departmentCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentCode');
    });
  }

  QueryBuilder<DepartmentMasterEntity, String, QQueryOperations>
      departmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentId');
    });
  }

  QueryBuilder<DepartmentMasterEntity, String, QQueryOperations>
      departmentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentName');
    });
  }

  QueryBuilder<DepartmentMasterEntity, String, QQueryOperations>
      departmentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentType');
    });
  }

  QueryBuilder<DepartmentMasterEntity, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<DepartmentMasterEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DepartmentMasterEntity, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<DepartmentMasterEntity, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<DepartmentMasterEntity, bool, QQueryOperations>
      isProductionDepartmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isProductionDepartment');
    });
  }

  QueryBuilder<DepartmentMasterEntity, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DateTime?, QQueryOperations>
      lastSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSynced');
    });
  }

  QueryBuilder<DepartmentMasterEntity, String?, QQueryOperations>
      sourceWarehouseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceWarehouseId');
    });
  }

  QueryBuilder<DepartmentMasterEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<DepartmentMasterEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<DepartmentMasterEntity, int, QQueryOperations>
      versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
