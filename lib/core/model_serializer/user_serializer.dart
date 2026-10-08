/// Model Serializer (DTO) for handling /auth/me user profile responses.
class UserSerializer {
  final int id;
  final String username;
  final String? email;
  final String role;
  final bool isActive;
  final String? employeeCode;
  final String? managerCode;

  const UserSerializer({
    required this.id,
    required this.username,
    this.email,
    required this.role,
    required this.isActive,
    this.employeeCode,
    this.managerCode,
  });

  factory UserSerializer.fromJson(Map<String, dynamic> json) {
    return UserSerializer(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'EMPLOYEE',
      isActive: json['is_active'] as bool? ?? true,
      employeeCode: json['employee_code'] as String?,
      managerCode: json['manager_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'is_active': isActive,
      'employee_code': employeeCode,
      'manager_code': managerCode,
    };
  }
}
