import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/model_serializer/leave_stream_event_serializer.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_submit_event.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_submit_state.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';

export 'leave_submit_event.dart';
export 'leave_submit_state.dart';

class LeaveSubmitBloc extends Bloc<LeaveSubmitEvent, LeaveSubmitState> {
  final ILeaveRepository leaveRepository;

  LeaveSubmitBloc({required this.leaveRepository})
      : super(const LeaveSubmitState()) {
    on<LeaveModeToggled>(_onModeToggled);
    on<LeaveInputChanged>(_onInputChanged);
    on<LeaveFormReset>(_onReset);
    on<LeaveSubmitRequested>(_onSubmitRequested);
  }

  void _onModeToggled(LeaveModeToggled event, Emitter<LeaveSubmitState> emit) {
    emit(state.copyWith(isAiMode: event.isAiMode));
  }

  void _onInputChanged(LeaveInputChanged event, Emitter<LeaveSubmitState> emit) {
    emit(state.copyWith(
      userInput: event.userInput ?? state.userInput,
      leaveType: event.leaveType ?? state.leaveType,
      durationDays: event.durationDays ?? state.durationDays,
      requiresMedicalCertificate: event.requiresMedicalCertificate ??
          state.requiresMedicalCertificate,
    ));
  }

  void _onReset(LeaveFormReset event, Emitter<LeaveSubmitState> emit) {
    emit(const LeaveSubmitState());
  }

  Future<void> _onSubmitRequested(
    LeaveSubmitRequested event,
    Emitter<LeaveSubmitState> emit,
  ) async {
    // 1. Validation
    if (state.isAiMode && state.userInput.trim().isEmpty) {
      emit(state.copyWith(
        status: const BlocStatusError(
          'لطفاً متن درخواست مرخصی خود را وارد نمایید.',
          400,
        ),
        errorMessage: 'لطفاً متن درخواست مرخصی خود را وارد نمایید.',
      ));
      return;
    }

    if (!state.isAiMode && state.durationDays <= 0) {
      emit(state.copyWith(
        status: const BlocStatusError(
          'تعداد روزهای مرخصی باید حداقل ۱ روز کاری باشد.',
          400,
        ),
        errorMessage: 'تعداد روزهای مرخصی باید حداقل ۱ روز کاری باشد.',
      ));
      return;
    }

    // 2. Start Thinking
    emit(state.copyWith(
      isThinking: true,
      currentStep: 'init',
      orbState: OrbState.searching,
      progress: 0.1,
      statusText: 'ارسال درخواست به ایجنت هوش مصنوعی...',
      status: const BlocStatusLoading(),
      errorMessage: null,
    ));

    // 3. Connect to SSE stream
    final stream = leaveRepository.submitLeaveRequestStream(
      userInput: state.isAiMode ? state.userInput : null,
      leaveType: !state.isAiMode ? state.leaveType : null,
      durationDays: !state.isAiMode ? state.durationDays : null,
      requiresMedicalCertificate:
          !state.isAiMode ? state.requiresMedicalCertificate : null,
    );

    await emit.forEach<LeaveStreamEventSerializer>(
      stream,
      onData: (event) {
        if (event.isError) {
          return state.copyWith(
            isThinking: false,
            currentStep: 'error',
            orbState: OrbState.breathing,
            progress: 0.0,
            statusText: event.statusText,
            errorMessage: event.error ?? event.statusText,
            status: BlocStatusError(event.error ?? event.statusText, 400),
          );
        }

        if (event.isCompleted) {
          return state.copyWith(
            isThinking: false,
            currentStep: 'completed',
            orbState: event.orbState,
            progress: 1.0,
            statusText: event.statusText,
            completedEvent: event,
            status: BlocStatusCompleted<LeaveStreamEventSerializer>(event),
          );
        }

        // Active thinking step
        return state.copyWith(
          isThinking: true,
          currentStep: event.step,
          orbState: event.orbState,
          progress: event.progress,
          statusText: event.statusText,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          isThinking: false,
          currentStep: 'error',
          orbState: OrbState.breathing,
          progress: 0.0,
          statusText: 'خطای غیرمنتظره در استریم: $error',
          errorMessage: error.toString(),
          status: BlocStatusError(error.toString(), 500),
        );
      },
    );
  }
}
