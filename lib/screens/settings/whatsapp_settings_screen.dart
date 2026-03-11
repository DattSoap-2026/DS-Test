import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/whatsapp_service.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_card.dart';
import '../../utils/app_toast.dart';

class WhatsAppSettingsScreen extends StatefulWidget {
  const WhatsAppSettingsScreen({super.key});

  @override
  State<WhatsAppSettingsScreen> createState() => _WhatsAppSettingsScreenState();
}

class _WhatsAppSettingsScreenState extends State<WhatsAppSettingsScreen> {
  final _storage = const FlutterSecureStorage();
  final _phoneNumberController = TextEditingController();
  final _accessTokenController = TextEditingController();
  final _testPhoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _isTesting = false;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _accessTokenController.dispose();
    _testPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final phoneNumberId = await _storage.read(key: 'whatsapp_phone_number_id');
      final accessToken = await _storage.read(key: 'whatsapp_access_token');
      final enabled = await _storage.read(key: 'whatsapp_enabled');

      if (mounted) {
        setState(() {
          _phoneNumberController.text = phoneNumberId ?? '';
          _accessTokenController.text = accessToken ?? '';
          _isEnabled = enabled == 'true';
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to load settings: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (_phoneNumberController.text.isEmpty ||
        _accessTokenController.text.isEmpty) {
      AppToast.showError(context, 'Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _storage.write(
        key: 'whatsapp_phone_number_id',
        value: _phoneNumberController.text.trim(),
      );
      await _storage.write(
        key: 'whatsapp_access_token',
        value: _accessTokenController.text.trim(),
      );
      await _storage.write(
        key: 'whatsapp_enabled',
        value: _isEnabled.toString(),
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Settings saved successfully');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to save settings: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    if (_testPhoneController.text.isEmpty) {
      AppToast.showError(context, 'Please enter a test phone number');
      return;
    }

    if (!WhatsAppService.isValidPhoneNumber(_testPhoneController.text)) {
      AppToast.showError(context, 'Invalid phone number format');
      return;
    }

    setState(() => _isTesting = true);
    try {
      final service = WhatsAppService(
        phoneNumberId: _phoneNumberController.text.trim(),
        accessToken: _accessTokenController.text.trim(),
      );

      final success = await service.sendTextMessage(
        to: _testPhoneController.text.trim(),
        message: 'Test message from DattSoap ERP. WhatsApp integration is working! 🎉',
      );

      if (mounted) {
        if (success) {
          AppToast.showSuccess(context, 'Test message sent successfully!');
        } else {
          AppToast.showError(context, 'Failed to send test message');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Test failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _openDocumentation() async {
    const documentationUrl = 'https://developers.facebook.com/docs/whatsapp';
    final uri = Uri.parse(documentationUrl);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        AppToast.showError(context, 'Unable to open documentation link');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to open documentation: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Integration'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildConfigCard(),
                  const SizedBox(height: 16),
                  _buildTestCard(),
                  const SizedBox(height: 16),
                  _buildUseCasesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Setup Instructions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('1. Create a Meta Business Account'),
            const Text('2. Set up WhatsApp Business API'),
            const Text('3. Get Phone Number ID from Meta Dashboard'),
            const Text('4. Generate Access Token'),
            const Text('5. Enter credentials below'),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _openDocumentation,
              icon: const Icon(Icons.open_in_new),
              label: const Text('View Documentation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
              title: const Text('Enable WhatsApp Integration'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number ID *',
                hintText: 'Enter your WhatsApp Phone Number ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              enabled: _isEnabled,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accessTokenController,
              decoration: const InputDecoration(
                labelText: 'Access Token *',
                hintText: 'Enter your WhatsApp Access Token',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
              enabled: _isEnabled,
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Save Settings',
              onPressed: _saveSettings,
              isLoading: _isLoading,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testPhoneController,
              decoration: const InputDecoration(
                labelText: 'Test Phone Number',
                hintText: 'Enter phone number (e.g., 9876543210)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_android),
                helperText: 'Enter 10-digit mobile number',
              ),
              keyboardType: TextInputType.phone,
              enabled: _isEnabled,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Send Test Message',
              onPressed: _testConnection,
              isLoading: _isTesting,
              icon: Icons.send,
              variant: ButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCasesCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use Cases',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildUseCase(
              Icons.receipt_long,
              'Invoice Notifications',
              'Send invoices automatically after sale',
            ),
            _buildUseCase(
              Icons.payment,
              'Payment Reminders',
              'Remind customers about pending payments',
            ),
            _buildUseCase(
              Icons.shopping_cart,
              'Order Confirmations',
              'Confirm orders instantly',
            ),
            _buildUseCase(
              Icons.local_shipping,
              'Delivery Updates',
              'Keep customers informed about delivery status',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCase(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
