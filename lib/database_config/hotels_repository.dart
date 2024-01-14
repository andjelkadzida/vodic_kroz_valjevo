import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class HotelsRepository {
  late Database _databaseInstance;

  HotelsRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if hotels data exists, false otherwise
  Future<bool> checkHotelsDataExist() async {
    List<Map<String, dynamic>> sights = await _databaseInstance.query('Hotels');
    return sights.isNotEmpty;
  }

  Future<void> bulkInsertHotelsData(
      List<Map<String, dynamic>> hotelsList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in hotelsList) {
        // Load image as Uint8List
        Uint8List imageBytes =
            await DatabaseHelper.loadImageAsUint8List(data['imagePath']);
        Uint8List imageBytes2 =
            await DatabaseHelper.loadImageAsUint8List(data['imagePath2']);
        Uint8List imageBytes3 =
            await DatabaseHelper.loadImageAsUint8List(data['imagePath3']);

        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Hotels(
            hotel_image_path, 
            hotel_image_path2, 
            hotel_image_path3, 
            latitude,
            longitude,
            title_en, 
            title_de, 
            title_sr, 
            title_sr_Cyrl, 
            title_sr_Latn, 
            noStars
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          imageBytes,
          imageBytes2,
          imageBytes3,
          data['latitude'],
          data['longitude'],
          data['titles']['en'],
          data['titles']['de'],
          data['titles']['sr'],
          data['titles']['sr_Cyrl'],
          data['titles']['sr_Latn'],
          data['noStars'],
        ]);
      }
      // Commit the batch
      await batch.commit();
    });
  }

  Future<void> hotelsDataInsertion() async {
    List<Map<String, dynamic>> hotelsList = [
      {
        'imagePath': 'images/hotelsImages/bubicaSpolja.jpeg',
        'imagePath2': 'images/hotelsImages/bubicaSoba.jpeg',
        'imagePath3': 'images/hotelsImages/bubicaKupatilo.jpeg',
        'latitude': 44.269317305096884,
        'longitude': 19.890976396550382,
        'titles': {
          'en': 'Bubica Residence',
          'de': 'Bubica Residenze',
          'sr': 'Konačište Bubica',
          'sr_Cyrl': 'Коначиште Бубица',
          'sr_Latn': 'Konačište Bubica',
        },
        'noStars': '3',
      },
      {
        'imagePath': 'images/hotelsImages/grandSpolja.jpeg',
        'imagePath2': 'images/hotelsImages/grandSoba.jpg',
        'imagePath3': 'images/hotelsImages/grandKupatilo.jpg',
        'latitude': 44.26931060511534,
        'longitude': 19.884675167713866,
        'titles': {
          'en': 'Hotel Grand',
          'de': 'Hotel Grand',
          'sr': 'Hotel Grand',
          'sr_Cyrl': 'Хотел Гранд',
          'sr_Latn': 'Hotel Grand',
        },
        'noStars': '3',
      },
      {
        'imagePath': 'images/hotelsImages/omniSpolja.jpg',
        'imagePath2': 'images/hotelsImages/omniSoba.jpg',
        'imagePath3': 'images/hotelsImages/omniKupatilo.jpg',
        'latitude': 44.26323769320158,
        'longitude': 19.890492339708686,
        'titles': {
          'en': 'Hotel Omni',
          'de': 'Hotel Omni',
          'sr': 'Hotel Omni',
          'sr_Cyrl': 'Хотел Омни',
          'sr_Latn': 'Hotel Omni',
        },
        'noStars': '4',
      },
    ];

    await bulkInsertHotelsData(hotelsList);

    await _databaseInstance.close();
  }
}
