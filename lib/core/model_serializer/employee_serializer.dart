/// Model Serializer (DTO) for Employee data from /employees/
class EmployeeSerializer {
  final int id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String department;
  final String? managerCode;
  final int sickLeaveBalance;
  final int annualLeaveBalance;

  const EmployeeSerializer({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.department,
    this.managerCode,
    required this.sickLeaveBalance,
    required this.annualLeaveBalance,
  });

  factory EmployeeSerializer.fromJson(Map<String, dynamic> json) {
    return EmployeeSerializer(
      id: json['id'] as int? ?? 0,
      employeeCode: json['employee_code'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      managerCode: json['manager_code'] as String?,
      sickLeaveBalance: json['sick_leave_balance'] as int? ?? 0,
      annualLeaveBalance: json['annual_leave_balance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'first_name': firstName,
      'last_name': lastName,
      'department': department,
      'manager_code': managerCode,
      'sick_leave_balance': sickLeaveBalance,
      'annual_leave_balance': annualLeaveBalance,
    };
  }
}
