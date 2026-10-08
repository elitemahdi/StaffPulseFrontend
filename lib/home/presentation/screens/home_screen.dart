import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staffpulseapp/core/configs/colors.dart';
import 'package:staffpulseapp/core/model_serializer/employee_serializer.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/storage_service.dart';
import 'package:staffpulseapp/core/services/theme.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EmployeeSerializer? _employeeProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeProfile();
  }

  Future<void> _fetchEmployeeProfile() async {
    final globalCtrl = locator<GlobalController>();
    final user = globalCtrl.currentUser;

    if (user != null && user.employeeCode.isNotEmpty) {
      final repo = locator<ILeaveRepository>();
      final result = await repo.getEmployeeLeaveProfile(user.employeeCode);
      if (mounted) {
        setState(() {
          if (result is DataSuccess) {
            _employeeProfile = result.data;
          }
          _isLoadingProfile = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalCtrl = locator<GlobalController>();
    final user = globalCtrl.currentUser;

    final canAccessManagerTasks = user != null &&
        (user.isManager || user.isHr || user.isExecutive || user.isAdmin);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('سامانه سازمانی استاف‌پالس'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: 'خروج از حساب',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.appleBlue,
        backgroundColor: AppTheme.darkSurface,
        onRefresh: _fetchEmployeeProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Profile Glass Banner
              _buildUserProfileBanner(user),

              const SizedBox(height: 18),

              // 2. Quick Balances (Annual & Sick)
              _buildBalancesSection(),

              const SizedBox(height: 22),

              // 3. Quick Action Hub
              const Text(
                'میز کار و دسترسی سریع',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionsGrid(context, canAccessManagerTasks: canAccessManagerTasks),

              const SizedBox(height: 22),

              // 4. Fast-Track Auto Approval Policy Hint
              _buildFastTrackPolicyInfo(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileBanner(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.appleBlue.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: AppTheme.appleBlue, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'پرسنل استاف‌پالس',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.appleBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user?.roleTitleFa ?? 'کارمند',
                        style: const TextStyle(
                          color: AppTheme.appleBlue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_employeeProfile != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'دپارتمان: ${_employeeProfile!.department}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalancesSection() {
    final annualBalance = _employeeProfile?.annualLeaveBalance ?? 26;
    final sickBalance = _employeeProfile?.sickLeaveBalance ?? 30;

    return Row(
      children: [
        Expanded(
          child: _buildBalanceCard(
            title: 'مانده استحقاقی',
            subtitle: 'مرخصی سالانه مصوب',
            value: '$annualBalance روز',
            icon: Icons.beach_access_rounded,
            color: AppTheme.appleBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBalanceCard(
            title: 'مانده استعلاجی',
            subtitle: 'مرخصی درمانی با گواهی',
            value: '$sickBalance روز',
            icon: Icons.medical_services_rounded,
            color: AppColors.volcano6,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              _isLoadingProfile
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context, {required bool canAccessManagerTasks}) {
    return Column(
      children: [
        // 1. Submit Leave Request (AI Powered)
        _buildActionTile(
          context,
          title: 'ثبت هوشمند مرخصی (AI RAG)',
          subtitle: 'ارزیابی خودکار با هوش مصنوعی و اجرای گردش کار BPMN',
          icon: Icons.auto_awesome_rounded,
          iconColor: AppTheme.appleTeal,
          route: '/leave/submit',
          highlight: true,
        ),
        const SizedBox(height: 12),

        // 2. My Requests History
        _buildActionTile(
          context,
          title: 'سوابق و پرونده مرخصی من',
          subtitle: 'مشاهده وضعیت تاییدات، مراحل و دیاگرام زنده Flowable',
          icon: Icons.history_rounded,
          iconColor: AppTheme.appleIndigo,
          route: '/leave/history',
        ),
        const SizedBox(height: 12),

        // 3. Manager Approval Inbox (if manager / hr / executive / admin)
        if (canAccessManagerTasks)
          _buildActionTile(
            context,
            title: 'کارتابل تاییدات مدیر واحد',
            subtitle: 'بررسی، تایید یا رد درخواست‌های پرسنل دپارتمان با گارد ایمن',
            icon: Icons.fact_check_rounded,
            iconColor: AppTheme.appleGreen,
            route: '/manager/tasks',
            badgeText: 'مدیر سازمانی',
          ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String route,
    bool highlight = false,
    String? badgeText,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: highlight
              ? AppTheme.appleBlue.withValues(alpha: 0.15)
              : AppTheme.darkSurface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlight
                ? AppTheme.appleBlue.withValues(alpha: 0.4)
                : AppTheme.glassBorderColor,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.appleGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(color: AppTheme.appleGreen, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastTrackPolicyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorPrimaryBase.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.colorPrimaryBorder.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppTheme.appleOrange, size: 20),
              SizedBox(width: 8),
              Text(
                'شرایط تایید خودکار و آنی (Fast-Track Auto-Approval)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• مدت حداکثر ۲ روز کاری\n'
            '• نوع مرخصی: استحقاقی سالانه\n'
            '• مصرف حداکثر ۲۰٪ مانده سالانه\n'
            '• عدم نیاز به گواهی پزشکی',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.glassBorderColor),
        ),
        title: const Text('خروج از حساب کاربری', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'آیا مایل به خروج از سامانه استاف‌پالس هستید؟',
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
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final storage = locator<IStorageService>();
      await storage.removeToken();
      final globalCtrl = locator<GlobalController>();
      globalCtrl.reset();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
