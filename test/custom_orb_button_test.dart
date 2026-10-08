import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/widget/components/custom_orb_button.dart';

void main() {
  group('CustomOrbButton Component Tests', () {
    testWidgets('Renders idle state with text and handles tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOrbButton(
              text: 'ورود به سامانه',
              pauseOrb: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('ورود به سامانه'), findsOneWidget);
      expect(find.byType(ThinkingOrb), findsNothing);

      await tester.tap(find.text('ورود به سامانه'));
      expect(tapped, isTrue);
    });

    testWidgets('Renders loading state with ThinkingOrb and loadingText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomOrbButton(
              text: 'ورود به سامانه',
              isLoading: true,
              loadingText: 'در حال بررسی هویت...',
              orbState: OrbState.working,
              pauseOrb: true,
            ),
          ),
        ),
      );

      expect(find.text('در حال بررسی هویت...'), findsOneWidget);
      expect(find.byType(ThinkingOrb), findsOneWidget);
    });

    testWidgets('Renders success state with successText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomOrbButton(
              text: 'ورود به سامانه',
              isSuccess: true,
              successText: 'خوش آمدید!',
              pauseOrb: true,
            ),
          ),
        ),
      );

      expect(find.text('خوش آمدید!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('Renders error state with errorText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomOrbButton(
              text: 'ورود به سامانه',
              isError: true,
              errorText: 'تلاش مجدد',
              pauseOrb: true,
            ),
          ),
        ),
      );

      expect(find.text('تلاش مجدد'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('Responds reactively to LoadingButtonController', (tester) async {
      final controller = LoadingButtonController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomOrbButton(
              controller: controller,
              text: 'ثبت',
              loadingText: 'در حال پردازش...',
              successText: 'انجام شد!',
              pauseOrb: true,
            ),
          ),
        ),
      );

      expect(find.text('ثبت'), findsOneWidget);

      // Start loading
      controller.start();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('در حال پردازش...'), findsOneWidget);
      expect(find.byType(ThinkingOrb), findsOneWidget);

      // Transition to success
      controller.success();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('انجام شد!'), findsOneWidget);

      controller.dispose();
    });
  });
}
