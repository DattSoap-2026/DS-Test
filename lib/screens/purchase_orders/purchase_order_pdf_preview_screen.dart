import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../services/purchase_order_service.dart';
import '../../services/purchase_order_pdf_service.dart';
import '../../models/types/purchase_order_types.dart';

class PurchaseOrderPdfPreviewScreen extends StatefulWidget {
  final String poId;
  const PurchaseOrderPdfPreviewScreen({super.key, required this.poId});

  @override
  State<PurchaseOrderPdfPreviewScreen> createState() =>
      _PurchaseOrderPdfPreviewScreenState();
}

class _PurchaseOrderPdfPreviewScreenState
    extends State<PurchaseOrderPdfPreviewScreen> {
  PurchaseOrder? _order;
  bool _isLoading = true;
  Future<Uint8List>? _pdfFuture; // Added this line

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final service = context.read<PurchaseOrderService>();
      final poMap = await service.findInLocal(widget.poId);
      if (poMap == null) throw Exception('Order not found');
      final order = PurchaseOrder.fromJson(poMap);
      if (mounted) {
        setState(() {
          _order = order;
          _pdfFuture = PurchaseOrderPdfService.generatePdf(
            order,
          ).then((doc) => doc.save()); // Modified this line
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order for preview: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('PO Preview: ${_order!.poNumber}')),
      body:
          _pdfFuture ==
              null // Modified this block
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              build: (format) => _pdfFuture!,
              allowSharing: true,
              allowPrinting: true,
              canChangePageFormat: true,
              canChangeOrientation: true,
              canDebug: false,
              dynamicLayout: true,
              useActions: true,
              initialPageFormat: PdfPageFormat.a4,
              pdfFileName: 'PO_${_order!.poNumber}.pdf',
            ),
    );
  }
}
