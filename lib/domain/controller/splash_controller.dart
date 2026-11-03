import 'package:dart_gemini_example/data/database/repository/device_repository.dart';
import 'package:dart_gemini_example/domain/config/device_helper.dart';
import 'package:dart_gemini_example/domain/config/enums.dart';
import 'package:dart_gemini_example/domain/model/async_state.dart';
import 'package:dart_gemini_example/domain/model/device.dart';
import 'package:dart_gemini_example/domain/model/device_model.dart';
import 'package:optional/optional.dart';
import 'package:signals/signals.dart' show signal;
import 'package:uuid/uuid.dart';

final class SplashController {
  SplashController(
    this._deviceRepository, {
    DeviceInfoLoader? deviceInfoLoader,
  }) : _deviceInfoLoader = deviceInfoLoader ?? DeviceHelper.getDevice;

  final DeviceRepository _deviceRepository;
  final DeviceInfoLoader _deviceInfoLoader;
  final state = signal<AsyncState<Device>>(const AsyncState.initial());

  Future<void> loadDeviceStatus() async {
    state.value = const AsyncState.loading();
    try {
      final result = await _deviceInfoLoader();
      final select = GetDevice(result.name, result.code);
      final Optional<Device> existingDevice =
          await _deviceRepository.findDefaultDevice(select);

      if (existingDevice.isPresent) {
        state.value = AsyncState.completed(existingDevice.value);
        return;
      }

      final now = DateTime.now();
      final newDevice = Device(
        const Uuid().v4(),
        true,
        now,
        now,
        result.name,
        result.code,
        DeviceStatus.apikey,
        null,
      );
      final createdDevice = await _deviceRepository.create(newDevice);
      if (createdDevice.isEmpty) {
        throw StateError('The device could not be initialized.');
      }

      state.value = AsyncState.completed(createdDevice.value);
    } catch (error) {
      state.value = AsyncState.error(error);
    }
  }

  void dispose() {
    state.dispose();
  }
}
