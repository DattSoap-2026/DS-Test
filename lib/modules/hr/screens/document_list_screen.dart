import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import '../services/document_service.dart';
import '../models/employee_document_model.dart';
import '../../../providers/auth/auth_provider.dart';
import 'document_upload_screen.dart';
import '../../../utils/app_toast.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class DocumentListScreen extends StatefulWidget {
  final String? employeeId;

  const DocumentListScreen({super.key, this.employeeId});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  List<EmployeeDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final service = context.read<DocumentService>();
    final empId = widget.employeeId ?? auth.currentUser?.id;

    if (empId != null) {
      final docs = await service.getEmployeeDocuments(empId);
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
          ? const Center(child: Text('No documents uploaded'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _documents.length,
              itemBuilder: (ctx, i) => _buildDocCard(_documents[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DocumentUploadScreen(employeeId: widget.employeeId),
            ),
          );
          _loadDocuments();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDocCard(EmployeeDocument doc) {
    final statusColor = doc.isExpired
        ? Colors.red
        : doc.isExpiringSoon
        ? Colors.orange
        : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(
            doc.documentType,
          ).withValues(alpha: 0.2),
          child: Icon(
            _getTypeIcon(doc.documentType),
            color: _getTypeColor(doc.documentType),
          ),
        ),
        title: Text(doc.documentName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc.documentType),
            if (doc.documentNumber != null)
              Text(doc.documentNumber!, style: const TextStyle(fontSize: 11)),
            if (doc.expiryDate != null)
              Text(
                doc.isExpired
                    ? 'Expired!'
                    : doc.isExpiringSoon
                    ? 'Expires in ${doc.daysUntilExpiry} days'
                    : 'Valid until ${doc.expiryDate!.day}/${doc.expiryDate!.month}/${doc.expiryDate!.year}',
                style: TextStyle(color: statusColor, fontSize: 11),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (doc.isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 20),
            PopupMenuButton<String>(
              onSelected: (v) => _handleAction(v, doc),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.contains('Aadhar') || type.contains('PAN')) return Colors.blue;
    if (type.contains('License')) return Colors.purple;
    if (type.contains('Education')) return Colors.green;
    if (type.contains('Bank')) return Colors.orange;
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  IconData _getTypeIcon(String type) {
    if (type.contains('Aadhar') || type.contains('PAN')) return Icons.badge;
    if (type.contains('License')) return Icons.drive_eta;
    if (type.contains('Passport')) return Icons.flight;
    if (type.contains('Education')) return Icons.school;
    if (type.contains('Bank')) return Icons.account_balance;
    return Icons.description;
  }

  Future<void> _handleAction(String action, EmployeeDocument doc) async {
    switch (action) {
      case 'view':
        final file = File(doc.filePath);
        if (await file.exists()) {
          await OpenFile.open(doc.filePath);
        } else {
          if (mounted) {
            AppToast.showError(context, 'File not found');
          }
        }
        break;
      case 'delete':
        final service = context.read<DocumentService>();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => ResponsiveAlertDialog(
            title: const Text('Delete Document?'),
            content: Text('Delete "${doc.documentName}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await service.deleteDocument(doc.id);
          _loadDocuments();
        }
        break;
    }
  }
}

