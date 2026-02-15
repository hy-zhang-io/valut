// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_mapping.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCategoryMappingCollection on Isar {
  IsarCollection<CategoryMapping> get categoryMappings => this.collection();
}

const CategoryMappingSchema = CollectionSchema(
  name: r'CategoryMapping',
  id: -5001963481450507564,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'externalCategory': PropertySchema(
      id: 1,
      name: r'externalCategory',
      type: IsarType.string,
    ),
    r'internalCategoryId': PropertySchema(
      id: 2,
      name: r'internalCategoryId',
      type: IsarType.long,
    ),
    r'isSystemPreset': PropertySchema(
      id: 3,
      name: r'isSystemPreset',
      type: IsarType.bool,
    ),
    r'sourceType': PropertySchema(
      id: 4,
      name: r'sourceType',
      type: IsarType.string,
    )
  },
  estimateSize: _categoryMappingEstimateSize,
  serialize: _categoryMappingSerialize,
  deserialize: _categoryMappingDeserialize,
  deserializeProp: _categoryMappingDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _categoryMappingGetId,
  getLinks: _categoryMappingGetLinks,
  attach: _categoryMappingAttach,
  version: '3.1.0+1',
);

int _categoryMappingEstimateSize(
  CategoryMapping object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.externalCategory.length * 3;
  bytesCount += 3 + object.sourceType.length * 3;
  return bytesCount;
}

void _categoryMappingSerialize(
  CategoryMapping object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeString(offsets[1], object.externalCategory);
  writer.writeLong(offsets[2], object.internalCategoryId);
  writer.writeBool(offsets[3], object.isSystemPreset);
  writer.writeString(offsets[4], object.sourceType);
}

CategoryMapping _categoryMappingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CategoryMapping(
    description: reader.readStringOrNull(offsets[0]),
    externalCategory: reader.readString(offsets[1]),
    id: id,
    internalCategoryId: reader.readLong(offsets[2]),
    sourceType: reader.readString(offsets[4]),
  );
  return object;
}

P _categoryMappingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _categoryMappingGetId(CategoryMapping object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _categoryMappingGetLinks(CategoryMapping object) {
  return [];
}

void _categoryMappingAttach(
    IsarCollection<dynamic> col, Id id, CategoryMapping object) {}

extension CategoryMappingQueryWhereSort
    on QueryBuilder<CategoryMapping, CategoryMapping, QWhere> {
  QueryBuilder<CategoryMapping, CategoryMapping, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CategoryMappingQueryWhere
    on QueryBuilder<CategoryMapping, CategoryMapping, QWhereClause> {
  QueryBuilder<CategoryMapping, CategoryMapping, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CategoryMappingQueryFilter
    on QueryBuilder<CategoryMapping, CategoryMapping, QFilterCondition> {
  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'externalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'externalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'externalCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'externalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'externalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'externalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'externalCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      externalCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'externalCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      internalCategoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'internalCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      internalCategoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'internalCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      internalCategoryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'internalCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      internalCategoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'internalCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      isSystemPresetEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSystemPreset',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterFilterCondition>
      sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceType',
        value: '',
      ));
    });
  }
}

extension CategoryMappingQueryObject
    on QueryBuilder<CategoryMapping, CategoryMapping, QFilterCondition> {}

extension CategoryMappingQueryLinks
    on QueryBuilder<CategoryMapping, CategoryMapping, QFilterCondition> {}

extension CategoryMappingQuerySortBy
    on QueryBuilder<CategoryMapping, CategoryMapping, QSortBy> {
  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByExternalCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCategory', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByExternalCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCategory', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByInternalCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalCategoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByInternalCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalCategoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByIsSystemPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemPreset', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortByIsSystemPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemPreset', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }
}

extension CategoryMappingQuerySortThenBy
    on QueryBuilder<CategoryMapping, CategoryMapping, QSortThenBy> {
  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByExternalCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCategory', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByExternalCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCategory', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByInternalCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalCategoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByInternalCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'internalCategoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByIsSystemPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemPreset', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenByIsSystemPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemPreset', Sort.desc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QAfterSortBy>
      thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }
}

extension CategoryMappingQueryWhereDistinct
    on QueryBuilder<CategoryMapping, CategoryMapping, QDistinct> {
  QueryBuilder<CategoryMapping, CategoryMapping, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QDistinct>
      distinctByExternalCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalCategory',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QDistinct>
      distinctByInternalCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'internalCategoryId');
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QDistinct>
      distinctByIsSystemPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSystemPreset');
    });
  }

  QueryBuilder<CategoryMapping, CategoryMapping, QDistinct>
      distinctBySourceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }
}

extension CategoryMappingQueryProperty
    on QueryBuilder<CategoryMapping, CategoryMapping, QQueryProperty> {
  QueryBuilder<CategoryMapping, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CategoryMapping, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CategoryMapping, String, QQueryOperations>
      externalCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalCategory');
    });
  }

  QueryBuilder<CategoryMapping, int, QQueryOperations>
      internalCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'internalCategoryId');
    });
  }

  QueryBuilder<CategoryMapping, bool, QQueryOperations>
      isSystemPresetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSystemPreset');
    });
  }

  QueryBuilder<CategoryMapping, String, QQueryOperations> sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }
}
