import 'dart:io';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/database_config/tour_data_service.dart';
import '../lib/l10n/app_localizations.dart';
import '../lib/pages/hotels/hotel_details.dart';
import '../lib/pages/hotels/hotels.dart';
import '../lib/pages/hotels_and_restaurants.dart';
import '../lib/pages/menu/menu_page.dart';
import '../lib/pages/shared/tour_photo_gallery.dart';
import '../lib/pages/sights/sight_details_page.dart';
import '../lib/pages/sport_and_recreation.dart';

import 'support/fake_parse_client.dart';
import 'support/tour_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeParseClient client;
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const events = MethodChannel('dev.fluttercommunity.plus/connectivity_status');

  setUpAll(() async {
    client = FakeParseClient(makeTourFixtures());
    await Parse().initialize(
      'test-application',
      'https://example.test/parse',
      clientKey: 'test-client',
      appName: 'Test',
      appVersion: '1',
      appPackageName: 'test.app',
      coreStore: CoreStoreMemoryImp(),
      fileDirectory: Directory.systemTemp.path,
      restRetryIntervals: [],
      clientCreator: (
              {required bool sendSessionId,
              SecurityContext? securityContext}) =>
          client,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    for (final collection in TourCollection.values) {
      TourDataService.instance.refresh(collection);
    }
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, (_) async => ['none']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, null);
    messenger.setMockMethodCallHandler(events, null);
  });

  testWidgets('photo controls navigate, zoom, move, and reset without gestures',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(
      const Scaffold(
        body: SingleChildScrollView(
          child: TourPhotoGallery(
            images: [
              'images/appLogo.png',
              'images/backgroundAndCoverImages/background.jpg',
            ],
            semanticLabel: 'Gallery',
            height: 200,
          ),
        ),
      ),
    ));
    final galleryContext = tester.element(find.byType(TourPhotoGallery));
    await tester.runAsync(() => precacheImage(
          const AssetImage('images/appLogo.png'),
          galleryContext,
        ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final messages = AppLocalizations.of(galleryContext)!;
    final photo = tester.widget<PhotoView>(find.byType(PhotoView).first);
    final controller = photo.controller!;
    final originalScale = controller.scale;
    expect(originalScale, isNotNull);

    await tester.tap(find.byTooltip(messages.zoomIn));
    await tester.pump();
    expect(controller.scale, greaterThan(originalScale!));
    expect(find.byTooltip(messages.movePhotoUp), findsOneWidget);
    await tester.tap(find.byTooltip(messages.movePhotoUp));
    await tester.pump();
    expect(controller.position, isNot(Offset.zero));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await tester.tap(find.byTooltip(messages.resetZoom));
    await tester.pump();
    expect(controller.scale, closeTo(originalScale, 0.0001));
    expect(controller.position, Offset.zero);

    final next = find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == messages.nextPhoto,
    );
    final nextIcon =
        find.descendant(of: next, matching: find.byIcon(Icons.chevron_right));
    Focus.of(tester.element(nextIcon)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text(messages.positionInList(2, 2)), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  for (final dimensions in <List<double>>[
    [200, 160, 200, 120],
    [120, 160, 80, 160],
  ]) {
    final initialWidth = dimensions[0];
    final initialHeight = dimensions[1];
    final resizedWidth = dimensions[2];
    final resizedHeight = dimensions[3];
    testWidgets(
        'photo reset fits after resizing '
        '${initialWidth}x$initialHeight to ${resizedWidth}x$resizedHeight',
        (tester) async {
      Widget gallery(double width, double height) => _app(
            Scaffold(
              body: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: width,
                    child: TourPhotoGallery(
                      images: const ['images/appLogo.png'],
                      semanticLabel: 'Gallery',
                      height: height,
                    ),
                  ),
                ),
              ),
            ),
          );

      await tester.pumpWidget(gallery(initialWidth, initialHeight));
      final galleryContext = tester.element(find.byType(TourPhotoGallery));
      await tester.runAsync(() => precacheImage(
            const AssetImage('images/appLogo.png'),
            galleryContext,
          ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final messages = AppLocalizations.of(galleryContext)!;
      final controller =
          tester.widget<PhotoView>(find.byType(PhotoView).first).controller!;
      final originalScale = controller.scale!;
      await tester.tap(find.byTooltip(messages.zoomIn));
      await tester.pump();
      expect(controller.scale, greaterThan(originalScale));

      await tester.pumpWidget(gallery(resizedWidth, resizedHeight));
      await tester.pump();
      await tester.ensureVisible(find.byTooltip(messages.resetZoom));
      await tester.pump();
      await tester.tap(find.byTooltip(messages.resetZoom));
      await tester.pump();
      final oldFit =
          initialWidth < initialHeight ? initialWidth : initialHeight;
      final newFit =
          resizedWidth < resizedHeight ? resizedWidth : resizedHeight;
      expect(
          controller.scale, closeTo(originalScale * newFit / oldFit, 0.0001));
      expect(controller.position, Offset.zero);
      final zoomOut = tester.widget<IconButton>(find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == messages.zoomOut,
      ));
      expect(zoomOut.onPressed, isNull);
    });
  }

  testWidgets('a refreshed gallery replaces its images and resets its page',
      (tester) async {
    Widget gallery(List<String> images) => _app(
          Scaffold(
            body: TourPhotoGallery(
              images: images,
              semanticLabel: 'Gallery',
              height: 200,
            ),
          ),
        );

    await tester.pumpWidget(gallery(const [
      'images/appLogo.png',
      'images/backgroundAndCoverImages/background.jpg',
    ]));
    final context = tester.element(find.byType(TourPhotoGallery));
    final messages = AppLocalizations.of(context)!;
    await tester.tap(find.byTooltip(messages.nextPhoto));
    await tester.pump();
    expect(find.text(messages.positionInList(2, 2)), findsOneWidget);

    await tester.pumpWidget(gallery(const ['images/appLogo.png']));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(messages.positionInList(1, 1)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an unavailable photo offers a labeled retry', (tester) async {
    await tester.pumpWidget(_app(
      const Scaffold(
        body: TourPhotoGallery(
          images: [
            'images/appLogo.png',
            'https://example.test/unavailable.jpg',
          ],
          semanticLabel: 'Gallery',
          height: 200,
        ),
      ),
    ));
    final context = tester.element(find.byType(TourPhotoGallery));
    final messages = AppLocalizations.of(context)!;
    await tester.tap(find.byTooltip(messages.nextPhoto));
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final retry = find.text(messages.retryImage);
    expect(retry, findsOneWidget);
    await tester.tap(retry);
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    expect(find.text(messages.positionInList(2, 2)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recreation items can be changed with buttons', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const SportsAndRecreation()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final context = tester.element(find.byType(SportsAndRecreation));
    final messages = AppLocalizations.of(context)!;
    final next = find.byTooltip(messages.nextItem).first;
    await tester.ensureVisible(next);
    await tester.pump();
    await tester.tap(next);
    await tester.pump();
    expect(find.text(client.records['Parks']![1]['title_en']), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('hotel list is accessible offline and opens details by keyboard',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const Hotels()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    final context = tester.element(find.byType(Hotels));
    final messages = AppLocalizations.of(context)!;
    await tester.tap(find.text(messages.listView));
    await tester.pump();
    final title = client.records['Hotels']!.first['title_en'] as String;
    expect(find.text(title), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    Focus.of(tester.element(find.text(title))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(HotelDetailsPage), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('map and list choices remain reachable at 300% text',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: const TextScaler.linear(3),
          ),
          child: child!,
        ),
        home: const Hotels(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final context = tester.element(find.byType(Hotels));
    final messages = AppLocalizations.of(context)!;
    final listChoice = find.text(messages.listView);
    await tester.ensureVisible(listChoice);
    await tester.pump();
    expect(listChoice.hitTestable(), findsOneWidget);
    await tester.tap(listChoice);
    await tester.pump();
    expect(
        find.text(client.records['Hotels']!.first['title_de']), findsOneWidget);
  });

  testWidgets('screen readers can independently activate read and stop',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_app(const SightDetailsPage(sightId: 'Sights1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final context = tester.element(find.byType(SightDetailsPage));
      final messages = AppLocalizations.of(context)!;
      final read =
          tester.getSemantics(find.byTooltip(messages.tapToHearSightDetails));
      final stop = tester.getSemantics(find.byTooltip(messages.stopReading));
      expect(read.label, contains(messages.tapToHearSightDetails));
      expect(stop.label, contains(messages.stopReading));
      expect(read.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(stop.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('decorative animations respect reduced-motion settings',
      (tester) async {
    for (final page in [const MenuPage(), const HotelsAndRestaurants()]) {
      await tester.pumpWidget(_app(page));
      await tester.pump();
      final animations =
          tester.widgetList<LottieBuilder>(find.byType(LottieBuilder));
      expect(animations, isNotEmpty);
      expect(
          animations.every((animation) => animation.animate == false), isTrue);
    }
  });
}

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: home,
    );
