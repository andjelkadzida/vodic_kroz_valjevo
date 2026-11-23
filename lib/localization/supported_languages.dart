// ignore_for_file: constant_identifier_names

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// SharedPreferences key under which the selected language is stored.
/// The name is unchanged, so values saved by earlier app versions still load.
const String SCRIPT_CODE = 'scriptCode';

// Selection keys: the values stored in SharedPreferences.
// They are unchanged from the previous version ('Latn', 'Cyrl', 'en', 'de').
const String SERBIAN_LATIN = 'Latn';
const String SERBIAN_CYRL = 'Cyrl';
const String ENGLISH = 'en';
const String GERMAN = 'de';

// The locales the app can run in. Country codes are plain region codes
// (RS, US, DE), and only Serbian carries a script code.
const Locale serbianLatinLocale = Locale.fromSubtags(
  languageCode: 'sr',
  scriptCode: 'Latn',
  countryCode: 'RS',
);
const Locale serbianCyrillicLocale = Locale.fromSubtags(
  languageCode: 'sr',
  scriptCode: 'Cyrl',
  countryCode: 'RS',
);
const Locale englishLocale = Locale('en', 'US');
const Locale germanLocale = Locale('de', 'DE');

/// Pass this to MaterialApp.supportedLocales.
const List<Locale> appSupportedLocales = <Locale>[
  serbianCyrillicLocale,
  serbianLatinLocale,
  englishLocale,
  germanLocale,
];

Future<Locale> setLocale(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(SCRIPT_CODE, key);
  return localeForKey(key);
}

Future<Locale> getLocale() async {
  final prefs = await SharedPreferences.getInstance();
  return localeForKey(prefs.getString(SCRIPT_CODE) ?? SERBIAN_CYRL);
}

Locale localeForKey(String key) {
  switch (key) {
    case SERBIAN_CYRL:
      return serbianCyrillicLocale;
    case ENGLISH:
      return englishLocale;
    case GERMAN:
      return germanLocale;
    case SERBIAN_LATIN:
    default:
      return serbianLatinLocale;
  }
}

AppLocalizations localization(BuildContext context) {
  return AppLocalizations.of(context)!;
}
