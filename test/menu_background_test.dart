import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/l10n/app_localizations.dart';
import '../lib/navigation/bottom_navigation.dart';
import '../lib/pages/menu/menu_item.dart';
import '../lib/pages/menu/menu_page.dart';

void main() {
  const scenarios = <_Scenario>[
    _Scenario('phone portrait', Size(390, 844), Locale('en'), 1),
    _Scenario('tall portrait', Size(400, 1100), Locale('de'), 1),
    _Scenario('phone landscape', Size(640, 360), Locale('en'), 2),
    _Scenario('tablet landscape', Size(1280, 800),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'), 1),
    _Scenario('large text', Size(320, 480),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'), 3),
    _Scenario('landscape cutout', Size(800, 360), Locale('de'), 2,
        horizontalInset: 28),
  ];

  for (final scenario in scenarios) {
    testWidgets('menu background fills the content area on ${scenario.name}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = scenario.size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      if (scenario.horizontalInset > 0) {
        tester.view.padding = FakeViewPadding(
          left: scenario.horizontalInset,
          right: scenario.horizontalInset,
        );
        addTearDown(tester.view.resetPadding);
      }

      await tester.pumpWidget(
        MaterialApp(
          locale: scenario.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scenario.textScale),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: const MenuPage(),
        ),
      );
      await tester.pump();

      final background = find.byWidgetPredicate((widget) {
        if (widget is! Container || widget.decoration is! BoxDecoration) {
          return false;
        }
        final decoration = widget.decoration! as BoxDecoration;
        final image = decoration.image?.image;
        return image is AssetImage &&
            image.assetName == 'images/backgroundAndCoverImages/background.jpg';
      });
      expect(background, findsOneWidget);
      final decoration =
          tester.widget<Container>(background).decoration! as BoxDecoration;
      expect(decoration.image!.fit, BoxFit.cover);
      Object? imageError;
      await tester.runAsync(() => precacheImage(
            const AssetImage('images/backgroundAndCoverImages/background.jpg'),
            tester.element(background),
            onError: (error, stackTrace) => imageError = error,
          ));
      await tester.pump();
      expect(imageError, isNull);
      expect(
        tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        const Color.fromRGBO(11, 20, 32, 1),
      );
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .backgroundColor,
        Colors.white,
      );

      final scaffold = tester.getRect(find.byType(Scaffold));
      final appBar = tester.getRect(find.byType(AppBar));
      final navigation = tester.getRect(find.byType(CustomBottomNavigationBar));
      final image = tester.getRect(background);
      expect(image.left, closeTo(scaffold.left, 0.1));
      expect(image.right, closeTo(scaffold.right, 0.1));
      expect(image.top, closeTo(appBar.bottom, 0.1));
      expect(image.bottom, closeTo(navigation.top, 0.1));

      final scrollable = find.descendant(
        of: background,
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(scrollable).position;
      if (position.maxScrollExtent > 0) {
        await tester.drag(scrollable, Offset(0, -scenario.size.height * 2));
        await tester.pumpAndSettle();
        expect(position.pixels, greaterThan(0));
        expect(tester.getRect(background), image);
      }
      final messages = AppLocalizations.of(tester.element(background))!;
      for (final label in [
        messages.aboutCity,
        messages.sights,
        messages.sportRecreation,
        messages.restaurantsAndHotels,
      ]) {
        final title = find.text(label);
        final item = find.ancestor(
          of: title,
          matching: find.byType(MenuItem),
        );
        expect(item, findsOneWidget);
        await Scrollable.ensureVisible(tester.element(title), alignment: 0.5);
        await tester.pump();
        expect(
          title.hitTestable(),
          findsOneWidget,
          reason: 'title=${tester.getRect(title)}, '
              'item=${tester.getRect(item)}, '
              'viewport=${tester.getRect(scrollable)}, '
              'scroll=${position.pixels}/${position.maxScrollExtent}',
        );
        expect(tester.getRect(background), image);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

class _Scenario {
  const _Scenario(this.name, this.size, this.locale, this.textScale,
      {this.horizontalInset = 0});

  final String name;
  final Size size;
  final Locale locale;
  final double textScale;
  final double horizontalInset;
}
