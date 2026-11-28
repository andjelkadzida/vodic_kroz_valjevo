import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodic_kroz_valjevo/main.dart';

import 'support/network_image_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const tts = MethodChannel('flutter_tts');

  group('VodicKrozValjevo', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'scriptCode': 'de'});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(tts, (_) async => 1);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(tts, null);
    });

    testWidgets('restores the saved language', (WidgetTester tester) async {
      await tester.pumpWidget(const VodicKrozValjevo(isFirstRun: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final locale =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).locale;
      expect(locale?.languageCode, 'de');
    });

    for (final scenario in const [
      _BackgroundScenario(Size(390, 844), 1, 633),
      _BackgroundScenario(Size(844, 390), 2, 1688),
    ]) {
      testWidgets('home background is downsampled for ${scenario.size}',
          (tester) async {
        tester.view.devicePixelRatio = scenario.devicePixelRatio;
        tester.view.physicalSize = scenario.size * scenario.devicePixelRatio;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const VodicKrozValjevo(isFirstRun: true));
        await tester.pump();
        final background = find.byWidgetPredicate((widget) {
          if (widget is! Image || widget.image is! ResizeImage) return false;
          final provider = (widget.image as ResizeImage).imageProvider;
          return provider is AssetImage &&
              provider.assetName ==
                  'images/backgroundAndCoverImages/homeImage.jpg';
        });
        final image = tester.widget<Image>(background);
        expect(image.fit, BoxFit.cover);

        final stream = image.image.resolve(
          createLocalImageConfiguration(tester.element(background)),
        );
        final decoded = Completer<Size>();
        final listener = ImageStreamListener(
          (info, _) {
            decoded.complete(
              Size(info.image.width.toDouble(), info.image.height.toDouble()),
            );
            info.dispose();
          },
          onError: (error, stackTrace) =>
              decoded.completeError(error, stackTrace),
        );
        stream.addListener(listener);
        try {
          await waitForWidgetCondition(tester, () => decoded.isCompleted);
          expect((await decoded.future).width, scenario.width);
        } finally {
          stream.removeListener(listener);
        }
      });
    }
  });
}

class _BackgroundScenario {
  const _BackgroundScenario(this.size, this.devicePixelRatio, this.width);

  final Size size;
  final double devicePixelRatio;
  final int width;
}
