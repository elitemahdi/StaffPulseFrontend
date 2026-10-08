import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/configs/colors.dart';
import 'package:staffpulseapp/core/model_serializer/leave_task_serializer.dart';
import 'package:staffpulseapp/core/services/app_toast.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/theme.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_bloc.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_event.dart';
import 'package:staffpulseapp/leave/presentation/controller/manager_tasks_state.dart';
import 'package:staffpulseapp/leave/presentation/widgets/process_diagram_sheet.dart';

class ManagerTasksScreen extends StatelessWidget {
  const ManagerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManagerTasksBloc>(
      create: (ctx) => locator<ManagerTasksBloc>()..add(const FetchPendingTasksEvent()),
      child: const _ManagerTasksView(),
    );
  }
}

class _ManagerTasksView extends StatefulWidget {
  const _ManagerTasksView();

  @override
  State<_ManagerTasksView> createState() => _ManagerTasksViewState();
}

class _ManagerTasksViewState extends State<_ManagerTasksView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalCtrl = locator<GlobalController>();
    final currentUser = globalCtrl.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('کارتابل تاییدات و گردش کار مدیر'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'بروزرسانی کارتابل',
            onPressed: () {
              context.read<ManagerTasksBloc>().add(const FetchPendingTasksEvent(isRefresh: true));
            },
          ),
        ],
      ),
      body: BlocConsumer<ManagerTasksBloc, ManagerTasksState>(
        listener: (context, state) {
          if (state is ManagerTasksActionSuccessState) {
            AppToast.success(state.message);
          } else if (state is ManagerTasksErrorState) {
            AppToast.error(state.message);
          }
        },
        builder: (context, state) {
          if (state is ManagerTasksLoadingState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThinkingOrb(
                    state: OrbState.working,
                    size: 60,
                    color: AppTheme.appleBlue,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'در حال همگام‌سازی کارتابل با موتور Flowable...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (state is ManagerTasksLoadedState) {
            return RefreshIndicator(
              color: AppTheme.appleBlue,
              backgroundColor: AppTheme.darkSurface,
              onRefresh: () async {
                context.read<ManagerTasksBloc>().add(const FetchPendingTasksEvent(isRefresh: true));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Statistics Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: _buildStatsBar(state.allTasks),
                    ),
                  ),

                  // 2. Search & Filter Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildSearchBox(context),
                    ),
                  ),

                  // 3. Task List or Empty State
                  if (state.filteredTasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(state.allTasks.isEmpty),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = state.filteredTasks[index];
                            final isProcessing = state.processingTaskId == task.taskId;
                            final isSelfRequest = currentUser != null &&
                                currentUser.employeeCode.isNotEmpty &&
                                task.employeeCode == currentUser.employeeCode;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTaskCard(
                                context,
                                task: task,
                                isProcessing: isProcessing,
                                isSelfRequest: isSelfRequest,
                              ),
                            );
                          },
                          childCount: state.filteredTasks.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          // Initial or Error with retry
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.colorErrorBase, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'خطا در بارگذاری کارتابل یا عدم برقراری اتصال',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ManagerTasksBloc>().add(const FetchPendingTasksEvent());
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

  Widget _buildStatsBar(List<LeaveTaskSerializer> tasks) {
    final total = tasks.length;
    final highRisk = tasks.where((t) => (t.aiRiskScore ?? 0) > 0.7).length;
    final medical = tasks.where((t) => t.requiresMedicalCertificate).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            title: 'کل درخواست‌ها',
            value: '$total',
            icon: Icons.inbox_rounded,
            color: AppTheme.appleBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            title: 'ریسک بالا (AI)',
            value: '$highRisk',
            icon: Icons.shield_outlined,
            color: highRisk > 0 ? AppColors.colorErrorBase : AppColors.colorSuccess,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            title: 'پزشکی / استعلاجی',
            value: '$medical',
            icon: Icons.local_hospital_outlined,
            color: AppColors.volcano6,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
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
                value,
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

  Widget _buildSearchBox(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (val) {
        context.read<ManagerTasksBloc>().add(SearchFilterTasksEvent(val));
      },
      decoration: InputDecoration(
        hintText: 'جستجو بر اساس کد پرسنلی، دپارتمان یا نوع مرخصی...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  context.read<ManagerTasksBloc>().add(const SearchFilterTasksEvent(''));
                },
              )
            : null,
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context, {
    required LeaveTaskSerializer task,
    required bool isProcessing,
    required bool isSelfRequest,
  }) {
    final riskScore = task.aiRiskScore ?? 0.3;
    final riskColor = riskScore > 0.7
        ? AppColors.colorErrorBase
        : (riskScore > 0.4 ? AppColors.colorWarningBase : AppColors.colorSuccess);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelfRequest
              ? AppColors.colorWarningBase.withValues(alpha: 0.5)
              : AppTheme.glassBorderColor,
          width: isSelfRequest ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Applicant and Department
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.appleBlue.withValues(alpha: 0.2),
                child: const Icon(Icons.person_outline_rounded, color: AppTheme.appleBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'پرسنل: ${task.employeeCode}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.department,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.taskName ?? 'مرحله تایید مدیر واحد',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Live BPMN diagram button
              IconButton(
                onPressed: () {
                  ProcessDiagramSheet.show(
                    context,
                    processInstanceId: task.processInstanceId,
                    title: 'فرایند مرخصی ${task.leaveType} (${task.employeeCode})',
                  );
                },
                icon: const Icon(Icons.timeline_rounded, color: AppTheme.appleTeal),
                tooltip: 'مشاهده دیاگرام زنده Flowable',
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Leave specs chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                label: 'نوع مرخصی: ${task.leaveType}',
                icon: Icons.calendar_today_outlined,
                color: AppTheme.appleIndigo,
              ),
              _buildBadge(
                label: 'مدت: ${task.durationDays} روز',
                icon: Icons.access_time_rounded,
                color: AppTheme.appleBlue,
              ),
              if (task.requiresMedicalCertificate)
                _buildBadge(
                  label: 'نیازمند گواهی پزشکی',
                  icon: Icons.medical_services_outlined,
                  color: AppColors.volcano6,
                ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. AI Intelligence Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: riskColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: riskColor, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'تحلیل هوشمند و ماتریس سازمانی:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ریسک: ${(riskScore * 100).toInt()}%',
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.aiRecommendation != null && task.aiRecommendation!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'پیشنهاد هوش مصنوعی: ${_translateRecommendation(task.aiRecommendation!)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (task.aiReasoning != null && task.aiReasoning!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.aiReasoning!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Anti-Self-Approval Guard (Rule 3.B) or Action Buttons
          if (isSelfRequest)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.colorWarningBase.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.colorWarningBase.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.colorWarningBase, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'عدم امکان تایید خودکار (Anti-Self-Approval): این درخواست متعلق به خود شماست و باید توسط مدیر مافوق تعیین تکلیف شود.',
                      style: TextStyle(
                        color: AppColors.colorWarningBase,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ThinkingOrb(
                  state: OrbState.solving,
                  size: 32,
                  color: AppTheme.appleBlue,
                ),
              ),
            )
          else
            Row(
              children: [
                // Reject Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _promptActionDialog(
                      context,
                      task: task,
                      approved: false,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('رد درخواست'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.colorErrorBase,
                      side: BorderSide(color: AppColors.colorErrorBase.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Approve Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _promptActionDialog(
                      context,
                      task: task,
                      approved: true,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('تایید و ثبت'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.appleGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool noTasksAtAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noTasksAtAll ? Icons.task_alt_rounded : Icons.search_off_rounded,
            color: AppTheme.appleTeal.withValues(alpha: 0.6),
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            noTasksAtAll
                ? 'هیچ درخواست در انتظار بررسی وجود ندارد.'
                : 'نتیجه‌ای با عبارت جستجو شده یافت نشد.',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            noTasksAtAll
                ? 'کارتابل شما خالی است.'
                : 'می‌توانید عبارت جستجو را پاک کنید.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _promptActionDialog(
    BuildContext context, {
    required LeaveTaskSerializer task,
    required bool approved,
  }) async {
    final commentController = TextEditingController();
    final defaultComment = approved ? 'تایید بر اساس بررسی سازمانی' : 'عدم موافقت با توجه به نیازمندی واحد';
    commentController.text = defaultComment;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppTheme.glassBorderColor),
        ),
        title: Row(
          children: [
            Icon(
              approved ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: approved ? AppTheme.appleGreen : AppColors.colorErrorBase,
            ),
            const SizedBox(width: 10),
            Text(
              approved ? 'تایید درخواست مرخصی' : 'رد درخواست مرخصی',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'پرسنل ${task.employeeCode} (${task.leaveType} ${task.durationDays} روزه)',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'توضیحات و یادداشت مدیر',
                hintText: 'توضیحات خود را بنویسید...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('انصراف', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: approved ? AppTheme.appleGreen : AppColors.colorErrorBase,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(approved ? 'تایید قطعی' : 'رد قطعی'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.read<ManagerTasksBloc>().add(
            ProcessTaskDecisionEvent(
              taskId: task.taskId,
              approved: approved,
              comment: commentController.text.trim(),
              applicantEmployeeCode: task.employeeCode,
            ),
          );
    }
  }

  String _translateRecommendation(String rec) {
    switch (rec) {
      case 'AUTO_APPROVE':
        return 'تایید خودکار هوشمند (Fast-Track)';
      case 'UNIT_MANAGER_REVIEW':
        return 'بررسی توسط مدیر واحد';
      case 'SENIOR_EXECUTIVE_REVIEW':
        return 'ارجاع به مدیریت ارشد (ریسک یا مدت بالا)';
      case 'HR_MEDICAL_AUDIT':
        return 'نیازمند ممیزی پزشک منابع انسانی';
      default:
        return rec;
    }
  }
}
