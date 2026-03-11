// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSaleEntityCollection on Isar {
  IsarCollection<SaleEntity> get saleEntitys => this.collection();
}

const SaleEntitySchema = CollectionSchema(
  name: r'SaleEntity',
  id: -5784553327846138448,
  properties: {
    r'additionalDiscountAmount': PropertySchema(
      id: 0,
      name: r'additionalDiscountAmount',
      type: IsarType.double,
    ),
    r'additionalDiscountPercentage': PropertySchema(
      id: 1,
      name: r'additionalDiscountPercentage',
      type: IsarType.double,
    ),
    r'cancelReason': PropertySchema(
      id: 2,
      name: r'cancelReason',
      type: IsarType.string,
    ),
    r'cancelledAt': PropertySchema(
      id: 3,
      name: r'cancelledAt',
      type: IsarType.string,
    ),
    r'cancelledBy': PropertySchema(
      id: 4,
      name: r'cancelledBy',
      type: IsarType.string,
    ),
    r'cgstAmount': PropertySchema(
      id: 5,
      name: r'cgstAmount',
      type: IsarType.double,
    ),
    r'commissionAmount': PropertySchema(
      id: 6,
      name: r'commissionAmount',
      type: IsarType.double,
    ),
    r'commissionType': PropertySchema(
      id: 7,
      name: r'commissionType',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 8,
      name: r'createdAt',
      type: IsarType.string,
    ),
    r'createdByRole': PropertySchema(
      id: 9,
      name: r'createdByRole',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 10,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'discountAmount': PropertySchema(
      id: 11,
      name: r'discountAmount',
      type: IsarType.double,
    ),
    r'discountPercentage': PropertySchema(
      id: 12,
      name: r'discountPercentage',
      type: IsarType.double,
    ),
    r'dispatchRequired': PropertySchema(
      id: 13,
      name: r'dispatchRequired',
      type: IsarType.bool,
    ),
    r'gstPercentage': PropertySchema(
      id: 14,
      name: r'gstPercentage',
      type: IsarType.double,
    ),
    r'gstType': PropertySchema(
      id: 15,
      name: r'gstType',
      type: IsarType.string,
    ),
    r'humanReadableId': PropertySchema(
      id: 16,
      name: r'humanReadableId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 17,
      name: r'id',
      type: IsarType.string,
    ),
    r'igstAmount': PropertySchema(
      id: 18,
      name: r'igstAmount',
      type: IsarType.double,
    ),
    r'isDeleted': PropertySchema(
      id: 19,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'itemDiscountAmount': PropertySchema(
      id: 20,
      name: r'itemDiscountAmount',
      type: IsarType.double,
    ),
    r'itemProductIds': PropertySchema(
      id: 21,
      name: r'itemProductIds',
      type: IsarType.stringList,
    ),
    r'items': PropertySchema(
      id: 22,
      name: r'items',
      type: IsarType.objectList,
      target: r'SaleItemEntity',
    ),
    r'month': PropertySchema(
      id: 23,
      name: r'month',
      type: IsarType.long,
    ),
    r'paidAmount': PropertySchema(
      id: 24,
      name: r'paidAmount',
      type: IsarType.double,
    ),
    r'paymentStatus': PropertySchema(
      id: 25,
      name: r'paymentStatus',
      type: IsarType.string,
    ),
    r'recipientId': PropertySchema(
      id: 26,
      name: r'recipientId',
      type: IsarType.string,
    ),
    r'recipientName': PropertySchema(
      id: 27,
      name: r'recipientName',
      type: IsarType.string,
    ),
    r'recipientType': PropertySchema(
      id: 28,
      name: r'recipientType',
      type: IsarType.string,
    ),
    r'roundOff': PropertySchema(
      id: 29,
      name: r'roundOff',
      type: IsarType.double,
    ),
    r'route': PropertySchema(
      id: 30,
      name: r'route',
      type: IsarType.string,
    ),
    r'saleType': PropertySchema(
      id: 31,
      name: r'saleType',
      type: IsarType.string,
    ),
    r'salesmanId': PropertySchema(
      id: 32,
      name: r'salesmanId',
      type: IsarType.string,
    ),
    r'salesmanName': PropertySchema(
      id: 33,
      name: r'salesmanName',
      type: IsarType.string,
    ),
    r'sgstAmount': PropertySchema(
      id: 34,
      name: r'sgstAmount',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 35,
      name: r'status',
      type: IsarType.string,
    ),
    r'subtotal': PropertySchema(
      id: 36,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'syncStatus': PropertySchema(
      id: 37,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _SaleEntitysyncStatusEnumValueMap,
    ),
    r'taxableAmount': PropertySchema(
      id: 38,
      name: r'taxableAmount',
      type: IsarType.double,
    ),
    r'totalAmount': PropertySchema(
      id: 39,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'tripId': PropertySchema(
      id: 40,
      name: r'tripId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 41,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'vehicleNumber': PropertySchema(
      id: 42,
      name: r'vehicleNumber',
      type: IsarType.string,
    ),
    r'year': PropertySchema(
      id: 43,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _saleEntityEstimateSize,
  serialize: _saleEntitySerialize,
  deserialize: _saleEntityDeserialize,
  deserializeProp: _saleEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'humanReadableId': IndexSchema(
      id: 6529491649427260140,
      name: r'humanReadableId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'humanReadableId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'recipientType': IndexSchema(
      id: -7120346817217072765,
      name: r'recipientType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recipientType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'recipientId': IndexSchema(
      id: 3707675062653042085,
      name: r'recipientId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recipientId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'tripId': IndexSchema(
      id: 7734156669642746260,
      name: r'tripId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tripId',
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
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
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
  embeddedSchemas: {r'SaleItemEntity': SaleItemEntitySchema},
  getId: _saleEntityGetId,
  getLinks: _saleEntityGetLinks,
  attach: _saleEntityAttach,
  version: '3.1.0+1',
);

int _saleEntityEstimateSize(
  SaleEntity object,
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
    final value = object.cancelledAt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cancelledBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.commissionType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.createdAt.length * 3;
  {
    final value = object.createdByRole;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gstType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.humanReadableId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final list = object.itemProductIds;
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
    final list = object.items;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[SaleItemEntity]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              SaleItemEntitySchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.paymentStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.recipientId.length * 3;
  bytesCount += 3 + object.recipientName.length * 3;
  bytesCount += 3 + object.recipientType.length * 3;
  {
    final value = object.route;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.saleType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.salesmanId.length * 3;
  bytesCount += 3 + object.salesmanName.length * 3;
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tripId;
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

void _saleEntitySerialize(
  SaleEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.additionalDiscountAmount);
  writer.writeDouble(offsets[1], object.additionalDiscountPercentage);
  writer.writeString(offsets[2], object.cancelReason);
  writer.writeString(offsets[3], object.cancelledAt);
  writer.writeString(offsets[4], object.cancelledBy);
  writer.writeDouble(offsets[5], object.cgstAmount);
  writer.writeDouble(offsets[6], object.commissionAmount);
  writer.writeString(offsets[7], object.commissionType);
  writer.writeString(offsets[8], object.createdAt);
  writer.writeString(offsets[9], object.createdByRole);
  writer.writeDateTime(offsets[10], object.deletedAt);
  writer.writeDouble(offsets[11], object.discountAmount);
  writer.writeDouble(offsets[12], object.discountPercentage);
  writer.writeBool(offsets[13], object.dispatchRequired);
  writer.writeDouble(offsets[14], object.gstPercentage);
  writer.writeString(offsets[15], object.gstType);
  writer.writeString(offsets[16], object.humanReadableId);
  writer.writeString(offsets[17], object.id);
  writer.writeDouble(offsets[18], object.igstAmount);
  writer.writeBool(offsets[19], object.isDeleted);
  writer.writeDouble(offsets[20], object.itemDiscountAmount);
  writer.writeStringList(offsets[21], object.itemProductIds);
  writer.writeObjectList<SaleItemEntity>(
    offsets[22],
    allOffsets,
    SaleItemEntitySchema.serialize,
    object.items,
  );
  writer.writeLong(offsets[23], object.month);
  writer.writeDouble(offsets[24], object.paidAmount);
  writer.writeString(offsets[25], object.paymentStatus);
  writer.writeString(offsets[26], object.recipientId);
  writer.writeString(offsets[27], object.recipientName);
  writer.writeString(offsets[28], object.recipientType);
  writer.writeDouble(offsets[29], object.roundOff);
  writer.writeString(offsets[30], object.route);
  writer.writeString(offsets[31], object.saleType);
  writer.writeString(offsets[32], object.salesmanId);
  writer.writeString(offsets[33], object.salesmanName);
  writer.writeDouble(offsets[34], object.sgstAmount);
  writer.writeString(offsets[35], object.status);
  writer.writeDouble(offsets[36], object.subtotal);
  writer.writeByte(offsets[37], object.syncStatus.index);
  writer.writeDouble(offsets[38], object.taxableAmount);
  writer.writeDouble(offsets[39], object.totalAmount);
  writer.writeString(offsets[40], object.tripId);
  writer.writeDateTime(offsets[41], object.updatedAt);
  writer.writeString(offsets[42], object.vehicleNumber);
  writer.writeLong(offsets[43], object.year);
}

SaleEntity _saleEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SaleEntity();
  object.additionalDiscountAmount = reader.readDoubleOrNull(offsets[0]);
  object.additionalDiscountPercentage = reader.readDoubleOrNull(offsets[1]);
  object.cancelReason = reader.readStringOrNull(offsets[2]);
  object.cancelledAt = reader.readStringOrNull(offsets[3]);
  object.cancelledBy = reader.readStringOrNull(offsets[4]);
  object.cgstAmount = reader.readDoubleOrNull(offsets[5]);
  object.commissionAmount = reader.readDoubleOrNull(offsets[6]);
  object.commissionType = reader.readStringOrNull(offsets[7]);
  object.createdAt = reader.readString(offsets[8]);
  object.createdByRole = reader.readStringOrNull(offsets[9]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[10]);
  object.discountAmount = reader.readDoubleOrNull(offsets[11]);
  object.discountPercentage = reader.readDoubleOrNull(offsets[12]);
  object.dispatchRequired = reader.readBoolOrNull(offsets[13]);
  object.gstPercentage = reader.readDoubleOrNull(offsets[14]);
  object.gstType = reader.readStringOrNull(offsets[15]);
  object.humanReadableId = reader.readStringOrNull(offsets[16]);
  object.id = reader.readString(offsets[17]);
  object.igstAmount = reader.readDoubleOrNull(offsets[18]);
  object.isDeleted = reader.readBool(offsets[19]);
  object.itemDiscountAmount = reader.readDoubleOrNull(offsets[20]);
  object.itemProductIds = reader.readStringList(offsets[21]);
  object.items = reader.readObjectList<SaleItemEntity>(
    offsets[22],
    SaleItemEntitySchema.deserialize,
    allOffsets,
    SaleItemEntity(),
  );
  object.month = reader.readLongOrNull(offsets[23]);
  object.paidAmount = reader.readDoubleOrNull(offsets[24]);
  object.paymentStatus = reader.readStringOrNull(offsets[25]);
  object.recipientId = reader.readString(offsets[26]);
  object.recipientName = reader.readString(offsets[27]);
  object.recipientType = reader.readString(offsets[28]);
  object.roundOff = reader.readDoubleOrNull(offsets[29]);
  object.route = reader.readStringOrNull(offsets[30]);
  object.saleType = reader.readStringOrNull(offsets[31]);
  object.salesmanId = reader.readString(offsets[32]);
  object.salesmanName = reader.readString(offsets[33]);
  object.sgstAmount = reader.readDoubleOrNull(offsets[34]);
  object.status = reader.readStringOrNull(offsets[35]);
  object.subtotal = reader.readDoubleOrNull(offsets[36]);
  object.syncStatus =
      _SaleEntitysyncStatusValueEnumMap[reader.readByteOrNull(offsets[37])] ??
          SyncStatus.pending;
  object.taxableAmount = reader.readDoubleOrNull(offsets[38]);
  object.totalAmount = reader.readDoubleOrNull(offsets[39]);
  object.tripId = reader.readStringOrNull(offsets[40]);
  object.updatedAt = reader.readDateTime(offsets[41]);
  object.vehicleNumber = reader.readStringOrNull(offsets[42]);
  object.year = reader.readLongOrNull(offsets[43]);
  return object;
}

P _saleEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readBoolOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readDoubleOrNull(offset)) as P;
    case 21:
      return (reader.readStringList(offset)) as P;
    case 22:
      return (reader.readObjectList<SaleItemEntity>(
        offset,
        SaleItemEntitySchema.deserialize,
        allOffsets,
        SaleItemEntity(),
      )) as P;
    case 23:
      return (reader.readLongOrNull(offset)) as P;
    case 24:
      return (reader.readDoubleOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readDoubleOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readDoubleOrNull(offset)) as P;
    case 35:
      return (reader.readStringOrNull(offset)) as P;
    case 36:
      return (reader.readDoubleOrNull(offset)) as P;
    case 37:
      return (_SaleEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 38:
      return (reader.readDoubleOrNull(offset)) as P;
    case 39:
      return (reader.readDoubleOrNull(offset)) as P;
    case 40:
      return (reader.readStringOrNull(offset)) as P;
    case 41:
      return (reader.readDateTime(offset)) as P;
    case 42:
      return (reader.readStringOrNull(offset)) as P;
    case 43:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SaleEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _SaleEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _saleEntityGetId(SaleEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _saleEntityGetLinks(SaleEntity object) {
  return [];
}

void _saleEntityAttach(IsarCollection<dynamic> col, Id id, SaleEntity object) {}

extension SaleEntityByIndex on IsarCollection<SaleEntity> {
  Future<SaleEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  SaleEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<SaleEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<SaleEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(SaleEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(SaleEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<SaleEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<SaleEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension SaleEntityQueryWhereSort
    on QueryBuilder<SaleEntity, SaleEntity, QWhere> {
  QueryBuilder<SaleEntity, SaleEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SaleEntityQueryWhere
    on QueryBuilder<SaleEntity, SaleEntity, QWhereClause> {
  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> isarIdNotEqualTo(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause>
      humanReadableIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'humanReadableId',
        value: [null],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause>
      humanReadableIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'humanReadableId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause>
      humanReadableIdEqualTo(String? humanReadableId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'humanReadableId',
        value: [humanReadableId],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause>
      humanReadableIdNotEqualTo(String? humanReadableId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'humanReadableId',
              lower: [],
              upper: [humanReadableId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'humanReadableId',
              lower: [humanReadableId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'humanReadableId',
              lower: [humanReadableId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'humanReadableId',
              lower: [],
              upper: [humanReadableId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> recipientTypeEqualTo(
      String recipientType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recipientType',
        value: [recipientType],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause>
      recipientTypeNotEqualTo(String recipientType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientType',
              lower: [],
              upper: [recipientType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientType',
              lower: [recipientType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientType',
              lower: [recipientType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientType',
              lower: [],
              upper: [recipientType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> recipientIdEqualTo(
      String recipientId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recipientId',
        value: [recipientId],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> recipientIdNotEqualTo(
      String recipientId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientId',
              lower: [],
              upper: [recipientId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientId',
              lower: [recipientId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientId',
              lower: [recipientId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recipientId',
              lower: [],
              upper: [recipientId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> tripIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tripId',
        value: [null],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> tripIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tripId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> tripIdEqualTo(
      String? tripId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tripId',
        value: [tripId],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> tripIdNotEqualTo(
      String? tripId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tripId',
              lower: [],
              upper: [tripId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tripId',
              lower: [tripId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tripId',
              lower: [tripId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tripId',
              lower: [],
              upper: [tripId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [null],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> statusEqualTo(
      String? status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> statusNotEqualTo(
      String? status) {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> salesmanIdEqualTo(
      String salesmanId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salesmanId',
        value: [salesmanId],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> salesmanIdNotEqualTo(
      String salesmanId) {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> createdAtEqualTo(
      String createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> createdAtNotEqualTo(
      String createdAt) {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterWhereClause> idNotEqualTo(
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

extension SaleEntityQueryFilter
    on QueryBuilder<SaleEntity, SaleEntity, QFilterCondition> {
  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'additionalDiscountAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'additionalDiscountAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'additionalDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'additionalDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'additionalDiscountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'additionalDiscountPercentage',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'additionalDiscountPercentage',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountPercentageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountPercentageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'additionalDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountPercentageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'additionalDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      additionalDiscountPercentageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'additionalDiscountPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelReason',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelReason',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelReason',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelReason',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cancelledAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cancelledAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelledAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelledAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelledAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledBy',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledBy',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelledBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledBy',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cancelledByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelledBy',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cgstAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cgstAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cgstAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cgstAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> cgstAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cgstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cgstAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cgstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      cgstAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cgstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> cgstAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cgstAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'commissionAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'commissionAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commissionAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commissionAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commissionAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commissionAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'commissionType',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'commissionType',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commissionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commissionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commissionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commissionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'commissionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'commissionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'commissionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'commissionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commissionType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      commissionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'commissionType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> createdAtEqualTo(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> createdAtEndsWith(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> createdAtContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> createdAtMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdByRole',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdByRole',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleEqualTo(
    String? value, {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleGreaterThan(
    String? value, {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleLessThan(
    String? value, {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdByRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdByRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByRole',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      createdByRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdByRole',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> deletedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> deletedAtLessThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> deletedAtBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discountAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discountAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discountPercentage',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discountPercentage',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountPercentageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountPercentageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountPercentageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      discountPercentageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discountPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      dispatchRequiredIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dispatchRequired',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      dispatchRequiredIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dispatchRequired',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      dispatchRequiredEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dispatchRequired',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gstPercentage',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gstPercentage',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstPercentageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gstPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstPercentageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gstPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstPercentageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gstPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstPercentageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gstPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gstType',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gstType',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gstType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gstType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gstType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gstType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gstType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gstType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gstType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gstType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> gstTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gstType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      gstTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gstType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'humanReadableId',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'humanReadableId',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'humanReadableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'humanReadableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'humanReadableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'humanReadableId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'humanReadableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'humanReadableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'humanReadableId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'humanReadableId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'humanReadableId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      humanReadableIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'humanReadableId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idContains(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idMatches(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      igstAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'igstAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      igstAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'igstAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> igstAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'igstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      igstAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'igstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      igstAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'igstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> igstAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'igstAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> isDeletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemDiscountAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itemDiscountAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemDiscountAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itemDiscountAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemDiscountAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemDiscountAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemDiscountAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemDiscountAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemDiscountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itemProductIds',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itemProductIds',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemProductIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemProductIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemProductIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemProductIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemProductIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemProductIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemProductIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemProductIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemProductIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemProductIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemProductIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemProductIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemProductIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemProductIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemProductIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemProductIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemProductIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> itemsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> itemsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'items',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemsLengthEqualTo(int length) {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> itemsIsEmpty() {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemsIsNotEmpty() {
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemsLengthLessThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemsLengthGreaterThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      itemsLengthBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> monthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'month',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> monthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'month',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> monthEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> monthGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> monthLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> monthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'month',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paidAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paidAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paidAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paidAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> paidAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paidAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paidAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> paidAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentStatus',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentStatus',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      paymentStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipientId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipientId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipientId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipientName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipientName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipientName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipientType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipientType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipientType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipientType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipientType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipientType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipientType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      recipientTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipientType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> roundOffIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'roundOff',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      roundOffIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'roundOff',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> roundOffEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roundOff',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      roundOffGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roundOff',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> roundOffLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roundOff',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> roundOffBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roundOff',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'route',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'route',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'route',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'route',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> routeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      routeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> saleTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saleType',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      saleTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saleType',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> saleTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      saleTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> saleTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> saleTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saleType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      saleTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'saleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> saleTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'saleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> saleTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> saleTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saleType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      saleTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      saleTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saleType',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> salesmanIdEqualTo(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> salesmanIdBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      salesmanIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> salesmanIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      salesmanIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      salesmanIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      salesmanNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      salesmanNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      salesmanNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      salesmanNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      sgstAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sgstAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      sgstAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sgstAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> sgstAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sgstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      sgstAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sgstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      sgstAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sgstAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> sgstAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sgstAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusGreaterThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusLessThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusContains(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusMatches(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> subtotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subtotal',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      subtotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subtotal',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> subtotalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      subtotalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> subtotalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> subtotalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> syncStatusEqualTo(
      SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> syncStatusBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      taxableAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'taxableAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      taxableAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'taxableAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      taxableAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taxableAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      taxableAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taxableAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      taxableAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taxableAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      taxableAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taxableAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      totalAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      totalAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalAmount',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      totalAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      totalAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      totalAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      totalAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tripId',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      tripIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tripId',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tripId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tripId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tripId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tripId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tripId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tripId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tripId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tripId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> tripIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tripId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      tripIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tripId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      vehicleNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vehicleNumber',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      vehicleNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vehicleNumber',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      vehicleNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      vehicleNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      vehicleNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition>
      vehicleNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> yearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> yearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> yearEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> yearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> yearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> yearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SaleEntityQueryObject
    on QueryBuilder<SaleEntity, SaleEntity, QFilterCondition> {
  QueryBuilder<SaleEntity, SaleEntity, QAfterFilterCondition> itemsElement(
      FilterQuery<SaleItemEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension SaleEntityQueryLinks
    on QueryBuilder<SaleEntity, SaleEntity, QFilterCondition> {}

extension SaleEntityQuerySortBy
    on QueryBuilder<SaleEntity, SaleEntity, QSortBy> {
  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByAdditionalDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByAdditionalDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByAdditionalDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountPercentage', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByAdditionalDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountPercentage', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCancelReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCancelReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCancelledBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCancelledByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cgstAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCgstAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cgstAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCommissionAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByCommissionAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCommissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByCommissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCreatedByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByCreatedByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByDispatchRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchRequired', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByDispatchRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchRequired', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByGstPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstPercentage', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByGstPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstPercentage', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByGstType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByGstTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByHumanReadableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humanReadableId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByHumanReadableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humanReadableId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByIgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'igstAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByIgstAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'igstAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByItemDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      sortByItemDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRecipientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRecipientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRecipientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRecipientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRecipientType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRecipientTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRoundOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundOff', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRoundOffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundOff', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySaleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySaleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sgstAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySgstAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sgstAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByTaxableAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxableAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByTaxableAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxableAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByTripId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByTripIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SaleEntityQuerySortThenBy
    on QueryBuilder<SaleEntity, SaleEntity, QSortThenBy> {
  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByAdditionalDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByAdditionalDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByAdditionalDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountPercentage', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByAdditionalDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalDiscountPercentage', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCancelReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCancelReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCancelledBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCancelledByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cgstAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCgstAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cgstAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCommissionAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByCommissionAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCommissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByCommissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commissionType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCreatedByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByCreatedByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByRole', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountPercentage', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByDispatchRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchRequired', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByDispatchRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dispatchRequired', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByGstPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstPercentage', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByGstPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstPercentage', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByGstType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByGstTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gstType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByHumanReadableId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humanReadableId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByHumanReadableIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humanReadableId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByIgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'igstAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByIgstAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'igstAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByItemDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy>
      thenByItemDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRecipientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRecipientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRecipientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRecipientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRecipientType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRecipientTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRoundOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundOff', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRoundOffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundOff', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySaleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleType', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySaleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleType', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sgstAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySgstAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sgstAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByTaxableAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxableAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByTaxableAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taxableAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByTripId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByTripIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripId', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SaleEntityQueryWhereDistinct
    on QueryBuilder<SaleEntity, SaleEntity, QDistinct> {
  QueryBuilder<SaleEntity, SaleEntity, QDistinct>
      distinctByAdditionalDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'additionalDiscountAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct>
      distinctByAdditionalDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'additionalDiscountPercentage');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCancelReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCancelledAt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCancelledBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cgstAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCommissionAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commissionAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCommissionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commissionType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCreatedAt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByCreatedByRole(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByRole',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct>
      distinctByDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountPercentage');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByDispatchRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dispatchRequired');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByGstPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gstPercentage');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByGstType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gstType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByHumanReadableId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'humanReadableId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByIgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'igstAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct>
      distinctByItemDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemDiscountAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByItemProductIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemProductIds');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByPaymentStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByRecipientId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipientId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByRecipientName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipientName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByRecipientType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipientType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByRoundOff() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roundOff');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByRoute(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'route', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctBySaleType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saleType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctBySalesmanId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctBySalesmanName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctBySgstAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sgstAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByTaxableAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taxableAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByTripId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tripId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByVehicleNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SaleEntity, SaleEntity, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension SaleEntityQueryProperty
    on QueryBuilder<SaleEntity, SaleEntity, QQueryProperty> {
  QueryBuilder<SaleEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations>
      additionalDiscountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'additionalDiscountAmount');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations>
      additionalDiscountPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'additionalDiscountPercentage');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> cancelReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelReason');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> cancelledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledAt');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> cancelledByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledBy');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> cgstAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cgstAmount');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations>
      commissionAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commissionAmount');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> commissionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commissionType');
    });
  }

  QueryBuilder<SaleEntity, String, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> createdByRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByRole');
    });
  }

  QueryBuilder<SaleEntity, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> discountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountAmount');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations>
      discountPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountPercentage');
    });
  }

  QueryBuilder<SaleEntity, bool?, QQueryOperations> dispatchRequiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dispatchRequired');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> gstPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gstPercentage');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> gstTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gstType');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations>
      humanReadableIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'humanReadableId');
    });
  }

  QueryBuilder<SaleEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> igstAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'igstAmount');
    });
  }

  QueryBuilder<SaleEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations>
      itemDiscountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemDiscountAmount');
    });
  }

  QueryBuilder<SaleEntity, List<String>?, QQueryOperations>
      itemProductIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemProductIds');
    });
  }

  QueryBuilder<SaleEntity, List<SaleItemEntity>?, QQueryOperations>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<SaleEntity, int?, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> paidAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAmount');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> paymentStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentStatus');
    });
  }

  QueryBuilder<SaleEntity, String, QQueryOperations> recipientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipientId');
    });
  }

  QueryBuilder<SaleEntity, String, QQueryOperations> recipientNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipientName');
    });
  }

  QueryBuilder<SaleEntity, String, QQueryOperations> recipientTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipientType');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> roundOffProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roundOff');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> routeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'route');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> saleTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saleType');
    });
  }

  QueryBuilder<SaleEntity, String, QQueryOperations> salesmanIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanId');
    });
  }

  QueryBuilder<SaleEntity, String, QQueryOperations> salesmanNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanName');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> sgstAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sgstAmount');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }

  QueryBuilder<SaleEntity, SyncStatus, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> taxableAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taxableAmount');
    });
  }

  QueryBuilder<SaleEntity, double?, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> tripIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tripId');
    });
  }

  QueryBuilder<SaleEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SaleEntity, String?, QQueryOperations> vehicleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleNumber');
    });
  }

  QueryBuilder<SaleEntity, int?, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const SaleItemEntitySchema = Schema(
  name: r'SaleItemEntity',
  id: -4719789940000797445,
  properties: {
    r'baseUnit': PropertySchema(
      id: 0,
      name: r'baseUnit',
      type: IsarType.string,
    ),
    r'conversionFactor': PropertySchema(
      id: 1,
      name: r'conversionFactor',
      type: IsarType.double,
    ),
    r'discount': PropertySchema(
      id: 2,
      name: r'discount',
      type: IsarType.double,
    ),
    r'finalBaseQuantity': PropertySchema(
      id: 3,
      name: r'finalBaseQuantity',
      type: IsarType.long,
    ),
    r'isFree': PropertySchema(
      id: 4,
      name: r'isFree',
      type: IsarType.bool,
    ),
    r'lineAdditionalDiscountShare': PropertySchema(
      id: 5,
      name: r'lineAdditionalDiscountShare',
      type: IsarType.double,
    ),
    r'lineItemDiscountAmount': PropertySchema(
      id: 6,
      name: r'lineItemDiscountAmount',
      type: IsarType.double,
    ),
    r'lineNetAmount': PropertySchema(
      id: 7,
      name: r'lineNetAmount',
      type: IsarType.double,
    ),
    r'linePrimaryDiscountShare': PropertySchema(
      id: 8,
      name: r'linePrimaryDiscountShare',
      type: IsarType.double,
    ),
    r'lineSubtotal': PropertySchema(
      id: 9,
      name: r'lineSubtotal',
      type: IsarType.double,
    ),
    r'lineTaxAmount': PropertySchema(
      id: 10,
      name: r'lineTaxAmount',
      type: IsarType.double,
    ),
    r'lineTotalAmount': PropertySchema(
      id: 11,
      name: r'lineTotalAmount',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 12,
      name: r'name',
      type: IsarType.string,
    ),
    r'price': PropertySchema(
      id: 13,
      name: r'price',
      type: IsarType.double,
    ),
    r'productId': PropertySchema(
      id: 14,
      name: r'productId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 15,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'returnedQuantity': PropertySchema(
      id: 16,
      name: r'returnedQuantity',
      type: IsarType.long,
    ),
    r'schemeName': PropertySchema(
      id: 17,
      name: r'schemeName',
      type: IsarType.string,
    ),
    r'secondaryPrice': PropertySchema(
      id: 18,
      name: r'secondaryPrice',
      type: IsarType.double,
    ),
    r'secondaryUnit': PropertySchema(
      id: 19,
      name: r'secondaryUnit',
      type: IsarType.string,
    )
  },
  estimateSize: _saleItemEntityEstimateSize,
  serialize: _saleItemEntitySerialize,
  deserialize: _saleItemEntityDeserialize,
  deserializeProp: _saleItemEntityDeserializeProp,
);

