import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../database_config/database_helper.dart';
import '../../helper/images_loader_helper.dart';
import '../../localization/supported_languages.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../text_to_speech/text_to_speech_config.dart';

class SightDetailsPage extends StatelessWidget {
  final int sightId;

  const SightDetailsPage({Key? key, required this.sightId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSightFromDatabase(sightId, localization(context).localeName),
      builder: (context, snapshot) {
        return DatabaseHelper.buildFutureState<Map<String, dynamic>>(
          context: context,
          snapshot: snapshot,
          onData: (sightData) {
            List<String> images = [
              sightData['sight_image_path'],
              sightData['sight_image_path2'],
              sightData['sight_image_path3'],
            ];

            precacheImages(context, images);

            return Scaffold(
              appBar: customAppBar(
                context,
                sightData['title'],
              ),
              bottomNavigationBar: const CustomBottomNavigationBar(),
              body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: localization(context)
                              .imageOfSight(sightData['title']),
                          child: Container(
                            color: Colors.transparent,
                            height: constraints.maxHeight * 0.3,
                            child: PhotoViewGallery.builder(
                              itemCount: images.length,
                              builder: (context, index) {
                                return PhotoViewGalleryPageOptions(
                                  imageProvider: AssetImage(images[index]),
                                  maxScale:
                                      PhotoViewComputedScale.contained * 5,
                                  minScale: PhotoViewComputedScale.contained,
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
                        SizedBox(height: constraints.maxHeight * 0.03),
                        ExpansionTile(
                          expandedAlignment: Alignment.bottomCenter,
                          enableFeedback: true,
                          initiallyExpanded: false,
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
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
                              ),
                              SizedBox(
                                width: max(50, constraints.maxWidth * 0.1),
                                height: max(50, constraints.maxHeight * 0.1),
                                child: GestureDetector(
                                  onDoubleTap: () => TextToSpeechConfig.instance
                                      .stopSpeaking(),
                                  child: IconButton(
                                    onPressed: () => TextToSpeechConfig.instance
                                        .speak(sightData['description']),
                                    tooltip: localization(context)
                                        .tapToHearSightDetails,
                                    icon: Icon(
                                      Icons.volume_up,
                                      semanticLabel: localization(context)
                                          .tapToHearSightDetails,
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
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getSightFromDatabase(
      int sightId, String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    return await db.rawQuery('''
    SELECT 
      sight_image_path, 
      sight_image_path2,
      sight_image_path3,
      title_$languageCode AS title, 
      description_$languageCode AS description
    FROM Sights
    WHERE id = $sightId
  ''').then((result) => result.first);
  }
}
