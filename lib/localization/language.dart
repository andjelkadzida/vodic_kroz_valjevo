import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/menu/menu_page.dart';
import '../navigation/navigation_helper.dart';
import 'locale_controller.dart';
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
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: localization(context).changeLanguageLabel(language.name),
        child: InkWell(
          onTap: () async {
            await LocaleScope.of(context).select(language.scriptCode);
            HapticFeedback.selectionClick();
            if (!context.mounted) return;
            if (calledFromNavBar) {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            } else {
              navigateTo(context, const MenuPage());
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: Text(language.flag,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      language.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showLanguageMenuIfNeeded(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (!context.mounted) return;
  if (prefs.getBool('isFirstRun') ?? true) {
    showLanguageMenu(context);
  } else {
    navigateTo(context, const MenuPage());
  }
}

void showLanguageMenu(BuildContext context, {bool calledFromNavBar = false}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      final height = MediaQuery.of(context).size.height;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height * 0.9),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Semantics(
                    child: Text(
                      localization(context).chooseLanguage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
                ...Language.languageList(context).map(
                  (language) => Semantics(
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
              ],
            ),
          ),
        ),
      );
    },
  );
}
