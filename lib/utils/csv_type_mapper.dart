import '../models/types/product_types.dart';

class CsvTypeMapper {
  static ProductType toItemType(String? value) {
    if (value == null || value.isEmpty) return ProductType.rawMaterial;
    return ProductType.fromString(value);
  }

  static ProductTypeEnum toProductType(String? value) {
    if (value == null || value.isEmpty) return ProductTypeEnum.raw;
    try {
      return ProductTypeEnum.values.firstWhere(
        (e) => e.name.toUpperCase() == value.toUpperCase(),
        orElse: () => ProductTypeEnum.raw,
      );
    } catch (_) {
      // Fallback for human readable strings if they differ from enum names
      final normalized = value.toLowerCase().replaceAll(' ', '');
      if (normalized.contains('finished')) return ProductTypeEnum.finished;
      if (normalized.contains('semi')) return ProductTypeEnum.semi;
      if (normalized.contains('trade')) return ProductTypeEnum.traded;
      if (normalized.contains('pack')) return ProductTypeEnum.packaging;
      return ProductTypeEnum.raw;
    }
  }
}
