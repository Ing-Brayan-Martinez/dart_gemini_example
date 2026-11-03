import 'package:dart_gemini_example/data/database/repository/device_repository.dart';
import 'package:dart_gemini_example/domain/controller/api_key_controller.dart';
import 'package:dart_gemini_example/domain/controller/splash_controller.dart';
import 'package:dart_gemini_example/domain/config/device_helper.dart';
import 'package:dart_gemini_example/domain/config/enums.dart';
import 'package:dart_gemini_example/domain/model/async_state.dart';
import 'package:dart_gemini_example/domain/model/device.dart';
import 'package:dart_gemini_example/domain/model/device_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optional/optional.dart';

void main() {
  final deviceInfo = DeviceResult('Test device', 'test-device-id');

  test('splash controller creates a device when none is saved', () async {
    final repository = FakeDeviceRepository();
    final controller = SplashController(
      repository,
      deviceInfoLoader: () async => deviceInfo,
    );
    addTearDown(controller.dispose);

    await controller.loadDeviceStatus();

    expect(controller.state.value.status, AsyncStateStatus.completed);
    expect(controller.state.value.data?.name, deviceInfo.name);
    expect(repository.device?.status, DeviceStatus.apikey);
  });

  test('API key controller saves the key and reports completed state',
      () async {
    final repository = FakeDeviceRepository();
    final controller = ApiKeyController(
      repository,
      deviceInfoLoader: () async => deviceInfo,
    );
    addTearDown(controller.dispose);

    await controller.assignApiKey(' test-key ');

    expect(controller.state.value.status, AsyncStateStatus.completed);
    expect(controller.state.value.data, 'test-key');
    expect(repository.device?.passKeyID, 'test-key');
    expect(repository.device?.status, DeviceStatus.chat);
  });

  test('API key controller exposes repository errors in its state', () async {
    final controller = ApiKeyController(
      FakeDeviceRepository()..findError = StateError('database unavailable'),
      deviceInfoLoader: () async => deviceInfo,
    );
    addTearDown(controller.dispose);

    await expectLater(controller.assignApiKey('test-key'), throwsStateError);

    expect(controller.state.value.status, AsyncStateStatus.error);
    expect(controller.state.value.error, isA<StateError>());
  });
}

final class FakeDeviceRepository implements DeviceRepository {
  Device? device;
  Object? findError;

  @override
  Future<Optional<Device>> create(Device param) async {
    device = param;
    return Optional.of(param);
  }

  @override
  Future<Optional<Device>> update(Device param) async {
    device = param;
    return Optional.of(param);
  }

  @override
  Future<Optional<Device>> findDefaultDevice(GetDevice select) async {
    if (findError case final error?) throw error;
    if (device case final saved?
        when saved.name == select.name && saved.code == select.code) {
      return Optional.of(saved);
    }
    return const Optional.empty();
  }

  @override
  Future<int> isEmpty() async => device == null ? 1 : 0;

  @override
  Future<void> truncate() async {
    device = null;
  }
}
