import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staffpulseapp/core/services/api_client.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';
import 'package:staffpulseapp/core/services/storage_service.dart';
import 'package:staffpulseapp/login/presentation/controller/login_bloc.dart';
import 'package:staffpulseapp/login/repository/auth_repository.dart';
import 'package:staffpulseapp/splash/presentation/controller/splash_bloc.dart';
import 'package:staffpulseapp/splash/repository/splash_repository.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // 1. SharedPreferences & StorageService
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  final storageService = StorageService(prefs: sharedPreferences);
  locator.registerSingleton<IStorageService>(storageService);

  // 2. Global Controller
  final globalController = GlobalController();
  final savedToken = sharedPreferences.getString('staffpulse_access_token');
  if (savedToken != null && savedToken.isNotEmpty) {
    globalController.setToken(savedToken);
  }
  locator.registerSingleton<GlobalController>(globalController);

  // 3. API Client
  locator.registerLazySingleton<ApiClient>(() => ApiClient());

  // 4. Repositories
  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      apiClient: locator<ApiClient>(),
      prefs: locator<SharedPreferences>(),
      globalController: locator<GlobalController>(),
    ),
  );

  locator.registerLazySingleton<ISplashRepository>(
    () => SplashRepository(
      apiClient: locator<ApiClient>(),
      storageService: locator<IStorageService>(),
      globalController: locator<GlobalController>(),
    ),
  );

  // 5. Blocs (Factory)
  locator.registerFactory<LoginBloc>(
    () => LoginBloc(authRepository: locator<IAuthRepository>()),
  );

  locator.registerFactory<SplashBloc>(
    () => SplashBloc(splashRepository: locator<ISplashRepository>()),
  );
}