import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/theme.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';
import 'package:staffpulseapp/login/presentation/controller/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => locator<LoginBloc>(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final TextEditingController _usernameController = TextEditingController(text: 'admin');
  final TextEditingController _passwordController = TextEditingController(text: '123456');
  final LoadingButtonController _buttonController = LoadingButtonController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _fillCredentials(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  void _submitLogin(BuildContext context) {
    context.read<LoginBloc>().add(
          LoginSubmitted(
            username: _usernameController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktopOrWeb = screenSize.width > 600;

    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status is BlocStatusLoading) {
          _buttonController.start();
        } else if (state.status is BlocStatusCompleted) {
          _buttonController.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xE630D158),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'ورود موفقیت‌آمیز بود. در حال انتقال...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
          Future.delayed(const Duration(milliseconds: 700), () {
            if (context.mounted) {
              context.go('/home');
            }
          });
        } else if (state.status is BlocStatusError) {
          _buttonController.error();
        }
      },
      builder: (context, state) {
        final isLoading = state.status is BlocStatusLoading;
        final bloc = context.read<LoginBloc>();

        return Scaffold(
          body: LiquidGlassView(
            // Ambient glowing gradient backdrop for authentic Apple Liquid Glass refraction
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
                        maxWidth: isDesktopOrWeb ? 460 : screenSize.width,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Apple-Style Floating App Icon
                          _buildAppHeader(),
                          const SizedBox(height: 28),

                          // 2. Liquid Glass Login Card
                          LiquidGlassLens(
                            style: const LiquidGlassStyle(
                              shape: LiquidGlassShape.continuousRoundedRectangle(
                                cornerRadius: 28,
                              ),
                              appearance: LiquidGlassAppearance(
                                color: Color(0x1AFFFFFF),
                              ),
                              refraction: LiquidGlassRefraction(
                                distortion: 0.12,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppTheme.glassBorderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Card Title
                                  const Text(
                                    'ورود به حساب کاربری',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'نام کاربری و کلمه عبور سازمانی خود را وارد نمایید.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Error Banner (if any)
                                  if (state.status is BlocStatusError) ...[
                                    _buildErrorBanner(
                                      (state.status as BlocStatusError).message ?? 'خطا در احراز هویت',
                                    ),
                                    const SizedBox(height: 18),
                                  ],

                                  // Username Field
                                  _buildTextField(
                                    controller: _usernameController,
                                    label: 'نام کاربری',
                                    hint: 'مثال: admin یا ali.mohammadi',
                                    icon: Icons.person_outline_rounded,
                                    errorText: state.usernameError,
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: 16),

                                  // Password Field
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'کلمه عبور',
                                    hint: '••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: !state.isPasswordVisible,
                                    errorText: state.passwordError,
                                    enabled: !isLoading,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        state.isPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white.withValues(alpha: 0.6),
                                      ),
                                      onPressed: () {
                                        bloc.add(const LoginPasswordVisibilityToggled());
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 26),

                                  // Apple Liquid Glass Button with LoadingIndicator.orb
                                  LiquidGlassLens(
                                    style: const LiquidGlassStyle(
                                      shape: LiquidGlassShape.continuousRoundedRectangle(
                                        cornerRadius: 18,
                                      ),
                                      appearance: LiquidGlassAppearance(
                                        color: Color(0x550A84FF),
                                      ),
                                      refraction: LiquidGlassRefraction(distortion: 0.08),
                                    ),
                                    child: SizedBox(
                                      height: 52,
                                      child: LoadingButton(
                                        controller: _buttonController,
                                        type: ButtonType.elevated,
                                        indicator: const LoadingIndicator.orb(
                                          state: OrbState.working,
                                          speed: 1.2,
                                          color: Colors.white,
                                        ),
                                        loadingText: 'در حال بررسی هویت...',
                                        successText: 'خوش آمدید!',
                                        errorText: 'تلاش مجدد',
                                        buttonStyle: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        ),
                                        onPressed: () async {
                                          _submitLogin(context);
                                        },
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'ورود به سامانه',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_back_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. Quick Test Credentials Helper
                          _buildQuickFillSection(),
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

  /// Ambient mesh gradient with blurred glowing orbs for authentic VisionOS glass refraction
  Widget _buildAmbientBackdrop(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      color: AppTheme.darkBackground,
      child: Stack(
        children: [
          // Top-right glowing Electric Indigo orb
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x995E5CE6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom-left glowing Neon Cyan orb
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x800A84FF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Center-left Magenta orb
          Positioned(
            top: size.height * 0.4,
            left: size.width * 0.1,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x55BF5AF2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Soft backdrop blur pass to blend colors smoothly
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        // VisionOS-style Glass App Badge
        LiquidGlassLens(
          style: const LiquidGlassStyle(
            shape: LiquidGlassShape.continuousRoundedRectangle(cornerRadius: 22),
            appearance: LiquidGlassAppearance(
              color: Color(0x330A84FF),
            ),
            refraction: LiquidGlassRefraction(distortion: 0.1),
          ),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.glassHighlightColor, width: 1.2),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'StaffPulse',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'مدیریت هوشمند پرسنل و گردش کار BPMN',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x33FF453A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x66FF453A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.appleRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFFD2CF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFillSection() {
    return Column(
      children: [
        Text(
          'تکمیل سریع اطلاعات تست (کلمه عبور همه: 123456)',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildRoleChip(label: 'ادمین سیستم (admin)', user: 'admin'),
            _buildRoleChip(label: 'مدیر IT (mgr.rezaei)', user: 'mgr.rezaei'),
            _buildRoleChip(label: 'منابع انسانی (hr.moradi)', user: 'hr.moradi'),
            _buildRoleChip(label: 'کارمند (ali.mohammadi)', user: 'ali.mohammadi'),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip({required String label, required String user}) {
    return InkWell(
      onTap: () => _fillCredentials(user, '123456'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
