import 'package:flutter/material.dart';

import '../database_config/database_helper.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';
import '../navigation/navigation_helper.dart';
import 'parks/park_details.dart';
import 'sports/sport_details.dart';

class SportsAndRecreation extends StatelessWidget {
  const SportsAndRecreation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return Scaffold(
              appBar: customAppBar(
                context,
                localization(context).sportRecreation,
              ),
              body: Column(
                children: [
                  Semantics(
                    child: Text(
                      localization(context).parks,
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getParksDataFromDatabase(
                        localization(context).localeName),
                    builder: (context, snapshot) {
                      return DatabaseHelper.buildFutureState<
                          List<Map<String, dynamic>>>(
                        context: context,
                        snapshot: snapshot,
                        onData: (data) => _buildSportsSlider(
                            context, data, constraints, orientation),
                      );
                    },
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Semantics(
                    child: Text(
                      localization(context).sportFields,
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getSportsDataFromDatabase(
                        localization(context).localeName),
                    builder: (context, snapshot) {
                      return DatabaseHelper.buildFutureState<
                          List<Map<String, dynamic>>>(
                        context: context,
                        snapshot: snapshot,
                        onData: (data) => _buildSportsSlider(
                            context, data, constraints, orientation),
                      );
                    },
                  ),
                ],
              ),
              bottomNavigationBar: const CustomBottomNavigationBar(),
            );
          },
        );
      },
    );
  }

  Widget _buildSportsSlider(
      BuildContext context,
      List<Map<String, dynamic>> data,
      BoxConstraints constraints,
      Orientation orientation) {
    double viewportFraction = constraints.maxWidth < 600 ? 0.8 : 0.5;

    return Expanded(
      child: PageView.builder(
        itemCount: data.length,
        controller: PageController(viewportFraction: viewportFraction),
        itemBuilder: (context, index) {
          var item = data[index];
          return _buildSportsItem(context, item, constraints, orientation);
        },
      ),
    );
  }

  Widget _buildSportsItem(BuildContext context, Map<String, dynamic> data,
      BoxConstraints constraints, Orientation orientation) {
    return Card(
      margin: EdgeInsets.all(constraints.maxWidth * 0.02),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              data.containsKey('park_image_path')
                  ? showDetailsPage(
                      context,
                      ParkDetailsPage(
                        parkId: data['id'],
                      ))
                  : showDetailsPage(
                      context, SportDetailsPage(sportId: data['id']));
            },
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Semantics(
                onTapHint: data.containsKey('park_image_path')
                    ? localization(context).tapToViewPark
                    : localization(context).tapToViewSport,
                child: Image.asset(
                  data.containsKey('park_image_path')
                      ? data['park_image_path']
                      : data['sport_image_path'],
                  fit: BoxFit.cover,
                  semanticLabel: localization(context).image(data['title']),
                ),
              ),
            ),
          )),
          Container(
            padding: EdgeInsets.all(constraints.maxWidth * 0.02),
            decoration: BoxDecoration(
              color: Colors.teal[300],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Semantics(
                child: Text(
                  data['title'],
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: orientation == Orientation.portrait ? 2 : 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Getting sports data from the database
  Future<List<Map<String, dynamic>>> _getSportsDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT
        id,
        sport_image_path,
        sport_image_path2,
        sport_image_path3,
        title_$languageCode AS title,
        latitude,
        longitude,
        description_$languageCode AS description
      FROM Sports
    ''');
    return data;
  }

  // Getting parks data from the database
  Future<List<Map<String, dynamic>>> _getParksDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT
        id,
        park_image_path,
        park_image_path2,
        park_image_path3,
        title_$languageCode AS title,
        latitude,
        longitude,
        description_$languageCode AS description
      FROM Parks
    ''');
    return data;
  }
}
