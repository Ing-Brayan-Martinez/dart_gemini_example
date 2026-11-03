import 'package:dart_gemini_example/data/database/repository/device_repository.dart';
import 'package:dart_gemini_example/domain/controller/api_key_controller.dart';
import 'package:dart_gemini_example/domain/controller/splash_controller.dart';
import 'package:provider/provider.dart';

final providers = [
  Provider<DeviceRepository>(
    create: (_) => DeviceRepositoryImpl(),
  ),
  Provider<SplashController>(
    create: (context) => SplashController(
      context.read<DeviceRepository>(),
    ),
    dispose: (_, controller) => controller.dispose(),
  ),
  Provider<ApiKeyController>(
    create: (context) => ApiKeyController(
      context.read<DeviceRepository>(),
    ),
    dispose: (_, controller) => controller.dispose(),
  ),
];
