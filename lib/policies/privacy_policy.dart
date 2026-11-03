import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import 'legal_dialog.dart';

void showPrivacyPolicy(BuildContext context) {
  final messages = localization(context);
  showLegalDialog(
    context,
    title: messages.privacyPolicy,
    sections: [
      LegalSection(
          title: messages.infoByYou, content: messages.infoByYouContent),
      LegalSection(
          title: messages.autoCollectedData,
          content: messages.autoCollectedDataContent),
      LegalSection(
          title: messages.localStorage, content: messages.localStorageContent),
      LegalSection(
          title: messages.useOfInfo, content: messages.useOfInfoContent),
      LegalSection(
          title: messages.thirdParty, content: messages.thirdPartyContent),
      LegalSection(
          title: messages.tearmsOfAnd, content: messages.tearmsOfAndContent),
      LegalSection(
          title: messages.ongoingAmend, content: messages.ongoingAmendContent),
      LegalSection(title: messages.contact, content: messages.contactContent),
      LegalSection(
          title: messages.mapCredits, content: messages.mapCreditsContent),
    ],
  );
}
