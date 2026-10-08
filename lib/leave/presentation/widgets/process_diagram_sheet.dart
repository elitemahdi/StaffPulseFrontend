import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/configs/colors.dart';
import 'package:staffpulseapp/core/services/locator.dart';
import 'package:staffpulseapp/core/services/theme.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/leave/repository/leave_repository.dart';

class ProcessDiagramSheet extends StatefulWidget {
  final String processInstanceId;
  final String title;

  const ProcessDiagramSheet({
    super.key,
    required this.processInstanceId,
    this.title = 'نمودار زنده گردش کار BPMN 2.0',
  });

  static Future<void> show(BuildContext context, {required String processInstanceId, String? title}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProcessDiagramSheet(
        processInstanceId: processInstanceId,
        title: title ?? 'نمودار زنده گردش کار BPMN 2.0',
      ),
    );
  }

  @override
  State<ProcessDiagramSheet> createState() => _ProcessDiagramSheetState();
}

class _ProcessDiagramSheetState extends State<ProcessDiagramSheet> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDiagram();
  }

  Future<void> _loadDiagram() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = locator<ILeaveRepository>();
    final result = await repo.getProcessDiagramBytes(widget.processInstanceId);

    if (mounted) {
      if (result is DataSuccess && result.data != null) {
        setState(() {
          _imageBytes = Uint8List.fromList(result.data!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.error ?? 'تصویر گردش کار یافت نشد یا پروسه خاتمه یافته است.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.82,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppTheme.glassBorderColor),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.appleTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_tree_outlined,
                    color: AppTheme.appleTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'شناسه پروسه: ${widget.processInstanceId}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _loadDiagram,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                  tooltip: 'بروزرسانی',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Info banner for red border highlighting in Flowable
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.colorPrimaryBase.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.colorPrimaryBorder.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.appleTeal, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'کادر قرمز رنگ در دیاگرام نشان‌دهنده موقعیت و گام فعال پرونده در موتور Flowable است.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppTheme.glassBorderColor, height: 16),

          // Diagram content view
          Expanded(
            child: _buildDiagramBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ThinkingOrb(
              state: OrbState.searching,
              size: 54,
              color: AppTheme.appleTeal,
            ),
            const SizedBox(height: 18),
            Text(
              'در حال واکشی نمودار از موتور Flowable BPMN...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image_outlined, color: AppColors.colorWarningBase, size: 48),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _loadDiagram,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('تلاش مجدد'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.glassBorderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_imageBytes != null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.glassBorderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(32),
          child: Center(
            child: Image.memory(
              _imageBytes!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Text('خطا در بارگذاری تصویر', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
