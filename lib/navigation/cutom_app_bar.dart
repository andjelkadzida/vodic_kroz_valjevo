import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

AppBar customAppBar(BuildContext context, String title) {
  return AppBar(
    title: Semantics(
        label: title,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: MediaQuery.of(context).textScaler.scale(24.0),
              ),
        )),
    actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.info_outline,
          semanticLabel: localization(context).aboutApp,
        ),
        onPressed: () {
          showAboutDialog(
            context: context,
            applicationIcon: Semantics(
              label: localization(context).appLogo,
              child: const FlutterLogo(),
            ),
            applicationName: localization(context).appTitle,
            applicationVersion: '1.0.0',
            applicationLegalese: localization(context).appAuthor,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  localization(context).aboutAppDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: MediaQuery.of(context).textScaler.scale(14.0),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  localization(context).aboutAppLocalization,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: MediaQuery.of(context).textScaler.scale(14.0),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  localization(context).aboutAppAccessibility,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: MediaQuery.of(context).textScaler.scale(14.0),
                      ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      showPrivacyPolicy(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        localization(context).privacyPolicy,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize:
                                  MediaQuery.of(context).textScaler.scale(14.0),
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showTermsOfUse(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        localization(context).termsOfUse,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize:
                                  MediaQuery.of(context).textScaler.scale(14.0),
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
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
    ],
    excludeHeaderSemantics: true,
    centerTitle: true,
    backgroundColor: Colors.teal,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    elevation: (MediaQuery.of(context).size.width / 150).clamp(0.0, 6.0),
  );
}

// Function to show Privacy Policy
void showPrivacyPolicy(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localization(context).privacyPolicy),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Your Privacy Policy content goes here...'),
            ],
          ),
        ),
        actions: <Widget>[
          Semantics(
            button: true,
            label: localization(context).closeDialog,
            child: TextButton(
              child: Text(localization(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}

// Function to show Terms of Use
void showTermsOfUse(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localization(context).termsOfUse),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Your Terms of Use content goes here...'),
            ],
          ),
        ),
        actions: <Widget>[
          Semantics(
            button: true,
            label: localization(context).closeDialog,
            child: TextButton(
              child: Text(localization(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}
