import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration? duration,
  }) {
    _remove();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }
    final theme = Theme.of(context);
    final toastDuration = duration ?? _defaultDuration(type);

    _entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, type: type, theme: theme),
    );

    overlay.insert(_entry!);

    Future.delayed(toastDuration, _remove);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }

  static void _remove() {
    _entry?.remove();
    _entry = null;
  }

  static Duration _defaultDuration(ToastType type) {
    switch (type) {
      case ToastType.error:
        return const Duration(seconds: 5);
      case ToastType.warning:
        return const Duration(seconds: 4);
      default:
        return const Duration(seconds: 2);
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ThemeData theme;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.theme,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.width(context) > 600;

    return Positioned(
      top: isDesktop ? 24 : null,
      bottom: isDesktop ? null : 32,

      left: isDesktop ? null : 16,
      right: isDesktop
          ? 24
          : 16, // Ensure generic right padding on mobile too if not desktop
      child: SafeArea(
        child: Align(
          alignment: isDesktop
              ? Alignment.topRight
              : Alignment.bottomCenter, // Ensure alignment
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: _ToastContainer(
                message: widget.message,
                type: widget.type,
                theme: widget.theme,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastContainer extends StatelessWidget {
  final String message;
  final ToastType type;
  final ThemeData theme;

  const _ToastContainer({
    required this.message,
    required this.type,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final config = _ToastStyle.fromType(type, theme);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: config.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: config.border),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, color: config.iconColor),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: config.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToastStyle {
  final Color background;
  final Color border;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  _ToastStyle({
    required this.background,
    required this.border,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });

  static _ToastStyle fromType(ToastType type, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    switch (type) {
      case ToastType.success:
        return _ToastStyle(
          background: isDark ? AppColors.darkSuccessBg : AppColors.successBg,
          border: AppColors.success,
          textColor: AppColors.success,
          iconColor: AppColors.success,
          icon: Icons.check_circle,
        );
      case ToastType.error:
        return _ToastStyle(
          background:
              isDark ? AppColors.darkError.withValues(alpha: 0.2) : const Color(0xFFFDECEC),
          border: theme.colorScheme.error,
          textColor: theme.colorScheme.error,
          iconColor: theme.colorScheme.error,
          icon: Icons.error,
        );
      case ToastType.warning:
        return _ToastStyle(
          background:
              isDark ? AppColors.darkWarningBg : AppColors.warningBg,
          border: AppColors.warning,
          textColor: AppColors.warning,
          iconColor: AppColors.warning,
          icon: Icons.warning,
        );
      default:
        return _ToastStyle(
          background:
              isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surface,
          border: AppColors.info,
          textColor: theme.colorScheme.onSurface,
          iconColor: AppColors.info,
          icon: Icons.info,
        );
    }
  }
}

