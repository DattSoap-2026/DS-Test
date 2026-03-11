class StockDiscrepancy {
  final String productId;
  final String productName;
  final String productSku;
  final double systemStock;
  final double ledgerStock;
  final double difference;
  final int ledgerEntryCount;

  StockDiscrepancy({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.systemStock,
    required this.ledgerStock,
    required this.difference,
    required this.ledgerEntryCount,
  });

  String get explanation {
    if (difference > 0) {
      return 'Stock is HIGHER than ledger by ${difference.abs().toStringAsFixed(2)}. '
          'Possible: Missing OUT entries or manual stock increase.';
    } else {
      return 'Stock is LOWER than ledger by ${difference.abs().toStringAsFixed(2)}. '
          'Possible: Missing IN entries or data corruption.';
    }
  }
}
