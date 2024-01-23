import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../styles/common_styles.dart';

class Hotels extends StatelessWidget {
  const Hotels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: localization(context).hotels,
          child: Text(
            localization(context).hotels,
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
          child: GestureDetector(
            onTap: () => {
              showHotelDetailsDialog(context, hotelData),
              HapticFeedback.selectionClick()
            },
            child: Tooltip(
              message: '${hotelData['title']}',
              child: Icon(
                Icons.location_pin,
                size: MediaQuery.of(context).textScaler.scale(35),
                semanticLabel: '${hotelData['title']}',
                color: Colors.blue,
              ),
            ),
          ));
    }).toList();

    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(44.267, 19.886),
        initialZoom: 13.0,
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        int numberOfStars = hotelData['noStars'];

        Widget hotelStars = _generateStarIcons(
            numberOfStars, context, MediaQuery.of(context).textScaler);

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Semantics(
                  label: localization(context).hotelName,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: hotelData['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).textScaler.scale(20),
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
                    List<Uint8List> images = [
                      hotelData['hotel_image_path'],
                      hotelData['hotel_image_path2'],
                      hotelData['hotel_image_path3'],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [hotelStars],
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

  // Generate number of stars
  Widget _generateStarIcons(
      int numberOfStars, BuildContext context, TextScaler textScaler) {
    List<Widget> stars = List.generate(
      numberOfStars,
      (index) => Icon(
        Icons.star,
        color: Colors.amber,
        size: MediaQuery.of(context).textScaler.scale(35),
      ),
    );

    return Semantics(
      label: '${localization(context).starRating} $numberOfStars',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: stars,
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
        hotel_image_path3,
        title_$languageCode AS title, 
        latitude, 
        longitude, 
        noStars 
      FROM Hotels
    ''');
    return data;
  }
}
