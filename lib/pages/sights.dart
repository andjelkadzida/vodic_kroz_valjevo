import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'sight_details_page.dart';
import '../navigation/navigation_drawer.dart' as nav_drawer;
import '../database_config/database_helper.dart';
import '../text_to_speech/text_to_speech_config.dart';
import '../maps_navigation/locator.dart';
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class Sights extends StatelessWidget {
  Sights({Key? key}) : super(key: key);
  final MapScreen mapScreen = MapScreen();

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization(context).sights,
            style: AppStyles.defaultAppBarTextStyle(textScaler)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: buildSightsDataWidget(context),
      drawer: const nav_drawer.NavigationDrawer(),
    );
  }

  Widget buildSightsDataWidget(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSightsDataFromDatabase(localization(context).localeName),
      builder: (context, snapshot) {
        return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
          context: context,
          snapshot: snapshot,
          onData: (data) => buildSightsGrid(data),
        );
      },
    );
  }

  Widget buildSightsGrid(List<Map<String, dynamic>> sightsData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount = screenWidth < 600 ? 2 : 4;
        double itemWidth = screenWidth / crossAxisCount - 16;

        return GridView.builder(
          shrinkWrap: true,
          itemCount: sightsData.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            final Uint8List imageBytes = sightsData[index]['sights_image_path'];
            final String title = sightsData[index]['title'];
            final String description = sightsData[index]['description'];
            final double destLatitude = sightsData[index]['latitude'];
            final double destLongitude = sightsData[index]['longitude'];

            return buildGridItem(itemWidth, imageBytes, title, destLatitude,
                destLongitude, description, context);
          },
        );
      },
    );
  }

  Widget buildGridItem(
      double itemWidth,
      Uint8List imageBytes,
      String title,
      double destLatitude,
      double destLongitude,
      String description,
      BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return Dialog(
              child: SizedBox(
                width: MediaQuery.of(dialogContext).size.width * 0.8,
                height: MediaQuery.of(dialogContext).size.height * 0.35,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Semantics(
                        label: '${localization(context).enlargedImage} $title',
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Semantics(
                            label: '${localization(context).nameOfSight}$title',
                            child: Text(
                              title,
                              style: AppStyles.sightDialogStyle(textScaler),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Semantics(
                          label: localization(context).hearLandmarkName,
                          tooltip: localization(context).hearLandmarkName,
                          child: IconButton(
                            onPressed: () {
                              TextToSpeechConfig.instance.speak(title);
                            },
                            icon: const Icon(Icons.volume_up_sharp),
                            enableFeedback: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Semantics(
        container: true,
        label:
            '${localization(context).sight} $title. ${localization(context).tapForDetails}',
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => SightDetailsPage(
                              imageBytes: imageBytes,
                              title: title,
                              description: description)),
                    );
                  },
                  child: Semantics(
                    image: true,
                    label: title,
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                      semanticLabel: '${localization(context).sight} $title',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Semantics(
                  button: true,
                  label: '${localization(context).navigateTo}$title',
                  child: MaterialButton(
                    onPressed: () async {
                      TextToSpeechConfig.instance
                          .speak('${localization(context).navigateTo}$title');
                      await mapScreen.getCurrentLocation();
                      await mapScreen.navigateToDestination(
                          destLatitude, destLongitude);
                    },
                    minWidth: itemWidth,
                    height: 48.0,
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '${localization(context).navigateTo}$title',
                      style: AppStyles.sightTitleStyle(textScaler),
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

  // Getting data from the database
  Future<List<Map<String, dynamic>>> _getSightsDataFromDatabase(
      String languageCode) async {
    final Database db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT 
        sights_image_path, 
        title_$languageCode AS title,
        description_$languageCode AS description,
        latitude,
        longitude
      FROM 
        Sights
    ''');
    return data;
  }
}
