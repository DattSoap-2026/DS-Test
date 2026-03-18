import '../../features/inventory/models/product.dart';
import '../../features/inventory/models/stock_movement.dart';
import '../utils/sync_logger.dart';

/// Conflict winner metadata.
enum ConflictWinner { local, remote }

/// Result of product conflict resolution.
class ProductConflictResolution {
  /// Creates a resolution result.
  const ProductConflictResolution({
    required this.product,
    required this.winner,
    required this.reason,
  });

  final Product product;
  final ConflictWinner winner;
  final String reason;
}

/// Result of stock movement conflict resolution.
class StockMovementConflictResolution {
  /// Creates a resolution result.
  const StockMovementConflictResolution({
    required this.stockMovement,
    required this.winner,
    required this.reason,
  });

  final StockMovement stockMovement;
  final ConflictWinner winner;
  final String reason;
}

/// Resolves sync conflicts using version check followed by LWW.
class ConflictResolver {
  ConflictResolver._();

  /// Resolves a product conflict and logs the winning side and reason.
  static ProductConflictResolution resolveProduct({
    required Product? local,
    required Product remote,
  }) {
    if (local == null) {
      const reason = 'Remote won because no local record exists.';
      _logDecision(
        collection: 'products',
        documentId: remote.firebaseId,
        winner: ConflictWinner.remote,
        reason: reason,
      );
      return ProductConflictResolution(
        product: remote.copyWith(isSynced: true),
        winner: ConflictWinner.remote,
        reason: reason,
      );
    }

    if (remote.version > local.version) {
      const reason = 'Remote won because it has a higher version.';
      _logDecision(
        collection: 'products',
        documentId: remote.firebaseId,
        winner: ConflictWinner.remote,
        reason: reason,
      );
      return ProductConflictResolution(
        product: remote.copyWith(isSynced: true),
        winner: ConflictWinner.remote,
        reason: reason,
      );
    }

    if (local.version > remote.version) {
      const reason = 'Local won because it has a higher version.';
      _logDecision(
        collection: 'products',
        documentId: local.firebaseId,
        winner: ConflictWinner.local,
        reason: reason,
      );
      return ProductConflictResolution(
        product: local,
        winner: ConflictWinner.local,
        reason: reason,
      );
    }

    if (remote.lastModified.isAfter(local.lastModified)) {
      const reason =
          'Remote won because versions matched and remote lastModified is newer.';
      _logDecision(
        collection: 'products',
        documentId: remote.firebaseId,
        winner: ConflictWinner.remote,
        reason: reason,
      );
      return ProductConflictResolution(
        product: remote.copyWith(isSynced: true),
        winner: ConflictWinner.remote,
        reason: reason,
      );
    }

    const reason =
        'Local won because versions matched and local lastModified is newer or equal.';
    _logDecision(
      collection: 'products',
      documentId: local.firebaseId,
      winner: ConflictWinner.local,
      reason: reason,
    );
    return ProductConflictResolution(
      product: local,
      winner: ConflictWinner.local,
      reason: reason,
    );
  }

  /// Resolves a stock movement conflict and logs the winning side and reason.
  static StockMovementConflictResolution resolveStockMovement({
    required StockMovement? local,
    required StockMovement remote,
  }) {
    if (local == null) {
      const reason = 'Remote won because no local movement exists.';
      _logDecision(
        collection: 'stock_movements',
        documentId: remote.firebaseId,
        winner: ConflictWinner.remote,
        reason: reason,
      );
      return StockMovementConflictResolution(
        stockMovement: remote.copyWith(isSynced: true),
        winner: ConflictWinner.remote,
        reason: reason,
      );
    }

    if (remote.timestamp.isAfter(local.timestamp)) {
      const reason = 'Remote won because its timestamp is newer.';
      _logDecision(
        collection: 'stock_movements',
        documentId: remote.firebaseId,
        winner: ConflictWinner.remote,
        reason: reason,
      );
      return StockMovementConflictResolution(
        stockMovement: remote.copyWith(isSynced: true),
        winner: ConflictWinner.remote,
        reason: reason,
      );
    }

    const reason = 'Local won because its timestamp is newer or equal.';
    _logDecision(
      collection: 'stock_movements',
      documentId: local.firebaseId,
      winner: ConflictWinner.local,
      reason: reason,
    );
    return StockMovementConflictResolution(
      stockMovement: local,
      winner: ConflictWinner.local,
      reason: reason,
    );
  }

  static void _logDecision({
    required String collection,
    required String documentId,
    required ConflictWinner winner,
    required String reason,
  }) {
    SyncLogger.instance.i(
      'Conflict resolved for $collection/$documentId. Winner: ${winner.name}. Reason: $reason',
      time: DateTime.now(),
    );
  }
}
