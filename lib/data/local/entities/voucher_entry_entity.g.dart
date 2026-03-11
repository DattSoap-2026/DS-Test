// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_entry_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVoucherEntryEntityCollection on Isar {
  IsarCollection<VoucherEntryEntity> get voucherEntryEntitys =>
      this.collection();
}

const VoucherEntryEntitySchema = CollectionSchema(
  name: r'VoucherEntryEntity',
  id: -2372287687359127094,
  properties: {
    r'accountCode': PropertySchema(
      id: 0,
      name: r'accountCode',
      type: IsarType.string,
    ),
    r'accountingDimensionsJson': PropertySchema(
      id: 1,
      name: r'accountingDimensionsJson',
      type: IsarType.string,
    ),
    r'credit': PropertySchema(
      id: 2,
      name: r'credit',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 3,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dealerId': PropertySchema(
      id: 4,
      name: r'dealerId',
      type: IsarType.string,
    ),
    r'dealerName': PropertySchema(
      id: 5,
      name: r'dealerName',
      type: IsarType.string,
    ),
    r'debit': PropertySchema(
      id: 6,
      name: r'debit',
      type: IsarType.double,
    ),
    r'deletedAt': PropertySchema(
      id: 7,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'dimensionVersion': PropertySchema(
      id: 8,
      name: r'dimensionVersion',
      type: IsarType.long,
    ),
    r'district': PropertySchema(
      id: 9,
      name: r'district',
      type: IsarType.string,
    ),
    r'division': PropertySchema(
      id: 10,
      name: r'division',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 11,
      name: r'id',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 12,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'narration': PropertySchema(
      id: 13,
      name: r'narration',
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
      enumMap: _VoucherEntryEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 19,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'voucherId': PropertySchema(
      id: 20,
      name: r'voucherId',
      type: IsarType.string,
    )
  },
  estimateSize: _voucherEntryEntityEstimateSize,
  serialize: _voucherEntryEntitySerialize,
  deserialize: _voucherEntryEntityDeserialize,
  deserializeProp: _voucherEntryEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'voucherId': IndexSchema(
      id: -3324150503629685036,
      name: r'voucherId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'voucherId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'accountCode': IndexSchema(
      id: 5787832013363107608,
      name: r'accountCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'accountCode',
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
  getId: _voucherEntryEntityGetId,
  getLinks: _voucherEntryEntityGetLinks,
  attach: _voucherEntryEntityAttach,
  version: '3.1.0+1',
);

int _voucherEntryEntityEstimateSize(
  VoucherEntryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accountCode.length * 3;
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
    final value = object.narration;
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
  bytesCount += 3 + object.voucherId.length * 3;
  return bytesCount;
}

void _voucherEntryEntitySerialize(
  VoucherEntryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountCode);
  writer.writeString(offsets[1], object.accountingDimensionsJson);
  writer.writeDouble(offsets[2], object.credit);
  writer.writeDateTime(offsets[3], object.date);
  writer.writeString(offsets[4], object.dealerId);
  writer.writeString(offsets[5], object.dealerName);
  writer.writeDouble(offsets[6], object.debit);
  writer.writeDateTime(offsets[7], object.deletedAt);
  writer.writeLong(offsets[8], object.dimensionVersion);
  writer.writeString(offsets[9], object.district);
  writer.writeString(offsets[10], object.division);
  writer.writeString(offsets[11], object.id);
  writer.writeBool(offsets[12], object.isDeleted);
  writer.writeString(offsets[13], object.narration);
  writer.writeString(offsets[14], object.route);
  writer.writeString(offsets[15], object.saleDate);
  writer.writeString(offsets[16], object.salesmanId);
  writer.writeString(offsets[17], object.salesmanName);
  writer.writeByte(offsets[18], object.syncStatus.index);
  writer.writeDateTime(offsets[19], object.updatedAt);
  writer.writeString(offsets[20], object.voucherId);
}

VoucherEntryEntity _voucherEntryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VoucherEntryEntity();
  object.accountCode = reader.readString(offsets[0]);
  object.accountingDimensionsJson = reader.readStringOrNull(offsets[1]);
  object.credit = reader.readDouble(offsets[2]);
  object.date = reader.readDateTimeOrNull(offsets[3]);
  object.dealerId = reader.readStringOrNull(offsets[4]);
  object.dealerName = reader.readStringOrNull(offsets[5]);
  object.debit = reader.readDouble(offsets[6]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[7]);
  object.dimensionVersion = reader.readLongOrNull(offsets[8]);
  object.district = reader.readStringOrNull(offsets[9]);
  object.division = reader.readStringOrNull(offsets[10]);
  object.id = reader.readString(offsets[11]);
  object.isDeleted = reader.readBool(offsets[12]);
  object.narration = reader.readStringOrNull(offsets[13]);
  object.route = reader.readStringOrNull(offsets[14]);
  object.saleDate = reader.readStringOrNull(offsets[15]);
  object.salesmanId = reader.readStringOrNull(offsets[16]);
  object.salesmanName = reader.readStringOrNull(offsets[17]);
  object.syncStatus = _VoucherEntryEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[18])] ??
      SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[19]);
  object.voucherId = reader.readString(offsets[20]);
  return object;
}

