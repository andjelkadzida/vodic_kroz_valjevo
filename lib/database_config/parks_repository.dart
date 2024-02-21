import 'package:sqflite/sqflite.dart';

class ParksRepository {
  late Database _databaseInstance;

  ParksRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if sights data exists, false otherwise
  Future<bool> checkParksDataExists() async {
    List<Map<String, dynamic>> parks = await _databaseInstance.query('Parks');
    return parks.isNotEmpty;
  }

  Future<void> bulkInsertParksData(List<Map<String, dynamic>> dataList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in dataList) {
        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Parks(
            park_image_path,
            park_image_path2,
            park_image_path3,
            title_en,
            title_de,
            title_sr,
            title_sr_Cyrl,
            title_sr_Latn,
            latitude,
            longitude
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          data['park_image_path'],
          data['park_image_path2'],
          data['park_image_path3'],
          data['titles']['en'],
          data['titles']['de'],
          data['titles']['sr'],
          data['titles']['sr_Cyrl'],
          data['titles']['sr_Latn'],
          data['latitude'],
          data['longitude'],
        ]);
      }
      // Commit the batch
      await batch.commit();
    });
  }

  Future<void> parksDataInsertion() async {
    List<Map<String, dynamic>> dataList = [
      // Jadar
      {
        'park_image_path': 'images/parksImages/jadar/jadar1.jpg',
        'park_image_path2': 'images/parksImages/jadar/jadar2.jpg',
        'park_image_path3': 'images/parksImages/jadar/jadar3.jpg',
        'titles': {
          'en': 'Park Vide Jocić',
          'de': 'Titel auf Deutsch',
          'sr': 'Park Vide Jocić',
          'sr_Cyrl': 'Парк Виде Јоцић',
          'sr_Latn': 'Park Vide Jocić',
        },
        'latitude': 44.26955379468345,
        'longitude': 19.879072700675714,
      },
      // Pecina
      {
        'park_image_path': 'images/parksImages/pecina/pecina1.jpg',
        'park_image_path2': 'images/parksImages/pecina/pecina2.jpg',
        'park_image_path3': 'images/parksImages/pecina/pecina3.jpg',
        'titles': {
          'en': 'Pećina',
          'de': 'Pećina',
          'sr': 'Pećina',
          'sr_Cyrl': 'Пећина',
          'sr_Latn': 'Pećina',
        },
        'latitude': 44.262610342861635,
        'longitude': 19.873701632737493,
      },
      // Peti Puk
      {
        'park_image_path': 'images/parksImages/petiPuk/petiPuk1.jpg',
        'park_image_path2': 'images/parksImages/petiPuk/petiPuk2.jpg',
        'park_image_path3': 'images/parksImages/petiPuk/petiPuk3.jpg',
        'titles': {
          'en': 'Peti Puk',
          'de': 'Peti Puk',
          'sr': 'Peti Puk',
          'sr_Cyrl': 'Пети Пук',
          'sr_Latn': 'Peti Puk',
        },
        'latitude': 44.282386269219636,
        'longitude': 19.89021169469568,
      },
    ];
    await bulkInsertParksData(dataList);
  }
}
