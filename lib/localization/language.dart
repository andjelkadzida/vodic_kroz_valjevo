import 'dart:math';

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

  static List<Language> languageList(BuildContext context) {
    return <Language>[
      Language(1, '🇷🇸', localization(context).serbian, 'sr', 'Latn', 'sr-RS'),
      Language(
          2, '🇷🇸', localization(context).serbianCyrl, 'sr', 'Cyrl', 'sr-RS'),
      Language(3, '🇺🇸', localization(context).english, 'en', 'en', 'en-US'),
      Language(4, '🇩🇪', localization(context).german, 'de', 'de', 'de-DE')
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
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth,
      child: IntrinsicWidth(
        child: SizedBox(
          height: max(50, screenHeight * 0.08),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Semantics(
                label: localization(context).changeLanguageLabel(language.name),
                child: SizedBox(
                  width: max(50, screenWidth * 0.55),
                  height: max(50, screenHeight * 0.2),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ExcludeSemantics(
                          child: Text(
                            language.flag,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          language.name,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                  ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setSelectedLanguage(language);
                      if (calledFromNavBar) {
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      } else {
                        navigateTo(context, const MenuPage());
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void setSelectedLanguage(Language language) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstRun', false);

  HapticFeedback.selectionClick();

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
        color: Colors.white,
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
                child: Text(
                  localization(context).chooseLanguage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
            ...Language.languageList(context).map(
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
