import 'package:sqflite/sqflite.dart';

class SportsRepository {
  late Database _databaseInstance;

  SportsRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if sights data exists, false otherwise
  Future<bool> checkSportsDataExists() async {
    List<Map<String, dynamic>> sports = await _databaseInstance.query('Sports');
    return sports.isNotEmpty;
  }

  Future<void> bulkInsertSportsData(List<Map<String, dynamic>> dataList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in dataList) {
        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Sports(
            sport_image_path,
            sport_image_path2,
            sport_image_path3,
            title_en,
            title_de,
            title_sr,
            title_sr_Cyrl,
            title_sr_Latn,
            latitude,
            longitude,
            description_en,
            description_de,
            description_sr,
            description_sr_Cyrl,
            description_sr_Latn
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          data['sport_image_path'],
          data['sport_image_path2'],
          data['sport_image_path3'],
          data['titles']['en'],
          data['titles']['de'],
          data['titles']['sr'],
          data['titles']['sr_Cyrl'],
          data['titles']['sr_Latn'],
          data['latitude'],
          data['longitude'],
          data['description']['en'],
          data['description']['de'],
          data['description']['sr'],
          data['description']['sr_Cyrl'],
          data['description']['sr_Latn'],
        ]);
      }
      // Commit the batch
      await batch.commit();
    });
  }

  Future<void> sportsDataInsertion() async {
    List<Map<String, dynamic>> dataList = [
      // Peti Puk
      {
        'sport_image_path': 'images/sportsImages/petiPuk/petiPuk1.jpg',
        'sport_image_path2': 'images/sportsImages/petiPuk/petiPuk2.jpg',
        'sport_image_path3': 'images/sportsImages/petiPuk/petiPuk3.jpg',
        'titles': {
          'en': 'Stadium of the FC Radnički Valjevo',
          'de': 'Stadion des FC Radnički Valjevo',
          'sr': 'Stadion FK Radnički Valjevo',
          'sr_Cyrl': 'Стадион ФК Раднички Ваљево',
          'sr_Latn': 'Stadion FK Radnički Valjevo',
        },
        'latitude': 44.28262046857639,
        'longitude': 19.891158538859084,
        'description': {
          'en': 'Description in English',
          'de': 'Beschreibung auf Deutsch',
          'sr': 'Опис на српском',
          'sr_Cyrl': 'Опис на српском ћирилицом',
          'sr_Latn': 'Opis na srpskom latinicom',
        },
      },
      // Gradski stadion
      {
        'sport_image_path':
            'images/sportsImages/gradskiStadion/gradskiStadion1.jpg',
        'sport_image_path2':
            'images/sportsImages/gradskiStadion/gradskiStadion2.jpg',
        'sport_image_path3':
            'images/sportsImages/gradskiStadion/gradskiStadion3.jpg',
        'titles': {
          'en': 'Stadium of the FC Budućnost',
          'de': 'Stadion des FC Budućnost',
          'sr': 'Stadion FK Budućnost',
          'sr_Cyrl': 'Стадион ФК Будућност',
          'sr_Latn': 'Stadion FK Budućnost',
        },
        'latitude': 44.261982888560105,
        'longitude': 19.874679134004655,
        'description': {
          'en': 'Description in English',
          'de': 'Beschreibung auf Deutsch',
          'sr': 'Опис на српском',
          'sr_Cyrl': 'Опис на српском ћирилицом',
          'sr_Latn': 'Opis na srpskom latinicom',
        },
      },
      // Tenis
      {
        'sport_image_path': 'images/sportsImages/tenis/tenis1.jpg',
        'sport_image_path2': 'images/sportsImages/tenis/tenis2.jpg',
        'sport_image_path3': 'images/sportsImages/tenis/tenis3.jpg',
        'titles': {
          'en': 'Tennis court',
          'de': 'Tennisplatz',
          'sr': 'Teniski teren',
          'sr_Cyrl': 'Тениски терен',
          'sr_Latn': 'Teniski teren',
        },
        'latitude': 44.26262278827975,
        'longitude': 19.876072656330674,
        'description': {
          'en': 'Description in English',
          'de': 'Beschreibung auf Deutsch',
          'sr': 'Опис на српском',
          'sr_Cyrl': 'Опис на српском ћирилицом',
          'sr_Latn': 'Opis na srpskom latinicom',
        },
      },
    ];

    await bulkInsertSportsData(dataList);
  }
}
