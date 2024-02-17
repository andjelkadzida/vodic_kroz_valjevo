import 'package:flutter/material.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingHorizontal = screenWidth * 0.08;
    double paddingVertical = screenWidth * 0.02;
    double fontSize = screenWidth * 0.04;

    // If called from bottom navigation bar, navigate back, otherwise navigate to menu page
    return ElevatedButton(
      onPressed: () {
        setSelectedLanguage(language);
        if (calledFromNavBar) {
          Navigator.pop(context);
        } else {
          navigateTo(context, const MenuPage());
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(48, 48),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            language.flag,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            language.name,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ],
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

// Set different bahaviopur for language menu based on where it was called from
void showLanguageMenu(BuildContext context, {bool calledFromNavBar = false}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                localization(context).chooseLanguage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ...Language.languageList().map((language) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: LanguageButton(
                      language: language, calledFromNavBar: calledFromNavBar),
                )),
          ],
        ),
      );
    },
  );
}
