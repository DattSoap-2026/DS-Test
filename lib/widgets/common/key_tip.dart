import 'package:flutter/material.dart';
import '../../core/shortcuts/key_tip_controller.dart';

class KeyTip extends StatefulWidget {
  final String label;
  final String description;
  final VoidCallback onTrigger;
  final Widget child;
  final bool disabled;

  const KeyTip({
    super.key,
    required this.label,
    required this.description,
    required this.onTrigger,
    required this.child,
    this.disabled = false,
  });

  @override
  State<KeyTip> createState() => _KeyTipState();
}

class _KeyTipState extends State<KeyTip> {
  @override
  void initState() {
    super.initState();
    if (!widget.disabled) {
      _register();
    }
  }

  @override
  void didUpdateWidget(KeyTip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label ||
        oldWidget.disabled != widget.disabled) {
      KeyTipController.instance.unregister(oldWidget.label);
      if (!widget.disabled) {
        _register();
      }
    }
  }

  @override
  void dispose() {
    KeyTipController.instance.unregister(widget.label);
    super.dispose();
  }

  void _register() {
    KeyTipController.instance.register(
      widget.label,
      KeyTipNode(
        label: widget.label,
        onTrigger: widget.onTrigger,
        description: widget.description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KeyTipController.instance,
      builder: (context, _) {
        final showTips = KeyTipController.instance.mode != KeyTipMode.hidden;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (showTips && !widget.disabled)
              Positioned(
                left: 0,
                right: 0,
                top: -12, // Verify positioning logic
                child: Center(child: _buildBadge(context)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.6),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.label.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
