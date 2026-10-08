import 'dart:ui';
import 'package:awesome_toast/awesome_toast.dart';
import 'package:flutter/material.dart';

/// Centralized Toast Notification service for StaffPulse using [awesome_toast].
///
/// Provides Apple Liquid Glass styled toast notifications with Persian (RTL) layout,
/// status halos, duration progress indicators, and dismiss capabilities.
class AppToast {
  AppToast._();

  /// Default configuration for [ToastProvider] in StaffPulse.
  static ToastStackConfig get stackConfig => ToastStackConfig(
        position: ToastPosition.topCenter,
        defaultDuration: const Duration(seconds: 4),
        stackThreshold: 3,
        showProgressByDefault: true,
        toastBuilder: _buildGlassToast,
      );

  /// Shows a success toast with Apple Emerald/Mint aesthetic.
  static void success(
    String message, {
    String title = 'عملیات موفق',
    Duration? duration,
  }) {
    ToastService.instance.success(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shows an error toast with Apple Coral/Ruby destructive aesthetic.
  static void error(
    String message, {
    String title = 'خطا در عملیات',
    Duration? duration,
  }) {
    ToastService.instance.error(
      title,
      message,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Shows a warning toast with Apple Amber aesthetic.
  static void warning(
    String message, {
    String title = 'توجه',
    Duration? duration,
  }) {
    ToastService.instance.warning(
      title,
      message,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Shows an informational toast with Apple Electric Blue aesthetic.
  static void info(
    String message, {
    String title = 'اطلاعیه',
    Duration? duration,
  }) {
    ToastService.instance.info(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Custom Liquid Glass builder rendering toasts with RTL Persian layout.
  static Widget _buildGlassToast(
    BuildContext context,
    String title,
    String message,
    ToastType type,
    ValueNotifier<double>? progress,
    VoidCallback? dismissToast,
    List<ToastAction>? actions,
    bool? dismissable,
    bool? showProgress,
  ) {
    Color accentColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        accentColor = const Color(0xFF30D158);
        iconData = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        accentColor = const Color(0xFFFF453A);
        iconData = Icons.error_rounded;
        break;
      case ToastType.warning:
        accentColor = const Color(0xFFFF9F0A);
        iconData = Icons.warning_amber_rounded;
        break;
      case ToastType.info:
      default:
        accentColor = const Color(0xFF0A84FF);
        iconData = Icons.info_rounded;
        break;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: const Color(0xCC161B26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      // Status Icon with subtle colored glowing halo
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title and Message
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              message,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dismiss Button
                      if (dismissable ?? true) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          onPressed: dismissToast,
                          splashRadius: 16,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Progress Indicator
                if (showProgress == true && progress != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: progress,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentColor.withValues(alpha: 0.7),
                          ),
                          minHeight: 2.5,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
