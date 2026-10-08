import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/configs/constants.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_request_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_stream_event_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_task_serializer.dart';
import 'package:staffpulseapp/core/services/api_client.dart';
import 'package:staffpulseapp/core/services/storage_service.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';

abstract class ILeaveRepository {
  Stream<LeaveStreamEventSerializer> submitLeaveRequestStream({
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    String? employeeCode,
  });

  Future<DataState<LeaveRequestSerializer>> submitLeaveRequest({
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    String? employeeCode,
  });

  Future<DataState<List<LeaveTaskSerializer>>> getPendingTasks({String? group});

  Future<DataState<Map<String, dynamic>>> executeTaskAction({
    required String taskId,
    required bool approved,
    String? comment,
  });

  Future<DataState<List<LeaveRequestSerializer>>> getEmployeeLeaveRequests(String employeeCode);

  Future<DataState<EmployeeSerializer>> getEmployeeLeaveProfile(String employeeCode);

  Future<DataState<Map<String, dynamic>>> cancelLeaveRequest(int id);

  Future<DataState<List<int>>> getProcessDiagramBytes(String processInstanceId);
}

class LeaveRepository implements ILeaveRepository {
  final ApiClient apiClient;
  final IStorageService storageService;

  LeaveRepository({
    required this.apiClient,
    required this.storageService,
  });

