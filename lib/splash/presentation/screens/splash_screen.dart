import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/theme.dart';
import 'package:staffpulseapp/core/widget/components/custom_orb_button.dart';
import 'package:staffpulseapp/splash/presentation/controller/splash_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>(
      create: (_) => locator<SplashBloc>()..add(const SplashStarted()),
      child: const _SplashContent(),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return BlocConsumer<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state.step == SplashStep.authenticated) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (context.mounted) {
              context.go('/home');
            }
          });
        } else if (state.step == SplashStep.unauthenticated) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
      },
      builder: (context, state) {
        final bloc = context.read<SplashBloc>();

        return Scaffold(
          body: LiquidGlassView(
            backgroundWidget: _buildAmbientBackdrop(screenSize),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 440 : screenSize.width,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Futuristic App Logo & Emblem
                          _buildBrandHeader(),
                          const SizedBox(height: 36),

                          // 2. Liquid Glass Diagnostic Status Card
                          LiquidGlassLens(
                            style: const LiquidGlassStyle(
                              shape: LiquidGlassShape.continuousRoundedRectangle(
                                cornerRadius: 28,
                              ),
                              appearance: LiquidGlassAppearance(
                                color: Color(0x1AFFFFFF),
                              ),
                              refraction: LiquidGlassRefraction(distortion: 0.12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppTheme.glassBorderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Central Thinking Orb with animated state transitions
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0x140A84FF),
                                      border: Border.all(
                                        color: const Color(0x330A84FF),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: ThinkingOrb(
                                        state: state.orbState,
                                        size: 48,
                                        color: state.step == SplashStep.connectionError
                                            ? const Color(0xFFFF453A)
                                            : Colors.white,
                                        speed: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),

                                  // Status message text
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      state.statusText,
                                      key: ValueKey(state.statusText),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: state.step == SplashStep.connectionError
                                            ? const Color(0xFFFF453A)
                                            : Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),

                                  // Error explanation and actions
                                  if (state.step == SplashStep.connectionError) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0x22FF453A),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0x55FF453A),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.wifi_off_rounded,
                                            color: Color(0xFFFF453A),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              state.errorMessage ??
                                                  'خطا در برقراری ارتباط با شبکه یا سرور.',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.85),
                                                fontSize: 12.5,
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Retry Button
                                    CustomOrbButton(
                                      text: 'تلاش مجدد',
                                      icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                      orbState: OrbState.connecting,
                                      onPressed: () {
                                        bloc.add(const SplashRetryRequested());
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    // Skip to Login Button
                                    TextButton(
                                      onPressed: () {
                                        context.go('/login');
                                      },
                                      child: Text(
                                        'انتقال دستی به صفحه ورود',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.65),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Footer Version & Security label
                          Text(
                            'StaffPulse Enterprise v1.0.0 • AI-Orchestrated BPMN',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A84FF).withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.bubble_chart_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'استاف‌پالس | StaffPulse',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'سامانه هوشمند پرسنل، گردش‌کار و مرخصی',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAmbientBackdrop(Size screenSize) {
    return Stack(
      children: [
        // Solid deep obsidian canvas
        Container(color: const Color(0xFF0B0E14)),

        // Cyan-Blue dynamic orb
        Positioned(
          top: -80,
          left: -40,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A84FF).withValues(alpha: 0.32),
            ),
          ),
        ),

        // Purple-Indigo accent orb
        Positioned(
          bottom: -60,
          right: -50,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5E5CE6).withValues(alpha: 0.28),
            ),
          ),
        ),

        // Emerald subtle glow orb
        Positioned(
          top: screenSize.height * 0.4,
          right: -70,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF30D158).withValues(alpha: 0.16),
            ),
          ),
        ),

        // Optical frosted glass blur filter
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
