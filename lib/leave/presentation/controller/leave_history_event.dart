import 'package:equatable/equatable.dart';

abstract class LeaveHistoryEvent extends Equatable {
  const LeaveHistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeaveHistoryEvent extends LeaveHistoryEvent {
  final String? employeeCode;
  final bool isRefresh;

  const FetchLeaveHistoryEvent({this.employeeCode, this.isRefresh = false});

  @override
  List<Object?> get props => [employeeCode, isRefresh];
}

class CancelLeaveRequestEvent extends LeaveHistoryEvent {
  final int requestId;

  const CancelLeaveRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class FilterHistoryStatusEvent extends LeaveHistoryEvent {
  final String status;

  const FilterHistoryStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}
