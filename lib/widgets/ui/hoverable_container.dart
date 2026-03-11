import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class HoverableContainer extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final Decoration? hoverDecoration;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTap;

  const HoverableContainer({
    super.key,
    this.child,
    this.padding,
    this.decoration,
    this.hoverDecoration,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.onTap,
  });

  @override
  State<HoverableContainer> createState() => _HoverableContainerState();
}

class _HoverableContainerState extends State<HoverableContainer> {
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
    final effectiveDecoration = _isHovered
        ? (widget.hoverDecoration ?? widget.decoration)
        : widget.decoration;

    final content = GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        padding: widget.padding,
        decoration: effectiveDecoration,
        child: widget.child,
      ),
    );

    if (!_supportsHover) return content;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: content,
    );
  }
}
