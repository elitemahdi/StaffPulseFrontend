import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:staffpulseapp/core/configs/constants.dart';
import 'package:staffpulseapp/core/model_serializer/user_serializer.dart';
import 'package:staffpulseapp/core/services/api_client.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/services/storage_service.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/login/models/login_mapper.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

abstract class ISplashRepository {
  Future<bool> checkInternetConnection();
  Future<bool> checkServerConnection();
  String? getSavedToken();
  Future<DataState<UserUiModel>> validateTokenAndGetUser(String token);
  Future<void> clearSavedToken();
}

class SplashRepository implements ISplashRepository {
  final ApiClient apiClient;
  final IStorageService storageService;
  final GlobalController globalController;

  SplashRepository({
    required this.apiClient,
    required this.storageService,
    required this.globalController,
  });

  @override
  Future<bool> checkInternetConnection() async {
    if (kIsWeb) {
      // Browsers handle networking through fetch/XHR
      return true;
    }
    try {
      final lookup = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 4));
      if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      // Fallback probe
      try {
        final socket = await Socket.connect('8.8.8.8', 53,
            timeout: const Duration(seconds: 3));
        socket.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  @override
  Future<bool> checkServerConnection() async {
    try {
      // Probe backend to verify host and port are accepting HTTP requests
      final response = await apiClient.dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.loginEndpoint}',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode != null && response.statusCode! < 500;
    } catch (_) {
      // Try probing the docs / OpenAPI schema
      try {
        final docsUrl = AppConstants.apiBaseUrl.replaceAll('/api/v1', '/docs');
        final probe = await apiClient.dio.get(
          docsUrl,
          options: Options(
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        return probe.statusCode != null && probe.statusCode! < 500;
      } catch (_) {
        return false;
      }
    }
  }

  @override
  String? getSavedToken() {
    return storageService.getToken();
  }

  @override
  Future<void> clearSavedToken() async {
    await storageService.removeToken();
    globalController.reset();
  }

  @override
  Future<DataState<UserUiModel>> validateTokenAndGetUser(String token) async {
    try {
      final response = await apiClient.dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.meEndpoint}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> rawJson = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final userDto = UserSerializer.fromJson(rawJson);
        final uiModel = userDto.toUiModel(token: token);

        // Update session
        globalController.setCurrentUser(uiModel);
        return DataSuccess<UserUiModel>(uiModel);
      } else {
        return DataFailed<UserUiModel>(
          'توکن نامعتبر است یا نشست کاربری منقضی شده است.',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await clearSavedToken();
      }
      return DataFailed<UserUiModel>(
        ApiClient.formatDioError(e),
        e.response?.statusCode,
      );
    } catch (e) {
      return DataFailed<UserUiModel>('خطای غیرمنتظره در اعتبارسنجی توکن: $e');
    }
  }
}
