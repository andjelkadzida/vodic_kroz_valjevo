import 'package:flutter/material.dart';

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
    return GridView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      itemCount: sightsData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
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

    return Semantics(
      label: localization(context).tapToSeeSightDetails(sightData['title']),
      child: InkWell(
        onTap: () => navigateTo(
          context,
          SightDetailsPage(
            sightId: sightData['id'],
          ),
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    sightData['sight_image_path'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        sightData['title'],
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500),
                        maxLines: 5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        semanticLabel: localization(context).tapToHearSightName,
                      ),
                      onPressed: () {
                        TextToSpeechConfig.instance.speak(
                          sightData['title'],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  onTapHint: localization(context).tapToNavigateToSight,
                  child: InkWell(
                    onTap: () => mapScreen.navigateToDestination(
                        sightData['latitude'], sightData['longitude']),
                    child: Text(
                      localization(context).startNavigation,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black,
                            fontSize: screenWidth * 0.037,
                            fontWeight: FontWeight.w300,
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
  }
}
