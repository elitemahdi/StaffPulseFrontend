import 'package:equatable/equatable.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

class LoginState extends Equatable {
  final BlocStatus<UserUiModel> status;
  final bool isPasswordVisible;
  final String? usernameError;
  final String? passwordError;

  const LoginState({
    this.status = const BlocStatusInitial(),
    this.isPasswordVisible = false,
    this.usernameError,
    this.passwordError,
  });

  LoginState copyWith({
    BlocStatus<UserUiModel>? status,
    bool? isPasswordVisible,
    String? usernameError,
    String? passwordError,
    bool clearErrors = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      usernameError: clearErrors ? null : (usernameError ?? this.usernameError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        isPasswordVisible,
        usernameError,
        passwordError,
      ];
}
