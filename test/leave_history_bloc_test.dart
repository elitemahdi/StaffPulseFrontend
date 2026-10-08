import 'package:flutter_test/flutter_test.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_request_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_stream_event_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_task_serializer.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_bloc.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_event.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_state.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

class MockLeaveHistoryRepository implements ILeaveRepository {
  List<LeaveRequestSerializer> mockRequests = [];
  EmployeeSerializer? mockProfile;
  bool shouldFailRequests = false;
  bool shouldFailCancel = false;

  @override
  Stream<LeaveStreamEventSerializer> submitLeaveRequestStream({
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    String? employeeCode,
  }) async* {}

  @override
  Future<DataState<LeaveRequestSerializer>> submitLeaveRequest({
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    String? employeeCode,
  }) async =>
      const DataFailed('Not implemented');

  @override
  Future<DataState<List<LeaveTaskSerializer>>> getPendingTasks({String? group}) async =>
      const DataFailed('Not implemented');

  @override
  Future<DataState<Map<String, dynamic>>> executeTaskAction({
    required String taskId,
    required bool approved,
    String? comment,
  }) async =>
      const DataFailed('Not implemented');

  @override
  Future<DataState<List<LeaveRequestSerializer>>> getEmployeeLeaveRequests(String employeeCode) async {
    if (shouldFailRequests) {
      return const DataFailed('خطای سرور در بازیابی سوابق', 500);
    }
    return DataSuccess<List<LeaveRequestSerializer>>(mockRequests);
  }

  @override
  Future<DataState<EmployeeSerializer>> getEmployeeLeaveProfile(String employeeCode) async {
    if (mockProfile != null) {
      return DataSuccess<EmployeeSerializer>(mockProfile!);
    }
    return const DataFailed('پروفایل یافت نشد');
  }

  @override
  Future<DataState<Map<String, dynamic>>> cancelLeaveRequest(int id) async {
    if (shouldFailCancel) {
      return const DataFailed('خطا در لغو درخواست', 400);
    }
    return DataSuccess<Map<String, dynamic>>({
      'status': 'cancelled',
      'message': 'درخواست با موفقیت لغو شد',
      'request_id': id,
    });
  }

  @override
  Future<DataState<List<int>>> getProcessDiagramBytes(String processInstanceId) async =>
      const DataFailed('Not implemented');
}

void main() {
  group('LeaveHistoryBloc Tests', () {
    late MockLeaveHistoryRepository mockRepo;
    late GlobalController globalController;
    late LeaveHistoryBloc bloc;

    final dummyProfile = const EmployeeSerializer(
      id: 1,
      employeeCode: 'EMP-1001',
      firstName: 'محمد',
      lastName: 'رضایی',
      department: 'فناوری اطلاعات',
      sickLeaveBalance: 28,
      annualLeaveBalance: 22,
    );

    final dummyPending = const LeaveRequestSerializer(
      id: 501,
      employeeCode: 'EMP-1001',
      processInstanceId: 'proc-501',
      leaveType: 'استحقاقی',
      durationDays: 2,
      requiresMedicalCertificate: false,
      requiresSeniorApproval: false,
      currentStep: 'PENDING_MANAGER',
      status: 'PENDING',
      aiRiskScore: 0.25,
      aiRecommendation: 'UNIT_MANAGER_REVIEW',
    );

    final dummyApproved = const LeaveRequestSerializer(
      id: 502,
      employeeCode: 'EMP-1001',
      processInstanceId: 'proc-502',
      leaveType: 'استعلاجی',
      durationDays: 1,
      requiresMedicalCertificate: true,
      requiresSeniorApproval: false,
      currentStep: 'COMPLETED',
      status: 'APPROVED',
      aiRiskScore: 0.1,
      aiRecommendation: 'AUTO_APPROVE',
    );

    setUp(() {
      mockRepo = MockLeaveHistoryRepository();
      mockRepo.mockProfile = dummyProfile;
      mockRepo.mockRequests = [dummyPending, dummyApproved];

      globalController = GlobalController();
      globalController.setCurrentUser(const UserUiModel(
        username: 'emp_rezaei',
        employeeCode: 'EMP-1001',
        role: 'EMPLOYEE',
        roleTitleFa: 'کارشناس',
        token: 'fake-token',
        isAdmin: false,
        isManager: false,
        isHr: false,
        isExecutive: false,
      ));

      bloc = LeaveHistoryBloc(
        leaveRepository: mockRepo,
        globalController: globalController,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is LeaveHistoryInitialState', () {
      expect(bloc.state, equals(const LeaveHistoryInitialState()));
    });

    test('FetchLeaveHistoryEvent emits loading and loaded on success', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const LeaveHistoryLoadingState(),
          LeaveHistoryLoadedState(
            allRequests: [dummyPending, dummyApproved],
            filteredRequests: [dummyPending, dummyApproved],
            profile: dummyProfile,
            selectedStatus: 'ALL',
          ),
        ]),
      );

      bloc.add(const FetchLeaveHistoryEvent());
      await expectation;
    });

    test('CancelLeaveRequestEvent cancels pending request and updates state', () async {
      // First load
      bloc.add(const FetchLeaveHistoryEvent());
      await pumpEventQueue();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LeaveHistoryLoadedState>().having((s) => s.cancellingRequestId, 'cancelling', 501),
          isA<LeaveHistoryActionSuccessState>().having((s) => s.requestId, 'requestId', 501),
          isA<LeaveHistoryLoadedState>().having(
            (s) => s.allRequests.firstWhere((r) => r.id == 501).status,
            'status cancelled',
            'CANCELLED',
          ),
        ]),
      );

      bloc.add(const CancelLeaveRequestEvent(requestId: 501));
      await expectation;
    });

    test('FilterHistoryStatusEvent filters by status correctly', () async {
      bloc.add(const FetchLeaveHistoryEvent());
      await pumpEventQueue();

      bloc.add(const FilterHistoryStatusEvent('APPROVED'));
      await pumpEventQueue();

      final state = bloc.state as LeaveHistoryLoadedState;
      expect(state.selectedStatus, equals('APPROVED'));
      expect(state.filteredRequests.length, equals(1));
      expect(state.filteredRequests.first.id, equals(502));
    });
  });
}
