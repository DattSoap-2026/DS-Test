// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cutting_batch_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCuttingBatchEntityCollection on Isar {
  IsarCollection<CuttingBatchEntity> get cuttingBatchEntitys =>
      this.collection();
}

const CuttingBatchEntitySchema = CollectionSchema(
  name: r'CuttingBatchEntity',
  id: -7039675186929719099,
  properties: {
    r'actualAvgWeightGm': PropertySchema(
      id: 0,
      name: r'actualAvgWeightGm',
      type: IsarType.double,
    ),
    r'avgBoxWeightKg': PropertySchema(
      id: 1,
      name: r'avgBoxWeightKg',
      type: IsarType.double,
    ),
    r'batchGeneId': PropertySchema(
      id: 2,
      name: r'batchGeneId',
      type: IsarType.string,
    ),
    r'batchNumber': PropertySchema(
      id: 3,
      name: r'batchNumber',
      type: IsarType.string,
    ),
    r'boxesCount': PropertySchema(
      id: 4,
      name: r'boxesCount',
      type: IsarType.long,
    ),
    r'completedAt': PropertySchema(
      id: 5,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'cuttingWasteKg': PropertySchema(
      id: 7,
      name: r'cuttingWasteKg',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 8,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 9,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'departmentId': PropertySchema(
      id: 10,
      name: r'departmentId',
      type: IsarType.string,
    ),
    r'departmentName': PropertySchema(
      id: 11,
      name: r'departmentName',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 12,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'finishedGoodId': PropertySchema(
      id: 13,
      name: r'finishedGoodId',
      type: IsarType.string,
    ),
    r'finishedGoodName': PropertySchema(
      id: 14,
      name: r'finishedGoodName',
      type: IsarType.string,
    ),
    r'finishedGoodsStockAdjusted': PropertySchema(
      id: 15,
      name: r'finishedGoodsStockAdjusted',
      type: IsarType.bool,
    ),
    r'id': PropertySchema(
      id: 16,
      name: r'id',
      type: IsarType.string,
    ),
    r'inputWeightKg': PropertySchema(
      id: 17,
      name: r'inputWeightKg',
      type: IsarType.double,
    ),
    r'isDeleted': PropertySchema(
      id: 18,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 19,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastSynced': PropertySchema(
      id: 20,
      name: r'lastSynced',
      type: IsarType.dateTime,
    ),
    r'operatorId': PropertySchema(
      id: 21,
      name: r'operatorId',
      type: IsarType.string,
    ),
    r'operatorName': PropertySchema(
      id: 22,
      name: r'operatorName',
      type: IsarType.string,
    ),
    r'outputWeightKg': PropertySchema(
      id: 23,
      name: r'outputWeightKg',
      type: IsarType.double,
    ),
    r'rejectionReason': PropertySchema(
      id: 24,
      name: r'rejectionReason',
      type: IsarType.string,
    ),
    r'semiFinishedProductId': PropertySchema(
      id: 25,
      name: r'semiFinishedProductId',
      type: IsarType.string,
    ),
    r'semiFinishedProductName': PropertySchema(
      id: 26,
      name: r'semiFinishedProductName',
      type: IsarType.string,
    ),
    r'semiFinishedStockAdjusted': PropertySchema(
      id: 27,
      name: r'semiFinishedStockAdjusted',
      type: IsarType.bool,
    ),
    r'shift': PropertySchema(
      id: 28,
      name: r'shift',
      type: IsarType.string,
    ),
    r'stage': PropertySchema(
      id: 29,
      name: r'stage',
      type: IsarType.string,
    ),
    r'standardWeightGm': PropertySchema(
      id: 30,
      name: r'standardWeightGm',
      type: IsarType.double,
    ),
    r'supervisorId': PropertySchema(
      id: 31,
      name: r'supervisorId',
      type: IsarType.string,
    ),
    r'supervisorName': PropertySchema(
      id: 32,
      name: r'supervisorName',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 33,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _CuttingBatchEntitysyncStatusEnumValueMap,
    ),
    r'tolerancePercent': PropertySchema(
      id: 34,
      name: r'tolerancePercent',
      type: IsarType.double,
    ),
    r'totalBatchWeightKg': PropertySchema(
      id: 35,
      name: r'totalBatchWeightKg',
      type: IsarType.double,
    ),
    r'totalFinishedWeightKg': PropertySchema(
      id: 36,
      name: r'totalFinishedWeightKg',
      type: IsarType.double,
    ),
    r'unitsProduced': PropertySchema(
      id: 37,
      name: r'unitsProduced',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 38,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 39,
      name: r'version',
      type: IsarType.long,
    ),
    r'wasteRemark': PropertySchema(
      id: 40,
      name: r'wasteRemark',
      type: IsarType.string,
    ),
    r'wasteStockAdjusted': PropertySchema(
      id: 41,
      name: r'wasteStockAdjusted',
      type: IsarType.bool,
    ),
    r'wasteType': PropertySchema(
      id: 42,
      name: r'wasteType',
      type: IsarType.string,
    ),
    r'wasteWeightKg': PropertySchema(
      id: 43,
      name: r'wasteWeightKg',
      type: IsarType.double,
    ),
    r'weightBalanceValid': PropertySchema(
      id: 44,
      name: r'weightBalanceValid',
      type: IsarType.bool,
    ),
    r'weightDifferenceKg': PropertySchema(
      id: 45,
      name: r'weightDifferenceKg',
      type: IsarType.double,
    ),
    r'weightDifferencePercent': PropertySchema(
      id: 46,
      name: r'weightDifferencePercent',
      type: IsarType.double,
    ),
    r'weightValidationMessage': PropertySchema(
      id: 47,
      name: r'weightValidationMessage',
      type: IsarType.string,
    ),
    r'weightValidationPassed': PropertySchema(
      id: 48,
      name: r'weightValidationPassed',
      type: IsarType.bool,
    )
  },
  estimateSize: _cuttingBatchEntityEstimateSize,
  serialize: _cuttingBatchEntitySerialize,
  deserialize: _cuttingBatchEntityDeserialize,
  deserializeProp: _cuttingBatchEntityDeserializeProp,
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
    r'batchGeneId': IndexSchema(
      id: 7743754317774011156,
      name: r'batchGeneId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'batchGeneId',
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
    r'semiFinishedProductId': IndexSchema(
      id: -1867326522524618946,
      name: r'semiFinishedProductId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'semiFinishedProductId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'finishedGoodId': IndexSchema(
      id: -2818918535409507697,
      name: r'finishedGoodId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'finishedGoodId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'stage': IndexSchema(
      id: 4281597865616208537,
      name: r'stage',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stage',
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
  getId: _cuttingBatchEntityGetId,
  getLinks: _cuttingBatchEntityGetLinks,
  attach: _cuttingBatchEntityAttach,
  version: '3.1.0+1',
);

int _cuttingBatchEntityEstimateSize(
  CuttingBatchEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.batchGeneId.length * 3;
  bytesCount += 3 + object.batchNumber.length * 3;
  bytesCount += 3 + object.departmentId.length * 3;
  bytesCount += 3 + object.departmentName.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.finishedGoodId.length * 3;
  bytesCount += 3 + object.finishedGoodName.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.operatorId.length * 3;
  bytesCount += 3 + object.operatorName.length * 3;
  {
    final value = object.rejectionReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.semiFinishedProductId.length * 3;
  bytesCount += 3 + object.semiFinishedProductName.length * 3;
  bytesCount += 3 + object.shift.length * 3;
  bytesCount += 3 + object.stage.length * 3;
  bytesCount += 3 + object.supervisorId.length * 3;
  bytesCount += 3 + object.supervisorName.length * 3;
  {
    final value = object.wasteRemark;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.wasteType.length * 3;
  {
    final value = object.weightValidationMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cuttingBatchEntitySerialize(
  CuttingBatchEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.actualAvgWeightGm);
  writer.writeDouble(offsets[1], object.avgBoxWeightKg);
  writer.writeString(offsets[2], object.batchGeneId);
  writer.writeString(offsets[3], object.batchNumber);
  writer.writeLong(offsets[4], object.boxesCount);
  writer.writeDateTime(offsets[5], object.completedAt);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeDouble(offsets[7], object.cuttingWasteKg);
  writer.writeDateTime(offsets[8], object.date);
  writer.writeDateTime(offsets[9], object.deletedAt);
  writer.writeString(offsets[10], object.departmentId);
  writer.writeString(offsets[11], object.departmentName);
  writer.writeString(offsets[12], object.deviceId);
  writer.writeString(offsets[13], object.finishedGoodId);
  writer.writeString(offsets[14], object.finishedGoodName);
  writer.writeBool(offsets[15], object.finishedGoodsStockAdjusted);
  writer.writeString(offsets[16], object.id);
  writer.writeDouble(offsets[17], object.inputWeightKg);
  writer.writeBool(offsets[18], object.isDeleted);
  writer.writeBool(offsets[19], object.isSynced);
  writer.writeDateTime(offsets[20], object.lastSynced);
  writer.writeString(offsets[21], object.operatorId);
  writer.writeString(offsets[22], object.operatorName);
  writer.writeDouble(offsets[23], object.outputWeightKg);
  writer.writeString(offsets[24], object.rejectionReason);
  writer.writeString(offsets[25], object.semiFinishedProductId);
  writer.writeString(offsets[26], object.semiFinishedProductName);
  writer.writeBool(offsets[27], object.semiFinishedStockAdjusted);
  writer.writeString(offsets[28], object.shift);
  writer.writeString(offsets[29], object.stage);
  writer.writeDouble(offsets[30], object.standardWeightGm);
  writer.writeString(offsets[31], object.supervisorId);
  writer.writeString(offsets[32], object.supervisorName);
  writer.writeByte(offsets[33], object.syncStatus.index);
  writer.writeDouble(offsets[34], object.tolerancePercent);
  writer.writeDouble(offsets[35], object.totalBatchWeightKg);
  writer.writeDouble(offsets[36], object.totalFinishedWeightKg);
  writer.writeLong(offsets[37], object.unitsProduced);
  writer.writeDateTime(offsets[38], object.updatedAt);
  writer.writeLong(offsets[39], object.version);
  writer.writeString(offsets[40], object.wasteRemark);
  writer.writeBool(offsets[41], object.wasteStockAdjusted);
  writer.writeString(offsets[42], object.wasteType);
  writer.writeDouble(offsets[43], object.wasteWeightKg);
  writer.writeBool(offsets[44], object.weightBalanceValid);
  writer.writeDouble(offsets[45], object.weightDifferenceKg);
  writer.writeDouble(offsets[46], object.weightDifferencePercent);
  writer.writeString(offsets[47], object.weightValidationMessage);
  writer.writeBool(offsets[48], object.weightValidationPassed);
}

CuttingBatchEntity _cuttingBatchEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CuttingBatchEntity();
  object.actualAvgWeightGm = reader.readDouble(offsets[0]);
  object.avgBoxWeightKg = reader.readDoubleOrNull(offsets[1]);
  object.batchGeneId = reader.readString(offsets[2]);
  object.batchNumber = reader.readString(offsets[3]);
  object.boxesCount = reader.readLong(offsets[4]);
  object.completedAt = reader.readDateTimeOrNull(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.cuttingWasteKg = reader.readDouble(offsets[7]);
  object.date = reader.readDateTime(offsets[8]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[9]);
  object.departmentId = reader.readString(offsets[10]);
  object.departmentName = reader.readString(offsets[11]);
  object.deviceId = reader.readString(offsets[12]);
  object.finishedGoodId = reader.readString(offsets[13]);
  object.finishedGoodName = reader.readString(offsets[14]);
  object.finishedGoodsStockAdjusted = reader.readBool(offsets[15]);
  object.id = reader.readString(offsets[16]);
  object.inputWeightKg = reader.readDouble(offsets[17]);
  object.isDeleted = reader.readBool(offsets[18]);
  object.isSynced = reader.readBool(offsets[19]);
  object.lastSynced = reader.readDateTimeOrNull(offsets[20]);
  object.operatorId = reader.readString(offsets[21]);
  object.operatorName = reader.readString(offsets[22]);
  object.outputWeightKg = reader.readDouble(offsets[23]);
  object.rejectionReason = reader.readStringOrNull(offsets[24]);
  object.semiFinishedProductId = reader.readString(offsets[25]);
  object.semiFinishedProductName = reader.readString(offsets[26]);
  object.semiFinishedStockAdjusted = reader.readBool(offsets[27]);
  object.shift = reader.readString(offsets[28]);
  object.stage = reader.readString(offsets[29]);
  object.standardWeightGm = reader.readDouble(offsets[30]);
  object.supervisorId = reader.readString(offsets[31]);
  object.supervisorName = reader.readString(offsets[32]);
  object.syncStatus = _CuttingBatchEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[33])] ??
      SyncStatus.pending;
  object.tolerancePercent = reader.readDouble(offsets[34]);
  object.totalBatchWeightKg = reader.readDouble(offsets[35]);
  object.totalFinishedWeightKg = reader.readDouble(offsets[36]);
  object.unitsProduced = reader.readLong(offsets[37]);
  object.updatedAt = reader.readDateTime(offsets[38]);
  object.version = reader.readLong(offsets[39]);
  object.wasteRemark = reader.readStringOrNull(offsets[40]);
  object.wasteStockAdjusted = reader.readBool(offsets[41]);
  object.wasteType = reader.readString(offsets[42]);
  object.wasteWeightKg = reader.readDouble(offsets[43]);
  object.weightBalanceValid = reader.readBool(offsets[44]);
  object.weightDifferenceKg = reader.readDouble(offsets[45]);
  object.weightDifferencePercent = reader.readDouble(offsets[46]);
  object.weightValidationMessage = reader.readStringOrNull(offsets[47]);
  object.weightValidationPassed = reader.readBool(offsets[48]);
  return object;
}

P _cuttingBatchEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readDouble(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readBool(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readDouble(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (_CuttingBatchEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 34:
      return (reader.readDouble(offset)) as P;
    case 35:
      return (reader.readDouble(offset)) as P;
    case 36:
      return (reader.readDouble(offset)) as P;
    case 37:
      return (reader.readLong(offset)) as P;
    case 38:
      return (reader.readDateTime(offset)) as P;
    case 39:
      return (reader.readLong(offset)) as P;
    case 40:
      return (reader.readStringOrNull(offset)) as P;
    case 41:
      return (reader.readBool(offset)) as P;
    case 42:
      return (reader.readString(offset)) as P;
    case 43:
      return (reader.readDouble(offset)) as P;
    case 44:
      return (reader.readBool(offset)) as P;
    case 45:
      return (reader.readDouble(offset)) as P;
    case 46:
      return (reader.readDouble(offset)) as P;
    case 47:
      return (reader.readStringOrNull(offset)) as P;
    case 48:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CuttingBatchEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _CuttingBatchEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _cuttingBatchEntityGetId(CuttingBatchEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _cuttingBatchEntityGetLinks(
    CuttingBatchEntity object) {
  return [];
}

void _cuttingBatchEntityAttach(
    IsarCollection<dynamic> col, Id id, CuttingBatchEntity object) {}

extension CuttingBatchEntityByIndex on IsarCollection<CuttingBatchEntity> {
  Future<CuttingBatchEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  CuttingBatchEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<CuttingBatchEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<CuttingBatchEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(CuttingBatchEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(CuttingBatchEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<CuttingBatchEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<CuttingBatchEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension CuttingBatchEntityQueryWhereSort
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QWhere> {
  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension CuttingBatchEntityQueryWhere
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QWhereClause> {
  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      batchNumberEqualTo(String batchNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'batchNumber',
        value: [batchNumber],
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      batchNumberNotEqualTo(String batchNumber) {
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      batchGeneIdEqualTo(String batchGeneId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'batchGeneId',
        value: [batchGeneId],
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      batchGeneIdNotEqualTo(String batchGeneId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchGeneId',
              lower: [],
              upper: [batchGeneId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchGeneId',
              lower: [batchGeneId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchGeneId',
              lower: [batchGeneId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'batchGeneId',
              lower: [],
              upper: [batchGeneId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      dateGreaterThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      dateLessThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      dateBetween(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      semiFinishedProductIdEqualTo(String semiFinishedProductId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'semiFinishedProductId',
        value: [semiFinishedProductId],
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      semiFinishedProductIdNotEqualTo(String semiFinishedProductId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semiFinishedProductId',
              lower: [],
              upper: [semiFinishedProductId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semiFinishedProductId',
              lower: [semiFinishedProductId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semiFinishedProductId',
              lower: [semiFinishedProductId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semiFinishedProductId',
              lower: [],
              upper: [semiFinishedProductId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      finishedGoodIdEqualTo(String finishedGoodId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'finishedGoodId',
        value: [finishedGoodId],
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      finishedGoodIdNotEqualTo(String finishedGoodId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedGoodId',
              lower: [],
              upper: [finishedGoodId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedGoodId',
              lower: [finishedGoodId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedGoodId',
              lower: [finishedGoodId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finishedGoodId',
              lower: [],
              upper: [finishedGoodId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      stageEqualTo(String stage) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stage',
        value: [stage],
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      stageNotEqualTo(String stage) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stage',
              lower: [],
              upper: [stage],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stage',
              lower: [stage],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stage',
              lower: [stage],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stage',
              lower: [],
              upper: [stage],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterWhereClause>
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

extension CuttingBatchEntityQueryFilter
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QFilterCondition> {
  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      actualAvgWeightGmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualAvgWeightGm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      actualAvgWeightGmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualAvgWeightGm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      actualAvgWeightGmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualAvgWeightGm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      actualAvgWeightGmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualAvgWeightGm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      avgBoxWeightKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avgBoxWeightKg',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      avgBoxWeightKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avgBoxWeightKg',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      avgBoxWeightKgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgBoxWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      avgBoxWeightKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgBoxWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      avgBoxWeightKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgBoxWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      avgBoxWeightKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgBoxWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchGeneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batchGeneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batchGeneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batchGeneId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'batchGeneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'batchGeneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchGeneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchGeneId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchGeneId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchGeneIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchGeneId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberEqualTo(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberGreaterThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberLessThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberBetween(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberStartsWith(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberEndsWith(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'batchNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'batchNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batchNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      batchNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'batchNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      boxesCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'boxesCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      boxesCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'boxesCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      boxesCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'boxesCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      boxesCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'boxesCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      cuttingWasteKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cuttingWasteKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      cuttingWasteKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cuttingWasteKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      cuttingWasteKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cuttingWasteKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      cuttingWasteKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cuttingWasteKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      dateBetween(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      departmentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedGoodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finishedGoodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finishedGoodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finishedGoodId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'finishedGoodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'finishedGoodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'finishedGoodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'finishedGoodId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedGoodId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'finishedGoodId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedGoodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finishedGoodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finishedGoodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finishedGoodName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'finishedGoodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'finishedGoodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'finishedGoodName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'finishedGoodName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedGoodName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'finishedGoodName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      finishedGoodsStockAdjustedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedGoodsStockAdjusted',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      inputWeightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      inputWeightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inputWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      inputWeightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inputWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      inputWeightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inputWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      lastSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      lastSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSynced',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      lastSyncedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operatorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operatorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatorId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operatorId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operatorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operatorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operatorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatorName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      operatorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operatorName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      outputWeightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      outputWeightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outputWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      outputWeightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outputWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      outputWeightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outputWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rejectionReason',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rejectionReason',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectionReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rejectionReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectionReason',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      rejectionReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rejectionReason',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semiFinishedProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'semiFinishedProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'semiFinishedProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'semiFinishedProductId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'semiFinishedProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'semiFinishedProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'semiFinishedProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'semiFinishedProductId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semiFinishedProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'semiFinishedProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semiFinishedProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'semiFinishedProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'semiFinishedProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'semiFinishedProductName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'semiFinishedProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'semiFinishedProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'semiFinishedProductName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'semiFinishedProductName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semiFinishedProductName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedProductNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'semiFinishedProductName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      semiFinishedStockAdjustedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semiFinishedStockAdjusted',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shift',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shift',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shift',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      shiftIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shift',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stage',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      stageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stage',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      standardWeightGmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standardWeightGm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      standardWeightGmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'standardWeightGm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      standardWeightGmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'standardWeightGm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      standardWeightGmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'standardWeightGm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdEqualTo(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdGreaterThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdLessThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdBetween(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdStartsWith(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdEndsWith(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supervisorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supervisorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supervisorId',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameEqualTo(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameGreaterThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameLessThan(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameBetween(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameStartsWith(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameEndsWith(
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supervisorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supervisorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supervisorName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      supervisorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supervisorName',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      tolerancePercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tolerancePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      tolerancePercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tolerancePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      tolerancePercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tolerancePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      tolerancePercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tolerancePercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalBatchWeightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBatchWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalBatchWeightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBatchWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalBatchWeightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBatchWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalBatchWeightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBatchWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalFinishedWeightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFinishedWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalFinishedWeightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFinishedWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalFinishedWeightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFinishedWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      totalFinishedWeightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFinishedWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      unitsProducedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitsProduced',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      unitsProducedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitsProduced',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      unitsProducedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitsProduced',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      unitsProducedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitsProduced',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
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

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wasteRemark',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wasteRemark',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasteRemark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wasteRemark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wasteRemark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wasteRemark',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'wasteRemark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'wasteRemark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'wasteRemark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'wasteRemark',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasteRemark',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteRemarkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'wasteRemark',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteStockAdjustedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasteStockAdjusted',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasteType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wasteType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wasteType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wasteType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'wasteType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'wasteType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'wasteType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'wasteType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasteType',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'wasteType',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteWeightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasteWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteWeightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wasteWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteWeightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wasteWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      wasteWeightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wasteWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightBalanceValidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightBalanceValid',
        value: value,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferenceKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightDifferenceKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferenceKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightDifferenceKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferenceKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightDifferenceKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferenceKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightDifferenceKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferencePercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightDifferencePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferencePercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightDifferencePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferencePercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightDifferencePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightDifferencePercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightDifferencePercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weightValidationMessage',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weightValidationMessage',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightValidationMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightValidationMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightValidationMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightValidationMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weightValidationMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weightValidationMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weightValidationMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weightValidationMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightValidationMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weightValidationMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterFilterCondition>
      weightValidationPassedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightValidationPassed',
        value: value,
      ));
    });
  }
}

extension CuttingBatchEntityQueryObject
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QFilterCondition> {}

extension CuttingBatchEntityQueryLinks
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QFilterCondition> {}

extension CuttingBatchEntityQuerySortBy
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QSortBy> {
  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByActualAvgWeightGm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualAvgWeightGm', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByActualAvgWeightGmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualAvgWeightGm', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByAvgBoxWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBoxWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByAvgBoxWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBoxWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByBatchGeneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchGeneId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByBatchGeneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchGeneId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByBatchNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByBatchNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByBoxesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boxesCount', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByBoxesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boxesCount', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByCuttingWasteKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuttingWasteKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByCuttingWasteKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuttingWasteKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDepartmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDepartmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDepartmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDepartmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByFinishedGoodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByFinishedGoodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByFinishedGoodName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByFinishedGoodNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByFinishedGoodsStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodsStockAdjusted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByFinishedGoodsStockAdjustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodsStockAdjusted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByInputWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByInputWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByOperatorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByOperatorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByOutputWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByOutputWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByRejectionReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByRejectionReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySemiFinishedProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySemiFinishedProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySemiFinishedProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySemiFinishedProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySemiFinishedStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedStockAdjusted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySemiFinishedStockAdjustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedStockAdjusted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByStandardWeightGm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standardWeightGm', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByStandardWeightGmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standardWeightGm', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySupervisorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySupervisorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByTolerancePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tolerancePercent', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByTolerancePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tolerancePercent', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByTotalBatchWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByTotalBatchWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByTotalFinishedWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFinishedWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByTotalFinishedWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFinishedWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByUnitsProduced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsProduced', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByUnitsProducedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsProduced', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteRemark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteRemark', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteRemarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteRemark', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteStockAdjusted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteStockAdjustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteStockAdjusted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteType', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteType', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWasteWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightBalanceValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightBalanceValid', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightBalanceValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightBalanceValid', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightDifferenceKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferenceKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightDifferenceKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferenceKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightDifferencePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferencePercent', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightDifferencePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferencePercent', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightValidationMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationMessage', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightValidationMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationMessage', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightValidationPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationPassed', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      sortByWeightValidationPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationPassed', Sort.desc);
    });
  }
}

extension CuttingBatchEntityQuerySortThenBy
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QSortThenBy> {
  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByActualAvgWeightGm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualAvgWeightGm', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByActualAvgWeightGmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualAvgWeightGm', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByAvgBoxWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBoxWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByAvgBoxWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgBoxWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByBatchGeneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchGeneId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByBatchGeneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchGeneId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByBatchNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByBatchNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batchNumber', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByBoxesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boxesCount', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByBoxesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boxesCount', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByCuttingWasteKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuttingWasteKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByCuttingWasteKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuttingWasteKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDepartmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDepartmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDepartmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDepartmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByFinishedGoodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByFinishedGoodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByFinishedGoodName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByFinishedGoodNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByFinishedGoodsStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodsStockAdjusted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByFinishedGoodsStockAdjustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedGoodsStockAdjusted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByInputWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByInputWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByLastSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSynced', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByOperatorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByOperatorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByOutputWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByOutputWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByRejectionReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByRejectionReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySemiFinishedProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySemiFinishedProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySemiFinishedProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySemiFinishedProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedProductName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySemiFinishedStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedStockAdjusted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySemiFinishedStockAdjustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semiFinishedStockAdjusted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByStandardWeightGm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standardWeightGm', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByStandardWeightGmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standardWeightGm', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySupervisorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySupervisorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorId', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySupervisorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySupervisorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisorName', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByTolerancePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tolerancePercent', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByTolerancePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tolerancePercent', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByTotalBatchWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByTotalBatchWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBatchWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByTotalFinishedWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFinishedWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByTotalFinishedWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFinishedWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByUnitsProduced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsProduced', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByUnitsProducedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsProduced', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteRemark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteRemark', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteRemarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteRemark', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteStockAdjusted', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteStockAdjustedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteStockAdjusted', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteType', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteType', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteWeightKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWasteWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasteWeightKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightBalanceValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightBalanceValid', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightBalanceValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightBalanceValid', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightDifferenceKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferenceKg', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightDifferenceKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferenceKg', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightDifferencePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferencePercent', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightDifferencePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightDifferencePercent', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightValidationMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationMessage', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightValidationMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationMessage', Sort.desc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightValidationPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationPassed', Sort.asc);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QAfterSortBy>
      thenByWeightValidationPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValidationPassed', Sort.desc);
    });
  }
}

extension CuttingBatchEntityQueryWhereDistinct
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct> {
  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByActualAvgWeightGm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualAvgWeightGm');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByAvgBoxWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgBoxWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByBatchGeneId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchGeneId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByBatchNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batchNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByBoxesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boxesCount');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByCuttingWasteKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cuttingWasteKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByDepartmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByDepartmentName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByFinishedGoodId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedGoodId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByFinishedGoodName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedGoodName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByFinishedGoodsStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedGoodsStockAdjusted');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByInputWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByLastSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSynced');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByOperatorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operatorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByOperatorName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operatorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByOutputWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByRejectionReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectionReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctBySemiFinishedProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semiFinishedProductId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctBySemiFinishedProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semiFinishedProductName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctBySemiFinishedStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semiFinishedStockAdjusted');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByShift({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shift', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByStage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByStandardWeightGm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'standardWeightGm');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctBySupervisorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctBySupervisorName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisorName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByTolerancePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tolerancePercent');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByTotalBatchWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBatchWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByTotalFinishedWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFinishedWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByUnitsProduced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitsProduced');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWasteRemark({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasteRemark', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWasteStockAdjusted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasteStockAdjusted');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWasteType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasteType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWasteWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasteWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWeightBalanceValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightBalanceValid');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWeightDifferenceKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightDifferenceKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWeightDifferencePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightDifferencePercent');
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWeightValidationMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightValidationMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QDistinct>
      distinctByWeightValidationPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightValidationPassed');
    });
  }
}

extension CuttingBatchEntityQueryProperty
    on QueryBuilder<CuttingBatchEntity, CuttingBatchEntity, QQueryProperty> {
  QueryBuilder<CuttingBatchEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      actualAvgWeightGmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualAvgWeightGm');
    });
  }

  QueryBuilder<CuttingBatchEntity, double?, QQueryOperations>
      avgBoxWeightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgBoxWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      batchGeneIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchGeneId');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      batchNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batchNumber');
    });
  }

  QueryBuilder<CuttingBatchEntity, int, QQueryOperations> boxesCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boxesCount');
    });
  }

  QueryBuilder<CuttingBatchEntity, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      cuttingWasteKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cuttingWasteKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<CuttingBatchEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      departmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentId');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      departmentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentName');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      finishedGoodIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedGoodId');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      finishedGoodNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedGoodName');
    });
  }

  QueryBuilder<CuttingBatchEntity, bool, QQueryOperations>
      finishedGoodsStockAdjustedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedGoodsStockAdjusted');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      inputWeightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<CuttingBatchEntity, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<CuttingBatchEntity, DateTime?, QQueryOperations>
      lastSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSynced');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      operatorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operatorId');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      operatorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operatorName');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      outputWeightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, String?, QQueryOperations>
      rejectionReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectionReason');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      semiFinishedProductIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semiFinishedProductId');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      semiFinishedProductNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semiFinishedProductName');
    });
  }

  QueryBuilder<CuttingBatchEntity, bool, QQueryOperations>
      semiFinishedStockAdjustedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semiFinishedStockAdjusted');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations> shiftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shift');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations> stageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stage');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      standardWeightGmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'standardWeightGm');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      supervisorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisorId');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      supervisorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisorName');
    });
  }

  QueryBuilder<CuttingBatchEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      tolerancePercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tolerancePercent');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      totalBatchWeightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBatchWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      totalFinishedWeightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFinishedWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, int, QQueryOperations>
      unitsProducedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitsProduced');
    });
  }

  QueryBuilder<CuttingBatchEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<CuttingBatchEntity, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }

  QueryBuilder<CuttingBatchEntity, String?, QQueryOperations>
      wasteRemarkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasteRemark');
    });
  }

  QueryBuilder<CuttingBatchEntity, bool, QQueryOperations>
      wasteStockAdjustedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasteStockAdjusted');
    });
  }

  QueryBuilder<CuttingBatchEntity, String, QQueryOperations>
      wasteTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasteType');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      wasteWeightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasteWeightKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, bool, QQueryOperations>
      weightBalanceValidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightBalanceValid');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      weightDifferenceKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightDifferenceKg');
    });
  }

  QueryBuilder<CuttingBatchEntity, double, QQueryOperations>
      weightDifferencePercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightDifferencePercent');
    });
  }

  QueryBuilder<CuttingBatchEntity, String?, QQueryOperations>
      weightValidationMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightValidationMessage');
    });
  }

  QueryBuilder<CuttingBatchEntity, bool, QQueryOperations>
      weightValidationPassedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightValidationPassed');
    });
  }
}
