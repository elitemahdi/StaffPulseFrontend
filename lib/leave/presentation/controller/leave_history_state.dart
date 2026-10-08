import 'package:equatable/equatable.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_request_serializer.dart';

abstract class LeaveHistoryState extends Equatable {
  const LeaveHistoryState();

  @override
  List<Object?> get props => [];
}

class LeaveHistoryInitialState extends LeaveHistoryState {
  const LeaveHistoryInitialState();
}

class LeaveHistoryLoadingState extends LeaveHistoryState {
  const LeaveHistoryLoadingState();
}

class LeaveHistoryLoadedState extends LeaveHistoryState {
  final List<LeaveRequestSerializer> allRequests;
  final List<LeaveRequestSerializer> filteredRequests;
  final EmployeeSerializer? profile;
  final String selectedStatus;
  final int? cancellingRequestId;

  const LeaveHistoryLoadedState({
    required this.allRequests,
    required this.filteredRequests,
    this.profile,
    this.selectedStatus = 'ALL',
    this.cancellingRequestId,
  });

  LeaveHistoryLoadedState copyWith({
    List<LeaveRequestSerializer>? allRequests,
    List<LeaveRequestSerializer>? filteredRequests,
    EmployeeSerializer? profile,
    String? selectedStatus,
    int? cancellingRequestId,
    bool clearCancellingRequest = false,
  }) {
    return LeaveHistoryLoadedState(
      allRequests: allRequests ?? this.allRequests,
      filteredRequests: filteredRequests ?? this.filteredRequests,
      profile: profile ?? this.profile,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      cancellingRequestId: clearCancellingRequest ? null : (cancellingRequestId ?? this.cancellingRequestId),
    );
  }

  @override
  List<Object?> get props => [
        allRequests,
        filteredRequests,
        profile,
        selectedStatus,
        cancellingRequestId,
      ];
}

class LeaveHistoryActionSuccessState extends LeaveHistoryState {
  final String message;
  final int requestId;

  const LeaveHistoryActionSuccessState({
    required this.message,
    required this.requestId,
  });

  @override
  List<Object?> get props => [message, requestId];
}

class LeaveHistoryErrorState extends LeaveHistoryState {
  final String message;

  const LeaveHistoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
