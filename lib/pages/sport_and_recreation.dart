import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../database_config/database_helper.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';

class SportsAndRecreation extends StatelessWidget {
  const SportsAndRecreation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var headlineStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: MediaQuery.of(context).size.width * 0.05,
        );

    return Scaffold(
      appBar: AppBar(
        title:
            Text(localization(context).sportRecreation, style: headlineStyle),
        excludeHeaderSemantics: true,
        toolbarTextStyle: Theme.of(context).primaryTextTheme.titleLarge,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getSportsDataFromDatabase(localization(context).localeName),
        builder: (context, snapshot) {
          return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
            context: context,
            snapshot: snapshot,
            onData: (data) => buildSportsUI(context, data),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget buildSportsUI(BuildContext context, List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          _buildHorizontalListView(localization(context).sportFields, data,
              MediaQuery.of(context).size),
          _buildHorizontalListView(
              localization(context).parks, data, MediaQuery.of(context).size),
        ],
      ),
    );
  }

  Widget _buildHorizontalListView(
      String title, List<Map<String, dynamic>> data, Size screenSize) {
    double itemHeight = screenSize.height * 0.3;
    double itemWidth = screenSize.width * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
            ),
            // Provide semantics for the title for screen readers
            semanticsLabel: '$title section',
          ),
        ),
        SizedBox(
            height: itemHeight,
            child: ListView.separated(
              padding:
                  EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: screenSize.width * 0.02),
              itemBuilder: (BuildContext context, int index) {
                var item = data[index];
                Uint8List imageBytes = item['sports_image_path'];

                return Container(
                  width: itemWidth,
                  margin:
                      EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }

  // Getting hotel data from the database
  Future<List<Map<String, dynamic>>> _getSportsDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT
        sports_image_path,
        title_$languageCode AS title
      FROM SportsAndRecreation
    ''');
    return data;
  }
}
