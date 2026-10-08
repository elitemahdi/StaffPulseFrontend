import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_request_serializer.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_event.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_state.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';

class LeaveHistoryBloc extends Bloc<LeaveHistoryEvent, LeaveHistoryState> {
  final ILeaveRepository leaveRepository;
  final GlobalController globalController;

  LeaveHistoryBloc({
    required this.leaveRepository,
    required this.globalController,
  }) : super(const LeaveHistoryInitialState()) {
    on<FetchLeaveHistoryEvent>(_onFetchLeaveHistory);
    on<CancelLeaveRequestEvent>(_onCancelLeaveRequest);
    on<FilterHistoryStatusEvent>(_onFilterHistoryStatus);
  }

  Future<void> _onFetchLeaveHistory(
    FetchLeaveHistoryEvent event,
    Emitter<LeaveHistoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const LeaveHistoryLoadingState());
    }

    final empCode = event.employeeCode ?? globalController.currentUser?.employeeCode;
    if (empCode == null || empCode.isEmpty) {
      emit(const LeaveHistoryErrorState('کد پرسنلی کارمند مشخص نشده است.'));
      return;
    }

    final results = await Future.wait([
      leaveRepository.getEmployeeLeaveRequests(empCode),
      leaveRepository.getEmployeeLeaveProfile(empCode),
    ]);

    final requestsResult = results[0] as DataState<List<LeaveRequestSerializer>>;
    final profileResult = results[1] as DataState<EmployeeSerializer>;

    if (requestsResult is DataSuccess) {
      final requests = requestsResult.data ?? [];
      final profile = profileResult is DataSuccess ? profileResult.data : null;

      emit(LeaveHistoryLoadedState(
        allRequests: requests,
        filteredRequests: requests,
        profile: profile,
        selectedStatus: 'ALL',
      ));
    } else {
      emit(LeaveHistoryErrorState(requestsResult.error ?? 'خطا در بارگذاری سوابق مرخصی'));
    }
  }

  Future<void> _onCancelLeaveRequest(
    CancelLeaveRequestEvent event,
    Emitter<LeaveHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LeaveHistoryLoadedState) return;

    emit(currentState.copyWith(cancellingRequestId: event.requestId));

    final result = await leaveRepository.cancelLeaveRequest(event.requestId);

    if (result is DataSuccess) {
      final message = result.data?['message'] as String? ?? 'درخواست با موفقیت لغو شد.';

      final updatedAll = currentState.allRequests.map((r) {
        if (r.id == event.requestId) {
          return LeaveRequestSerializer(
            id: r.id,
            employeeCode: r.employeeCode,
            processInstanceId: r.processInstanceId,
            leaveType: r.leaveType,
            durationDays: r.durationDays,
            requiresMedicalCertificate: r.requiresMedicalCertificate,
            requiresSeniorApproval: r.requiresSeniorApproval,
            currentStep: 'CANCELLED_BY_USER',
            status: 'CANCELLED',
            aiRiskScore: r.aiRiskScore,
            aiRecommendation: r.aiRecommendation,
            aiReasoning: r.aiReasoning,
            createdAt: r.createdAt,
          );
        }
        return r;
      }).toList();

      final updatedFiltered = _applyStatusFilter(updatedAll, currentState.selectedStatus);

      emit(LeaveHistoryActionSuccessState(
        message: message,
        requestId: event.requestId,
      ));

      emit(LeaveHistoryLoadedState(
        allRequests: updatedAll,
        filteredRequests: updatedFiltered,
        profile: currentState.profile,
        selectedStatus: currentState.selectedStatus,
      ));
    } else {
      emit(currentState.copyWith(clearCancellingRequest: true));
      emit(LeaveHistoryErrorState(result.error ?? 'خطا در لغو درخواست مرخصی'));
      emit(currentState.copyWith(clearCancellingRequest: true));
    }
  }

  void _onFilterHistoryStatus(
    FilterHistoryStatusEvent event,
    Emitter<LeaveHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is! LeaveHistoryLoadedState) return;

    final filtered = _applyStatusFilter(currentState.allRequests, event.status);

    emit(currentState.copyWith(
      filteredRequests: filtered,
      selectedStatus: event.status,
    ));
  }

  List<LeaveRequestSerializer> _applyStatusFilter(
    List<LeaveRequestSerializer> list,
    String status,
  ) {
    if (status == 'ALL') return list;
    return list.where((r) => r.status.toUpperCase() == status.toUpperCase()).toList();
  }
}
