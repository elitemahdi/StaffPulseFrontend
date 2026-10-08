import 'package:equatable/equatable.dart';

/// Pure UI Model: Contains only the necessary formatted, typed data properties
/// required by the user interface and presentation controllers.
class UserUiModel extends Equatable {
  final String username;
  final String employeeCode;
  final String role;
  final String roleTitleFa;
  final String token;
  final bool isAdmin;
  final bool isManager;
  final bool isHr;
  final bool isExecutive;

  const UserUiModel({
    required this.username,
    required this.employeeCode,
    required this.role,
    required this.roleTitleFa,
    required this.token,
    required this.isAdmin,
    required this.isManager,
    required this.isHr,
    required this.isExecutive,
  });

  String get displayName => employeeCode.isNotEmpty ? '$username ($employeeCode)' : username;

  @override
  List<Object?> get props => [
        username,
        employeeCode,
        role,
        roleTitleFa,
        token,
        isAdmin,
        isManager,
        isHr,
        isExecutive,
      ];
}
