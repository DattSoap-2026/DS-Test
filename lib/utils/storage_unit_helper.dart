class StorageUnitHelper {
  static const String tonUnit = 'Ton';
  static const String kgUnit = 'Kg';
  static const double _kgPerTon = 1000.0;

  // [LOCKED] Tanks UI always displays inventory in Tons.
  // Legacy records can contain mixed unit labels (Kg/Liters), but tank quantity
  // values are treated as ton-scale values for display consistency.
  static String tankDisplayUnit([String? ignoredUnit]) => tonUnit;

  static double tankDisplayQuantity(double quantity, {String? storageUnit}) {
    // Keep numeric value unchanged for legacy data compatibility.
    return quantity;
  }

  static double tankDisplayQuantityToKg(double quantityInTon) {
    return quantityInTon * _kgPerTon;
  }

  static bool isTonUnit(String? unit) {
    final normalized = (unit ?? '').trim().toLowerCase();
    return normalized == 'ton' || normalized == 'tons' || normalized == 't';
  }

  static String normalizeStorageUnit(String? unit) {
    return isTonUnit(unit)
        ? tonUnit
        : (unit?.trim().isNotEmpty == true ? unit!.trim() : tonUnit);
  }

  static double kgToStorageQuantity(double quantityKg, {String? storageUnit}) {
    return isTonUnit(storageUnit) ? quantityKg / _kgPerTon : quantityKg;
  }

  static double storageQuantityToKg(double quantity, {String? storageUnit}) {
    return isTonUnit(storageUnit) ? quantity * _kgPerTon : quantity;
  }
}
