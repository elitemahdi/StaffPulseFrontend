import 'package:flutter_test/flutter_test.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';
import 'package:staffpulseapp/splash/presentation/controller/splash_bloc.dart';
import 'package:staffpulseapp/splash/repository/splash_repository.dart';

class MockSplashRepository implements ISplashRepository {
  bool mockInternet = true;
  bool mockServer = true;
  String? mockToken;
  DataState<UserUiModel>? mockUserResult;
  bool clearTokenCalled = false;

  @override
  Future<bool> checkInternetConnection() async => mockInternet;

  @override
  Future<bool> checkServerConnection() async => mockServer;

  @override
  String? getSavedToken() => mockToken;

  @override
  Future<void> clearSavedToken() async {
    clearTokenCalled = true;
    mockToken = null;
  }

  @override
  Future<DataState<UserUiModel>> validateTokenAndGetUser(String token) async {
    return mockUserResult ?? DataFailed('Mock error', 401);
  }
}

void main() {
  group('SplashBloc Tests', () {
    late MockSplashRepository mockRepo;
    late SplashBloc splashBloc;

    setUp(() {
      mockRepo = MockSplashRepository();
      splashBloc = SplashBloc(splashRepository: mockRepo);
    });

    tearDown(() {
      splashBloc.close();
    });

    test('Initial state is correct', () {
      expect(splashBloc.state.step, SplashStep.initial);
      expect(splashBloc.state.canRetry, isFalse);
    });

    test('Emits connectionError when internet is unavailable', () async {
      mockRepo.mockInternet = false;

      splashBloc.add(const SplashStarted());

      await expectLater(
        splashBloc.stream,
        emitsInOrder([
          predicate<SplashState>((s) => s.step == SplashStep.checkingInternet),
          predicate<SplashState>((s) =>
              s.step == SplashStep.connectionError &&
              s.canRetry == true &&
              s.errorMessage!.contains('اینترنت')),
        ]),
      );
    });

    test('Emits connectionError when server is unreachable', () async {
      mockRepo.mockInternet = true;
      mockRepo.mockServer = false;

      splashBloc.add(const SplashStarted());

      await expectLater(
        splashBloc.stream,
        emitsInOrder([
          predicate<SplashState>((s) => s.step == SplashStep.checkingInternet),
          predicate<SplashState>((s) => s.step == SplashStep.checkingServer),
          predicate<SplashState>((s) =>
              s.step == SplashStep.connectionError &&
              s.canRetry == true &&
              s.errorMessage!.contains('سرور')),
        ]),
      );
    });

    test('Emits unauthenticated when no token is saved', () async {
      mockRepo.mockInternet = true;
      mockRepo.mockServer = true;
      mockRepo.mockToken = null;

      splashBloc.add(const SplashStarted());

      await expectLater(
        splashBloc.stream,
        emitsInOrder([
          predicate<SplashState>((s) => s.step == SplashStep.checkingInternet),
          predicate<SplashState>((s) => s.step == SplashStep.checkingServer),
          predicate<SplashState>((s) => s.step == SplashStep.checkingAuth),
          predicate<SplashState>((s) => s.step == SplashStep.unauthenticated),
        ]),
      );
    });

    test('Emits authenticated when valid token exists and profile loads', () async {
      mockRepo.mockInternet = true;
      mockRepo.mockServer = true;
      mockRepo.mockToken = 'valid_jwt_token';
      const dummyUser = UserUiModel(
        username: 'admin',
        employeeCode: 'EMP-1001',
        role: 'ADMIN',
        roleTitleFa: 'مدیر ارشد سیستم',
        token: 'valid_jwt_token',
        isAdmin: true,
        isManager: false,
        isHr: false,
        isExecutive: false,
      );
      mockRepo.mockUserResult = const DataSuccess(dummyUser);

      splashBloc.add(const SplashStarted());

      await expectLater(
        splashBloc.stream,
        emitsInOrder([
          predicate<SplashState>((s) => s.step == SplashStep.checkingInternet),
          predicate<SplashState>((s) => s.step == SplashStep.checkingServer),
          predicate<SplashState>((s) => s.step == SplashStep.checkingAuth),
          predicate<SplashState>((s) =>
              s.step == SplashStep.authenticated && s.user?.username == 'admin'),
        ]),
      );
    });

    test('Emits unauthenticated and clears token when token is expired/invalid', () async {
      mockRepo.mockInternet = true;
      mockRepo.mockServer = true;
      mockRepo.mockToken = 'expired_jwt_token';
      mockRepo.mockUserResult = const DataFailed('Unauthorized', 401);

      splashBloc.add(const SplashStarted());

      await expectLater(
        splashBloc.stream,
        emitsInOrder([
          predicate<SplashState>((s) => s.step == SplashStep.checkingInternet),
          predicate<SplashState>((s) => s.step == SplashStep.checkingServer),
          predicate<SplashState>((s) => s.step == SplashStep.checkingAuth),
          predicate<SplashState>((s) => s.step == SplashStep.unauthenticated),
        ]),
      );

      expect(mockRepo.clearTokenCalled, isTrue);
    });
  });
}
