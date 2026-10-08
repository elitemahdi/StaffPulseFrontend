import 'package:flutter_test/flutter_test.dart';
import 'package:staffpulseapp/login/models/login_mapper.dart';
import 'package:staffpulseapp/core/model_serializer/login_response_serializer.dart';

void main() {
  group('Login Architecture Tests: DTO Serializer to UI Model Mapping', () {
    test('Correctly maps ADMIN LoginResponseSerializer to UserUiModel', () {
      final rawJson = {
        'access_token': 'jwt_secret_token_123',
        'token_type': 'bearer',
        'role': 'ADMIN',
        'username': 'admin',
        'employee_code': 'EMP-1001',
      };

      // 1. Fill API Model Serializer
      final serializer = LoginResponseSerializer.fromJson(rawJson);
      expect(serializer.accessToken, 'jwt_secret_token_123');
      expect(serializer.role, 'ADMIN');

      // 2. Map to UI Model
      final uiModel = serializer.toUiModel();

      expect(uiModel.username, 'admin');
      expect(uiModel.employeeCode, 'EMP-1001');
      expect(uiModel.role, 'ADMIN');
      expect(uiModel.roleTitleFa, 'مدیر ارشد سیستم');
      expect(uiModel.isAdmin, isTrue);
      expect(uiModel.isManager, isFalse);
      expect(uiModel.token, 'jwt_secret_token_123');
    });

    test('Correctly maps MANAGER and EMPLOYEE roles', () {
      final managerSerializer = LoginResponseSerializer(
        accessToken: 'token_mgr',
        tokenType: 'bearer',
        role: 'MANAGER',
        username: 'mgr.rezaei',
        employeeCode: 'EMP-1005',
      );
      final managerUi = managerSerializer.toUiModel();
      expect(managerUi.roleTitleFa, 'مدیر واحد');
      expect(managerUi.isManager, isTrue);
      expect(managerUi.isAdmin, isFalse);

      final employeeSerializer = LoginResponseSerializer(
        accessToken: 'token_emp',
        tokenType: 'bearer',
        role: 'EMPLOYEE',
        username: 'ali.mohammadi',
        employeeCode: 'EMP-1007',
      );
      final employeeUi = employeeSerializer.toUiModel();
      expect(employeeUi.roleTitleFa, 'کارمند');
      expect(employeeUi.isAdmin, isFalse);
      expect(employeeUi.isManager, isFalse);
    });
  });
}