int _saleItemEntityEstimateSize(
  SaleItemEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.baseUnit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.productId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.schemeName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.secondaryUnit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _saleItemEntitySerialize(
  SaleItemEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.baseUnit);
  writer.writeDouble(offsets[1], object.conversionFactor);
  writer.writeDouble(offsets[2], object.discount);
  writer.writeLong(offsets[3], object.finalBaseQuantity);
  writer.writeBool(offsets[4], object.isFree);
  writer.writeDouble(offsets[5], object.lineAdditionalDiscountShare);
  writer.writeDouble(offsets[6], object.lineItemDiscountAmount);
  writer.writeDouble(offsets[7], object.lineNetAmount);
  writer.writeDouble(offsets[8], object.linePrimaryDiscountShare);
  writer.writeDouble(offsets[9], object.lineSubtotal);
  writer.writeDouble(offsets[10], object.lineTaxAmount);
  writer.writeDouble(offsets[11], object.lineTotalAmount);
  writer.writeString(offsets[12], object.name);
  writer.writeDouble(offsets[13], object.price);
  writer.writeString(offsets[14], object.productId);
  writer.writeLong(offsets[15], object.quantity);
  writer.writeLong(offsets[16], object.returnedQuantity);
  writer.writeString(offsets[17], object.schemeName);
  writer.writeDouble(offsets[18], object.secondaryPrice);
  writer.writeString(offsets[19], object.secondaryUnit);
}

