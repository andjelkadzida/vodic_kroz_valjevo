import 'package:flutter/material.dart';

import '../../localization/supported_languages.dart';
import '../../text_to_speech/speech_controls.dart';
import 'tour_photo_gallery.dart';

class GuideDetailsContent extends StatelessWidget {
  const GuideDetailsContent({
    Key? key,
    required this.images,
    required this.imageLabel,
    required this.description,
    required this.readTooltip,
    required this.accentColor,
    this.onNavigate,
    this.navigationHint,
  }) : super(key: key);

  final List<String> images;
  final String imageLabel;
  final String description;
  final String readTooltip;
  final Color accentColor;
  final VoidCallback? onNavigate;
  final String? navigationHint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = (constraints.maxWidth * 0.03).clamp(12.0, 24.0);
          final galleryHeight =
              (constraints.maxHeight * 0.45).clamp(160.0, 400.0);
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TourPhotoGallery(
                      images: images,
                      semanticLabel: imageLabel,
                      height: galleryHeight,
                    ),
                    if (onNavigate != null) ...[
                      const SizedBox(height: 12),
                      Semantics(
                        button: true,
                        onTapHint: navigationHint,
                        child: InkWell(
                          onTap: onNavigate,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                localization(context).startNavigation,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ExpansionTile(
                      expandedAlignment: Alignment.bottomCenter,
                      enableFeedback: true,
                      initiallyExpanded: true,
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              localization(context).details,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          SpeechControls(
                            text: description,
                            readLabel: readTooltip,
                          ),
                        ],
                      ),
                      children: [
                        Divider(color: accentColor, thickness: 3),
                        Text(
                          description,
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
