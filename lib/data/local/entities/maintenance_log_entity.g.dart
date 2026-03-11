// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_log_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMaintenanceLogEntityCollection on Isar {
  IsarCollection<MaintenanceLogEntity> get maintenanceLogEntitys =>
      this.collection();
}

const MaintenanceLogEntitySchema = CollectionSchema(
  name: r'MaintenanceLogEntity',
  id: 1751803043324165989,
  properties: {
    r'attachments': PropertySchema(
      id: 0,
      name: r'attachments',
      type: IsarType.stringList,
    ),
    r'billNumber': PropertySchema(
      id: 1,
      name: r'billNumber',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 3,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 4,
      name: r'description',
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
    r'items': PropertySchema(
      id: 7,
      name: r'items',
      type: IsarType.objectList,
      target: r'MaintenanceItemEntity',
    ),
    r'labourCost': PropertySchema(
      id: 8,
      name: r'labourCost',
      type: IsarType.double,
    ),
    r'mechanicName': PropertySchema(
      id: 9,
      name: r'mechanicName',
      type: IsarType.string,
    ),
    r'nextServiceDate': PropertySchema(
      id: 10,
      name: r'nextServiceDate',
      type: IsarType.dateTime,
    ),
    r'odometerReading': PropertySchema(
      id: 11,
      name: r'odometerReading',
      type: IsarType.double,
    ),
    r'partsCost': PropertySchema(
      id: 12,
      name: r'partsCost',
      type: IsarType.double,
    ),
    r'paymentMode': PropertySchema(
      id: 13,
      name: r'paymentMode',
      type: IsarType.string,
    ),
    r'serviceDate': PropertySchema(
      id: 14,
      name: r'serviceDate',
      type: IsarType.dateTime,
    ),
    r'syncStatus': PropertySchema(
      id: 15,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _MaintenanceLogEntitysyncStatusEnumValueMap,
    ),
    r'totalCost': PropertySchema(
      id: 16,
      name: r'totalCost',
      type: IsarType.double,
    ),
    r'type': PropertySchema(
      id: 17,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 18,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vehicleId': PropertySchema(
      id: 19,
      name: r'vehicleId',
      type: IsarType.string,
    ),
    r'vehicleNumber': PropertySchema(
      id: 20,
      name: r'vehicleNumber',
      type: IsarType.string,
    ),
    r'vendor': PropertySchema(
      id: 21,
      name: r'vendor',
      type: IsarType.string,
    )
  },
  estimateSize: _maintenanceLogEntityEstimateSize,
  serialize: _maintenanceLogEntitySerialize,
  deserialize: _maintenanceLogEntityDeserialize,
  deserializeProp: _maintenanceLogEntityDeserializeProp,
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
  embeddedSchemas: {r'MaintenanceItemEntity': MaintenanceItemEntitySchema},
  getId: _maintenanceLogEntityGetId,
  getLinks: _maintenanceLogEntityGetLinks,
  attach: _maintenanceLogEntityAttach,
  version: '3.1.0+1',
);

int _maintenanceLogEntityEstimateSize(
  MaintenanceLogEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.attachments;
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
    final value = object.billNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.createdAt.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final list = object.items;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[MaintenanceItemEntity]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += MaintenanceItemEntitySchema.estimateSize(
              value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.mechanicName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.paymentMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.vehicleId.length * 3;
  bytesCount += 3 + object.vehicleNumber.length * 3;
  bytesCount += 3 + object.vendor.length * 3;
  return bytesCount;
}

void _maintenanceLogEntitySerialize(
  MaintenanceLogEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.attachments);
  writer.writeString(offsets[1], object.billNumber);
  writer.writeString(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.deletedAt);
  writer.writeString(offsets[4], object.description);
  writer.writeString(offsets[5], object.id);
  writer.writeBool(offsets[6], object.isDeleted);
  writer.writeObjectList<MaintenanceItemEntity>(
    offsets[7],
    allOffsets,
    MaintenanceItemEntitySchema.serialize,
    object.items,
  );
  writer.writeDouble(offsets[8], object.labourCost);
  writer.writeString(offsets[9], object.mechanicName);
  writer.writeDateTime(offsets[10], object.nextServiceDate);
  writer.writeDouble(offsets[11], object.odometerReading);
  writer.writeDouble(offsets[12], object.partsCost);
  writer.writeString(offsets[13], object.paymentMode);
  writer.writeDateTime(offsets[14], object.serviceDate);
  writer.writeByte(offsets[15], object.syncStatus.index);
  writer.writeDouble(offsets[16], object.totalCost);
  writer.writeString(offsets[17], object.type);
  writer.writeDateTime(offsets[18], object.updatedAt);
  writer.writeString(offsets[19], object.vehicleId);
  writer.writeString(offsets[20], object.vehicleNumber);
  writer.writeString(offsets[21], object.vendor);
}

MaintenanceLogEntity _maintenanceLogEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MaintenanceLogEntity();
  object.attachments = reader.readStringList(offsets[0]);
  object.billNumber = reader.readStringOrNull(offsets[1]);
  object.createdAt = reader.readString(offsets[2]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.description = reader.readString(offsets[4]);
  object.id = reader.readString(offsets[5]);
  object.isDeleted = reader.readBool(offsets[6]);
  object.items = reader.readObjectList<MaintenanceItemEntity>(
    offsets[7],
    MaintenanceItemEntitySchema.deserialize,
    allOffsets,
    MaintenanceItemEntity(),
  );
  object.labourCost = reader.readDoubleOrNull(offsets[8]);
  object.mechanicName = reader.readStringOrNull(offsets[9]);
  object.nextServiceDate = reader.readDateTimeOrNull(offsets[10]);
  object.odometerReading = reader.readDoubleOrNull(offsets[11]);
  object.partsCost = reader.readDoubleOrNull(offsets[12]);
  object.paymentMode = reader.readStringOrNull(offsets[13]);
  object.serviceDate = reader.readDateTime(offsets[14]);
  object.syncStatus = _MaintenanceLogEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[15])] ??
      SyncStatus.pending;
  object.totalCost = reader.readDouble(offsets[16]);
  object.type = reader.readString(offsets[17]);
  object.updatedAt = reader.readDateTime(offsets[18]);
  object.vehicleId = reader.readString(offsets[19]);
  object.vehicleNumber = reader.readString(offsets[20]);
  object.vendor = reader.readString(offsets[21]);
  return object;
}

