import 'package:get_it/get_it.dart';
import 'package:staffpulseapp/core/services/global_controller.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // registerLazySingleton and registerSingleton
  
  locator.registerLazySingleton<GlobalController>(() => GlobalController());

}