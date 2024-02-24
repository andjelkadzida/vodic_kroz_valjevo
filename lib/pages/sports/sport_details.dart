import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../localization/supported_languages.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../text_to_speech/text_to_speech_config.dart';

class SportDetailsPage extends StatelessWidget {
  final Map<String, dynamic> sportData;

  const SportDetailsPage({Key? key, required this.sportData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      sportData['sport_image_path'],
      sportData['sport_image_path2'],
      sportData['sport_image_path3'],
    ];
    return Scaffold(
      appBar: customAppBar(
        context,
        sportData['title'],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  image: true,
                  label: localization(context).imageOfSight(sportData['title']),
                  child: Container(
                    color: Colors.transparent,
                    height: width * 0.6,
                    child: PhotoViewGallery.builder(
                      itemCount: images.length,
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: AssetImage(images[index]),
                          maxScale: PhotoViewComputedScale.contained * 5,
                          minScale: PhotoViewComputedScale.contained,
                          initialScale: PhotoViewComputedScale.contained,
                          basePosition: Alignment.center,
                          filterQuality: FilterQuality.high,
                          heroAttributes:
                              PhotoViewHeroAttributes(tag: images[index]),
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
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: max(width * 0.06, 48),
                        height: max(width * 0.06, 48),
                        child: GestureDetector(
                          onDoubleTap: () =>
                              TextToSpeechConfig.instance.stopSpeaking(),
                          child: IconButton(
                            onPressed: () => TextToSpeechConfig.instance
                                .speak(sportData['description']),
                            tooltip: localization(context).tapToHearDetails,
                            icon: Icon(
                              Icons.volume_up,
                              semanticLabel:
                                  localization(context).tapToHearDetails,
                              size: width * 0.065,
                              applyTextScaling: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Text(
                      sportData['description'],
                      textAlign: TextAlign.justify,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .displayMedium
                          ?.copyWith(
                              color: Colors.black,
                              fontSize: width * 0.065,
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