  @override
  Stream<LeaveStreamEventSerializer> submitLeaveRequestStream({
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    String? employeeCode,
  }) async* {
    final payload = <String, dynamic>{};
    if (userInput != null && userInput.trim().isNotEmpty) {
      payload['user_input'] = userInput.trim();
    }
    if (leaveType != null && leaveType.isNotEmpty) {
      payload['leave_type'] = leaveType;
    }
    if (durationDays != null) {
      payload['duration_days'] = durationDays;
    }
    if (requiresMedicalCertificate != null) {
      payload['requires_medical_certificate'] = requiresMedicalCertificate;
    }
    if (employeeCode != null && employeeCode.isNotEmpty) {
      payload['employee_code'] = employeeCode;
    }

    final token = storageService.getToken();

    try {
      final response = await apiClient.dio.post<ResponseBody>(
        '${AppConstants.apiBaseUrl}${AppConstants.leaveSubmitStreamEndpoint}',
        data: payload,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        yield const LeaveStreamEventSerializer(
          step: 'error',
          orbState: OrbState.breathing,
          progress: 0.0,
          statusText: 'جریان داده‌های سرور برقرار نشد.',
          error: 'Empty response stream',
        );
        return;
      }

      await for (final line in stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.startsWith('data: ')) {
          final rawJson = line.substring(6).trim();
          if (rawJson.isNotEmpty) {
            try {
              final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
              yield LeaveStreamEventSerializer.fromJson(decoded);
            } catch (err) {
              // Ignore malformed heartbeats
            }
          }
        }
      }
    } on DioException catch (e) {
      yield LeaveStreamEventSerializer(
        step: 'error',
        orbState: OrbState.breathing,
        progress: 0.0,
        statusText: ApiClient.formatDioError(e),
        error: ApiClient.formatDioError(e),
      );
    } catch (e) {
      yield LeaveStreamEventSerializer(
        step: 'error',
        orbState: OrbState.breathing,
        progress: 0.0,
        statusText: 'خطای غیرمنتظره در ارتباط با سرور: $e',
        error: e.toString(),
      );
    }
  }

  @override
  Future<DataState<LeaveRequestSerializer>> submitLeaveRequest({
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    String? employeeCode,
  }) async {
    final payload = <String, dynamic>{};
    if (userInput != null) payload['user_input'] = userInput;
    if (leaveType != null) payload['leave_type'] = leaveType;
    if (durationDays != null) payload['duration_days'] = durationDays;
    if (requiresMedicalCertificate != null) {
      payload['requires_medical_certificate'] = requiresMedicalCertificate;
    }
    if (employeeCode != null) payload['employee_code'] = employeeCode;

    try {
      final response = await apiClient.post(
        AppConstants.leaveSubmitEndpoint,
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> rawJson = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return DataSuccess<LeaveRequestSerializer>(
          LeaveRequestSerializer.fromJson(rawJson),
        );
      }
      return DataFailed('پاسخ نامعتبر از سرور دریافت شد.', response.statusCode);
    } on DioException catch (e) {
      return DataFailed(ApiClient.formatDioError(e), e.response?.statusCode);
    } catch (e) {
      return DataFailed('خطای غیرمنتظره: $e');
    }
  }

  @override
  Future<DataState<List<LeaveTaskSerializer>>> getPendingTasks({String? group}) async {
    try {
      final response = await apiClient.get(
        AppConstants.pendingTasksEndpoint,
        queryParameters: group != null ? {'group': group} : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data as List : [];
        final tasks = list
            .map((item) => LeaveTaskSerializer.fromJson(
                  item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item as Map),
                ))
            .toList();
        return DataSuccess<List<LeaveTaskSerializer>>(tasks);
      }
      return DataFailed('خطا در دریافت تسک‌های کارتابل', response.statusCode);
    } on DioException catch (e) {
      return DataFailed(ApiClient.formatDioError(e), e.response?.statusCode);
    } catch (e) {
      return DataFailed('خطای غیرمنتظره: $e');
    }
  }

  @override
  Future<DataState<Map<String, dynamic>>> executeTaskAction({
    required String taskId,
    required bool approved,
    String? comment,
  }) async {
    try {
      final response = await apiClient.post(
        '/leave/tasks/$taskId/action',
        data: {
          'approved': approved,
          'comment': comment ?? (approved ? 'تایید شد' : 'رد شد'),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return DataSuccess<Map<String, dynamic>>(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return DataFailed('خطا در پردازش اقدام تسک', response.statusCode);
    } on DioException catch (e) {
      return DataFailed(ApiClient.formatDioError(e), e.response?.statusCode);
    } catch (e) {
      return DataFailed('خطای غیرمنتظره: $e');
    }
  }

  @override
  Future<DataState<List<LeaveRequestSerializer>>> getEmployeeLeaveRequests(String employeeCode) async {
    try {
      final response = await apiClient.get('/leave/employee/$employeeCode/requests');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data as List : [];
        final requests = list
            .map((item) => LeaveRequestSerializer.fromJson(
                  item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item as Map),
                ))
            .toList();
        return DataSuccess<List<LeaveRequestSerializer>>(requests);
      }
      return DataFailed('خطا در دریافت سوابق مرخصی', response.statusCode);
    } on DioException catch (e) {
      return DataFailed(ApiClient.formatDioError(e), e.response?.statusCode);
    } catch (e) {
      return DataFailed('خطای غیرمنتظره: $e');
    }
  }

  @override
  Future<DataState<EmployeeSerializer>> getEmployeeLeaveProfile(String employeeCode) async {
    try {
      final response = await apiClient.get('/leave/employee/$employeeCode/profile');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> rawJson = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return DataSuccess<EmployeeSerializer>(EmployeeSerializer.fromJson(rawJson));
      }
      return DataFailed('خطا در دریافت پروفایل پرسنلی', response.statusCode);
    } on DioException catch (e) {
      return DataFailed(ApiClient.formatDioError(e), e.response?.statusCode);
    } catch (e) {
      return DataFailed('خطای غیرمنتظره: $e');
    }
  }

  @override
  Future<DataState<Map<String, dynamic>>> cancelLeaveRequest(int id) async {
    try {
      final response = await apiClient.post('/leave/employee/requests/$id/cancel');
      if (response.statusCode == 200 && response.data != null) {
        return DataSuccess<Map<String, dynamic>>(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return DataFailed('خطا در لغو درخواست مرخصی', response.statusCode);
    } on DioException catch (e) {
      return DataFailed(ApiClient.formatDioError(e), e.response?.statusCode);
    } catch (e) {
      return DataFailed('خطای غیرمنتظره: $e');
    }
  }

  @override
  Future<DataState<List<int>>> getProcessDiagramBytes(String processInstanceId) async {
    try {
      final response = await apiClient.dio.get<List<int>>(
        '${AppConstants.apiBaseUrl}/leave/process-instances/$processInstanceId/diagram',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            if (storageService.getToken() != null)
              'Authorization': 'Bearer ${storageService.getToken()}',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return DataSuccess<List<int>>(response.data!);
      }
      return DataFailed('تصویر گردش کار یافت نشد.', response.statusCode);
    } on DioException catch (e) {
      return DataFailed(ApiClient.formatDioError(e), e.response?.statusCode);
    } catch (e) {
      return DataFailed('خطای غیرمنتظره: $e');
    }
  }
}