SaleItemEntity _saleItemEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SaleItemEntity();
  object.baseUnit = reader.readStringOrNull(offsets[0]);
  object.conversionFactor = reader.readDoubleOrNull(offsets[1]);
  object.discount = reader.readDoubleOrNull(offsets[2]);
  object.finalBaseQuantity = reader.readLongOrNull(offsets[3]);
  object.isFree = reader.readBoolOrNull(offsets[4]);
  object.lineAdditionalDiscountShare = reader.readDoubleOrNull(offsets[5]);
  object.lineItemDiscountAmount = reader.readDoubleOrNull(offsets[6]);
  object.lineNetAmount = reader.readDoubleOrNull(offsets[7]);
  object.linePrimaryDiscountShare = reader.readDoubleOrNull(offsets[8]);
  object.lineSubtotal = reader.readDoubleOrNull(offsets[9]);
  object.lineTaxAmount = reader.readDoubleOrNull(offsets[10]);
  object.lineTotalAmount = reader.readDoubleOrNull(offsets[11]);
  object.name = reader.readStringOrNull(offsets[12]);
  object.price = reader.readDoubleOrNull(offsets[13]);
  object.productId = reader.readStringOrNull(offsets[14]);
  object.quantity = reader.readLongOrNull(offsets[15]);
  object.returnedQuantity = reader.readLongOrNull(offsets[16]);
  object.schemeName = reader.readStringOrNull(offsets[17]);
  object.secondaryPrice = reader.readDoubleOrNull(offsets[18]);
  object.secondaryUnit = reader.readStringOrNull(offsets[19]);
  return object;
}

