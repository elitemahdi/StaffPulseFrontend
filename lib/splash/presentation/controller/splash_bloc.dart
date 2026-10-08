import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';
import 'package:staffpulseapp/splash/presentation/controller/splash_event.dart';
import 'package:staffpulseapp/splash/presentation/controller/splash_state.dart';
import 'package:staffpulseapp/splash/repository/splash_repository.dart';

export 'splash_event.dart';
export 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ISplashRepository splashRepository;

  SplashBloc({required this.splashRepository}) : super(const SplashState()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashRetryRequested>(_onSplashRetryRequested);
  }

  Future<void> _onSplashRetryRequested(
    SplashRetryRequested event,
    Emitter<SplashState> emit,
  ) async {
    add(const SplashStarted());
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    // 1. Step 1: Internet Connection Check
    emit(state.copyWith(
      step: SplashStep.checkingInternet,
      statusText: 'در حال بررسی اتصال به اینترنت...',
      orbState: OrbState.searching,
      errorMessage: null,
      canRetry: false,
    ));
    await Future.delayed(const Duration(milliseconds: 300));

    final isInternetOk = await splashRepository.checkInternetConnection();
    if (!isInternetOk) {
      emit(state.copyWith(
        step: SplashStep.connectionError,
        statusText: 'عدم دسترسی به اینترنت',
        errorMessage:
            'دستگاه شما به اینترنت متصل نیست. لطفاً اتصال شبکه را بررسی نموده و مجدداً تلاش کنید.',
        orbState: OrbState.breathing,
        canRetry: true,
      ));
      return;
    }

    // 2. Step 2: Server Connection Check
    emit(state.copyWith(
      step: SplashStep.checkingServer,
      statusText: 'در حال بررسی ارتباط با سرور سازمانی...',
      orbState: OrbState.connecting,
    ));
    await Future.delayed(const Duration(milliseconds: 300));

    final isServerOk = await splashRepository.checkServerConnection();
    if (!isServerOk) {
      emit(state.copyWith(
        step: SplashStep.connectionError,
        statusText: 'سرور سازمانی در دسترس نیست',
        errorMessage:
            'امکان برقراری ارتباط با سرور وجود ندارد. از فعال بودن سرویس Backend اطمینان حاصل فرمایید.',
        orbState: OrbState.breathing,
        canRetry: true,
      ));
      return;
    }

    // 3. Step 3: Check Storage for Token
    emit(state.copyWith(
      step: SplashStep.checkingAuth,
      statusText: 'در حال بررسی نشست کاربری و توکن امنیتی...',
      orbState: OrbState.solving,
    ));
    await Future.delayed(const Duration(milliseconds: 300));

    final token = splashRepository.getSavedToken();
    if (token == null || token.trim().isEmpty) {
      emit(state.copyWith(
        step: SplashStep.unauthenticated,
        statusText: 'در حال انتقال به صفحه ورود...',
        orbState: OrbState.working,
      ));
      return;
    }

    // 4. Step 4: Token exists -> Validate & Fetch Profile from /auth/me
    final result = await splashRepository.validateTokenAndGetUser(token);
    if (result is DataSuccess<UserUiModel> && result.data != null) {
      emit(state.copyWith(
        step: SplashStep.authenticated,
        statusText: 'خوش آمدید! در حال انتقال به سامانه...',
        orbState: OrbState.working,
        user: result.data,
      ));
    } else {
      // Invalid/expired token -> clear and redirect
      await splashRepository.clearSavedToken();
      emit(state.copyWith(
        step: SplashStep.unauthenticated,
        statusText: 'نشست کاربری نامعتبر است. انتقال به صفحه ورود...',
        orbState: OrbState.breathing,
      ));
    }
  }
}
