import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'key_tip_controller.dart';

/// Callback type for shortcut actions
typedef ShortcutCallback = void Function(BuildContext context);

/// A simpler, more reliable shortcuts wrapper using CallbackShortcuts
class GlobalShortcutsWrapper extends StatelessWidget {
  final Widget child;
  final ShortcutCallback? onSearch; // Ctrl+K
  final ShortcutCallback? onHelp; // Ctrl+/
  final ShortcutCallback? onNewItem; // Ctrl+N
  final ShortcutCallback? onNewTab; // Ctrl+T
  final ShortcutCallback? onCloseTab; // Ctrl+W
  final ShortcutCallback? onSave; // Ctrl+S

  const GlobalShortcutsWrapper({
    super.key,
    required this.child,
    this.onSearch,
    this.onHelp,
    this.onNewItem,
    this.onNewTab,
    this.onCloseTab,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    // Only enable shortcuts on Windows desktop
    if (!Platform.isWindows) {
      return child;
    }

    return CallbackShortcuts(
      bindings: {
        // Ctrl + K: Search / Command Palette
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          onSearch?.call(context);
        },

        // Ctrl + /: Help
        const SingleActivator(LogicalKeyboardKey.slash, control: true): () {
          onHelp?.call(context);
        },

        // Ctrl + N: New Item
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          onNewItem?.call(context);
        },

        // Ctrl + T: New Tab
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
          onNewTab?.call(context);
        },

        // Ctrl + W: Close Tab
        const SingleActivator(LogicalKeyboardKey.keyW, control: true): () {
          onCloseTab?.call(context);
        },

        // Ctrl + S: Save
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          onSave?.call(context);
        },

        // Alt + ?: Help Overlay
        const SingleActivator(LogicalKeyboardKey.slash, alt: true): () {
          // Alt + ? (on US layout)
          // We'll define onHelpOverlay separately or reuse generic help
          // For now, let's just trigger generic help if no specific implementation
          // Or better, let KeyTipController handle this?
          // Actually, simplest is to add onHelpOverlay callback or handle globally.
          // Let's reuse onHelp for now to show shortcuts, or upgrade onHelp.
          onHelp?.call(context);
        },
      },
      child: KeyboardListener(
        focusNode: FocusNode(
          debugLabel: 'GlobalShortcutsWrapper',
          skipTraversal: true,
          canRequestFocus: false,
        ),
        onKeyEvent: (event) {
          // Pass event to KeyTipController
          final handled = KeyTipController.instance.handleKeyEvent(event);
          if (handled) return;

          // Handle Alt Toggle
          if (event //
                  is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.altLeft ||
                  event.logicalKey == LogicalKeyboardKey.altRight)) {
            // Check if other keys were pressed?
            // Ideally we want "Press & Release Alt" with nothing else.
            // KeyTipController logic handles this simply as "Toggle".
            KeyTipController.instance.toggleMode();
          }
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

// Legacy Intent classes for backward compatibility
class SearchIntent extends Intent {
  const SearchIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class HelpIntent extends Intent {
  const HelpIntent();
}

class NewTabIntent extends Intent {
  const NewTabIntent();
}

class SplitViewIntent extends Intent {
  const SplitViewIntent();
}

class NewWindowIntent extends Intent {
  const NewWindowIntent();
}

class CloseTabIntent extends Intent {
  const CloseTabIntent();
}

class NewItemIntent extends Intent {
  const NewItemIntent();
}
