import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class SightsRepository {
  late Database _databaseInstance;

  SightsRepository(Database database) {
    _databaseInstance = database;
  }

  Future<void> bulkInsertSightsData(List<Map<String, dynamic>> dataList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in dataList) {
        // Load image as Uint8List
        Uint8List imageBytes = await _loadImageAsUint8List(data['imagePath']);

        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Sights(
            sights_image_path, 
            latitude,
            longitude,
            title_en, 
            title_de, 
            title_sr, 
            title_sr_Cyrl, 
            title_sr_Latn, 
            description_en, 
            description_de, 
            description_sr, 
            description_sr_Cyrl, 
            description_sr_Latn
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          imageBytes,
          data['latitude'],
          data['longitude'],
          data['titles']['en'],
          data['titles']['de'],
          data['titles']['sr'],
          data['titles']['sr_Cyrl'],
          data['titles']['sr_Latn'],
          data['descriptions']['en'],
          data['descriptions']['de'],
          data['descriptions']['sr'],
          data['descriptions']['sr_Cyrl'],
          data['descriptions']['sr_Latn'],
        ]);
      }
      // Commit the batch
      await batch.commit();
    });
  }

  Future<Uint8List> _loadImageAsUint8List(String imagePath) async {
    ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }

  Future<void> dataInsertion() async {
    List<Map<String, dynamic>> dataList = [
      {
        'imagePath': 'images/muzejLogo.png',
        'latitude': 44.26925398584459,
        'longitude': 19.885692396117847,
        'titles': {
          'en': 'Valjevo Museum',
          'de': 'Titel auf Deutsch',
          'sr': 'Naslov na srpskom latinicom',
          'sr_Cyrl': 'Наслов на српском ћирилицом',
          'sr_Latn': 'Naslov na srpskom latinicom',
        },
        'descriptions': {
          'en': 'Description in English',
          'de': 'Beschreibung auf Deutsch',
          'sr': 'Opis na srpskom latinicom',
          'sr_Cyrl': 'Опис на српском ћирилицом',
          'sr_Latn': 'Opis na srpskom latinicom',
        },
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
        'descriptions': {
          'en': 'Tower description',
          'de': 'Turm Beschreibung',
          'sr': 'Kula opis',
          'sr_Cyrl': 'Кула опис',
          'sr_Latn': 'Kula opis',
        },
      },
    ];

    await bulkInsertSightsData(dataList);

    await _databaseInstance.close();
  }
}
