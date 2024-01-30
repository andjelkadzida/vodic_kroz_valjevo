import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vodic_kroz_valjevo/maps_navigation/map_builder.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/locator.dart';
import '../../styles/common_styles.dart';

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
          child: GestureDetector(
            onTap: () => {
              showRestaurantDetailsDialog(context, restaurantData),
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

Future<void> showRestaurantDetailsDialog(
    BuildContext context, Map<String, dynamic> restaurantData) async {
  final MediaQueryData mediaQueryData = MediaQuery.of(context);
  final double screenHeight = mediaQueryData.size.height;
  final MapScreen mapScreen = MapScreen();
  double? distance;
  Position? currentPosition = await mapScreen.getCurrentLocation();
  if (currentPosition != null) {
    LatLng userPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    LatLng restaurantPosition =
        LatLng(restaurantData['latitude'], restaurantData['longitude']);
    distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        restaurantPosition.latitude,
        restaurantPosition.longitude);
  }

  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Semantics(
                label: localization(context).restaurantName,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: restaurantData['title'],
                    style: AppStyles.hotelsAndRestaurantsTitleStyle(
                        MediaQuery.of(context).textScaler),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              CarouselSlider.builder(
                itemCount: 3,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  List<Uint8List> images = [
                    restaurantData['restaurant_image_path'],
                    restaurantData['restaurant_image_path2'],
                    restaurantData['restaurant_image_path3'],
                  ];

                  //Prechache images to avoid screen flickering
                  precacheImage(MemoryImage(images[itemIndex]), context);

                  return Semantics(
                    label: localization(context).hotelImage,
                    child: InteractiveViewer(
                      child: Image.memory(
                        images[itemIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  aspectRatio: 2.0,
                  initialPage: 0,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Semantics(
                child: Text(
                  distance != null
                      ? '${localization(context).distanceFromRestaurant} $distance m'
                      : localization(context).distanceNotAvailable,
                  style: AppStyles.hotelsAndRestaurantsTextStyle(
                      MediaQuery.of(context).textScaler),
                ),
              ),
              Semantics(
                button: true,
                label: localization(context).closeDialog,
                child: Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: TextButton(
                    child: Text(
                      localization(context).close,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
