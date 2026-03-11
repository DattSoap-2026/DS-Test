// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_order_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRouteOrderEntityCollection on Isar {
  IsarCollection<RouteOrderEntity> get routeOrderEntitys => this.collection();
}

const RouteOrderEntitySchema = CollectionSchema(
  name: r'RouteOrderEntity',
  id: 3772208425685658979,
  properties: {
    r'cancelReason': PropertySchema(
      id: 0,
      name: r'cancelReason',
      type: IsarType.string,
    ),
    r'cancelledAt': PropertySchema(
      id: 1,
      name: r'cancelledAt',
      type: IsarType.dateTime,
    ),
    r'cancelledById': PropertySchema(
      id: 2,
      name: r'cancelledById',
      type: IsarType.string,
    ),
    r'cancelledByName': PropertySchema(
      id: 3,
      name: r'cancelledByName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdById': PropertySchema(
      id: 5,
      name: r'createdById',
      type: IsarType.string,
    ),
    r'createdByName': PropertySchema(
      id: 6,
      name: r'createdByName',
      type: IsarType.string,
    ),
    r'createdByRole': PropertySchema(
      id: 7,
      name: r'createdByRole',
      type: IsarType.string,
    ),
    r'dealerId': PropertySchema(
      id: 8,
      name: r'dealerId',
      type: IsarType.string,
    ),
    r'dealerName': PropertySchema(
      id: 9,
      name: r'dealerName',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 10,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'deletedById': PropertySchema(
      id: 11,
      name: r'deletedById',
      type: IsarType.string,
    ),
    r'deletedByName': PropertySchema(
      id: 12,
      name: r'deletedByName',
      type: IsarType.string,
    ),
    r'dispatchBeforeDate': PropertySchema(
      id: 13,
      name: r'dispatchBeforeDate',
      type: IsarType.string,
    ),
    r'dispatchId': PropertySchema(
      id: 14,
      name: r'dispatchId',
      type: IsarType.string,
    ),
    r'dispatchStatus': PropertySchema(
      id: 15,
      name: r'dispatchStatus',
      type: IsarType.string,
    ),
    r'dispatchedAt': PropertySchema(
      id: 16,
      name: r'dispatchedAt',
      type: IsarType.dateTime,
    ),
    r'dispatchedById': PropertySchema(
      id: 17,
      name: r'dispatchedById',
      type: IsarType.string,
    ),
    r'dispatchedByName': PropertySchema(
      id: 18,
      name: r'dispatchedByName',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 19,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 20,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isOrderBasedDispatch': PropertySchema(
      id: 21,
      name: r'isOrderBasedDispatch',
      type: IsarType.bool,
    ),
    r'itemsJson': PropertySchema(
      id: 22,
      name: r'itemsJson',
      type: IsarType.string,
    ),
    r'lastEditedAt': PropertySchema(
      id: 23,
      name: r'lastEditedAt',
      type: IsarType.dateTime,
    ),
    r'lastEditedById': PropertySchema(
      id: 24,
      name: r'lastEditedById',
      type: IsarType.string,
    ),
    r'lastEditedByName': PropertySchema(
      id: 25,
      name: r'lastEditedByName',
      type: IsarType.string,
    ),
    r'orderNo': PropertySchema(
      id: 26,
      name: r'orderNo',
      type: IsarType.string,
    ),
    r'productionStatus': PropertySchema(
      id: 27,
      name: r'productionStatus',
      type: IsarType.string,
    ),
    r'productionUpdatedAt': PropertySchema(
      id: 28,
      name: r'productionUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'productionUpdatedById': PropertySchema(
      id: 29,
      name: r'productionUpdatedById',
      type: IsarType.string,
    ),
    r'productionUpdatedByName': PropertySchema(
      id: 30,
      name: r'productionUpdatedByName',
      type: IsarType.string,
    ),
    r'routeId': PropertySchema(
      id: 31,
      name: r'routeId',
      type: IsarType.string,
    ),
    r'routeName': PropertySchema(
      id: 32,
      name: r'routeName',
      type: IsarType.string,
    ),
    r'salesmanId': PropertySchema(
      id: 33,
      name: r'salesmanId',
      type: IsarType.string,
    ),
    r'salesmanName': PropertySchema(
      id: 34,
      name: r'salesmanName',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 35,
      name: r'source',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 36,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _RouteOrderEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 37,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _routeOrderEntityEstimateSize,
  serialize: _routeOrderEntitySerialize,
  deserialize: _routeOrderEntityDeserialize,
  deserializeProp: _routeOrderEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'routeId': IndexSchema(
      id: 3544562048266535092,
      name: r'routeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'routeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'salesmanId': IndexSchema(
      id: 6029406009596130287,
      name: r'salesmanId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'salesmanId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'productionStatus': IndexSchema(
      id: 6502121614945923634,
      name: r'productionStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'productionStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dispatchStatus': IndexSchema(
      id: 8699895592795208211,
      name: r'dispatchStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dispatchStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
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
  getId: _routeOrderEntityGetId,
  getLinks: _routeOrderEntityGetLinks,
  attach: _routeOrderEntityAttach,
  version: '3.1.0+1',
);

int _routeOrderEntityEstimateSize(
  RouteOrderEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cancelReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cancelledById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cancelledByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.createdById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.createdByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.createdByRole.length * 3;
  bytesCount += 3 + object.dealerId.length * 3;
  bytesCount += 3 + object.dealerName.length * 3;
  {
    final value = object.deletedById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.deletedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dispatchBeforeDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dispatchId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dispatchStatus.length * 3;
  {
    final value = object.dispatchedById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dispatchedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.itemsJson.length * 3;
  {
    final value = object.lastEditedById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastEditedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.orderNo.length * 3;
  bytesCount += 3 + object.productionStatus.length * 3;
  {
    final value = object.productionUpdatedById;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.productionUpdatedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.routeId.length * 3;
  bytesCount += 3 + object.routeName.length * 3;
  bytesCount += 3 + object.salesmanId.length * 3;
  bytesCount += 3 + object.salesmanName.length * 3;
  bytesCount += 3 + object.source.length * 3;
  return bytesCount;
}

void _routeOrderEntitySerialize(
  RouteOrderEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cancelReason);
  writer.writeDateTime(offsets[1], object.cancelledAt);
  writer.writeString(offsets[2], object.cancelledById);
  writer.writeString(offsets[3], object.cancelledByName);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.createdById);
  writer.writeString(offsets[6], object.createdByName);
  writer.writeString(offsets[7], object.createdByRole);
  writer.writeString(offsets[8], object.dealerId);
  writer.writeString(offsets[9], object.dealerName);
  writer.writeDateTime(offsets[10], object.deletedAt);
  writer.writeString(offsets[11], object.deletedById);
  writer.writeString(offsets[12], object.deletedByName);
  writer.writeString(offsets[13], object.dispatchBeforeDate);
  writer.writeString(offsets[14], object.dispatchId);
  writer.writeString(offsets[15], object.dispatchStatus);
  writer.writeDateTime(offsets[16], object.dispatchedAt);
  writer.writeString(offsets[17], object.dispatchedById);
  writer.writeString(offsets[18], object.dispatchedByName);
  writer.writeString(offsets[19], object.id);
  writer.writeBool(offsets[20], object.isDeleted);
  writer.writeBool(offsets[21], object.isOrderBasedDispatch);
  writer.writeString(offsets[22], object.itemsJson);
  writer.writeDateTime(offsets[23], object.lastEditedAt);
  writer.writeString(offsets[24], object.lastEditedById);
  writer.writeString(offsets[25], object.lastEditedByName);
  writer.writeString(offsets[26], object.orderNo);
  writer.writeString(offsets[27], object.productionStatus);
  writer.writeDateTime(offsets[28], object.productionUpdatedAt);
  writer.writeString(offsets[29], object.productionUpdatedById);
  writer.writeString(offsets[30], object.productionUpdatedByName);
  writer.writeString(offsets[31], object.routeId);
  writer.writeString(offsets[32], object.routeName);
  writer.writeString(offsets[33], object.salesmanId);
  writer.writeString(offsets[34], object.salesmanName);
  writer.writeString(offsets[35], object.source);
  writer.writeByte(offsets[36], object.syncStatus.index);
  writer.writeDateTime(offsets[37], object.updatedAt);
}

RouteOrderEntity _routeOrderEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RouteOrderEntity();
  object.cancelReason = reader.readStringOrNull(offsets[0]);
  object.cancelledAt = reader.readDateTimeOrNull(offsets[1]);
  object.cancelledById = reader.readStringOrNull(offsets[2]);
  object.cancelledByName = reader.readStringOrNull(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.createdById = reader.readStringOrNull(offsets[5]);
  object.createdByName = reader.readStringOrNull(offsets[6]);
  object.createdByRole = reader.readString(offsets[7]);
  object.dealerId = reader.readString(offsets[8]);
  object.dealerName = reader.readString(offsets[9]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[10]);
  object.deletedById = reader.readStringOrNull(offsets[11]);
  object.deletedByName = reader.readStringOrNull(offsets[12]);
  object.dispatchBeforeDate = reader.readStringOrNull(offsets[13]);
  object.dispatchId = reader.readStringOrNull(offsets[14]);
  object.dispatchStatus = reader.readString(offsets[15]);
  object.dispatchedAt = reader.readDateTimeOrNull(offsets[16]);
  object.dispatchedById = reader.readStringOrNull(offsets[17]);
  object.dispatchedByName = reader.readStringOrNull(offsets[18]);
  object.id = reader.readString(offsets[19]);
  object.isDeleted = reader.readBool(offsets[20]);
  object.isOrderBasedDispatch = reader.readBool(offsets[21]);
  object.itemsJson = reader.readString(offsets[22]);
  object.lastEditedAt = reader.readDateTimeOrNull(offsets[23]);
  object.lastEditedById = reader.readStringOrNull(offsets[24]);
  object.lastEditedByName = reader.readStringOrNull(offsets[25]);
  object.orderNo = reader.readString(offsets[26]);
  object.productionStatus = reader.readString(offsets[27]);
  object.productionUpdatedAt = reader.readDateTimeOrNull(offsets[28]);
  object.productionUpdatedById = reader.readStringOrNull(offsets[29]);
  object.productionUpdatedByName = reader.readStringOrNull(offsets[30]);
  object.routeId = reader.readString(offsets[31]);
  object.routeName = reader.readString(offsets[32]);
  object.salesmanId = reader.readString(offsets[33]);
  object.salesmanName = reader.readString(offsets[34]);
  object.source = reader.readString(offsets[35]);
  object.syncStatus = _RouteOrderEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[36])] ??
      SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[37]);
  return object;
}

P _routeOrderEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readString(offset)) as P;
    case 35:
      return (reader.readString(offset)) as P;
    case 36:
      return (_RouteOrderEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 37:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RouteOrderEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _RouteOrderEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _routeOrderEntityGetId(RouteOrderEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _routeOrderEntityGetLinks(RouteOrderEntity object) {
  return [];
}

void _routeOrderEntityAttach(
    IsarCollection<dynamic> col, Id id, RouteOrderEntity object) {}

extension RouteOrderEntityByIndex on IsarCollection<RouteOrderEntity> {
  Future<RouteOrderEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  RouteOrderEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<RouteOrderEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<RouteOrderEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(RouteOrderEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(RouteOrderEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<RouteOrderEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<RouteOrderEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension RouteOrderEntityQueryWhereSort
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QWhere> {
  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension RouteOrderEntityQueryWhere
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QWhereClause> {
  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      routeIdEqualTo(String routeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'routeId',
        value: [routeId],
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      routeIdNotEqualTo(String routeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [],
              upper: [routeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [routeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [routeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [],
              upper: [routeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      salesmanIdEqualTo(String salesmanId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salesmanId',
        value: [salesmanId],
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      salesmanIdNotEqualTo(String salesmanId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salesmanId',
              lower: [],
              upper: [salesmanId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salesmanId',
              lower: [salesmanId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salesmanId',
              lower: [salesmanId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salesmanId',
              lower: [],
              upper: [salesmanId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      productionStatusEqualTo(String productionStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productionStatus',
        value: [productionStatus],
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      productionStatusNotEqualTo(String productionStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productionStatus',
              lower: [],
              upper: [productionStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productionStatus',
              lower: [productionStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productionStatus',
              lower: [productionStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productionStatus',
              lower: [],
              upper: [productionStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      dispatchStatusEqualTo(String dispatchStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dispatchStatus',
        value: [dispatchStatus],
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      dispatchStatusNotEqualTo(String dispatchStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dispatchStatus',
              lower: [],
              upper: [dispatchStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dispatchStatus',
              lower: [dispatchStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dispatchStatus',
              lower: [dispatchStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dispatchStatus',
              lower: [],
              upper: [dispatchStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterWhereClause>
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

extension RouteOrderEntityQueryFilter
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QFilterCondition> {
  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelReason',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelReason',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelReason',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelReason',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cancelledById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cancelledById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelledById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelledById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelledById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelledByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      cancelledByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelledByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdByRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdByRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdByRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdByRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByRole',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      createdByRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdByRole',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dealerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dealerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dealerId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dealerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dealerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dealerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dealerName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deletedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deletedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deletedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deletedById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deletedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deletedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deletedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deletedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deletedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      deletedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deletedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dispatchBeforeDate',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dispatchBeforeDate',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchBeforeDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dispatchBeforeDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dispatchBeforeDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dispatchBeforeDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dispatchBeforeDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dispatchBeforeDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dispatchBeforeDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dispatchBeforeDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchBeforeDate',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchBeforeDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dispatchBeforeDate',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dispatchId',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dispatchId',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dispatchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dispatchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dispatchId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dispatchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dispatchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dispatchId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dispatchId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dispatchId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dispatchStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dispatchStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dispatchStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dispatchStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dispatchStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dispatchStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dispatchStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dispatchStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dispatchedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dispatchedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dispatchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dispatchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dispatchedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dispatchedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dispatchedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dispatchedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dispatchedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dispatchedById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dispatchedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dispatchedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dispatchedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dispatchedById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dispatchedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dispatchedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dispatchedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dispatchedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dispatchedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dispatchedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dispatchedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dispatchedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dispatchedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dispatchedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      dispatchedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dispatchedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      isOrderBasedDispatchEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOrderBasedDispatch',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      itemsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastEditedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastEditedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEditedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEditedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEditedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEditedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastEditedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastEditedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEditedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEditedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEditedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEditedById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastEditedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastEditedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastEditedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastEditedById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEditedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastEditedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastEditedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastEditedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEditedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEditedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEditedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEditedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastEditedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastEditedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastEditedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastEditedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEditedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      lastEditedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastEditedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'orderNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'orderNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'orderNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'orderNo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderNo',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      orderNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'orderNo',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productionStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productionStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productionStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productionStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productionUpdatedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productionUpdatedAt',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productionUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productionUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productionUpdatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productionUpdatedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productionUpdatedById',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionUpdatedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productionUpdatedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productionUpdatedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productionUpdatedById',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productionUpdatedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productionUpdatedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productionUpdatedById',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productionUpdatedById',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionUpdatedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productionUpdatedById',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productionUpdatedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productionUpdatedByName',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionUpdatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productionUpdatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productionUpdatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productionUpdatedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productionUpdatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productionUpdatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productionUpdatedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productionUpdatedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productionUpdatedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      productionUpdatedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productionUpdatedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'routeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'routeId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameEqualTo(
    String value, {
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameGreaterThan(
    String value, {
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameLessThan(
    String value, {
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'routeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'routeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      routeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'routeName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'salesmanId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'salesmanName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      salesmanNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterFilterCondition>
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

extension RouteOrderEntityQueryObject
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QFilterCondition> {}

extension RouteOrderEntityQueryLinks
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QFilterCondition> {}

extension RouteOrderEntityQuerySortBy
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QSortBy> {
  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelledById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelledByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelledByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCancelledByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByCreatedByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDealerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDealerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDealerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDealerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDeletedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDeletedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDeletedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDeletedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchBeforeDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchBeforeDate', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchBeforeDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchBeforeDate', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchStatus', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchStatus', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByDispatchedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByIsOrderBasedDispatch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOrderBasedDispatch', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByIsOrderBasedDispatchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOrderBasedDispatch', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByItemsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByItemsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByLastEditedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByLastEditedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByLastEditedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByLastEditedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByLastEditedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByLastEditedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByOrderNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByOrderNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStatus', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStatus', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionUpdatedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionUpdatedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionUpdatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByProductionUpdatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByRouteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByRouteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RouteOrderEntityQuerySortThenBy
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QSortThenBy> {
  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelledById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelledByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelledByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCancelledByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByCreatedByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDealerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDealerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDealerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDealerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDeletedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDeletedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDeletedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDeletedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchBeforeDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchBeforeDate', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchBeforeDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchBeforeDate', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchStatus', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchStatus', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByDispatchedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByIsOrderBasedDispatch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOrderBasedDispatch', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByIsOrderBasedDispatchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOrderBasedDispatch', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByItemsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByItemsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByLastEditedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByLastEditedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByLastEditedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByLastEditedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByLastEditedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByLastEditedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEditedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByOrderNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByOrderNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStatus', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionStatus', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionUpdatedById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedById', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionUpdatedByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedById', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionUpdatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedByName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByProductionUpdatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productionUpdatedByName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByRouteName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByRouteNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RouteOrderEntityQueryWhereDistinct
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct> {
  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCancelReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledAt');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCancelledById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledById',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCancelledByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCreatedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdById', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCreatedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByCreatedByRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByRole',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDealerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dealerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDealerName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dealerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDeletedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedById', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDeletedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDispatchBeforeDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dispatchBeforeDate',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDispatchId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dispatchId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDispatchStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dispatchStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDispatchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dispatchedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDispatchedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dispatchedById',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByDispatchedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dispatchedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByIsOrderBasedDispatch() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOrderBasedDispatch');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByItemsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByLastEditedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEditedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByLastEditedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEditedById',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByLastEditedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEditedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct> distinctByOrderNo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderNo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByProductionStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productionStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByProductionUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productionUpdatedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByProductionUpdatedById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productionUpdatedById',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByProductionUpdatedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productionUpdatedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct> distinctByRouteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByRouteName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctBySalesmanId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctBySalesmanName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<RouteOrderEntity, RouteOrderEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension RouteOrderEntityQueryProperty
    on QueryBuilder<RouteOrderEntity, RouteOrderEntity, QQueryProperty> {
  QueryBuilder<RouteOrderEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      cancelReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelReason');
    });
  }

  QueryBuilder<RouteOrderEntity, DateTime?, QQueryOperations>
      cancelledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledAt');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      cancelledByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledById');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      cancelledByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledByName');
    });
  }

  QueryBuilder<RouteOrderEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      createdByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdById');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      createdByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByName');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations>
      createdByRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByRole');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations> dealerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dealerId');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations>
      dealerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dealerName');
    });
  }

  QueryBuilder<RouteOrderEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      deletedByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedById');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      deletedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedByName');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      dispatchBeforeDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dispatchBeforeDate');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      dispatchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dispatchId');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations>
      dispatchStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dispatchStatus');
    });
  }

  QueryBuilder<RouteOrderEntity, DateTime?, QQueryOperations>
      dispatchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dispatchedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      dispatchedByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dispatchedById');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      dispatchedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dispatchedByName');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RouteOrderEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<RouteOrderEntity, bool, QQueryOperations>
      isOrderBasedDispatchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOrderBasedDispatch');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations> itemsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemsJson');
    });
  }

  QueryBuilder<RouteOrderEntity, DateTime?, QQueryOperations>
      lastEditedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEditedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      lastEditedByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEditedById');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      lastEditedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEditedByName');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations> orderNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderNo');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations>
      productionStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productionStatus');
    });
  }

  QueryBuilder<RouteOrderEntity, DateTime?, QQueryOperations>
      productionUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productionUpdatedAt');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      productionUpdatedByIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productionUpdatedById');
    });
  }

  QueryBuilder<RouteOrderEntity, String?, QQueryOperations>
      productionUpdatedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productionUpdatedByName');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations> routeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeId');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations> routeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeName');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations>
      salesmanIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanId');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations>
      salesmanNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanName');
    });
  }

  QueryBuilder<RouteOrderEntity, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<RouteOrderEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<RouteOrderEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
