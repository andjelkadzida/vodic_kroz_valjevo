import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../database_config/database_helper.dart';
import '../../helper/images_loader_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../text_to_speech/text_to_speech_config.dart';

class SportDetailsPage extends StatelessWidget {
  final int sportId;

  const SportDetailsPage({Key? key, required this.sportId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    MapScreen mapScreen = MapScreen();
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSportFromDatabase(sportId, localization(context).localeName),
      builder: (context, snapshot) {
        return DatabaseHelper.buildFutureState<Map<String, dynamic>>(
          context: context,
          snapshot: snapshot,
          onData: (sportData) {
            List<String> images = [
              sportData['sport_image_path'],
              sportData['sport_image_path2'],
              sportData['sport_image_path3'],
            ];
            precacheImages(context, images);
            return Scaffold(
              appBar: customAppBar(
                context,
                sportData['title'],
              ),
              bottomNavigationBar: const CustomBottomNavigationBar(),
              body: OrientationBuilder(
                builder: (context, orientation) {
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              label: localization(context)
                                  .image(sportData['title']),
                              child: Container(
                                color: Colors.transparent,
                                height: constraints.maxWidth * 0.6,
                                child: PhotoViewGallery.builder(
                                  itemCount: images.length,
                                  builder: (context, index) {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider: AssetImage(images[index]),
                                      maxScale:
                                          PhotoViewComputedScale.contained * 5,
                                      minScale:
                                          PhotoViewComputedScale.contained,
                                      initialScale:
                                          PhotoViewComputedScale.contained,
                                      basePosition: Alignment.center,
                                      filterQuality: FilterQuality.high,
                                      heroAttributes: PhotoViewHeroAttributes(
                                          tag: images[index]),
                                    );
                                  },
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  backgroundDecoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  loadingBuilder: (context, event) => Center(
                                    child: Semantics(
                                      tooltip: localization(context).loading,
                                      child: CircularProgressIndicator(
                                        semanticsLabel:
                                            localization(context).loading,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: constraints.maxWidth * 0.015,
                                  ),
                                ),
                                child: Text(
                                  localization(context).startNavigation,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: constraints.maxWidth * 0.05,
                                      ),
                                ),
                                onPressed: () {
                                  mapScreen.navigateToDestination(
                                      sportData['latitude'],
                                      sportData['longitude']);
                                },
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            ExpansionTile(
                              expandedAlignment: Alignment.bottomCenter,
                              enableFeedback: true,
                              initiallyExpanded: false,
                              title: Row(
                                children: [
                                  Text(
                                    localization(context).details,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.black,
                                          fontSize: constraints.maxWidth * 0.06,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: screenWidth * 0.03),
                                  SizedBox(
                                    width: max(constraints.maxWidth * 0.06, 50),
                                    height:
                                        max(constraints.maxWidth * 0.06, 50),
                                    child: GestureDetector(
                                      onDoubleTap: () => TextToSpeechConfig
                                          .instance
                                          .stopSpeaking(),
                                      child: IconButton(
                                        onPressed: () => TextToSpeechConfig
                                            .instance
                                            .speak(sportData['description']),
                                        tooltip: localization(context)
                                            .tapToHearSportDetails,
                                        icon: Icon(
                                          Icons.volume_up,
                                          semanticLabel: localization(context)
                                              .tapToHearSportDetails,
                                          size: constraints.maxWidth * 0.065,
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
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Colors.black,
                                          fontSize: constraints.maxWidth * 0.05,
                                          fontWeight: FontWeight.w400),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getSportFromDatabase(
      int sportId, String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    return await db.rawQuery('''
    SELECT
      id,
      sport_image_path, 
      sport_image_path2,
      sport_image_path3,
      title_$languageCode AS title, 
      description_$languageCode AS description,
      latitude,
      longitude
    FROM Sports
    WHERE id = $sportId
  ''').then((result) => result.first);
  }
}
