import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class SportsRepository {
  late Database _databaseInstance;

  SportsRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if sights data exists, false otherwise
  Future<bool> checkSportsDataExists() async {
    List<Map<String, dynamic>> sports =
        await _databaseInstance.query('SportsAndRecreation');
    return sports.isNotEmpty;
  }

  Future<void> bulkInsertSportsData(List<Map<String, dynamic>> dataList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in dataList) {
        // Load image as Uint8List
        Uint8List imageBytes =
            await DatabaseHelper.loadImageAsUint8List(data['imagePath']);

        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO SportsAndRecreation(
            sports_image_path,
            title_en,
            title_de,
            title_sr,
            title_sr_Cyrl,
            title_sr_Latn
          )
          VALUES(?, ?, ?, ?, ?, ?)
        ''', [
          imageBytes,
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

  Future<void> sportsDataInsertion() async {
    List<Map<String, dynamic>> dataList = [
      {
        'imagePath': 'images/muzejLogo.png',
        'titles': {
          'en': 'Park na Jadru (Park Vide Jocić)',
          'de': 'Titel auf Deutsch',
          'sr': 'Naslov na srpskom latinicom',
          'sr_Cyrl': 'Наслов на српском ћирилицом',
          'sr_Latn': 'Naslov na srpskom latinicom',
        },
      },
      {
        'imagePath': 'images/kulaNenadovica.jpg',
        'titles': {
          'en': 'Nenadovic\'s tower',
          'de': 'Nenadovics Turm',
          'sr': 'Kula Nenadovića',
          'sr_Cyrl': 'Кула Ненадовића',
          'sr_Latn': 'Kula Nenadovića',
        },
      },
    ];

    await bulkInsertSportsData(dataList);
  }
}
