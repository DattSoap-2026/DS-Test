// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tank_lot_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTankLotEntityCollection on Isar {
  IsarCollection<TankLotEntity> get tankLotEntitys => this.collection();
}

const TankLotEntitySchema = CollectionSchema(
  name: r'TankLotEntity',
  id: 6452783719006117897,
  properties: {
    r'deletedAt': PropertySchema(
      id: 0,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'initialQuantity': PropertySchema(
      id: 2,
      name: r'initialQuantity',
      type: IsarType.double,
    ),
    r'isDeleted': PropertySchema(
      id: 3,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'materialId': PropertySchema(
      id: 4,
      name: r'materialId',
      type: IsarType.string,
    ),
    r'materialName': PropertySchema(
      id: 5,
      name: r'materialName',
      type: IsarType.string,
    ),
    r'purchaseOrderId': PropertySchema(
      id: 6,
      name: r'purchaseOrderId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 7,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'receivedDate': PropertySchema(
      id: 8,
      name: r'receivedDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.string,
    ),
    r'supplierId': PropertySchema(
      id: 10,
      name: r'supplierId',
      type: IsarType.string,
    ),
    r'supplierName': PropertySchema(
      id: 11,
      name: r'supplierName',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 12,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _TankLotEntitysyncStatusEnumValueMap,
    ),
    r'tankId': PropertySchema(
      id: 13,
      name: r'tankId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _tankLotEntityEstimateSize,
  serialize: _tankLotEntitySerialize,
  deserialize: _tankLotEntityDeserialize,
  deserializeProp: _tankLotEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'tankId': IndexSchema(
      id: 3441290314583732874,
      name: r'tankId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tankId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'materialId': IndexSchema(
      id: -4039490305560314015,
      name: r'materialId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'materialId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'receivedDate': IndexSchema(
      id: 2837984934516465990,
      name: r'receivedDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'receivedDate',
          type: IndexType.value,
          caseSensitive: false,
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
  getId: _tankLotEntityGetId,
  getLinks: _tankLotEntityGetLinks,
  attach: _tankLotEntityAttach,
  version: '3.1.0+1',
);

int _tankLotEntityEstimateSize(
  TankLotEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.materialId.length * 3;
  bytesCount += 3 + object.materialName.length * 3;
  bytesCount += 3 + object.purchaseOrderId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.supplierId.length * 3;
  bytesCount += 3 + object.supplierName.length * 3;
  bytesCount += 3 + object.tankId.length * 3;
  return bytesCount;
}

void _tankLotEntitySerialize(
  TankLotEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.deletedAt);
  writer.writeString(offsets[1], object.id);
  writer.writeDouble(offsets[2], object.initialQuantity);
  writer.writeBool(offsets[3], object.isDeleted);
  writer.writeString(offsets[4], object.materialId);
  writer.writeString(offsets[5], object.materialName);
  writer.writeString(offsets[6], object.purchaseOrderId);
  writer.writeDouble(offsets[7], object.quantity);
  writer.writeDateTime(offsets[8], object.receivedDate);
  writer.writeString(offsets[9], object.status);
  writer.writeString(offsets[10], object.supplierId);
  writer.writeString(offsets[11], object.supplierName);
  writer.writeByte(offsets[12], object.syncStatus.index);
  writer.writeString(offsets[13], object.tankId);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

TankLotEntity _tankLotEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TankLotEntity();
  object.deletedAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = reader.readString(offsets[1]);
  object.initialQuantity = reader.readDouble(offsets[2]);
  object.isDeleted = reader.readBool(offsets[3]);
  object.materialId = reader.readString(offsets[4]);
  object.materialName = reader.readString(offsets[5]);
  object.purchaseOrderId = reader.readString(offsets[6]);
  object.quantity = reader.readDouble(offsets[7]);
  object.receivedDate = reader.readDateTime(offsets[8]);
  object.status = reader.readString(offsets[9]);
  object.supplierId = reader.readString(offsets[10]);
  object.supplierName = reader.readString(offsets[11]);
  object.syncStatus = _TankLotEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[12])] ??
      SyncStatus.pending;
  object.tankId = reader.readString(offsets[13]);
  object.updatedAt = reader.readDateTime(offsets[14]);
  return object;
}

P _tankLotEntityDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (_TankLotEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TankLotEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _TankLotEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _tankLotEntityGetId(TankLotEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _tankLotEntityGetLinks(TankLotEntity object) {
  return [];
}

void _tankLotEntityAttach(
    IsarCollection<dynamic> col, Id id, TankLotEntity object) {}

extension TankLotEntityByIndex on IsarCollection<TankLotEntity> {
  Future<TankLotEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  TankLotEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<TankLotEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<TankLotEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(TankLotEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(TankLotEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<TankLotEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<TankLotEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension TankLotEntityQueryWhereSort
    on QueryBuilder<TankLotEntity, TankLotEntity, QWhere> {
  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhere> anyReceivedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'receivedDate'),
      );
    });
  }
}

extension TankLotEntityQueryWhere
    on QueryBuilder<TankLotEntity, TankLotEntity, QWhereClause> {
  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause> tankIdEqualTo(
      String tankId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tankId',
        value: [tankId],
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      tankIdNotEqualTo(String tankId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tankId',
              lower: [],
              upper: [tankId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tankId',
              lower: [tankId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tankId',
              lower: [tankId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tankId',
              lower: [],
              upper: [tankId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      materialIdEqualTo(String materialId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'materialId',
        value: [materialId],
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      materialIdNotEqualTo(String materialId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'materialId',
              lower: [],
              upper: [materialId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'materialId',
              lower: [materialId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'materialId',
              lower: [materialId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'materialId',
              lower: [],
              upper: [materialId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      receivedDateEqualTo(DateTime receivedDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'receivedDate',
        value: [receivedDate],
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      receivedDateNotEqualTo(DateTime receivedDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receivedDate',
              lower: [],
              upper: [receivedDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receivedDate',
              lower: [receivedDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receivedDate',
              lower: [receivedDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receivedDate',
              lower: [],
              upper: [receivedDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      receivedDateGreaterThan(
    DateTime receivedDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'receivedDate',
        lower: [receivedDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      receivedDateLessThan(
    DateTime receivedDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'receivedDate',
        lower: [],
        upper: [receivedDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
      receivedDateBetween(
    DateTime lowerReceivedDate,
    DateTime upperReceivedDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'receivedDate',
        lower: [lowerReceivedDate],
        includeLower: includeLower,
        upper: [upperReceivedDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause> statusEqualTo(
      String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterWhereClause> idNotEqualTo(
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

extension TankLotEntityQueryFilter
    on QueryBuilder<TankLotEntity, TankLotEntity, QFilterCondition> {
  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition> idContains(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition> idMatches(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      initialQuantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initialQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      initialQuantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initialQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      initialQuantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initialQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      initialQuantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initialQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'materialId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'materialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'materialId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'materialId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'materialName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'materialName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'materialName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'materialName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'materialName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'materialName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'materialName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'materialName',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      materialNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'materialName',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseOrderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseOrderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseOrderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseOrderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'purchaseOrderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'purchaseOrderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'purchaseOrderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'purchaseOrderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseOrderId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      purchaseOrderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'purchaseOrderId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      quantityEqualTo(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      quantityGreaterThan(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      quantityLessThan(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      quantityBetween(
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      receivedDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      receivedDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      receivedDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      receivedDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supplierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supplierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supplierId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supplierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supplierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supplierId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supplierId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplierId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supplierId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supplierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supplierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supplierName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supplierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supplierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supplierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supplierName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplierName',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      supplierNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supplierName',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tankId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tankId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tankId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tankId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      tankIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tankId',
        value: '',
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterFilterCondition>
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

extension TankLotEntityQueryObject
    on QueryBuilder<TankLotEntity, TankLotEntity, QFilterCondition> {}

extension TankLotEntityQueryLinks
    on QueryBuilder<TankLotEntity, TankLotEntity, QFilterCondition> {}

extension TankLotEntityQuerySortBy
    on QueryBuilder<TankLotEntity, TankLotEntity, QSortBy> {
  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByInitialQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialQuantity', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByInitialQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialQuantity', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByMaterialId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByMaterialIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByMaterialName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialName', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByMaterialNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialName', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByPurchaseOrderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseOrderId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByPurchaseOrderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseOrderId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByReceivedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedDate', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByReceivedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedDate', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortBySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortBySupplierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortBySupplierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortBySupplierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByTankId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByTankIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TankLotEntityQuerySortThenBy
    on QueryBuilder<TankLotEntity, TankLotEntity, QSortThenBy> {
  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByInitialQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialQuantity', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByInitialQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialQuantity', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByMaterialId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByMaterialIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByMaterialName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialName', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByMaterialNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialName', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByPurchaseOrderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseOrderId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByPurchaseOrderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseOrderId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByReceivedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedDate', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByReceivedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedDate', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenBySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenBySupplierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenBySupplierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenBySupplierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByTankId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankId', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByTankIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tankId', Sort.desc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TankLotEntityQueryWhereDistinct
    on QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> {
  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct>
      distinctByInitialQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialQuantity');
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByMaterialId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'materialId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByMaterialName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'materialName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct>
      distinctByPurchaseOrderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseOrderId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct>
      distinctByReceivedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedDate');
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctBySupplierId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplierId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctBySupplierName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplierName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByTankId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tankId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TankLotEntity, TankLotEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TankLotEntityQueryProperty
    on QueryBuilder<TankLotEntity, TankLotEntity, QQueryProperty> {
  QueryBuilder<TankLotEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<TankLotEntity, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TankLotEntity, double, QQueryOperations>
      initialQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialQuantity');
    });
  }

  QueryBuilder<TankLotEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations> materialIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'materialId');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations> materialNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'materialName');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations>
      purchaseOrderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseOrderId');
    });
  }

  QueryBuilder<TankLotEntity, double, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<TankLotEntity, DateTime, QQueryOperations>
      receivedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedDate');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations> supplierIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplierId');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations> supplierNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplierName');
    });
  }

  QueryBuilder<TankLotEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<TankLotEntity, String, QQueryOperations> tankIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tankId');
    });
  }

  QueryBuilder<TankLotEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
