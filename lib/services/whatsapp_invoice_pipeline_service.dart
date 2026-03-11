import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/types/sales_types.dart';
import '../utils/app_logger.dart';
import '../utils/pdf_generator.dart';
import '../utils/whatsapp_helper.dart';
import 'settings_service.dart';
import 'whatsapp_service.dart';

class WhatsAppInvoicePipelineService {
  WhatsAppInvoicePipelineService._internal();

  static final WhatsAppInvoicePipelineService instance =
      WhatsAppInvoicePipelineService._internal();

  static const String _queuePrefsKey = 'whatsapp_invoice_pdf_jobs_v1';
  static const String _successAckPrefsKey =
      'whatsapp_invoice_pdf_success_ack_v1';
  static const String _terminalSkipPrefsKey =
      'whatsapp_invoice_pdf_terminal_skips_v1';
  static const int _maxAttempts = 4;
  static const int _maxCompletedJobsToKeep = 120;
  static const int _maxTerminalSkipsToKeep = 200;
  static const int _maxSuccessAcksToKeep = 500;

  bool _isProcessing = false;
  Timer? _retryTimer;

  Future<void> enqueueInvoicePdfJob({
    required Sale sale,
    required CompanyProfileData companyProfile,
    required String customerName,
    required String? customerPhone,
    required String source,
  }) async {
    final normalizedPhone = _normalizePhoneForWhatsApp(customerPhone);
    if (normalizedPhone == null) {
      await _recordTerminalSkip(
        saleId: sale.id,
        invoiceNumber: _invoiceNumberForSale(sale),
        reason: 'missing_phone',
        source: source,
      );
      AppLogger.info(
        'WhatsApp invoice terminal_skip reason=missing_phone saleId=${sale.id}',
        tag: 'WhatsAppPipeline',
      );
      return;
    }

    final queue = await _loadQueue();
    final jobId = _buildJobIdForSale(
      sale.id,
      invoiceNumber: _invoiceNumberForSale(sale),
    );
    final successAcks = await _loadSuccessAckMap();
    if (successAcks.containsKey(jobId)) {
      AppLogger.info(
        'WhatsApp invoice already acknowledged as sent for saleId=${sale.id}; enqueue skipped',
        tag: 'WhatsAppPipeline',
      );
      return;
    }
    final existing = _findJobById(queue, jobId);
    if (existing != null) {
      AppLogger.debug(
        'WhatsApp invoice job already exists for saleId=${sale.id} (status=${existing.status})',
        tag: 'WhatsAppPipeline',
      );
      _scheduleNextRetry(queue);
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final normalizedCustomerName = customerName.trim().isEmpty
        ? sale.recipientName
        : customerName.trim();

    queue.add(
      _WhatsAppInvoiceJob(
        jobId: jobId,
        saleId: sale.id.trim(),
        invoiceNumber: _invoiceNumberForSale(sale),
        customerName: normalizedCustomerName,
        customerPhoneNormalized: normalizedPhone,
        salePayload: sale.toJson(),
        companyProfilePayload: _serializeCompanyProfile(companyProfile),
        source: source,
        status: _JobStatus.pending,
        attempt: 0,
        nextRetryAtUtc: nowUtc.toIso8601String(),
        lastError: null,
        createdAtUtc: nowUtc.toIso8601String(),
        updatedAtUtc: nowUtc.toIso8601String(),
        completedAtUtc: null,
      ),
    );

    await _saveQueue(queue);
    AppLogger.info(
      'WhatsApp invoice job queued saleId=${sale.id} invoice=${_invoiceNumberForSale(sale)}',
      tag: 'WhatsAppPipeline',
    );

    _scheduleNextRetry(queue);
    unawaited(processPendingJobs());
  }

  Future<void> processPendingJobs() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      var queue = await _loadQueue();
      if (queue.isEmpty) {
        _retryTimer?.cancel();
        _retryTimer = null;
        return;
      }

      var changed = false;
      final nowUtc = DateTime.now().toUtc();

      for (var i = 0; i < queue.length; i++) {
        final job = queue[i];
        if (!_isJobActive(job.status)) continue;
        if (await _isJobAlreadyAcked(job.jobId)) {
          queue[i] = job.copyWith(
            status: _JobStatus.success,
            updatedAtUtc: nowUtc.toIso8601String(),
            completedAtUtc: nowUtc.toIso8601String(),
            nextRetryAtUtc: null,
          );
          changed = true;
          continue;
        }

        final nextRetryAt = _parseUtc(job.nextRetryAtUtc) ?? nowUtc;
        if (nextRetryAt.isAfter(nowUtc)) continue;

        final updated = await _processSingleJob(job);
        queue[i] = updated;
        changed = true;
      }

      if (changed) {
        queue = _pruneQueue(queue);
        await _saveQueue(queue);
      }

      _scheduleNextRetry(queue);
    } catch (e) {
      AppLogger.warning(
        'WhatsApp pipeline processing failed: $e',
        tag: 'WhatsAppPipeline',
      );
    } finally {
      _isProcessing = false;
    }
  }

  Future<_WhatsAppInvoiceJob> _processSingleJob(_WhatsAppInvoiceJob job) async {
    final nowUtc = DateTime.now().toUtc();
    final nowIso = nowUtc.toIso8601String();
    final attempt = job.attempt + 1;

    final service = await WhatsAppHelper.getService();
    if (service == null) {
      return job.copyWith(
        status: _JobStatus.terminalFailed,
        attempt: attempt,
        lastError: 'whatsapp_not_configured',
        updatedAtUtc: nowIso,
        completedAtUtc: nowIso,
        nextRetryAtUtc: null,
      );
    }

    Sale sale;
    CompanyProfileData companyProfile;
    try {
      sale = Sale.fromJson(job.salePayload);
      companyProfile = CompanyProfileData.fromJson(job.companyProfilePayload);
    } catch (e) {
      return job.copyWith(
        status: _JobStatus.terminalFailed,
        attempt: attempt,
        lastError: 'payload_decode_failed:$e',
        updatedAtUtc: nowIso,
        completedAtUtc: nowIso,
        nextRetryAtUtc: null,
      );
    }

    Uint8List pdfBytes;
    try {
      pdfBytes = await PdfGenerator.generateSaleInvoicePdfBytes(
        sale,
        companyProfile,
      );
    } catch (e) {
      return job.copyWith(
        status: _JobStatus.terminalFailed,
        attempt: attempt,
        lastError: 'pdf_generation_failed:$e',
        updatedAtUtc: nowIso,
        completedAtUtc: nowIso,
        nextRetryAtUtc: null,
      );
    }

    final invoiceNumber = _invoiceNumberForSale(
      sale,
      fallback: job.invoiceNumber,
    );
    final safeInvoiceToken = _sanitizeForFileName(invoiceNumber);
    final filename =
        'Invoice_${safeInvoiceToken.isEmpty ? sale.id : safeInvoiceToken}.pdf';

    final upload = await service.uploadDocumentBytes(
      bytes: pdfBytes,
      filename: filename,
    );
    if (!upload.success) {
      return _handleTransportFailure(
        job: job,
        attempt: attempt,
        stage: 'upload',
        result: upload,
      );
    }

    final mediaId = upload.data?.trim();
    if (mediaId == null || mediaId.isEmpty) {
      return job.copyWith(
        status: _JobStatus.terminalFailed,
        attempt: attempt,
        lastError: 'upload_invalid_media_id',
        updatedAtUtc: nowIso,
        completedAtUtc: nowIso,
        nextRetryAtUtc: null,
      );
    }

    final caption =
        'Invoice #$invoiceNumber\nAmount: ₹${sale.totalAmount.toStringAsFixed(2)}';
    final sendResult = await service.sendDocumentByMediaId(
      to: job.customerPhoneNormalized,
      mediaId: mediaId,
      filename: filename,
      caption: caption,
    );
    if (!sendResult.success) {
      return _handleTransportFailure(
        job: job,
        attempt: attempt,
        stage: 'send_document',
        result: sendResult,
      );
    }

    AppLogger.success(
      'WhatsApp invoice sent saleId=${job.saleId} invoice=$invoiceNumber',
      tag: 'WhatsAppPipeline',
    );
    await _markJobSuccessAcked(job.jobId);
    return job.copyWith(
      status: _JobStatus.success,
      attempt: attempt,
      lastError: null,
      updatedAtUtc: nowIso,
      completedAtUtc: nowIso,
      nextRetryAtUtc: null,
    );
  }

  _WhatsAppInvoiceJob _handleTransportFailure({
    required _WhatsAppInvoiceJob job,
    required int attempt,
    required String stage,
    required WhatsAppTransportResult<dynamic> result,
  }) {
    final nowUtc = DateTime.now().toUtc();
    final nowIso = nowUtc.toIso8601String();
    final statusCode = result.statusCode != null ? ':${result.statusCode}' : '';
    final reason = '$stage:${result.reason}$statusCode';

    if (result.transientFailure && attempt < _maxAttempts) {
      final retryAt = nowUtc.add(_retryDelayForAttempt(attempt));
      AppLogger.warning(
        'WhatsApp invoice transient failure saleId=${job.saleId}, retryAt=${retryAt.toIso8601String()}, reason=$reason',
        tag: 'WhatsAppPipeline',
      );
      return job.copyWith(
        status: _JobStatus.retryScheduled,
        attempt: attempt,
        lastError: reason,
        updatedAtUtc: nowIso,
        completedAtUtc: null,
        nextRetryAtUtc: retryAt.toIso8601String(),
      );
    }

    final terminalReason = result.transientFailure && attempt >= _maxAttempts
        ? '$reason:max_attempts_exhausted'
        : reason;
    AppLogger.warning(
      'WhatsApp invoice terminal failure saleId=${job.saleId}, reason=$terminalReason',
      tag: 'WhatsAppPipeline',
    );
    return job.copyWith(
      status: _JobStatus.terminalFailed,
      attempt: attempt,
      lastError: terminalReason,
      updatedAtUtc: nowIso,
      completedAtUtc: nowIso,
      nextRetryAtUtc: null,
    );
  }

  Duration _retryDelayForAttempt(int attempt) {
    switch (attempt) {
      case 1:
        return const Duration(seconds: 30);
      case 2:
        return const Duration(minutes: 2);
      case 3:
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 15);
    }
  }

  void _scheduleNextRetry(List<_WhatsAppInvoiceJob> queue) {
    _retryTimer?.cancel();
    _retryTimer = null;

    DateTime? nearestDueUtc;
    final nowUtc = DateTime.now().toUtc();

    for (final job in queue) {
      if (!_isJobActive(job.status)) continue;
      final dueAt = _parseUtc(job.nextRetryAtUtc);
      if (dueAt == null) continue;
      if (nearestDueUtc == null || dueAt.isBefore(nearestDueUtc)) {
        nearestDueUtc = dueAt;
      }
    }

    if (nearestDueUtc == null) return;

    final delay = nearestDueUtc.difference(nowUtc);
    _retryTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () => unawaited(processPendingJobs()),
    );
  }

  Future<List<_WhatsAppInvoiceJob>> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queuePrefsKey);
    if (raw == null || raw.isEmpty) return <_WhatsAppInvoiceJob>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <_WhatsAppInvoiceJob>[];
      return decoded
          .map(_WhatsAppInvoiceJob.fromJson)
          .whereType<_WhatsAppInvoiceJob>()
          .toList();
    } catch (e) {
      AppLogger.warning(
        'WhatsApp queue decode failed: $e',
        tag: 'WhatsAppPipeline',
      );
      return <_WhatsAppInvoiceJob>[];
    }
  }

  Future<void> _saveQueue(List<_WhatsAppInvoiceJob> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(queue.map((e) => e.toJson()).toList());
    await prefs.setString(_queuePrefsKey, encoded);
  }

  List<_WhatsAppInvoiceJob> _pruneQueue(List<_WhatsAppInvoiceJob> queue) {
    final active = <_WhatsAppInvoiceJob>[];
    final completed = <_WhatsAppInvoiceJob>[];
    for (final job in queue) {
      if (_isJobActive(job.status)) {
        active.add(job);
      } else {
        completed.add(job);
      }
    }

    completed.sort((a, b) => (b.updatedAtUtc).compareTo(a.updatedAtUtc));
    final cappedCompleted = completed.take(_maxCompletedJobsToKeep).toList();
    return <_WhatsAppInvoiceJob>[...active, ...cappedCompleted];
  }

  _WhatsAppInvoiceJob? _findJobById(
    List<_WhatsAppInvoiceJob> queue,
    String jobId,
  ) {
    for (final job in queue) {
      if (job.jobId == jobId) return job;
    }
    return null;
  }

  bool _isJobActive(String status) {
    return status == _JobStatus.pending || status == _JobStatus.retryScheduled;
  }

  DateTime? _parseUtc(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  String _buildJobIdForSale(String saleId, {String? invoiceNumber}) {
    final normalized = saleId.trim();
    if (normalized.isEmpty) {
      final fallback = _sanitizeForFileName(invoiceNumber ?? 'unknown');
      return fallback.isEmpty ? 'wa_invoice_unknown' : 'wa_invoice_$fallback';
    }
    return 'wa_invoice_$normalized';
  }

  String _invoiceNumberForSale(Sale sale, {String? fallback}) {
    final humanReadable = sale.humanReadableId?.trim();
    if (humanReadable != null && humanReadable.isNotEmpty) return humanReadable;
    final id = sale.id.trim();
    if (id.isNotEmpty) return id;
    return fallback?.trim().isNotEmpty == true ? fallback!.trim() : 'N/A';
  }

  String _sanitizeForFileName(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String? _normalizePhoneForWhatsApp(String? rawPhone) {
    final trimmed = rawPhone?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final normalized = WhatsAppService.normalizePhoneNumber(trimmed);
    if (!WhatsAppService.isValidPhoneNumber(normalized)) return null;
    return normalized;
  }

  Map<String, dynamic> _serializeCompanyProfile(CompanyProfileData profile) {
    return {
      'name': profile.name,
      'tagline': profile.tagline,
      'address': profile.address,
      'phone': profile.phone,
      'email': profile.email,
      'website': profile.website,
      'logoUrl': profile.logoUrl,
      'gstin': profile.gstin,
      'pan': profile.pan,
      if (profile.bankDetails != null)
        'bankDetails': profile.bankDetails!.toJson(),
    };
  }

  Future<void> _recordTerminalSkip({
    required String saleId,
    required String invoiceNumber,
    required String reason,
    required String source,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_terminalSkipPrefsKey);
    final records = <Map<String, dynamic>>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              records.add(Map<String, dynamic>.from(item));
            }
          }
        }
      } catch (_) {
        // Ignore malformed historical data and rewrite clean list.
      }
    }

    records.add({
      'saleId': saleId.trim(),
      'invoiceNumber': invoiceNumber.trim(),
      'reason': reason,
      'source': source,
      'createdAtUtc': DateTime.now().toUtc().toIso8601String(),
      'status': 'terminal_skip',
    });

    if (records.length > _maxTerminalSkipsToKeep) {
      records.removeRange(0, records.length - _maxTerminalSkipsToKeep);
    }

    await prefs.setString(_terminalSkipPrefsKey, jsonEncode(records));
  }

  Future<Map<String, String>> _loadSuccessAckMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_successAckPrefsKey);
    if (raw == null || raw.isEmpty) return <String, String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, String>{};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<void> _saveSuccessAckMap(Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_successAckPrefsKey, jsonEncode(map));
  }

  Future<bool> _isJobAlreadyAcked(String jobId) async {
    final ackMap = await _loadSuccessAckMap();
    return ackMap.containsKey(jobId);
  }

  Future<void> _markJobSuccessAcked(String jobId) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final ackMap = await _loadSuccessAckMap();
    ackMap[jobId] = nowIso;
    if (ackMap.length > _maxSuccessAcksToKeep) {
      final sortedKeys = ackMap.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final removeCount = ackMap.length - _maxSuccessAcksToKeep;
      for (var i = 0; i < removeCount; i++) {
        ackMap.remove(sortedKeys[i].key);
      }
    }
    await _saveSuccessAckMap(ackMap);
  }
}

