import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../database_config/database_helper.dart';
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () => showDetailsPage(
                context, SightDetailsPage(sightData: sightData)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: localization(context).tapToHearSightName,
                  child: Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            sightData['title'],
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                        GestureDetector(
                          onDoubleTap: () =>
                              TextToSpeechConfig.instance.stopSpeaking(),
                          child: IconButton(
                            onPressed: () => TextToSpeechConfig.instance
                                .speak(sightData['title']),
                            alignment: Alignment.centerRight,
                            icon: Icon(Icons.volume_up,
                                applyTextScaling: true,
                                semanticLabel:
                                    localization(context).tapToHearSightName),
                            tooltip: localization(context).tapToHearSightName,
                            iconSize: MediaQuery.of(context).size.width * 0.06,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label:
                        localization(context).imageOfSight(sightData['title']),
                    image: true,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.transparent,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            sightData['sight_image_path'],
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.02),
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      mapScreen.navigateToDestination(
                          sightData['latitude'], sightData['longitude']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: Size(constraints.maxWidth, 48),
                    ),
                    child: Text(
                      localization(context).startNavigation,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              Theme.of(context).textTheme.labelLarge?.fontSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
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
