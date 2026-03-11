// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_production_log_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDetailedProductionLogEntityCollection on Isar {
  IsarCollection<DetailedProductionLogEntity>
      get detailedProductionLogEntitys => this.collection();
}

const DetailedProductionLogEntitySchema = CollectionSchema(
  name: r'DetailedProductionLogEntity',
  id: -3084489092137594217,
  properties: {
    r'additionalRawMaterialsUsed': PropertySchema(
      id: 0,
      name: r'additionalRawMaterialsUsed',
      type: IsarType.objectList,
      target: r'ProductionMaterialItem',
    ),
    r'batchNumber': PropertySchema(
      id: 1,
      name: r'batchNumber',
      type: IsarType.string,
    ),
    r'costPerUnit': PropertySchema(
      id: 2,
      name: r'costPerUnit',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'cuttingWastage': PropertySchema(
      id: 4,
      name: r'cuttingWastage',
      type: IsarType.object,
      target: r'ProductionMaterialItem',
    ),
    r'deletedAt': PropertySchema(
      id: 5,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 6,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 7,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'issueId': PropertySchema(
      id: 8,
      name: r'issueId',
      type: IsarType.string,
    ),
    r'packagingMaterialsUsed': PropertySchema(
      id: 9,
      name: r'packagingMaterialsUsed',
      type: IsarType.objectList,
      target: r'ProductionMaterialItem',
    ),
    r'productId': PropertySchema(
      id: 10,
      name: r'productId',
      type: IsarType.string,
    ),
    r'productName': PropertySchema(
      id: 11,
      name: r'productName',
      type: IsarType.string,
    ),
    r'semiFinishedGoodsUsed': PropertySchema(
      id: 12,
      name: r'semiFinishedGoodsUsed',
      type: IsarType.objectList,
      target: r'ProductionMaterialItem',
    ),
    r'supervisorId': PropertySchema(
      id: 13,
      name: r'supervisorId',
      type: IsarType.string,
    ),
    r'supervisorName': PropertySchema(
      id: 14,
      name: r'supervisorName',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 15,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _DetailedProductionLogEntitysyncStatusEnumValueMap,
    ),
    r'totalBatchCost': PropertySchema(
      id: 16,
      name: r'totalBatchCost',
      type: IsarType.double,
    ),
    r'totalBatchQuantity': PropertySchema(
      id: 17,
      name: r'totalBatchQuantity',
      type: IsarType.long,
    ),
    r'unit': PropertySchema(
      id: 18,
      name: r'unit',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 19,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _detailedProductionLogEntityEstimateSize,
  serialize: _detailedProductionLogEntitySerialize,
  deserialize: _detailedProductionLogEntityDeserialize,
  deserializeProp: _detailedProductionLogEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'batchNumber': IndexSchema(
      id: -5361927408577734280,
      name: r'batchNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'batchNumber',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'productId': IndexSchema(
      id: 5580769080710688203,
      name: r'productId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'productId',
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
  embeddedSchemas: {r'ProductionMaterialItem': ProductionMaterialItemSchema},
  getId: _detailedProductionLogEntityGetId,
  getLinks: _detailedProductionLogEntityGetLinks,
  attach: _detailedProductionLogEntityAttach,
  version: '3.1.0+1',
);

int _detailedProductionLogEntityEstimateSize(
  DetailedProductionLogEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.additionalRawMaterialsUsed.length * 3;
  {
    final offsets = allOffsets[ProductionMaterialItem]!;
    for (var i = 0; i < object.additionalRawMaterialsUsed.length; i++) {
      final value = object.additionalRawMaterialsUsed[i];
      bytesCount +=
          ProductionMaterialItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.batchNumber.length * 3;
  {
    final value = object.cuttingWastage;
    if (value != null) {
      bytesCount += 3 +
          ProductionMaterialItemSchema.estimateSize(
              value, allOffsets[ProductionMaterialItem]!, allOffsets);
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.issueId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.packagingMaterialsUsed.length * 3;
  {
    final offsets = allOffsets[ProductionMaterialItem]!;
    for (var i = 0; i < object.packagingMaterialsUsed.length; i++) {
      final value = object.packagingMaterialsUsed[i];
      bytesCount +=
          ProductionMaterialItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.productId.length * 3;
  bytesCount += 3 + object.productName.length * 3;
  bytesCount += 3 + object.semiFinishedGoodsUsed.length * 3;
  {
    final offsets = allOffsets[ProductionMaterialItem]!;
    for (var i = 0; i < object.semiFinishedGoodsUsed.length; i++) {
      final value = object.semiFinishedGoodsUsed[i];
      bytesCount +=
          ProductionMaterialItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.supervisorId.length * 3;
  bytesCount += 3 + object.supervisorName.length * 3;
  bytesCount += 3 + object.unit.length * 3;
  return bytesCount;
}

void _detailedProductionLogEntitySerialize(
  DetailedProductionLogEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<ProductionMaterialItem>(
    offsets[0],
    allOffsets,
    ProductionMaterialItemSchema.serialize,
    object.additionalRawMaterialsUsed,
  );
  writer.writeString(offsets[1], object.batchNumber);
  writer.writeDouble(offsets[2], object.costPerUnit);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeObject<ProductionMaterialItem>(
    offsets[4],
    allOffsets,
    ProductionMaterialItemSchema.serialize,
    object.cuttingWastage,
  );
  writer.writeDateTime(offsets[5], object.deletedAt);
  writer.writeString(offsets[6], object.id);
  writer.writeBool(offsets[7], object.isDeleted);
  writer.writeString(offsets[8], object.issueId);
  writer.writeObjectList<ProductionMaterialItem>(
    offsets[9],
    allOffsets,
    ProductionMaterialItemSchema.serialize,
    object.packagingMaterialsUsed,
  );
  writer.writeString(offsets[10], object.productId);
  writer.writeString(offsets[11], object.productName);
  writer.writeObjectList<ProductionMaterialItem>(
    offsets[12],
    allOffsets,
    ProductionMaterialItemSchema.serialize,
    object.semiFinishedGoodsUsed,
  );
  writer.writeString(offsets[13], object.supervisorId);
  writer.writeString(offsets[14], object.supervisorName);
  writer.writeByte(offsets[15], object.syncStatus.index);
  writer.writeDouble(offsets[16], object.totalBatchCost);
  writer.writeLong(offsets[17], object.totalBatchQuantity);
  writer.writeString(offsets[18], object.unit);
  writer.writeDateTime(offsets[19], object.updatedAt);
}

DetailedProductionLogEntity _detailedProductionLogEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetailedProductionLogEntity();
  object.additionalRawMaterialsUsed =
      reader.readObjectList<ProductionMaterialItem>(
            offsets[0],
            ProductionMaterialItemSchema.deserialize,
            allOffsets,
            ProductionMaterialItem(),
          ) ??
          [];
  object.batchNumber = reader.readString(offsets[1]);
  object.costPerUnit = reader.readDouble(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.cuttingWastage = reader.readObjectOrNull<ProductionMaterialItem>(
    offsets[4],
    ProductionMaterialItemSchema.deserialize,
    allOffsets,
  );
  object.deletedAt = reader.readDateTimeOrNull(offsets[5]);
  object.id = reader.readString(offsets[6]);
  object.isDeleted = reader.readBool(offsets[7]);
  object.issueId = reader.readStringOrNull(offsets[8]);
  object.packagingMaterialsUsed = reader.readObjectList<ProductionMaterialItem>(
        offsets[9],
        ProductionMaterialItemSchema.deserialize,
        allOffsets,
        ProductionMaterialItem(),
      ) ??
      [];
  object.productId = reader.readString(offsets[10]);
  object.productName = reader.readString(offsets[11]);
  object.semiFinishedGoodsUsed = reader.readObjectList<ProductionMaterialItem>(
        offsets[12],
        ProductionMaterialItemSchema.deserialize,
        allOffsets,
        ProductionMaterialItem(),
      ) ??
      [];
  object.supervisorId = reader.readString(offsets[13]);
  object.supervisorName = reader.readString(offsets[14]);
  object.syncStatus = _DetailedProductionLogEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[15])] ??
      SyncStatus.pending;
  object.totalBatchCost = reader.readDouble(offsets[16]);
  object.totalBatchQuantity = reader.readLong(offsets[17]);
  object.unit = reader.readString(offsets[18]);
  object.updatedAt = reader.readDateTime(offsets[19]);
  return object;
}

P _detailedProductionLogEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<ProductionMaterialItem>(
            offset,
            ProductionMaterialItemSchema.deserialize,
            allOffsets,
            ProductionMaterialItem(),
          ) ??
          []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readObjectOrNull<ProductionMaterialItem>(
        offset,
        ProductionMaterialItemSchema.deserialize,
        allOffsets,
      )) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readObjectList<ProductionMaterialItem>(
            offset,
            ProductionMaterialItemSchema.deserialize,
            allOffsets,
            ProductionMaterialItem(),
          ) ??
          []) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readObjectList<ProductionMaterialItem>(
            offset,
            ProductionMaterialItemSchema.deserialize,
            allOffsets,
            ProductionMaterialItem(),
          ) ??
          []) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (_DetailedProductionLogEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DetailedProductionLogEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _DetailedProductionLogEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _detailedProductionLogEntityGetId(DetailedProductionLogEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _detailedProductionLogEntityGetLinks(
    DetailedProductionLogEntity object) {
  return [];
}

void _detailedProductionLogEntityAttach(
    IsarCollection<dynamic> col, Id id, DetailedProductionLogEntity object) {}

extension DetailedProductionLogEntityByIndex
    on IsarCollection<DetailedProductionLogEntity> {
  Future<DetailedProductionLogEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  DetailedProductionLogEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<DetailedProductionLogEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<DetailedProductionLogEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(DetailedProductionLogEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(DetailedProductionLogEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<DetailedProductionLogEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<DetailedProductionLogEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension DetailedProductionLogEntityQueryWhereSort on QueryBuilder<
    DetailedProductionLogEntity, DetailedProductionLogEntity, QWhere> {
  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DetailedProductionLogEntityQueryWhere on QueryBuilder<
    DetailedProductionLogEntity, DetailedProductionLogEntity, QWhereClause> {
  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> batchNumberEqualTo(String batchNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'batchNumber',
        value: [batchNumber],
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> batchNumberNotEqualTo(String batchNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [],
              upper: [batchNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [batchNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [batchNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchNumber',
              lower: [],
              upper: [batchNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> productIdEqualTo(String productId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productId',
        value: [productId],
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> productIdNotEqualTo(String productId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [],
              upper: [productId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [productId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [productId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [],
              upper: [productId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

extension DetailedProductionLogEntityQueryFilter on QueryBuilder<
    DetailedProductionLogEntity,
    DetailedProductionLogEntity,
    QFilterCondition> {
  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      additionalRawMaterialsUsedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'additionalRawMaterialsUsed',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> additionalRawMaterialsUsedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'additionalRawMaterialsUsed',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> additionalRawMaterialsUsedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'additionalRawMaterialsUsed',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> additionalRawMaterialsUsedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'additionalRawMaterialsUsed',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> additionalRawMaterialsUsedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'additionalRawMaterialsUsed',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> additionalRawMaterialsUsedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'additionalRawMaterialsUsed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      batchNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      batchNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> batchNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> costPerUnitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costPerUnit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> costPerUnitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costPerUnit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> costPerUnitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costPerUnit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> costPerUnitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costPerUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> cuttingWastageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cuttingWastage',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> cuttingWastageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cuttingWastage',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'issueId',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'issueId',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issueId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      issueIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      issueIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issueId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issueId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> issueIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issueId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> packagingMaterialsUsedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'packagingMaterialsUsed',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> packagingMaterialsUsedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'packagingMaterialsUsed',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> packagingMaterialsUsedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'packagingMaterialsUsed',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> packagingMaterialsUsedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'packagingMaterialsUsed',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> packagingMaterialsUsedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'packagingMaterialsUsed',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> packagingMaterialsUsedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'packagingMaterialsUsed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      productIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      productIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      productNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      productNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> semiFinishedGoodsUsedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semiFinishedGoodsUsed',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> semiFinishedGoodsUsedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semiFinishedGoodsUsed',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> semiFinishedGoodsUsedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semiFinishedGoodsUsed',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> semiFinishedGoodsUsedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semiFinishedGoodsUsed',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> semiFinishedGoodsUsedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semiFinishedGoodsUsed',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> semiFinishedGoodsUsedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semiFinishedGoodsUsed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supervisorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      supervisorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      supervisorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supervisorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supervisorId',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supervisorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      supervisorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      supervisorNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supervisorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorName',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> supervisorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supervisorName',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBatchCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBatchCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBatchCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBatchCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchQuantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBatchQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchQuantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBatchQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchQuantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBatchQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> totalBatchQuantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBatchQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
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
}

extension DetailedProductionLogEntityQueryObject on QueryBuilder<
    DetailedProductionLogEntity,
    DetailedProductionLogEntity,
    QFilterCondition> {
  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      additionalRawMaterialsUsedElement(FilterQuery<ProductionMaterialItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'additionalRawMaterialsUsed');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      cuttingWastage(FilterQuery<ProductionMaterialItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cuttingWastage');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      packagingMaterialsUsedElement(FilterQuery<ProductionMaterialItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'packagingMaterialsUsed');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
          QAfterFilterCondition>
      semiFinishedGoodsUsedElement(FilterQuery<ProductionMaterialItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'semiFinishedGoodsUsed');
    });
  }
}

extension DetailedProductionLogEntityQueryLinks on QueryBuilder<
    DetailedProductionLogEntity,
    DetailedProductionLogEntity,
    QFilterCondition> {}

extension DetailedProductionLogEntityQuerySortBy on QueryBuilder<
    DetailedProductionLogEntity, DetailedProductionLogEntity, QSortBy> {
  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByBatchNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByBatchNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByCostPerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerUnit', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByCostPerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerUnit', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByIssueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByIssueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortBySupervisorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortBySupervisorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByTotalBatchCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByTotalBatchCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByTotalBatchQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchQuantity', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByTotalBatchQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchQuantity', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension DetailedProductionLogEntityQuerySortThenBy on QueryBuilder<
    DetailedProductionLogEntity, DetailedProductionLogEntity, QSortThenBy> {
  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByBatchNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByBatchNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByCostPerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerUnit', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByCostPerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerUnit', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByIssueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByIssueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueId', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenBySupervisorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenBySupervisorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByTotalBatchCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByTotalBatchCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchCost', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByTotalBatchQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchQuantity', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByTotalBatchQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchQuantity', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension DetailedProductionLogEntityQueryWhereDistinct on QueryBuilder<
    DetailedProductionLogEntity, DetailedProductionLogEntity, QDistinct> {
  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByBatchNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByCostPerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costPerUnit');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByIssueId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issueId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctBySupervisorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctBySupervisorName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisorName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByTotalBatchCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBatchCost');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByTotalBatchQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBatchQuantity');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByUnit({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DetailedProductionLogEntity,
      QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension DetailedProductionLogEntityQueryProperty on QueryBuilder<
    DetailedProductionLogEntity, DetailedProductionLogEntity, QQueryProperty> {
  QueryBuilder<DetailedProductionLogEntity, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, List<ProductionMaterialItem>,
      QQueryOperations> additionalRawMaterialsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'additionalRawMaterialsUsed');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String, QQueryOperations>
      batchNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchNumber');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, double, QQueryOperations>
      costPerUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costPerUnit');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, ProductionMaterialItem?,
      QQueryOperations> cuttingWastageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cuttingWastage');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String?, QQueryOperations>
      issueIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issueId');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, List<ProductionMaterialItem>,
      QQueryOperations> packagingMaterialsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packagingMaterialsUsed');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String, QQueryOperations>
      productIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productId');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String, QQueryOperations>
      productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, List<ProductionMaterialItem>,
      QQueryOperations> semiFinishedGoodsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semiFinishedGoodsUsed');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String, QQueryOperations>
      supervisorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisorId');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String, QQueryOperations>
      supervisorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisorName');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, double, QQueryOperations>
      totalBatchCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBatchCost');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, int, QQueryOperations>
      totalBatchQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBatchQuantity');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, String, QQueryOperations>
      unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<DetailedProductionLogEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ProductionMaterialItemSchema = Schema(
  name: r'ProductionMaterialItem',
  id: -2000939599771440065,
  properties: {
    r'movementType': PropertySchema(
      id: 0,
      name: r'movementType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'productId': PropertySchema(
      id: 2,
      name: r'productId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'unit': PropertySchema(
      id: 4,
      name: r'unit',
      type: IsarType.string,
    )
  },
  estimateSize: _productionMaterialItemEstimateSize,
  serialize: _productionMaterialItemSerialize,
  deserialize: _productionMaterialItemDeserialize,
  deserializeProp: _productionMaterialItemDeserializeProp,
);

int _productionMaterialItemEstimateSize(
  ProductionMaterialItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.movementType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.productId.length * 3;
  {
    final value = object.unit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _productionMaterialItemSerialize(
  ProductionMaterialItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.movementType);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.productId);
  writer.writeDouble(offsets[3], object.quantity);
  writer.writeString(offsets[4], object.unit);
}

ProductionMaterialItem _productionMaterialItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductionMaterialItem();
  object.movementType = reader.readString(offsets[0]);
  object.name = reader.readString(offsets[1]);
  object.productId = reader.readString(offsets[2]);
  object.quantity = reader.readDouble(offsets[3]);
  object.unit = reader.readStringOrNull(offsets[4]);
  return object;
}

P _productionMaterialItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ProductionMaterialItemQueryFilter on QueryBuilder<
    ProductionMaterialItem, ProductionMaterialItem, QFilterCondition> {
  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      movementTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      movementTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movementType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> movementTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameBetween(
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      productIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      productIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> productIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
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

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
          QAfterFilterCondition>
      unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductionMaterialItem, ProductionMaterialItem,
      QAfterFilterCondition> unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }
}

extension ProductionMaterialItemQueryObject on QueryBuilder<
    ProductionMaterialItem, ProductionMaterialItem, QFilterCondition> {}
