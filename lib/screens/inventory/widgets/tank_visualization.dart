import 'package:flutter/material.dart';

class TankVisualization extends StatelessWidget {
  final double fillLevel; // 0 to 100
  final Color liquidColor;
  final String label;
  final String unitLabel;

  const TankVisualization({
    super.key,
    required this.fillLevel,
    required this.liquidColor,
    this.label = '',
    this.unitLabel = 'Ton',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tank Body
          CustomPaint(
            size: Size.infinite,
            painter: TankPainter(
              fillLevel: fillLevel / 100,
              liquidColor: liquidColor,
              colorScheme: colorScheme,
            ),
          ),
          // Label in center
          if (label.isNotEmpty)
            Positioned(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    unitLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TankPainter extends CustomPainter {
  final double fillLevel;
  final Color liquidColor;
  final ColorScheme colorScheme;

  TankPainter({
    required this.fillLevel,
    required this.liquidColor,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final R = size.width * 0.2; // Border radius for tank

    // Tank background (Glass effect)
    final tankPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(R)));

    // Draw outer shell shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(R)),
      Paint()
        ..color = colorScheme.shadow.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4),
    );

    // Draw main glass body
    final glassGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surface.withValues(alpha: 0.8),
        colorScheme.surface.withValues(alpha: 0.3),
        colorScheme.outlineVariant.withValues(alpha: 0.5),
      ],
    ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(R)),
      Paint()..shader = glassGradient,
    );

    // Draw Liquid
    final liquidHeight = size.height * fillLevel;
    final liquidRect = Rect.fromLTWH(
      0,
      size.height - liquidHeight,
      size.width,
      liquidHeight,
    );

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [liquidColor.withValues(alpha: 0.8), liquidColor],
      ).createShader(liquidRect);

    // Clip liquid to tank shape
    canvas.save();
    canvas.clipPath(tankPath);

    // Draw liquid body
    canvas.drawRect(liquidRect, liquidPaint);

    // Draw gloss/reflection on liquid
    final glossPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.onSurface.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height - liquidHeight,
              size.width,
              liquidHeight * 0.3,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - liquidHeight,
        size.width,
        liquidHeight * 0.3,
      ),
      glossPaint,
    );

    canvas.restore();

    // Draw Border
    final borderPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(R)),
      borderPaint,
    );

    // Draw top gloss
    final topGloss = Path()
      ..moveTo(R, R)
      ..quadraticBezierTo(size.width / 2, 0, size.width - R, R);
    canvas.drawPath(
      topGloss,
      Paint()
        ..color = colorScheme.onSurface.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant TankPainter oldDelegate) =>
      oldDelegate.fillLevel != fillLevel ||
      oldDelegate.liquidColor != liquidColor ||
      oldDelegate.colorScheme != colorScheme;
}
