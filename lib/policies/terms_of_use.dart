import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../localization/supported_languages.dart';

void showTermsOfUse(BuildContext context) {
  final size = MediaQuery.of(context).size;
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Semantics(
          header: true,
          child: Text(
            localization(context).termsOfUse,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: size.width * 0.06,
                ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: _buildTermsOfUseContent(context, size),
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

List<Widget> _buildTermsOfUseContent(BuildContext context, Size size) {
  return [
    Text(localization(context).lastUpdated('24-02-2024'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            )),
    SizedBox(height: size.height * 0.01),
    _buildSection(context, localization(context).acceptanceTerms,
        localization(context).acceptanceTermsContent, size),
    _buildSection(context, localization(context).termsChanges,
        localization(context).termsChangesContent, size),
    _buildSection(context, localization(context).privacyPolicy,
        localization(context).privacyContent, size),
    _buildSection(context, localization(context).userConduct,
        localization(context).userConductContent, size),
    _buildSection(context, localization(context).intellectualProperty,
        localization(context).intellectualPropertyContent, size),
    _buildSection(context, localization(context).userGen,
        localization(context).userGenContent, size),
    _buildSection(context, localization(context).thirdPartServices,
        localization(context).thirdPartServicesContent, size),
    _buildSection(context, localization(context).appChanges,
        localization(context).appChangesContent, size),
    Text(
      localization(context).contactUs,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: size.width * 0.06,
          ),
    ),
    GestureDetector(
      onTap: () {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'andjelkadzida@gmail.com',
        );
        launchUrlString(emailLaunchUri.toString());
      },
      child: Semantics(
        link: true,
        label: localization(context).contactUsContent,
        child: RichText(
          text: TextSpan(
            text: localization(context).contactUsContent,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: size.width * 0.035,
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
    ),
  ];
}

Widget _buildSection(
    BuildContext context, String title, String content, Size size) {
  return Semantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: size.width * 0.035,
              ),
        ),
        SizedBox(height: size.height * 0.02),
      ],
    ),
  );
}
