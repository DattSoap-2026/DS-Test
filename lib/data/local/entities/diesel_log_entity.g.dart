// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diesel_log_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDieselLogEntityCollection on Isar {
  IsarCollection<DieselLogEntity> get dieselLogEntitys => this.collection();
}

const DieselLogEntitySchema = CollectionSchema(
  name: r'DieselLogEntity',
  id: -198217420104676917,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.string,
    ),
    r'createdBy': PropertySchema(
      id: 1,
      name: r'createdBy',
      type: IsarType.string,
    ),
    r'cycleDistance': PropertySchema(
      id: 2,
      name: r'cycleDistance',
      type: IsarType.double,
    ),
    r'cycleEfficiency': PropertySchema(
      id: 3,
      name: r'cycleEfficiency',
      type: IsarType.double,
    ),
    r'cycleFuelUsed': PropertySchema(
      id: 4,
      name: r'cycleFuelUsed',
      type: IsarType.double,
    ),
    r'deletedAt': PropertySchema(
      id: 5,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'distance': PropertySchema(
      id: 6,
      name: r'distance',
      type: IsarType.double,
    ),
    r'driverName': PropertySchema(
      id: 7,
      name: r'driverName',
      type: IsarType.string,
    ),
    r'fillDate': PropertySchema(
      id: 8,
      name: r'fillDate',
      type: IsarType.dateTime,
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
    r'journeyFrom': PropertySchema(
      id: 11,
      name: r'journeyFrom',
      type: IsarType.string,
    ),
    r'journeyTo': PropertySchema(
      id: 12,
      name: r'journeyTo',
      type: IsarType.string,
    ),
    r'liters': PropertySchema(
      id: 13,
      name: r'liters',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 14,
      name: r'notes',
      type: IsarType.string,
    ),
    r'odometerReading': PropertySchema(
      id: 15,
      name: r'odometerReading',
      type: IsarType.double,
    ),
    r'originalPenaltyAmount': PropertySchema(
      id: 16,
      name: r'originalPenaltyAmount',
      type: IsarType.double,
    ),
    r'overriddenBy': PropertySchema(
      id: 17,
      name: r'overriddenBy',
      type: IsarType.string,
    ),
    r'overrideReason': PropertySchema(
      id: 18,
      name: r'overrideReason',
      type: IsarType.string,
    ),
    r'penaltyAmount': PropertySchema(
      id: 19,
      name: r'penaltyAmount',
      type: IsarType.double,
    ),
    r'penaltyOverridden': PropertySchema(
      id: 20,
      name: r'penaltyOverridden',
      type: IsarType.bool,
    ),
    r'rate': PropertySchema(
      id: 21,
      name: r'rate',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 22,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 23,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _DieselLogEntitysyncStatusEnumValueMap,
    ),
    r'tankFull': PropertySchema(
      id: 24,
      name: r'tankFull',
      type: IsarType.bool,
    ),
    r'totalCost': PropertySchema(
      id: 25,
      name: r'totalCost',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 26,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vehicleId': PropertySchema(
      id: 27,
      name: r'vehicleId',
      type: IsarType.string,
    ),
    r'vehicleNumber': PropertySchema(
      id: 28,
      name: r'vehicleNumber',
      type: IsarType.string,
    )
  },
  estimateSize: _dieselLogEntityEstimateSize,
  serialize: _dieselLogEntitySerialize,
  deserialize: _dieselLogEntityDeserialize,
  deserializeProp: _dieselLogEntityDeserializeProp,
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
    r'fillDate': IndexSchema(
      id: 2461768064851653161,
      name: r'fillDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fillDate',
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
  getId: _dieselLogEntityGetId,
  getLinks: _dieselLogEntityGetLinks,
  attach: _dieselLogEntityAttach,
  version: '3.1.0+1',
);

int _dieselLogEntityEstimateSize(
  DieselLogEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.createdAt.length * 3;
  {
    final value = object.createdBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.driverName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.journeyFrom;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.journeyTo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.overriddenBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.overrideReason;
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
  bytesCount += 3 + object.vehicleId.length * 3;
  bytesCount += 3 + object.vehicleNumber.length * 3;
  return bytesCount;
}

void _dieselLogEntitySerialize(
  DieselLogEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.createdBy);
  writer.writeDouble(offsets[2], object.cycleDistance);
  writer.writeDouble(offsets[3], object.cycleEfficiency);
  writer.writeDouble(offsets[4], object.cycleFuelUsed);
  writer.writeDateTime(offsets[5], object.deletedAt);
  writer.writeDouble(offsets[6], object.distance);
  writer.writeString(offsets[7], object.driverName);
  writer.writeDateTime(offsets[8], object.fillDate);
  writer.writeString(offsets[9], object.id);
  writer.writeBool(offsets[10], object.isDeleted);
  writer.writeString(offsets[11], object.journeyFrom);
  writer.writeString(offsets[12], object.journeyTo);
  writer.writeDouble(offsets[13], object.liters);
  writer.writeString(offsets[14], object.notes);
  writer.writeDouble(offsets[15], object.odometerReading);
  writer.writeDouble(offsets[16], object.originalPenaltyAmount);
  writer.writeString(offsets[17], object.overriddenBy);
  writer.writeString(offsets[18], object.overrideReason);
  writer.writeDouble(offsets[19], object.penaltyAmount);
  writer.writeBool(offsets[20], object.penaltyOverridden);
  writer.writeDouble(offsets[21], object.rate);
  writer.writeString(offsets[22], object.status);
  writer.writeByte(offsets[23], object.syncStatus.index);
  writer.writeBool(offsets[24], object.tankFull);
  writer.writeDouble(offsets[25], object.totalCost);
  writer.writeDateTime(offsets[26], object.updatedAt);
  writer.writeString(offsets[27], object.vehicleId);
  writer.writeString(offsets[28], object.vehicleNumber);
}

DieselLogEntity _dieselLogEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DieselLogEntity();
  object.createdAt = reader.readString(offsets[0]);
  object.createdBy = reader.readStringOrNull(offsets[1]);
  object.cycleDistance = reader.readDoubleOrNull(offsets[2]);
  object.cycleEfficiency = reader.readDoubleOrNull(offsets[3]);
  object.cycleFuelUsed = reader.readDoubleOrNull(offsets[4]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[5]);
  object.distance = reader.readDoubleOrNull(offsets[6]);
  object.driverName = reader.readStringOrNull(offsets[7]);
  object.fillDate = reader.readDateTime(offsets[8]);
  object.id = reader.readString(offsets[9]);
  object.isDeleted = reader.readBool(offsets[10]);
  object.journeyFrom = reader.readStringOrNull(offsets[11]);
  object.journeyTo = reader.readStringOrNull(offsets[12]);
  object.liters = reader.readDouble(offsets[13]);
  object.notes = reader.readStringOrNull(offsets[14]);
  object.odometerReading = reader.readDouble(offsets[15]);
  object.originalPenaltyAmount = reader.readDoubleOrNull(offsets[16]);
  object.overriddenBy = reader.readStringOrNull(offsets[17]);
  object.overrideReason = reader.readStringOrNull(offsets[18]);
  object.penaltyAmount = reader.readDoubleOrNull(offsets[19]);
  object.penaltyOverridden = reader.readBool(offsets[20]);
  object.rate = reader.readDouble(offsets[21]);
  object.status = reader.readStringOrNull(offsets[22]);
  object.syncStatus = _DieselLogEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[23])] ??
      SyncStatus.pending;
  object.tankFull = reader.readBool(offsets[24]);
  object.totalCost = reader.readDouble(offsets[25]);
  object.updatedAt = reader.readDateTime(offsets[26]);
  object.vehicleId = reader.readString(offsets[27]);
  object.vehicleNumber = reader.readString(offsets[28]);
  return object;
}

