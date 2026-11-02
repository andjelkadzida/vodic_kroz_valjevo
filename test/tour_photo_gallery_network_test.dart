import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/pages/shared/tour_photo_gallery.dart';

import 'support/network_image_test_support.dart';

void main() {
  testWidgets('a failed remote photo can be retried without duplicate requests',
      (tester) async {
    var requests = 0;
    final server = (await tester.runAsync(() async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        requests++;
        if (requests == 1) {
          request.response.statusCode = HttpStatus.serviceUnavailable;
        } else {
          request.response.headers.contentType = ContentType('image', 'png');
          request.response.add(testPng);
        }
        await request.response.close();
      });
      return server;
    }))!;
    final httpClient =
        HttpOverrides.runWithHttpOverrides(HttpClient.new, RealHttpOverrides())
          ..findProxy = (_) => 'DIRECT';
    final originalProvider = debugNetworkImageHttpClientProvider;
    debugNetworkImageHttpClientProvider = () => httpClient;
    try {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TourPhotoGallery(
              images: ['http://127.0.0.1:${server.port}/photo.png'],
              semanticLabel: 'Gallery',
              height: 200,
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(TourPhotoGallery));
      final messages = AppLocalizations.of(context)!;
      final retry = find.text(messages.retryImage);
      await waitForWidgetCondition(tester, () => retry.evaluate().isNotEmpty);
      expect(requests, 1);

      await tester.tap(retry);
      final zoomIn = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == messages.zoomIn,
      );
      await waitForWidgetCondition(
        tester,
        () => tester.widget<IconButton>(zoomIn).onPressed != null,
        debug: () {
          final photo = tester.widget<PhotoView>(find.byType(PhotoView).first);
          return 'requests: $requests, retry: ${retry.evaluate().length}, '
              'loading: ${find.byType(CircularProgressIndicator).evaluate().length}, '
              'controller: ${photo.controller?.value}';
        },
      );
      expect(requests, 2);
      expect(retry, findsNothing);
      final controller =
          tester.widget<PhotoView>(find.byType(PhotoView).first).controller!;
      final originalScale = controller.scale!;
      await tester.tap(zoomIn);
      await tester.pump();
      expect(controller.scale, greaterThan(originalScale));
      expect(tester.takeException(), isNull);
    } finally {
      debugNetworkImageHttpClientProvider = originalProvider;
      httpClient.close(force: true);
      await tester.runAsync(() => server.close(force: true));
    }
  });
}
