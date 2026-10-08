import 'package:awesome_toast/awesome_toast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffpulseapp/core/services/app_toast.dart';

void main() {
  group('AppToast Service Tests', () {
    setUp(() {
      ToastService.instance.initialize(AppToast.stackConfig);
    });

    test('AppToast stackConfig is properly configured', () {
      final config = AppToast.stackConfig;
      expect(config.position, ToastPosition.topCenter);
      expect(config.defaultDuration, const Duration(seconds: 4));
      expect(config.showProgressByDefault, isTrue);
      expect(config.toastBuilder, isNotNull);
    });

    test('AppToast.success queues a success toast', () {
      AppToast.success('پیام تستی موفقیت', title: 'موفق');
      expect(ToastService.instance.items.isNotEmpty, isTrue);
    });

    test('AppToast.error queues an error toast', () {
      AppToast.error('خطای تستی', title: 'خطا');
      expect(ToastService.instance.items.isNotEmpty, isTrue);
    });

    test('AppToast.warning and info queue toasts', () {
      AppToast.warning('پیام هشدار');
      AppToast.info('پیام اطلاع‌رسانی');
      expect(ToastService.instance.items.isNotEmpty, isTrue);
    });
  });
}
