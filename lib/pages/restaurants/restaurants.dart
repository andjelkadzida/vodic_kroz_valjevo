import 'package:flutter/material.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_builder.dart';
import '../../navigation/cutom_app_bar.dart';
import 'restaurant_details.dart';

class Restaurants extends StatelessWidget {
  const Restaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).restaurants,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getRestaurantsFromDatabase(localization(context).localeName),
        builder: (context, snapshot) {
          return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
              context: context,
              snapshot: snapshot,
              onData: (data) => buildWithMarkers(
                  context,
                  data,
                  (restaurantData) =>
                      RestaurantDetailsPage(restaurantData: restaurantData)));
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getRestaurantsFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    return await db.rawQuery('''
      SELECT 
        restaurant_image_path, 
        restaurant_image_path2,
        title_$languageCode AS title, 
        latitude, 
        longitude
      FROM Restaurants
    ''');
  }
}
