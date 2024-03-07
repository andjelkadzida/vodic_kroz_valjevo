import 'package:sqflite/sqflite.dart';

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
        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Restaurants(
            restaurant_image_path, 
            restaurant_image_path2, 
            latitude,
            longitude,
            title_en, 
            title_de, 
            title_sr, 
            title_sr_Cyrl, 
            title_sr_Latn
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          data['restaurant_image_path'],
          data['restaurant_image_path2'],
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
        'restaurant_image_path':
            'images/restaurantsImages/paviljonNapolju.jpeg',
        'restaurant_image_path2': 'images/restaurantsImages/paviljonUnutra.jpg',
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
        'restaurant_image_path': 'images/restaurantsImages/lovciNapolju.jpeg',
        'restaurant_image_path2': 'images/restaurantsImages/lovciUnutra.jpeg',
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
        'restaurant_image_path': 'images/restaurantsImages/kucaSpolja.jpg',
        'restaurant_image_path2': 'images/restaurantsImages/kucaUnutra.jpg',
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
        'restaurant_image_path': 'images/restaurantsImages/tavernaSpolja.jpg',
        'restaurant_image_path2': 'images/restaurantsImages/tavernaUnutra.jpg',
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
        'restaurant_image_path': 'images/restaurantsImages/laPiazzaSpolja.jpg',
        'restaurant_image_path2': 'images/restaurantsImages/laPiazzaUnutra.jpg',
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
