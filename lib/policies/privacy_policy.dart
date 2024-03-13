import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';

void showPrivacyPolicy(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Semantics(
          header: true,
          child: Text(
            localization(context).privacyPolicy,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: screenSize.width * 0.06,
                ),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ..._buildPrivacyPolicyContent(context, screenSize),
            ],
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localization(context).close),
            ),
          ),
        ],
      );
    },
  );
}

List<Widget> _buildPrivacyPolicyContent(BuildContext context, Size screenSize) {
  return [
    _buildSection(context, screenSize, localization(context).infoByYou,
        localization(context).infoByYouContent),
    _buildSection(context, screenSize, localization(context).autoCollectedData,
        localization(context).autoCollectedDataContent),
    _buildSection(context, screenSize, localization(context).localStorage,
        localization(context).localStorageContent),
    _buildSection(context, screenSize, localization(context).useOfInfo,
        localization(context).useOfInfoContent),
    _buildSection(context, screenSize, localization(context).thirdParty,
        localization(context).thirdPartyContent),
    _buildSection(context, screenSize, localization(context).tearmsOfAnd,
        localization(context).tearmsOfAndContent),
    _buildSection(context, screenSize, localization(context).ongoingAmend,
        localization(context).ongoingAmendContent),
    _buildSection(context, screenSize, localization(context).contact,
        localization(context).contactContent),
    _buildSection(context, screenSize, localization(context).mapCredits,
        localization(context).mapCreditsContent),
  ];
}

Widget _buildSection(
    BuildContext context, Size screenSize, String title, String content) {
  var screenWidth = screenSize.width;
  var screenHeight = screenSize.height;
  return Semantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: screenWidth * 0.035,
              ),
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    ),
  );
}
