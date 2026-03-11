import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:isar/isar.dart';
import '../../data/local/entities/product_entity.dart';
import '../../services/ai_brain_service.dart';
import '../../services/database_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/responsive.dart';

/// Offline-first AI assistant panel with a single unified chat UI.
class AIAssistantPanel extends StatefulWidget {
  const AIAssistantPanel({super.key});

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  bool _isTyping = false;
  String? _lastUserMessage;
  final TextEditingController _chatController = TextEditingController();

  // Voice input
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _speechInitialized = false;
  String _currentLocale = 'en_IN';

  // Voice output
  late FlutterTts _tts;
  bool _isSpeaking = false;
  bool _ttsEnabled = true;
  bool _ttsInitialized = false;

  // Scanner
  MobileScannerController? _scannerController;
  bool _scannerSheetOpen = false;

  // Learning context
  String? _lastAIResponse;

  bool get _isWindowsDesktop =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static const Map<String, ModuleInfo> _projectKnowledge = {
    'raw_material': ModuleInfo(
      name: 'Raw Material',
      description: 'Manage raw materials like oils, chemicals, and packaging.',
      dataFlow: 'Purchase -> Stock -> Production',
      tables: ['raw_materials', 'material_stocks'],
      relatedModules: ['purchase', 'production', 'inventory'],
    ),
    'production': ModuleInfo(
      name: 'Production (Bhatti)',
      description:
          'Soap manufacturing process: cutting, drying, and packaging.',
      dataFlow: 'Raw Material -> Bhatti -> Semi-Finished -> Finished Goods',
      tables: ['batches', 'production_logs', 'bhatti_records'],
      relatedModules: ['inventory', 'raw_material', 'finished_goods'],
    ),
    'inventory': ModuleInfo(
      name: 'Inventory / Stock',
      description: 'Stock levels, adjustments, transfers, and tracking.',
      dataFlow: 'All modules -> Stock update -> Reports',
      tables: ['stocks', 'stock_movements', 'warehouses'],
      relatedModules: ['sales', 'purchase', 'production', 'dispatch'],
    ),
    'sales': ModuleInfo(
      name: 'Sales',
      description: 'Customer orders, invoicing, and GST calculations.',
      dataFlow: 'Customer -> Order -> Invoice -> Dispatch -> Payment',
      tables: ['sales', 'sale_items', 'customers'],
      relatedModules: ['inventory', 'dispatch', 'returns', 'reports'],
    ),
    'dispatch': ModuleInfo(
      name: 'Dispatch',
      description: 'Delivery trips, vehicle tracking, and route management.',
      dataFlow: 'Sales -> Trip Creation -> Loading -> Delivery -> Completion',
      tables: ['trips', 'trip_items', 'vehicles', 'drivers'],
      relatedModules: ['sales', 'inventory', 'gps'],
    ),
    'purchase': ModuleInfo(
      name: 'Purchase Orders',
      description: 'Supplier orders, GRN, and material receiving.',
      dataFlow: 'PO Creation -> Approval -> Receiving -> Stock Update',
      tables: ['purchase_orders', 'po_items', 'suppliers'],
      relatedModules: ['inventory', 'raw_material', 'accounts'],
    ),
    'returns': ModuleInfo(
      name: 'Returns',
      description: 'Customer returns, damage handling, and credit notes.',
      dataFlow: 'Return Request -> Approval -> Stock Adjustment -> Credit',
      tables: ['returns', 'return_items'],
      relatedModules: ['sales', 'inventory', 'accounts'],
    ),
    'reports': ModuleInfo(
      name: 'Reports & Analytics',
      description: 'Business intelligence, GST reports, and stock summaries.',
      dataFlow: 'All Data -> Aggregation -> Visualization -> Export',
      tables: ['aggregated_views'],
      relatedModules: ['all modules'],
    ),
  };

