import 'dart:math';

import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import '../policies/privacy_policy.dart';
import '../policies/terms_of_use.dart';

AppBar customAppBar(BuildContext context, String title, Color color) {
  var screenWidth = MediaQuery.of(context).size.width;
  var screenHeight = MediaQuery.of(context).size.height;
  return AppBar(
    title: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    ),
    actions: <Widget>[
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
                image: true,
                label: localization(context).appLogo,
                child: FlutterLogo(size: screenWidth * 0.1),
              ),
              applicationName: localization(context).appTitle,
              applicationVersion: '1.0.0',
              applicationLegalese: localization(context).appAuthor,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Text(
                    localization(context).aboutAppDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: screenWidth * 0.03,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Text(
                    localization(context).aboutAppLocalization,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: screenWidth * 0.03,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Text(
                    localization(context).aboutAppAccessibility,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: screenWidth * 0.03,
                        ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: max(50, screenWidth * 0.3),
                      height: max(50, screenHeight * 0.05),
                      child: InkWell(
                        onTap: () {
                          showPrivacyPolicy(context);
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            localization(context).privacyPolicy,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: max(50, screenWidth * 0.3),
                      height: max(50, screenHeight * 0.05),
                      child: InkWell(
                        onTap: () {
                          showTermsOfUse(context);
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            localization(context).termsOfUse,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
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
    elevation: (screenWidth / 150).clamp(0.0, 6.0),
  );
}
