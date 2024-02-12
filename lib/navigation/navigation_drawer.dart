import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/language.dart';
import '../localization/supported_languages.dart';
import '../main.dart';
import '../styles/common_styles.dart';

Widget headerWidget(BuildContext context) {
  final textScaler = MediaQuery.textScalerOf(context);

  return Semantics(
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              localization(context).cityName,
              style: AppStyles.headerWidgetStyle(textScaler),
              semanticsLabel: localization(context).cityName,
            ),
          ),
          languageWidget(context),
        ],
      ),
    ),
  );
}

Widget languageWidget(BuildContext buildContext) {
  return PopupMenuButton<Language>(
    tooltip: localization(buildContext).languageMenu,
    icon: Semantics(
      label: localization(buildContext).languageMenu,
      child: const Icon(
        Icons.language,
        color: Colors.white,
        textDirection: TextDirection.ltr,
      ),
    ),
    offset: const Offset(60, 40),
    onSelected: (Language language) async {
      Locale locale = await setLocale(language.scriptCode);
      VodicKrozValjevo.setLanguage(locale);
    },
    itemBuilder: (BuildContext context) {
      return Language.languageList().map((Language e) {
        return PopupMenuItem<Language>(
          value: e,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ExcludeSemantics(
                  child: Text(
                e.flag,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(20)),
              )),
              Semantics(
                label: e.name,
                excludeSemantics: true,
                child: Text(
                  e.name,
                ),
              ),
            ],
          ),
        );
      }).toList();
    },
  );
}

void navigateTo(BuildContext context, Widget page) {
  String routeName = page.runtimeType.toString();

  // Check if the current route is the same as the target route
  bool isCurrentRouteTarget = false;
  Navigator.popUntil(context, (route) {
    if (route.settings.name == routeName) {
      isCurrentRouteTarget = true;
    }
    return true;
  });

  // Only navigate if the current route is not the target route
  if (!isCurrentRouteTarget) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: routeName),
      ),
    );
    HapticFeedback.vibrate();
  }
}
