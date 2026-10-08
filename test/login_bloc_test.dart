import 'package:flutter_test/flutter_test.dart';
import 'package:staffpulseapp/core/utils/bloc_states.dart';
import 'package:staffpulseapp/core/utils/data_state.dart';
import 'package:staffpulseapp/login/models/user_ui_model.dart';
import 'package:staffpulseapp/login/presentation/controller/login_bloc.dart';
import 'package:staffpulseapp/login/repository/auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  DataState<UserUiModel>? mockResponse;
  bool loginCalled = false;
  String? capturedUsername;
  String? capturedPassword;

  @override
  Future<DataState<UserUiModel>> login({
    required String username,
    required String password,
  }) async {
    loginCalled = true;
    capturedUsername = username;
    capturedPassword = password;
    return mockResponse ??
        DataFailed<UserUiModel>('Default mock error', 400);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getSavedToken() async => null;
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginBloc loginBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginBloc = LoginBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    loginBloc.close();
  });

  group('LoginBloc Tests', () {
    test('Initial state is correct', () {
      expect(loginBloc.state.status, isA<BlocStatusInitial>());
      expect(loginBloc.state.isPasswordVisible, isFalse);
      expect(loginBloc.state.usernameError, isNull);
      expect(loginBloc.state.passwordError, isNull);
    });

    test('LoginPasswordVisibilityToggled event toggles visibility', () {
      expect(loginBloc.state.isPasswordVisible, isFalse);

      loginBloc.add(const LoginPasswordVisibilityToggled());
      expectLater(
        loginBloc.stream,
        emits(predicate<LoginState>((s) => s.isPasswordVisible == true)),
      );
    });

    test('Validation emits errors when credentials are empty', () async {
      loginBloc.add(const LoginSubmitted(username: '', password: ''));

      await expectLater(
        loginBloc.stream,
        emits(predicate<LoginState>((s) =>
            s.usernameError != null &&
            s.passwordError != null &&
            mockAuthRepository.loginCalled == false)),
      );
    });

    test('Successful submission emits Loading then Completed', () async {
      final dummyUser = const UserUiModel(
        username: 'admin',
        employeeCode: 'EMP-1001',
        role: 'ADMIN',
        roleTitleFa: 'مدیر ارشد سیستم',
        token: 'token_123',
        isAdmin: true,
        isManager: false,
        isHr: false,
        isExecutive: false,
      );
      mockAuthRepository.mockResponse = DataSuccess(dummyUser);

      loginBloc.add(const LoginSubmitted(
        username: 'admin',
        password: 'password123',
      ));

      await expectLater(
        loginBloc.stream,
        emitsInOrder([
          predicate<LoginState>((s) => s.status is BlocStatusLoading),
          predicate<LoginState>((s) =>
              s.status is BlocStatusCompleted<UserUiModel> &&
              (s.status as BlocStatusCompleted<UserUiModel>).value.username == 'admin'),
        ]),
      );

      expect(mockAuthRepository.loginCalled, isTrue);
      expect(mockAuthRepository.capturedUsername, 'admin');
    });

    test('Failed submission emits Loading then Error', () async {
      mockAuthRepository.mockResponse =
          DataFailed('نام کاربری یا کلمه عبور اشتباه است', 401);

      loginBloc.add(const LoginSubmitted(
        username: 'wrong_user',
        password: 'wrong_password',
      ));

      await expectLater(
        loginBloc.stream,
        emitsInOrder([
          predicate<LoginState>((s) => s.status is BlocStatusLoading),
          predicate<LoginState>((s) =>
              s.status is BlocStatusError<UserUiModel> &&
              (s.status as BlocStatusError<UserUiModel>).message ==
                  'نام کاربری یا کلمه عبور اشتباه است'),
        ]),
      );
    });
  });
}
