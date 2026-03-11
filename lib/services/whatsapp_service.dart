import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

class WhatsAppTransportResult<T> {
  final bool success;
  final bool transientFailure;
  final T? data;
  final int? statusCode;
  final String reason;
  final String? responseBody;

  const WhatsAppTransportResult({
    required this.success,
    required this.transientFailure,
    this.data,
    this.statusCode,
    required this.reason,
    this.responseBody,
  });
}

/// WhatsApp Business API Integration Service
/// Supports sending messages, invoices, and notifications via WhatsApp
class WhatsAppService {
  static const String _baseUrl = 'https://graph.facebook.com/v18.0';
  static const Duration _requestTimeout = Duration(seconds: 25);

  final String _phoneNumberId;
  final String _accessToken;

  WhatsAppService({required String phoneNumberId, required String accessToken})
    : _phoneNumberId = phoneNumberId,
      _accessToken = accessToken;

  Future<WhatsAppTransportResult<String>> uploadDocumentBytes({
    required Uint8List bytes,
    required String filename,
    String mimeType = 'application/pdf',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/$_phoneNumberId/media'),
      );
      request.headers['Authorization'] = 'Bearer $_accessToken';
      request.fields['messaging_product'] = 'whatsapp';
      request.fields['type'] = mimeType;
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

      final streamed = await request.send().timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamed);
      final statusCode = response.statusCode;
      final transientStatus = _isTransientStatus(statusCode);

      if (statusCode >= 200 && statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final mediaId = decoded['id']?.toString().trim();
          if (mediaId != null && mediaId.isNotEmpty) {
            return WhatsAppTransportResult<String>(
              success: true,
              transientFailure: false,
              data: mediaId,
              statusCode: statusCode,
              reason: 'ok',
              responseBody: response.body,
            );
          }
        }

