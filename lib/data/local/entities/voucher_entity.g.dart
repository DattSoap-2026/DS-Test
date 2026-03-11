// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVoucherEntityCollection on Isar {
  IsarCollection<VoucherEntity> get voucherEntitys => this.collection();
}

const VoucherEntitySchema = CollectionSchema(
  name: r'VoucherEntity',
  id: 4165992973744833777,
  properties: {
    r'accountingDimensionsJson': PropertySchema(
      id: 0,
      name: r'accountingDimensionsJson',
      type: IsarType.string,
    ),
    r'amount': PropertySchema(
      id: 1,
      name: r'amount',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dealerId': PropertySchema(
      id: 3,
      name: r'dealerId',
      type: IsarType.string,
    ),
    r'dealerName': PropertySchema(
      id: 4,
      name: r'dealerName',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 5,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'dimensionVersion': PropertySchema(
      id: 6,
      name: r'dimensionVersion',
      type: IsarType.long,
    ),
    r'district': PropertySchema(
      id: 7,
      name: r'district',
      type: IsarType.string,
    ),
    r'division': PropertySchema(
      id: 8,
      name: r'division',
      type: IsarType.string,
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
    r'linkedId': PropertySchema(
      id: 11,
      name: r'linkedId',
      type: IsarType.string,
    ),
    r'narration': PropertySchema(
      id: 12,
      name: r'narration',
      type: IsarType.string,
    ),
    r'partyName': PropertySchema(
      id: 13,
      name: r'partyName',
      type: IsarType.string,
    ),
    r'route': PropertySchema(
      id: 14,
      name: r'route',
      type: IsarType.string,
    ),
    r'saleDate': PropertySchema(
      id: 15,
      name: r'saleDate',
      type: IsarType.string,
    ),
    r'salesmanId': PropertySchema(
      id: 16,
      name: r'salesmanId',
      type: IsarType.string,
    ),
    r'salesmanName': PropertySchema(
      id: 17,
      name: r'salesmanName',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 18,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _VoucherEntitysyncStatusEnumValueMap,
    ),
    r'transactionRefId': PropertySchema(
      id: 19,
      name: r'transactionRefId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 20,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'voucherNumber': PropertySchema(
      id: 22,
      name: r'voucherNumber',
      type: IsarType.string,
    )
  },
  estimateSize: _voucherEntityEstimateSize,
  serialize: _voucherEntitySerialize,
  deserialize: _voucherEntityDeserialize,
  deserializeProp: _voucherEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'transactionRefId': IndexSchema(
      id: -1354246549252083624,
      name: r'transactionRefId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionRefId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'type': IndexSchema(
      id: 5117122708147080838,
      name: r'type',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'linkedId': IndexSchema(
      id: 9174995129670660136,
      name: r'linkedId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'linkedId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'partyName': IndexSchema(
      id: 3345427415762707765,
      name: r'partyName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'partyName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'voucherNumber': IndexSchema(
      id: -6620117117444045036,
      name: r'voucherNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'voucherNumber',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'route': IndexSchema(
      id: 8686557153332962867,
      name: r'route',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'route',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'district': IndexSchema(
      id: 4102361732179188505,
      name: r'district',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'district',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'division': IndexSchema(
      id: 8393290812841796395,
      name: r'division',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'division',
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
    r'dealerId': IndexSchema(
      id: -1831829691253688618,
      name: r'dealerId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dealerId',
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
  getId: _voucherEntityGetId,
  getLinks: _voucherEntityGetLinks,
  attach: _voucherEntityAttach,
  version: '3.1.0+1',
);

int _voucherEntityEstimateSize(
  VoucherEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accountingDimensionsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dealerId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dealerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.district;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.division;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.linkedId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.narration.length * 3;
  {
    final value = object.partyName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.route;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.saleDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.salesmanId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.salesmanName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.transactionRefId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  {
    final value = object.voucherNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _voucherEntitySerialize(
  VoucherEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountingDimensionsJson);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeString(offsets[3], object.dealerId);
  writer.writeString(offsets[4], object.dealerName);
  writer.writeDateTime(offsets[5], object.deletedAt);
  writer.writeLong(offsets[6], object.dimensionVersion);
  writer.writeString(offsets[7], object.district);
  writer.writeString(offsets[8], object.division);
  writer.writeString(offsets[9], object.id);
  writer.writeBool(offsets[10], object.isDeleted);
  writer.writeString(offsets[11], object.linkedId);
  writer.writeString(offsets[12], object.narration);
  writer.writeString(offsets[13], object.partyName);
  writer.writeString(offsets[14], object.route);
  writer.writeString(offsets[15], object.saleDate);
  writer.writeString(offsets[16], object.salesmanId);
  writer.writeString(offsets[17], object.salesmanName);
  writer.writeByte(offsets[18], object.syncStatus.index);
  writer.writeString(offsets[19], object.transactionRefId);
  writer.writeString(offsets[20], object.type);
  writer.writeDateTime(offsets[21], object.updatedAt);
  writer.writeString(offsets[22], object.voucherNumber);
}

VoucherEntity _voucherEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VoucherEntity();
  object.accountingDimensionsJson = reader.readStringOrNull(offsets[0]);
  object.amount = reader.readDouble(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.dealerId = reader.readStringOrNull(offsets[3]);
  object.dealerName = reader.readStringOrNull(offsets[4]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[5]);
  object.dimensionVersion = reader.readLongOrNull(offsets[6]);
  object.district = reader.readStringOrNull(offsets[7]);
  object.division = reader.readStringOrNull(offsets[8]);
  object.id = reader.readString(offsets[9]);
  object.isDeleted = reader.readBool(offsets[10]);
  object.linkedId = reader.readStringOrNull(offsets[11]);
  object.narration = reader.readString(offsets[12]);
  object.partyName = reader.readStringOrNull(offsets[13]);
  object.route = reader.readStringOrNull(offsets[14]);
  object.saleDate = reader.readStringOrNull(offsets[15]);
  object.salesmanId = reader.readStringOrNull(offsets[16]);
  object.salesmanName = reader.readStringOrNull(offsets[17]);
  object.syncStatus = _VoucherEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[18])] ??
      SyncStatus.pending;
  object.transactionRefId = reader.readString(offsets[19]);
  object.type = reader.readString(offsets[20]);
  object.updatedAt = reader.readDateTime(offsets[21]);
  object.voucherNumber = reader.readStringOrNull(offsets[22]);
  return object;
}

P _voucherEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (_VoucherEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDateTime(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _VoucherEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _VoucherEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _voucherEntityGetId(VoucherEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _voucherEntityGetLinks(VoucherEntity object) {
  return [];
}

void _voucherEntityAttach(
    IsarCollection<dynamic> col, Id id, VoucherEntity object) {}

extension VoucherEntityByIndex on IsarCollection<VoucherEntity> {
  Future<VoucherEntity?> getByTransactionRefId(String transactionRefId) {
    return getByIndex(r'transactionRefId', [transactionRefId]);
  }

  VoucherEntity? getByTransactionRefIdSync(String transactionRefId) {
    return getByIndexSync(r'transactionRefId', [transactionRefId]);
  }

  Future<bool> deleteByTransactionRefId(String transactionRefId) {
    return deleteByIndex(r'transactionRefId', [transactionRefId]);
  }

  bool deleteByTransactionRefIdSync(String transactionRefId) {
    return deleteByIndexSync(r'transactionRefId', [transactionRefId]);
  }

  Future<List<VoucherEntity?>> getAllByTransactionRefId(
      List<String> transactionRefIdValues) {
    final values = transactionRefIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'transactionRefId', values);
  }

  List<VoucherEntity?> getAllByTransactionRefIdSync(
      List<String> transactionRefIdValues) {
    final values = transactionRefIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'transactionRefId', values);
  }

  Future<int> deleteAllByTransactionRefId(List<String> transactionRefIdValues) {
    final values = transactionRefIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'transactionRefId', values);
  }

  int deleteAllByTransactionRefIdSync(List<String> transactionRefIdValues) {
    final values = transactionRefIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'transactionRefId', values);
  }

  Future<Id> putByTransactionRefId(VoucherEntity object) {
    return putByIndex(r'transactionRefId', object);
  }

  Id putByTransactionRefIdSync(VoucherEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'transactionRefId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTransactionRefId(List<VoucherEntity> objects) {
    return putAllByIndex(r'transactionRefId', objects);
  }

  List<Id> putAllByTransactionRefIdSync(List<VoucherEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'transactionRefId', objects,
        saveLinks: saveLinks);
  }

  Future<VoucherEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  VoucherEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<VoucherEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<VoucherEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(VoucherEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(VoucherEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<VoucherEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<VoucherEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension VoucherEntityQueryWhereSort
    on QueryBuilder<VoucherEntity, VoucherEntity, QWhere> {
  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension VoucherEntityQueryWhere
    on QueryBuilder<VoucherEntity, VoucherEntity, QWhereClause> {
  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      transactionRefIdEqualTo(String transactionRefId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'transactionRefId',
        value: [transactionRefId],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      transactionRefIdNotEqualTo(String transactionRefId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionRefId',
              lower: [],
              upper: [transactionRefId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionRefId',
              lower: [transactionRefId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionRefId',
              lower: [transactionRefId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionRefId',
              lower: [],
              upper: [transactionRefId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> typeEqualTo(
      String type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'type',
        value: [type],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> typeNotEqualTo(
      String type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      linkedIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkedId',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      linkedIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'linkedId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> linkedIdEqualTo(
      String? linkedId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkedId',
        value: [linkedId],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      linkedIdNotEqualTo(String? linkedId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedId',
              lower: [],
              upper: [linkedId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedId',
              lower: [linkedId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedId',
              lower: [linkedId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedId',
              lower: [],
              upper: [linkedId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      partyNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'partyName',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      partyNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'partyName',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      partyNameEqualTo(String? partyName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'partyName',
        value: [partyName],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      partyNameNotEqualTo(String? partyName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyName',
              lower: [],
              upper: [partyName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyName',
              lower: [partyName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyName',
              lower: [partyName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyName',
              lower: [],
              upper: [partyName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      voucherNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'voucherNumber',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      voucherNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'voucherNumber',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      voucherNumberEqualTo(String? voucherNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'voucherNumber',
        value: [voucherNumber],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      voucherNumberNotEqualTo(String? voucherNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherNumber',
              lower: [],
              upper: [voucherNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherNumber',
              lower: [voucherNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherNumber',
              lower: [voucherNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherNumber',
              lower: [],
              upper: [voucherNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> routeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'route',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      routeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'route',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> routeEqualTo(
      String? route) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'route',
        value: [route],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> routeNotEqualTo(
      String? route) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'route',
              lower: [],
              upper: [route],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'route',
              lower: [route],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'route',
              lower: [route],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'route',
              lower: [],
              upper: [route],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      districtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'district',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      districtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'district',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> districtEqualTo(
      String? district) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'district',
        value: [district],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      districtNotEqualTo(String? district) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'district',
              lower: [],
              upper: [district],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'district',
              lower: [district],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'district',
              lower: [district],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'district',
              lower: [],
              upper: [district],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      divisionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'division',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      divisionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'division',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> divisionEqualTo(
      String? division) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'division',
        value: [division],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      divisionNotEqualTo(String? division) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'division',
              lower: [],
              upper: [division],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'division',
              lower: [division],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'division',
              lower: [division],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'division',
              lower: [],
              upper: [division],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      salesmanIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salesmanId',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      salesmanIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'salesmanId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      salesmanIdEqualTo(String? salesmanId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salesmanId',
        value: [salesmanId],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      salesmanIdNotEqualTo(String? salesmanId) {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      dealerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dealerId',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      dealerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dealerId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> dealerIdEqualTo(
      String? dealerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dealerId',
        value: [dealerId],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause>
      dealerIdNotEqualTo(String? dealerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dealerId',
              lower: [],
              upper: [dealerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dealerId',
              lower: [dealerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dealerId',
              lower: [dealerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dealerId',
              lower: [],
              upper: [dealerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterWhereClause> idNotEqualTo(
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

extension VoucherEntityQueryFilter
    on QueryBuilder<VoucherEntity, VoucherEntity, QFilterCondition> {
  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accountingDimensionsJson',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accountingDimensionsJson',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountingDimensionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountingDimensionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountingDimensionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountingDimensionsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountingDimensionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountingDimensionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountingDimensionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountingDimensionsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountingDimensionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountingDimensionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dealerId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dealerId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdEqualTo(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdGreaterThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdLessThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dealerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dealerId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dealerName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dealerName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameEqualTo(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameGreaterThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameLessThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dealerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dealerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dealerName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dimensionVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dimensionVersion',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dimensionVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dimensionVersion',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dimensionVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dimensionVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dimensionVersionGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dimensionVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dimensionVersionLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dimensionVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      dimensionVersionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dimensionVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'district',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'district',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'district',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'district',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'district',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'district',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'district',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'district',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'district',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'district',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'district',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      districtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'district',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'division',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'division',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'division',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'division',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'division',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'division',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'division',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'division',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'division',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'division',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'division',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      divisionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'division',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> idContains(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> idMatches(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      linkedIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'narration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'narration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'narration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'narration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'narration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'narration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'narration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'narration',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'narration',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      narrationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'narration',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partyName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partyName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partyName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partyName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partyName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partyName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'route',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'route',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeEqualTo(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeGreaterThan(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeLessThan(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeBetween(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeStartsWith(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeEndsWith(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'route',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      routeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saleDate',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saleDate',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saleDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saleDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saleDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'saleDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'saleDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saleDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saleDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleDate',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      saleDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saleDate',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'salesmanId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'salesmanId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdEqualTo(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdGreaterThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdLessThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'salesmanName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'salesmanName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameEqualTo(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameGreaterThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameLessThan(
    String? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      salesmanNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionRefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transactionRefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transactionRefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transactionRefId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'transactionRefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'transactionRefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'transactionRefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'transactionRefId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionRefId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      transactionRefIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'transactionRefId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> typeBetween(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition> typeMatches(
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voucherNumber',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voucherNumber',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voucherNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voucherNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voucherNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voucherNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voucherNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voucherNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voucherNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voucherNumber',
        value: '',
      ));
    });
  }
}

extension VoucherEntityQueryObject
    on QueryBuilder<VoucherEntity, VoucherEntity, QFilterCondition> {}

extension VoucherEntityQueryLinks
    on QueryBuilder<VoucherEntity, VoucherEntity, QFilterCondition> {}

extension VoucherEntityQuerySortBy
    on QueryBuilder<VoucherEntity, VoucherEntity, QSortBy> {
  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByAccountingDimensionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByAccountingDimensionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDealerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDealerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDealerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDealerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDimensionVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDimensionVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDistrict() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDistrictDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDivision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDivisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByLinkedId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByLinkedIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByNarration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByNarrationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByPartyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByPartyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortBySaleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySaleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByTransactionRefId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRefId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByTransactionRefIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRefId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByVoucherNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNumber', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByVoucherNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNumber', Sort.desc);
    });
  }
}

extension VoucherEntityQuerySortThenBy
    on QueryBuilder<VoucherEntity, VoucherEntity, QSortThenBy> {
  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByAccountingDimensionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByAccountingDimensionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDealerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDealerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDealerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDealerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDimensionVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDimensionVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDistrict() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDistrictDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDivision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDivisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByLinkedId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByLinkedIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByNarration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByNarrationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByPartyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByPartyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenBySaleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySaleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByTransactionRefId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRefId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByTransactionRefIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRefId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByVoucherNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNumber', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByVoucherNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNumber', Sort.desc);
    });
  }
}

extension VoucherEntityQueryWhereDistinct
    on QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> {
  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByAccountingDimensionsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountingDimensionsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByDealerId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dealerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByDealerName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dealerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByDimensionVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dimensionVersion');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByDistrict(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'district', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByDivision(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'division', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByLinkedId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByNarration(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'narration', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByPartyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partyName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByRoute(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'route', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySaleDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saleDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySalesmanId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySalesmanName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByTransactionRefId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionRefId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByVoucherNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voucherNumber',
          caseSensitive: caseSensitive);
    });
  }
}

extension VoucherEntityQueryProperty
    on QueryBuilder<VoucherEntity, VoucherEntity, QQueryProperty> {
  QueryBuilder<VoucherEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      accountingDimensionsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountingDimensionsJson');
    });
  }

  QueryBuilder<VoucherEntity, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<VoucherEntity, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> dealerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dealerId');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> dealerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dealerName');
    });
  }

  QueryBuilder<VoucherEntity, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<VoucherEntity, int?, QQueryOperations>
      dimensionVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dimensionVersion');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> districtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'district');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> divisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'division');
    });
  }

  QueryBuilder<VoucherEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VoucherEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> linkedIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedId');
    });
  }

  QueryBuilder<VoucherEntity, String, QQueryOperations> narrationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'narration');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> partyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partyName');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> routeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'route');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> saleDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saleDate');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> salesmanIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanId');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      salesmanNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanName');
    });
  }

  QueryBuilder<VoucherEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<VoucherEntity, String, QQueryOperations>
      transactionRefIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionRefId');
    });
  }

  QueryBuilder<VoucherEntity, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<VoucherEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      voucherNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voucherNumber');
    });
  }
}
