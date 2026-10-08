import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staffpulseapp/core/configs/constants.dart';
import 'package:staffpulseapp/core/services/api_client.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/login/models/login_mapper.dart';
import 'package:staffpulseapp/core/model_serializer/login_response_serializer.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

abstract class IAuthRepository {
  Future<DataState<UserUiModel>> login({
    required String username,
    required String password,
  });
  Future<void> logout();
  Future<String?> getSavedToken();
}

class AuthRepository implements IAuthRepository {
  final ApiClient apiClient;
  final SharedPreferences prefs;
  final GlobalController globalController;

  AuthRepository({
    required this.apiClient,
    required this.prefs,
    required this.globalController,
  });

  @override
  Future<DataState<UserUiModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username.trim(),
          'password': password.trim(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> rawJson = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        // 1. Fill the API Model Serializer (DTO)
        final serializer = LoginResponseSerializer.fromJson(rawJson);

        // 2. Map to the clean UI Model
        final uiModel = serializer.toUiModel();

        // 3. Persist session
        await prefs.setString(AppConstants.storageTokenKey, uiModel.token);
        globalController.setCurrentUser(uiModel);

        return DataSuccess<UserUiModel>(uiModel);
      } else {
        return DataFailed<UserUiModel>(
          'پاسخ نامعتبر از سرور دریافت شد.',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message = ApiClient.formatDioError(e);
      return DataFailed<UserUiModel>(message, e.response?.statusCode);
    } catch (e) {
      return DataFailed<UserUiModel>('خطای غیرمنتظره: $e');
    }
  }

  @override
  Future<void> logout() async {
    await prefs.remove(AppConstants.storageTokenKey);
    globalController.reset();
  }

  @override
  Future<String?> getSavedToken() async {
    return prefs.getString(AppConstants.storageTokenKey);
  }
}
