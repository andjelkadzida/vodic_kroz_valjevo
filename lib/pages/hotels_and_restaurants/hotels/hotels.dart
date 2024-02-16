import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../database_config/database_helper.dart';
import '../../../localization/supported_languages.dart';
import '../../../maps_navigation/map_builder.dart';
import '../../../navigation/cutom_app_bar.dart';
import 'hotel_details.dart';

class Hotels extends StatelessWidget {
  const Hotels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).hotels,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getHotelsDataFromDatabase(localization(context).localeName),
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
      BuildContext context, List<Map<String, dynamic>> hotelsData) {
    List<Marker> markers = hotelsData.map((hotelData) {
      LatLng position = LatLng(
          hotelData['latitude'] as double, hotelData['longitude'] as double);

      return Marker(
        point: position,
        width: MediaQuery.of(context).textScaler.scale(48),
        height: MediaQuery.of(context).textScaler.scale(48),
        child: GestureDetector(
          onTap: () => _showHotelDetails(context, hotelData),
          child: Tooltip(
            message: '${hotelData['title']}',
            child: Icon(
              Icons.location_pin,
              size: MediaQuery.of(context).textScaler.scale(35),
              semanticLabel: '${hotelData['title']}',
              color: Colors.blue,
            ),
          ),
        ),
      );
    }).toList();

    return buildMapWithMarkers(markers);
  }

  void _showHotelDetails(BuildContext context, Map<String, dynamic> hotelData) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => HotelDetailsPage(
          hotelData: hotelData,
        ),
      ),
    );
  }

// Getting hotel data from the database
  Future<List<Map<String, dynamic>>> _getHotelsDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT 
        hotel_image_path, 
        hotel_image_path2,
        title_$languageCode AS title, 
        website,
        latitude, 
        longitude, 
        noStars 
      FROM Hotels
    ''');
    return data;
  }
}
