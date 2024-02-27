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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenWidth = constraints.maxWidth;
        double paddingHorizontal = screenWidth * 0.08;
        double paddingVertical = screenWidth * 0.02;
        double fontSize = screenWidth * 0.04;

        // If called from bottom navigation bar, navigate back, otherwise navigate to menu page
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
          ),
        );
      },
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
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double screenWidth = constraints.maxWidth;
          double paddingHorizontal = screenWidth * 0.08;
          double paddingVertical = screenWidth * 0.02;
          double fontSize = screenWidth * 0.04;

          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal, vertical: paddingVertical),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: paddingVertical),
                  child: Semantics(
                    header: true,
                    child: Text(
                      localization(context).chooseLanguage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
                ...Language.languageList().map((language) => Padding(
                      padding: EdgeInsets.only(bottom: paddingVertical),
                      child: Semantics(
                        button: true,
                        enabled: true,
                        onTapHint:
                            localization(context).selectLanguageLabel(language),
                        child: LanguageButton(
                            language: language,
                            calledFromNavBar: calledFromNavBar),
                      ),
                    )),
              ],
            ),
          );
        },
      );
    },
  );
}