P _saleItemEntityDeserializeProp<P>(
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
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension SaleItemEntityQueryFilter
    on QueryBuilder<SaleItemEntity, SaleItemEntity, QFilterCondition> {
  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baseUnit',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baseUnit',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baseUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      baseUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baseUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      conversionFactorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'conversionFactor',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      conversionFactorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'conversionFactor',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      conversionFactorEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversionFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      conversionFactorGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversionFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      conversionFactorLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversionFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      conversionFactorBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversionFactor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      discountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      discountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      discountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      discountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      discountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      discountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      finalBaseQuantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'finalBaseQuantity',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      finalBaseQuantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'finalBaseQuantity',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      finalBaseQuantityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finalBaseQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      finalBaseQuantityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finalBaseQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      finalBaseQuantityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finalBaseQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      finalBaseQuantityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finalBaseQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      isFreeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isFree',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      isFreeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isFree',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      isFreeEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFree',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineAdditionalDiscountShareIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lineAdditionalDiscountShare',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineAdditionalDiscountShareIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lineAdditionalDiscountShare',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineAdditionalDiscountShareEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lineAdditionalDiscountShare',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineAdditionalDiscountShareGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lineAdditionalDiscountShare',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineAdditionalDiscountShareLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lineAdditionalDiscountShare',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineAdditionalDiscountShareBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lineAdditionalDiscountShare',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineItemDiscountAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lineItemDiscountAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineItemDiscountAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lineItemDiscountAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineItemDiscountAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lineItemDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineItemDiscountAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lineItemDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineItemDiscountAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lineItemDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineItemDiscountAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lineItemDiscountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineNetAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lineNetAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineNetAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lineNetAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineNetAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lineNetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineNetAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lineNetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineNetAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lineNetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineNetAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lineNetAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      linePrimaryDiscountShareIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linePrimaryDiscountShare',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      linePrimaryDiscountShareIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linePrimaryDiscountShare',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      linePrimaryDiscountShareEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linePrimaryDiscountShare',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      linePrimaryDiscountShareGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linePrimaryDiscountShare',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      linePrimaryDiscountShareLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linePrimaryDiscountShare',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      linePrimaryDiscountShareBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linePrimaryDiscountShare',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineSubtotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lineSubtotal',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineSubtotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lineSubtotal',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineSubtotalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lineSubtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineSubtotalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lineSubtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineSubtotalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lineSubtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineSubtotalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lineSubtotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTaxAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lineTaxAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTaxAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lineTaxAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTaxAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lineTaxAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTaxAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lineTaxAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTaxAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lineTaxAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTaxAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lineTaxAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTotalAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lineTotalAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTotalAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lineTotalAmount',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTotalAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lineTotalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTotalAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lineTotalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTotalAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lineTotalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      lineTotalAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lineTotalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      priceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'price',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      priceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'price',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      priceEqualTo(
    double? value, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      priceGreaterThan(
    double? value, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      priceLessThan(
    double? value, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      priceBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productId',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productId',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdEqualTo(
    String? value, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdGreaterThan(
    String? value, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdLessThan(
    String? value, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdStartsWith(
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdEndsWith(
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

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      productIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      quantityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      quantityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      quantityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      quantityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      returnedQuantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'returnedQuantity',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      returnedQuantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'returnedQuantity',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      returnedQuantityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'returnedQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      returnedQuantityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'returnedQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      returnedQuantityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'returnedQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      returnedQuantityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'returnedQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'schemeName',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'schemeName',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schemeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemeName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      schemeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schemeName',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryPriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondaryPrice',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryPriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondaryPrice',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryPriceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryPriceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryPriceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryPriceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondaryUnit',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondaryUnit',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'secondaryUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'secondaryUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'secondaryUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'secondaryUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<SaleItemEntity, SaleItemEntity, QAfterFilterCondition>
      secondaryUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'secondaryUnit',
        value: '',
      ));
    });
  }
}

extension SaleItemEntityQueryObject
    on QueryBuilder<SaleItemEntity, SaleItemEntity, QFilterCondition> {}
