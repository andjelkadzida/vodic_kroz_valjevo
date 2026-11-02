import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/helper/remote_data_builder.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/main.dart';

void main() {
  testWidgets('shows a localized error and retries the online request',
      (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RemoteDataBuilder<List<String>>(
          queryKey: 'de',
          standalone: true,
          load: () async {
            attempts++;
            if (attempts == 1) throw StateError('offline');
            return ['Loaded'];
          },
          onData: (data) => Scaffold(body: Text(data.single)),
        ),
      ),
    );
    await tester.pump();

    final context =
        tester.element(find.byType(RemoteDataBuilder<List<String>>));
    expect(find.text(AppLocalizations.of(context)!.errorLoadingData),
        findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(
        find.byTooltip(
            MaterialLocalizations.of(context).refreshIndicatorSemanticLabel),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    await tester.pump();
    expect(attempts, 2);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('re-fetches when the selected language changes', (tester) async {
    final requests = <String>[];
    Widget app(String locale) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RemoteDataBuilder<String>(
            queryKey: locale,
            load: () async {
              requests.add(locale);
              return locale;
            },
            onData: (data) => Text(data, textDirection: TextDirection.ltr),
          ),
        );

    await tester.pumpWidget(app('en'));
    await tester.pump();
    expect(find.text('en'), findsOneWidget);

    await tester.pumpWidget(app('sr_Cyrl'));
    await tester.pump();
    expect(find.text('sr_Cyrl'), findsOneWidget);
    expect(requests, ['en', 'sr_Cyrl']);
  });

  testWidgets('reports empty results and offers a retry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RemoteDataBuilder<List<String>>(
          queryKey: 'empty',
          load: () async => [],
          onData: (_) => const Text('unexpected'),
        ),
      ),
    );
    await tester.pump();
    final context =
        tester.element(find.byType(RemoteDataBuilder<List<String>>));
    expect(find.text(AppLocalizations.of(context)!.noDataAvailable),
        findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('retry invalidates the cache and reloads once', (tester) async {
    final signal = ValueNotifier<int>(0);
    addTearDown(signal.dispose);
    var loads = 0;
    var invalidations = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RemoteDataBuilder<List<String>>(
          queryKey: 'cache',
          refreshSignal: signal,
          onRetry: () {
            invalidations++;
            signal.value++;
          },
          load: () async {
            loads++;
            return loads == 1 ? [] : ['refreshed'];
          },
          onData: (data) => Text(data.single, textDirection: TextDirection.ltr),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    await tester.pump();
    expect(invalidations, 1);
    expect(loads, 2);
    expect(find.text('refreshed'), findsOneWidget);
  });

  testWidgets('startup failures are visible and initialization can be retried',
      (tester) async {
    var attempts = 0;
    final retry = Completer<bool>();
    await tester.pumpWidget(ApplicationBootstrap(
      initialize: () {
        attempts++;
        if (attempts == 1) return Future.error(StateError('bad configuration'));
        return retry.future;
      },
    ));
    await tester.pump();
    final context = tester.element(find.byType(Scaffold));
    expect(find.text(AppLocalizations.of(context)!.errorLoadingData),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(attempts, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    retry.completeError(StateError('still unavailable'));
    await tester.pump();
    expect(find.text(AppLocalizations.of(context)!.errorLoadingData),
        findsOneWidget);
  });
}
