import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../localization/supported_languages.dart';
import 'tour_photo_gallery.dart';

class HospitalityDetailsContent extends StatelessWidget {
  const HospitalityDetailsContent({
    Key? key,
    required this.title,
    required this.images,
    required this.imageLabel,
    required this.photoSourceUrl,
    required this.navigationHint,
    required this.onNavigate,
    this.website,
    this.stars,
  }) : super(key: key);

  final String title;
  final List<String> images;
  final String imageLabel;
  final String photoSourceUrl;
  final String navigationHint;
  final VoidCallback onNavigate;
  final String? website;
  final int? stars;

  void _openUrl(String url) {
    launchUrlString(url);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = (constraints.maxWidth * 0.04).clamp(12.0, 24.0);
          final galleryHeight =
              (constraints.maxHeight * 0.4).clamp(160.0, 380.0);
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    Center(
                      child: Semantics(
                        link: true,
                        child: InkWell(
                          onTap: () => _openUrl(photoSourceUrl),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  const ExcludeSemantics(
                                    child: Icon(Icons.copyright, size: 20),
                                  ),
                                  Text(
                                    localization(context).photoSource,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Divider(thickness: 2),
                    if (stars != null)
                      Semantics(
                        label: localization(context).starCount(stars!),
                        tooltip: localization(context).starCount(stars!),
                        child: Wrap(
                          children: List.generate(
                            stars!,
                            (_) => const Icon(Icons.star, size: 24),
                          ),
                        ),
                      ),
                    if (website != null)
                      Semantics(
                        link: true,
                        child: InkWell(
                          onTap: () => _openUrl(website!),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                localization(context).website,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
