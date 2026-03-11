import 'package:flutter/material.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class EmailTestScreen extends StatefulWidget {
  const EmailTestScreen({super.key});

  @override
  State<EmailTestScreen> createState() => _EmailTestScreenState();
}

class _EmailTestScreenState extends State<EmailTestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _htmlController = TextEditingController();
  final _textController = TextEditingController();

  final String _sampleTemplate = '''<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; padding: 20px;">
  <div style="max-width: 600px; margin: 0 auto; background: #f9fafb; padding: 30px; border-radius: 12px; border: 1px solid #e5e7eb;">
    <h1 style="color: #4f46e5; margin-bottom: 20px;">Email Service Live!</h1>
    <p style="color: #374151; font-size: 16px; line-height: 1.5;">This is a test email sent from the <strong>DattSoap</strong> admin panel.</p>
    <div style="background: #ffffff; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #4f46e5;">
      Your SMTP configuration is working perfectly.
    </div>
    <p style="color: #6b7280; font-size: 14px;">If you didn't expect this email, please ignore it.</p>
  </div>
</body>
</html>''';

  @override
  void initState() {
    super.initState();
    _subjectController.text = 'DattSoap: Email Configuration Test';
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final functions = FirebaseFunctions.instance;
      // Note: Ensure the function name matches your Firebase setup
      final callable = functions.httpsCallable('sendCustomEmail');

      await callable.call({
        'to': _toController.text.trim(),
        'subject': _subjectController.text.trim(),
        'html': _htmlController.text.trim(),
        'text': _textController.text.trim().isEmpty
            ? null
            : _textController.text.trim(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _htmlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;

    if (user == null || user.role != UserRole.admin) {
      return const Scaffold(
        body: Center(child: Text('Admin access required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Utility'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMainCard(),
              const SizedBox(height: 24),
              _buildSampleCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test SMTP Configuration',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify your email server is correctly sending transactional emails.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email Address *',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Enter recipient email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject Line *',
                prefixIcon: Icon(Icons.subject),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Enter subject' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _htmlController,
              decoration: const InputDecoration(
                labelText: 'HTML Content *',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                hintText: '<h1>Body Content</h1>...',
              ),
              maxLines: 8,
              validator: (v) => v!.isEmpty ? 'Enter HTML content' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Plain Text Snippet (Fallback)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : colorScheme.onInverseSurface;
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HTML Starter Template',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _htmlController.text = _sampleTemplate;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Template applied to HTML field'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.content_paste_go,
                    size: 16,
                    color: AppColors.info,
                  ),
                  label: const Text(
                    'Apply Template',
                    style: TextStyle(color: AppColors.info, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: textColor.withValues(alpha: 0.12)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _sampleTemplate,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSend,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: const Text('Send Test Email Now'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4f46e5),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