class _JobStatus {
  static const String pending = 'pending';
  static const String retryScheduled = 'retry_scheduled';
  static const String success = 'success';
  static const String terminalFailed = 'terminal_failed';
}

class _WhatsAppInvoiceJob {
  final String jobId;
  final String saleId;
  final String invoiceNumber;
  final String customerName;
  final String customerPhoneNormalized;
  final Map<String, dynamic> salePayload;
  final Map<String, dynamic> companyProfilePayload;
  final String source;
  final String status;
  final int attempt;
  final String? nextRetryAtUtc;
  final String? lastError;
  final String createdAtUtc;
  final String updatedAtUtc;
  final String? completedAtUtc;

  const _WhatsAppInvoiceJob({
    required this.jobId,
    required this.saleId,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhoneNormalized,
    required this.salePayload,
    required this.companyProfilePayload,
    required this.source,
    required this.status,
    required this.attempt,
    required this.nextRetryAtUtc,
    required this.lastError,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.completedAtUtc,
  });

  _WhatsAppInvoiceJob copyWith({
    String? status,
    int? attempt,
    String? nextRetryAtUtc,
    String? lastError,
    String? updatedAtUtc,
    String? completedAtUtc,
  }) {
    return _WhatsAppInvoiceJob(
      jobId: jobId,
      saleId: saleId,
      invoiceNumber: invoiceNumber,
      customerName: customerName,
      customerPhoneNormalized: customerPhoneNormalized,
      salePayload: salePayload,
      companyProfilePayload: companyProfilePayload,
      source: source,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      nextRetryAtUtc: nextRetryAtUtc,
      lastError: lastError,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      completedAtUtc: completedAtUtc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'saleId': saleId,
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'customerPhoneNormalized': customerPhoneNormalized,
      'salePayload': salePayload,
      'companyProfilePayload': companyProfilePayload,
      'source': source,
      'status': status,
      'attempt': attempt,
      'nextRetryAtUtc': nextRetryAtUtc,
      'lastError': lastError,
      'createdAtUtc': createdAtUtc,
      'updatedAtUtc': updatedAtUtc,
      'completedAtUtc': completedAtUtc,
    };
  }

