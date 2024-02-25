import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';

void showPrivacyPolicy(BuildContext context) {
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
            children: <Widget>[
              ..._buildPrivacyPolicyContent(context),
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

List<Widget> _buildPrivacyPolicyContent(BuildContext context) {
  return [
    _buildSection(context, localization(context).infoByYou,
        localization(context).infoByYouContent),
    _buildSection(context, localization(context).autoCollectedData,
        localization(context).autoCollectedDataContent),
    _buildSection(context, localization(context).localStorage,
        localization(context).localStorageContent),
    _buildSection(context, localization(context).useOfInfo,
        localization(context).useOfInfoContent),
    _buildSection(context, localization(context).thirdParty,
        localization(context).thirdPartyContent),
    _buildSection(context, localization(context).tearmsOfAnd,
        localization(context).tearmsOfAndContent),
    _buildSection(
        context, localization(context).law, localization(context).lawContent),
    _buildSection(context, localization(context).ongoingAmend,
        localization(context).ongoingAmendContent),
    _buildSection(context, localization(context).contact,
        localization(context).contactContent),
    _buildSection(context, localization(context).mapCredits,
        localization(context).mapCreditsContent),
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
