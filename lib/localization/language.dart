import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../pages/menu/menu_page.dart';
import '../navigation/navigation_helper.dart';
import 'supported_languages.dart';

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final String scriptCode;
  final String countyCode;

  Language(this.id, this.flag, this.name, this.languageCode, this.scriptCode,
      this.countyCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, '🇷🇸', 'Srpski', 'sr', 'Latn', 'sr-RS'),
      Language(2, '🇷🇸', 'Српски', 'sr', 'Cyrl', 'sr-RS'),
      Language(3, '🇺🇸', 'English', 'en', 'en', 'en-US'),
      Language(4, '🇩🇪', 'Deutsch', 'de', 'de', 'de-DE')
    ];
  }
}

class LanguageButton extends StatelessWidget {
  final Language language;
  final bool calledFromNavBar;

  const LanguageButton(
      {Key? key, required this.language, this.calledFromNavBar = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Semantics(
      label: localization(context).changeLanguageLabel(language.name),
      child: ElevatedButton(
        onPressed: () {
          setSelectedLanguage(language);
          if (calledFromNavBar) {
            Navigator.pop(context);
            HapticFeedback.selectionClick();
          } else {
            navigateTo(context, const MenuPage());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.04,
              ),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.width * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(50, 50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              language.flag,
              style: TextStyle(
                fontSize: size.width * 0.04,
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Text(
              language.name,
              style: TextStyle(
                fontSize: size.width * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void setSelectedLanguage(Language language) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstRun', false);

  Locale locale = await setLocale(language.scriptCode);
  VodicKrozValjevo.setLanguage(locale);
}

void showLanguageMenuIfNeeded(BuildContext context) {
  SharedPreferences.getInstance().then((prefs) {
    if (prefs.getBool('isFirstRun') ?? true) {
      showLanguageMenu(context);
    } else {
      navigateTo(context, const MenuPage());
    }
  });
}

// Set different bahaviour for language menu based on where it was called from
void showLanguageMenu(BuildContext context, {bool calledFromNavBar = false}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      var size = MediaQuery.of(context).size;
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.08,
          vertical: size.width * 0.02,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.width * 0.02),
              child: Semantics(
                header: true,
                child: Text(
                  localization(context).chooseLanguage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.04,
                  ),
                ),
              ),
            ),
            ...Language.languageList().map(
              (language) => Padding(
                padding: EdgeInsets.only(bottom: size.width * 0.02),
                child: Semantics(
                  button: true,
                  enabled: true,
                  onTapHint:
                      localization(context).selectLanguageLabel(language),
                  child: LanguageButton(
                    language: language,
                    calledFromNavBar: calledFromNavBar,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
