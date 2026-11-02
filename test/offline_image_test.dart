import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vodic_kroz_valjevo/helper/images_loader_helper.dart';
import 'package:vodic_kroz_valjevo/helper/internet_connectivity.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/pages/shared/tour_photo_gallery.dart';

import 'support/network_image_test_support.dart';

void main() {
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const events = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
  const settings = MethodChannel('com.spencerccf.app_settings/methods');
  for (final gallery in [false, true]) {
    testWidgets(
        '${gallery ? 'gallery' : 'thumbnail'} recovers after reconnecting',
        (tester) async {
      var connected = false;
      var serverOnline = false;
      var successfulRequests = 0;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
          connectivity, (_) async => [connected ? 'wifi' : 'none']);
      messenger.setMockMethodCallHandler(events, (_) async => null);
      messenger.setMockMethodCallHandler(settings, (_) async => null);
      final server = (await tester.runAsync(() async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        server.listen((request) async {
          if (!serverOnline) {
            final socket =
                await request.response.detachSocket(writeHeaders: false);
            socket.destroy();
            return;
          }
          successfulRequests++;
          request.response.headers.contentType = ContentType('image', 'png');
          request.response.add(testPng);
          await request.response.close();
        });
        return server;
      }))!;
      final httpClient = HttpOverrides.runWithHttpOverrides(
          HttpClient.new, RealHttpOverrides())
        ..findProxy = (_) => 'DIRECT';
      final originalProvider = debugNetworkImageHttpClientProvider;
      debugNetworkImageHttpClientProvider = () => httpClient;
      try {
        final url = 'http://127.0.0.1:${server.port}/photo.png';
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: gallery
                  ? TourPhotoGallery(
                      images: [url],
                      semanticLabel: 'Gallery',
                      height: 200,
                    )
                  : SizedBox(
                      width: 240,
                      height: 200,
                      child: TourImage(image: url, fit: BoxFit.cover),
                    ),
            ),
          ),
        );
        final context = tester.element(find.byType(Scaffold));
        final messages = AppLocalizations.of(context)!;
        await waitForWidgetCondition(
            tester,
            () =>
                find.text(messages.noInternetConnection).evaluate().isNotEmpty);
        expect(find.text(messages.openSettings), findsOneWidget);
        expect(find.text(messages.errorLoadingData), findsNothing);

        serverOnline = true;
        connected = true;
        await NetworkStatusMonitor.instance.refresh();
        await waitForWidgetCondition(tester, () {
          if (gallery) {
            final zoom = find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton && widget.tooltip == messages.zoomIn,
            );
            return zoom.evaluate().isNotEmpty &&
                tester.widget<IconButton>(zoom).onPressed != null;
          }
          return find
              .byWidgetPredicate(
                (widget) => widget is RawImage && widget.image != null,
              )
              .evaluate()
              .isNotEmpty;
        });
        expect(successfulRequests, greaterThanOrEqualTo(1));
        expect(find.text(messages.noInternetConnection), findsNothing);
        if (gallery) {
          expect(find.byType(PhotoView), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        debugNetworkImageHttpClientProvider = originalProvider;
        httpClient.close(force: true);
        await tester.runAsync(() => server.close(force: true));
        messenger.setMockMethodCallHandler(connectivity, null);
        messenger.setMockMethodCallHandler(events, null);
        messenger.setMockMethodCallHandler(settings, null);
      }
    });
  }
}
