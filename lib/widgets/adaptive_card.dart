import 'package:flutter/material.dart';

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
