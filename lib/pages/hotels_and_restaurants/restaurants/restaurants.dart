import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../database_config/database_helper.dart';
import '../../../localization/supported_languages.dart';
import '../../../maps_navigation/map_builder.dart';
import '../../../styles/common_styles.dart';
import 'restaurant_details.dart';

class Restaurants extends StatelessWidget {
  const Restaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: localization(context).restaurants,
          child: Text(
            localization(context).restaurants,
            style: AppStyles.defaultAppBarTextStyle(
                MediaQuery.of(context).textScaler),
          ),
        ),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
              _showRestaurantDetails(context, restaurantData),
              HapticFeedback.selectionClick()
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

  void _showRestaurantDetails(
      BuildContext context, Map<String, dynamic> restaurantData) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RestaurantDetailsPage(
          restaurantData: restaurantData,
        ),
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
        restaurant_image_path3,
        title_$languageCode AS title, 
        latitude, 
        longitude
      FROM Restaurants
    ''');
  }
}
