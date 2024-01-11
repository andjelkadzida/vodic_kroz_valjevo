import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../styles/common_styles.dart';

class Hotels extends StatelessWidget {
  const Hotels({Key? key}) : super(key: key);

  Future<List<LatLng>> fetchMarkerData() async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT latitude, longitude FROM Hotels');

    return List.generate(maps.length, (i) {
      return LatLng(
        maps[i]['latitude'] as double,
        maps[i]['longitude'] as double,
      );
    });
  }

  void _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      AppSettings.openAppSettings(type: AppSettingsType.wireless);
    }
  }

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
          iconTheme:
              const IconThemeData(color: Colors.white) // Color of drawer icon
          ),
      body: FutureBuilder<List<LatLng>>(
        future: fetchMarkerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(''));
          }
          // Open settings for internet if there is no Internet connection
          _checkInternetConnection();

          List<Marker> markers = snapshot.data!
              .map((latLng) => Marker(
                    point: latLng,
                    child: const Icon(Icons.pin_drop),
                  ))
              .toList();

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(44.275, 19.898),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getHotelsDataFromDatabase(
      String languageCode) async {
    final Database db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT 
        hotels_image_path, 
        title_$languageCode AS title,
        latitude,
        longitude,
        noStars
      FROM 
        Hotels
    ''');
    return data;
  }
}
