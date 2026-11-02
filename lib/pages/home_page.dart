import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/accessibility_theme.dart';
import '../localization/language.dart';
import '../localization/supported_languages.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/backgroundAndCoverImages/homeImage.jpg',
            fit: BoxFit.cover,
            semanticLabel: localization(context).valjevoCityImage,
          ),
          const ExcludeSemantics(child: ColoredBox(color: photoTextScrim)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal =
                    (constraints.maxWidth * 0.05).clamp(16.0, 40.0);
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontal,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 720,
                        minHeight: (constraints.maxHeight - 32)
                            .clamp(0, double.infinity),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            localization(context).song,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localization(context).songAuthor,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            button: true,
                            label: localization(context).getStarted,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                showLanguageMenuIfNeeded(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(48, 48),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: Text(localization(context).getStarted),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
