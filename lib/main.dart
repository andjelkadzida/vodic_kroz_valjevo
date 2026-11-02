import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_config/back4app_config_loader.dart';
import 'helper/accessibility_theme.dart';
import 'helper/connection_problem_view.dart';
import 'helper/internet_connectivity.dart';
import 'localization/locale_controller.dart';
import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';
import 'text_to_speech/text_to_speech_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ApplicationBootstrap());
}

Future<bool> initializeApplication() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('isFirstRun') ?? true;

  if (isFirstRun) {
    await prefs.setBool('isFirstRun', true);
  }

  final back4App = await loadBack4AppConfig();

  await Future.wait([
    TextToSpeechConfig.instance.setEngine(),
    Parse().initialize(
      back4App.applicationId,
      back4App.serverUrl.toString(),
      clientKey: back4App.clientKey,
    ),
  ]);

  return isFirstRun;
}

class ApplicationBootstrap extends StatefulWidget {
  const ApplicationBootstrap(
      {Key? key, this.initialize = initializeApplication})
      : super(key: key);

  final Future<bool> Function() initialize;

  @override
  State<ApplicationBootstrap> createState() => _ApplicationBootstrapState();
}

class _ApplicationBootstrapState extends State<ApplicationBootstrap> {
  late Future<bool> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = widget.initialize();
  }

  void _retry() {
    setState(() {
      _initialization = widget.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return VodicKrozValjevo(isFirstRun: snapshot.data!);
        }

        return MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          debugShowCheckedModeBanner: false,
          home: Builder(
            builder: (context) {
              final messages = AppLocalizations.of(context)!;
              final hasError =
                  snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasError;
              return Scaffold(
                backgroundColor: hasError ? null : Colors.white,
                body: !hasError
                    ? const _LaunchSplash()
                    : Center(
                        child: isPossibleConnectionFailure(snapshot.error!)
                            ? ConnectionAwareFailure(onRetry: _retry)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(messages.errorLoadingData),
                                  IconButton(
                                    onPressed: _retry,
                                    tooltip: MaterialLocalizations.of(context)
                                        .refreshIndicatorSemanticLabel,
                                    icon: Icon(
                                      Icons.refresh,
                                      semanticLabel:
                                          MaterialLocalizations.of(context)
                                              .refreshIndicatorSemanticLabel,
                                    ),
                                  ),
                                ],
                              ),
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LaunchSplash extends StatelessWidget {
  const _LaunchSplash();

  @override
  Widget build(BuildContext context) {
    final messages = AppLocalizations.of(context)!;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logoSize =
              (constraints.biggest.shortestSide * 0.5).clamp(0.0, 168.0);
          final cacheWidth = (logoSize * MediaQuery.devicePixelRatioOf(context))
              .ceil()
              .clamp(1, 672);
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/splash_logo.png',
                    width: logoSize,
                    height: logoSize,
                    cacheWidth: cacheWidth,
                    fit: BoxFit.contain,
                    semanticLabel: messages.appLogo,
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: const Color(0xFF5A1218),
                    semanticsLabel: messages.loading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VodicKrozValjevo extends StatefulWidget {
  final bool isFirstRun;

  const VodicKrozValjevo({Key? key, required this.isFirstRun})
      : super(key: key);

  @override
  State<VodicKrozValjevo> createState() => _VodicKrozValjevo();
}

class _VodicKrozValjevo extends State<VodicKrozValjevo> {
  late final LocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = LocaleController()..load();
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) => MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: _localeController.locale,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Roboto',
            primarySwatch: Colors.blue,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: accessibleLinkColor),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            canvasColor: Colors.transparent,
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
