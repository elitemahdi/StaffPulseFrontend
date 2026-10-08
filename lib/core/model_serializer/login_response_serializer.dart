/// Model Serializer (DTO) for handling the raw backend response from /auth/login.
/// Contains all properties returned by the FastAPI server.
class LoginResponseSerializer {
  final String accessToken;
  final String tokenType;
  final String role;
  final String username;
  final String? employeeCode;

  const LoginResponseSerializer({
    required this.accessToken,
    required this.tokenType,
    required this.role,
    required this.username,
    this.employeeCode,
  });

  factory LoginResponseSerializer.fromJson(Map<String, dynamic> json) {
    return LoginResponseSerializer(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      role: json['role'] as String? ?? 'EMPLOYEE',
      username: json['username'] as String? ?? '',
      employeeCode: json['employee_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'role': role,
      'username': username,
      'employee_code': employeeCode,
    };
  }
}
