import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/pages/hotels_and_restaurants.dart';

void main() {
  const scenarios = [
    _LayoutScenario('English', Locale('en'), Size(360, 800), 1),
    _LayoutScenario('German', Locale('de'), Size(320, 800), 1),
    _LayoutScenario(
      'Serbian Latin',
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      Size(320, 800),
      1,
    ),
    _LayoutScenario(
      'Serbian Cyrillic',
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
      Size(360, 800),
      1,
    ),
    _LayoutScenario('large text', Locale('en'), Size(320, 800), 2),
    _LayoutScenario('short screen', Locale('en'), Size(320, 480), 2),
    _LayoutScenario('landscape', Locale('en'), Size(640, 360), 1),
  ];

  for (final scenario in scenarios) {
    testWidgets('menu labels fit without clipping: ${scenario.name}',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = scenario.size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          locale: scenario.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scenario.textScale),
            ),
            child: child!,
          ),
          home: const HotelsAndRestaurants(),
        ),
      );

      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(HotelsAndRestaurants));
      final localizations = AppLocalizations.of(context)!;
      final background = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) return false;
        final image = decoration.image?.image;
        return image is AssetImage &&
            image.assetName ==
                'images/backgroundAndCoverImages/hotelsBackground.jpg';
      });
      expect(background, findsOneWidget);
      final scrollView = find.descendant(
        of: background,
        matching: find.byType(SingleChildScrollView),
      );
      expect(scrollView, findsOneWidget);
      final backgroundRect = tester.getRect(background);
      final scaffoldRect = tester.getRect(find.byType(Scaffold));
      final appBarRect = tester.getRect(find.byType(AppBar));
      final bottomBarRect = tester.getRect(find.byType(BottomNavigationBar));
      expect(backgroundRect.left, closeTo(scaffoldRect.left, 0.01));
      expect(backgroundRect.right, closeTo(scaffoldRect.right, 0.01));
      expect(backgroundRect.top, closeTo(appBarRect.bottom, 0.01));
      expect(backgroundRect.bottom, closeTo(bottomBarRect.top, 0.01));
      for (final label in [localizations.hotels, localizations.restaurants]) {
        final labelFinder = find.text(label);
        expect(labelFinder, findsOneWidget);

        await tester.ensureVisible(labelFinder);
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(labelFinder.hitTestable(), findsOneWidget);

        final inkWell = find.ancestor(
          of: labelFinder,
          matching: find.byType(InkWell),
        );
        expect(inkWell, findsOneWidget);
        expect(tester.widget<InkWell>(inkWell).onTap, isNotNull);

        final richTextFinder = find.descendant(
          of: labelFinder,
          matching: find.byType(RichText),
        );
        final richText = tester.widget<RichText>(richTextFinder);
        final renderedSize = tester.getSize(richTextFinder);
        final labelRect = tester.getRect(richTextFinder);
        final viewportRect = tester.getRect(scrollView);
        final card = find.ancestor(
          of: labelFinder,
          matching: find.byType(Card),
        );
        final cardRect = tester.getRect(card);
        expect(cardRect.center.dx, closeTo(backgroundRect.center.dx, 0.01));
        expect(labelRect.left, greaterThanOrEqualTo(cardRect.left));
        expect(labelRect.right, lessThanOrEqualTo(cardRect.right));
        expect(labelRect.top, greaterThanOrEqualTo(viewportRect.top - 0.01));
        expect(labelRect.bottom, lessThanOrEqualTo(viewportRect.bottom + 0.01));

        final painter = TextPainter(
          text: richText.text,
          textDirection: richText.textDirection ?? TextDirection.ltr,
          textAlign: richText.textAlign,
          textScaler: richText.textScaler,
          locale: richText.locale,
          strutStyle: richText.strutStyle,
          textWidthBasis: richText.textWidthBasis,
          textHeightBehavior: richText.textHeightBehavior,
        )..layout(maxWidth: renderedSize.width);
        final requiredHeight = painter.height;
        painter.dispose();
        expect(
          requiredHeight,
          lessThanOrEqualTo(renderedSize.height + 0.01),
          reason: '$label must be fully visible',
        );
      }
    });
  }
}

class _LayoutScenario {
  const _LayoutScenario(this.name, this.locale, this.size, this.textScale);

  final String name;
  final Locale locale;
  final Size size;
  final double textScale;
}
