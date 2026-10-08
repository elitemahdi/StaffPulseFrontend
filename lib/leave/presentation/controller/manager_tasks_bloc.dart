import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_event.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_state.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';

class ManagerTasksBloc extends Bloc<ManagerTasksEvent, ManagerTasksState> {
  final ILeaveRepository leaveRepository;
  final GlobalController globalController;

  ManagerTasksBloc({
    required this.leaveRepository,
    required this.globalController,
  }) : super(const ManagerTasksInitialState()) {
    on<FetchPendingTasksEvent>(_onFetchPendingTasks);
    on<ProcessTaskDecisionEvent>(_onProcessTaskDecision);
    on<SearchFilterTasksEvent>(_onSearchFilterTasks);
  }

  Future<void> _onFetchPendingTasks(
    FetchPendingTasksEvent event,
    Emitter<ManagerTasksState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const ManagerTasksLoadingState());
    }

    final result = await leaveRepository.getPendingTasks(group: event.group);

    if (result is DataSuccess && result.data != null) {
      final tasks = result.data!;
      emit(ManagerTasksLoadedState(
        allTasks: tasks,
        filteredTasks: tasks,
      ));
    } else {
      emit(ManagerTasksErrorState(result.error ?? 'خطا در بارگذاری تسک‌های کارتابل'));
    }
  }

  Future<void> _onProcessTaskDecision(
    ProcessTaskDecisionEvent event,
    Emitter<ManagerTasksState> emit,
  ) async {
    final currentUser = globalController.currentUser;

    // Rule 3.B: Anti-Self-Approval Guard
    if (currentUser != null &&
        currentUser.employeeCode.isNotEmpty &&
        event.applicantEmployeeCode.isNotEmpty &&
        currentUser.employeeCode == event.applicantEmployeeCode) {
      emit(const ManagerTasksErrorState(
        'تایید یا رد درخواست مرخصی توسط خود متقاضی (Anti-Self-Approval) اکیداً ممنوع است.',
      ));
      return;
    }

    final currentState = state;
    if (currentState is! ManagerTasksLoadedState) return;

    // Set processing indicator on this specific task
    emit(currentState.copyWith(processingTaskId: event.taskId));

    final result = await leaveRepository.executeTaskAction(
      taskId: event.taskId,
      approved: event.approved,
      comment: event.comment,
    );

    if (result is DataSuccess) {
      final message = result.data?['message'] as String? ??
          (event.approved ? 'درخواست با موفقیت تایید شد.' : 'درخواست با موفقیت رد شد.');

      final updatedAll = currentState.allTasks.where((t) => t.taskId != event.taskId).toList();
      final updatedFiltered = currentState.filteredTasks.where((t) => t.taskId != event.taskId).toList();

      emit(ManagerTasksActionSuccessState(
        message: message,
        approved: event.approved,
        taskId: event.taskId,
      ));

      // Re-emit loaded state with the updated task list
      emit(ManagerTasksLoadedState(
        allTasks: updatedAll,
        filteredTasks: updatedFiltered,
        searchQuery: currentState.searchQuery,
      ));
    } else {
      emit(currentState.copyWith(clearProcessingTask: true));
      emit(ManagerTasksErrorState(result.error ?? 'خطا در اعمال تصمیم روی تسک'));
      emit(currentState.copyWith(clearProcessingTask: true));
    }
  }

  void _onSearchFilterTasks(
    SearchFilterTasksEvent event,
    Emitter<ManagerTasksState> emit,
  ) {
    final currentState = state;
    if (currentState is! ManagerTasksLoadedState) return;

    final query = event.query.trim().toLowerCase();
    if (query.isEmpty) {
      emit(currentState.copyWith(
        filteredTasks: currentState.allTasks,
        searchQuery: '',
      ));
      return;
    }

    final filtered = currentState.allTasks.where((task) {
      final codeMatches = task.employeeCode.toLowerCase().contains(query);
      final deptMatches = task.department.toLowerCase().contains(query);
      final typeMatches = task.leaveType.toLowerCase().contains(query);
      final taskNameMatches = (task.taskName ?? '').toLowerCase().contains(query);
      return codeMatches || deptMatches || typeMatches || taskNameMatches;
    }).toList();

    emit(currentState.copyWith(
      filteredTasks: filtered,
      searchQuery: query,
    ));
  }
}
