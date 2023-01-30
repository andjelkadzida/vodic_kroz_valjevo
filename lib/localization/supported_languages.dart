import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String LANG_CODE = 'languageCode';

//Supported languages
const String SERBIAN = 'sr';
const String ENGLISH = 'en';
const String GERMAN = 'de';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LANG_CODE, languageCode);
  return _lang(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANG_CODE) ?? SERBIAN;
  return _lang(languageCode);
}

Locale _lang(String languageCode) {
  switch (languageCode) {
    case SERBIAN:
      return const Locale(SERBIAN, '');
    case ENGLISH:
      return const Locale(ENGLISH, '');
    case GERMAN:
      return const Locale(GERMAN, '');
    default:
      return const Locale(ENGLISH, '');
  }
}

AppLocalizations localization(BuildContext context) {
  return AppLocalizations.of(context)!;
}