P _voucherEntryEntityDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
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
      return (_VoucherEntryEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _VoucherEntryEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _VoucherEntryEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _voucherEntryEntityGetId(VoucherEntryEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _voucherEntryEntityGetLinks(
    VoucherEntryEntity object) {
  return [];
}

void _voucherEntryEntityAttach(
    IsarCollection<dynamic> col, Id id, VoucherEntryEntity object) {}

extension VoucherEntryEntityByIndex on IsarCollection<VoucherEntryEntity> {
  Future<VoucherEntryEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  VoucherEntryEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<VoucherEntryEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<VoucherEntryEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(VoucherEntryEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(VoucherEntryEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<VoucherEntryEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<VoucherEntryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension VoucherEntryEntityQueryWhereSort
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QWhere> {
  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension VoucherEntryEntityQueryWhere
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QWhereClause> {
  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      voucherIdEqualTo(String voucherId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'voucherId',
        value: [voucherId],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      voucherIdNotEqualTo(String voucherId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherId',
              lower: [],
              upper: [voucherId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherId',
              lower: [voucherId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherId',
              lower: [voucherId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'voucherId',
              lower: [],
              upper: [voucherId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      accountCodeEqualTo(String accountCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'accountCode',
        value: [accountCode],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      accountCodeNotEqualTo(String accountCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountCode',
              lower: [],
              upper: [accountCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountCode',
              lower: [accountCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountCode',
              lower: [accountCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountCode',
              lower: [],
              upper: [accountCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dateEqualTo(DateTime? date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dateNotEqualTo(DateTime? date) {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dateGreaterThan(
    DateTime? date, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dateLessThan(
    DateTime? date, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dateBetween(
    DateTime? lowerDate,
    DateTime? upperDate, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      routeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'route',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      routeEqualTo(String? route) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'route',
        value: [route],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      routeNotEqualTo(String? route) {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      districtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'district',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      districtEqualTo(String? district) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'district',
        value: [district],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      divisionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'division',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      divisionEqualTo(String? division) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'division',
        value: [division],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      salesmanIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salesmanId',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      salesmanIdEqualTo(String? salesmanId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salesmanId',
        value: [salesmanId],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dealerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dealerId',
        value: [null],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      dealerIdEqualTo(String? dealerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dealerId',
        value: [dealerId],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterWhereClause>
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

extension VoucherEntryEntityQueryFilter
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QFilterCondition> {
  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountCode',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountCode',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accountingDimensionsJson',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accountingDimensionsJson',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountingDimensionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      accountingDimensionsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountingDimensionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      creditEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      creditGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      creditLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      creditBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dateGreaterThan(
    DateTime? value, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dateLessThan(
    DateTime? value, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dateBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dealerId',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dealerId',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dealerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dealerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dealerId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dealerName',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dealerName',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dealerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dealerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dealerName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dealerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dealerName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      debitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'debit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      debitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'debit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      debitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'debit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      debitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'debit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dimensionVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dimensionVersion',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dimensionVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dimensionVersion',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      dimensionVersionEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dimensionVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      districtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'district',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      districtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'district',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      districtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'district',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      districtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'district',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      districtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'district',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      districtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'district',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      divisionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'division',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      divisionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'division',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      divisionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'division',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      divisionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'division',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      divisionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'division',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      divisionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'division',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'narration',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'narration',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationEqualTo(
    String? value, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationGreaterThan(
    String? value, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationLessThan(
    String? value, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'narration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'narration',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'narration',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      narrationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'narration',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      routeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'route',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      routeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'route',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      routeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      routeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'route',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      routeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      routeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      saleDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'saleDate',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      saleDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'saleDate',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      saleDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saleDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      saleDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saleDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      saleDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleDate',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      saleDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saleDate',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'salesmanId',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'salesmanId',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'salesmanName',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'salesmanName',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salesmanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salesmanName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      salesmanNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salesmanName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voucherId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voucherId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterFilterCondition>
      voucherIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voucherId',
        value: '',
      ));
    });
  }
}

extension VoucherEntryEntityQueryObject
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QFilterCondition> {}

extension VoucherEntryEntityQueryLinks
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QFilterCondition> {}

extension VoucherEntryEntityQuerySortBy
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QSortBy> {
  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByAccountCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountCode', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByAccountCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountCode', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByAccountingDimensionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByAccountingDimensionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByCreditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credit', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDealerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDealerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDealerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDealerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'debit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'debit', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDimensionVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDimensionVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDistrict() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDistrictDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDivision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByDivisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByNarration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByNarrationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySaleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySaleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByVoucherId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      sortByVoucherIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherId', Sort.desc);
    });
  }
}

extension VoucherEntryEntityQuerySortThenBy
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QSortThenBy> {
  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByAccountCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountCode', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByAccountCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountCode', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByAccountingDimensionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByAccountingDimensionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountingDimensionsJson', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByCreditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credit', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDealerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDealerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDealerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDealerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dealerName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'debit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'debit', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDimensionVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDimensionVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dimensionVersion', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDistrict() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDistrictDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'district', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDivision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByDivisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'division', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByNarration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByNarrationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'narration', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySaleDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySaleDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleDate', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySalesmanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySalesmanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySalesmanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySalesmanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salesmanName', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByVoucherId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QAfterSortBy>
      thenByVoucherIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherId', Sort.desc);
    });
  }
}

extension VoucherEntryEntityQueryWhereDistinct
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct> {
  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByAccountCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByAccountingDimensionsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountingDimensionsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credit');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDealerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dealerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDealerName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dealerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'debit');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDimensionVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dimensionVersion');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDistrict({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'district', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByDivision({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'division', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByNarration({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'narration', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByRoute({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'route', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctBySaleDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saleDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctBySalesmanId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctBySalesmanName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salesmanName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QDistinct>
      distinctByVoucherId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voucherId', caseSensitive: caseSensitive);
    });
  }
}

extension VoucherEntryEntityQueryProperty
    on QueryBuilder<VoucherEntryEntity, VoucherEntryEntity, QQueryProperty> {
  QueryBuilder<VoucherEntryEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<VoucherEntryEntity, String, QQueryOperations>
      accountCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountCode');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      accountingDimensionsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountingDimensionsJson');
    });
  }

  QueryBuilder<VoucherEntryEntity, double, QQueryOperations> creditProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credit');
    });
  }

  QueryBuilder<VoucherEntryEntity, DateTime?, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      dealerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dealerId');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      dealerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dealerName');
    });
  }

  QueryBuilder<VoucherEntryEntity, double, QQueryOperations> debitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'debit');
    });
  }

  QueryBuilder<VoucherEntryEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<VoucherEntryEntity, int?, QQueryOperations>
      dimensionVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dimensionVersion');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      districtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'district');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      divisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'division');
    });
  }

  QueryBuilder<VoucherEntryEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VoucherEntryEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      narrationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'narration');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations> routeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'route');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      saleDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saleDate');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      salesmanIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanId');
    });
  }

  QueryBuilder<VoucherEntryEntity, String?, QQueryOperations>
      salesmanNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salesmanName');
    });
  }

  QueryBuilder<VoucherEntryEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<VoucherEntryEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<VoucherEntryEntity, String, QQueryOperations>
      voucherIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voucherId');
    });
  }
}
