import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:staffpulseapp/core/configs/constants.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/services/locator.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl}) {
    final effectiveBaseUrl = baseUrl ?? AppConstants.apiBaseUrl;

    dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Attach Interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach Bearer token from GlobalController if available
          try {
            if (locator.isRegistered<GlobalController>()) {
              final token = locator<GlobalController>().token;
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (_) {
            // Locator might not be ready yet
          }

          if (kDebugMode) {
            debugPrint('🌐 [DIO REQ] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('✅ [DIO RES ${response.statusCode}] ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint('❌ [DIO ERR ${error.response?.statusCode}] ${error.requestOptions.path}: ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Format Dio errors into friendly messages
  static String formatDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first.containsKey('msg')) {
            return first['msg'].toString();
          }
        }
      }
      switch (error.response?.statusCode) {
        case 400:
          return 'درخواست نامعتبر است (کد ۴۰۰)';
        case 401:
          return 'نام کاربری یا کلمه عبور اشتباه است (کد ۴۰۱)';
        case 403:
          return 'شما دسترسی لازم برای این عملیات را ندارید (کد ۴۰۳)';
        case 404:
          return 'آیتم مورد نظر یافت نشد (کد ۴۰۴)';
        case 422:
          return 'اطلاعات ارسالی نامعتبر است (کد ۴۲۲)';
        case 500:
          return 'خطای داخلی سرور رخ داد (کد ۵۰۰)';
        case 502:
          return 'خطا در ارتباط با موتور فرایند یا سرویس‌های پشتیبان (کد ۵۰۲)';
        default:
          return 'خطایی از سمت سرور رخ داد: ${error.response?.statusCode}';
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'مهلت زمانی اتصال به سرور به پایان رسید.';
      case DioExceptionType.connectionError:
        return 'اتصال به سرور برقرار نشد. لطفاً وضعیت شبکه یا اجرای بک‌اند را بررسی فرمایید.';
      case DioExceptionType.cancel:
        return 'درخواست توسط کاربر لغو گردید.';
      default:
        return error.message ?? 'خطای نامشخص در ارتباط با سرور';
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
