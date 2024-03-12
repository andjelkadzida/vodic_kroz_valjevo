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

class ParkDetailsPage extends StatelessWidget {
  final int parkId;
  static MapScreen mapScreen = MapScreen();

  const ParkDetailsPage({Key? key, required this.parkId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<Map<String, dynamic>>(
      future: _getParkById(parkId, localization(context).localeName),
      builder: (context, snapshot) {
        return DatabaseHelper.buildFutureState<Map<String, dynamic>>(
          context: context,
          snapshot: snapshot,
          onData: (parkData) {
            final images = [
              parkData['park_image_path'],
              parkData['park_image_path2'],
              parkData['park_image_path3'],
            ];

            precacheImages(context, images);
            return Scaffold(
              appBar: customAppBar(
                context,
                (parkData['title'] as String).split('\n').first,
                const Color.fromRGBO(65, 89, 45, 1),
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
                            _buildImageGallery(
                                context, images, parkData, screenWidth),
                            SizedBox(height: screenWidth * 0.03),
                            _buildNavigationButton(
                                context, parkData, screenWidth),
                            SizedBox(height: screenWidth * 0.03),
                            _buildDetailsExpansionTile(
                                context, parkData, screenWidth),
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
}

Widget _buildImageGallery(BuildContext context, List<dynamic> images,
    Map<String, dynamic> parkData, double screenWidth) {
  return Semantics(
    label: localization(context).image(parkData['title']),
    child: Container(
      color: Colors.transparent,
      height: screenWidth * 0.6,
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
            heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
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
              semanticsLabel: localization(context).loading,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildNavigationButton(
    BuildContext context, Map<String, dynamic> parkData, double screenWidth) {
  return SizedBox(
    width: double.infinity,
    height: max(50, screenWidth * 0.1),
    child: Semantics(
      button: true,
      onTapHint: localization(context).tapToNavigateToPark,
      child: InkWell(
        onTap: () => MapScreen()
            .navigateToDestination(parkData['latitude'], parkData['longitude']),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            localization(context).startNavigation,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w300,
                ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildDetailsExpansionTile(
    BuildContext context, Map<String, dynamic> parkData, double screenWidth) {
  return ExpansionTile(
    expandedAlignment: Alignment.bottomCenter,
    enableFeedback: true,
    initiallyExpanded: false,
    title: Row(
      children: [
        Text(
          localization(context).details,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: screenWidth * 0.03),
        SizedBox(
          width: max(screenWidth * 0.06, 50),
          height: max(screenWidth * 0.06, 50),
          child: GestureDetector(
            onDoubleTap: () => TextToSpeechConfig.instance.stopSpeaking(),
            child: IconButton(
              onPressed: () =>
                  TextToSpeechConfig.instance.speak(parkData['description']),
              tooltip: localization(context).tapToHearParkDetails,
              icon: Icon(
                Icons.volume_up,
                semanticLabel: localization(context).tapToHearParkDetails,
                size: screenWidth * 0.065,
                applyTextScaling: true,
              ),
            ),
          ),
        ),
      ],
    ),
    children: [
      Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromRGBO(65, 89, 45, 1),
              width: 3.0,
            ),
          ),
        ),
      ),
      Text(
        parkData['description'],
        textAlign: TextAlign.left,
        style: Theme.of(context).primaryTextTheme.bodySmall?.copyWith(
            color: Colors.black,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w300),
      ),
    ],
  );
}

Future<Map<String, dynamic>> _getParkById(
    int parkId, String languageCode) async {
  final db = await DatabaseHelper.instance.getNamedDatabase();
  return await db.rawQuery('''
    SELECT 
      park_image_path, 
      park_image_path2,
      park_image_path3,
      title_$languageCode AS title, 
      description_$languageCode AS description,
      latitude,
      longitude
    FROM Parks
    WHERE id = $parkId
  ''').then((result) => result.first);
}
