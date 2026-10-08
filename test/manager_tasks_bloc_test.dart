import 'package:flutter_test/flutter_test.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_request_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_stream_event_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_task_serializer.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_bloc.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_event.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_state.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

class MockLeaveRepository implements ILeaveRepository {
  List<LeaveTaskSerializer> mockTasks = [];
  bool shouldFailTasks = false;
  bool shouldFailAction = false;
  bool actionCalled = false;

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
  Future<DataState<List<LeaveTaskSerializer>>> getPendingTasks({String? group}) async {
    if (shouldFailTasks) {
      return const DataFailed('خطای سرور در بازیابی تسک‌ها', 500);
    }
    return DataSuccess<List<LeaveTaskSerializer>>(mockTasks);
  }

  @override
  Future<DataState<Map<String, dynamic>>> executeTaskAction({
    required String taskId,
    required bool approved,
    String? comment,
  }) async {
    actionCalled = true;
    if (shouldFailAction) {
      return const DataFailed('خطای پردازش اقدام تسک', 400);
    }
    return DataSuccess<Map<String, dynamic>>({
      'status': approved ? 'approved' : 'rejected',
      'message': approved ? 'تسک تایید شد' : 'تسک رد شد',
    });
  }

  @override
  Future<DataState<List<LeaveRequestSerializer>>> getEmployeeLeaveRequests(String employeeCode) async =>
      const DataFailed('Not implemented');

  @override
  Future<DataState<EmployeeSerializer>> getEmployeeLeaveProfile(String employeeCode) async =>
      const DataFailed('Not implemented');

  @override
  Future<DataState<Map<String, dynamic>>> cancelLeaveRequest(int id) async =>
      const DataFailed('Not implemented');

  @override
  Future<DataState<List<int>>> getProcessDiagramBytes(String processInstanceId) async =>
      const DataFailed('Not implemented');
}

void main() {
  group('ManagerTasksBloc Tests', () {
    late MockLeaveRepository mockRepo;
    late GlobalController globalController;
    late ManagerTasksBloc bloc;

    final dummyTask1 = LeaveTaskSerializer(
      taskId: 'task-101',
      taskName: 'تایید مدیر فنی',
      processInstanceId: 'proc-101',
      employeeCode: 'EMP-2002',
      department: 'مهندسی',
      leaveType: 'استحقاقی',
      durationDays: 3,
      requiresMedicalCertificate: false,
      aiRiskScore: 0.35,
      aiRecommendation: 'UNIT_MANAGER_REVIEW',
    );

    final dummyTaskSelf = LeaveTaskSerializer(
      taskId: 'task-102',
      taskName: 'تایید مدیر',
      processInstanceId: 'proc-102',
      employeeCode: 'MGR-1001', // Same as current user
      department: 'فناوری اطلاعات',
      leaveType: 'استحقاقی',
      durationDays: 2,
      requiresMedicalCertificate: false,
      aiRiskScore: 0.2,
      aiRecommendation: 'AUTO_APPROVE',
    );

    setUp(() {
      mockRepo = MockLeaveRepository();
      globalController = GlobalController();
      globalController.setCurrentUser(const UserUiModel(
        username: 'manager_ali',
        employeeCode: 'MGR-1001',
        role: 'MANAGER',
        roleTitleFa: 'مدیر دپارتمان',
        token: 'fake-token',
        isAdmin: false,
        isManager: true,
        isHr: false,
        isExecutive: false,
      ));

      bloc = ManagerTasksBloc(
        leaveRepository: mockRepo,
        globalController: globalController,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is ManagerTasksInitialState', () {
      expect(bloc.state, equals(const ManagerTasksInitialState()));
    });

    test('FetchPendingTasksEvent emits loading and loaded on success', () async {
      mockRepo.mockTasks = [dummyTask1];

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const ManagerTasksLoadingState(),
          ManagerTasksLoadedState(
            allTasks: [dummyTask1],
            filteredTasks: [dummyTask1],
          ),
        ]),
      );

      bloc.add(const FetchPendingTasksEvent());
      await expectation;
    });

    test('FetchPendingTasksEvent emits loading and error on failure', () async {
      mockRepo.shouldFailTasks = true;

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const ManagerTasksLoadingState(),
          const ManagerTasksErrorState('خطای سرور در بازیابی تسک‌ها'),
        ]),
      );

      bloc.add(const FetchPendingTasksEvent());
      await expectation;
    });

    test('ProcessTaskDecisionEvent enforces Anti-Self-Approval Guard (Rule 3.B)', () async {
      mockRepo.mockTasks = [dummyTaskSelf];

      // First load tasks
      bloc.add(const FetchPendingTasksEvent());
      await pumpEventQueue();

      final expectation = expectLater(
        bloc.stream,
        emits(const ManagerTasksErrorState(
          'تایید یا رد درخواست مرخصی توسط خود متقاضی (Anti-Self-Approval) اکیداً ممنوع است.',
        )),
      );

      // Attempt self-approval
      bloc.add(ProcessTaskDecisionEvent(
        taskId: 'task-102',
        approved: true,
        applicantEmployeeCode: 'MGR-1001', // Same as logged in manager
      ));

      await expectation;
      expect(mockRepo.actionCalled, isFalse); // Repository was NOT touched
    });

    test('ProcessTaskDecisionEvent successfully approves other employee request', () async {
      mockRepo.mockTasks = [dummyTask1];

      // First load tasks
      bloc.add(const FetchPendingTasksEvent());
      await pumpEventQueue();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ManagerTasksLoadedState>().having((s) => s.processingTaskId, 'processing', 'task-101'),
          isA<ManagerTasksActionSuccessState>()
              .having((s) => s.approved, 'approved', true)
              .having((s) => s.taskId, 'taskId', 'task-101'),
          isA<ManagerTasksLoadedState>().having((s) => s.allTasks.isEmpty, 'allTasks empty', true),
        ]),
      );

      bloc.add(const ProcessTaskDecisionEvent(
        taskId: 'task-101',
        approved: true,
        applicantEmployeeCode: 'EMP-2002', // Another employee
        comment: 'موافقت شد',
      ));

      await expectation;
      expect(mockRepo.actionCalled, isTrue);
    });

    test('SearchFilterTasksEvent filters tasks by query', () async {
      mockRepo.mockTasks = [dummyTask1, dummyTaskSelf];

      bloc.add(const FetchPendingTasksEvent());
      await pumpEventQueue();

      bloc.add(const SearchFilterTasksEvent('مهندسی'));
      await pumpEventQueue();

      final state = bloc.state as ManagerTasksLoadedState;
      expect(state.filteredTasks.length, equals(1));
      expect(state.filteredTasks.first.department, equals('مهندسی'));
    });
  });
}
