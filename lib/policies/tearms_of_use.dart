import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';

void showTermsOfUse(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Semantics(
          header: true,
          child: Text(
            localization(context).privacyPolicy,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: _buildTermsOfUseContent(context),
          ),
        ),
        actions: <Widget>[
          Semantics(
            button: true,
            label: localization(context).closeDialog,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
              ),
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

List<Widget> _buildTermsOfUseContent(BuildContext context) {
  return [
    Text(localization(context).lastUpdated('24-02-2024'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: MediaQuery.of(context).textScaler.scale(24.0),
              fontWeight: FontWeight.bold,
            )),
    const SizedBox(height: 4.0),
    _buildSection(context, localization(context).acceptanceTerms,
        localization(context).acceptanceTermsContent),
    _buildSection(context, localization(context).termsChanges,
        localization(context).termsChangesContent),
    _buildSection(context, localization(context).privacyPolicy,
        localization(context).privacyContent),
    _buildSection(context, localization(context).userConduct,
        localization(context).userConductContent),
    _buildSection(context, localization(context).intellectualProperty,
        localization(context).intellectualPropertyContent),
    _buildSection(context, localization(context).userGen,
        localization(context).userGenContent),
    _buildSection(context, localization(context).thirdPartServices,
        localization(context).thirdPartServicesContent),
    _buildSection(context, localization(context).appChanges,
        localization(context).appChangesContent),
    Text(
      localization(context).contactUs,
      style: Theme.of(context).textTheme.titleLarge,
    ),
    Semantics(
      link: true,
      label: localization(context).contactUsContent,
      child: RichText(
        text: TextSpan(
          text: localization(context).contactUsContent,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: MediaQuery.of(context).textScaler.scale(14.0),
              ),
          children: const <TextSpan>[
            TextSpan(
              text: 'andjelkadzida@gmail.com',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ),
  ];
}

Widget _buildSection(BuildContext context, String title, String content) {
  return Semantics(
    header: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: MediaQuery.of(context).textScaler.scale(18.0),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: MediaQuery.of(context).textScaler.scale(14.0),
              ),
        ),
        const SizedBox(height: 16.0),
      ],
    ),
  );
}
