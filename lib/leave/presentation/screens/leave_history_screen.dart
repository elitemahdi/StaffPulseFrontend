import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/configs/colors.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/model_serializer/leave_request_serializer.dart';
import 'package:staffpulseapp/core/services/app_toast.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/theme.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_bloc.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_event.dart';
import 'package:staffpulseapp/leave/presentation/controller/leave_history_state.dart';
import 'package:staffpulseapp/leave/presentation/widgets/process_diagram_sheet.dart';

class LeaveHistoryScreen extends StatelessWidget {
  final String? employeeCode;

  const LeaveHistoryScreen({super.key, this.employeeCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaveHistoryBloc>(
      create: (ctx) => locator<LeaveHistoryBloc>()
        ..add(FetchLeaveHistoryEvent(employeeCode: employeeCode)),
      child: const _LeaveHistoryView(),
    );
  }
}

class _LeaveHistoryView extends StatelessWidget {
  const _LeaveHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('سوابق و وضعیت مرخصی‌ها'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'بروزرسانی',
            onPressed: () {
              context.read<LeaveHistoryBloc>().add(const FetchLeaveHistoryEvent(isRefresh: true));
            },
          ),
        ],
      ),
      body: BlocConsumer<LeaveHistoryBloc, LeaveHistoryState>(
        listener: (context, state) {
          if (state is LeaveHistoryActionSuccessState) {
            AppToast.success(state.message);
          } else if (state is LeaveHistoryErrorState) {
            AppToast.error(state.message);
          }
        },
        builder: (context, state) {
          if (state is LeaveHistoryLoadingState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThinkingOrb(
                    state: OrbState.searching,
                    size: 56,
                    color: AppTheme.appleTeal,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'در حال دریافت پرونده و سوابق مرخصی...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (state is LeaveHistoryLoadedState) {
            return RefreshIndicator(
              color: AppTheme.appleTeal,
              backgroundColor: AppTheme.darkSurface,
              onRefresh: () async {
                context.read<LeaveHistoryBloc>().add(const FetchLeaveHistoryEvent(isRefresh: true));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Employee Leave Balances Banner
                  if (state.profile != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: _buildBalancesCard(state.profile!),
                      ),
                    ),

                  // 2. Status Filter Tabs
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildStatusFilterTabs(context, state.selectedStatus),
                    ),
                  ),

                  // 3. Requests List or Empty State
                  if (state.filteredRequests.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final req = state.filteredRequests[index];
                            final isCancelling = state.cancellingRequestId == req.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildRequestCard(
                                context,
                                request: req,
                                isCancelling: isCancelling,
                              ),
                            );
                          },
                          childCount: state.filteredRequests.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          // Error / Retry
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.colorErrorBase, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'خطا در بارگذاری تاریخچه مرخصی',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<LeaveHistoryBloc>().add(const FetchLeaveHistoryEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalancesCard(EmployeeSerializer profile) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppTheme.appleTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                '${profile.firstName} ${profile.lastName} (${profile.employeeCode})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimaryBase.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  profile.department,
                  style: const TextStyle(color: AppTheme.appleBlue, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceGauge(
                  title: 'مرخصی استحقاقی (سالانه)',
                  balance: profile.annualLeaveBalance,
                  color: AppTheme.appleBlue,
                  icon: Icons.beach_access_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceGauge(
                  title: 'مرخصی استعلاجی (درمانی)',
                  balance: profile.sickLeaveBalance,
                  color: AppColors.volcano6,
                  icon: Icons.medical_services_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceGauge({
    required String title,
    required int balance,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Spacer(),
              Text(
                '$balance روز',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterTabs(BuildContext context, String currentStatus) {
    final filters = [
      {'label': 'همه', 'value': 'ALL'},
      {'label': 'در انتظار', 'value': 'PENDING'},
      {'label': 'تایید شده', 'value': 'APPROVED'},
      {'label': 'رد شده', 'value': 'REJECTED'},
      {'label': 'لغو شده', 'value': 'CANCELLED'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = currentStatus == f['value'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              onSelected: (_) {
                context.read<LeaveHistoryBloc>().add(FilterHistoryStatusEvent(f['value']!));
              },
              selectedColor: AppTheme.appleTeal.withValues(alpha: 0.25),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              side: BorderSide(
                color: isSelected ? AppTheme.appleTeal : AppTheme.glassBorderColor,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context, {
    required LeaveRequestSerializer request,
    required bool isCancelling,
  }) {
    final statusMeta = _getStatusMeta(request.status);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title and Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusMeta.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusMeta.icon, color: statusMeta.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرخصی ${request.leaveType} (${request.durationDays} روز)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'گام جاری: ${_formatStepName(request.currentStep)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusMeta.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusMeta.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusMeta.label,
                  style: TextStyle(
                    color: statusMeta.color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: AI Risk badge & details
          Row(
            children: [
              if (request.aiRiskScore != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.appleTeal, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'ریسک ارزیابی: ${((request.aiRiskScore ?? 0) * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (request.requiresMedicalCertificate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.volcano6.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'گواهی پزشکی',
                    style: TextStyle(color: AppColors.volcano6, fontSize: 11),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 3: Action Buttons (Diagram & Cancel)
          Row(
            children: [
              // Diagram button
              OutlinedButton.icon(
                onPressed: () {
                  ProcessDiagramSheet.show(
                    context,
                    processInstanceId: request.processInstanceId,
                    title: 'گردش کار مرخصی #${request.id}',
                  );
                },
                icon: const Icon(Icons.account_tree_outlined, size: 16),
                label: const Text('دیاگرام زنده BPMN'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.appleTeal,
                  side: const BorderSide(color: AppTheme.glassBorderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Spacer(),
              // Cancel button if pending
              if (request.status == 'PENDING')
                isCancelling
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton.icon(
                        onPressed: () => _confirmCancelRequest(context, request.id),
                        icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.colorErrorBase),
                        label: const Text(
                          'لغو درخواست',
                          style: TextStyle(color: AppColors.colorErrorBase, fontSize: 12.5),
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            color: AppTheme.appleTeal.withValues(alpha: 0.4),
            size: 56,
          ),
          const SizedBox(height: 14),
          const Text(
            'سابقه‌ای در این دسته‌بندی یافت نشد.',
            style: TextStyle(color: Colors.white70, fontSize: 14.5),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelRequest(BuildContext context, int requestId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.glassBorderColor),
        ),
        title: const Text('لغو درخواست مرخصی', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'آیا از لغو این درخواست مرخصی و توقف فرایند گردش کار اطمینان دارید؟',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorErrorBase),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('بله، لغو شود'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<LeaveHistoryBloc>().add(CancelLeaveRequestEvent(requestId: requestId));
    }
  }

  ({String label, Color color, IconData icon}) _getStatusMeta(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return (label: 'تایید شده', color: AppTheme.appleGreen, icon: Icons.check_circle_rounded);
      case 'PENDING':
        return (label: 'در انتظار تایید', color: AppTheme.appleOrange, icon: Icons.pending_rounded);
      case 'REJECTED':
        return (label: 'رد شده', color: AppColors.colorErrorBase, icon: Icons.cancel_rounded);
      case 'CANCELLED':
        return (label: 'لغو شده', color: Colors.grey, icon: Icons.remove_circle_outline_rounded);
      default:
        return (label: status, color: Colors.white70, icon: Icons.info_outline);
    }
  }

  String _formatStepName(String step) {
    switch (step) {
      case 'AUTO_APPROVED_BY_AI':
        return 'تایید خودکار هوشمند (Fast-Track)';
      case 'PENDING_MANAGER':
        return 'در انتظار بررسی مدیر واحد';
      case 'PENDING_MEDICAL':
        return 'در انتظار تایید پزشک منابع انسانی';
      case 'PENDING_SENIOR':
        return 'در انتظار بررسی مدیریت ارشد';
      case 'COMPLETED':
        return 'تکمیل و ثبت در سامانه';
      case 'CANCELLED_BY_USER':
        return 'لغو توسط کاربر';
      default:
        return step;
    }
  }
}
