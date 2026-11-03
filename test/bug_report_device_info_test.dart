import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vodic_kroz_valjevo/helper/bug_report_device_info.dart';

void main() {
  test('detects supported operating systems and reports unsupported ones', () {
    expect(detectBugReportOperatingSystem(platform: TargetPlatform.android),
        'Android');
    expect(detectBugReportOperatingSystem(platform: TargetPlatform.iOS), 'iOS');
    expect(detectBugReportOperatingSystem(platform: TargetPlatform.windows),
        'Other');
  });

  test('reads Android model and OS release', () async {
    final plugin = DeviceInfoPlugin.setMockInitialValues(
      androidDeviceInfo: AndroidDeviceInfo.fromMap({
        'version': {
          'codename': 'REL',
          'incremental': '1',
          'previewSdkInt': 0,
          'release': '15',
          'sdkInt': 35,
        },
        'board': 'board',
        'bootloader': 'bootloader',
        'brand': 'brand',
        'device': 'device',
        'display': 'display',
        'fingerprint': 'fingerprint',
        'hardware': 'hardware',
        'host': 'host',
        'id': 'id',
        'manufacturer': 'manufacturer',
        'model': 'Pixel 9',
        'product': 'product',
        'tags': 'tags',
        'type': 'user',
        'isPhysicalDevice': true,
        'freeDiskSize': 0,
        'totalDiskSize': 0,
        'isLowRamDevice': false,
        'physicalRamSize': 0,
        'availableRamSize': 0,
      }),
    );

    final info = await loadBugReportDeviceInfo(
      deviceInfo: plugin,
      platform: TargetPlatform.android,
    );
    expect(info.deviceModel, 'Pixel 9');
    expect(info.operatingSystemVersion, '15');
  });

  test('reads the user-facing iOS model and system version', () async {
    final plugin = DeviceInfoPlugin.setMockInitialValues(
      iosDeviceInfo: IosDeviceInfo.fromMap({
        'name': 'iPhone',
        'systemName': 'iOS',
        'systemVersion': '18.1',
        'model': 'iPhone',
        'modelName': 'iPhone 16 Pro',
        'localizedModel': 'iPhone',
        'freeDiskSize': 0,
        'totalDiskSize': 0,
        'isPhysicalDevice': true,
        'isiOSAppOnMac': false,
        'isiOSAppOnVision': false,
        'physicalRamSize': 0,
        'availableRamSize': 0,
        'utsname': {
          'sysname': 'Darwin',
          'nodename': 'test',
          'release': '1',
          'version': '1',
          'machine': 'iPhone17,1',
        },
      }),
    );

    final info = await loadBugReportDeviceInfo(
      deviceInfo: plugin,
      platform: TargetPlatform.iOS,
    );
    expect(info.deviceModel, 'iPhone 16 Pro');
    expect(info.operatingSystemVersion, '18.1');
  });

  test('reports unsupported platforms', () async {
    await expectLater(
      loadBugReportDeviceInfo(platform: TargetPlatform.windows),
      throwsUnsupportedError,
    );
  });
}