        return WhatsAppTransportResult<String>(
          success: false,
          transientFailure: false,
          statusCode: statusCode,
          reason: 'invalid_upload_response',
          responseBody: response.body,
        );
      }

      return WhatsAppTransportResult<String>(
        success: false,
        transientFailure: transientStatus,
        statusCode: statusCode,
        reason: 'upload_http_error',
        responseBody: response.body,
      );
    } on TimeoutException catch (e) {
      return WhatsAppTransportResult<String>(
        success: false,
        transientFailure: true,
        reason: 'timeout',
        responseBody: e.toString(),
      );
    } on SocketException catch (e) {
      return WhatsAppTransportResult<String>(
        success: false,
        transientFailure: true,
        reason: 'socket_error',
        responseBody: e.toString(),
      );
    } on http.ClientException catch (e) {
      return WhatsAppTransportResult<String>(
        success: false,
        transientFailure: true,
        reason: 'client_exception',
        responseBody: e.toString(),
      );
    } on HttpException catch (e) {
      return WhatsAppTransportResult<String>(
        success: false,
        transientFailure: true,
        reason: 'http_exception',
        responseBody: e.toString(),
      );
    } catch (e, stack) {
      AppLogger.error(
        'WhatsApp media upload error',
        error: e,
        stackTrace: stack,
        tag: 'WhatsApp',
      );
      return WhatsAppTransportResult<String>(
        success: false,
        transientFailure: false,
        reason: 'upload_exception',
        responseBody: e.toString(),
      );
    }
  }

  Future<WhatsAppTransportResult<void>> sendDocumentByMediaId({
    required String to,
    required String mediaId,
    required String filename,
    String? caption,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$_phoneNumberId/messages'),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'messaging_product': 'whatsapp',
              'to': _formatPhoneNumber(to),
              'type': 'document',
              'document': {
                'id': mediaId,
                'filename': filename,
                if (caption != null) 'caption': caption,
              },
            }),
          )
          .timeout(_requestTimeout);

      final statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode < 300) {
        return WhatsAppTransportResult<void>(
          success: true,
          transientFailure: false,
          statusCode: statusCode,
          reason: 'ok',
          responseBody: response.body,
        );
      }

      return WhatsAppTransportResult<void>(
        success: false,
        transientFailure: _isTransientStatus(statusCode),
        statusCode: statusCode,
        reason: 'send_http_error',
        responseBody: response.body,
      );
    } on TimeoutException catch (e) {
      return WhatsAppTransportResult<void>(
        success: false,
        transientFailure: true,
        reason: 'timeout',
        responseBody: e.toString(),
      );
    } on SocketException catch (e) {
      return WhatsAppTransportResult<void>(
        success: false,
        transientFailure: true,
        reason: 'socket_error',
        responseBody: e.toString(),
      );
    } on http.ClientException catch (e) {
      return WhatsAppTransportResult<void>(
        success: false,
        transientFailure: true,
        reason: 'client_exception',
        responseBody: e.toString(),
      );
    } on HttpException catch (e) {
      return WhatsAppTransportResult<void>(
        success: false,
        transientFailure: true,
        reason: 'http_exception',
        responseBody: e.toString(),
      );
    } catch (e, stack) {
      AppLogger.error(
        'WhatsApp send document by media id error',
        error: e,
        stackTrace: stack,
        tag: 'WhatsApp',
      );
      return WhatsAppTransportResult<void>(
        success: false,
        transientFailure: false,
        reason: 'send_exception',
        responseBody: e.toString(),
      );
    }
  }

  /// Send a text message
  Future<bool> sendTextMessage({
    required String to,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$_phoneNumberId/messages'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messaging_product': 'whatsapp',
          'to': _formatPhoneNumber(to),
          'type': 'text',
          'text': {'body': message},
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.success('WhatsApp message sent to $to', tag: 'WhatsApp');
        return true;
      } else {
        AppLogger.error(
          'WhatsApp send failed: ${response.body}',
          tag: 'WhatsApp',
        );
        return false;
      }
    } catch (e, stack) {
      AppLogger.error('WhatsApp error', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Send invoice/document
  Future<bool> sendDocument({
    required String to,
    required String documentUrl,
    required String filename,
    String? caption,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$_phoneNumberId/messages'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messaging_product': 'whatsapp',
          'to': _formatPhoneNumber(to),
          'type': 'document',
          'document': {
            'link': documentUrl,
            'filename': filename,
            if (caption != null) 'caption': caption,
          },
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.success('WhatsApp document sent to $to', tag: 'WhatsApp');
        return true;
      } else {
        AppLogger.error(
          'WhatsApp document send failed: ${response.body}',
          tag: 'WhatsApp',
        );
        return false;
      }
    } catch (e, stack) {
      AppLogger.error('WhatsApp error', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Send template message (pre-approved templates)
  Future<bool> sendTemplateMessage({
    required String to,
    required String templateName,
    required String languageCode,
    List<String>? parameters,
  }) async {
    try {
      final components = parameters != null && parameters.isNotEmpty
          ? [
              {
                'type': 'body',
                'parameters': parameters
                    .map((p) => {'type': 'text', 'text': p})
                    .toList(),
              },
            ]
          : null;

      final response = await http.post(
        Uri.parse('$_baseUrl/$_phoneNumberId/messages'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messaging_product': 'whatsapp',
          'to': _formatPhoneNumber(to),
          'type': 'template',
          'template': {
            'name': templateName,
            'language': {'code': languageCode},
            if (components != null) 'components': components,
          },
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.success('WhatsApp template sent to $to', tag: 'WhatsApp');
        return true;
      } else {
        AppLogger.error(
          'WhatsApp template send failed: ${response.body}',
          tag: 'WhatsApp',
        );
        return false;
      }
    } catch (e, stack) {
      AppLogger.error('WhatsApp error', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Send invoice notification
  Future<bool> sendInvoiceNotification({
    required String to,
    required String customerName,
    required String invoiceNumber,
    required double amount,
    String? pdfUrl,
  }) async {
    final message =
        '''
Dear $customerName,

Your invoice #$invoiceNumber has been generated.
Amount: ₹${amount.toStringAsFixed(2)}

Thank you for your business!
- DattSoap ERP
''';

    // Send text message
    final textSent = await sendTextMessage(to: to, message: message);

    // If PDF URL provided, send document
    if (textSent && pdfUrl != null) {
      return await sendDocument(
        to: to,
        documentUrl: pdfUrl,
        filename: 'Invoice_$invoiceNumber.pdf',
        caption: 'Invoice #$invoiceNumber',
      );
    }

    return textSent;
  }

  /// Send payment reminder
  Future<bool> sendPaymentReminder({
    required String to,
    required String customerName,
    required double pendingAmount,
  }) async {
    final message =
        '''
Dear $customerName,

This is a friendly reminder about your pending payment.
Amount Due: ₹${pendingAmount.toStringAsFixed(2)}

Please clear the dues at your earliest convenience.

Thank you!
- DattSoap ERP
''';

    return await sendTextMessage(to: to, message: message);
  }

  /// Send order confirmation
  Future<bool> sendOrderConfirmation({
    required String to,
    required String customerName,
    required String orderNumber,
    required double amount,
  }) async {
    final message =
        '''
Dear $customerName,

Your order #$orderNumber has been confirmed!
Amount: ₹${amount.toStringAsFixed(2)}

We'll notify you once it's dispatched.

Thank you!
- DattSoap ERP
''';

    return await sendTextMessage(to: to, message: message);
  }

  /// Send delivery update
  Future<bool> sendDeliveryUpdate({
    required String to,
    required String customerName,
    required String orderNumber,
    required String status,
  }) async {
    final message =
        '''
Dear $customerName,

Order #$orderNumber Update:
Status: $status

Thank you for your patience!
- DattSoap ERP
''';

    return await sendTextMessage(to: to, message: message);
  }

  /// Format phone number to international format
  String _formatPhoneNumber(String phone) {
    return normalizePhoneNumber(phone);
  }

  static String normalizePhoneNumber(String phone) {
    // Remove all non-numeric characters
    var cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 0, remove it (Indian format)
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // If doesn't start with country code, add India code (91)
    if (!cleaned.startsWith('91') && cleaned.length == 10) {
      cleaned = '91$cleaned';
    }

    return cleaned;
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  bool _isTransientStatus(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }

  /// Send notification to multiple recipients (for Admin/Manager routing)
  Future<void> sendToMultipleRecipients({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    for (final phone in phoneNumbers) {
      try {
        await sendTextMessage(to: phone, message: message);
        // Rate limiting: 500ms delay between messages
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        AppLogger.error(
          'Failed to send WhatsApp to $phone',
          tag: 'WhatsApp',
          error: e,
        );
      }
    }
  }
}
