import 'package:equatable/equatable.dart';
import 'package:staffpulseapp/core/model_serializer/leave_task_serializer.dart';

abstract class ManagerTasksState extends Equatable {
  const ManagerTasksState();

  @override
  List<Object?> get props => [];
}

class ManagerTasksInitialState extends ManagerTasksState {
  const ManagerTasksInitialState();
}

class ManagerTasksLoadingState extends ManagerTasksState {
  const ManagerTasksLoadingState();
}

class ManagerTasksLoadedState extends ManagerTasksState {
  final List<LeaveTaskSerializer> allTasks;
  final List<LeaveTaskSerializer> filteredTasks;
  final String? processingTaskId;
  final String searchQuery;

  const ManagerTasksLoadedState({
    required this.allTasks,
    required this.filteredTasks,
    this.processingTaskId,
    this.searchQuery = '',
  });

  ManagerTasksLoadedState copyWith({
    List<LeaveTaskSerializer>? allTasks,
    List<LeaveTaskSerializer>? filteredTasks,
    String? processingTaskId,
    bool clearProcessingTask = false,
    String? searchQuery,
  }) {
    return ManagerTasksLoadedState(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      processingTaskId: clearProcessingTask ? null : (processingTaskId ?? this.processingTaskId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allTasks, filteredTasks, processingTaskId, searchQuery];
}

class ManagerTasksActionSuccessState extends ManagerTasksState {
  final String message;
  final bool approved;
  final String taskId;

  const ManagerTasksActionSuccessState({
    required this.message,
    required this.approved,
    required this.taskId,
  });

  @override
  List<Object?> get props => [message, approved, taskId];
}

class ManagerTasksErrorState extends ManagerTasksState {
  final String message;

  const ManagerTasksErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
