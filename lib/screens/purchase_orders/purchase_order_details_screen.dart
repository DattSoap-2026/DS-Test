import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/purchase_order_service.dart';
import '../../models/types/purchase_order_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/purchase_order_pdf_service.dart';
import '../../services/suppliers_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/app_toast.dart';
import '../../utils/normalized_number_input_formatter.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';
import '../inventory/dialogs/post_grn_distribution_dialog.dart';

class PurchaseOrderDetailsScreen extends StatefulWidget {
  final String poId;
  const PurchaseOrderDetailsScreen({super.key, required this.poId});

  @override
  State<PurchaseOrderDetailsScreen> createState() =>
      _PurchaseOrderDetailsScreenState();
}

class PrintPreviewIntent extends Intent {
  const PrintPreviewIntent();
}

class _PurchaseOrderDetailsScreenState
    extends State<PurchaseOrderDetailsScreen> {
  bool _isLoading = true;
  PurchaseOrder? _order;
  Supplier? _supplier;
  bool _isActionLoading = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<PurchaseOrderService>();
      final poMap = await service.findInLocal(widget.poId);
      if (poMap == null) throw Exception('Order not found');
      final order = PurchaseOrder.fromJson(poMap);

      if (mounted) {
        setState(() {
          _order = order;
        });
        _focusNode.requestFocus();

        // Also load supplier for sharing details
        try {
          final supService = context.read<SuppliersService>();
          final suppliers = await supService.getSuppliers();
          final supplier = suppliers.cast<Supplier?>().firstWhere(
            (s) => s?.id == order.supplierId,
            orElse: () => null,
          );
          setState(() {
            _supplier = supplier;
            _isLoading = false;
          });
        } catch (e) {
          debugPrint('Error loading supplier: $e');
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading order: $e');
      }
    }
  }

  Future<void> _handleStatusChange(PurchaseOrderStatus newStatus) async {
    setState(() => _isActionLoading = true);
    try {
      final service = context.read<PurchaseOrderService>();
      final currentUser = context.read<AuthProvider>().currentUser;
      List<PostGrnDistributionProduct> distributionProducts =
          const <PostGrnDistributionProduct>[];
      String? distributionReferenceId;
      String? distributionReferenceNumber;

      if (newStatus == PurchaseOrderStatus.received) {
        final sourceOrder = _order;
        if (sourceOrder != null) {
          distributionProducts = _buildDistributionProductsFromBaseQty(
            _buildRemainingBaseQtyMap(sourceOrder),
            sourceOrder: sourceOrder,
          );
          distributionReferenceId = sourceOrder.id;
          distributionReferenceNumber = sourceOrder.poNumber;
        }

        // Special handling for receiving stock
        await service.receiveStock(
          poId: _order!.id,
          userId: currentUser?.id ?? 'unknown',
          userName: currentUser?.name ?? 'Unknown',
        );
        if (mounted) {
          if (mounted) {
            AppToast.showSuccess(
              context,
              'Stock received successfully! Inventory updated.',
            );
          }
        }
      } else {
        await service.updateStatus(_order!.id, newStatus);
        if (mounted) {
          if (mounted) {
            AppToast.showSuccess(context, 'Order marked as ${newStatus.value}');
          }
        }
      }

      await _loadOrder(); // Refresh
      if (newStatus == PurchaseOrderStatus.received &&
          distributionProducts.isNotEmpty &&
          distributionReferenceId != null &&
          distributionReferenceNumber != null &&
          mounted) {
        await _offerPostReceiptDistribution(
          referenceId: distributionReferenceId,
          referenceNumber: distributionReferenceNumber,
          products: distributionProducts,
        );
      }
      setState(() => _isActionLoading = false);
    } catch (e) {
      setState(() => _isActionLoading = false);
      if (mounted) {
        if (mounted) {
          AppToast.showError(context, 'Error updating status: $e');
        }
      }
    }
  }

  Future<void> _showReceiveDialog() async {
    // Map to track quantities being received NOW
    // Initialize with 0 or remaining? Better to initialize with remaining for convenience
    // but allow editing.
    final Map<String, TextEditingController> qtyControllers = {};

    // Prepare controllers
    for (final item in _order!.items) {
      const initialVal = 0.0;
      qtyControllers[item.productId] = TextEditingController(
        text: initialVal.toInt().toString(),
      );
    }

    await showDialog(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Receive Stock'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter quantities being received now.\nLeave as 0 to skip item.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._order!.items.map((item) {
                    final received = item.receivedQuantity ?? 0;
                    final remaining = item.quantity - received;

                    if (remaining <= 0 && received >= item.quantity) {
                      // Fully received item, maybe hide or show disabled?
                      // Let's hide to reduce clutter unless desired.
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Ordered: ${item.quantity}, Rec: $received',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: qtyControllers[item.productId],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                NormalizedNumberInputFormatter.decimal(
                                  keepZeroWhenEmpty: true,
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Receive',
                                isDense: true,
                                border: const OutlineInputBorder(),
                                suffixText: item.unit,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Collect Data
                final List<Map<String, double>> receivedQtys = [];
                qtyControllers.forEach((pid, controller) {
                  final val = double.tryParse(controller.text) ?? 0.0;
                  if (val > 0) {
                    receivedQtys.add({pid: val});
                  }
                });

                Navigator.pop(context);
                if (receivedQtys.isNotEmpty) {
                  _processStockReceipt(receivedQtys);
                } else {
                  // Nothing to receive
                  AppToast.showWarning(
                    context,
                    'No quantities entered to receive.',
                  );
                }
              },
              child: const Text('Confirm Receipt'),
            ),
          ],
        );
      },
    );

    // Cleanup controllers
    for (final c in qtyControllers.values) {
      c.dispose();
    }
  }

  Future<void> _processStockReceipt(
    List<Map<String, double>> receivedQtys,
  ) async {
    setState(() => _isActionLoading = true);
    try {
      final service = context.read<PurchaseOrderService>();
      final currentUser = context.read<AuthProvider>().currentUser;
      final sourceOrder = _order;
      if (sourceOrder == null) {
        throw Exception('Purchase order not loaded');
      }
      final distributionProducts = _buildDistributionProductsFromBaseQty(
        _buildIncomingBaseQtyMap(sourceOrder, receivedQtys),
        sourceOrder: sourceOrder,
      );

      await service.receiveStock(
        poId: sourceOrder.id,
        userId: currentUser?.id ?? 'unknown',
        userName: currentUser?.name ?? 'Unknown',
        receivedQtys: receivedQtys,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Stock received successfully!');
      }
      await _loadOrder();
      if (distributionProducts.isNotEmpty && mounted) {
        await _offerPostReceiptDistribution(
          referenceId: sourceOrder.id,
          referenceNumber: sourceOrder.poNumber,
          products: distributionProducts,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error receiving stock: $e');
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  double _toBaseQty(PurchaseOrderItem item, double quantity) {
    if (item.baseUnit == null || item.conversionFactor == null) {
      return quantity;
    }
    if (item.unit == item.baseUnit) {
      return quantity;
    }
    return quantity * item.conversionFactor!;
  }

  Map<String, double> _buildRemainingBaseQtyMap(PurchaseOrder order) {
    final result = <String, double>{};
    for (final item in order.items) {
      final alreadyReceived = item.receivedQuantity ?? 0.0;
      final remaining = (item.quantity - alreadyReceived)
          .clamp(0.0, double.infinity)
          .toDouble();
      if (remaining <= 0) continue;
      final baseQty = _toBaseQty(item, remaining);
      if (baseQty <= 0) continue;
      result[item.productId] = (result[item.productId] ?? 0) + baseQty;
    }
    return result;
  }

  Map<String, double> _buildIncomingBaseQtyMap(
    PurchaseOrder order,
    List<Map<String, double>> receivedQtys,
  ) {
    final result = <String, double>{};
    final orderItemsById = <String, PurchaseOrderItem>{
      for (final item in order.items) item.productId: item,
    };
    for (final row in receivedQtys) {
      if (row.length != 1) continue;
      final productId = row.keys.first;
      final incomingQty = row.values.first;
      final item = orderItemsById[productId];
      if (item == null || incomingQty <= 0) continue;
      final baseQty = _toBaseQty(item, incomingQty);
      if (baseQty <= 0) continue;
      result[productId] = (result[productId] ?? 0) + baseQty;
    }
    return result;
  }

  List<PostGrnDistributionProduct> _buildDistributionProductsFromBaseQty(
    Map<String, double> baseQtyByProduct, {
    required PurchaseOrder sourceOrder,
  }) {
    if (baseQtyByProduct.isEmpty) return const <PostGrnDistributionProduct>[];
    final orderItemsById = <String, PurchaseOrderItem>{
      for (final item in sourceOrder.items) item.productId: item,
    };
    final output = <PostGrnDistributionProduct>[];
    for (final entry in baseQtyByProduct.entries) {
      final qty = entry.value;
      if (qty <= 0) continue;
      final item = orderItemsById[entry.key];
      output.add(
        PostGrnDistributionProduct(
          productId: entry.key,
          productName: item?.name ?? entry.key,
          availableQty: qty,
          unit: item?.baseUnit ?? item?.unit ?? 'Unit',
        ),
      );
    }
    return output;
  }

  Future<void> _offerPostReceiptDistribution({
    required String referenceId,
    required String referenceNumber,
    required List<PostGrnDistributionProduct> products,
  }) async {
    if (products.isEmpty || !mounted) return;

    final shouldDistribute = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Distribute Received Stock'),
        content: const Text(
          'Stock received successfully.\n\nDo you want to distribute it now to Tanks/Godowns and Departments?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Distribute Now'),
          ),
        ],
      ),
    );

    if (shouldDistribute != true || !mounted) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      AppToast.showError(context, 'User session not found');
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: !_isActionLoading,
      builder: (dialogContext) => PostGrnDistributionDialog(
        referenceId: referenceId,
        referenceNumber: referenceNumber,
        operatorId: currentUser.id,
        operatorName: currentUser.name,
        products: products,
      ),
    );

    if (result == null || !mounted) return;
    final storageCount = (result['storageTransfers'] as num?)?.toInt() ?? 0;
    final departmentCount =
        (result['departmentTransfers'] as num?)?.toInt() ?? 0;
    AppToast.showSuccess(
      context,
      'Distribution completed: $storageCount storage transfer(s), $departmentCount department transfer(s).',
    );
  }

  Future<void> _handleShare({bool isWhatsApp = false}) async {
    if (_order == null) return;

    // 1. Validation
    if (_supplier == null) {
      AppToast.showWarning(context, 'Supplier details not loaded yet.');
      return;
    }

    if (isWhatsApp && (_supplier!.mobile.isEmpty)) {
      AppToast.showWarning(
        context,
        'Supplier mobile number missing. Please update supplier profile.',
      );
      return;
    }

    if (!isWhatsApp &&
        (_supplier!.email == null || _supplier!.email!.isEmpty)) {
      AppToast.showWarning(
        context,
        'Supplier email missing. Please update supplier profile.',
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      // 2. Generate PDF File
      final file = await PurchaseOrderPdfService.generatePdfFile(_order!);

      // 3. Prepare Message
      final message =
          'Dear ${_supplier!.contactPerson},\n\nPlease find attached Purchase Order ${_order!.poNumber} from DattSoap ERP.\n\nTotal Amount: \u20B9${_order!.totalAmount.toStringAsFixed(2)}\nExpected Delivery: ${_order!.expectedDeliveryDate != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(_order!.expectedDeliveryDate!)) : 'As soon as possible'}';

      // 4. Trigger OS Share Intent
      if (isWhatsApp) {
        // WhatsApp Intent (Best effort for mobile)
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
          subject: 'Purchase Order ${_order!.poNumber}',
        );
      } else {
        // General Share (Email/Other)
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
          subject: 'Purchase Order ${_order!.poNumber}',
        );
      }

      // 5. Cleanup will happen on dispose or manually if needed
      // For now, cleaning up older files on screen entry/exit is safer
      await PurchaseOrderPdfService.cleanup();
    } catch (e) {
      if (mounted) {
        if (mounted) {
          AppToast.showError(context, 'Error sharing PO: $e');
        }
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    PurchaseOrderPdfService.cleanup();
    super.dispose();
  }

  Future<void> _handlePrint() async {
    _navigateToPreview();
  }

  void _navigateToPreview() {
    debugPrint('DEBUG: Navigate to preview triggered via shortcut or button');
    if (_order == null) return;
    context.pushNamed(
      'purchase_order_preview',
      pathParameters: {'poId': _order!.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_order == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
            const PrintPreviewIntent(),
      },
      child: Actions(
        actions: {
          PrintPreviewIntent: CallbackAction<PrintPreviewIntent>(
            onInvoke: (intent) => _navigateToPreview(),
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_order!.poNumber),
                  Text(
                    _order!.status.value.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: _buildActions(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildItemsTable(),
                        const SizedBox(height: 24),
                        if (_order!.notes != null && _order!.notes!.isNotEmpty)
                          _buildNotesCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        icon: const Icon(Icons.print),
        tooltip: 'Print PO',
        onPressed: _handlePrint,
      ),
      IconButton(
        icon: const Icon(Icons.share),
        tooltip: 'Share PO PDF',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('Share via WhatsApp'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleShare(isWhatsApp: true);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Share via Email'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleShare(isWhatsApp: false);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.edit),
        tooltip: 'Edit PO',
        onPressed: () {
          context.pushNamed(
            'purchase_order_edit',
            pathParameters: {'poId': _order!.id},
          );
        },
      ),
      if (_order!.status == PurchaseOrderStatus.draft)
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          tooltip: 'Delete Draft',
          onPressed: _isActionLoading ? null : _showDeleteConfirmation,
        ),
      if (_order!.status == PurchaseOrderStatus.ordered)
        IconButton(
          icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
          tooltip: 'Cancel Order',
          onPressed: _isActionLoading ? null : _showCancelConfirmation,
        ),
    ];
  }

  Widget _buildBottomBar() {
    List<Widget> buttons = [];

    if (_order!.status == PurchaseOrderStatus.draft) {
      buttons.add(
        Expanded(
          child: FilledButton(
            onPressed: _isActionLoading
                ? null
                : () => _handleStatusChange(PurchaseOrderStatus.ordered),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Place Order', style: TextStyle(fontSize: 16)),
          ),
        ),
      );
    } else if (_order!.status == PurchaseOrderStatus.ordered ||
        _order!.status == PurchaseOrderStatus.partiallyReceived) {
      buttons.add(
        Expanded(
          child: FilledButton(
            onPressed: _isActionLoading
                ? null
                : () => _showReceiveDialog(), // Changed to dialog
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Receive Stock', style: TextStyle(fontSize: 16)),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Theme.of(context).colorScheme.shadow.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.4
                  : 0.1,
            ),
          ),
        ],
      ),
      child: SafeArea(child: Row(children: buttons)),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Supplier', _order!.supplierName),
            const Divider(),
            _buildInfoRow(
              'Invoice Number',
              (_order!.supplierInvoiceNumber == null ||
                      _order!.supplierInvoiceNumber!.trim().isEmpty)
                  ? '-'
                  : _order!.supplierInvoiceNumber!.trim(),
            ),
            const Divider(),
            _buildInfoRow(
              'Invoice Date',
              _formatOptionalDate(_order!.invoiceDate) ?? '-',
            ),
            const Divider(),
            _buildInfoRow(
              'Date Created',
              DateFormat(
                'MMM d, yyyy h:mm a',
              ).format(DateTime.parse(_order!.createdAt)),
            ),
            const Divider(),
            _buildInfoRow('Created By', _order!.createdByName),
            if (_order!.expectedDeliveryDate != null) ...[
              const Divider(),
              _buildInfoRow(
                'Expected Delivery',
                DateFormat(
                  'MMM d, yyyy',
                ).format(DateTime.parse(_order!.expectedDeliveryDate!)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_order!.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String? _formatOptionalDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('MMM d, yyyy').format(parsed);
  }

  Widget _buildItemsTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ..._order!.items.map(
            (item) => Column(
              children: [
                ListTile(
                  title: Text(
                    item.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity} ${item.unit} x \u20B9${item.unitPrice} (+${item.gstPercentage}% GST)',
                      ),
                      if ((item.receivedQuantity ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Received: ${item.receivedQuantity} / ${item.quantity} ${item.unit}',
                            style: GoogleFonts.inter(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '\u20B9${item.total.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTotalRow('Subtotal (Taxable)', _order!.subtotal),
                if (_order!.gstType == 'CGST+SGST') ...[
                  _buildTotalRow('CGST', _order!.cgstAmount),
                  _buildTotalRow('SGST', _order!.sgstAmount),
                ] else if (_order!.gstType == 'IGST') ...[
                  _buildTotalRow('IGST', _order!.igstAmount),
                ],
                _buildTotalRow('Round Off', _order!.roundOff),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\u20B9${_order!.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value) {
    if (value == 0 && label != 'Round Off') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
          Text(
            '\u20B9${value.toStringAsFixed(2)}',
            style: GoogleFonts.inter(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    if (_order == null) return;
    setState(() => _isActionLoading = true);
    try {
      final service = context.read<PurchaseOrderService>();
      await service.deletePurchaseOrder(_order!.id);
      if (mounted) {
        context.pop(); // Go back to list
        AppToast.showSuccess(context, 'Purchase Order deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActionLoading = false);
        AppToast.showError(context, 'Error deleting order: $e');
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Delete Purchase Order'),
        content: const Text(
          'Are you sure you want to delete this draft? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleDelete();
    }
  }

  Future<void> _showCancelConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Cancel Purchase Order'),
        content: const Text(
          'Are you sure you want to cancel this order? It will be marked as cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleStatusChange(PurchaseOrderStatus.cancelled);
    }
  }
}
