import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/widget/components/custom_orb_button.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_submit_state.dart';

class RagThinkingSheet extends StatelessWidget {
  final LeaveSubmitState state;
  final VoidCallback onDismiss;

  const RagThinkingSheet({
    super.key,
    required this.state,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = state.completedEvent != null;
    final isError = state.errorMessage != null;
    final isAutoApproved = state.isAutoApproved;

    Color accentColor = const Color(0xFF0A84FF);
    if (isAutoApproved) {
      accentColor = const Color(0xFF30D158);
    } else if (isError) {
      accentColor = const Color(0xFFFF453A);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xEB0B0E14),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.18),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Thinking Orb Card
            LiquidGlassLens(
              style: LiquidGlassStyle(
                shape: const LiquidGlassShape.continuousRoundedRectangle(
                  cornerRadius: 45,
                ),
                appearance: LiquidGlassAppearance(
                  color: accentColor.withValues(alpha: 0.15),
                ),
                refraction: const LiquidGlassRefraction(distortion: 0.08),
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: ThinkingOrb(
                    state: state.orbState,
                    size: 56,
                    color: Colors.white,
                    speed: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Step Title
            Text(
              isDone
                  ? (isAutoApproved ? 'تایید آنی هوشمند (Fast-Track)' : 'ثبت در کارتابل سازمانی')
                  : isError
                      ? 'خطا در ارزیابی درخواست'
                      : 'ایجنت هوش مصنوعی در حال تفکر است...',
              style: TextStyle(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Status Description
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                state.statusText,
                key: ValueKey(state.statusText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Progress Bar (when thinking)
            if (state.isThinking) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Completed Outcome Card
            if (isDone && state.completedEvent != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAutoApproved
                              ? Icons.verified_rounded
                              : Icons.schedule_rounded,
                          color: accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAutoApproved
                                ? 'شاخص ریسک: ${state.completedEvent!.aiRiskScore ?? 0.1} (مجاز برای تایید آنی)'
                                : 'شاخص ریسک: ${state.completedEvent!.aiRiskScore ?? 0.4} (ارجاع به مدیر واحد)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.completedEvent!.aiReasoning != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.completedEvent!.aiReasoning!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomOrbButton(
                text: 'متوجه شدم (بازگشت)',
                glassColor: accentColor.withValues(alpha: 0.4),
                onPressed: onDismiss,
              ),
            ],

            // Error Outcome
            if (isError) ...[
              const SizedBox(height: 16),
              CustomOrbButton(
                text: 'بستن و ویرایش درخواست',
                glassColor: const Color(0x66FF453A),
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