  static const Map<String, List<String>> _moduleAliases = {
    'raw_material': [
      'raw material',
      'material',
      'chemical',
      'packaging',
      'oil',
    ],
    'production': [
      'production',
      'bhatti',
      'batch',
      'finished goods',
      'manufacturing',
    ],
    'inventory': [
      'inventory',
      'stock',
      'warehouse',
      'godown',
      'reconcile',
      'adjustment',
    ],
    'sales': [
      'sales',
      'sale',
      'order',
      'invoice',
      'billing',
      'customer',
      'gst',
    ],
    'dispatch': ['dispatch', 'trip', 'delivery', 'van loading', 'in_transit'],
    'purchase': ['purchase', 'po', 'supplier', 'grn', 'receiving'],
    'returns': ['return', 'damage', 'credit note'],
    'reports': ['report', 'analytics', 'dashboard', 'summary', 'export'],
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    _messages.add(
      ChatMessage(
        text:
            'Namaste! Main DattSoap Assistant hoon. Aap type ya bol sakte hain.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    try {
      final brainService = context.read<AIBrainService>();
      final recentMessages = await brainService.getRecentMessages(limit: 20);
      if (!mounted) return;
      for (final msg in recentMessages.reversed) {
        _messages.add(
          ChatMessage(
            text: msg.content,
            isUser: msg.isUser,
            timestamp: msg.timestamp,
          ),
        );
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Could not load chat history: $e');
    }
  }

  Future<void> _initSpeech() async {
    if (_isWindowsDesktop) {
      // Speech plugin teardown is unstable on Windows desktop.
      _speechAvailable = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    _speech = stt.SpeechToText();
    _speechInitialized = true;
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() => _isListening = false);
          debugPrint('Speech error: $error');
        },
      );

      if (_speechAvailable) {
        final locales = await _speech.locales();
        if (locales.isNotEmpty) {
          final hindi = locales.where((l) => l.localeId.startsWith('hi'));
          final english = locales.where((l) => l.localeId.startsWith('en'));
          if (hindi.isNotEmpty) {
            _currentLocale = hindi.first.localeId;
          } else if (english.isNotEmpty) {
            _currentLocale = english.first.localeId;
          } else {
            _currentLocale = locales.first.localeId;
          }
        }
      }
    } catch (e) {
      debugPrint('Speech init error: $e');
      _speechAvailable = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    _ttsInitialized = true;
    try {
      await _tts.setLanguage('hi-IN');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setCancelHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    if (_speechInitialized && !_isWindowsDesktop && _isListening) {
      unawaited(_stopSpeechSafely());
    }
    if (_ttsInitialized) {
      unawaited(_stopTtsSafely());
    }
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _stopSpeechSafely() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Speech stop skipped on dispose: $e');
    }
  }

