import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final Color? borderColor;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.borderColor,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isHovered = false;

  bool get _supportsHover {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  void _setHovered(bool value) {
    if (!mounted || !_supportsHover || _isHovered == value) return;
    setState(() => _isHovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(18);

    final card = GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        transform: _isHovered
            ? Matrix4.translationValues(0.0, -4.0, 0.0)
            : Matrix4.identity(),
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: effectiveBorderRadius,
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ],
          border: Border.all(
            color:
                widget.borderColor ??
                Theme.of(context).colorScheme.outline.withValues(
                  alpha: _isHovered ? 0.4 : 0.12,
                ),
          ),
        ),
        child: widget.child,
      ),
    );

    if (!_supportsHover) return card;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: card,
    );
  }
}
