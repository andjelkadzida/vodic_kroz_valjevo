import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../styles/common_styles.dart';

class Hotels extends StatelessWidget {
  Hotels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
            label: localization(context).hotels,
            child: Text(
              localization(context).hotels,
              style: AppStyles.defaultAppBarTextStyle(textScaler),
            )),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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

      final textScaler = MediaQuery.textScalerOf(context);

      return Marker(
          point: position,
          child: GestureDetector(
            onTap: () => showHotelDetailsDialog(context, hotelData),
            child: Tooltip(
              message: '${hotelData['title']}',
              child: Icon(
                Icons.pin_drop,
                size: textScaler.scale(35),
                semanticLabel: '${hotelData['title']}',
                color: Colors.black,
              ),
            ),
          ));
    }).toList();

    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(44.275, 19.898),
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  void showHotelDetailsDialog(
      BuildContext context, Map<String, dynamic> hotelData) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double screenHeight = mediaQueryData.size.height;
    final double screenWidth = mediaQueryData.size.width;
    final textScaler = MediaQuery.textScalerOf(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Uint8List imageBytes = hotelData['hotel_image_path'];
        int numberOfStars = hotelData['noStars'];

        List<Widget> hotelStars = List.generate(
          numberOfStars,
          (index) => Icon(
            Icons.star,
            color: Colors.amber,
            size: textScaler.scale(30),
          ),
        );

        return AlertDialog(
          title: Text(
            hotelData['title'],
            textAlign: TextAlign.center,
            style: AppStyles.sightTitleStyle(textScaler),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Semantics(
                  label: hotelData['title'],
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.8, // Max width constraint
                        maxHeight: screenHeight * 0.4, // Max height constraint
                      ),
                      child: Semantics(
                        label: hotelData['titel'],
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.contain,
                        ),
                      )),
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      hotelStars.map((star) => Flexible(child: star)).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      isSemanticButton: true,
                      child: Text(localization(context).close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Getting hotel data from the database
  Future<List<Map<String, dynamic>>> _getHotelsDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT 
        hotel_image_path, 
        title_$languageCode AS title, 
        latitude, 
        longitude, 
        noStars 
      FROM Hotels
    ''');
    return data;
  }
}
