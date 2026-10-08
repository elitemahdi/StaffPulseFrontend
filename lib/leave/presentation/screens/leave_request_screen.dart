import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/services/app_toast.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/theme.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';
import 'package:staffpulseapp/core/widget/components/custom_orb_button.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_submit_bloc.dart';
import 'package:staffpulseapp/leave/presentation/widgets/rag_thinking_sheet.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaveSubmitBloc>(
      create: (_) => locator<LeaveSubmitBloc>(),
      child: const _LeaveRequestContent(),
    );
  }
}

class _LeaveRequestContent extends StatefulWidget {
  const _LeaveRequestContent();

  @override
  State<_LeaveRequestContent> createState() => _LeaveRequestContentState();
}

class _LeaveRequestContentState extends State<_LeaveRequestContent> {
  final TextEditingController _promptController = TextEditingController(
    text: 'سلام فردا به علت دندان‌درد شدید نیاز به ۱ روز مرخصی استعلاجی دارم.',
  );

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _showThinkingModal(BuildContext context, LeaveSubmitBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<LeaveSubmitBloc, LeaveSubmitState>(
            builder: (context, state) {
              return RagThinkingSheet(
                state: state,
                onDismiss: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return BlocConsumer<LeaveSubmitBloc, LeaveSubmitState>(
      listener: (context, state) {
        if (state.status is BlocStatusCompleted) {
          final isAuto = state.isAutoApproved;
          AppToast.success(
            isAuto
                ? 'درخواست مرخصی با موفقیت تایید خودکار شد!'
                : 'درخواست ثبت شد و به کارتابل مدیر ارسال گردید.',
            title: isAuto ? 'تایید آنی Fast-Track' : 'ثبت در کارتابل',
          );
        } else if (state.status is BlocStatusError) {
          final err = (state.status as BlocStatusError).message ?? 'خطا در ثبت درخواست';
          AppToast.error(err, title: 'خطا در درخواست');
        }
      },
      builder: (context, state) {
        final bloc = context.read<LeaveSubmitBloc>();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            title: const Text(
              'ثبت درخواست مرخصی هوشمند',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          extendBodyBehindAppBar: true,
          body: LiquidGlassView(
            backgroundWidget: _buildAmbientBackdrop(screenSize),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 540 : screenSize.width,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Mode Selector (AI vs Manual Form)
                          _buildModeSelector(bloc, state),
                          const SizedBox(height: 20),

                          // 2. Main Input Card
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
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppTheme.glassBorderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: state.isAiMode
                                  ? _buildAiInputSection(bloc, state)
                                  : _buildStructuredFormSection(bloc, state),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. Submit Button with CustomOrbButton
                          CustomOrbButton(
                            text: 'ارزیابی هوشمند و ثبت درخواست',
                            loadingText: 'در حال ارزیابی با هوش مصنوعی...',
                            orbState: OrbState.solving,
                            orbSize: 22,
                            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            onPressed: () {
                              if (state.isAiMode) {
                                bloc.add(LeaveInputChanged(userInput: _promptController.text));
                              }
                              bloc.add(const LeaveSubmitRequested());
                              _showThinkingModal(context, bloc);
                            },
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

  Widget _buildModeSelector(LeaveSubmitBloc bloc, LeaveSubmitState state) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => bloc.add(const LeaveModeToggled(true)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: state.isAiMode ? const Color(0xFF0A84FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      color: state.isAiMode ? Colors.white : Colors.white60,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ایجنت هوش مصنوعی (متن آزاد)',
                      style: TextStyle(
                        color: state.isAiMode ? Colors.white : Colors.white70,
                        fontWeight: state.isAiMode ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => bloc.add(const LeaveModeToggled(false)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !state.isAiMode ? const Color(0xFF0A84FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      color: !state.isAiMode ? Colors.white : Colors.white60,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'فرم ساختاریافته دستی',
                      style: TextStyle(
                        color: !state.isAiMode ? Colors.white : Colors.white70,
                        fontWeight: !state.isAiMode ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInputSection(LeaveSubmitBloc bloc, LeaveSubmitState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'توضیح آزاد به هوش مصنوعی (RAG)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'متن درخواست خود را بنویسید؛ ایجنت آیین‌نامه را بررسی و نوع مرخصی را استخراج می‌کند.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 18),

        // Text area
        TextField(
          controller: _promptController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'مثال: به علت مراسم خانوادگی فردا به ۲ روز مرخصی استحقاقی نیاز دارم...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Quick Suggestion Chips
        Text(
          'نمونه درخواست‌های آماده:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPromptChip('۱ روز استحقاقی جهت امور شخصی', bloc),
            _buildPromptChip('۱ روز استعلاجی به علت دندان‌درد', bloc),
            _buildPromptChip('۵ روز استحقاقی جهت مسافرت سالانه', bloc),
          ],
        ),
      ],
    );
  }

  Widget _buildPromptChip(String text, LeaveSubmitBloc bloc) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _promptController.text = text;
        });
        bloc.add(LeaveInputChanged(userInput: text));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0x1F0A84FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x330A84FF)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF90CAFF),
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStructuredFormSection(LeaveSubmitBloc bloc, LeaveSubmitState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'مشخصات مرخصی',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),

        // Leave Type Choice
        Row(
          children: [
            Expanded(
              child: _buildTypeRadio('استحقاقی', state.leaveType == 'استحقاقی', () {
                bloc.add(const LeaveInputChanged(leaveType: 'استحقاقی'));
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeRadio('استعلاجی', state.leaveType == 'استعلاجی', () {
                bloc.add(const LeaveInputChanged(
                  leaveType: 'استعلاجی',
                  requiresMedicalCertificate: true,
                ));
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Duration Stepper
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'مدت زمان مرخصی (روز):',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                  onPressed: state.durationDays > 1
                      ? () => bloc.add(LeaveInputChanged(durationDays: state.durationDays - 1))
                      : null,
                ),
                Text(
                  '${state.durationDays}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                  onPressed: state.durationDays < 15
                      ? () => bloc.add(LeaveInputChanged(durationDays: state.durationDays + 1))
                      : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Medical certificate checkbox
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'نیاز به ارائه و تایید گواهی پزشکی دارد',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          value: state.requiresMedicalCertificate,
          activeColor: const Color(0xFF0A84FF),
          onChanged: (val) {
            bloc.add(LeaveInputChanged(requiresMedicalCertificate: val ?? false));
          },
        ),
      ],
    );
  }

  Widget _buildTypeRadio(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x330A84FF) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0A84FF) : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientBackdrop(Size screenSize) {
    return Stack(
      children: [
        Container(color: const Color(0xFF0B0E14)),
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A84FF).withValues(alpha: 0.28),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: -40,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5E5CE6).withValues(alpha: 0.24),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
