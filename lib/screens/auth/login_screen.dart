import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/custom_button.dart';
import '../../services/biometric_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isBiometricLoading = false;
  bool _isBiometricAvailable = false;
  bool _hasBiometricCredentials = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  String _appVersion = '';

  late AnimationController _controller;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final BiometricAuthService _biometricAuthService = BiometricAuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _initializeBiometricState();
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
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Widget _buildFloatingBubble({
    required double width,
    required double height,
    required Alignment alignment,
    required double progress,
    required double size,
    required double phase,
    required double opacity,
  }) {
    final centerX = (alignment.x + 1) * 0.5 * width;
    final centerY = (alignment.y + 1) * 0.5 * height;
    final driftY = math.sin((progress * math.pi * 2) + phase) * 15;
    final driftX = math.cos((progress * math.pi * 1.4) + phase) * 8;

    return Positioned(
      left: centerX - (size / 2) + driftX,
      top: centerY - (size / 2) + driftY,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: (opacity * 0.75).clamp(0.0, 1.0)),
              Colors.white.withValues(alpha: (opacity * 0.08).clamp(0.0, 1.0)),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: (opacity * 0.95).clamp(0.0, 1.0),
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(
                alpha: (opacity * 0.45).clamp(0.0, 1.0),
              ),
              blurRadius: size * 0.35,
            ),
          ],
        ),
      ),
    );
  }

  double _loopPulse(
    double t,
    double center, {
    double span = 0.8,
    int totalSteps = 4,
  }) {
    final track = (t * totalSteps) % totalSteps;
    final diff = (track - center).abs();
    final wrappedDiff = math.min(diff, totalSteps - diff);
    final value = (1 - (wrappedDiff / span)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(value);
  }

  Widget _buildWorkflowNode({
    required IconData icon,
    required String label,
    required Color color,
    required double pulse,
    required double iconSize,
    required double labelSize,
  }) {
    final scale = 0.88 + (0.2 * pulse);
    final glow = 0.14 + (0.46 * pulse);
    return Transform.translate(
      offset: Offset(0, (1 - pulse) * 4),
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(iconSize * 0.45),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14 + (0.1 * pulse)),
                border: Border.all(
                  color: color.withValues(alpha: 0.45 + (0.26 * pulse)),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: glow),
                    blurRadius: 14 + (8 * pulse),
                    spreadRadius: 1 + (0.6 * pulse),
                  ),
                ],
              ),
              child: Icon(icon, size: iconSize, color: color),
            ),
            SizedBox(height: iconSize * 0.35),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78 + (0.2 * pulse)),
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowConnector({
    required double pulse,
    required double width,
  }) {
    final glow = 0.08 + (0.65 * pulse);
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 2.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.03 * glow),
            Colors.white.withValues(alpha: 0.85 * glow),
            Colors.white.withValues(alpha: 0.03 * glow),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.52 * glow),
            blurRadius: 9,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  InputDecoration _buildGlossyInputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF394B62),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.88),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
    );
  }

  Widget _buildGlossyField({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBrandHeader(ThemeData theme, double maxWidth) {
    final logoBase = math.max(82.0, math.min(maxWidth * 0.24, 124.0));
    final logoOuter = logoBase * 1.6;
    final logoInner = logoBase * 1.15;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: logoOuter,
              height: logoOuter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.22),
                    const Color(0xFF38BDF8).withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: logoInner,
              height: logoInner,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.32),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/company-logo.png',
              width: logoBase,
              height: logoBase,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.factory_rounded,
                size: logoBase * 0.68,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Datt Soap Industry',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Smart Manufacturing ERP',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricIcon(ThemeData theme) {
    final canUseBiometric =
        _isBiometricAvailable &&
        _hasBiometricCredentials &&
        !_isLoading &&
        !_isBiometricLoading;
    final biometricColor = _isBiometricAvailable
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: canUseBiometric ? _handleBiometricLogin : null,
        radius: 30,
        splashColor: biometricColor.withValues(alpha: 0.22),
        highlightColor: biometricColor.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(
              alpha: _isBiometricAvailable ? 0.5 : 0.2,
            ),
            shape: BoxShape.circle,
          ),
          child: _isBiometricLoading
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.primary,
                    ),
                  ),
                )
              : Icon(Icons.fingerprint, size: 32, color: biometricColor),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, _) {
        final t = _backgroundController.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final workflowBottom = (height * 0.14)
                    .clamp(90.0, 130.0)
                    .toDouble();
                final iconSize = math.max(20.0, math.min(width * 0.048, 42.0));
                final labelSize = math.max(10.0, math.min(width * 0.017, 16.0));
                final connectorWidth = math.max(
                  18.0,
                  math.min(width * 0.085, 78.0),
                );

                final rawPulse = 0.35 + (0.65 * _loopPulse(t, 0));
                final prodPulse = 0.35 + (0.65 * _loopPulse(t, 1));
                final invPulse = 0.35 + (0.65 * _loopPulse(t, 2));
                final dispatchPulse = 0.35 + (0.65 * _loopPulse(t, 3));
                final c1Pulse = 0.22 + (0.78 * _loopPulse(t, 0.5, span: 0.95));
                final c2Pulse = 0.22 + (0.78 * _loopPulse(t, 1.5, span: 0.95));
                final c3Pulse = 0.22 + (0.78 * _loopPulse(t, 2.5, span: 0.95));

                return Stack(
                  children: [
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(-0.78, -0.72),
                      progress: t,
                      size: width * 0.14,
                      phase: 0.6,
                      opacity: 0.15,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(0.72, -0.56),
                      progress: t,
                      size: width * 0.1,
                      phase: 1.9,
                      opacity: 0.17,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(0.82, 0.16),
                      progress: t,
                      size: width * 0.16,
                      phase: 3.4,
                      opacity: 0.1,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(-0.83, 0.24),
                      progress: t,
                      size: width * 0.08,
                      phase: 5.2,
                      opacity: 0.13,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(0.2, 0.9),
                      progress: t,
                      size: width * 0.12,
                      phase: 4.1,
                      opacity: 0.1,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(-0.96, 0.64),
                      progress: t,
                      size: width * 0.09,
                      phase: 2.3,
                      opacity: 0.16,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(-0.22, -0.92),
                      progress: t,
                      size: width * 0.08,
                      phase: 0.9,
                      opacity: 0.13,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(0.96, 0.7),
                      progress: t,
                      size: width * 0.2,
                      phase: 3.8,
                      opacity: 0.11,
                    ),
                    _buildFloatingBubble(
                      width: width,
                      height: height,
                      alignment: const Alignment(-0.62, 0.86),
                      progress: t,
                      size: width * 0.1,
                      phase: 5.6,
                      opacity: 0.12,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: workflowBottom,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.95,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildWorkflowNode(
                                    icon: Icons.inventory_2_rounded,
                                    label: 'Raw Material',
                                    color: const Color(0xFFF59E0B),
                                    pulse: rawPulse,
                                    iconSize: iconSize,
                                    labelSize: labelSize,
                                  ),
                                  _buildWorkflowConnector(
                                    pulse: c1Pulse,
                                    width: connectorWidth,
                                  ),
                                  _buildWorkflowNode(
                                    icon: Icons.precision_manufacturing_rounded,
                                    label: 'Production',
                                    color: const Color(0xFF38BDF8),
                                    pulse: prodPulse,
                                    iconSize: iconSize,
                                    labelSize: labelSize,
                                  ),
                                  _buildWorkflowConnector(
                                    pulse: c2Pulse,
                                    width: connectorWidth,
                                  ),
                                  _buildWorkflowNode(
                                    icon: Icons.warehouse_rounded,
                                    label: 'Inventory',
                                    color: const Color(0xFFA78BFA),
                                    pulse: invPulse,
                                    iconSize: iconSize,
                                    labelSize: labelSize,
                                  ),
                                  _buildWorkflowConnector(
                                    pulse: c3Pulse,
                                    width: connectorWidth,
                                  ),
                                  _buildWorkflowNode(
                                    icon: Icons.local_shipping_rounded,
                                    label: 'Dispatch',
                                    color: const Color(0xFF34D399),
                                    pulse: dispatchPulse,
                                    iconSize: iconSize,
                                    labelSize: labelSize,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _friendlyErrorMessage(String errorMessage) {
    if (errorMessage.contains('network-request-failed') ||
        errorMessage.contains('offline')) {
      return "Offline Mode: First-time login requires internet connection.";
    }
    return errorMessage.replaceAll('Exception: ', '');
  }

  Future<void> _initializeBiometricState() async {
    final availability = await _biometricAuthService.getAvailability();
    final hasCredentials = await _biometricAuthService.hasStoredCredentials();
    final saved = await _biometricAuthService.readCredentials();
    if (!mounted) return;

    setState(() {
      _isBiometricAvailable = availability.available;
      _hasBiometricCredentials = hasCredentials;
    });

    if (saved != null && _emailController.text.trim().isEmpty) {
      _emailController.text = saved.email;
    }
  }

  Future<void> _saveBiometricCredentialsIfPossible() async {
    final availability = await _biometricAuthService.getAvailability();
    if (!availability.available) return;
    await _biometricAuthService.saveCredentials(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _isBiometricAvailable = true;
      _hasBiometricCredentials = true;
    });
  }

  bool _shouldClearBiometricCredentials(String errorMessage) {
    return errorMessage.contains('wrong-password') ||
        errorMessage.contains('invalid-credential') ||
        errorMessage.contains('user-not-found');
  }

  Future<void> _handleBiometricLogin() async {
    if (_isLoading || _isBiometricLoading) return;

    setState(() {
      _isBiometricLoading = true;
      _errorMessage = null;
    });

    try {
      final availability = await _biometricAuthService.getAvailability();
      final saved = await _biometricAuthService.readCredentials();

      if (!availability.available) {
        if (!mounted) return;
        setState(() {
          _isBiometricAvailable = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication is not available'),
          ),
        );
        return;
      }

      if (saved == null) {
        if (!mounted) return;
        setState(() {
          _hasBiometricCredentials = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'First login once with email and password to enable biometric login',
            ),
          ),
        );
        return;
      }

      final authenticated = await _biometricAuthService.authenticateForLogin();
      if (!authenticated) {
        return;
      }

      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithEmailAndPassword(
        email: saved.email,
        password: saved.password,
      );

      if (!mounted) return;
      _emailController.text = saved.email;
    } catch (e) {
      final errorMsg = e.toString();
      if (_shouldClearBiometricCredentials(errorMsg)) {
        await _biometricAuthService.clearCredentials();
        if (mounted) {
          setState(() {
            _hasBiometricCredentials = false;
          });
        }
      }
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyErrorMessage(errorMsg);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBiometricLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _saveBiometricCredentialsIfPossible();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _friendlyErrorMessage(e.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildAnimatedBackground()),
          // Soft dim overlay to keep the image visible but readable
          Positioned.fill(
            child: Container(
              color: theme.colorScheme.surface.withValues(
                alpha: isDark ? 0.08 : 0.03,
              ),
            ),
          ),
          // Gentle gradient overlay (no harsh opacity)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface.withValues(
                      alpha: isDark ? 0.1 : 0.03,
                    ),
                    theme.colorScheme.surface.withValues(
                      alpha: isDark ? 0.18 : 0.08,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentMaxWidth = math.min(
                    420.0,
                    constraints.maxWidth - 48,
                  );
                  final loginButtonWidth = math.max(
                    170.0,
                    math.min(240.0, contentMaxWidth * 0.68),
                  );
                  final bottomInset = math.max(
                    160.0,
                    constraints.maxHeight * 0.24,
                  );

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, bottomInset),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: contentMaxWidth,
                          minHeight: math.max(
                            0.0,
                            constraints.maxHeight - bottomInset - 16,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBrandHeader(theme, contentMaxWidth),
                            const SizedBox(height: 20),
                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildGlossyField(
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1D2837),
                                          ),
                                      decoration: _buildGlossyInputDecoration(
                                        hintText: 'Email Address',
                                        prefixIcon: const Icon(
                                          Icons.alternate_email_rounded,
                                          size: 20,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildGlossyField(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleLogin(),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1D2837),
                                          ),
                                      decoration: _buildGlossyInputDecoration(
                                        hintText: 'Password',
                                        prefixIcon: const Icon(
                                          Icons.lock_person_outlined,
                                          size: 20,
                                          color: Color(0xFF64748B),
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_rounded
                                                  : Icons
                                                        .visibility_off_rounded,
                                              size: 20,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (_errorMessage != null)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorScheme.error
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            color: theme.colorScheme.error,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: TextStyle(
                                                color: theme.colorScheme.error,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Align(
                                    child: SizedBox(
                                      width: loginButtonWidth,
                                      child: CustomButton(
                                        label: 'LOGIN',
                                        isLoading:
                                            _isLoading || _isBiometricLoading,
                                        onPressed: _isBiometricLoading
                                            ? null
                                            : _handleLogin,
                                        height: 50,
                                        icon: Icons.arrow_forward_rounded,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomOffset = (constraints.maxHeight * 0.05)
                    .clamp(24.0, 48.0)
                    .toDouble();
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomOffset),
                    child: _buildBiometricIcon(theme),
                  ),
                );
              },
            ),
          ),
          if (_appVersion.isNotEmpty)
            Positioned(
              bottom: 8.0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _appVersion,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 12.0,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
