import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../database_config/database_helper.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../navigation/navigation_helper.dart';
import '../../text_to_speech/text_to_speech_config.dart';
import 'sight_details_page.dart';

class Sights extends StatelessWidget {
  final MapScreen mapScreen = MapScreen();

  Sights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: customAppBar(
            context,
            localization(context).sights,
            const Color.fromRGBO(87, 19, 20, 1),
          ),
          bottomNavigationBar: const CustomBottomNavigationBar(),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getSightsFromDatabase(localization(context).localeName),
            builder: (context, snapshot) {
              return DatabaseHelper.buildFutureState<
                  List<Map<String, dynamic>>>(
                context: context,
                snapshot: snapshot,
                onData: (data) => buildSightsList(data, context),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildSightsList(
      List<Map<String, dynamic>> sightsData, BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      itemCount: sightsData.length,
      itemBuilder: (context, index) {
        return SightListItem(
            sightData: sightsData[index], mapScreen: mapScreen);
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getSightsFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    return await db.rawQuery('''
      SELECT
        id,
        sight_image_path, 
        sight_image_path2,
        sight_image_path3,
        title_$languageCode AS title, 
        description_$languageCode AS description,
        latitude, 
        longitude
      FROM Sights
    ''');
  }
}

class SightListItem extends StatelessWidget {
  final Map<String, dynamic> sightData;
  final MapScreen mapScreen;

  const SightListItem(
      {Key? key, required this.sightData, required this.mapScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => showDetailsPage(
          context,
          SightDetailsPage(
            sightId: sightData['id'],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Semantics(
                child: AutoSizeText(
                  sightData['title'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: screenWidth * 0.06,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              trailing: SizedBox(
                width: max(50, screenWidth * 0.1),
                height: max(50, screenHeight * 0.1),
                child: IconButton(
                  onPressed: () =>
                      TextToSpeechConfig.instance.speak(sightData['title']),
                  icon: Icon(
                    Icons.volume_up,
                    semanticLabel: localization(context).tapToHearSightName,
                  ),
                  tooltip: localization(context).tapToHearSightName,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Semantics(
                onTapHint: localization(context).tapToViewSight,
                child: Image.asset(sightData['sight_image_path'],
                    fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  mapScreen.navigateToDestination(
                      sightData['latitude'], sightData['longitude']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(
                    max(50, screenWidth),
                    max(50, screenHeight * 0.05),
                  ),
                ),
                child: Semantics(
                  button: true,
                  enabled: true,
                  onTapHint: localization(context).startNavigation,
                  child: Text(
                    localization(context).startNavigation,
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.04),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
