// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVehicleEntityCollection on Isar {
  IsarCollection<VehicleEntity> get vehicleEntitys => this.collection();
}

const VehicleEntitySchema = CollectionSchema(
  name: r'VehicleEntity',
  id: 1452110314205909781,
  properties: {
    r'capacity': PropertySchema(
      id: 0,
      name: r'capacity',
      type: IsarType.double,
    ),
    r'costPerKm': PropertySchema(
      id: 1,
      name: r'costPerKm',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.string,
    ),
    r'currentOdometer': PropertySchema(
      id: 3,
      name: r'currentOdometer',
      type: IsarType.double,
    ),
    r'deletedAt': PropertySchema(
      id: 4,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'fitnessExpiryDate': PropertySchema(
      id: 5,
      name: r'fitnessExpiryDate',
      type: IsarType.dateTime,
    ),
    r'fuelType': PropertySchema(
      id: 6,
      name: r'fuelType',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 7,
      name: r'id',
      type: IsarType.string,
    ),
    r'insuranceExpiryDate': PropertySchema(
      id: 8,
      name: r'insuranceExpiryDate',
      type: IsarType.dateTime,
    ),
    r'insuranceProvider': PropertySchema(
      id: 9,
      name: r'insuranceProvider',
      type: IsarType.string,
    ),
    r'insuranceStartDate': PropertySchema(
      id: 10,
      name: r'insuranceStartDate',
      type: IsarType.dateTime,
    ),
    r'isDeleted': PropertySchema(
      id: 11,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'lastDieselFill': PropertySchema(
      id: 12,
      name: r'lastDieselFill',
      type: IsarType.string,
    ),
    r'maxAverage': PropertySchema(
      id: 13,
      name: r'maxAverage',
      type: IsarType.double,
    ),
    r'minAverage': PropertySchema(
      id: 14,
      name: r'minAverage',
      type: IsarType.double,
    ),
    r'model': PropertySchema(
      id: 15,
      name: r'model',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 16,
      name: r'name',
      type: IsarType.string,
    ),
    r'number': PropertySchema(
      id: 17,
      name: r'number',
      type: IsarType.string,
    ),
    r'permitExpiryDate': PropertySchema(
      id: 18,
      name: r'permitExpiryDate',
      type: IsarType.dateTime,
    ),
    r'permitNumber': PropertySchema(
      id: 19,
      name: r'permitNumber',
      type: IsarType.string,
    ),
    r'policyNumber': PropertySchema(
      id: 20,
      name: r'policyNumber',
      type: IsarType.string,
    ),
    r'pucExpiryDate': PropertySchema(
      id: 21,
      name: r'pucExpiryDate',
      type: IsarType.dateTime,
    ),
    r'pucNumber': PropertySchema(
      id: 22,
      name: r'pucNumber',
      type: IsarType.string,
    ),
    r'purchaseDate': PropertySchema(
      id: 23,
      name: r'purchaseDate',
      type: IsarType.dateTime,
    ),
    r'rcNumber': PropertySchema(
      id: 24,
      name: r'rcNumber',
      type: IsarType.string,
    ),
    r'serialNumber': PropertySchema(
      id: 25,
      name: r'serialNumber',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 26,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 27,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _VehicleEntitysyncStatusEnumValueMap,
    ),
    r'totalDieselCost': PropertySchema(
      id: 28,
      name: r'totalDieselCost',
      type: IsarType.double,
    ),
    r'totalDistance': PropertySchema(
      id: 29,
      name: r'totalDistance',
      type: IsarType.double,
    ),
    r'totalFuelConsumed': PropertySchema(
      id: 30,
      name: r'totalFuelConsumed',
      type: IsarType.double,
    ),
    r'totalMaintenanceCost': PropertySchema(
      id: 31,
      name: r'totalMaintenanceCost',
      type: IsarType.double,
    ),
    r'totalTyreCost': PropertySchema(
      id: 32,
      name: r'totalTyreCost',
      type: IsarType.double,
    ),
    r'type': PropertySchema(
      id: 33,
      name: r'type',
      type: IsarType.string,
    ),
    r'tyreSize': PropertySchema(
      id: 34,
      name: r'tyreSize',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 35,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _vehicleEntityEstimateSize,
  serialize: _vehicleEntitySerialize,
  deserialize: _vehicleEntityDeserialize,
  deserializeProp: _vehicleEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'number': IndexSchema(
      id: 5012388430481709372,
      name: r'number',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'number',
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
  getId: _vehicleEntityGetId,
  getLinks: _vehicleEntityGetLinks,
  attach: _vehicleEntityAttach,
  version: '3.1.0+1',
);

int _vehicleEntityEstimateSize(
  VehicleEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.createdAt.length * 3;
  {
    final value = object.fuelType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.insuranceProvider;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastDieselFill;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.model;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.number.length * 3;
  {
    final value = object.permitNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.policyNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pucNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rcNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.serialNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.type.length * 3;
  {
    final value = object.tyreSize;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _vehicleEntitySerialize(
  VehicleEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.capacity);
  writer.writeDouble(offsets[1], object.costPerKm);
  writer.writeString(offsets[2], object.createdAt);
  writer.writeDouble(offsets[3], object.currentOdometer);
  writer.writeDateTime(offsets[4], object.deletedAt);
  writer.writeDateTime(offsets[5], object.fitnessExpiryDate);
  writer.writeString(offsets[6], object.fuelType);
  writer.writeString(offsets[7], object.id);
  writer.writeDateTime(offsets[8], object.insuranceExpiryDate);
  writer.writeString(offsets[9], object.insuranceProvider);
  writer.writeDateTime(offsets[10], object.insuranceStartDate);
  writer.writeBool(offsets[11], object.isDeleted);
  writer.writeString(offsets[12], object.lastDieselFill);
  writer.writeDouble(offsets[13], object.maxAverage);
  writer.writeDouble(offsets[14], object.minAverage);
  writer.writeString(offsets[15], object.model);
  writer.writeString(offsets[16], object.name);
  writer.writeString(offsets[17], object.number);
  writer.writeDateTime(offsets[18], object.permitExpiryDate);
  writer.writeString(offsets[19], object.permitNumber);
  writer.writeString(offsets[20], object.policyNumber);
  writer.writeDateTime(offsets[21], object.pucExpiryDate);
  writer.writeString(offsets[22], object.pucNumber);
  writer.writeDateTime(offsets[23], object.purchaseDate);
  writer.writeString(offsets[24], object.rcNumber);
  writer.writeString(offsets[25], object.serialNumber);
  writer.writeString(offsets[26], object.status);
  writer.writeByte(offsets[27], object.syncStatus.index);
  writer.writeDouble(offsets[28], object.totalDieselCost);
  writer.writeDouble(offsets[29], object.totalDistance);
  writer.writeDouble(offsets[30], object.totalFuelConsumed);
  writer.writeDouble(offsets[31], object.totalMaintenanceCost);
  writer.writeDouble(offsets[32], object.totalTyreCost);
  writer.writeString(offsets[33], object.type);
  writer.writeString(offsets[34], object.tyreSize);
  writer.writeDateTime(offsets[35], object.updatedAt);
}

VehicleEntity _vehicleEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VehicleEntity();
  object.capacity = reader.readDoubleOrNull(offsets[0]);
  object.costPerKm = reader.readDouble(offsets[1]);
  object.createdAt = reader.readString(offsets[2]);
  object.currentOdometer = reader.readDouble(offsets[3]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[4]);
  object.fitnessExpiryDate = reader.readDateTimeOrNull(offsets[5]);
  object.fuelType = reader.readStringOrNull(offsets[6]);
  object.id = reader.readString(offsets[7]);
  object.insuranceExpiryDate = reader.readDateTimeOrNull(offsets[8]);
  object.insuranceProvider = reader.readStringOrNull(offsets[9]);
  object.insuranceStartDate = reader.readDateTimeOrNull(offsets[10]);
  object.isDeleted = reader.readBool(offsets[11]);
  object.lastDieselFill = reader.readStringOrNull(offsets[12]);
  object.maxAverage = reader.readDouble(offsets[13]);
  object.minAverage = reader.readDouble(offsets[14]);
  object.model = reader.readStringOrNull(offsets[15]);
  object.name = reader.readString(offsets[16]);
  object.number = reader.readString(offsets[17]);
  object.permitExpiryDate = reader.readDateTimeOrNull(offsets[18]);
  object.permitNumber = reader.readStringOrNull(offsets[19]);
  object.policyNumber = reader.readStringOrNull(offsets[20]);
  object.pucExpiryDate = reader.readDateTimeOrNull(offsets[21]);
  object.pucNumber = reader.readStringOrNull(offsets[22]);
  object.purchaseDate = reader.readDateTimeOrNull(offsets[23]);
  object.rcNumber = reader.readStringOrNull(offsets[24]);
  object.serialNumber = reader.readStringOrNull(offsets[25]);
  object.status = reader.readString(offsets[26]);
  object.syncStatus = _VehicleEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[27])] ??
      SyncStatus.pending;
  object.totalDieselCost = reader.readDouble(offsets[28]);
  object.totalDistance = reader.readDouble(offsets[29]);
  object.totalFuelConsumed = reader.readDouble(offsets[30]);
  object.totalMaintenanceCost = reader.readDouble(offsets[31]);
  object.totalTyreCost = reader.readDouble(offsets[32]);
  object.type = reader.readString(offsets[33]);
  object.tyreSize = reader.readStringOrNull(offsets[34]);
  object.updatedAt = reader.readDateTime(offsets[35]);
  return object;
}

P _vehicleEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (_VehicleEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 28:
      return (reader.readDouble(offset)) as P;
    case 29:
      return (reader.readDouble(offset)) as P;
    case 30:
      return (reader.readDouble(offset)) as P;
    case 31:
      return (reader.readDouble(offset)) as P;
    case 32:
      return (reader.readDouble(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _VehicleEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _VehicleEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _vehicleEntityGetId(VehicleEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _vehicleEntityGetLinks(VehicleEntity object) {
  return [];
}

void _vehicleEntityAttach(
    IsarCollection<dynamic> col, Id id, VehicleEntity object) {}

extension VehicleEntityByIndex on IsarCollection<VehicleEntity> {
  Future<VehicleEntity?> getByNumber(String number) {
    return getByIndex(r'number', [number]);
  }

  VehicleEntity? getByNumberSync(String number) {
    return getByIndexSync(r'number', [number]);
  }

  Future<bool> deleteByNumber(String number) {
    return deleteByIndex(r'number', [number]);
  }

  bool deleteByNumberSync(String number) {
    return deleteByIndexSync(r'number', [number]);
  }

  Future<List<VehicleEntity?>> getAllByNumber(List<String> numberValues) {
    final values = numberValues.map((e) => [e]).toList();
    return getAllByIndex(r'number', values);
  }

  List<VehicleEntity?> getAllByNumberSync(List<String> numberValues) {
    final values = numberValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'number', values);
  }

  Future<int> deleteAllByNumber(List<String> numberValues) {
    final values = numberValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'number', values);
  }

  int deleteAllByNumberSync(List<String> numberValues) {
    final values = numberValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'number', values);
  }

  Future<Id> putByNumber(VehicleEntity object) {
    return putByIndex(r'number', object);
  }

  Id putByNumberSync(VehicleEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'number', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNumber(List<VehicleEntity> objects) {
    return putAllByIndex(r'number', objects);
  }

  List<Id> putAllByNumberSync(List<VehicleEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'number', objects, saveLinks: saveLinks);
  }

  Future<VehicleEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  VehicleEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<VehicleEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<VehicleEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(VehicleEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(VehicleEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<VehicleEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<VehicleEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension VehicleEntityQueryWhereSort
    on QueryBuilder<VehicleEntity, VehicleEntity, QWhere> {
  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VehicleEntityQueryWhere
    on QueryBuilder<VehicleEntity, VehicleEntity, QWhereClause> {
  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause> numberEqualTo(
      String number) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'number',
        value: [number],
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause>
      numberNotEqualTo(String number) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'number',
              lower: [],
              upper: [number],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'number',
              lower: [number],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'number',
              lower: [number],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'number',
              lower: [],
              upper: [number],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterWhereClause> idNotEqualTo(
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

extension VehicleEntityQueryFilter
    on QueryBuilder<VehicleEntity, VehicleEntity, QFilterCondition> {
  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      capacityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'capacity',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      capacityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'capacity',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      capacityEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      capacityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      capacityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capacity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      capacityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capacity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      costPerKmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costPerKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      costPerKmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costPerKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      costPerKmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costPerKm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      costPerKmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costPerKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      createdAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      createdAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      createdAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      createdAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      currentOdometerEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      currentOdometerGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      currentOdometerLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentOdometer',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      currentOdometerBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentOdometer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fitnessExpiryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fitnessExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fitnessExpiryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fitnessExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fitnessExpiryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fitnessExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fitnessExpiryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fitnessExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fitnessExpiryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fitnessExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fitnessExpiryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fitnessExpiryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fuelType',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fuelType',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fuelType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fuelType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fuelType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fuelType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fuelType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fuelType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fuelType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fuelType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fuelType',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      fuelTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fuelType',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> idContains(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> idMatches(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceExpiryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insuranceExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceExpiryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insuranceExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceExpiryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceExpiryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insuranceExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceExpiryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insuranceExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceExpiryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insuranceExpiryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insuranceProvider',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insuranceProvider',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insuranceProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insuranceProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insuranceProvider',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'insuranceProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'insuranceProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'insuranceProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'insuranceProvider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceProviderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'insuranceProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceStartDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insuranceStartDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceStartDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insuranceStartDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceStartDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceStartDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insuranceStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceStartDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insuranceStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      insuranceStartDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insuranceStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDieselFill',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDieselFill',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDieselFill',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDieselFill',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDieselFill',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDieselFill',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastDieselFill',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastDieselFill',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastDieselFill',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastDieselFill',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDieselFill',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      lastDieselFillIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastDieselFill',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      maxAverageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      maxAverageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      maxAverageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      maxAverageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxAverage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      minAverageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      minAverageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      minAverageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      minAverageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minAverage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'model',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'model',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'model',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'model',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'number',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'number',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'number',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      numberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'number',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitExpiryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'permitExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitExpiryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'permitExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitExpiryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permitExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitExpiryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permitExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitExpiryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permitExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitExpiryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permitExpiryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'permitNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'permitNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permitNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permitNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permitNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permitNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permitNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permitNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permitNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permitNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permitNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      permitNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permitNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'policyNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'policyNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'policyNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'policyNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'policyNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'policyNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'policyNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'policyNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'policyNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      policyNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'policyNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucExpiryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pucExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucExpiryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pucExpiryDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucExpiryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pucExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucExpiryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pucExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucExpiryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pucExpiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucExpiryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pucExpiryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pucNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pucNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pucNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pucNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pucNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pucNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pucNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pucNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pucNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pucNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pucNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      pucNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pucNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      purchaseDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purchaseDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      purchaseDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purchaseDate',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      purchaseDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      purchaseDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      purchaseDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      purchaseDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rcNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rcNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rcNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rcNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rcNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rcNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rcNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rcNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rcNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rcNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rcNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      rcNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rcNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serialNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serialNumber',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serialNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serialNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serialNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      serialNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serialNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDieselCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDieselCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDieselCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDieselCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDieselCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDieselCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDieselCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDieselCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDistanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDistanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDistanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalDistanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDistance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalFuelConsumedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFuelConsumed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalFuelConsumedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFuelConsumed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalFuelConsumedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFuelConsumed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalFuelConsumedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFuelConsumed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalMaintenanceCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMaintenanceCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalMaintenanceCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMaintenanceCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalMaintenanceCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMaintenanceCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalMaintenanceCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMaintenanceCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalTyreCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalTyreCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalTyreCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalTyreCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalTyreCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalTyreCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      totalTyreCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalTyreCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      typeGreaterThan(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      typeLessThan(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> typeBetween(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      typeStartsWith(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      typeEndsWith(
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tyreSize',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tyreSize',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tyreSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tyreSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tyreSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tyreSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tyreSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tyreSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tyreSize',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tyreSize',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      tyreSizeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tyreSize',
        value: '',
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterFilterCondition>
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

extension VehicleEntityQueryObject
    on QueryBuilder<VehicleEntity, VehicleEntity, QFilterCondition> {}

extension VehicleEntityQueryLinks
    on QueryBuilder<VehicleEntity, VehicleEntity, QFilterCondition> {}

extension VehicleEntityQuerySortBy
    on QueryBuilder<VehicleEntity, VehicleEntity, QSortBy> {
  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByCostPerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerKm', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByCostPerKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerKm', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByCurrentOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOdometer', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByCurrentOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOdometer', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByFitnessExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByFitnessExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByFuelType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByFuelTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByInsuranceExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByInsuranceExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByInsuranceProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceProvider', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByInsuranceProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceProvider', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByInsuranceStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceStartDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByInsuranceStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceStartDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByLastDieselFill() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDieselFill', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByLastDieselFillDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDieselFill', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByMaxAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAverage', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByMaxAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAverage', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByMinAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAverage', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByMinAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAverage', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPermitExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPermitExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPermitNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPermitNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPolicyNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPolicyNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPucExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPucExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByPucNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPucNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByRcNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByRcNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortBySerialNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortBySerialNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalDieselCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDieselCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalDieselCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDieselCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalFuelConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFuelConsumed', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalFuelConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFuelConsumed', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalMaintenanceCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMaintenanceCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalMaintenanceCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMaintenanceCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalTyreCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTyreCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTotalTyreCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTyreCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByTyreSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tyreSize', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByTyreSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tyreSize', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension VehicleEntityQuerySortThenBy
    on QueryBuilder<VehicleEntity, VehicleEntity, QSortThenBy> {
  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByCapacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacity', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByCostPerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerKm', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByCostPerKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerKm', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByCurrentOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOdometer', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByCurrentOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentOdometer', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByFitnessExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByFitnessExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByFuelType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByFuelTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fuelType', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByInsuranceExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByInsuranceExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByInsuranceProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceProvider', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByInsuranceProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceProvider', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByInsuranceStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceStartDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByInsuranceStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceStartDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByLastDieselFill() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDieselFill', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByLastDieselFillDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDieselFill', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByMaxAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAverage', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByMaxAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAverage', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByMinAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAverage', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByMinAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAverage', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPermitExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPermitExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPermitNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPermitNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permitNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPolicyNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPolicyNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPucExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucExpiryDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPucExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucExpiryDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByPucNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPucNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pucNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByRcNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByRcNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenBySerialNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenBySerialNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalDieselCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDieselCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalDieselCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDieselCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalFuelConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFuelConsumed', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalFuelConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFuelConsumed', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalMaintenanceCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMaintenanceCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalMaintenanceCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMaintenanceCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalTyreCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTyreCost', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTotalTyreCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTyreCost', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByTyreSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tyreSize', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByTyreSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tyreSize', Sort.desc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension VehicleEntityQueryWhereDistinct
    on QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> {
  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByCapacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capacity');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByCostPerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costPerKm');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByCreatedAt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByCurrentOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentOdometer');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByFitnessExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fitnessExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByFuelType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fuelType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByInsuranceExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insuranceExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByInsuranceProvider({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insuranceProvider',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByInsuranceStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insuranceStartDate');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByLastDieselFill({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDieselFill',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByMaxAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAverage');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByMinAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minAverage');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'number', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByPermitExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permitExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByPermitNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permitNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByPolicyNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'policyNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByPucExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pucExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByPucNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pucNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseDate');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByRcNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rcNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctBySerialNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serialNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByTotalDieselCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDieselCost');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByTotalDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDistance');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByTotalFuelConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFuelConsumed');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByTotalMaintenanceCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMaintenanceCost');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct>
      distinctByTotalTyreCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTyreCost');
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByTyreSize(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tyreSize', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VehicleEntity, VehicleEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension VehicleEntityQueryProperty
    on QueryBuilder<VehicleEntity, VehicleEntity, QQueryProperty> {
  QueryBuilder<VehicleEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<VehicleEntity, double?, QQueryOperations> capacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capacity');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations> costPerKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costPerKm');
    });
  }

  QueryBuilder<VehicleEntity, String, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations>
      currentOdometerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentOdometer');
    });
  }

  QueryBuilder<VehicleEntity, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<VehicleEntity, DateTime?, QQueryOperations>
      fitnessExpiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fitnessExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations> fuelTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fuelType');
    });
  }

  QueryBuilder<VehicleEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VehicleEntity, DateTime?, QQueryOperations>
      insuranceExpiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insuranceExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations>
      insuranceProviderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insuranceProvider');
    });
  }

  QueryBuilder<VehicleEntity, DateTime?, QQueryOperations>
      insuranceStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insuranceStartDate');
    });
  }

  QueryBuilder<VehicleEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations>
      lastDieselFillProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDieselFill');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations> maxAverageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAverage');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations> minAverageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minAverage');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<VehicleEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<VehicleEntity, String, QQueryOperations> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'number');
    });
  }

  QueryBuilder<VehicleEntity, DateTime?, QQueryOperations>
      permitExpiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permitExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations>
      permitNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permitNumber');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations>
      policyNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyNumber');
    });
  }

  QueryBuilder<VehicleEntity, DateTime?, QQueryOperations>
      pucExpiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pucExpiryDate');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations> pucNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pucNumber');
    });
  }

  QueryBuilder<VehicleEntity, DateTime?, QQueryOperations>
      purchaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseDate');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations> rcNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rcNumber');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations>
      serialNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serialNumber');
    });
  }

  QueryBuilder<VehicleEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<VehicleEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations>
      totalDieselCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDieselCost');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations>
      totalDistanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDistance');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations>
      totalFuelConsumedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFuelConsumed');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations>
      totalMaintenanceCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMaintenanceCost');
    });
  }

  QueryBuilder<VehicleEntity, double, QQueryOperations>
      totalTyreCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTyreCost');
    });
  }

  QueryBuilder<VehicleEntity, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<VehicleEntity, String?, QQueryOperations> tyreSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tyreSize');
    });
  }

  QueryBuilder<VehicleEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
