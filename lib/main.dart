import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/pages/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const VodicKrozValjevo());
}

class VodicKrozValjevo extends StatefulWidget {
  const VodicKrozValjevo({Key? key}) : super(key: key);

  @override
  State<VodicKrozValjevo> createState() => _VodicKrozValjevo();

  // Setting language
  static void setLanguage(BuildContext buildContext, Locale newLanguage) {
    _VodicKrozValjevo? appState =
        buildContext.findAncestorStateOfType<_VodicKrozValjevo>();
    appState?.setLanguage(newLanguage);
  }
}

class _VodicKrozValjevo extends State<VodicKrozValjevo> {
  Locale? _lang;
  final flutterTts = FlutterTts();

  setLanguage(Locale lang) {
    setState(() {
      _lang = lang;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((lang) => {setLanguage(lang)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Flutter Text-To-Speech voice configuration
    flutterTts.setLanguage(COUNTRY_CODE);
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: _lang,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // builder: (context, child) => AccessibilityTools(child: child),
      home: HomePage(),
    );
  }
}
