import 'package:flutter_test/flutter_test.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_request_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_stream_event_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_task_serializer.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_submit_bloc.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';

class MockLeaveRepository implements ILeaveRepository {
  List<LeaveStreamEventSerializer> mockEvents = [];

  @override
  Stream<LeaveStreamEventSerializer> submitLeaveRequestStream({
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    String? employeeCode,
  }) async* {
    for (final event in mockEvents) {
      yield event;
    }
  }

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
  group('LeaveSubmitBloc Unit Tests', () {
    late MockLeaveRepository mockRepo;
    late LeaveSubmitBloc bloc;

    setUp(() {
      mockRepo = MockLeaveRepository();
      bloc = LeaveSubmitBloc(leaveRepository: mockRepo);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is correct', () {
      expect(bloc.state.isAiMode, isTrue);
      expect(bloc.state.durationDays, 1);
      expect(bloc.state.leaveType, 'استحقاقی');
      expect(bloc.state.isThinking, isFalse);
    });

    test('LeaveModeToggled updates mode', () {
      bloc.add(const LeaveModeToggled(false));
      expectLater(
        bloc.stream,
        emits(predicate<LeaveSubmitState>((s) => s.isAiMode == false)),
      );
    });

    test('Emits error when AI mode input is empty', () async {
      final expectation = expectLater(
        bloc.stream,
        emits(predicate<LeaveSubmitState>((s) =>
            s.status is BlocStatusError &&
            s.errorMessage!.contains('متن درخواست'))),
      );
      bloc.add(const LeaveSubmitRequested());
      await expectation;
    });

    test('Streams real-time thinking events and reaches completed state', () async {
      mockRepo.mockEvents = [
        const LeaveStreamEventSerializer(
          step: 'rag_search',
          orbState: OrbState.searching,
          progress: 0.35,
          statusText: 'در حال جستجوی قوانین سازمانی...',
        ),
        const LeaveStreamEventSerializer(
          step: 'ai_audit',
          orbState: OrbState.connecting,
          progress: 0.70,
          statusText: 'در حال تطبیق با سیاست‌ها...',
        ),
        const LeaveStreamEventSerializer(
          step: 'completed',
          orbState: OrbState.working,
          progress: 1.0,
          statusText: 'تایید آنی Fast-Track',
          data: {
            'status': 'auto_approved',
            'ai_risk_score': 0.1,
            'ai_recommendation': 'AUTO_APPROVE',
            'ai_reasoning': 'منطبق بر ضوابط ۲ روزه',
          },
        ),
      ];

      bloc.add(const LeaveInputChanged(userInput: '۱ روز مرخصی استحقاقی'));
      await pumpEventQueue();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<LeaveSubmitState>((s) =>
              s.isThinking == true && s.orbState == OrbState.searching),
          predicate<LeaveSubmitState>((s) =>
              s.currentStep == 'rag_search' && s.progress == 0.35),
          predicate<LeaveSubmitState>((s) =>
              s.currentStep == 'ai_audit' && s.orbState == OrbState.connecting),
          predicate<LeaveSubmitState>((s) =>
              s.status is BlocStatusCompleted &&
              s.isAutoApproved == true &&
              s.completedEvent?.aiRiskScore == 0.1),
        ]),
      );

      bloc.add(const LeaveSubmitRequested());
      await expectation;
    });
  });
}
