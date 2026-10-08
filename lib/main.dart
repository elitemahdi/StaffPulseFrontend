import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/router.dart';
import 'package:staffpulseapp/core/services/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables if available
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Falls back to AppConstants defaults
  }

  // Setup service locator (GetIt, SharedPreferences, ApiClient, Repositories)
  await setupLocator();

  runApp(const StaffPulseApp());
}

class StaffPulseApp extends StatelessWidget {
  const StaffPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StaffPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
