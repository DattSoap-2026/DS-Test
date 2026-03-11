import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/types/user_types.dart';
import '../services/whatsapp_service.dart';
import '../utils/app_logger.dart';

/// Helper class to integrate WhatsApp with business flows
class WhatsAppHelper {
  static const _storage = FlutterSecureStorage();

  /// Check if WhatsApp is enabled and configured
  static Future<bool> isEnabled() async {
    try {
      final enabled = await _storage.read(key: 'whatsapp_enabled');
      final phoneNumberId = await _storage.read(key: 'whatsapp_phone_number_id');
      final accessToken = await _storage.read(key: 'whatsapp_access_token');

      return enabled == 'true' &&
          phoneNumberId != null &&
          phoneNumberId.isNotEmpty &&
          accessToken != null &&
          accessToken.isNotEmpty;
    } catch (e) {
      AppLogger.error('WhatsApp enabled check failed', error: e);
      return false;
    }
  }

  /// Get configured WhatsApp service instance
  static Future<WhatsAppService?> getService() async {
    try {
      if (!await isEnabled()) return null;

      final phoneNumberId = await _storage.read(key: 'whatsapp_phone_number_id');
      final accessToken = await _storage.read(key: 'whatsapp_access_token');

      if (phoneNumberId == null || accessToken == null) return null;

      return WhatsAppService(
        phoneNumberId: phoneNumberId,
        accessToken: accessToken,
      );
    } catch (e) {
      AppLogger.error('WhatsApp service creation failed', error: e);
      return null;
    }
  }

  /// Send invoice after sale
  static Future<void> sendInvoiceAfterSale({
    required String customerPhone,
    required String customerName,
    required String invoiceNumber,
    required double amount,
    String? pdfUrl,
  }) async {
    try {
      final service = await getService();
      if (service == null) {
        AppLogger.info('WhatsApp not configured, skipping invoice send');
        return;
      }

      await service.sendInvoiceNotification(
        to: customerPhone,
        customerName: customerName,
        invoiceNumber: invoiceNumber,
        amount: amount,
        pdfUrl: pdfUrl,
      );
    } catch (e) {
      AppLogger.error('Failed to send invoice via WhatsApp', error: e);
    }
  }

  /// Send payment reminder
  static Future<void> sendPaymentReminder({
    required String customerPhone,
    required String customerName,
    required double pendingAmount,
  }) async {
    try {
      final service = await getService();
      if (service == null) return;

      await service.sendPaymentReminder(
        to: customerPhone,
        customerName: customerName,
        pendingAmount: pendingAmount,
      );
    } catch (e) {
      AppLogger.error('Failed to send payment reminder', error: e);
    }
  }

  /// Send order confirmation
  static Future<void> sendOrderConfirmation({
    required String customerPhone,
    required String customerName,
    required String orderNumber,
    required double amount,
  }) async {
    try {
      final service = await getService();
      if (service == null) return;

      await service.sendOrderConfirmation(
        to: customerPhone,
        customerName: customerName,
        orderNumber: orderNumber,
        amount: amount,
      );
    } catch (e) {
      AppLogger.error('Failed to send order confirmation', error: e);
    }
  }

  /// Send delivery update
  static Future<void> sendDeliveryUpdate({
    required String customerPhone,
    required String customerName,
    required String orderNumber,
    required String status,
  }) async {
    try {
      final service = await getService();
      if (service == null) return;

      await service.sendDeliveryUpdate(
        to: customerPhone,
        customerName: customerName,
        orderNumber: orderNumber,
        status: status,
      );
    } catch (e) {
      AppLogger.error('Failed to send delivery update', error: e);
    }
  }

  /// Send notification with role-based routing (to user + all admins/managers)
  static Future<void> sendNotificationWithRouting({
    required String message,
    required String primaryRecipientPhone,
    required AppUser? currentUser,
    required List<AppUser> allUsers,
  }) async {
    try {
      final service = await getService();
      if (service == null) {
        AppLogger.info('WhatsApp not configured, skipping notification');
        return;
      }

      // Collect all recipient phones
      final recipients = <String>{};

      // SECURITY FIX: Validate primary recipient phone
      if (primaryRecipientPhone.isNotEmpty &&
          WhatsAppService.isValidPhoneNumber(primaryRecipientPhone)) {
        recipients.add(primaryRecipientPhone);
      }

      // SECURITY FIX: Validate all Admin and Manager phones
      for (final user in allUsers) {
        if (user.isAdminOrManager &&
            user.phone != null &&
            user.phone!.isNotEmpty &&
            WhatsAppService.isValidPhoneNumber(user.phone!)) {
          recipients.add(user.phone!);
        }
      }

      // Format message with user mention if currentUser exists
      String finalMessage = message;
      if (currentUser != null) {
        finalMessage = '$message\n\n👤 By: ${currentUser.name} (${currentUser.role.value})';
      }

      // Send to all recipients
      await service.sendToMultipleRecipients(
        phoneNumbers: recipients.toList(),
        message: finalMessage,
      );

      AppLogger.success(
        'WhatsApp sent to ${recipients.length} recipients',
        tag: 'WhatsApp',
      );
    } catch (e) {
      AppLogger.error('Failed to send WhatsApp with routing', error: e);
    }
  }
}
