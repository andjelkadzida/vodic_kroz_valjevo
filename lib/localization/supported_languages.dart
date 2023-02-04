import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String LANG_CODE = 'languageCode';
const String SCRIPT_CODE = 'scriptCode';

//Supported languages and scripts
const String SERBIAN_LATIN = 'Latn';
const String SERBIAN_CYRL = 'Cyrl';
const String ENGLISH = 'en';
const String GERMAN = 'de';
const String SERBIAN = 'sr';

Future<Locale> setLocale(String scriptCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(SCRIPT_CODE, scriptCode);
  return _lang(scriptCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String scriptCode = _prefs.getString(SCRIPT_CODE) ?? SERBIAN_CYRL;
  return _lang(scriptCode);
}

Locale _lang(String scriptCode) {
  switch (scriptCode) {
    case SERBIAN_LATIN:
      return const Locale.fromSubtags(
          languageCode: SERBIAN, scriptCode: SERBIAN_LATIN);
    case SERBIAN_CYRL:
      return const Locale.fromSubtags(
          languageCode: SERBIAN, scriptCode: SERBIAN_CYRL);
    case ENGLISH:
      return const Locale.fromSubtags(
          languageCode: ENGLISH, scriptCode: ENGLISH);
    case GERMAN:
      return const Locale.fromSubtags(languageCode: GERMAN, scriptCode: GERMAN);
    default:
      return const Locale.fromSubtags(
          languageCode: SERBIAN, scriptCode: SERBIAN_LATIN);
  }
}

AppLocalizations localization(BuildContext context) {
  return AppLocalizations.of(context)!;
}
