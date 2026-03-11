import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/document_service.dart';
import '../models/employee_document_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../utils/app_toast.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String? employeeId;

  const DocumentUploadScreen({super.key, this.employeeId});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedType = 'Aadhar Card';
  DateTime? _expiryDate;
  String? _filePath;
  String? _fileName;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final docType = DocumentType.commonTypes.firstWhere(
      (t) => t.name == _selectedType,
      orElse: () => DocumentType.commonTypes.last,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: OutlineInputBorder(),
                ),
                items: DocumentType.commonTypes
                    .map(
                      (t) =>
                          DropdownMenuItem(value: t.name, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Document Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (docType.requiresNumber) ...[
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: '$_selectedType Number',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (docType.requiresExpiry) ...[
                InkWell(
                  onTap: _pickExpiryDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _expiryDate != null
                              ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                              : 'Select date',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _filePath != null
                            ? Icons.check_circle
                            : Icons.cloud_upload,
                        size: 48,
                        color: _filePath != null
                            ? Colors.green
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(_fileName ?? 'Tap to select file'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading || _filePath == null ? null : _upload,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Upload Document'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _filePath == null) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final service = context.read<DocumentService>();
      final empId = widget.employeeId ?? auth.currentUser?.id;

      await service.addDocument(
        employeeId: empId!,
        documentType: _selectedType,
        documentName: _nameController.text,
        sourceFilePath: _filePath!,
        documentNumber: _numberController.text.isNotEmpty
            ? _numberController.text
            : null,
        expiryDate: _expiryDate,
        remarks: _remarksController.text.isNotEmpty
            ? _remarksController.text
            : null,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Document uploaded');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