  Future<void> _stopTtsSafely() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS stop skipped on dispose: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable || !_speechInitialized || _isListening) return;

    if (mounted) {
      setState(() => _isListening = true);
    }

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _chatController.text = result.recognizedWords;
        });
      },
      localeId: _currentLocale,
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _stopListening({required bool autoSend}) async {
    if (_speechInitialized) {
      await _speech.stop();
    }
    if (!mounted) return;
    setState(() => _isListening = false);
    if (autoSend && _chatController.text.trim().isNotEmpty) {
      _sendMessage();
    }
  }

  Future<void> _speak(String text) async {
    if (!_ttsEnabled) return;

    final cleanText = text
        .replaceAll(RegExp(r'[*_`#]'), '')
        .replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '')
        .trim();

    if (cleanText.isNotEmpty) {
      await _tts.speak(cleanText);
    }
  }

  Future<void> _openScannerSheet() async {
    if (_scannerSheetOpen) return;
    _scannerSheetOpen = true;
    _scannerController ??= MobileScannerController();

    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        var handled = false;
        return SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.72,
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController!,
                onDetect: (capture) {
                  if (handled) return;
                  if (capture.barcodes.isEmpty) return;
                  final raw = capture.barcodes.first.rawValue;
                  if (raw == null || raw.isEmpty) return;
                  handled = true;
                  Navigator.of(sheetContext).pop(raw);
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );

    _scannerSheetOpen = false;
    await _scannerController?.stop();

    if (!mounted) return;
    if (code != null && code.isNotEmpty) {
      setState(() {
        _chatController.text = 'Barcode: $code';
      });
      _sendMessage();
    }
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _lastUserMessage = text;
    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _chatController.clear();
    _scrollToBottom();
    _saveChatMessage(text, true);
    _respondToMessage(text);
  }

  Future<void> _respondToMessage(String text) async {
    final response = await _processQuestion(text);
    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
      _isTyping = false;
      _lastAIResponse = response;
    });
    _scrollToBottom();
    _saveChatMessage(response, false);
    _speak(response);
  }

  Future<void> _saveChatMessage(String text, bool isUser) async {
    try {
      final brainService = context.read<AIBrainService>();
      await brainService.saveChatMessage(
        text: text,
        isUser: isUser,
        activeModule: null,
      );
    } catch (e) {
      debugPrint('Could not save chat message: $e');
    }
  }

  Future<String> _processQuestion(String question) async {
    final q = _normalizeQuestion(question);

    if (q.contains('remember this') || q.contains('yaad rakho')) {
      return await _handleRememberCommand(question);
    }

    if (q.contains('this is final') || q.contains('ye final hai')) {
      return await _handleLockCommand(question);
    }

    if (_hasAny(q, ['galat hai', 'wrong', 'nahi'])) {
      return _handleCorrectionPrompt();
    }

    // Check if the user is providing a correction after a prompt
    if (_lastUserMessage != null &&
        _hasAny(q, ['iska matlab', 'means', 'is'])) {
      return _handleCorrectionInput(question);
    }

    // Attempt Gemini online response if available and connected
    final brainService = context.read<AIBrainService>();
    if (brainService.isApiAvailable) {
      final geminiResponse = await brainService.askGemini(question);
      if (geminiResponse != null && geminiResponse.isNotEmpty) {
        return geminiResponse;
      }
    }

    // Check learned knowledge before template answers.
    try {
      final learnedKnowledge = await brainService.getRelevantKnowledge(
        question,
      );
      if (learnedKnowledge != null && learnedKnowledge.isNotEmpty) {
        return 'Mujhe yaad hai:\n\n$learnedKnowledge\n\nAgar update chahiye ho to "galat hai" bolkar sahi bata do.';
      }
    } catch (e) {
      debugPrint('Could not get learned knowledge: $e');
    }

    if (_hasAny(q, ['audit', 'checklist', 'verify', 'validation'])) {
      return _getAuditResponse(q);
    }

    if (_hasAny(q, ['sync', 'offline', 'online', 'pending sync'])) {
      return _getSyncResponse();
    }

    if (_hasAny(q, ['gst', 'tax', 'cgst', 'sgst', 'igst', 'invoice total'])) {
      return _getTaxKnowledgeResponse();
    }

    if (_isStockLookupQuery(q)) {
      final productQuery = _extractProductQuery(q);
      return await _handleStockQuery(productQuery);
    }

    if (_hasAny(q, ['flow', 'kaise', 'process', 'steps', 'workflow'])) {
      return _getFlowResponse(q);
    }

    final moduleKey = _detectModuleKey(q);
    if (moduleKey != null) {
      return _getModuleKnowledgeResponse(moduleKey, q);
    }

    if (_hasAny(q, ['stats', 'statistics'])) {
      return await _getStatsResponse();
    }

    if (_hasAny(q, ['help', 'madad'])) {
      return _getHelpResponse();
    }

    if (_hasAny(q, ['hello', 'hi', 'namaste', 'namaskar'])) {
      return 'Namaste! Main flow ke saath practical rules bhi bata sakta hoon.\n\n'
          'Example: "Sales GST ka breakdown batao" ya "Inventory reconciliation ka checklist do".';
    }

    return 'Main question samajh nahi paaya.\n\n'
        'Ye try karo:\n'
        '- "Sales GST kaise calculate hota hai"\n'
        '- "Dispatch lifecycle samjhao"\n'
        '- "Inventory audit checklist do"\n'
        '- "Stock kitna hai [product name]"';
  }

  String _normalizeQuestion(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _hasAny(String source, List<String> keywords) {
    for (final keyword in keywords) {
      if (source.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  String? _detectModuleKey(String query) {
    for (final entry in _moduleAliases.entries) {
      if (_hasAny(query, entry.value)) {
        return entry.key;
      }
    }
    return null;
  }

  bool _isStockLookupQuery(String query) {
    final hasStockTerm = _hasAny(query, [
      'stock',
      'inventory',
      'available',
      'in hand',
      'remaining',
      'bacha',
      'bache',
      'qty',
      'quantity',
      'maal',
      'mal',
      'product',
      'item',
    ]);
    final hasLookupIntent = _hasAny(query, [
      'kitna',
      'kitne',
      'how much',
      'check',
      'batao',
      'show',
      'find',
      'dikhao',
      'dekhao',
      'kaha',
    ]);
    return hasStockTerm || (hasLookupIntent && query.contains('mere'));
  }

  String _extractProductQuery(String query) {
    return query
        .replaceAll('stock', '')
        .replaceAll('inventory', '')
        .replaceAll('available', '')
        .replaceAll('remaining', '')
        .replaceAll('kitna', '')
        .replaceAll('kitne', '')
        .replaceAll('hai', '')
        .replaceAll('ka', '')
        .replaceAll('product', '')
        .replaceAll('item', '')
        .replaceAll('bache', '')
        .replaceAll('bacha', '')
        .replaceAll('mera', '')
        .replaceAll('mere', '')
        .replaceAll('pass', '')
        .replaceAll('paas', '')
        .replaceAll('apne', '')
        .replaceAll('iska', '')
        .replaceAll('kya', '')
        .replaceAll('batao', '')
        .replaceAll('show', '')
        .replaceAll('find', '')
        .replaceAll('dikhao', '')
        .replaceAll('dekhao', '')
        .replaceAll('maal', '')
        .replaceAll('mal', '')
        .replaceAll('liter', '')
        .replaceAll('ltr', '')
        .replaceAll('litre', '')
        .replaceAll('kg', '')
        .replaceAll('pack', '')
        .replaceAll('name', '')
        .replaceAll('se', '')
        .trim();
  }

  Future<String> _handleStockQuery(String productQuery) async {
    try {
      final db = context.read<DatabaseService>().db;
      final allProducts = await db.productEntitys.where().findAll();

      if (productQuery.isEmpty) {
        final inStock = allProducts.where((p) => (p.stock ?? 0) > 0).toList();
        inStock.sort((a, b) => (b.stock ?? 0).compareTo(a.stock ?? 0));
        final topMatches = inStock.take(5).toList();
        var response =
            'Aapke paas total ${inStock.length} items stock mein hain.\n\nTop Items:\n';
        for (final p in topMatches) {
          response += '- ${p.name}: ${p.stock ?? 0} ${p.baseUnit}\n';
        }
        response +=
            '\nKisi specific product ka naam bataiye stock dekhne ke liye.';
        return response;
      }

      final keywords = productQuery.toLowerCase().split(' ');
      final matches = allProducts.where((p) {
        final name = p.name.toLowerCase();
        return keywords.every((k) {
          if (k.length < 2) {
            final isDigit = int.tryParse(k) != null;
            if (!isDigit) return true;
          }
          return name.contains(k);
        });
      }).toList();

      if (matches.isEmpty) {
        final looseMatches = allProducts.where((p) {
          final name = p.name.toLowerCase();
          return keywords.any((k) => k.length > 3 && name.contains(k));
        }).toList();

        if (looseMatches.isEmpty) {
          return '"$productQuery" naam ka koi product nahi mila.\n\nTry checking spelling.';
        }
        matches.addAll(looseMatches);
      }

      if (matches.length == 1) {
        final p = matches.first;
        return 'Stock Report\n\n'
            'Product: ${p.name}\n'
            'Current Stock: ${p.stock ?? 0} ${p.baseUnit}\n'
            'Price: Rs ${p.price ?? 0}\n\n'
            'Last Updated: ${_formatTime(p.updatedAt)}\n\n'
            'Tip: Stock mismatch ho to "inventory reconciliation checklist" pucho.';
      }

      final topMatches = matches.take(5).toList();
      var response = 'Stock matches (${matches.length}):\n\n';
      for (final p in topMatches) {
        response += '- ${p.name}: ${p.stock ?? 0} ${p.baseUnit}\n';
      }
      if (matches.length > 5) {
        response += '\n...and ${matches.length - 5} more.';
      }
      response +=
          '\n\nExact product name bhejo, main detailed stock report dunga.';
      return response;
    } catch (e) {
      debugPrint('Stock Query Error: $e');
      return 'Stock check karte waqt error aaya.';
    }
  }

  Future<String> _handleRememberCommand(String input) async {
    final parts = input.toLowerCase().split(
      RegExp(r'remember this|yaad rakho'),
    );
    if (parts.length > 1) {
      final knowledge = parts[1].trim();
      if (knowledge.isNotEmpty) {
        try {
          final brainService = context.read<AIBrainService>();
          await brainService.learnCorrection(
            context: 'User taught',
            correction: knowledge,
            category: 'user_teaching',
            tags: ['manual', 'user_input'],
          );
          return 'Thik hai, maine yaad rakh liya.';
        } catch (e) {
          return 'Save nahi ho paya. Phir se try karo.';
        }
      }
    }
    return 'Kya yaad rakhna hai? "remember this [fact]" bolo.';
  }

  Future<String> _handleLockCommand(String input) async {
    if (_lastAIResponse != null) {
      try {
        final brainService = context.read<AIBrainService>();
        await brainService.lockKnowledge(
          context: 'Last AI response',
          knowledge: _lastAIResponse!,
          category: 'locked_knowledge',
          tags: ['final', 'user_confirmed'],
        );
        return 'Thik hai, is response ko final mark kar diya.';
      } catch (e) {
        return 'Lock nahi ho paya. Phir se try karo.';
      }
    }
    return 'Pehle koi sawal pucho, phir "this is final" bolo.';
  }

  Future<String> _handleCorrectionPrompt() async {
    if (_lastUserMessage != null) {
      return 'Maaf kijeiye, main samajh nahi paaya. "$_lastUserMessage" ka sahi matlab kya hai?';
    }
    return 'Maaf kijeiye, main samajh nahi paaya. Sahi jawab kya hona chahiye?';
  }

  Future<String> _handleCorrectionInput(String correction) async {
    if (_lastUserMessage == null) return 'Pehle batayein ki kya galat tha.';
    final brainService = context.read<AIBrainService>();
    await brainService.learnIntentMapping(_lastUserMessage!, correction);
    final prev = _lastUserMessage;
    _lastUserMessage = null; // Clear to prevent double learning
    return 'Theek hai, maine seekh liya hai ki "$prev" ka matlab "$correction" hai. Agli baar dhyan rakhunga!';
  }

  Future<String> _getStatsResponse() async {
    try {
      final brainService = context.read<AIBrainService>();
      final stats = await brainService.getLearningStats();

      return 'AI Brain Stats\n\n'
          'Total Learnings: ${stats['totalLearnings']}\n'
          'Locked Knowledge: ${stats['lockedKnowledge']}\n'
          'High Confidence: ${stats['highConfidence']}\n'
          'Chat Messages: ${stats['totalMessages']}';
    } catch (e) {
      return 'Stats load nahi ho paye.';
    }
  }

  String _getHelpResponse() {
    return 'Main practical knowledge de sakta hoon:\n'
        '- Module workflow + controls\n'
        '- GST calculation logic\n'
        '- Inventory reconciliation checklist\n'
        '- Dispatch lifecycle\n'
        '- Offline-first sync behavior\n'
        '- Product stock lookup\n\n'
        'Try:\n'
        '- "Sales GST breakdown"\n'
        '- "Dispatch status flow"\n'
        '- "Inventory audit checklist"';
  }

  String _getModuleKnowledgeResponse(String moduleKey, String query) {
    switch (moduleKey) {
      case 'inventory':
        return _getInventoryKnowledgeResponse(query);
      case 'sales':
        return _getSalesKnowledgeResponse(query);
      case 'dispatch':
        return _getDispatchKnowledgeResponse();
      case 'purchase':
        return _getPurchaseKnowledgeResponse();
      case 'production':
        return _getProductionKnowledgeResponse();
      case 'returns':
        return _getReturnsKnowledgeResponse();
      case 'reports':
        return _getReportsKnowledgeResponse();
      case 'raw_material':
        return _getRawMaterialKnowledgeResponse();
      default:
        final module = _projectKnowledge[moduleKey];
        if (module == null) {
          return _getHelpResponse();
        }
        return '${module.name}\n\n${module.description}\n\n'
            'Flow: ${module.dataFlow}\n'
            'Tables: ${module.tables.join(", ")}';
    }
  }

  String _getInventoryKnowledgeResponse(String query) {
    final module = _projectKnowledge['inventory']!;
    if (_hasAny(query, ['reconcile', 'mismatch', 'difference', 'adjustment'])) {
      return '${module.name} - Reconciliation\n\n'
          'Use case: physical stock aur system stock alag ho.\n\n'
          'Checklist:\n'
          '1. Product-wise physical count lock karo.\n'
          '2. Difference identify karo (plus/minus).\n'
          '3. Adjustment movement reason ke saath post karo.\n'
          '4. Ledger/report me same reference ID verify karo.\n'
          '5. Final variance report export karo.\n\n'
          'Important control:\n'
          '- Salesman ko warehouse adjustment allow nahi hai.\n'
          '- Insufficient stock par transaction reject hota hai.';
    }

    return '${module.name}\n\n'
        'Ye module warehouse stock, department issue/return, aur salesman allocation track karta hai.\n\n'
        'Operational flow:\n'
        '1. Stock movement (in/out/adjust)\n'
        '2. Department issue ya return\n'
        '3. Dispatch allocation update\n'
        '4. Reconcile and report\n\n'
        'Critical controls:\n'
        '- Har change movement/ledger reference ke saath save hota hai.\n'
        '- Negative ya insufficient stock attempts block kiye jate hain.\n'
        '- Offline me local save hota hai, sync baad me queue se hota hai.\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getSalesKnowledgeResponse(String query) {
    final module = _projectKnowledge['sales']!;
    if (_hasAny(query, ['gst', 'tax', 'cgst', 'sgst', 'igst', 'invoice'])) {
      return _getTaxKnowledgeResponse();
    }

    return '${module.name}\n\n'
        'Ye module customer order se invoice, collection aur dispatch trigger tak ka full cycle handle karta hai.\n\n'
        'Core process:\n'
        '1. Customer + route context resolve\n'
        '2. Product lines add, stock validation\n'
        '3. Discount and GST calculate\n'
        '4. Sale local DB me save (pending sync)\n'
        '5. Voucher/accounting posting queue\n'
        '6. Dispatch required ho to trip planning\n\n'
        'Important checks:\n'
        '- Line level aur overall discounts dono apply hote hain.\n'
        '- Taxable amount discount ke baad calculate hota hai.\n'
        '- Amounts 2 decimal precision par round kiye jate hain.\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getDispatchKnowledgeResponse() {
    final module = _projectKnowledge['dispatch']!;
    return '${module.name}\n\n'
        'Dispatch module trip planning aur delivery execution handle karta hai.\n\n'
        'Lifecycle:\n'
        '1. Trip create (pending)\n'
        '2. Sales link and vehicle/driver assign\n'
        '3. Trip start (in_progress / in_transit)\n'
        '4. Delivery complete and reconcile\n\n'
        'ERP safeguards:\n'
        '- Sales link hote hi relevant sale status update hota hai.\n'
        '- Dispatch allocation ke waqt stock availability check hota hai.\n'
        '- Receive/completion events se final status lock hota hai.\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getPurchaseKnowledgeResponse() {
    final module = _projectKnowledge['purchase']!;
    return '${module.name}\n\n'
        'Supplier procurement process yahan manage hota hai.\n\n'
        'Process:\n'
        '1. PO create\n'
        '2. Approval and supplier confirmation\n'
        '3. GRN / receiving\n'
        '4. Inventory stock update and audit trail\n\n'
        'Checks:\n'
        '- Received qty aur PO qty match verify karo.\n'
        '- Rate/discount/tax variance capture karo.\n'
        '- Receiving ke turant baad stock ledger verify karo.\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getProductionKnowledgeResponse() {
    final module = _projectKnowledge['production']!;
    return '${module.name}\n\n'
        'Production module raw material ko batch process se finished goods me convert karta hai.\n\n'
        'Process:\n'
        '1. Raw material issue\n'
        '2. Bhatti/batch execution\n'
        '3. Semi-finished to finished conversion\n'
        '4. Finished stock posting\n\n'
        'Checks:\n'
        '- Batch input-output variance monitor karo.\n'
        '- Wastage logs maintain karo.\n'
        '- Output posting ke baad inventory reports verify karo.\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getReturnsKnowledgeResponse() {
    final module = _projectKnowledge['returns']!;
    return '${module.name}\n\n'
        'Returns module damage/return approvals aur stock correction handle karta hai.\n\n'
        'Process:\n'
        '1. Return request capture\n'
        '2. Approval and reason classification\n'
        '3. Stock adjustment (salesman/warehouse)\n'
        '4. Credit note or accounting impact\n\n'
        'Checks:\n'
        '- Return quantity original sale context se validate karo.\n'
        '- Stock rollback entry and reference id traceable honi chahiye.\n'
        '- Financial adjustment customer balance ke saath reconcile karo.\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getReportsKnowledgeResponse() {
    final module = _projectKnowledge['reports']!;
    return '${module.name}\n\n'
        'Reports module operational data ko decision-ready format me aggregate karta hai.\n\n'
        'Use cases:\n'
        '- Stock valuation and stock movement analysis\n'
        '- Sales-dispatch reconciliation\n'
        '- Salesman performance and route productivity\n'
        '- GST/compliance summaries\n\n'
        'Validation rule:\n'
        '- Report total ko source transaction totals ke saath match karna mandatory hai.\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getRawMaterialKnowledgeResponse() {
    final module = _projectKnowledge['raw_material']!;
    return '${module.name}\n\n'
        'Ye module oils, chemicals, packaging jaise inputs ka planning aur tracking karta hai.\n\n'
        'Process:\n'
        '1. Purchase receiving\n'
        '2. Quality/quantity verification\n'
        '3. Storage and issue to production\n'
        '4. Consumption vs production variance review\n\n'
        'Tables: ${module.tables.join(", ")}\n'
        'Connected: ${module.relatedModules.join(", ")}';
  }

  String _getTaxKnowledgeResponse() {
    return 'Sales GST & Invoice Logic\n\n'
        'Calculation sequence:\n'
        '1. Line subtotal = quantity x unit price\n'
        '2. Line item discount apply hota hai\n'
        '3. Overall discount and additional discount proportionately distribute hote hain\n'
        '4. Taxable amount = subtotal - all discounts\n'
        '5. GST type ke hisab se split:\n'
        '   - CGST+SGST: equal split\n'
        '   - IGST: full amount IGST me\n'
        '6. Total amount = taxable + total GST\n\n'
        'Accuracy rules:\n'
        '- Monetary values 2 decimals par round hoti hain.\n'
        '- Discount pehle, GST baad me calculate hota hai.';
  }

  String _getAuditResponse(String query) {
    final moduleKey = _detectModuleKey(query);
    final moduleName = moduleKey == null
        ? 'General'
        : _projectKnowledge[moduleKey]!.name;

    return '$moduleName Audit Checklist\n\n'
        '1. UI validation: mandatory fields, permissions, status transitions\n'
        '2. Business rules: tax, stock, route, approval constraints\n'
        '3. Local DB: Isar write success + syncStatus consistency\n'
        '4. Queue/sync: failed network me retry entry confirm karo\n'
        '5. Reconciliation: report totals vs transaction totals match karo';
  }

  String _getFlowResponse(String query) {
    if (_hasAny(query, ['sale', 'order', 'invoice'])) {
      return 'Sales Flow\n\n'
          '1. Customer and route resolve\n'
          '2. Product lines + stock validation\n'
          '3. Discount + GST calculation\n'
          '4. Save in Isar as pending/synced\n'
          '5. Queue + background sync\n'
          '6. Dispatch/collection follow-up';
    }

    if (_hasAny(query, ['dispatch', 'trip', 'delivery'])) {
      return 'Dispatch Flow\n\n'
          '1. Trip creation\n'
          '2. Sales assignment\n'
          '3. Stock allocation checks\n'
          '4. In-transit execution\n'
          '5. Delivery completion\n'
          '6. Reconcile and close';
    }

    if (_hasAny(query, ['inventory', 'stock'])) {
      return 'Inventory Flow\n\n'
          '1. Purchase/production inflow\n'
          '2. Sales/dispatch/dept outflow\n'
          '3. Movement ledger update\n'
          '4. Reconciliation adjustments\n'
          '5. Reporting and audit trail';
    }

    return 'Main Flow\n\n'
        'Raw Material -> Production -> Finished Goods -> Inventory -> Sales -> Dispatch -> Reports';
  }

  String _getSyncResponse() {
    return 'Sync System\n\n'
        'Offline-first behavior:\n'
        '- Isar local DB primary write path hai\n'
        '- Sync queue pending actions track karti hai\n'
        '- Network milte hi background push/retry hota hai\n\n'
        'Failure scenario:\n'
        '- Network fail par transaction local safe rehta hai\n'
        '- Sync status pending mark hota hai\n'
        '- Next successful run me auto reconcile hota hai';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);

    return Drawer(
      width: Responsive.clamp(context, min: 300, max: 420, ratio: 0.32),
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, user?.name.toString()),
            _buildQuickChips(theme),
            Expanded(child: _buildChatList(theme)),
            _buildInputBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String? userName) {
    final micLabel = _speechAvailable ? 'Mic: Ready' : 'Mic: Unavailable';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DattSoap Assistant',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userName == null ? micLabel : '$micLabel - $userName',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (_isSpeaking) {
                _tts.stop();
              }
            },
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            tooltip: _ttsEnabled ? 'Speaker on' : 'Speaker off',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips(ThemeData theme) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        children: [
          _buildQuickChip(theme, 'Inventory'),
          _buildQuickChip(theme, 'Sales'),
          _buildQuickChip(theme, 'Dispatch'),
          _buildQuickChip(theme, 'Reports'),
        ],
      ),
    );
  }

  Widget _buildQuickChip(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: () {
          _chatController.text = label;
          _sendMessage();
        },
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
    );
  }

  Widget _buildChatList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator(theme);
        }
        return _buildMessageBubble(_messages[index], theme);
      },
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _openScannerSheet,
            icon: const Icon(Icons.qr_code_scanner, size: 20),
            tooltip: 'Camera',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 6),
          _buildVoiceButton(theme),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: _isListening ? 'Bol rahe ho...' : 'Type message',
                hintStyle: TextStyle(
                  color: _isListening
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _isListening
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, size: 18),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton(ThemeData theme) {
    if (!_speechAvailable) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.mic_off,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => _startListening(),
      onTapUp: (_) => _stopListening(autoSend: true),
      onTapCancel: () => _stopListening(autoSend: false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(_isListening ? 12 : 8),
        decoration: BoxDecoration(
          color: _isListening
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: _isListening
              ? [
                  BoxShadow(
                    color: theme.colorScheme.error.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          size: _isListening ? 22 : 18,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: message.isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(message.isUser ? 14 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 14),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 120)),
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3 + (value * 0.5),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ModuleInfo {
  final String name;
  final String description;
  final String dataFlow;
  final List<String> tables;
  final List<String> relatedModules;

  const ModuleInfo({
    required this.name,
    required this.description,
    required this.dataFlow,
    required this.tables,
    required this.relatedModules,
  });
}
