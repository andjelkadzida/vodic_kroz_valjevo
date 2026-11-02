import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/helper/images_loader_helper.dart';
import '../lib/l10n/app_localizations.dart';

void main() {
  testWidgets('a failed guide photo shows a localized error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: tourImageErrorBuilder(context, StateError('offline'), null),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(Scaffold));
    final message = AppLocalizations.of(context)!.errorLoadingData;
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(find.byTooltip(message), findsOneWidget);
  });
}
