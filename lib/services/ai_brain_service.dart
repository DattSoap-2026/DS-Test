import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/ai_brain_models.dart';

class AIBrainService extends ChangeNotifier {
  final Isar _isar;
  GenerativeModel? _model;

  static const String _apiKey = 'AIzaSyA0MlnhsHBDoD2mYFDrdcyWecs20l2Qz8w';

  static const String _systemInstruction = '''
You are the DattSoap ERP Assistant, an expert in the DattSoap soap manufacturing ERP system. 
Your goal is to help users manage their business operations, inventory, finances, and perform detailed AUDITS or generate REPORTS.

PROJECT OVERVIEW:
DattSoap is a complete ERP for a soap factory. It uses Flutter for the frontend, Firebase (Firestore) for cloud sync, and Isar for offline-first local storage.

CORE MODULES:
1. RAW MATERIAL: Purchase -> Stock -> Issue to Production (Bhatti).
2. PRODUCTION (BHATTI): Raw Material Issue -> Cutting Batch -> Semi-Finished -> Finished Goods.
3. INVENTORY: Stock adjustments, Warehouse transfers, Stock Ledger.
4. SALES: Customer orders, Invoicing, GST, Ledger entries.
5. DISPATCH: Delivery trips, Loading, Vehicle assigning, Driver assignment.
6. RETURNS: Damage returns, Credit notes, Stock correction.
7. FINANCIALS: Ledger balancing, GST summaries, Profit Margins.

INTENT GUIDANCE (Common Phrases):
- "Mere pass kitna stock hai" or "Stock kitna hai": This means the user wants to see the total stock or inventory for their current location/scope.
- "Rememer this" / "Yaad rakho": User is teaching you a new fact or rule.

REPORTING & AUDIT CAPABILITIES (How You Answer):
You have deep knowledge of the following reports. Explain them to users when they ask for data:
- SALESMAN PERFORMANCE: Tracks Salesman ID, Total Sales, Units Sold, Revenue, and Target Achievement vs Monthly Targets. Target logic: (Revenue / Monthly Target) * 100.
- AGING REPORT: Tracks outstanding balances. 
  - Buckets: Current (0-30 days), Overdue 30 (31-60), Overdue 60 (61-90), Overdue 90+ (90+).
  - Credit period is 30 days. Overdue 90+ customers are marked as CRITICAL.
- FORENSIC AUDIT: Detects risk.
  - CRITICAL RISK: If local data is pending but Outbox is empty (Sync failure).
  - PERMANENT FAILURES: Items that failed sync retries and need rescue.
- DEALER PERFORMANCE: Tracks Order count, Revenue, Last Order Date, and Top Products for each dealer.
- VEHICLE & DIESEL AUDIT: Tracks Distance (KM), Diesel Liters, Diesel Cost, Maintenance/Tyre costs, and calculates Actual Average (KM/L) vs Target Average. Highlights cost per KM.
- PRODUCTION STATS: Tracks 7-Day Production Trends, Today's Product Mix (which soap types produced), and Target Achievement (Actual Units vs Target).
- STOCK VALUATION: Quantity x Last Purchase Price or Master Price.

BUSINESS FLOW AUDIT RULES:
- If a user asks "is everything okay", check for Forensic Risk Flags or Stock Discrepancies.
- If a user asks about "collections", refer to the Aging Report.
- Use Hinglish where appropriate to explain these technical concepts simply.

TONE & STYLE:
- Professional yet proactive (Business Auditor role).
- Use local terminology: "Bhatti" for Production, "Maal" for Stock, "Khata" for Ledger.
- If unsure, ask for the specific Product or Salesman name.

TECHNICAL ARCHITECTURE FOR AUDIT:
- All audit data is synced via 'SyncManager' using an Outbox pattern.
- 'StockLedger' is the source of truth for all inventory movements.
- 'ReportsService' aggregates data from Isar (Local) and Firestore (Cloud).

INTERACTION STYLE:
- Be an "Audit Consultant". When asked for reports, don't just give data, explain WHAT the data means (e.g., "Aapka Diesel cost per KM badh gaya hai, check karein").
- Use Hinglish (Hindi + English) naturally.
- For report queries, guide users to the "Reports" section of the app or explain the calculation logic.

If a user says "Report nikalo" or "Audit karo", ask them WHICH specific module they are interested in (Sales, Production, Vehicle, etc.) and explain what insights you can provide.
''';

