import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';

void showLegalDialog(
  BuildContext context, {
  required String title,
  required List<Widget> sections,
}) {
  showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Semantics(header: true, child: Text(title)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections,
        ),
      ),
      actions: [
        Semantics(
          button: true,
          label: localization(context).closeDialog,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(11, 20, 32, 1),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization(context).close),
          ),
        ),
      ],
    ),
  );
}

class LegalSection extends StatelessWidget {
  const LegalSection({Key? key, required this.title, required this.content})
      : super(key: key);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
