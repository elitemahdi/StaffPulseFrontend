import 'package:equatable/equatable.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/model_serializer/leave_stream_event_serializer.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';

class LeaveSubmitState extends Equatable {
  // Form input fields
  final bool isAiMode;
  final String userInput;
  final String leaveType;
  final int durationDays;
  final bool requiresMedicalCertificate;

  // Real-time Agent Thinking state
  final bool isThinking;
  final String currentStep;
  final OrbState orbState;
  final double progress;
  final String statusText;
  final LeaveStreamEventSerializer? completedEvent;
  final String? errorMessage;

  // General Bloc lifecycle status
  final BlocStatus status;

  const LeaveSubmitState({
    this.isAiMode = true,
    this.userInput = '',
    this.leaveType = 'استحقاقی',
    this.durationDays = 1,
    this.requiresMedicalCertificate = false,
    this.isThinking = false,
    this.currentStep = 'idle',
    this.orbState = OrbState.working,
    this.progress = 0.0,
    this.statusText = '',
    this.completedEvent,
    this.errorMessage,
    this.status = const BlocStatusInitial(),
  });

  LeaveSubmitState copyWith({
    bool? isAiMode,
    String? userInput,
    String? leaveType,
    int? durationDays,
    bool? requiresMedicalCertificate,
    bool? isThinking,
    String? currentStep,
    OrbState? orbState,
    double? progress,
    String? statusText,
    LeaveStreamEventSerializer? completedEvent,
    String? errorMessage,
    BlocStatus? status,
  }) {
    return LeaveSubmitState(
      isAiMode: isAiMode ?? this.isAiMode,
      userInput: userInput ?? this.userInput,
      leaveType: leaveType ?? this.leaveType,
      durationDays: durationDays ?? this.durationDays,
      requiresMedicalCertificate:
          requiresMedicalCertificate ?? this.requiresMedicalCertificate,
      isThinking: isThinking ?? this.isThinking,
      currentStep: currentStep ?? this.currentStep,
      orbState: orbState ?? this.orbState,
      progress: progress ?? this.progress,
      statusText: statusText ?? this.statusText,
      completedEvent: completedEvent ?? this.completedEvent,
      errorMessage: errorMessage,
      status: status ?? this.status,
    );
  }

  bool get isAutoApproved => completedEvent?.isAutoApproved ?? false;

  @override
  List<Object?> get props => [
        isAiMode,
        userInput,
        leaveType,
        durationDays,
        requiresMedicalCertificate,
        isThinking,
        currentStep,
        orbState,
        progress,
        statusText,
        completedEvent,
        errorMessage,
        status,
      ];
}
