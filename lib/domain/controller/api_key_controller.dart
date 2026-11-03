import 'package:dart_gemini_example/data/database/repository/device_repository.dart';
import 'package:dart_gemini_example/domain/config/enums.dart';
import 'package:dart_gemini_example/domain/config/device_helper.dart';
import 'package:dart_gemini_example/domain/model/async_state.dart';
import 'package:dart_gemini_example/domain/model/device.dart';
import 'package:dart_gemini_example/domain/model/device_model.dart';
import 'package:optional/optional.dart';
import 'package:signals/signals.dart' show signal;
import 'package:uuid/uuid.dart';

final class ApiKeyController {
  ApiKeyController(
    this._deviceRepository, {
    DeviceInfoLoader? deviceInfoLoader,
  }) : _deviceInfoLoader = deviceInfoLoader ?? DeviceHelper.getDevice;

  final DeviceRepository _deviceRepository;
  final DeviceInfoLoader _deviceInfoLoader;
  final state = signal<AsyncState<String>>(const AsyncState.initial());

  Future<void> assignApiKey(String apiKey) async {
    final normalizedApiKey = apiKey.trim();
    if (normalizedApiKey.isEmpty) {
      throw ArgumentError.value(apiKey, 'apiKey', 'API key cannot be empty.');
    }

    state.value = const AsyncState.loading();
    try {
      final result = await _deviceInfoLoader();
      final select = GetDevice(result.name, result.code);
      final Optional<Device> optionalDefault =
          await _deviceRepository.findDefaultDevice(select);

      if (optionalDefault.isEmpty) {
        final documentId = const Uuid().v4().toString();
        final device = Device(
          documentId,
          true,
          DateTime.now(),
          DateTime.now(),
          result.name,
          result.code,
          DeviceStatus.chat,
          normalizedApiKey,
        );
        final created = await _deviceRepository.create(device);
        if (created.isEmpty) {
          throw StateError('The API key could not be saved on this device.');
        }
      } else {
        final device = optionalDefault.value;
        device.updated = DateTime.now();
        device.status = DeviceStatus.chat;
        device.passKeyID = normalizedApiKey;

        final updated = await _deviceRepository.update(device);
        if (updated.isEmpty) {
          throw StateError('The API key could not be updated on this device.');
        }
      }

      state.value = AsyncState.completed(normalizedApiKey);
    } catch (error) {
      state.value = AsyncState.error(error);
      rethrow;
    }
  }

  Future<void> loadApiKey() async {
    state.value = const AsyncState.loading();
    try {
      final result = await _deviceInfoLoader();
      final select = GetDevice(result.name, result.code);
      final Optional<Device> optionalDefault =
          await _deviceRepository.findDefaultDevice(select);

      if (optionalDefault.isPresent) {
        final apiKey = optionalDefault.value.passKeyID?.trim();
        if (apiKey != null && apiKey.isNotEmpty) {
          state.value = AsyncState.completed(apiKey);
          return;
        }
      }

      throw StateError('No API key is saved for this device.');
    } catch (error) {
      state.value = AsyncState.error(error);
    }
  }

  void dispose() {
    state.dispose();
  }
}
