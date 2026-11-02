import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/navigation/cutom_app_bar.dart';
import 'package:vodic_kroz_valjevo/policies/privacy_policy.dart';
import 'package:vodic_kroz_valjevo/policies/terms_of_use.dart';

void main() {
  const scenarios = [
    _Scenario('small portrait', Size(320, 480), Locale('de')),
    _Scenario('small landscape', Size(640, 360),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl')),
    _Scenario('tablet landscape', Size(1280, 800), Locale('en')),
  ];

  for (final scenario in scenarios) {
    for (final policy in ['privacy', 'terms']) {
      testWidgets('$policy dialog fits ${scenario.name}', (tester) async {
        _setViewport(tester, scenario);
        await tester.pumpWidget(_app(
          scenario,
          Builder(builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (policy == 'privacy') {
                      showPrivacyPolicy(context);
                    } else {
                      showTermsOfUse(context);
                    }
                  },
                  child: const Text('Open policy'),
                ),
              ),
            );
          }),
        ));
        await tester.tap(find.text('Open policy'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(AlertDialog));
        final close = find.text(AppLocalizations.of(context)!.close);
        expect(close, findsOneWidget);
        expect(close.hitTestable(), findsOneWidget);
      });
    }

    testWidgets('about dialog fits ${scenario.name}', (tester) async {
      _setViewport(tester, scenario);
      await tester.pumpWidget(_app(
        scenario,
        Builder(builder: (context) {
          return Scaffold(
            appBar: customAppBar(
              context,
              AppLocalizations.of(context)!.menu,
              Colors.blue,
            ),
          );
        }),
      ));
      final context = tester.element(find.byType(Scaffold));
      await tester.tap(find.byTooltip(AppLocalizations.of(context)!.aboutApp));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AboutDialog), findsOneWidget);
      final logo = tester.widget<Image>(find.descendant(
        of: find.byType(AboutDialog),
        matching: find.byType(Image),
      ));
      expect(logo.image, isA<ResizeImage>());
      expect((logo.image as ResizeImage).width, 48);
    });
  }

  testWidgets('about logo decoding follows the device pixel ratio',
      (tester) async {
    const scenario = _Scenario('high density', Size(320, 480), Locale('en'));
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = scenario.size * 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(_app(
      scenario,
      Builder(builder: (context) {
        return Scaffold(
          appBar: customAppBar(context, 'Menu', Colors.blue),
        );
      }),
    ));
    final context = tester.element(find.byType(Scaffold));
    await tester.tap(find.byTooltip(AppLocalizations.of(context)!.aboutApp));
    await tester.pumpAndSettle();
    final logo = tester.widget<Image>(find.descendant(
      of: find.byType(AboutDialog),
      matching: find.byType(Image),
    ));
    expect(logo.image, isA<ResizeImage>());
    expect((logo.image as ResizeImage).width, 144);
  });
}

void _setViewport(WidgetTester tester, _Scenario scenario) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = scenario.size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _app(_Scenario scenario, Widget home) {
  return MaterialApp(
    locale: scenario.locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(2)),
      child: child!,
    ),
    home: home,
  );
}

class _Scenario {
  const _Scenario(this.name, this.size, this.locale);

  final String name;
  final Size size;
  final Locale locale;
}
