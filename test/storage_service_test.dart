import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staffpulseapp/core/services/storage_service.dart';

void main() {
  group('StorageService Unit Tests', () {
    late StorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Saves and reads primitives', () async {
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs: prefs);

      await storageService.saveString('test_key', 'test_val');
      expect(storageService.getString('test_key'), 'test_val');

      await storageService.saveBool('bool_key', true);
      expect(storageService.getBool('bool_key'), isTrue);

      await storageService.saveInt('int_key', 42);
      expect(storageService.getInt('int_key'), 42);
    });

    test('Saves and reads JSON maps', () async {
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs: prefs);

      final testMap = {'id': 100, 'role': 'MANAGER', 'is_active': true};
      await storageService.saveJson('model_key', testMap);

      final retrieved = storageService.getJson('model_key');
      expect(retrieved, isNotNull);
      expect(retrieved!['id'], 100);
      expect(retrieved['role'], 'MANAGER');
      expect(retrieved['is_active'], isTrue);
    });

    test('Manages token and credentials', () async {
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs: prefs);

      // Token
      await storageService.saveToken('jwt_sample_token');
      expect(storageService.getToken(), 'jwt_sample_token');
      await storageService.removeToken();
      expect(storageService.getToken(), isNull);

      // Credentials (Remember Me)
      await storageService.saveCredentials(
        username: 'ali.mohammadi',
        password: 'secret_password',
        rememberMe: true,
      );
      final creds = storageService.getSavedCredentials();
      expect(creds.rememberMe, isTrue);
      expect(creds.username, 'ali.mohammadi');
      expect(creds.password, 'secret_password');

      await storageService.clearSavedCredentials();
      final cleared = storageService.getSavedCredentials();
      expect(cleared.rememberMe, isFalse);
      expect(cleared.username, isNull);
    });
  });
}
