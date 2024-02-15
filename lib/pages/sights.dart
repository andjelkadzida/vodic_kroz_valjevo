import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'sight_details_page.dart';
import '../navigation/bottom_navigation.dart';
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
      bottomNavigationBar: const CustomBottomNavigationBar(),
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
            final String imagePath = sightsData[index]['sights_image_path'];
            final String title = sightsData[index]['title'];
            final String description = sightsData[index]['description'];
            final double destLatitude = sightsData[index]['latitude'];
            final double destLongitude = sightsData[index]['longitude'];

            return buildGridItem(itemWidth, imagePath, title, destLatitude,
                destLongitude, description, context);
          },
        );
      },
    );
  }

  Widget buildGridItem(
      double itemWidth,
      String imagePath,
      String title,
      double destLatitude,
      double destLongitude,
      String description,
      BuildContext context) {
    //Precache images to avoid screen flickering
    precacheImage(AssetImage(imagePath), context);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        _showImageDialog(context, imagePath, title);
      },
      behavior: HitTestBehavior.translucent,
      child: Semantics(
        container: true,
        label:
            '${localization(context).sight} $title. ${localization(context).tapForDetails}',
        child: Card(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 9,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => SightDetailsPage(
                              imagePath: imagePath,
                              title: title,
                              description: description)),
                    );
                  },
                  child: Semantics(
                    image: true,
                    label: title,
                    child: FadeInImage(
                      placeholder: AssetImage(imagePath),
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                      imageSemanticLabel:
                          '${localization(context).sight}"$title"',
                    ),
                  ),
                ),
              ),
              Expanded(
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
                      backgroundColor: Colors.white,
                      shape: const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0))),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      alignment: Alignment.center,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${localization(context).navigateTo}\n"$title"',
                        style: AppStyles.sightTitleStyle(
                            MediaQuery.of(context).textScaler),
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

  void _showImageDialog(BuildContext context, String imagePath, String title) {
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
                    label:
                        '${localization(dialogContext).enlargedImage} $title',
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        imagePath,
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
                        label:
                            '${localization(dialogContext).nameOfSight}$title',
                        child: Text(
                          title,
                          style: AppStyles.sightDialogStyle(
                              MediaQuery.of(dialogContext).textScaler),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Semantics(
                      label: localization(dialogContext).hearLandmarkName,
                      tooltip: localization(dialogContext).hearLandmarkName,
                      child: IconButton(
                        onPressed: () {
                          TextToSpeechConfig.instance.speak(title);
                        },
                        icon: Icon(Icons.volume_up_sharp,
                            semanticLabel:
                                localization(dialogContext).hearLandmarkName),
                        iconSize:
                            MediaQuery.of(dialogContext).textScaler.scale(30),
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
}
