// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_record_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPayrollRecordEntityCollection on Isar {
  IsarCollection<PayrollRecordEntity> get payrollRecordEntitys =>
      this.collection();
}

const PayrollRecordEntitySchema = CollectionSchema(
  name: r'PayrollRecordEntity',
  id: -3848737348331855622,
  properties: {
    r'baseSalary': PropertySchema(
      id: 0,
      name: r'baseSalary',
      type: IsarType.double,
    ),
    r'bonuses': PropertySchema(
      id: 1,
      name: r'bonuses',
      type: IsarType.double,
    ),
    r'deductions': PropertySchema(
      id: 2,
      name: r'deductions',
      type: IsarType.double,
    ),
    r'deletedAt': PropertySchema(
      id: 3,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'employeeId': PropertySchema(
      id: 4,
      name: r'employeeId',
      type: IsarType.string,
    ),
    r'generatedAt': PropertySchema(
      id: 5,
      name: r'generatedAt',
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
    r'month': PropertySchema(
      id: 8,
      name: r'month',
      type: IsarType.string,
    ),
    r'netSalary': PropertySchema(
      id: 9,
      name: r'netSalary',
      type: IsarType.double,
    ),
    r'paidAt': PropertySchema(
      id: 10,
      name: r'paidAt',
      type: IsarType.dateTime,
    ),
    r'paymentReference': PropertySchema(
      id: 11,
      name: r'paymentReference',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 13,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _PayrollRecordEntitysyncStatusEnumValueMap,
    ),
    r'totalHours': PropertySchema(
      id: 14,
      name: r'totalHours',
      type: IsarType.double,
    ),
    r'totalOvertimeHours': PropertySchema(
      id: 15,
      name: r'totalOvertimeHours',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _payrollRecordEntityEstimateSize,
  serialize: _payrollRecordEntitySerialize,
  deserialize: _payrollRecordEntityDeserialize,
  deserializeProp: _payrollRecordEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'employeeId': IndexSchema(
      id: 1283453093523034672,
      name: r'employeeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'employeeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'month': IndexSchema(
      id: -3594385961712742690,
      name: r'month',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'month',
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
  getId: _payrollRecordEntityGetId,
  getLinks: _payrollRecordEntityGetLinks,
  attach: _payrollRecordEntityAttach,
  version: '3.1.0+1',
);

int _payrollRecordEntityEstimateSize(
  PayrollRecordEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.employeeId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.month.length * 3;
  {
    final value = object.paymentReference;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _payrollRecordEntitySerialize(
  PayrollRecordEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.baseSalary);
  writer.writeDouble(offsets[1], object.bonuses);
  writer.writeDouble(offsets[2], object.deductions);
  writer.writeDateTime(offsets[3], object.deletedAt);
  writer.writeString(offsets[4], object.employeeId);
  writer.writeDateTime(offsets[5], object.generatedAt);
  writer.writeString(offsets[6], object.id);
  writer.writeBool(offsets[7], object.isDeleted);
  writer.writeString(offsets[8], object.month);
  writer.writeDouble(offsets[9], object.netSalary);
  writer.writeDateTime(offsets[10], object.paidAt);
  writer.writeString(offsets[11], object.paymentReference);
  writer.writeString(offsets[12], object.status);
  writer.writeByte(offsets[13], object.syncStatus.index);
  writer.writeDouble(offsets[14], object.totalHours);
  writer.writeDouble(offsets[15], object.totalOvertimeHours);
  writer.writeDateTime(offsets[16], object.updatedAt);
}

PayrollRecordEntity _payrollRecordEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PayrollRecordEntity();
  object.baseSalary = reader.readDouble(offsets[0]);
  object.bonuses = reader.readDouble(offsets[1]);
  object.deductions = reader.readDouble(offsets[2]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.employeeId = reader.readString(offsets[4]);
  object.generatedAt = reader.readDateTime(offsets[5]);
  object.id = reader.readString(offsets[6]);
  object.isDeleted = reader.readBool(offsets[7]);
  object.month = reader.readString(offsets[8]);
  object.netSalary = reader.readDouble(offsets[9]);
  object.paidAt = reader.readDateTimeOrNull(offsets[10]);
  object.paymentReference = reader.readStringOrNull(offsets[11]);
  object.status = reader.readString(offsets[12]);
  object.syncStatus = _PayrollRecordEntitysyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[13])] ??
      SyncStatus.pending;
  object.totalHours = reader.readDouble(offsets[14]);
  object.totalOvertimeHours = reader.readDouble(offsets[15]);
  object.updatedAt = reader.readDateTime(offsets[16]);
  return object;
}

P _payrollRecordEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (_PayrollRecordEntitysyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PayrollRecordEntitysyncStatusEnumValueMap = {
  'pending': 0,
  'synced': 1,
  'conflict': 2,
};
const _PayrollRecordEntitysyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.synced,
  2: SyncStatus.conflict,
};

Id _payrollRecordEntityGetId(PayrollRecordEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _payrollRecordEntityGetLinks(
    PayrollRecordEntity object) {
  return [];
}

void _payrollRecordEntityAttach(
    IsarCollection<dynamic> col, Id id, PayrollRecordEntity object) {}

extension PayrollRecordEntityByIndex on IsarCollection<PayrollRecordEntity> {
  Future<PayrollRecordEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  PayrollRecordEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<PayrollRecordEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<PayrollRecordEntity?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(PayrollRecordEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(PayrollRecordEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<PayrollRecordEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<PayrollRecordEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension PayrollRecordEntityQueryWhereSort
    on QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QWhere> {
  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PayrollRecordEntityQueryWhere
    on QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QWhereClause> {
  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      employeeIdEqualTo(String employeeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'employeeId',
        value: [employeeId],
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      employeeIdNotEqualTo(String employeeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [],
              upper: [employeeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [employeeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [employeeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'employeeId',
              lower: [],
              upper: [employeeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      monthEqualTo(String month) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'month',
        value: [month],
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      monthNotEqualTo(String month) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [],
              upper: [month],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [month],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [month],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month',
              lower: [],
              upper: [month],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterWhereClause>
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

extension PayrollRecordEntityQueryFilter on QueryBuilder<PayrollRecordEntity,
    PayrollRecordEntity, QFilterCondition> {
  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      baseSalaryEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseSalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      baseSalaryGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseSalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      baseSalaryLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseSalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      baseSalaryBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseSalary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      bonusesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bonuses',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      bonusesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bonuses',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      bonusesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bonuses',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      bonusesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bonuses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      deductionsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deductions',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      deductionsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deductions',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      deductionsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deductions',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      deductionsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deductions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'employeeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'employeeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'employeeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      employeeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'employeeId',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      generatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      generatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      generatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'month',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'month',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'month',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'month',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'month',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'month',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'month',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      monthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'month',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      netSalaryEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netSalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      netSalaryGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'netSalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      netSalaryLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'netSalary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      netSalaryBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'netSalary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paidAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paidAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paidAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paidAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paidAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paidAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentReference',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentReference',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentReference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentReference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentReference',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      paymentReferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentReference',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalOvertimeHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalOvertimeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalOvertimeHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalOvertimeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalOvertimeHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalOvertimeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      totalOvertimeHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalOvertimeHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterFilterCondition>
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

extension PayrollRecordEntityQueryObject on QueryBuilder<PayrollRecordEntity,
    PayrollRecordEntity, QFilterCondition> {}

extension PayrollRecordEntityQueryLinks on QueryBuilder<PayrollRecordEntity,
    PayrollRecordEntity, QFilterCondition> {}

extension PayrollRecordEntityQuerySortBy
    on QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QSortBy> {
  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByBaseSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseSalary', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByBaseSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseSalary', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByBonuses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonuses', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByBonusesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonuses', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByDeductions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductions', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByDeductionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductions', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByNetSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalary', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByNetSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalary', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByPaymentReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByPaymentReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByTotalOvertimeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOvertimeHours', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByTotalOvertimeHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOvertimeHours', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PayrollRecordEntityQuerySortThenBy
    on QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QSortThenBy> {
  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByBaseSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseSalary', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByBaseSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseSalary', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByBonuses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonuses', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByBonusesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bonuses', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByDeductions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductions', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByDeductionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deductions', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByEmployeeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByEmployeeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'employeeId', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByNetSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalary', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByNetSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalary', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByPaymentReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByPaymentReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentReference', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByTotalOvertimeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOvertimeHours', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByTotalOvertimeHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOvertimeHours', Sort.desc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PayrollRecordEntityQueryWhereDistinct
    on QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct> {
  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByBaseSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseSalary');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByBonuses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bonuses');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByDeductions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deductions');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByEmployeeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'employeeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByNetSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'netSalary');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAt');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByPaymentReference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentReference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalHours');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByTotalOvertimeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalOvertimeHours');
    });
  }

  QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PayrollRecordEntityQueryProperty
    on QueryBuilder<PayrollRecordEntity, PayrollRecordEntity, QQueryProperty> {
  QueryBuilder<PayrollRecordEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<PayrollRecordEntity, double, QQueryOperations>
      baseSalaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseSalary');
    });
  }

  QueryBuilder<PayrollRecordEntity, double, QQueryOperations>
      bonusesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bonuses');
    });
  }

  QueryBuilder<PayrollRecordEntity, double, QQueryOperations>
      deductionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deductions');
    });
  }

  QueryBuilder<PayrollRecordEntity, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<PayrollRecordEntity, String, QQueryOperations>
      employeeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employeeId');
    });
  }

  QueryBuilder<PayrollRecordEntity, DateTime, QQueryOperations>
      generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<PayrollRecordEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PayrollRecordEntity, bool, QQueryOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<PayrollRecordEntity, String, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<PayrollRecordEntity, double, QQueryOperations>
      netSalaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'netSalary');
    });
  }

  QueryBuilder<PayrollRecordEntity, DateTime?, QQueryOperations>
      paidAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAt');
    });
  }

  QueryBuilder<PayrollRecordEntity, String?, QQueryOperations>
      paymentReferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentReference');
    });
  }

  QueryBuilder<PayrollRecordEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PayrollRecordEntity, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<PayrollRecordEntity, double, QQueryOperations>
      totalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalHours');
    });
  }

  QueryBuilder<PayrollRecordEntity, double, QQueryOperations>
      totalOvertimeHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalOvertimeHours');
    });
  }

  QueryBuilder<PayrollRecordEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
