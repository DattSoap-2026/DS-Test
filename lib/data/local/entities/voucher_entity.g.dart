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
    r'cancelReason': PropertySchema(
      id: 2,
      name: r'cancelReason',
      type: IsarType.string,
    ),
    r'cancelledAt': PropertySchema(
      id: 3,
      name: r'cancelledAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdBy': PropertySchema(
      id: 5,
      name: r'createdBy',
      type: IsarType.string,
    ),
    r'createdByName': PropertySchema(
      id: 6,
      name: r'createdByName',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 7,
      name: r'date',
      type: IsarType.dateTime,
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
    r'deviceId': PropertySchema(
      id: 11,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'dimensionVersion': PropertySchema(
      id: 12,
      name: r'dimensionVersion',
      type: IsarType.long,
    ),
    r'district': PropertySchema(
      id: 13,
      name: r'district',
      type: IsarType.string,
    ),
    r'division': PropertySchema(
      id: 14,
      name: r'division',
      type: IsarType.string,
    ),
    r'entryCount': PropertySchema(
      id: 15,
      name: r'entryCount',
      type: IsarType.long,
    ),
    r'financialYearId': PropertySchema(
      id: 16,
      name: r'financialYearId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 17,
      name: r'id',
      type: IsarType.string,
    ),
    r'isBalanced': PropertySchema(
      id: 18,
      name: r'isBalanced',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 19,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 20,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastSynced': PropertySchema(
      id: 21,
      name: r'lastSynced',
      type: IsarType.dateTime,
    ),
    r'linkedId': PropertySchema(
      id: 22,
      name: r'linkedId',
      type: IsarType.string,
    ),
    r'narration': PropertySchema(
      id: 23,
      name: r'narration',
      type: IsarType.string,
    ),
    r'partyId': PropertySchema(
      id: 24,
      name: r'partyId',
      type: IsarType.string,
    ),
    r'partyName': PropertySchema(
      id: 25,
      name: r'partyName',
      type: IsarType.string,
    ),
    r'reversalOfVoucherId': PropertySchema(
      id: 26,
      name: r'reversalOfVoucherId',
      type: IsarType.string,
    ),
    r'reversalReason': PropertySchema(
      id: 27,
      name: r'reversalReason',
      type: IsarType.string,
    ),
    r'route': PropertySchema(
      id: 28,
      name: r'route',
      type: IsarType.string,
    ),
    r'saleDate': PropertySchema(
      id: 29,
      name: r'saleDate',
      type: IsarType.string,
    ),
    r'salesmanId': PropertySchema(
      id: 30,
      name: r'salesmanId',
      type: IsarType.string,
    ),
    r'salesmanName': PropertySchema(
      id: 31,
      name: r'salesmanName',
      type: IsarType.string,
    ),
    r'sourceId': PropertySchema(
      id: 32,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'sourceModule': PropertySchema(
      id: 33,
      name: r'sourceModule',
      type: IsarType.string,
    ),
    r'sourceNumber': PropertySchema(
      id: 34,
      name: r'sourceNumber',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 35,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 36,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _VoucherEntitysyncStatusEnumValueMap,
    ),
    r'totalCredit': PropertySchema(
      id: 37,
      name: r'totalCredit',
      type: IsarType.double,
    ),
    r'totalDebit': PropertySchema(
      id: 38,
      name: r'totalDebit',
      type: IsarType.double,
    ),
    r'transactionRefId': PropertySchema(
      id: 39,
      name: r'transactionRefId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 40,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 41,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 42,
      name: r'version',
      type: IsarType.long,
    ),
    r'voucherNumber': PropertySchema(
      id: 43,
      name: r'voucherNumber',
      type: IsarType.string,
    ),
    r'voucherType': PropertySchema(
      id: 44,
      name: r'voucherType',
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
    final value = object.cancelReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.createdBy;
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
  bytesCount += 3 + object.deviceId.length * 3;
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
  {
    final value = object.financialYearId;
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
    final value = object.partyId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.partyName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reversalOfVoucherId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reversalReason;
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
  {
    final value = object.sourceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceModule;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.transactionRefId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  {
    final value = object.voucherNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.voucherType;
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
  writer.writeString(offsets[2], object.cancelReason);
  writer.writeDateTime(offsets[3], object.cancelledAt);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.createdBy);
  writer.writeString(offsets[6], object.createdByName);
  writer.writeDateTime(offsets[7], object.date);
  writer.writeString(offsets[8], object.dealerId);
  writer.writeString(offsets[9], object.dealerName);
  writer.writeDateTime(offsets[10], object.deletedAt);
  writer.writeString(offsets[11], object.deviceId);
  writer.writeLong(offsets[12], object.dimensionVersion);
  writer.writeString(offsets[13], object.district);
  writer.writeString(offsets[14], object.division);
  writer.writeLong(offsets[15], object.entryCount);
  writer.writeString(offsets[16], object.financialYearId);
  writer.writeString(offsets[17], object.id);
  writer.writeBool(offsets[18], object.isBalanced);
  writer.writeBool(offsets[19], object.isDeleted);
  writer.writeBool(offsets[20], object.isSynced);
  writer.writeDateTime(offsets[21], object.lastSynced);
  writer.writeString(offsets[22], object.linkedId);
  writer.writeString(offsets[23], object.narration);
  writer.writeString(offsets[24], object.partyId);
  writer.writeString(offsets[25], object.partyName);
  writer.writeString(offsets[26], object.reversalOfVoucherId);
  writer.writeString(offsets[27], object.reversalReason);
  writer.writeString(offsets[28], object.route);
  writer.writeString(offsets[29], object.saleDate);
  writer.writeString(offsets[30], object.salesmanId);
  writer.writeString(offsets[31], object.salesmanName);
  writer.writeString(offsets[32], object.sourceId);
  writer.writeString(offsets[33], object.sourceModule);
  writer.writeString(offsets[34], object.sourceNumber);
  writer.writeString(offsets[35], object.status);
  writer.writeByte(offsets[36], object.syncStatus.index);
  writer.writeDouble(offsets[37], object.totalCredit);
  writer.writeDouble(offsets[38], object.totalDebit);
  writer.writeString(offsets[39], object.transactionRefId);
  writer.writeString(offsets[40], object.type);
  writer.writeDateTime(offsets[41], object.updatedAt);
  writer.writeLong(offsets[42], object.version);
  writer.writeString(offsets[43], object.voucherNumber);
  writer.writeString(offsets[44], object.voucherType);
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
  object.cancelReason = reader.readStringOrNull(offsets[2]);
  object.cancelledAt = reader.readDateTimeOrNull(offsets[3]);
  object.createdAt = reader.readDateTimeOrNull(offsets[4]);
  object.createdBy = reader.readStringOrNull(offsets[5]);
  object.createdByName = reader.readStringOrNull(offsets[6]);
  object.date = reader.readDateTime(offsets[7]);
  object.dealerId = reader.readStringOrNull(offsets[8]);
  object.dealerName = reader.readStringOrNull(offsets[9]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[10]);
  object.deviceId = reader.readString(offsets[11]);
  object.dimensionVersion = reader.readLongOrNull(offsets[12]);
  object.district = reader.readStringOrNull(offsets[13]);
  object.division = reader.readStringOrNull(offsets[14]);
  object.entryCount = reader.readLong(offsets[15]);
  object.financialYearId = reader.readStringOrNull(offsets[16]);
  object.id = reader.readString(offsets[17]);
  object.isBalanced = reader.readBool(offsets[18]);
  object.isDeleted = reader.readBool(offsets[19]);
  object.isSynced = reader.readBool(offsets[20]);
  object.lastSynced = reader.readDateTimeOrNull(offsets[21]);
  object.linkedId = reader.readStringOrNull(offsets[22]);
  object.narration = reader.readString(offsets[23]);
  object.partyId = reader.readStringOrNull(offsets[24]);
  object.partyName = reader.readStringOrNull(offsets[25]);
  object.reversalOfVoucherId = reader.readStringOrNull(offsets[26]);
  object.reversalReason = reader.readStringOrNull(offsets[27]);
  object.route = reader.readStringOrNull(offsets[28]);
  object.saleDate = reader.readStringOrNull(offsets[29]);
  object.salesmanId = reader.readStringOrNull(offsets[30]);
  object.salesmanName = reader.readStringOrNull(offsets[31]);
  object.sourceId = reader.readStringOrNull(offsets[32]);
  object.sourceModule = reader.readStringOrNull(offsets[33]);
  object.sourceNumber = reader.readStringOrNull(offsets[34]);
  object.status = reader.readString(offsets[35]);
  object.syncStatus = _VoucherEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[36])] ??
      SyncStatus.pending;
  object.totalCredit = reader.readDouble(offsets[37]);
  object.totalDebit = reader.readDouble(offsets[38]);
  object.transactionRefId = reader.readString(offsets[39]);
  object.type = reader.readString(offsets[40]);
  object.updatedAt = reader.readDateTime(offsets[41]);
  object.version = reader.readLong(offsets[42]);
  object.voucherNumber = reader.readStringOrNull(offsets[43]);
  object.voucherType = reader.readStringOrNull(offsets[44]);
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readStringOrNull(offset)) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readString(offset)) as P;
    case 36:
      return (_VoucherEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 37:
      return (reader.readDouble(offset)) as P;
    case 38:
      return (reader.readDouble(offset)) as P;
    case 39:
      return (reader.readString(offset)) as P;
    case 40:
      return (reader.readString(offset)) as P;
    case 41:
      return (reader.readDateTime(offset)) as P;
    case 42:
      return (reader.readLong(offset)) as P;
    case 43:
      return (reader.readStringOrNull(offset)) as P;
    case 44:
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelReason',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelReason',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelReason',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelReason',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      cancelledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdByName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdByName',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByName',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      createdByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdByName',
        value: '',
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
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      entryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      entryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      entryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      entryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financialYearId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financialYearId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'financialYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'financialYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'financialYearId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'financialYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'financialYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'financialYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'financialYearId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      financialYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialYearId',
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
      isBalancedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBalanced',
        value: value,
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
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
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
      lastSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      lastSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      lastSyncedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      lastSyncedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      lastSyncedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      lastSyncedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSynced',
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
      partyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partyId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partyId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partyId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      partyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partyId',
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
      reversalOfVoucherIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reversalOfVoucherId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reversalOfVoucherId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalOfVoucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reversalOfVoucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reversalOfVoucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reversalOfVoucherId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reversalOfVoucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reversalOfVoucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reversalOfVoucherId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reversalOfVoucherId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalOfVoucherId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalOfVoucherIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reversalOfVoucherId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reversalReason',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reversalReason',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reversalReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reversalReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalReason',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      reversalReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reversalReason',
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
      sourceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceId',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceModule',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceModule',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceModule',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceModule',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceModule',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceModuleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceModule',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceNumber',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceNumber',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      sourceNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
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
      totalCreditEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCredit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      totalCreditGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCredit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      totalCreditLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCredit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      totalCreditBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCredit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      totalDebitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDebit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      totalDebitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDebit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      totalDebitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDebit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      totalDebitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDebit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
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
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voucherType',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voucherType',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voucherType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voucherType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voucherType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voucherType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voucherType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voucherType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voucherType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherType',
        value: '',
      ));
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterFilterCondition>
      voucherTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voucherType',
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByCancelReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByCancelReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByEntryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByEntryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByFinancialYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialYearId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByFinancialYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialYearId', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByIsBalanced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanced', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByIsBalancedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanced', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByPartyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByReversalOfVoucherId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalOfVoucherId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByReversalOfVoucherIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalOfVoucherId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByReversalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByReversalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySourceModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySourceModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySourceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNumber', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortBySourceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNumber', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByTotalCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCredit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByTotalCreditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCredit', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByTotalDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByTotalDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebit', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> sortByVoucherType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherType', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      sortByVoucherTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherType', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByCancelReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByCancelReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelReason', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByCreatedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByCreatedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByName', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByEntryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByEntryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByFinancialYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialYearId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByFinancialYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialYearId', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByIsBalanced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanced', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByIsBalancedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBalanced', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByPartyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByReversalOfVoucherId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalOfVoucherId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByReversalOfVoucherIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalOfVoucherId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByReversalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByReversalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySourceModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySourceModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySourceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNumber', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenBySourceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceNumber', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByTotalCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCredit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByTotalCreditDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCredit', Sort.desc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByTotalDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebit', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByTotalDebitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebit', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy> thenByVoucherType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherType', Sort.asc);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QAfterSortBy>
      thenByVoucherTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherType', Sort.desc);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByCancelReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledAt');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByCreatedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByCreatedByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByName',
          caseSensitive: caseSensitive);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByEntryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryCount');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByFinancialYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByIsBalanced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBalanced');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSynced');
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

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByPartyId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByPartyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partyName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByReversalOfVoucherId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reversalOfVoucherId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByReversalReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reversalReason',
          caseSensitive: caseSensitive);
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

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySourceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySourceModule(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceModule', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySourceNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct>
      distinctByTotalCredit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCredit');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByTotalDebit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDebit');
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

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByVoucherNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voucherNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VoucherEntity, VoucherEntity, QDistinct> distinctByVoucherType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voucherType', caseSensitive: caseSensitive);
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

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      cancelReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelReason');
    });
  }

  QueryBuilder<VoucherEntity, DateTime?, QQueryOperations>
      cancelledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledAt');
    });
  }

  QueryBuilder<VoucherEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      createdByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByName');
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

  QueryBuilder<VoucherEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
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

  QueryBuilder<VoucherEntity, int, QQueryOperations> entryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryCount');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      financialYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialYearId');
    });
  }

  QueryBuilder<VoucherEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VoucherEntity, bool, QQueryOperations> isBalancedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBalanced');
    });
  }

  QueryBuilder<VoucherEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<VoucherEntity, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<VoucherEntity, DateTime?, QQueryOperations>
      lastSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSynced');
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

  QueryBuilder<VoucherEntity, String?, QQueryOperations> partyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partyId');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> partyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partyName');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      reversalOfVoucherIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reversalOfVoucherId');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      reversalReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reversalReason');
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

  QueryBuilder<VoucherEntity, String?, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      sourceModuleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceModule');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      sourceNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceNumber');
    });
  }

  QueryBuilder<VoucherEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<VoucherEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<VoucherEntity, double, QQueryOperations> totalCreditProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCredit');
    });
  }

  QueryBuilder<VoucherEntity, double, QQueryOperations> totalDebitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDebit');
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

  QueryBuilder<VoucherEntity, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations>
      voucherNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voucherNumber');
    });
  }

  QueryBuilder<VoucherEntity, String?, QQueryOperations> voucherTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voucherType');
    });
  }
}
