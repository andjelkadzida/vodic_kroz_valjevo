import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            onTap: () => {
              showHotelDetailsDialog(context, hotelData),
              HapticFeedback.vibrate()
            },
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
    final textScaler = MediaQuery.textScalerOf(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Uint8List imageBytes = hotelData['hotel_image_path'];
        int numberOfStars = hotelData['noStars'];

        List<Widget> hotelStars = List.generate(
          numberOfStars,
          (index) => Semantics(
            label: '${localization(context).starRating} $numberOfStars',
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: textScaler.scale(35),
            ),
          ),
        );

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Semantics(
                  label:
                      '${localization(context).hotelName} ${hotelData['title']}',
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: hotelData['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: textScaler.scale(20),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                CarouselSlider.builder(
                  itemCount: 3,
                  itemBuilder:
                      (BuildContext context, int itemIndex, int pageViewIndex) {
                    return Semantics(
                      label: localization(context).hotelImage,
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    aspectRatio: 2.0,
                    initialPage: 2,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: hotelStars,
                ),
                SizedBox(height: screenHeight * 0.02),
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
