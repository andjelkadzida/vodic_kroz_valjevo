import 'package:sqflite/sqflite.dart';

class AboutCityRepository {
  late Database _databaseInstance;

  AboutCityRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if about city data exists, false otherwise
  Future<bool> checkAboutCityDataExist() async {
    List<Map<String, dynamic>> aboutCity =
        await _databaseInstance.query('AboutCity');
    return aboutCity.isNotEmpty;
  }

  Future<void> bulkInsertAboutCityData(
      List<Map<String, dynamic>> aboutCityData) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in aboutCityData) {
        // Add insert operation to the batch
        batch.rawInsert('''
        INSERT INTO AboutCity(
          legend_title_en,
          legend_title_de,
          legend_title_sr,
          legend_title_sr_Cyrl,
          legend_title_sr_Latn,
          legend_description_en,
          legend_description_de,
          legend_description_sr,
          legend_description_sr_Cyrl,
          legend_description_sr_Latn
        )
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
          data['legend_title']['en'],
          data['legend_title']['de'],
          data['legend_title']['sr'],
          data['legend_title']['sr_Cyrl'],
          data['legend_title']['sr_Latn'],
          data['legend_description']['en'],
          data['legend_description']['de'],
          data['legend_description']['sr'],
          data['legend_description']['sr_Cyrl'],
          data['legend_description']['sr_Latn']
        ]);
      }
      // Commit the batch
      await batch.commit();
    });
  }

  Future<void> aboutCityDataInsertion() async {
    List<Map<String, dynamic>> aboutCityData = [
      {
        'legend_title': {
          'en': 'Legend 1',
          'de': 'Legende 1',
          'sr': 'Legenda 1',
          'sr_Cyrl': 'Легенда 1',
          'sr_Latn': 'Legenda 1'
        },
        'legend_description': {
          'en': 'Description 1',
          'de': 'Beschreibung 1',
          'sr': 'Opis 1',
          'sr_Cyrl': 'Опис 1',
          'sr_Latn': 'Opis 1'
        },
      },
      {
        'legend_title': {
          'en': 'Legend 2',
          'de': 'Legende 2',
          'sr': 'Legenda 2',
          'sr_Cyrl': 'Легенда 2',
          'sr_Latn': 'Legenda 2'
        },
        'legend_description': {
          'en': 'Description 2',
          'de': 'Beschreibung 2',
          'sr': 'Opis 2',
          'sr_Cyrl': 'Опис 2',
          'sr_Latn': 'Opis 2'
        },
      },
      {
        'legend_title': {
          'en': 'Legend 3',
          'de': 'Legende 3',
          'sr': 'Legenda 3',
          'sr_Cyrl': 'Легенда 3',
          'sr_Latn': 'Legenda 3'
        },
        'legend_description': {
          'en': 'Description 3',
          'de': 'Beschreibung 3',
          'sr': 'Opis 3',
          'sr_Cyrl': 'Опис 3',
          'sr_Latn': 'Opis 3'
        },
      },
    ];

    await bulkInsertAboutCityData(aboutCityData);
  }
}
