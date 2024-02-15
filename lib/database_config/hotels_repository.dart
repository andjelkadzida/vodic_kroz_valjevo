import 'package:sqflite/sqflite.dart';

class HotelsRepository {
  late Database _databaseInstance;

  HotelsRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if hotels data exists, false otherwise
  Future<bool> checkHotelsDataExist() async {
    List<Map<String, dynamic>> hotels = await _databaseInstance.query('Hotels');
    return hotels.isNotEmpty;
  }

  Future<void> bulkInsertHotelsData(
      List<Map<String, dynamic>> hotelsList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in hotelsList) {
        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Hotels(
            hotel_image_path, 
            hotel_image_path2, 
            latitude,
            longitude,
            title_en, 
            title_de, 
            title_sr, 
            title_sr_Cyrl, 
            title_sr_Latn, 
            website,
            noStars
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          data['hotel_image_path'],
          data['hotel_image_path2'],
          data['latitude'],
          data['longitude'],
          data['titles']['en'],
          data['titles']['de'],
          data['titles']['sr'],
          data['titles']['sr_Cyrl'],
          data['titles']['sr_Latn'],
          data['website'],
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
        'hotel_image_path': 'images/hotelsImages/bubicaSpolja.jpeg',
        'hotel_image_path2': 'images/hotelsImages/bubicaSoba.jpeg',
        'latitude': 44.269317305096884,
        'longitude': 19.890976396550382,
        'titles': {
          'en': 'Bubica Residence',
          'de': 'Bubica Residenze',
          'sr': 'Konačište Bubica',
          'sr_Cyrl': 'Коначиште Бубица',
          'sr_Latn': 'Konačište Bubica',
        },
        'website': 'https://bubica.co.rs',
        'noStars': '3',
      },
      {
        'hotel_image_path': 'images/hotelsImages/grandSpolja.jpeg',
        'hotel_image_path2': 'images/hotelsImages/grandSoba.jpg',
        'latitude': 44.26931060511534,
        'longitude': 19.884675167713866,
        'titles': {
          'en': 'Hotel Grand',
          'de': 'Hotel Grand',
          'sr': 'Hotel Grand',
          'sr_Cyrl': 'Хотел Гранд',
          'sr_Latn': 'Hotel Grand',
        },
        'website': 'https://www.facebook.com/hotelgrandvaljevo/?locale=sr_RS',
        'noStars': '3',
      },
      {
        'hotel_image_path': 'images/hotelsImages/omniSpolja.jpg',
        'hotel_image_path2': 'images/hotelsImages/omniSoba.jpg',
        'latitude': 44.26323769320158,
        'longitude': 19.890492339708686,
        'titles': {
          'en': 'Hotel Omni',
          'de': 'Hotel Omni',
          'sr': 'Hotel Omni',
          'sr_Cyrl': 'Хотел Омни',
          'sr_Latn': 'Hotel Omni',
        },
        'website': 'https://omnicentar.rs/hotel-omni/',
        'noStars': '4',
      },
    ];

    await bulkInsertHotelsData(hotelsList);
  }
}
