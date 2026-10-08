import 'package:equatable/equatable.dart';
import 'package:staffpulseapp/core/model_serializer/leave_stream_event_serializer.dart';

abstract class LeaveSubmitEvent extends Equatable {
  const LeaveSubmitEvent();

  @override
  List<Object?> get props => [];
}

class LeaveModeToggled extends LeaveSubmitEvent {
  final bool isAiMode;
  const LeaveModeToggled(this.isAiMode);

  @override
  List<Object?> get props => [isAiMode];
}

class LeaveInputChanged extends LeaveSubmitEvent {
  final String? userInput;
  final String? leaveType;
  final int? durationDays;
  final bool? requiresMedicalCertificate;

  const LeaveInputChanged({
    this.userInput,
    this.leaveType,
    this.durationDays,
    this.requiresMedicalCertificate,
  });

  @override
  List<Object?> get props => [
        userInput,
        leaveType,
        durationDays,
        requiresMedicalCertificate,
      ];
}

class LeaveSubmitRequested extends LeaveSubmitEvent {
  const LeaveSubmitRequested();
}

class LeaveStreamEventReceived extends LeaveSubmitEvent {
  final LeaveStreamEventSerializer event;
  const LeaveStreamEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

class LeaveFormReset extends LeaveSubmitEvent {
  const LeaveFormReset();
}
