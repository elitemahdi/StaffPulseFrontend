import 'package:equatable/equatable.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';

enum SplashStep {
  initial,
  checkingInternet,
  checkingServer,
  checkingAuth,
  authenticated,
  unauthenticated,
  connectionError,
}

class SplashState extends Equatable {
  final SplashStep step;
  final String statusText;
  final OrbState orbState;
  final UserUiModel? user;
  final String? errorMessage;
  final bool canRetry;

  const SplashState({
    this.step = SplashStep.initial,
    this.statusText = 'در حال آماده‌سازی سامانه...',
    this.orbState = OrbState.breathing,
    this.user,
    this.errorMessage,
    this.canRetry = false,
  });

  SplashState copyWith({
    SplashStep? step,
    String? statusText,
    OrbState? orbState,
    UserUiModel? user,
    String? errorMessage,
    bool? canRetry,
  }) {
    return SplashState(
      step: step ?? this.step,
      statusText: statusText ?? this.statusText,
      orbState: orbState ?? this.orbState,
      user: user ?? this.user,
      errorMessage: errorMessage,
      canRetry: canRetry ?? this.canRetry,
    );
  }

  @override
  List<Object?> get props => [
        step,
        statusText,
        orbState,
        user,
        errorMessage,
        canRetry,
      ];
}
