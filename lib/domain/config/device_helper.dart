import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceResult {
  String name;
  String code;

  DeviceResult(this.name, this.code);
}

typedef DeviceInfoLoader = Future<DeviceResult> Function();

final class DeviceHelper {
  static Future<DeviceResult> getDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return DeviceResult(
        webInfo.browserName.name,
        webInfo.userAgent ?? webInfo.appName ?? 'web',
      );
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final name = androidInfo.model;
      final code = androidInfo.id;

      if (kDebugMode) {
        print('Running on ${androidInfo.model}');
      }
      return DeviceResult(name, code);
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      final name = iosInfo.name;
      final code = iosInfo.identifierForVendor!;

      if (kDebugMode) {
        print('Running on ${iosInfo.utsname.machine}');
      }
      return DeviceResult(name, code);
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      final name = linuxInfo.name;
      final code = linuxInfo.machineId!;

      if (kDebugMode) {
        print('Running on ${linuxInfo.name}');
      }
      return DeviceResult(name, code);
    } else if (Platform.isMacOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      final name = macOsInfo.computerName;
      final code = macOsInfo.systemGUID!;

      if (kDebugMode) {
        print('Running on ${macOsInfo.computerName}');
      }
      return DeviceResult(name, code);
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      final name = windowsInfo.computerName;
      final code = windowsInfo.deviceId;

      if (kDebugMode) {
        print('Running on ${windowsInfo.computerName}');
      }
      return DeviceResult(name, code);
    }

    throw UnsupportedError('This platform is not supported.');
  }

  static String formatDeviceName(String name) {
    String result = '';
    if (name.isEmpty) {
      throw Error();
    } else if (name.length == 16 || name.length < 16) {
      result = name;
    } else if (name.length > 16) {
      result = name.substring(0, 16);
    }
    return result;
  }
}
