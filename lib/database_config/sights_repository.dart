import 'package:sqflite/sqflite.dart';

class SightsRepository {
  late Database _databaseInstance;

  SightsRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if sights data exists, false otherwise
  Future<bool> checkSightsDataExist() async {
    List<Map<String, dynamic>> sights = await _databaseInstance.query('Sights');
    return sights.isNotEmpty;
  }

  Future<void> bulkInsertSightsData(List<Map<String, dynamic>> dataList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in dataList) {
        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Sights(
            sight_image_path, 
            sight_image_path2,
            sight_image_path3,
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
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          data['sight_image_path'],
          data['sight_image_path2'],
          data['sight_image_path3'],
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

  Future<void> sightsDataInsertion() async {
    List<Map<String, dynamic>> dataList = [
      // Valjevski muzej
      {
        'sight_image_path': 'images/sightsImages/muzej/muzej1.jpg',
        'sight_image_path2': 'images/sightsImages/muzej/muzej2.jpg',
        'sight_image_path3': 'images/sightsImages/muzej/muzej3.jpeg',
        'latitude': 44.26925398584459,
        'longitude': 19.885692396117847,
        'titles': {
          'en': 'Valjevo Museum',
          'de': 'Museum von Valjevo',
          'sr': 'Valjevski muzej',
          'sr_Cyrl': 'Ваљевски музеј',
          'sr_Latn': 'Valjevski muzej',
        },
        'descriptions': {
          'en': 'Description in English',
          'de': 'Beschreibung auf Deutsch',
          'sr': 'Opis na srpskom latinicom',
          'sr_Cyrl': 'Опис на српском ћирилицом',
          'sr_Latn': 'Opis na srpskom latinicom',
        },
      },
      // Kula Nenadovica
      {
        'sight_image_path':
            'images/sightsImages/kulaNenadovica/kulaNenadovica1.jpg',
        'sight_image_path2':
            'images/sightsImages/kulaNenadovica/kulaNenadovica2.jpg',
        'sight_image_path3':
            'images/sightsImages/kulaNenadovica/kulaNenadovica3.jpg',
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
      // Valjevska gimnazija
      {
        'sight_image_path': 'images/sightsImages/gimnazija/gimnazija1.jpg',
        'sight_image_path2': 'images/sightsImages/gimnazija/gimnazija2.jpg',
        'sight_image_path3': 'images/sightsImages/gimnazija/gimnazija3.jpg',
        'latitude': 44.27835736293161,
        'longitude': 19.8847572164086,
        'titles': {
          'en': 'Valjevo Gymnasium',
          'de': 'Gymnasium von Valjevo',
          'sr': 'Valjevska gimnazija',
          'sr_Cyrl': 'Ваљевска гимназија',
          'sr_Latn': 'Valjevska gimnazija',
        },
        'descriptions': {
          'en': 'Gymnasium description',
          'de': 'Gymnasium Beschreibung',
          'sr': 'Gimnazija opis',
          'sr_Cyrl': 'Гимназија опис',
          'sr_Latn': 'Gimnazija opis',
        },
      },
      // Srpska pravoslavna crkva Vaskrsenja Gospodnjeg
      {
        'sight_image_path': 'images/sightsImages/hram/hram1.jpg',
        'sight_image_path2': 'images/sightsImages/hram/hram2.jpg',
        'sight_image_path3': 'images/sightsImages/hram/hram3.jpg',
        'latitude': 44.274172769846494,
        'longitude': 19.889581685484366,
        'titles': {
          'en': 'Serbian Orthodox Church of the Resurrection of the Lord',
          'de': 'Serbisch-orthodoxe Kirche der Auferstehung des Herrn',
          'sr': 'Srpska pravoslavna crkva Vaskrsenja Gospodnjeg',
          'sr_Cyrl': 'Српска православна црква Васкрсења Господњег',
          'sr_Latn': 'Srpska pravoslavna crkva Vaskrsenja Gospodnjeg',
        },
        'descriptions': {
          'en': 'Church description',
          'de': 'Kirche Beschreibung',
          'sr': 'Crkva opis',
          'sr_Cyrl': 'Црква опис',
          'sr_Latn': 'Crkva opis',
        },
      },
      // Markova stolica
      {
        'sight_image_path': 'images/sightsImages/paviljon/paviljon1.jpg',
        'sight_image_path2': 'images/sightsImages/paviljon/paviljon2.jpg',
        'sight_image_path3': 'images/sightsImages/paviljon/paviljon3.jpg',
        'latitude': 44.27981454262845,
        'longitude': 19.877936945116286,
        'titles': {
          'en': 'Markova Stolica',
          'de': 'Markova Stolica',
          'sr': 'Markova Stolica',
          'sr_Cyrl': 'Маркова Столица',
          'sr_Latn': 'Markova Stolica',
        },
        'descriptions': {
          'en': 'Markova Stolica description',
          'de': 'Markova Stolica Beschreibung',
          'sr': 'Markova Stolica opis',
          'sr_Cyrl': 'Маркова Столица опис',
          'sr_Latn': 'Markova Stolica opis',
        },
      },
      // Stevan
      {
        'sight_image_path': 'images/sightsImages/stevan/stevan1.jpg',
        'sight_image_path2': 'images/sightsImages/stevan/stevan2.jpg',
        'sight_image_path3': 'images/sightsImages/stevan/stevan3.jpg',
        'latitude': 44.276073,
        'longitude': 19.891073,
        'titles': {
          'en': 'Stevan Filipovic',
          'de': 'Stevan Filipovic',
          'sr': 'Stevan Filipovic',
          'sr_Cyrl': 'Стеван Филиповић',
          'sr_Latn': 'Stevan Filipovic',
        },
        'descriptions': {
          'en': 'Stevan Filipovic description',
          'de': 'Stevan Filipovic Beschreibung',
          'sr': 'Stevan Filipovic opis',
          'sr_Cyrl': 'Стеван Филиповић опис',
          'sr_Latn': 'Stevan Filipovic opis',
        },
      },
      // Tesnjar
      {
        'sight_image_path': 'images/sightsImages/tesnjar/tesnjar1.jpg',
        'sight_image_path2': 'images/sightsImages/tesnjar/tesnjar2.jpg',
        'sight_image_path3': 'images/sightsImages/tesnjar/tesnjar3.jpg',
        'latitude': 44.29062866176497,
        'longitude': 19.876563654330376,
        'titles': {
          'en': 'Tesnjar',
          'de': 'Tesnjar',
          'sr': 'Tešnjar',
          'sr_Cyrl': 'Тешњар',
          'sr_Latn': 'Tešnjar',
        },
        'descriptions': {
          'en': 'Tesnjar description',
          'de': 'Tesnjar Beschreibung',
          'sr': 'Tešnjar opis',
          'sr_Cyrl': 'Тешњар опис',
          'sr_Latn': 'Tešnjar opis',
        },
      },
      // Zivojin Misic
      {
        'sight_image_path': 'images/sightsImages/zivojin/zivojin1.jpg',
        'sight_image_path2': 'images/sightsImages/zivojin/zivojin2.jpg',
        'sight_image_path3': 'images/sightsImages/zivojin/zivojin3.jpg',
        'latitude': 44.29052905178508,
        'longitude': 19.884803402764618,
        'titles': {
          'en': 'Monument of Zivojin Misic',
          'de': 'Denkmal von Zivojin Misic',
          'sr': 'Spomenik Živojinu Mišiću',
          'sr_Cyrl': 'Споменик Живојину Мишићу',
          'sr_Latn': 'Spomenik Živojinu Mišiću',
        },
        'descriptions': {
          'en': 'Zivojin Misic description',
          'de': 'Zivojin Misic Beschreibung',
          'sr': 'Živojin Mišić opis',
          'sr_Cyrl': 'Живојин Мишић опис',
          'sr_Latn': 'Živojin Mišić opis',
        },
      },
      // Vuk Karadzic
      {
        'sight_image_path': 'images/sightsImages/vuk/vuk1.jpg',
        'sight_image_path2': 'images/sightsImages/vuk/vuk2.jpg',
        'sight_image_path3': 'images/sightsImages/vuk/vuk3.jpg',
        'latitude': 44.27408341006808,
        'longitude': 19.886016295773146,
        'titles': {
          'en': 'Monument of Vuk Karadžić',
          'de': 'Denkmal von Vuk Karadžić',
          'sr': 'Spomenik Vuku Karadžiću',
          'sr_Cyrl': 'Споменик Вуку Караџићу',
          'sr_Latn': 'Spomenik Vuku Karadžiću',
        },
        'descriptions': {
          'en': 'Vuk Karadzic description',
          'de': 'Vuk Karadzic Beschreibung',
          'sr': 'Vuk Karadzic opis',
          'sr_Cyrl': 'Вук Караџић опис',
          'sr_Latn': 'Vuk Karadzic opis',
        },
      },
      // Desanka Maksimovic
      {
        'sight_image_path': 'images/sightsImages/desanka/desanka1.jpg',
        'sight_image_path2': 'images/sightsImages/desanka/desanka2.jpg',
        'sight_image_path3': 'images/sightsImages/desanka/desanka3.jpg',
        'latitude': 44.270027255683395,
        'longitude': 19.884004638877375,
        'titles': {
          'en': 'Monument of Desanka Maksimović',
          'de': 'Denkmal von Desanka Maksimović',
          'sr': 'Spomenik Desanke Maksimović',
          'sr_Cyrl': 'Споменик Десанке Максимовић',
          'sr_Latn': 'Spomenik Desanke Maksimović',
        },
        'descriptions': {
          'en': 'Desanka Maksimovic description',
          'de': 'Desanka Maksimovic Beschreibung',
          'sr': 'Desanka Maksimovic opis',
          'sr_Cyrl': 'Десанка Максимовић опис',
          'sr_Latn': 'Desanka Maksimovic opis',
        },
      },
      // Muselimov konak
      {
        'sight_image_path':
            'images/sightsImages/muselimovKonak/muselimovKonak1.jpeg',
        'sight_image_path2':
            'images/sightsImages/muselimovKonak/muselimovKonak2.jpeg',
        'sight_image_path3':
            'images/sightsImages/muselimovKonak/muselimovKonak3.jpeg',
        'latitude': 44.26973928761971,
        'longitude': 19.88489479391643,
        'titles': {
          'en': 'Muselimov konak',
          'de': 'Muselimov konak',
          'sr': 'Muselimov konak',
          'sr_Cyrl': 'Муселимов конак',
          'sr_Latn': 'Muselimov konak',
        },
        'descriptions': {
          'en': 'Muselimov konak description',
          'de': 'Muselimov konak Beschreibung',
          'sr': 'Muselimov konak opis',
          'sr_Cyrl': 'Муселимов конак опис',
          'sr_Latn': 'Muselimov konak opis',
        },
      }
    ];

    await bulkInsertSightsData(dataList);
  }
}
