import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For setting preferred orientations
import 'package:vodic_kroz_valjevo/maps_navigation/locator.dart';
import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../navigation/cutom_app_bar.dart';
import 'sight_details_page.dart';

class Sights extends StatelessWidget {
  Sights({Key? key}) : super(key: key);
  final MapScreen mapScreen = MapScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).restaurants,
      ),
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
    int crossAxisCount = MediaQuery.of(context).size.width > 800
        ? 4
        : MediaQuery.of(context).size.width > 600
            ? 3
            : 2;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: MediaQuery.of(context).size.aspectRatio * 1.5,
      ),
      itemCount: sightsData.length,
      itemBuilder: (BuildContext context, int index) {
        return buildGridItem(context, sightsData[index]);
      },
    );
  }

  Widget buildGridItem(BuildContext context, Map<String, dynamic> sightData) {
    return Semantics(
      button: true,
      label: sightData['title'],
      hint: localization(context).tapForSightDetails,
      child: Card(
        child: InkWell(
          onTap: () {
            _showSightDetails(context, sightData);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  sightData['title'],
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Image.asset(
                  sightData['sights_image_path'],
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    mapScreen.navigateToDestination(
                        sightData['latitude'], sightData['longitude']);
                    HapticFeedback.lightImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      localization(context).startNavigation,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
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

  void _showSightDetails(BuildContext context, Map<String, dynamic> sightData) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => SightDetailsPage(
          sightData: sightData,
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getSightsFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    return await db.rawQuery('''
      SELECT 
        sights_image_path, 
        title_$languageCode AS title, 
        description_$languageCode AS description,
        latitude, 
        longitude
      FROM Sights
    ''');
  }
}
