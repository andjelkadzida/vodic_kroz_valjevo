import 'package:flutter/material.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_builder.dart';
import '../../navigation/cutom_app_bar.dart';
import 'hotel_details.dart';

class Hotels extends StatelessWidget {
  const Hotels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).hotels,
        const Color.fromRGBO(11, 20, 32, 1),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getHotelsDataFromDatabase(localization(context).localeName),
        builder: (context, snapshot) {
          return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
              context: context,
              snapshot: snapshot,
              onData: (data) => buildWithMarkers(context, data,
                  (hotelData) => HotelDetailsPage(hotelId: hotelData['id'])));
        },
      ),
    );
  }

  // Getting hotel data from the database
  Future<List<Map<String, dynamic>>> _getHotelsDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT 
        id,
        title_$languageCode AS title,
        latitude,
        longitude
      FROM 
        Hotels
    ''');
    return data;
  }
}
