import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static Future<String> getDeviceDetails() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceDetails = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceDetails = 'Android ${androidInfo.model}, ${androidInfo.version.release}, ${androidInfo.device}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceDetails = 'iOS ${iosInfo.utsname.machine}, ${iosInfo.systemVersion}, ${iosInfo.model}';
      }
    } catch (e) {
      deviceDetails = 'Failed to get device info: $e';
    }

    return deviceDetails;
  }
}