P _maintenanceLogEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readObjectList<MaintenanceItemEntity>(
        offset,
        MaintenanceItemEntitySchema.deserialize,
        allOffsets,
        MaintenanceItemEntity(),
      )) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (_MaintenanceLogEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDateTime(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MaintenanceLogEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _MaintenanceLogEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _maintenanceLogEntityGetId(MaintenanceLogEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _maintenanceLogEntityGetLinks(
    MaintenanceLogEntity object) {
  return [];
}

void _maintenanceLogEntityAttach(
    IsarCollection<dynamic> col, Id id, MaintenanceLogEntity object) {}

extension MaintenanceLogEntityByIndex on IsarCollection<MaintenanceLogEntity> {
  Future<MaintenanceLogEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  MaintenanceLogEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<MaintenanceLogEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<MaintenanceLogEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(MaintenanceLogEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(MaintenanceLogEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<MaintenanceLogEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<MaintenanceLogEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension MaintenanceLogEntityQueryWhereSort
    on QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QWhere> {
  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MaintenanceLogEntityQueryWhere
    on QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QWhereClause> {
  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
      vehicleIdEqualTo(String vehicleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vehicleId',
        value: [vehicleId],
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterWhereClause>
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

extension MaintenanceLogEntityQueryFilter on QueryBuilder<MaintenanceLogEntity,
    MaintenanceLogEntity, QFilterCondition> {
  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'attachments',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'attachments',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attachments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      attachmentsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      attachmentsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attachments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachments',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attachments',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> attachmentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'billNumber',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'billNumber',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'billNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'billNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      billNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      billNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> billNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtEqualTo(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtStartsWith(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtEndsWith(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      createdAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      createdAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> createdAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsLengthEqualTo(int length) {
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsIsEmpty() {
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsIsNotEmpty() {
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsLengthLessThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsLengthGreaterThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> itemsLengthBetween(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> labourCostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'labourCost',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> labourCostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'labourCost',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> labourCostEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'labourCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> labourCostGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'labourCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> labourCostLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'labourCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> labourCostBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'labourCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mechanicName',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mechanicName',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mechanicName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mechanicName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mechanicName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mechanicName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mechanicName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mechanicName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      mechanicNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mechanicName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      mechanicNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mechanicName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mechanicName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> mechanicNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mechanicName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> nextServiceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextServiceDate',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> nextServiceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextServiceDate',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> nextServiceDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> nextServiceDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> nextServiceDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> nextServiceDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextServiceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> odometerReadingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'odometerReading',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> odometerReadingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'odometerReading',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> odometerReadingEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odometerReading',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> odometerReadingGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'odometerReading',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> odometerReadingLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'odometerReading',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> odometerReadingBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'odometerReading',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> partsCostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partsCost',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> partsCostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partsCost',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> partsCostEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partsCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> partsCostGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partsCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> partsCostLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partsCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> partsCostBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partsCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentMode',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentMode',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      paymentModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      paymentModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMode',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> paymentModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMode',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> serviceDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> serviceDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> serviceDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> serviceDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> totalCostEqualTo(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> totalCostGreaterThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> totalCostLessThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> totalCostBetween(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdEqualTo(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdGreaterThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdLessThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdBetween(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdStartsWith(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdEndsWith(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      vehicleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      vehicleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberEqualTo(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberGreaterThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberLessThan(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberBetween(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberStartsWith(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberEndsWith(
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

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      vehicleNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      vehicleNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vehicleNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vendor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vendor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vendor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vendor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vendor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vendor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      vendorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vendor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      vendorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vendor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vendor',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
      QAfterFilterCondition> vendorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vendor',
        value: '',
      ));
    });
  }
}

extension MaintenanceLogEntityQueryObject on QueryBuilder<MaintenanceLogEntity,
    MaintenanceLogEntity, QFilterCondition> {
  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity,
          QAfterFilterCondition>
      itemsElement(FilterQuery<MaintenanceItemEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension MaintenanceLogEntityQueryLinks on QueryBuilder<MaintenanceLogEntity,
    MaintenanceLogEntity, QFilterCondition> {}

extension MaintenanceLogEntityQuerySortBy
    on QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QSortBy> {
  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByBillNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billNumber', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByBillNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billNumber', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByLabourCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'labourCost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByLabourCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'labourCost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByMechanicName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicName', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByMechanicNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicName', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByNextServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextServiceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByNextServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextServiceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByOdometerReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByPartsCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByPartsCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByPaymentMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMode', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByPaymentModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMode', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByVendor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendor', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      sortByVendorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendor', Sort.desc);
    });
  }
}

extension MaintenanceLogEntityQuerySortThenBy
    on QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QSortThenBy> {
  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByBillNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billNumber', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByBillNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billNumber', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByLabourCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'labourCost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByLabourCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'labourCost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByMechanicName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicName', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByMechanicNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mechanicName', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByNextServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextServiceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByNextServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextServiceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByOdometerReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByPartsCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByPartsCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByPaymentMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMode', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByPaymentModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMode', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByVendor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendor', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QAfterSortBy>
      thenByVendorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vendor', Sort.desc);
    });
  }
}

extension MaintenanceLogEntityQueryWhereDistinct
    on QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct> {
  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByAttachments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachments');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByBillNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByCreatedAt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByLabourCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'labourCost');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByMechanicName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mechanicName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByNextServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextServiceDate');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odometerReading');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByPartsCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partsCost');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByPaymentMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDate');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCost');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByVehicleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByVehicleNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceLogEntity, MaintenanceLogEntity, QDistinct>
      distinctByVendor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vendor', caseSensitive: caseSensitive);
    });
  }
}

