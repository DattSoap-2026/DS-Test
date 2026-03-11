import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ErpStartupSplash extends StatefulWidget {
  final VoidCallback? onLoginAction;
  final VoidCallback? onBiometricAction;

  const ErpStartupSplash({
    super.key,
    this.onLoginAction,
    this.onBiometricAction,
  });

  @override
  State<ErpStartupSplash> createState() => _ErpStartupSplashState();
}

class _ErpStartupSplashState extends State<ErpStartupSplash>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _breatheController;
  late final AnimationController _pulseController;

  String _appVersion = '';

  bool _showLoginButton = false;
  bool _hasCompletedFirstPass = false;

  @override
  void initState() {
    super.initState();
    // Faster, snappier intro duration
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    // Continuous smooth background breathing
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Subtle pulse for the login button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showLoginButton = true;
            _hasCompletedFirstPass = true;
          });
          _pulseController.repeat(reverse: true);
          // Loop from the icons start point
          _mainController.forward(from: 0.35);
        }
      }
    });

    _mainController.forward();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${info.version} (Build ${info.buildNumber})';
        });
      }
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _breatheController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _segment(double value, double start, double end) {
    if (value <= start) return 0;
    if (value >= end) return 1;
    return (value - start) / (end - start);
  }

  Widget _buildBubble({
    required double width,
    required double height,
    required Alignment alignment,
    required double progress,
    required double breathe,
    required double size,
    required double phase,
    required double opacity,
    required Color color,
  }) {
    final centerX = (alignment.x + 1) * 0.5 * width;
    final centerY = (alignment.y + 1) * 0.5 * height;

    // Complex organic movement
    final driftY = math.sin((progress * math.pi * 2) + phase) * 25 * breathe;
    final driftX = math.cos((progress * math.pi * 1.5) + phase) * 20;
    final scale = 1.0 + (breathe * 0.15 * math.sin(phase));

    return Positioned(
      left: centerX - (size / 2) + driftX,
      top: centerY - (size / 2) + driftY,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0)),
                color.withValues(alpha: 0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(
                  alpha: (opacity * 0.4 * breathe).clamp(0.0, 1.0),
                ),
                blurRadius: size * 0.8,
                spreadRadius: size * 0.2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double reveal,
    required Color iconColor,
    required double iconSize,
    required double fontSize,
    required double breathe,
  }) {
    // Dynamic spring effect
    final eased = Curves.elasticOut.transform(reveal.clamp(0.0, 1.0));
    final hoverY = math.sin(breathe * math.pi) * 4.0;

    return Opacity(
      opacity: reveal.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, ((1 - eased) * 40) + hoverY),
        child: Transform.scale(
          scale: 0.5 + (0.5 * eased),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(iconSize * 0.45),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withValues(alpha: 0.2 + (0.1 * breathe)),
                      iconColor.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.5 + (0.2 * breathe)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.3 * reveal),
                      blurRadius: 15 + (10 * breathe),
                      spreadRadius: 2 * breathe,
                    ),
                  ],
                ),
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
              SizedBox(height: iconSize * 0.4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      color: iconColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnector({
    required double reveal,
    required double width,
    required double breathe,
  }) {
    final glow = Curves.easeInOut.transform(reveal);
    return Container(
      width: width * glow,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: (0.8 * glow).clamp(0.0, 1.0)),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(
              alpha: (0.6 * glow * breathe).clamp(0.0, 1.0),
            ),
            blurRadius: 8 + (4 * breathe),
            spreadRadius: 1 * breathe,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Responsive sizing
    final logoBase = math.max(70.0, math.min(size.height * 0.12, 110.0));
    final iconSize = math.max(22.0, math.min(width * 0.04, 40.0));
    final connectorWidth = math.max(12.0, math.min(width * 0.04, 30.0));
    final fontSize = math.max(10.0, math.min(width * 0.014, 14.0));
    final verticalGap = math.max(12.0, math.min(size.height * 0.04, 24.0));

    return Material(
      color: const Color(0xFF020617),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _breatheController,
          _pulseController,
        ]),
        builder: (context, _) {
          final t = _mainController.value;
          final b = _breatheController.value;
          final p = _pulseController.value;

          // Elements timings
          final logoReveal = _hasCompletedFirstPass
              ? 1.0
              : Curves.elasticOut.transform(_segment(t, 0.0, 0.3));
          final subtitleOpacity = _hasCompletedFirstPass
              ? 1.0
              : Curves.easeIn.transform(_segment(t, 0.15, 0.35));

          final rawReveal = Curves.easeOutCubic.transform(
            _segment(t, 0.35, 0.45),
          );
          final c1 = Curves.easeOutCubic.transform(_segment(t, 0.40, 0.50));
          final prodReveal = Curves.easeOutCubic.transform(
            _segment(t, 0.45, 0.55),
          );
          final c2 = Curves.easeOutCubic.transform(_segment(t, 0.50, 0.60));
          final invReveal = Curves.easeOutCubic.transform(
            _segment(t, 0.55, 0.65),
          );
          final c3 = Curves.easeOutCubic.transform(_segment(t, 0.60, 0.70));
          final dispatchReveal = Curves.easeOutCubic.transform(
            _segment(t, 0.65, 0.75),
          );

          final loginReveal = Curves.easeOutCubic.transform(
            _segment(t, 0.80, 0.95),
          );
          final showLoginNow = _showLoginButton || loginReveal > 0.01;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Mesmerizing Animated Background Gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          const Color(0xFF0F172A),
                          const Color(0xFF1E293B),
                          b,
                        )!,
                        const Color(0xFF020617),
                        Color.lerp(
                          const Color(0xFF020617),
                          const Color(0xFF0B1120),
                          1 - b,
                        )!,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Animated Orbs
              LayoutBuilder(
                builder: (context, constraints) {
                  final cw = constraints.maxWidth;
                  final ch = constraints.maxHeight;
                  return Stack(
                    children: [
                      _buildBubble(
                        width: cw,
                        height: ch,
                        alignment: const Alignment(-0.8, -0.6),
                        progress: t,
                        breathe: b,
                        size: cw * 0.25,
                        phase: 0.0,
                        opacity: 0.15,
                        color: const Color(0xFF38BDF8),
                      ),
                      _buildBubble(
                        width: cw,
                        height: ch,
                        alignment: const Alignment(0.9, -0.2),
                        progress: t,
                        breathe: b,
                        size: cw * 0.2,
                        phase: 2.0,
                        opacity: 0.12,
                        color: const Color(0xFF818CF8),
                      ),
                      _buildBubble(
                        width: cw,
                        height: ch,
                        alignment: const Alignment(-0.4, 0.8),
                        progress: t,
                        breathe: b,
                        size: cw * 0.3,
                        phase: 4.0,
                        opacity: 0.1,
                        color: const Color(0xFF34D399),
                      ),
                    ],
                  );
                },
              ),

              // Glass Overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: const SizedBox(),
                ),
              ),

              // Foreground Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dynamic Logo Reveal
                      if (logoReveal > 0.01)
                        Transform.scale(
                          scale: 0.8 + (logoReveal * 0.2),
                          child: Transform.rotate(
                            angle: (1 - logoReveal) * -0.2,
                            child: Opacity(
                              opacity: logoReveal.clamp(0.0, 1.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulsing Outer Aura
                                  Container(
                                    width: logoBase * 1.5,
                                    height: logoBase * 1.5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Theme.of(
                                            context,
                                          ).colorScheme.primary.withValues(
                                            alpha: 0.2 + (0.1 * b),
                                          ),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.2, 1.0],
                                      ),
                                    ),
                                  ),
                                  // Rotating Glass Ring
                                  Transform.rotate(
                                    angle: t * math.pi * 2,
                                    child: Container(
                                      width: logoBase * 1.25,
                                      height: logoBase * 1.25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(
                                                alpha: 0.3 + (0.2 * b),
                                              ),
                                          width: 2.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.2),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Sharp Inner Ring
                                  Container(
                                    width: logoBase * 1.1,
                                    height: logoBase * 1.1,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/company-logo.png',
                                    width: logoBase,
                                    height: logoBase,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: verticalGap * 0.4),

                      // Text Elements
                      if (subtitleOpacity > 0.01)
                        Opacity(
                          opacity: subtitleOpacity,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - subtitleOpacity)),
                            child: Column(
                              children: [
                                Text(
                                  'Datt Soap Industry',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        shadows: [
                                          Shadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.5 * b),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'SMART MANUFACTURING ERP',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: verticalGap * 1.2),

                      // Workflow Chain
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFlowIcon(
                                context,
                                icon: Icons.inventory_2_rounded,
                                label: 'Materials',
                                reveal: rawReveal,
                                iconColor: const Color(0xFFF59E0B),
                                iconSize: iconSize,
                                fontSize: fontSize,
                                breathe: b,
                              ),
                              _buildConnector(
                                reveal: c1,
                                width: connectorWidth,
                                breathe: b,
                              ),
                              _buildFlowIcon(
                                context,
                                icon: Icons.precision_manufacturing_rounded,
                                label: 'Production',
                                reveal: prodReveal,
                                iconColor: const Color(0xFF38BDF8),
                                iconSize: iconSize,
                                fontSize: fontSize,
                                breathe: b,
                              ),
                              _buildConnector(
                                reveal: c2,
                                width: connectorWidth,
                                breathe: b,
                              ),
                              _buildFlowIcon(
                                context,
                                icon: Icons.warehouse_rounded,
                                label: 'Inventory',
                                reveal: invReveal,
                                iconColor: const Color(0xFFA78BFA),
                                iconSize: iconSize,
                                fontSize: fontSize,
                                breathe: b,
                              ),
                              _buildConnector(
                                reveal: c3,
                                width: connectorWidth,
                                breathe: b,
                              ),
                              _buildFlowIcon(
                                context,
                                icon: Icons.local_shipping_rounded,
                                label: 'Dispatch',
                                reveal: dispatchReveal,
                                iconColor: const Color(0xFF34D399),
                                iconSize: iconSize,
                                fontSize: fontSize,
                                breathe: b,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: verticalGap * 1.5),

                      // Interaction Area
                      if (showLoginNow)
                        Opacity(
                          opacity: _showLoginButton ? 1.0 : loginReveal,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              20 * (1 - (_showLoginButton ? 1.0 : loginReveal)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.3 + (0.2 * p)),
                                        blurRadius: 20 + (10 * p),
                                        spreadRadius: 2 * p,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: widget.onLoginAction,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 56,
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2.5,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkResponse(
                                    onTap: widget.onBiometricAction,
                                    radius: 32,
                                    splashColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.2),
                                    highlightColor: Colors.white10,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                        color: Colors.white.withValues(
                                          alpha: 0.02,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.fingerprint_rounded,
                                        size: 36,
                                        color: Colors.white.withValues(
                                          alpha: 0.7 + (0.3 * p),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // App Version Display
              if (_appVersion.isNotEmpty)
                Positioned(
                  bottom: 16.0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _appVersion,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12.0,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
