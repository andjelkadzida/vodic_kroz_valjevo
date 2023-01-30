import 'package:flutter/material.dart';
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

  //Setting language
  static void setLanguage(BuildContext buildContext, Locale newLanguage) {
    _VodicKrozValjevo? appState =
        buildContext.findAncestorStateOfType<_VodicKrozValjevo>();
    appState?.setLanguage(newLanguage);
  }
}

class _VodicKrozValjevo extends State<VodicKrozValjevo> {
  Locale? _lang;

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
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: _lang,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
