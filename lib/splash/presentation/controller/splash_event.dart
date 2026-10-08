import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers initial sequential diagnostic checks:
/// 1. Internet connection
/// 2. Server connection
/// 3. Storage token inspection
/// 4. User profile fetch & route dispatch
class SplashStarted extends SplashEvent {
  const SplashStarted();
}

/// Triggers retry if internet or server was unreachable.
class SplashRetryRequested extends SplashEvent {
  const SplashRetryRequested();
}
