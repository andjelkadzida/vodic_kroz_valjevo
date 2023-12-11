import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vodic_kroz_valjevo/database_config/database_helper.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/maps_navigation/locator.dart';
import 'package:vodic_kroz_valjevo/text_to_speech/text_to_speech_config.dart';

class Sights extends StatelessWidget {
  Sights({Key? key}) : super(key: key);
  final MapScreen mapScreen = MapScreen();
  final TextToSpeechConfig textToSpeechConfig = TextToSpeechConfig();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: localization(context).sights,
          child: Text(
            localization(context).sights,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: buildSightsDataWidget(context),
    );
  }

  Widget buildSightsDataWidget(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSightsDataFromDatabase(localization(context).localeName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available!'));
        } else {
          return buildSightsGrid(snapshot.data!);
        }
      },
    );
  }

  Widget buildGridItem(double itemWidth, Uint8List imageBytes, String title,
      double destLatitude, double destLongitude, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.memory(
                          imageBytes,
                          semanticLabel: title,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Flexible(
                          child: IconButton(
                            onPressed: () {
                              textToSpeechConfig.speak(title);
                            },
                            icon: Icon(Icons.volume_up_sharp,
                                semanticLabel: title),
                            enableFeedback: true,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SizedBox(
                width: itemWidth,
                height: itemWidth,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.fitWidth,
                  semanticLabel: title,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: itemWidth,
              height: 48.0,
              child: MaterialButton(
                onPressed: () async {
                  textToSpeechConfig
                      .speak(localization(context).startNavigation);
                  await mapScreen.getCurrentLocation(context);
                  await mapScreen.navigateToDestination(
                      destLatitude, destLongitude);
                },
                enableFeedback: true,
                child: Text(
                  localization(context).startNavigation,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSightsGrid(List<Map<String, dynamic>> sightsData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final itemWidth = (screenWidth / 2).floorToDouble();

        return GridView.builder(
          shrinkWrap: true,
          itemCount: sightsData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            final Uint8List imageBytes = sightsData[index]['sights_image_path'];
            final String title = sightsData[index]['title'];
            final double destLatitude = sightsData[index]['latitude'];
            final double destLongitude = sightsData[index]['longitude'];

            return buildGridItem(itemWidth, imageBytes, title, destLatitude,
                destLongitude, context);
          },
        );
      },
    );
  }
}

Future<List<Map<String, dynamic>>> _getSightsDataFromDatabase(
    String languageCode) async {
  final Database db = await DatabaseHelper.getNamedDatabase();

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
