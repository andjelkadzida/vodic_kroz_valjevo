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

        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Hotels(
            hotel_image_path, 
            latitude,
            longitude,
            title_en, 
            title_de, 
            title_sr, 
            title_sr_Cyrl, 
            title_sr_Latn, 
            noStars
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          imageBytes,
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
        'imagePath': 'images/muzejLogo.png',
        'latitude': 44.26925398584459,
        'longitude': 19.885692396117847,
        'titles': {
          'en': 'Valjevo Museum',
          'de': 'Museum von Valjevo',
          'sr': 'Valjevski muzej',
          'sr_Cyrl': 'Ваљевски музеј',
          'sr_Latn': 'Valjevski muzej',
        },
        'noStars': '3',
      },
      {
        'imagePath': 'images/kulaNenadovica.jpg',
        'latitude': 44.27809742651686,
        'longitude': 19.88519586174966,
        'titles': {
          'en': 'Nenadovic\'s tower',
          'de': 'Nenadovics Turm',
          'sr': 'Kula Nenadovića',
          'sr_Cyrl': 'Кула Ненадовића',
          'sr_Latn': 'Kula Nenadovića',
        },
        'noStars': '3',
      },
    ];

    await bulkInsertHotelsData(hotelsList);

    await _databaseInstance.close();
  }
}
