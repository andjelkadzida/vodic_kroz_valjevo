import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/localization/language.dart';
import 'package:vodic_kroz_valjevo/navigation/bottom_navigation.dart';
import 'package:vodic_kroz_valjevo/navigation/cutom_app_bar.dart';

void main() {
  const scenarios = [
    _Scenario('small portrait', Size(320, 480), Locale('de'), 2),
    _Scenario(
      'small landscape',
      Size(640, 360),
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
      2,
    ),
    _Scenario('phone', Size(390, 844), Locale('en'), 1),
    _Scenario(
      'tablet portrait',
      Size(800, 1280),
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      2,
    ),
    _Scenario('tablet landscape', Size(1280, 800), Locale('de'), 2),
    _Scenario('extra large text', Size(320, 480), Locale('de'), 3),
    _Scenario('English large text', Size(320, 480), Locale('en'), 3),
    _Scenario(
      'Latin large text',
      Size(320, 480),
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      3,
    ),
    _Scenario(
      'Cyrillic large text',
      Size(320, 480),
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
      3,
    ),
  ];

  for (final scenario in scenarios) {
    testWidgets('navigation fits ${scenario.name}', (tester) async {
      _setViewport(tester, scenario);
      await tester.pumpWidget(_app(
        scenario,
        Builder(builder: (context) {
          return Scaffold(
            appBar: customAppBar(
              context,
              AppLocalizations.of(context)!.restaurantsAndHotels,
              Colors.blue,
              onRefresh: () {},
            ),
            bottomNavigationBar:
                const CustomBottomNavigationBar(unselectedColor: Colors.blue),
            body: const SizedBox.expand(),
          );
        }),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);

      final context = tester.element(find.byType(Scaffold));
      final title =
          find.text(AppLocalizations.of(context)!.restaurantsAndHotels);
      expect(title, findsOneWidget);
      final titleRect = tester.getRect(title);
      final appBarRect = tester.getRect(find.byType(AppBar));
      expect(titleRect.top, greaterThanOrEqualTo(appBarRect.top));
      final titleScroll = find.ancestor(
        of: title,
        matching: find.byType(SingleChildScrollView),
      );
      if (titleScroll.evaluate().isEmpty) {
        expect(titleRect.bottom, lessThanOrEqualTo(appBarRect.bottom));
      } else {
        final scrollable = find.descendant(
          of: titleScroll,
          matching: find.byType(Scrollable),
        );
        await tester.drag(scrollable, const Offset(0, -1000));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.getRect(title).bottom,
            lessThanOrEqualTo(appBarRect.bottom + 0.1));
      }
      _expectTextFits(tester, title);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(
        find.byTooltip(
            MaterialLocalizations.of(context).refreshIndicatorSemanticLabel),
        findsOneWidget,
      );
    });

    testWidgets('language choices remain reachable on ${scenario.name}',
        (tester) async {
      _setViewport(tester, scenario);
      await tester.pumpWidget(_app(
        scenario,
        Builder(builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    showLanguageMenu(context, calledFromNavBar: true),
                child: const Text('Open languages'),
              ),
            ),
          );
        }),
      ));
      await tester.tap(find.text('Open languages'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(LanguageButton), findsNWidgets(4));
      for (var index = 0; index < 4; index++) {
        final button = find.byType(LanguageButton).at(index);
        await tester.ensureVisible(button);
        await tester.pump();
        expect(button.hitTestable(), findsOneWidget);
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      }
    });
  }
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
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scenario.textScale),
      ),
      child: child!,
    ),
    home: home,
  );
}

void _expectTextFits(WidgetTester tester, Finder text) {
  final richText = tester.widget<RichText>(
    find.descendant(of: text, matching: find.byType(RichText)).first,
  );
  final size = tester.getSize(text);
  final painter = TextPainter(
    text: richText.text,
    textDirection: richText.textDirection ?? TextDirection.ltr,
    textAlign: richText.textAlign,
    textScaler: richText.textScaler,
    locale: richText.locale,
    strutStyle: richText.strutStyle,
    textWidthBasis: richText.textWidthBasis,
    textHeightBehavior: richText.textHeightBehavior,
  )..layout(maxWidth: size.width);
  expect(painter.height, lessThanOrEqualTo(size.height + 0.01));
  painter.dispose();
}

class _Scenario {
  const _Scenario(this.name, this.size, this.locale, this.textScale);

  final String name;
  final Size size;
  final Locale locale;
  final double textScale;
}
