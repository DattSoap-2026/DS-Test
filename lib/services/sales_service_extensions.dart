import 'offline_first_service.dart';
import '../models/types/sales_types.dart';

const salesCollection = 'sales';

class SalesService extends OfflineFirstService {
  SalesService(super.firebase);

  @override
  String get localStorageKey => 'local_sales';

  // ... (keep all existing code)

  /// Update sale status with state machine validation
  Future<void> updateSaleStatus({
    required String saleId,
    required SaleStatus newStatus,
    required String updatedBy,
    required String updatedByName,
    String? notes,
  }) async {
    // Get current sale
    final sale = await findInLocal(saleId);
    if (sale == null) {
      throw Exception('Sale not found: $saleId');
    }

    // Validate state transition
    final currentStatus = SaleStatus.fromString(sale['status'] ?? 'created');
    SaleStateMachine.validateTransition(currentStatus, newStatus);

    // Prepare updates
    final updates = {
      'id': saleId,
      'status': newStatus.value,
      'statusUpdatedBy': updatedBy,
      'statusUpdatedByName': updatedByName,
      'statusUpdatedAt': getCurrentTimestamp(),
    };

    if (notes != null) {
      updates['statusNotes'] = notes;
    }

    // Update locally
    await updateInLocal(saleId, addTimestamps(updates, isNew: false));

    // Sync to Firebase
    await syncToFirebase('update', updates, collectionName: salesCollection);
  }

  /// Mark sale as delivered (stock given to customer)
  Future<void> markAsDelivered({
    required String saleId,
    required String deliveredBy,
    required String deliveredByName,
  }) async {
    await updateSaleStatus(
      saleId: saleId,
      newStatus: SaleStatus.delivered,
      updatedBy: deliveredBy,
      updatedByName: deliveredByName,
      notes: 'Stock delivered on ${DateTime.now().toIso8601String()}',
    );
  }

  /// Mark sale as completed (payment received)
  Future<void> markAsCompleted({
    required String saleId,
    required String completedBy,
    required String completedByName,
    double? paymentAmount,
  }) async {
    await updateSaleStatus(
      saleId: saleId,
      newStatus: SaleStatus.completed,
      updatedBy: completedBy,
      updatedByName: completedByName,
      notes: paymentAmount != null
          ? 'Cash payment ₹$paymentAmount received'
          : 'Payment completed',
    );
  }

  /// Cancel a sale (before delivery)
  Future<void> cancelSale({
    required String saleId,
    required String cancelledBy,
    required String cancelledByName,
    required String reason,
  }) async {
    await updateSaleStatus(
      saleId: saleId,
      newStatus: SaleStatus.cancelled,
      updatedBy: cancelledBy,
      updatedByName: cancelledByName,
      notes: 'Cancelled: $reason',
    );
  }
}
