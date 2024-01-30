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
    return Scaffold(
      appBar: AppBar(
        title: Text(localization(context).sights,
            style: AppStyles.defaultAppBarTextStyle(
                MediaQuery.of(context).textScaler)),
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
    //Prechache images to avoid screen flickering
    precacheImage(MemoryImage(imageBytes), context);

    Uint8List imagePlaceholder = Uint8List.fromList(imageBytes);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        _showImageDialog(context, imageBytes, title);
      },
      child: Semantics(
        container: true,
        label:
            '${localization(context).sight} $title. ${localization(context).tapForDetails}',
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 9,
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
                    child: FadeInImage(
                      placeholder: MemoryImage(imagePlaceholder),
                      image: MemoryImage(imageBytes),
                      fit: BoxFit.cover,
                      imageSemanticLabel:
                          '${localization(context).sight}"$title"',
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Semantics(
                  button: true,
                  label: '${localization(context).navigateTo}\n"$title"',
                  child: ElevatedButton(
                    onPressed: () async {
                      TextToSpeechConfig.instance.speak(
                          '${localization(context).navigateTo}\n"$title"');
                      await mapScreen.navigateToDestination(
                          destLatitude, destLongitude);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      shape: const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.center,
                    ),
                    child: Text(
                      '${localization(context).navigateTo}\n"$title"',
                      style: AppStyles.sightTitleStyle(
                          MediaQuery.of(context).textScaler),
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

  void _showImageDialog(
      BuildContext context, Uint8List imageBytes, String title) {
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
                  flex: 5,
                  fit: FlexFit.loose,
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
                          style: AppStyles.sightDialogStyle(
                              MediaQuery.of(context).textScaler),
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
                        icon: Icon(Icons.volume_up_sharp,
                            semanticLabel:
                                localization(context).hearLandmarkName),
                        iconSize: MediaQuery.of(context).textScaler.scale(30),
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

  final List<int> imagePlaceholder = <int>[
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    13,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    96,
    96,
    96,
    96,
    0,
    0,
    0,
    5,
    0,
    1,
    165,
    246,
    69,
    64,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130
  ];
}
