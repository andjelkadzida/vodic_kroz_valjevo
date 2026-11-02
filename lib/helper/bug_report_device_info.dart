import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class BugReportDeviceInfo {
  const BugReportDeviceInfo({
    required this.deviceModel,
    required this.operatingSystemVersion,
  });

  final String deviceModel;
  final String operatingSystemVersion;
}

typedef BugReportDeviceInfoLoader = Future<BugReportDeviceInfo> Function();

String? detectBugReportOperatingSystem({TargetPlatform? platform}) {
  switch (platform ?? defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'Android';
    case TargetPlatform.iOS:
      return 'iOS';
    default:
      return 'Other';
  }
}

Future<BugReportDeviceInfo> loadBugReportDeviceInfo({
  DeviceInfoPlugin? deviceInfo,
  TargetPlatform? platform,
}) async {
  final plugin = deviceInfo ?? DeviceInfoPlugin();
  switch (platform ?? defaultTargetPlatform) {
    case TargetPlatform.android:
      final info = await plugin.androidInfo;
      return BugReportDeviceInfo(
        deviceModel: info.model,
        operatingSystemVersion: info.version.release,
      );
    case TargetPlatform.iOS:
      final info = await plugin.iosInfo;
      return BugReportDeviceInfo(
        deviceModel: info.modelName,
        operatingSystemVersion: info.systemVersion,
      );
    default:
      throw UnsupportedError('Device information is only available on mobile.');
  }
}
