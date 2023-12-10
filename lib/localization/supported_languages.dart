import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String LANG_CODE = 'languageCode';
const String SCRIPT_CODE = 'scriptCode';
const String COUNTRY_CODE = 'countryCode';

//Supported languages and scripts
const String SERBIAN_LATIN = 'Latn';
const String SERBIAN_CYRL = 'Cyrl';
const String ENGLISH = 'en';
const String GERMAN = 'de';
const String SERBIAN = 'sr';

//Supported country codes
const String SERBIAN_CC = 'sr-RS';
const String ENGLISH_CC = 'en-US';
const String GERMAN_CC = 'de-DE';

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
          languageCode: SERBIAN,
          scriptCode: SERBIAN_LATIN,
          countryCode: SERBIAN_CC);
    case SERBIAN_CYRL:
      return const Locale.fromSubtags(
          languageCode: SERBIAN,
          scriptCode: SERBIAN_CYRL,
          countryCode: SERBIAN_CC);
    case ENGLISH:
      return const Locale.fromSubtags(
          languageCode: ENGLISH, scriptCode: ENGLISH, countryCode: ENGLISH_CC);
    case GERMAN:
      return const Locale.fromSubtags(
          languageCode: GERMAN, scriptCode: GERMAN, countryCode: GERMAN_CC);
    default:
      return const Locale.fromSubtags(
          languageCode: SERBIAN,
          scriptCode: SERBIAN_LATIN,
          countryCode: SERBIAN_CC);
  }
}

AppLocalizations localization(BuildContext context) {
  return AppLocalizations.of(context)!;
}
