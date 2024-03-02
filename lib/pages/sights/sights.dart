import 'dart:math';

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
            onData: (data) => buildSightsList(data, context),
          );
        },
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget buildSightsList(
      List<Map<String, dynamic>> sightsData, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
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
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () =>
            showDetailsPage(context, SightDetailsPage(sightData: sightData)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(sightData['title'],
                  style: Theme.of(context).textTheme.titleMedium),
              trailing: IconButton(
                onPressed: () =>
                    TextToSpeechConfig.instance.speak(sightData['title']),
                icon: Icon(
                  Icons.volume_up,
                  semanticLabel: localization(context).tapToHearSightName,
                ),
                tooltip: localization(context).tapToHearSightName,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Image.asset(sightData['sight_image_path'], fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  mapScreen.navigateToDestination(
                      sightData['latitude'], sightData['longitude']);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text(localization(context).startNavigation,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