extension MaintenanceLogEntityQueryProperty on QueryBuilder<
    MaintenanceLogEntity, MaintenanceLogEntity, QQueryProperty> {
  QueryBuilder<MaintenanceLogEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<MaintenanceLogEntity, List<String>?, QQueryOperations>
      attachmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachments');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String?, QQueryOperations>
      billNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billNumber');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MaintenanceLogEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MaintenanceLogEntity, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<MaintenanceLogEntity, List<MaintenanceItemEntity>?,
      QQueryOperations> itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<MaintenanceLogEntity, double?, QQueryOperations>
      labourCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'labourCost');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String?, QQueryOperations>
      mechanicNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mechanicName');
    });
  }

  QueryBuilder<MaintenanceLogEntity, DateTime?, QQueryOperations>
      nextServiceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextServiceDate');
    });
  }

  QueryBuilder<MaintenanceLogEntity, double?, QQueryOperations>
      odometerReadingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odometerReading');
    });
  }

  QueryBuilder<MaintenanceLogEntity, double?, QQueryOperations>
      partsCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partsCost');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String?, QQueryOperations>
      paymentModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMode');
    });
  }

  QueryBuilder<MaintenanceLogEntity, DateTime, QQueryOperations>
      serviceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDate');
    });
  }

  QueryBuilder<MaintenanceLogEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<MaintenanceLogEntity, double, QQueryOperations>
      totalCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCost');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<MaintenanceLogEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String, QQueryOperations>
      vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String, QQueryOperations>
      vehicleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleNumber');
    });
  }

  QueryBuilder<MaintenanceLogEntity, String, QQueryOperations>
      vendorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vendor');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MaintenanceItemEntitySchema = Schema(
  name: r'MaintenanceItemEntity',
  id: -7570447936879581056,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'partName': PropertySchema(
      id: 1,
      name: r'partName',
      type: IsarType.string,
    ),
    r'price': PropertySchema(
      id: 2,
      name: r'price',
      type: IsarType.double,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.double,
    )
  },
  estimateSize: _maintenanceItemEntityEstimateSize,
  serialize: _maintenanceItemEntitySerialize,
  deserialize: _maintenanceItemEntityDeserialize,
  deserializeProp: _maintenanceItemEntityDeserializeProp,
);

int _maintenanceItemEntityEstimateSize(
  MaintenanceItemEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.partName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _maintenanceItemEntitySerialize(
  MaintenanceItemEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeString(offsets[1], object.partName);
  writer.writeDouble(offsets[2], object.price);
  writer.writeDouble(offsets[3], object.quantity);
}

MaintenanceItemEntity _maintenanceItemEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MaintenanceItemEntity();
  object.description = reader.readStringOrNull(offsets[0]);
  object.partName = reader.readStringOrNull(offsets[1]);
  object.price = reader.readDouble(offsets[2]);
  object.quantity = reader.readDouble(offsets[3]);
  return object;
}

P _maintenanceItemEntityDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MaintenanceItemEntityQueryFilter on QueryBuilder<
    MaintenanceItemEntity, MaintenanceItemEntity, QFilterCondition> {
  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partName',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partName',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
          QAfterFilterCondition>
      partNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
          QAfterFilterCondition>
      partNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> partNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> priceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> priceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> priceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> priceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'price',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> quantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> quantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> quantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceItemEntity, MaintenanceItemEntity,
      QAfterFilterCondition> quantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MaintenanceItemEntityQueryObject on QueryBuilder<
    MaintenanceItemEntity, MaintenanceItemEntity, QFilterCondition> {}
