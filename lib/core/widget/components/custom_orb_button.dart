import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/services/theme.dart';

/// Typedef alias so both [CustomOrbButton] and [OrbLoadingButton] are available.
typedef OrbLoadingButton = CustomOrbButton;

/// A premium Apple Liquid Glass button integrated with the [ThinkingOrb]
/// animation indicator from `loading_icon_button`.
///
/// Designed for StaffPulse AI orchestration, this button supports:
/// - 9 distinct AI thinking orb states ([OrbState.working], [OrbState.searching], etc.)
/// - Real-time state drive via [LoadingButtonController] or direct boolean flags ([isLoading])
/// - Authentic VisionOS / macOS Liquid Glass refraction & specular highlights
/// - Interactive spring tactile touch scale & subtle haptic feedback
/// - Seamless animated transitions between idle, loading, success, and error phases.
class CustomOrbButton extends StatefulWidget {
  const CustomOrbButton({
    super.key,
    required this.text,
    this.onPressed,
    this.controller,
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.loadingText,
    this.successText,
    this.errorText,
    this.orbState = OrbState.working,
    this.orbSize = 20.0,
    this.orbColor = Colors.white,
    this.orbSpeed = 1.2,
    this.orbTheme = OrbTheme.auto,
    this.pauseOrb = false,
    this.icon,
    this.trailingIcon,
    this.height = 52.0,
    this.width,
    this.borderRadius = 18.0,
    this.glassColor = const Color(0x550A84FF),
    this.borderColor,
    this.textStyle,
    this.enabled = true,
  });

  /// Main label displayed in idle state.
  final String text;

  /// Callback when pressed. If null or [enabled] is false or loading, button is disabled.
  final VoidCallback? onPressed;

  /// Optional controller from `loading_icon_button` to drive idle/loading/success/error.
  final LoadingButtonController? controller;

  /// Direct flag to trigger loading state when not using a controller.
  final bool isLoading;

  /// Direct flag to trigger success state when not using a controller.
  final bool isSuccess;

  /// Direct flag to trigger error state when not using a controller.
  final bool isError;

  /// Text displayed alongside the orb during the loading phase.
  final String? loadingText;

  /// Text displayed during the success phase.
  final String? successText;

  /// Text displayed during the error phase.
  final String? errorText;

  /// Which of the 9 thinking orb states to render (default: [OrbState.working]).
  final OrbState orbState;

  /// Diameter of the thinking orb (default: 20px for tuned inline tier).
  final double orbSize;

  /// Orb color tint (defaults to white).
  final Color? orbColor;

  /// Orb rotation speed multiplier (default: 1.2).
  final double orbSpeed;

  /// Ambient brightness theme for the orb ink.
  final OrbTheme orbTheme;

  /// Whether to freeze orb animation (useful in automated widget tests).
  final bool pauseOrb;

  /// Optional leading icon (or trailing in RTL) for the idle state.
  final Widget? icon;

  /// Optional trailing icon for the idle state.
  final Widget? trailingIcon;

  /// Height of the button (default: 52px).
  final double height;

  /// Width of the button (default: fills available width if null).
  final double? width;

  /// Corner radius for the continuous rounded rectangle lens.
  final double borderRadius;

  /// Glass base tint (default: Apple iOS vibrant blue glass `Color(0x550A84FF)`).
  final Color glassColor;

  /// Glass outline border color.
  final Color? borderColor;

  /// Custom typography style for the button text.
  final TextStyle? textStyle;

  /// Whether the button is interactable.
  final bool enabled;

  @override
  State<CustomOrbButton> createState() => _CustomOrbButtonState();
}

class _CustomOrbButtonState extends State<CustomOrbButton> {
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomOrbButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isCurrentlyLoading {
    if (widget.controller != null) {
      return widget.controller!.state == ActionState.loading;
    }
    return widget.isLoading;
  }

  bool get _isCurrentlySuccess {
    if (widget.controller != null) {
      return widget.controller!.state == ActionState.success;
    }
    return widget.isSuccess;
  }

  bool get _isCurrentlyError {
    if (widget.controller != null) {
      return widget.controller!.state == ActionState.error;
    }
    return widget.isError;
  }

  bool get _canInteract =>
      widget.enabled &&
      !_isCurrentlyLoading &&
      widget.onPressed != null;

  void _handleTap() {
    if (!_canInteract) return;
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic glass tint based on active state
    Color activeGlassColor = widget.glassColor;
    if (_isCurrentlySuccess) {
      activeGlassColor = const Color(0x6630D158); // Apple Success Green
    } else if (_isCurrentlyError) {
      activeGlassColor = const Color(0x66FF453A); // Apple Destructive Red
    }

    final effectiveTextStyle = widget.textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        );

    final resolvedBorderColor = widget.borderColor ??
        (_isCurrentlySuccess
            ? const Color(0x8030D158)
            : _isCurrentlyError
                ? const Color(0x80FF453A)
                : AppTheme.glassBorderColor);

    return AnimatedScale(
      scale: _isPressed && _canInteract ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: LiquidGlassLens(
        style: LiquidGlassStyle(
          shape: LiquidGlassShape.continuousRoundedRectangle(
            cornerRadius: widget.borderRadius,
          ),
          appearance: LiquidGlassAppearance(
            color: activeGlassColor,
          ),
          refraction: const LiquidGlassRefraction(
            distortion: 0.08,
          ),
        ),
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: resolvedBorderColor,
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              onTapDown: _canInteract ? (_) => setState(() => _isPressed = true) : null,
              onTapUp: _canInteract ? (_) => setState(() => _isPressed = false) : null,
              onTapCancel: _canInteract ? () => setState(() => _isPressed = false) : null,
              onTap: _canInteract ? _handleTap : null,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _buildButtonContent(effectiveTextStyle),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    // 1. Loading Phase: Render ThinkingOrb with optional loading text
    if (_isCurrentlyLoading) {
      return Row(
        key: const ValueKey('orb_loading_state'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThinkingOrb(
            state: widget.orbState,
            size: widget.orbSize,
            color: widget.orbColor,
            speed: widget.orbSpeed,
            theme: widget.orbTheme,
            paused: widget.pauseOrb,
          ),
          if (widget.loadingText != null && widget.loadingText!.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              widget.loadingText!,
              style: textStyle.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    }

    // 2. Success Phase
    if (_isCurrentlySuccess) {
      return Row(
        key: const ValueKey('orb_success_state'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.successText ?? 'عملیات موفق',
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    // 3. Error Phase
    if (_isCurrentlyError) {
      return Row(
        key: const ValueKey('orb_error_state'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.errorText ?? 'خطا - تلاش مجدد',
            style: textStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    // 4. Idle Resting Phase
    return Row(
      key: const ValueKey('orb_idle_state'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: textStyle.copyWith(
            color: widget.enabled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          widget.trailingIcon!,
        ],
      ],
    );
  }
}
