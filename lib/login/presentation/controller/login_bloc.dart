import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';
import 'package:staffpulseapp/login/presentation/controller/login_event.dart';
import 'package:staffpulseapp/login/presentation/controller/login_state.dart';
import 'package:staffpulseapp/login/repository/auth_repository.dart';

export 'login_event.dart';
export 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginPasswordVisibilityToggled>(_onTogglePasswordVisibility);
    on<LoginResetRequested>(_onResetRequested);
  }

  void _onTogglePasswordVisibility(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onResetRequested(
    LoginResetRequested event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginState());
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // 1. Validation
    String? userErr;
    String? passErr;

    if (event.username.trim().isEmpty) {
      userErr = 'نام کاربری را وارد فرمایید';
    }
    if (event.password.trim().isEmpty) {
      passErr = 'کلمه عبور را وارد فرمایید';
    }

    if (userErr != null || passErr != null) {
      emit(state.copyWith(
        usernameError: userErr,
        passwordError: passErr,
      ));
      return;
    }

    // 2. Emit Loading
    emit(state.copyWith(
      clearErrors: true,
      status: const BlocStatusLoading(),
    ));

    // 3. Call Repository
    final result = await authRepository.login(
      username: event.username,
      password: event.password,
    );

    // 4. Emit Completed or Error
    if (result is DataSuccess<UserUiModel> && result.data != null) {
      emit(state.copyWith(
        status: BlocStatusCompleted<UserUiModel>(result.data!),
      ));
    } else {
      emit(state.copyWith(
        status: BlocStatusError<UserUiModel>(
          result.error ?? 'ورود به سامانه با شکست مواجه شد',
          result.errorCode,
        ),
      ));
    }
  }
}
