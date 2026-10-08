import 'package:equatable/equatable.dart';

abstract class ManagerTasksEvent extends Equatable {
  const ManagerTasksEvent();

  @override
  List<Object?> get props => [];
}

class FetchPendingTasksEvent extends ManagerTasksEvent {
  final bool isRefresh;
  final String? group;

  const FetchPendingTasksEvent({this.isRefresh = false, this.group});

  @override
  List<Object?> get props => [isRefresh, group];
}

class ProcessTaskDecisionEvent extends ManagerTasksEvent {
  final String taskId;
  final bool approved;
  final String? comment;
  final String applicantEmployeeCode;

  const ProcessTaskDecisionEvent({
    required this.taskId,
    required this.approved,
    this.comment,
    required this.applicantEmployeeCode,
  });

  @override
  List<Object?> get props => [taskId, approved, comment, applicantEmployeeCode];
}

class SearchFilterTasksEvent extends ManagerTasksEvent {
  final String query;

  const SearchFilterTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}
