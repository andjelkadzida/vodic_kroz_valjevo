import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class RestaurantsRepository {
  late Database _databaseInstance;

  RestaurantsRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if restaurants data exists, false otherwise
  Future<bool> checkRestaurantsDataExist() async {
    List<Map<String, dynamic>> restaurants =
        await _databaseInstance.query('Restaurants');
    return restaurants.isNotEmpty;
  }

  Future<void> bulkInsertRestaurantsData(
      List<Map<String, dynamic>> restaurantsList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in restaurantsList) {
        // Load image as Uint8List
        Uint8List imageBytes =
            await DatabaseHelper.loadImageAsUint8List(data['imagePath']);
        Uint8List imageBytes2 =
            await DatabaseHelper.loadImageAsUint8List(data['imagePath2']);
        Uint8List imageBytes3 =
            await DatabaseHelper.loadImageAsUint8List(data['imagePath3']);

        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Restaurants(
            restaurant_image_path, 
            restaurant_image_path2, 
            restaurant_image_path3, 
            latitude,
            longitude,
            title_en, 
            title_de, 
            title_sr, 
            title_sr_Cyrl, 
            title_sr_Latn
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
          data['titles']['sr_Latn']
        ]);
      }
      // Commit the batch
      await batch.commit();
    });
  }

  Future<void> restaurantsDataInsertion() async {
    List<Map<String, dynamic>> restaurantsList = [
      {
        'imagePath': 'images/restaurantsImages/paviljonNapolju.jpeg',
        'imagePath2': 'images/restaurantsImages/paviljonPrizemlje.jpeg',
        'imagePath3': 'images/restaurantsImages/paviljonSprat.jpeg',
        'latitude': 44.26121378368397,
        'longitude': 19.878408885329353,
        'titles': {
          'en': 'Paviljon "Markova stolica"',
          'de': 'Paviljon "Markova stolica"',
          'sr': 'Paviljon "Markova stolica"',
          'sr_Cyrl': 'Павиљон "Маркова столица"',
          'sr_Latn': 'Paviljon "Markova stolica"'
        },
      },
      {
        'imagePath': 'images/restaurantsImages/lovciNapolju.jpeg',
        'imagePath2': 'images/restaurantsImages/lovciUnutra.jpeg',
        'imagePath3': 'images/restaurantsImages/lovciHrana.jpeg',
        'latitude': 44.26254034889633,
        'longitude': 19.870473925801104,
        'titles': {
          'en': 'Restoran Lovački dom',
          'de': 'Restoran Lovački dom',
          'sr': 'Restoran Lovački dom',
          'sr_Cyrl': 'Ресторан Ловачки дом',
          'sr_Latn': 'Restoran Lovački dom'
        },
      },
      {
        'imagePath': 'images/restaurantsImages/kucaSpolja.jpeg',
        'imagePath2': 'images/restaurantsImages/kucaUnutra.jpeg',
        'imagePath3': 'images/restaurantsImages/kucaHrana.jpeg',
        'latitude': 44.270799571481014,
        'longitude': 19.891283525386942,
        'titles': {
          'en': 'Restoran Kuća',
          'de': 'Restoran Kuća',
          'sr': 'Restoran Kuća',
          'sr_Cyrl': 'Ресторан Кућа',
          'sr_Latn': 'Restoran Kuća'
        },
      },
      {
        'imagePath': 'images/restaurantsImages/tavernaSpolja.jpeg',
        'imagePath2': 'images/restaurantsImages/tavernaUnutra.jpeg',
        'imagePath3': 'images/restaurantsImages/tavernaHrana.jpeg',
        'latitude': 44.27082751943143,
        'longitude': 19.8831951515897,
        'titles': {
          'en': 'Taverna 014',
          'de': 'Taverna 014',
          'sr': 'Taverna 014',
          'sr_Cyrl': 'Таверна 014',
          'sr_Latn': 'Taverna 014'
        },
      },
      {
        'imagePath': 'images/restaurantsImages/laPiazzaSpolja.jpeg',
        'imagePath2': 'images/restaurantsImages/laPiazzaUnutra.jpeg',
        'imagePath3': 'images/restaurantsImages/laPiazzaHrana.jpeg',
        'latitude': 44.27005106183441,
        'longitude': 19.884875712310876,
        'titles': {
          'en': 'La Piazza',
          'de': 'La Piazza',
          'sr': 'La Piazza',
          'sr_Cyrl': 'La Piazza',
          'sr_Latn': 'La Piazza'
        },
      },
    ];

    await bulkInsertRestaurantsData(restaurantsList);
  }
}