P _dieselLogEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readDouble(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (_DieselLogEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 24:
      return (reader.readBool(offset)) as P;
    case 25:
      return (reader.readDouble(offset)) as P;
    case 26:
      return (reader.readDateTime(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DieselLogEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _DieselLogEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _dieselLogEntityGetId(DieselLogEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _dieselLogEntityGetLinks(DieselLogEntity object) {
  return [];
}

void _dieselLogEntityAttach(
    IsarCollection<dynamic> col, Id id, DieselLogEntity object) {}

extension DieselLogEntityByIndex on IsarCollection<DieselLogEntity> {
  Future<DieselLogEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  DieselLogEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<DieselLogEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<DieselLogEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(DieselLogEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(DieselLogEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<DieselLogEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<DieselLogEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension DieselLogEntityQueryWhereSort
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QWhere> {
  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhere> anyFillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'fillDate'),
      );
    });
  }
}

extension DieselLogEntityQueryWhere
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QWhereClause> {
  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      vehicleIdEqualTo(String vehicleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vehicleId',
        value: [vehicleId],
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      fillDateEqualTo(DateTime fillDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'fillDate',
        value: [fillDate],
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      fillDateNotEqualTo(DateTime fillDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fillDate',
              lower: [],
              upper: [fillDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fillDate',
              lower: [fillDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fillDate',
              lower: [fillDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fillDate',
              lower: [],
              upper: [fillDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      fillDateGreaterThan(
    DateTime fillDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fillDate',
        lower: [fillDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      fillDateLessThan(
    DateTime fillDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fillDate',
        lower: [],
        upper: [fillDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
      fillDateBetween(
    DateTime lowerFillDate,
    DateTime upperFillDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'fillDate',
        lower: [lowerFillDate],
        includeLower: includeLower,
        upper: [upperFillDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterWhereClause>
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

extension DieselLogEntityQueryFilter
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QFilterCondition> {
  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByEqualTo(
    String? value, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByGreaterThan(
    String? value, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByLessThan(
    String? value, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByStartsWith(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByEndsWith(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      createdByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleDistanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cycleDistance',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleDistanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cycleDistance',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleDistanceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cycleDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleDistanceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cycleDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleDistanceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cycleDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleDistanceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cycleDistance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleEfficiencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cycleEfficiency',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleEfficiencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cycleEfficiency',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleEfficiencyEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cycleEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleEfficiencyGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cycleEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleEfficiencyLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cycleEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleEfficiencyBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cycleEfficiency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleFuelUsedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cycleFuelUsed',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleFuelUsedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cycleFuelUsed',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleFuelUsedEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cycleFuelUsed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleFuelUsedGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cycleFuelUsed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleFuelUsedLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cycleFuelUsed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      cycleFuelUsedBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cycleFuelUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      distanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'distance',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      distanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'distance',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      distanceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      distanceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      distanceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      distanceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'driverName',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'driverName',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'driverName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'driverName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'driverName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'driverName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'driverName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'driverName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'driverName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'driverName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'driverName',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      driverNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'driverName',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      fillDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fillDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      fillDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fillDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      fillDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fillDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      fillDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fillDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'journeyFrom',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'journeyFrom',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'journeyFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'journeyFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'journeyFrom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'journeyFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'journeyFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'journeyFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'journeyFrom',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyFrom',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyFromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'journeyFrom',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'journeyTo',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'journeyTo',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'journeyTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'journeyTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'journeyTo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'journeyTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'journeyTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'journeyTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'journeyTo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyTo',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      journeyToIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'journeyTo',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      litersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'liters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      litersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'liters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      litersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'liters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      litersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'liters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesEqualTo(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesGreaterThan(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesLessThan(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesBetween(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesStartsWith(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesEndsWith(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      odometerReadingEqualTo(
    double value, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      odometerReadingGreaterThan(
    double value, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      odometerReadingLessThan(
    double value, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      odometerReadingBetween(
    double lower,
    double upper, {
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      originalPenaltyAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalPenaltyAmount',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      originalPenaltyAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalPenaltyAmount',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      originalPenaltyAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalPenaltyAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      originalPenaltyAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalPenaltyAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      originalPenaltyAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalPenaltyAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      originalPenaltyAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalPenaltyAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'overriddenBy',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'overriddenBy',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overriddenBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overriddenBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overriddenBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overriddenBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'overriddenBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'overriddenBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'overriddenBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'overriddenBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overriddenBy',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overriddenByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'overriddenBy',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'overrideReason',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'overrideReason',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overrideReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overrideReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overrideReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overrideReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'overrideReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'overrideReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'overrideReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'overrideReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overrideReason',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      overrideReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'overrideReason',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      penaltyAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'penaltyAmount',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      penaltyAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'penaltyAmount',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      penaltyAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'penaltyAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      penaltyAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'penaltyAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      penaltyAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'penaltyAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      penaltyAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'penaltyAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      penaltyOverriddenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'penaltyOverridden',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      rateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      rateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      rateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      rateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusEqualTo(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusGreaterThan(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusLessThan(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusBetween(
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      tankFullEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tankFull',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleId',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
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

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterFilterCondition>
      vehicleNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }
}

extension DieselLogEntityQueryObject
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QFilterCondition> {}

extension DieselLogEntityQueryLinks
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QFilterCondition> {}

extension DieselLogEntityQuerySortBy
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QSortBy> {
  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCycleDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleDistance', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCycleDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleDistance', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCycleEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEfficiency', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCycleEfficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEfficiency', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCycleFuelUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleFuelUsed', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByCycleFuelUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleFuelUsed', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByDriverName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'driverName', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByDriverNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'driverName', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByFillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fillDate', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByFillDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fillDate', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByJourneyFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyFrom', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByJourneyFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyFrom', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByJourneyTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyTo', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByJourneyToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyTo', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> sortByLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liters', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liters', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOdometerReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOriginalPenaltyAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPenaltyAmount', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOriginalPenaltyAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPenaltyAmount', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOverriddenBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overriddenBy', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOverriddenByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overriddenBy', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOverrideReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overrideReason', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByOverrideReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overrideReason', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByPenaltyAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyAmount', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByPenaltyAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyAmount', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByPenaltyOverridden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyOverridden', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByPenaltyOverriddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyOverridden', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> sortByRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByTankFull() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankFull', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByTankFullDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankFull', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      sortByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }
}

extension DieselLogEntityQuerySortThenBy
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QSortThenBy> {
  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCycleDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleDistance', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCycleDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleDistance', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCycleEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEfficiency', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCycleEfficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleEfficiency', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCycleFuelUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleFuelUsed', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByCycleFuelUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleFuelUsed', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByDriverName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'driverName', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByDriverNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'driverName', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByFillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fillDate', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByFillDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fillDate', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByJourneyFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyFrom', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByJourneyFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyFrom', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByJourneyTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyTo', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByJourneyToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyTo', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> thenByLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liters', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liters', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOdometerReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerReading', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOriginalPenaltyAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPenaltyAmount', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOriginalPenaltyAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPenaltyAmount', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOverriddenBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overriddenBy', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOverriddenByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overriddenBy', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOverrideReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overrideReason', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByOverrideReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overrideReason', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByPenaltyAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyAmount', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByPenaltyAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyAmount', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByPenaltyOverridden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyOverridden', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByPenaltyOverriddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'penaltyOverridden', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> thenByRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rate', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByTankFull() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankFull', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByTankFullDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankFull', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QAfterSortBy>
      thenByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }
}

extension DieselLogEntityQueryWhereDistinct
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> {
  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByCreatedAt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByCreatedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByCycleDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycleDistance');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByCycleEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycleEfficiency');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByCycleFuelUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycleFuelUsed');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByDriverName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'driverName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByFillDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fillDate');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByJourneyFrom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'journeyFrom', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByJourneyTo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'journeyTo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'liters');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odometerReading');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByOriginalPenaltyAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalPenaltyAmount');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByOverriddenBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overriddenBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByOverrideReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overrideReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByPenaltyAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'penaltyAmount');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByPenaltyOverridden() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'penaltyOverridden');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rate');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByTankFull() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tankFull');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCost');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct> distinctByVehicleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DieselLogEntity, DieselLogEntity, QDistinct>
      distinctByVehicleNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleNumber',
          caseSensitive: caseSensitive);
    });
  }
}

extension DieselLogEntityQueryProperty
    on QueryBuilder<DieselLogEntity, DieselLogEntity, QQueryProperty> {
  QueryBuilder<DieselLogEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DieselLogEntity, String, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations> createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<DieselLogEntity, double?, QQueryOperations>
      cycleDistanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycleDistance');
    });
  }

  QueryBuilder<DieselLogEntity, double?, QQueryOperations>
      cycleEfficiencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycleEfficiency');
    });
  }

  QueryBuilder<DieselLogEntity, double?, QQueryOperations>
      cycleFuelUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycleFuelUsed');
    });
  }

  QueryBuilder<DieselLogEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<DieselLogEntity, double?, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations>
      driverNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'driverName');
    });
  }

  QueryBuilder<DieselLogEntity, DateTime, QQueryOperations> fillDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fillDate');
    });
  }

  QueryBuilder<DieselLogEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DieselLogEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations>
      journeyFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'journeyFrom');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations> journeyToProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'journeyTo');
    });
  }

  QueryBuilder<DieselLogEntity, double, QQueryOperations> litersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'liters');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<DieselLogEntity, double, QQueryOperations>
      odometerReadingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odometerReading');
    });
  }

  QueryBuilder<DieselLogEntity, double?, QQueryOperations>
      originalPenaltyAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalPenaltyAmount');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations>
      overriddenByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overriddenBy');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations>
      overrideReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overrideReason');
    });
  }

  QueryBuilder<DieselLogEntity, double?, QQueryOperations>
      penaltyAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'penaltyAmount');
    });
  }

  QueryBuilder<DieselLogEntity, bool, QQueryOperations>
      penaltyOverriddenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'penaltyOverridden');
    });
  }

  QueryBuilder<DieselLogEntity, double, QQueryOperations> rateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rate');
    });
  }

  QueryBuilder<DieselLogEntity, String?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DieselLogEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<DieselLogEntity, bool, QQueryOperations> tankFullProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tankFull');
    });
  }

  QueryBuilder<DieselLogEntity, double, QQueryOperations> totalCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCost');
    });
  }

  QueryBuilder<DieselLogEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<DieselLogEntity, String, QQueryOperations> vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }

  QueryBuilder<DieselLogEntity, String, QQueryOperations>
      vehicleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleNumber');
    });
  }
}
