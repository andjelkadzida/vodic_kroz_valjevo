import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/main.dart';

void main() {
  const scenarios = <_SplashScenario>[
    _SplashScenario('small portrait', Size(320, 480), Locale('de'), 3, 1),
    _SplashScenario(
      'small landscape',
      Size(640, 360),
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
      2,
      1,
    ),
    _SplashScenario('tablet', Size(1280, 800), Locale('en'), 1, 1),
    _SplashScenario('high density', Size(390, 844), Locale('en'), 2, 3),
    _SplashScenario('compact window', Size(200, 160), Locale('en'), 3, 1),
  ];

  for (final scenario in scenarios) {
    testWidgets('startup splash fits ${scenario.name}', (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.devicePixelRatio = scenario.pixelRatio;
      tester.view.physicalSize = scenario.size * scenario.pixelRatio;
      tester.platformDispatcher.localeTestValue = scenario.locale;
      tester.platformDispatcher.textScaleFactorTestValue = scenario.textScale;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final initialization = Completer<bool>();
      try {
        await tester.pumpWidget(
          ApplicationBootstrap(initialize: () => initialization.future),
        );
        await tester.pump();

        final context = tester.element(find.byType(Scaffold));
        final messages = AppLocalizations.of(context)!;
        final imageFinder = find.byType(Image);
        final progress = find.byType(CircularProgressIndicator);
        expect(imageFinder, findsOneWidget);
        expect(progress, findsOneWidget);
        final image = tester.widget<Image>(imageFinder);
        expect(image.image, isA<ResizeImage>());
        final provider = (image.image as ResizeImage).imageProvider;
        expect(provider, isA<AssetImage>());
        expect((provider as AssetImage).assetName, 'images/splash_logo.png');

        final imageRect = tester.getRect(imageFinder);
        final progressRect = tester.getRect(progress);
        final screen = Offset.zero & scenario.size;
        expect(screen.contains(imageRect.topLeft), isTrue);
        expect(screen.contains(imageRect.bottomRight), isTrue);
        expect(screen.contains(progressRect.topLeft), isTrue);
        expect(screen.contains(progressRect.bottomRight), isTrue);
        expect(imageRect.width, lessThanOrEqualTo(168));
        expect(imageRect.width, imageRect.height);
        expect(find.bySemanticsLabel(messages.appLogo), findsOneWidget);
        expect(find.bySemanticsLabel(messages.loading), findsOneWidget);
        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        semantics.dispose();
      }
    });
  }

  testWidgets('splash is replaced by the app when initialization completes',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final initialization = Completer<bool>();
    await tester.pumpWidget(
      ApplicationBootstrap(initialize: () => initialization.future),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    initialization.complete(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(VodicKrozValjevo), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _SplashScenario {
  const _SplashScenario(
      this.name, this.size, this.locale, this.textScale, this.pixelRatio);

  final String name;
  final Size size;
  final Locale locale;
  final double textScale;
  final double pixelRatio;
}
