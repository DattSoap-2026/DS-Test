import 'package:flutter/material.dart';

class ThemeTransition extends StatefulWidget {
  final ThemeData theme;
  final Widget child;
  final Duration duration;

  const ThemeTransition({
    super.key,
    required this.theme,
    required this.child,
    required this.duration,
  });

  @override
  State<ThemeTransition> createState() => _ThemeTransitionState();
}

class _ThemeTransitionState extends State<ThemeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  int _themeHash = 0;

  @override
  void initState() {
    super.initState();
    _themeHash = widget.theme.hashCode;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..value = 1.0;
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant ThemeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextHash = widget.theme.hashCode;
    if (nextHash != _themeHash) {
      _themeHash = nextHash;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: widget.theme,
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: FadeTransition(
        opacity: _fade,
        child: widget.child,
      ),
    );
  }
}
