import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vodic_kroz_valjevo/database_config/db_helper.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth / 2).floor();

    int crossAxisCount = (screenWidth / itemWidth).floor();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSightsDataFromDatabase(localization(context).localeName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          final List<Map<String, dynamic>> sightsData = snapshot.data!;

          return ListView(
            children: [
              GridView.builder(
                shrinkWrap: true,
                itemCount: sightsData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final Uint8List imageBytes =
                      sightsData[index]['sights_image_path'];
                  final String title = sightsData[index]['title'];
                  final double destLatitude = sightsData[index]['latitude'];
                  final double destLongitude = sightsData[index]['longitude'];

                  return Column(
                    children: [
                      GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return Dialog(
                                child: InteractiveViewer(
                                  boundaryMargin: const EdgeInsets.all(20.0),
                                  minScale: 0.5,
                                  maxScale: 5.0,
                                  child: Image.memory(
                                    imageBytes,
                                    fit: BoxFit.cover,
                                    semanticLabel: title,
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
                              SizedBox(
                                width: itemWidth.toDouble(),
                                height: itemWidth.toDouble(),
                                child: Image.memory(
                                  imageBytes,
                                  fit: BoxFit.fitWidth,
                                  semanticLabel: title,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              SizedBox(
                                width: itemWidth.toDouble(),
                                height: 48.0,
                                child: MaterialButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  onPressed: () async {
                                    print('Button pressed');
                                    textToSpeechConfig.speak(
                                        localization(context).startNavigation);
                                    await mapScreen.getCurrentLocation(context);
                                    await mapScreen.navigateToDestination(
                                        destLatitude, destLongitude);
                                  },
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
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        }
      },
    );
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
}
