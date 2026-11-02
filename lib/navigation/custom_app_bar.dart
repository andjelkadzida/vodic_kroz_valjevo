import 'dart:math';

import 'package:flutter/material.dart';

import '../helper/responsive_layout.dart';
import '../localization/supported_languages.dart';
import '../policies/privacy_policy.dart';
import '../policies/terms_of_use.dart';

AppBar customAppBar(BuildContext context, String title, Color color,
    {VoidCallback? onRefresh}) {
  final screenSize = MediaQuery.of(context).size;
  final titleStyle =
      (Theme.of(context).textTheme.titleLarge ?? const TextStyle()).copyWith(
    color: Colors.white,
    fontSize: 20,
  );
  final leadingWidth = Navigator.canPop(context) ? 56.0 : 0.0;
  final actionWidth = onRefresh == null ? 48.0 : 96.0;
  final titleWidth = max(
    1.0,
    screenSize.width -
        MediaQuery.of(context).padding.horizontal -
        leadingWidth -
        actionWidth -
        32,
  );
  final requiredHeight = max(kToolbarHeight,
      measureTextHeight(context, title, titleStyle, titleWidth) + 16);
  final maximumHeight =
      max(kToolbarHeight, min(160.0, screenSize.height * 0.35));
  final toolbarHeight = min(requiredHeight, maximumHeight);
  final titleContent = DefaultTextStyle(
    style: titleStyle,
    textAlign: TextAlign.center,
    overflow: TextOverflow.visible,
    child: Text(title),
  );

  return AppBar(
    toolbarHeight: toolbarHeight,
    title: requiredHeight > maximumHeight
        ? SingleChildScrollView(primary: false, child: titleContent)
        : titleContent,
    actions: <Widget>[
      if (onRefresh != null)
        IconButton(
          tooltip:
              MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
          icon: Icon(
            Icons.refresh,
            semanticLabel:
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
          ),
          onPressed: onRefresh,
        ),
      Semantics(
        button: true,
        enabled: true,
        onTapHint: localization(context).openAboutDialog,
        child: IconButton(
          tooltip: localization(context).aboutApp,
          icon: Icon(
            Icons.info_outline,
            semanticLabel: localization(context).aboutApp,
          ),
          onPressed: () {
            showAboutDialog(
              barrierDismissible: false,
              context: context,
              applicationIcon: Semantics(
                label: localization(context).appLogo,
                child: Image.asset(
                  'images/appLogo.png',
                  width: 48,
                  cacheWidth:
                      (48 * MediaQuery.of(context).devicePixelRatio).ceil(),
                  fit: BoxFit.cover,
                ),
              ),
              applicationName: localization(context).appTitle,
              applicationVersion: '2.0.0',
              applicationLegalese: localization(context).appAuthor,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    localization(context).aboutAppDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    localization(context).aboutAppLocalization,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    localization(context).aboutAppAccessibility,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => showPrivacyPolicy(context),
                      child: Text(
                        localization(context).privacyPolicy,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => showTermsOfUse(context),
                      child: Text(
                        localization(context).termsOfUse,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ],
    excludeHeaderSemantics: false,
    centerTitle: true,
    backgroundColor: color,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    elevation: (screenSize.width / 150).clamp(0.0, 6.0),
  );
}