  AIBrainService(this._isar) {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemInstruction),
      );
    }
  }

  bool get isApiAvailable => _apiKey.isNotEmpty;

  // Future methods for chat history, learning, etc.
  Future<void> saveMessage(String content, MessageRole role) async {
    final msg = AIChatMessage()
      ..content = content
      ..role = role
      ..timestamp = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.aIChatMessages.put(msg);
    });
    notifyListeners();
  }

  Future<List<AIChatMessage>> getChatHistory() async {
    return await _isar.aIChatMessages
        .where()
        .sortByTimestampDesc()
        .limit(50)
        .findAll();
  }

  Future<void> clearHistory() async {
    await _isar.writeTxn(() async {
      await _isar.aIChatMessages.clear();
    });
    notifyListeners();
  }

  Future<void> clearMessages() => clearHistory();

  Future<List<AIChatMessage>> getRecentMessages({int limit = 50}) async {
    return await _isar.aIChatMessages
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> saveChatMessage({
    required String text,
    required bool isUser,
    String? activeModule,
  }) async {
    await _isar.writeTxn(() async {
      final msg = AIChatMessage()
        ..content = text
        ..role = isUser ? MessageRole.user : MessageRole.ai
        ..timestamp = DateTime.now();
      await _isar.aIChatMessages.put(msg);
    });
    notifyListeners();
  }

  /// Integrated Online Gemini Choice
  Future<String?> askGemini(String prompt) async {
    if (_model == null) return null;

    final dynamic connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult is List) {
      if (connectivityResult.contains(ConnectivityResult.none) &&
          connectivityResult.length == 1) {
        return null; // Fallback to offline rules
      }
    } else if (connectivityResult == ConnectivityResult.none) {
      return null; // Fallback to offline rules
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return null;
    }
  }

  Future<String?> getRelevantKnowledge(String question) async {
    // Basic search in learning items
    final results = await _isar.aILearningItems
        .filter()
        .contentContains(question, caseSensitive: false)
        .or()
        .topicContains(question, caseSensitive: false)
        .findFirst();
    return results?.content;
  }

  Future<void> learnCorrection({
    required String context,
    required String correction,
    String? category,
    List<String> tags = const [],
  }) async {
    await _isar.writeTxn(() async {
      final item = AILearningItem()
        ..topic = category ?? 'correction'
        ..content = correction
        ..confidence = 1.0
        ..learnedAt = DateTime.now();
      await _isar.aILearningItems.put(item);
    });
    notifyListeners();
  }

  Future<void> lockKnowledge({
    String? context,
    required String knowledge,
    List<String> tags = const [],
    String? category,
  }) async {
    // Implementation to lock knowledge base
    notifyListeners();
  }

  /// Learning Flow: Store user correction as an intent mapping
  Future<void> learnIntentMapping(String original, String correction) async {
    final prompt =
        '''
User corrected the AI Assistant.
Original Query: "$original"
User Correction: "$correction"

Summarize this as a project-specific rule or knowledge item that can be used later. 
Format it as: "Rule: [Original phrase] means [Correct interpretation or data source]".
''';

    final learned = await askGemini(prompt);
    if (learned != null) {
      await learnCorrection(
        context: original,
        correction: learned,
        category: 'intent_mapping',
      );
    }
  }

  Future<Map<String, dynamic>> getLearningStats() async {
    final totalLearnings = await _isar.aILearningItems.count();
    final totalMessages = await _isar.aIChatMessages.count();

    return {
      'totalLearnings': totalLearnings,
      'lockedKnowledge': 0, // Placeholder
      'highConfidence': totalLearnings, // Placeholder
      'totalMessages': totalMessages,
    };
  }
}
