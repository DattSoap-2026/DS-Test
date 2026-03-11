// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserEntityCollection on Isar {
  IsarCollection<UserEntity> get userEntitys => this.collection();
}

const UserEntitySchema = CollectionSchema(
  name: r'UserEntity',
  id: 965090076791382600,
  properties: {
    r'allocatedStockJson': PropertySchema(
      id: 0,
      name: r'allocatedStockJson',
      type: IsarType.string,
    ),
    r'assignedBaseProductId': PropertySchema(
      id: 1,
      name: r'assignedBaseProductId',
      type: IsarType.string,
    ),
    r'assignedBaseProductName': PropertySchema(
      id: 2,
      name: r'assignedBaseProductName',
      type: IsarType.string,
    ),
    r'assignedBhatti': PropertySchema(
      id: 3,
      name: r'assignedBhatti',
      type: IsarType.string,
    ),
    r'assignedDeliveryRoute': PropertySchema(
      id: 4,
      name: r'assignedDeliveryRoute',
      type: IsarType.string,
    ),
    r'assignedRoutes': PropertySchema(
      id: 5,
      name: r'assignedRoutes',
      type: IsarType.stringList,
    ),
    r'assignedSalesRoute': PropertySchema(
      id: 6,
      name: r'assignedSalesRoute',
      type: IsarType.string,
    ),
    r'assignedVehicleId': PropertySchema(
      id: 7,
      name: r'assignedVehicleId',
      type: IsarType.string,
    ),
    r'assignedVehicleName': PropertySchema(
      id: 8,
      name: r'assignedVehicleName',
      type: IsarType.string,
    ),
    r'assignedVehicleNumber': PropertySchema(
      id: 9,
      name: r'assignedVehicleNumber',
      type: IsarType.string,
    ),
    r'assignedWarehouseId': PropertySchema(
      id: 10,
      name: r'assignedWarehouseId',
      type: IsarType.string,
    ),
    r'assignedWarehouseName': PropertySchema(
      id: 11,
      name: r'assignedWarehouseName',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 12,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'department': PropertySchema(
      id: 13,
      name: r'department',
      type: IsarType.string,
    ),
    r'departmentsJson': PropertySchema(
      id: 14,
      name: r'departmentsJson',
      type: IsarType.string,
    ),
    r'designation': PropertySchema(
      id: 15,
      name: r'designation',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 16,
      name: r'email',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 17,
      name: r'id',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 18,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 19,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 20,
      name: r'name',
      type: IsarType.string,
    ),
    r'passwordHash': PropertySchema(
      id: 21,
      name: r'passwordHash',
      type: IsarType.string,
    ),
    r'permissions': PropertySchema(
      id: 22,
      name: r'permissions',
      type: IsarType.stringList,
    ),
    r'phone': PropertySchema(
      id: 23,
      name: r'phone',
      type: IsarType.string,
    ),
    r'role': PropertySchema(
      id: 24,
      name: r'role',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 25,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 26,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _UserEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 27,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _userEntityEstimateSize,
  serialize: _userEntitySerialize,
  deserialize: _userEntityDeserialize,
  deserializeProp: _userEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
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
  getId: _userEntityGetId,
  getLinks: _userEntityGetLinks,
  attach: _userEntityAttach,
  version: '3.1.0+1',
);

int _userEntityEstimateSize(
  UserEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.allocatedStockJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedBaseProductId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedBaseProductName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedBhatti;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedDeliveryRoute;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.assignedRoutes;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.assignedSalesRoute;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedVehicleId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedVehicleName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedVehicleNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedWarehouseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignedWarehouseName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.department;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.departmentsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.designation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.passwordHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.permissions;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.phone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.role;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userEntitySerialize(
  UserEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.allocatedStockJson);
  writer.writeString(offsets[1], object.assignedBaseProductId);
  writer.writeString(offsets[2], object.assignedBaseProductName);
  writer.writeString(offsets[3], object.assignedBhatti);
  writer.writeString(offsets[4], object.assignedDeliveryRoute);
  writer.writeStringList(offsets[5], object.assignedRoutes);
  writer.writeString(offsets[6], object.assignedSalesRoute);
  writer.writeString(offsets[7], object.assignedVehicleId);
  writer.writeString(offsets[8], object.assignedVehicleName);
  writer.writeString(offsets[9], object.assignedVehicleNumber);
  writer.writeString(offsets[10], object.assignedWarehouseId);
  writer.writeString(offsets[11], object.assignedWarehouseName);
  writer.writeDateTime(offsets[12], object.deletedAt);
  writer.writeString(offsets[13], object.department);
  writer.writeString(offsets[14], object.departmentsJson);
  writer.writeString(offsets[15], object.designation);
  writer.writeString(offsets[16], object.email);
  writer.writeString(offsets[17], object.id);
  writer.writeBool(offsets[18], object.isActive);
  writer.writeBool(offsets[19], object.isDeleted);
  writer.writeString(offsets[20], object.name);
  writer.writeString(offsets[21], object.passwordHash);
  writer.writeStringList(offsets[22], object.permissions);
  writer.writeString(offsets[23], object.phone);
  writer.writeString(offsets[24], object.role);
  writer.writeString(offsets[25], object.status);
  writer.writeByte(offsets[26], object.syncStatus.index);
  writer.writeDateTime(offsets[27], object.updatedAt);
}

UserEntity _userEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserEntity();
  object.allocatedStockJson = reader.readStringOrNull(offsets[0]);
  object.assignedBaseProductId = reader.readStringOrNull(offsets[1]);
  object.assignedBaseProductName = reader.readStringOrNull(offsets[2]);
  object.assignedBhatti = reader.readStringOrNull(offsets[3]);
  object.assignedDeliveryRoute = reader.readStringOrNull(offsets[4]);
  object.assignedRoutes = reader.readStringList(offsets[5]);
  object.assignedSalesRoute = reader.readStringOrNull(offsets[6]);
  object.assignedVehicleId = reader.readStringOrNull(offsets[7]);
  object.assignedVehicleName = reader.readStringOrNull(offsets[8]);
  object.assignedVehicleNumber = reader.readStringOrNull(offsets[9]);
  object.assignedWarehouseId = reader.readStringOrNull(offsets[10]);
  object.assignedWarehouseName = reader.readStringOrNull(offsets[11]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[12]);
  object.department = reader.readStringOrNull(offsets[13]);
  object.departmentsJson = reader.readStringOrNull(offsets[14]);
  object.designation = reader.readStringOrNull(offsets[15]);
  object.email = reader.readStringOrNull(offsets[16]);
  object.id = reader.readString(offsets[17]);
  object.isActive = reader.readBool(offsets[18]);
  object.isDeleted = reader.readBool(offsets[19]);
  object.name = reader.readStringOrNull(offsets[20]);
  object.passwordHash = reader.readStringOrNull(offsets[21]);
  object.permissions = reader.readStringList(offsets[22]);
  object.phone = reader.readStringOrNull(offsets[23]);
  object.role = reader.readStringOrNull(offsets[24]);
  object.status = reader.readStringOrNull(offsets[25]);
  object.syncStatus =
      _UserEntitysyncStatusValueEnumMap[reader.readByteOrNull(offsets[26])] ??
          SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[27]);
  return object;
}

P _userEntityDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringList(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (_UserEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 27:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _UserEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _userEntityGetId(UserEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _userEntityGetLinks(UserEntity object) {
  return [];
}

void _userEntityAttach(IsarCollection<dynamic> col, Id id, UserEntity object) {}

extension UserEntityByIndex on IsarCollection<UserEntity> {
  Future<UserEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  UserEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<UserEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<UserEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(UserEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(UserEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<UserEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<UserEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension UserEntityQueryWhereSort
    on QueryBuilder<UserEntity, UserEntity, QWhere> {
  QueryBuilder<UserEntity, UserEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserEntityQueryWhere
    on QueryBuilder<UserEntity, UserEntity, QWhereClause> {
  QueryBuilder<UserEntity, UserEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
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

  QueryBuilder<UserEntity, UserEntity, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<UserEntity, UserEntity, QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterWhereClause> idNotEqualTo(
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

extension UserEntityQueryFilter
    on QueryBuilder<UserEntity, UserEntity, QFilterCondition> {
  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'allocatedStockJson',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'allocatedStockJson',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allocatedStockJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allocatedStockJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allocatedStockJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allocatedStockJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'allocatedStockJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'allocatedStockJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'allocatedStockJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'allocatedStockJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allocatedStockJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      allocatedStockJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'allocatedStockJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedBaseProductId',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedBaseProductId',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBaseProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedBaseProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedBaseProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedBaseProductId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedBaseProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedBaseProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedBaseProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedBaseProductId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBaseProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedBaseProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedBaseProductName',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedBaseProductName',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBaseProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedBaseProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedBaseProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedBaseProductName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedBaseProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedBaseProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedBaseProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedBaseProductName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBaseProductName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBaseProductNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedBaseProductName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedBhatti',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedBhatti',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBhatti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedBhatti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedBhatti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedBhatti',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedBhatti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedBhatti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedBhatti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedBhatti',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBhatti',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedBhattiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedBhatti',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedDeliveryRoute',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedDeliveryRoute',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedDeliveryRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedDeliveryRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedDeliveryRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedDeliveryRoute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedDeliveryRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedDeliveryRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedDeliveryRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedDeliveryRoute',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedDeliveryRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedDeliveryRouteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedDeliveryRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedRoutes',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedRoutes',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedRoutes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedRoutes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedRoutes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedRoutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedRoutes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedRoutes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedRoutes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedRoutes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedRoutes',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedRoutes',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedRoutes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedRoutes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedRoutes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedRoutes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedRoutes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedRoutesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedRoutes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedSalesRoute',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedSalesRoute',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedSalesRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedSalesRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedSalesRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedSalesRoute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedSalesRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedSalesRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedSalesRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedSalesRoute',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedSalesRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedSalesRouteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedSalesRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedVehicleId',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedVehicleId',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedVehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedVehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedVehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedVehicleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedVehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedVehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedVehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedVehicleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedVehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedVehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedVehicleName',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedVehicleName',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedVehicleName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedVehicleName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedVehicleName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedVehicleName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedVehicleName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedVehicleName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedVehicleName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedVehicleName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedVehicleName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedVehicleName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedVehicleNumber',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedVehicleNumber',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedVehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedVehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedVehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedVehicleNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedVehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedVehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedVehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedVehicleNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedVehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedVehicleNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedVehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedWarehouseId',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedWarehouseId',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedWarehouseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedWarehouseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedWarehouseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedWarehouseId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedWarehouseId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedWarehouseName',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedWarehouseName',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedWarehouseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedWarehouseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedWarehouseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedWarehouseName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedWarehouseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedWarehouseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedWarehouseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedWarehouseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedWarehouseName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      assignedWarehouseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedWarehouseName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> deletedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> deletedAtLessThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> deletedAtBetween(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'department',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'department',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> departmentEqualTo(
    String? value, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentGreaterThan(
    String? value, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentLessThan(
    String? value, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> departmentBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> departmentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'department',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'departmentsJson',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'departmentsJson',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      departmentsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'designation',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'designation',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'designation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'designation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'designation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'designation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'designation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'designation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'designation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'designation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'designation',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      designationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'designation',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idContains(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idMatches(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> isDeletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameContains(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'passwordHash',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'passwordHash',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'passwordHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'passwordHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'passwordHash',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      passwordHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'passwordHash',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'permissions',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'permissions',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permissions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permissions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissions',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permissions',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      permissionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'role',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'role',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'role',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> roleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusEqualTo(
    String? value, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusGreaterThan(
    String? value, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusLessThan(
    String? value, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> syncStatusEqualTo(
      SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> syncStatusBetween(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition>
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<UserEntity, UserEntity, QAfterFilterCondition> updatedAtBetween(
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

extension UserEntityQueryObject
    on QueryBuilder<UserEntity, UserEntity, QFilterCondition> {}

extension UserEntityQueryLinks
    on QueryBuilder<UserEntity, UserEntity, QFilterCondition> {}

extension UserEntityQuerySortBy
    on QueryBuilder<UserEntity, UserEntity, QSortBy> {
  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAllocatedStockJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocatedStockJson', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAllocatedStockJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocatedStockJson', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedBaseProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductId', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedBaseProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductId', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedBaseProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductName', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedBaseProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductName', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByAssignedBhatti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBhatti', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedBhattiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBhatti', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedDeliveryRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedDeliveryRoute', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedDeliveryRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedDeliveryRoute', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedSalesRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedSalesRoute', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedSalesRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedSalesRoute', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByAssignedVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleId', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleId', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedVehicleName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleName', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedVehicleNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleName', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedWarehouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseId', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedWarehouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseId', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedWarehouseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseName', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByAssignedWarehouseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseName', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByDepartmentsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentsJson', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      sortByDepartmentsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentsJson', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByDesignation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'designation', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByDesignationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'designation', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByPasswordHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByPasswordHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UserEntityQuerySortThenBy
    on QueryBuilder<UserEntity, UserEntity, QSortThenBy> {
  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAllocatedStockJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocatedStockJson', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAllocatedStockJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocatedStockJson', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedBaseProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductId', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedBaseProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductId', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedBaseProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductName', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedBaseProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBaseProductName', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByAssignedBhatti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBhatti', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedBhattiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBhatti', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedDeliveryRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedDeliveryRoute', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedDeliveryRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedDeliveryRoute', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedSalesRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedSalesRoute', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedSalesRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedSalesRoute', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByAssignedVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleId', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleId', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedVehicleName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleName', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedVehicleNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleName', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedVehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedWarehouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseId', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedWarehouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseId', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedWarehouseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseName', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByAssignedWarehouseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedWarehouseName', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByDepartmentsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentsJson', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy>
      thenByDepartmentsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentsJson', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByDesignation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'designation', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByDesignationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'designation', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByPasswordHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByPasswordHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UserEntityQueryWhereDistinct
    on QueryBuilder<UserEntity, UserEntity, QDistinct> {
  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByAllocatedStockJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allocatedStockJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct>
      distinctByAssignedBaseProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedBaseProductId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct>
      distinctByAssignedBaseProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedBaseProductName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByAssignedBhatti(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedBhatti',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct>
      distinctByAssignedDeliveryRoute({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedDeliveryRoute',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByAssignedRoutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedRoutes');
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByAssignedSalesRoute(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedSalesRoute',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByAssignedVehicleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedVehicleId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByAssignedVehicleName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedVehicleName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct>
      distinctByAssignedVehicleNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedVehicleNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByAssignedWarehouseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedWarehouseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct>
      distinctByAssignedWarehouseName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedWarehouseName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByDepartment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'department', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByDepartmentsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByDesignation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'designation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByPasswordHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'passwordHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByPermissions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissions');
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByRole(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<UserEntity, UserEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension UserEntityQueryProperty
    on QueryBuilder<UserEntity, UserEntity, QQueryProperty> {
  QueryBuilder<UserEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      allocatedStockJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allocatedStockJson');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedBaseProductIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedBaseProductId');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedBaseProductNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedBaseProductName');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> assignedBhattiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedBhatti');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedDeliveryRouteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedDeliveryRoute');
    });
  }

  QueryBuilder<UserEntity, List<String>?, QQueryOperations>
      assignedRoutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedRoutes');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedSalesRouteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedSalesRoute');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedVehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedVehicleId');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedVehicleNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedVehicleName');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedVehicleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedVehicleNumber');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedWarehouseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedWarehouseId');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      assignedWarehouseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedWarehouseName');
    });
  }

  QueryBuilder<UserEntity, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> departmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'department');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations>
      departmentsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentsJson');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> designationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'designation');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<UserEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserEntity, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<UserEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> passwordHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'passwordHash');
    });
  }

  QueryBuilder<UserEntity, List<String>?, QQueryOperations>
      permissionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissions');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }

  QueryBuilder<UserEntity, String?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<UserEntity, SyncStatus, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<UserEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
