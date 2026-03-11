import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum KeyTipMode {
  hidden, // Tips are not visible
  global, // Showing top-level tips (Sidebar, etc.)
  page, // Showing page-level tips (if we drill down)
}

/// A node in the KeyTip tree.
class KeyTipNode {
  final String label; // The key sequence (e.g. "H", "S", "AA")
  final VoidCallback onTrigger;
  final String description;

  KeyTipNode({
    required this.label,
    required this.onTrigger,
    required this.description,
  });
}

class KeyTipController extends ChangeNotifier {
  static final KeyTipController instance = KeyTipController._internal();

  KeyTipController._internal();

  // State
  KeyTipMode _mode = KeyTipMode.hidden;
  KeyTipMode get mode => _mode;

  // Registry: Map of keys to actions.
  // We might want different maps for different scopes, but for now let's keep it simple:
  // Global registry for the active scope.
  final Map<String, KeyTipNode> _registry = {};
  Map<String, KeyTipNode> get registry => Map.unmodifiable(_registry);

  // Input buffer for multi-key sequences (future proofing)
  // String _inputBuffer = ''; // Removed for now as unused

  void register(String key, KeyTipNode node) {
    // Basic collision handling: if key exists, log warning or append suffix?
    // For now, overwrite or simple unique check could be added.
    _registry[key.toUpperCase()] = node;
    // notifyListeners(); // Removed to prevent build-phase rebuilds
  }

  void unregister(String key) {
    _registry.remove(key.toUpperCase());
    // notifyListeners(); // Removed to prevent build-phase rebuilds
  }

  void toggleMode() {
    // Security/UX: Don't toggle if user is typing in a text field
    if (_mode == KeyTipMode.hidden) {
      if (_isFocusOnTextInput()) {
        return; // Suppress
      }
      _mode = KeyTipMode.global;
    } else {
      _mode = KeyTipMode.hidden;
      // _inputBuffer = '';
    }
    notifyListeners();
  }

  void setMode(KeyTipMode newMode) {
    _mode = newMode;
    // if (newMode == KeyTipMode.hidden) {
    //   _inputBuffer = '';
    // }
    notifyListeners();
  }

  /// Handles key events from the root listener
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // Alt Toggle Logic (Press and Release is harder to capture purely here without state history,
    // but usually KeyUp + check if other keys were pressed.
    // Simplifying: If Alt is pressed, we might toggle.
    // However, clean Alt-toggle usually requires a FocusNode or RawKeyboardListener up high.
    // We'll expose a method `onAltPressed` to be called by the UI layer.

    if (_mode == KeyTipMode.hidden) return false;

    // If modal is open, we consume keys
    final char = event.character?.toUpperCase();
    if (char != null && _registry.containsKey(char)) {
      final node = _registry[char];
      node?.onTrigger();
      // Auto-hide after trigger? Usually yes for leaf actions.
      setMode(KeyTipMode.hidden);
      return true; // We handled it
    }

    // Escape to close
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setMode(KeyTipMode.hidden);
      return true;
    }

    return false; // Let it propagate if not matched
  }

  bool _isFocusOnTextInput() {
    final focusNode = FocusManager.instance.primaryFocus;
    if (focusNode == null) return false;
    // Context check or type check if possible, mainly heuristic
    // If the focused widget is a EditableText, usually has a specific runtime type internal
    // simpler: check context ancestor?
    return focusNode.context?.widget is EditableText;
  }
}