  static _WhatsAppInvoiceJob? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    try {
      final map = Map<String, dynamic>.from(raw);
      final jobId = (map['jobId'] ?? '').toString().trim();
      final saleId = (map['saleId'] ?? '').toString().trim();
      final customerPhoneNormalized = (map['customerPhoneNormalized'] ?? '')
          .toString()
          .trim();
      final salePayloadRaw = map['salePayload'];
      final companyPayloadRaw = map['companyProfilePayload'];
      if (jobId.isEmpty ||
          saleId.isEmpty ||
          customerPhoneNormalized.isEmpty ||
          salePayloadRaw is! Map ||
          companyPayloadRaw is! Map) {
        return null;
      }

      final status = (map['status'] ?? _JobStatus.pending).toString().trim();
      final normalizedStatus = status.isEmpty ? _JobStatus.pending : status;
      final attempt = (map['attempt'] as num?)?.toInt() ?? 0;
      final createdAtUtc = (map['createdAtUtc'] ?? '').toString().trim();
      final updatedAtUtc = (map['updatedAtUtc'] ?? '').toString().trim();
      if (createdAtUtc.isEmpty || updatedAtUtc.isEmpty) return null;

      return _WhatsAppInvoiceJob(
        jobId: jobId,
        saleId: saleId,
        invoiceNumber: (map['invoiceNumber'] ?? '').toString(),
        customerName: (map['customerName'] ?? '').toString(),
        customerPhoneNormalized: customerPhoneNormalized,
        salePayload: Map<String, dynamic>.from(salePayloadRaw),
        companyProfilePayload: Map<String, dynamic>.from(companyPayloadRaw),
        source: (map['source'] ?? '').toString(),
        status: normalizedStatus,
        attempt: attempt,
        nextRetryAtUtc: map['nextRetryAtUtc']?.toString(),
        lastError: map['lastError']?.toString(),
        createdAtUtc: createdAtUtc,
        updatedAtUtc: updatedAtUtc,
        completedAtUtc: map['completedAtUtc']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }
}
