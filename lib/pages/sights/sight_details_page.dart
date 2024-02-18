import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../localization/supported_languages.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../text_to_speech/text_to_speech_config.dart';

class SightDetailsPage extends StatelessWidget {
  final Map<String, dynamic> sightData;

  const SightDetailsPage({Key? key, required this.sightData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      sightData['sight_image_path'],
      sightData['sight_image_path2'],
    ];

    String title = sightData['title'];

    return Scaffold(
      appBar: customAppBar(
        context,
        title,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  image: true,
                  label: localization(context).imageOfSight(title),
                  child: SizedBox(
                    height: constraints.maxWidth > 600 ? 400 : 200,
                    child: PhotoViewGallery.builder(
                      itemCount: images.length,
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: AssetImage(images[index]),
                          initialScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.contained * 10,
                          heroAttributes:
                              PhotoViewHeroAttributes(tag: images[index]),
                          filterQuality: FilterQuality.high,
                        );
                      },
                      scrollPhysics: const BouncingScrollPhysics(),
                      backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                      ),
                      loadingBuilder: (context, event) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  expandedAlignment: Alignment.bottomCenter,
                  enableFeedback: true,
                  initiallyExpanded: false,
                  title: Row(
                    children: [
                      Text(
                        localization(context).description,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.black,
                              fontSize: constraints.maxWidth * 0.06,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: constraints.maxWidth * 0.06 > 48
                            ? constraints.maxWidth * 0.06
                            : 48,
                        height: constraints.maxWidth * 0.06 > 48
                            ? constraints.maxWidth * 0.06
                            : 48,
                        child: GestureDetector(
                          onDoubleTap: () =>
                              TextToSpeechConfig.instance.stopSpeaking(),
                          child: IconButton(
                            onPressed: () => TextToSpeechConfig.instance
                                .speak(sightData['description']),
                            tooltip: localization(context).tapToHearDetails,
                            icon: Icon(
                              Icons.volume_up,
                              semanticLabel:
                                  localization(context).tapToHearDetails,
                              size: constraints.maxWidth * 0.065,
                              applyTextScaling: true,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  children: [
                    Text(
                      sightData['description'],
                      textAlign: TextAlign.justify,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .displayMedium
                          ?.copyWith(
                              color: Colors.black,
                              fontSize: constraints.maxWidth * 0.065,
                              fontWeight: FontWeight.w400),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
