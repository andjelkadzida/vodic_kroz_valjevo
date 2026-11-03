import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helper/accessibility_theme.dart';
import '../localization/supported_languages.dart';
import 'legal_dialog.dart';

void showTermsOfUse(BuildContext context) {
  final messages = localization(context);
  showLegalDialog(
    context,
    title: messages.termsOfUse,
    sections: [
      Text(
        messages.lastUpdated('01-11-2026'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      LegalSection(
          title: messages.acceptanceTerms,
          content: messages.acceptanceTermsContent),
      LegalSection(
          title: messages.termsChanges, content: messages.termsChangesContent),
      LegalSection(
          title: messages.privacyPolicy, content: messages.privacyContent),
      LegalSection(
          title: messages.userConduct, content: messages.userConductContent),
      LegalSection(
          title: messages.intellectualProperty,
          content: messages.intellectualPropertyContent),
      LegalSection(title: messages.userGen, content: messages.userGenContent),
      LegalSection(
          title: messages.thirdPartServices,
          content: messages.thirdPartServicesContent),
      LegalSection(
          title: messages.appChanges, content: messages.appChangesContent),
      Semantics(
        header: true,
        child: Text(messages.contactUs,
            style: Theme.of(context).textTheme.titleMedium),
      ),
      Semantics(
        link: true,
        label: messages.contactUsContent,
        child: InkWell(
          onTap: () => launchUrlString(
            Uri(scheme: 'mailto', path: 'andjelkadzida@gmail.com').toString(),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Text.rich(
              TextSpan(
                text: messages.contactUsContent,
                children: const [
                  TextSpan(
                    text: 'andjelkadzida@gmail.com',
                    style: TextStyle(
                      color: accessibleLinkColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    ],
  );
}
