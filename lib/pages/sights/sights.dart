import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../localization/supported_languages.dart';
import '../../maps_navigation/locator.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../database_config/database_helper.dart';
import '../../text_to_speech/text_to_speech_config.dart';
import 'sight_details_page.dart';

class Sights extends StatelessWidget {
  final MapScreen mapScreen = MapScreen();

  Sights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).sights,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getSightsFromDatabase(localization(context).localeName),
        builder: (context, snapshot) {
          return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
            context: context,
            snapshot: snapshot,
            onData: (data) => buildSightsGrid(data, context),
          );
        },
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget buildSightsGrid(
      List<Map<String, dynamic>> sightsData, BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: sightsData.length,
      itemBuilder: (context, index) {
        return buildGridItem(context, sightsData[index]);
      },
    );
  }

  Widget buildGridItem(BuildContext context, Map<String, dynamic> sightData) {
    List<String> images = [
      sightData['sight_image_path'],
      sightData['sight_image_path2']
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => _showSightDetails(context, sightData),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: localization(context).tapToHearSightName,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        sightData['title'],
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontSize:
                                  MediaQuery.of(context).textScaler.scale(16),
                            ),
                      ),
                    ),
                    GestureDetector(
                      onDoubleTap: () =>
                          TextToSpeechConfig.instance.stopSpeaking(),
                      child: IconButton(
                        onPressed: () => TextToSpeechConfig.instance
                            .speak(sightData['title']),
                        icon: Icon(Icons.volume_up,
                            semanticLabel:
                                localization(context).tapToHearSightName),
                        tooltip: localization(context).tapToHearSightName,
                        iconSize: MediaQuery.of(context).textScaler.scale(24),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                label: localization(context).imageOfSight(sightData['title']),
                image: true,
                child: PhotoViewGallery.builder(
                  itemCount: images.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: AssetImage(images[index]),
                      maxScale: PhotoViewComputedScale.contained * 3,
                      initialScale: PhotoViewComputedScale.contained * 0.8,
                      filterQuality: FilterQuality.high,
                      heroAttributes:
                          PhotoViewHeroAttributes(tag: images[index]),
                    );
                  },
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                  ),
                  pageController: PageController(initialPage: 0),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  mapScreen.navigateToDestination(
                      sightData['latitude'], sightData['longitude']);
                  HapticFeedback.lightImpact();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(MediaQuery.of(context).size.width, 48),
                ),
                child: Text(
                  localization(context).startNavigation,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).textScaler.scale(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSightDetails(BuildContext context, Map<String, dynamic> sightData) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => SightDetailsPage(sightData: sightData),
      ),
    );
    HapticFeedback.lightImpact();
  }

  Future<List<Map<String, dynamic>>> _getSightsFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    return await db.rawQuery('''
      SELECT 
        sight_image_path, 
        sight_image_path2, 
        title_$languageCode AS title, 
        description_$languageCode AS description,
        latitude, 
        longitude
      FROM Sights
    ''');
  }
}
