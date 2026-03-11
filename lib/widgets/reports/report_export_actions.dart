import 'package:flutter/material.dart';

enum _ReportActionMenuItem { refresh, exportPdf, print }

class ReportExportActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onExport;
  final VoidCallback onPrint;
  final VoidCallback? onRefresh;

  const ReportExportActions({
    super.key,
    required this.isLoading,
    required this.onExport,
    required this.onPrint,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (isMobile) {
      return PopupMenuButton<_ReportActionMenuItem>(
        tooltip: 'More actions',
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case _ReportActionMenuItem.refresh:
              onRefresh?.call();
              break;
            case _ReportActionMenuItem.exportPdf:
              onExport();
              break;
            case _ReportActionMenuItem.print:
              onPrint();
              break;
          }
        },
        itemBuilder: (context) => [
          if (onRefresh != null)
            const PopupMenuItem<_ReportActionMenuItem>(
              value: _ReportActionMenuItem.refresh,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.refresh_rounded),
                title: Text('Refresh'),
              ),
            ),
          const PopupMenuItem<_ReportActionMenuItem>(
            value: _ReportActionMenuItem.exportPdf,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.picture_as_pdf_outlined),
              title: Text('Export PDF'),
            ),
          ),
          const PopupMenuItem<_ReportActionMenuItem>(
            value: _ReportActionMenuItem.print,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.print_outlined),
              title: Text('Print'),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: onRefresh,
            tooltip: 'Refresh',
          ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: onExport,
                tooltip: 'Export PDF',
              ),
              Container(
                width: 1,
                height: 22,
                color: colorScheme.outlineVariant,
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined),
                onPressed: onPrint,
                tooltip: 'Print',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
