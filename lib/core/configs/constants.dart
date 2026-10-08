import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppConstants {
  static const String appName = 'StaffPulse';
  static const String appTitleFa = 'سامانه هوشمند پرسنل و مرخصی استاف‌پالس';

  // Base API configuration
  static String get apiBaseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    // Default fallback based on platform
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      return 'http://127.0.0.1:8000/api/v1';
    }
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String storageTokenKey = 'staffpulse_access_token';
  static const String storageUserKey = 'staffpulse_user_session';
  static const String storageThemeKey = 'staffpulse_app_theme';
  static const String storageRememberMeKey = 'staffpulse_remember_me';
  static const String storageSavedUsernameKey = 'staffpulse_saved_username';
  static const String storageSavedPasswordKey = 'staffpulse_saved_password';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String meEndpoint = '/auth/me';
  static const String leaveSubmitEndpoint = '/leave/submit';
  static const String leaveSubmitStreamEndpoint = '/leave/submit-stream';
  static const String pendingTasksEndpoint = '/leave/tasks/pending';
}
