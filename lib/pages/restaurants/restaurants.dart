import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_builder.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../navigation/navigation_helper.dart';
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
            onData: (data) => buildWithMarkers(context, data),
          );
        },
      ),
    );
  }

  // Creating markers on map dynamically
  Widget buildWithMarkers(
      BuildContext context, List<Map<String, dynamic>> restaurantsData) {
    List<Marker> markers = restaurantsData.map((restaurantData) {
      LatLng position = LatLng(restaurantData['latitude'] as double,
          restaurantData['longitude'] as double);

      return Marker(
          point: position,
          width: MediaQuery.of(context).textScaler.scale(48),
          height: MediaQuery.of(context).textScaler.scale(48),
          child: GestureDetector(
            onTap: () => {
              showDetailsPage(context,
                  RestaurantDetailsPage(restaurantData: restaurantData))
            },
            child: Tooltip(
              message: '${restaurantData['title']}',
              child: Icon(
                Icons.location_pin,
                size: MediaQuery.of(context).textScaler.scale(35),
                semanticLabel: '${restaurantData['title']}',
                color: Colors.blue,
              ),
            ),
          ));
    }).toList();

    return buildMapWithMarkers(markers);
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
