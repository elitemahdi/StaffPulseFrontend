import 'package:staffpulseapp/core/model_serializer/login_response_serializer.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

/// Mapping extension that transforms the raw API response serializer (DTO)
/// into the clean UI model consumed by controllers and widgets.
extension LoginResponseSerializerX on LoginResponseSerializer {
  UserUiModel toUiModel() {
    final upperRole = role.toUpperCase();

    String persianRoleTitle;
    switch (upperRole) {
      case 'ADMIN':
        persianRoleTitle = 'مدیر ارشد سیستم';
        break;
      case 'EXECUTIVE':
        persianRoleTitle = 'مدیر ارشد سازمان';
        break;
      case 'HR':
        persianRoleTitle = 'مسئول منابع انسانی / بهداری';
        break;
      case 'MANAGER':
        persianRoleTitle = 'مدیر واحد';
        break;
      case 'EMPLOYEE':
      default:
        persianRoleTitle = 'کارمند';
        break;
    }

    return UserUiModel(
      username: username,
      employeeCode: employeeCode ?? 'نامشخص',
      role: upperRole,
      roleTitleFa: persianRoleTitle,
      token: accessToken,
      isAdmin: upperRole == 'ADMIN',
      isManager: upperRole == 'MANAGER',
      isHr: upperRole == 'HR',
      isExecutive: upperRole == 'EXECUTIVE',
    );
  }
}
