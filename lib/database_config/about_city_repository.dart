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

  Future<void> bulkInsertAboutCityData(List<Map<String, dynamic>> aboutCityData,
      Map<String, dynamic> history) async {
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
          legend_description_sr_Latn,
          history_en,
          history_de,
          history_sr,
          history_sr_Cyrl,
          history_sr_Latn
        )
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
          data['legend_description']['sr_Latn'],
          history['en'],
          history['de'],
          history['sr'],
          history['sr_Cyrl'],
          history['sr_Latn'],
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
      {
        'legend_title': {
          'en': 'Legend 4',
          'de': 'Legende 4',
          'sr': 'Legenda 4',
          'sr_Cyrl': 'Легенда 4',
          'sr_Latn': 'Legenda 4'
        },
        'legend_description': {
          'en': 'Description 4',
          'de': 'Beschreibung 4',
          'sr': 'Opis 4',
          'sr_Cyrl': 'Опис 4',
          'sr_Latn': 'Opis 4'
        },
      },
    ];

    Map<String, dynamic> history = {
      'en':
          "The city of Valjevo, according to the sources explored so far, is first mentioned in the documents preserved in the historical archive of Dubrovnik from the year 1393. Archaeological findings confirm that in the 14th century, during the reign of King Stefan Dragutin over Mačva (which included the area of Valjevo), there was a settlement inhabited by Serbian Orthodox people in this area.\n\nValjevo is located at 44° and 16\" of northern latitude and 19° and 53\" of eastern longitude.\n\nPart of the city is situated in the valley, and another part is on the surrounding hills encircle this valley from the north, west, and south. From the east, the Valjevo basin is widely open along the valley of the Kolubara River. The Kolubara River divides the urban settlement into two parts. On the right bank are older structures than on the other (Tešnjar with a more significant number of houses from the 19th century). On the left bank is the urban core and the two oldest preserved buildings: Muselim's Residence, built at the end of the 18th century, and Nenadović Tower, erected at the beginning of the 19th century.",
      'de':
          "Die Stadt Valjevo wird laut den bisher erforschten Quellen erstmals in den im historischen Archiv von Dubrovnik aus dem Jahr 1393 aufbewahrten Dokumenten erwähnt. Archäologische Funde bestätigen, dass es im 14. Jahrhundert, während der Herrschaft von König Stefan Dragutin über Mačva (zu dem auch das Gebiet von Valjevo gehörte), eine von serbisch-orthodoxen Menschen bewohnte Siedlung in dieser Gegend gab.\n\nValjevo liegt auf 44° und 16\" nördlicher Breite und 19° und 53\" östlicher Länge.\n\nEin Teil der Stadt befindet sich im Tal, und ein anderer Teil liegt auf den umgebenden Hügeln, die dieses Tal von Norden, Westen und Süden umschließen. Von Osten her ist das Valjevo-Becken weit offen entlang des Tals des Flusses Kolubara. Der Fluss Kolubara teilt die städtische Siedlung in zwei Teile. Am rechten Ufer befinden sich ältere Strukturen als am anderen (Tešnjar mit einer größeren Anzahl von Häusern aus dem 19. Jahrhundert). Am linken Ufer befindet sich der städtische Kern und die zwei ältesten erhaltenen Gebäude: Muselims Residenz, erbaut am Ende des 18. Jahrhunderts, und der Nenadović-Turm, errichtet zu Beginn des 19. Jahrhunderts.",
      'sr':
          "Grad Valjevo, prema do sada istraženim izvorima, prvi put se pominje u spisima sačuvanim u istorijskom arhivu Dubrovnika, iz 1393 godine. Arheološki nalazi potvrđuju da se već u 14.veku, u vreme vladavine kralja Stefana Dragutina Mačvom (u koju je ulazilo i područje Valjeva), na ovom prostoru nalazilo naselje nastanjeno srpskim pravoslavnim življem.\n\n Valjevo se nalazi na 44° i 16\" severne geografske širine i 19° i 53\" istočne geografske dužine.\n\nGrad je jednim svojim delom smešten u dolini, a drugim delom na okolnim brdima koja ovu dolinu okružuju sa severa, zapada i juga. Sa istočne strane valjevska kotlina je širom otvorena dolinom reke Kolubare.  Reka Kolubara gradsko naselje  deli na dva dela. Na desnoj obali nalaze se objekti stariji nego na drugoj (Tešnjar sa većim brojem kuća iz 19. veka). Na levoj obali se nalazi urbanističko jezgro ali i dve najstarije sačuvane građevine: Muselimov konak, podignut krajem 18. veka i Kula Nenadović, podignuta početkom 19. veka.",
      'sr_Cyrl':
          "Град Ваљево, према до сада истраженим изворима, први пут се помиње у списима сачуваним у историјском архиву Дубровника, из 1393 године. Археолошки налази потврђују да се већ у 14. веку, у време владавине краља Стефана Драгутина Мачвом (у коју је улазило и подручје Ваљева), на овом простору налазило насеље настањено српским православним живљем.\n\nВаљево се налази на 44° и 16\" северне географске ширине и 19° и 53\" источне географске дужине.\n\nГрад је једним својим делом смештен у долини, а другим делом на околним брдима која ову долину окружују са севера, запада и југа. Са источне стране ваљевска котлина је широм отворена долином реке Колубаре. Река Колубара градско насеље дела на два дела. На десној обали налазе се објекти старији него на другој (Тешњар са већим бројем кућа из 19. века). На левој обали се налази урбанистичко језгро али и две најстарије сачуване грађевине: Муселимов конак, подигнут крајем 18. века и Кула Ненадовић, подигнута почетком 19. века.",
      'sr_Latn':
          "Grad Valjevo, prema do sada istraženim izvorima, prvi put se pominje u spisima sačuvanim u istorijskom arhivu Dubrovnika, iz 1393 godine. Arheološki nalazi potvrđuju da se već u 14.veku, u vreme vladavine kralja Stefana Dragutina Mačvom (u koju je ulazilo i područje Valjeva), na ovom prostoru nalazilo naselje nastanjeno srpskim pravoslavnim življem.\n\n Valjevo se nalazi na 44° i 16\" severne geografske širine i 19° i 53\" istočne geografske dužine.\n\nGrad je jednim svojim delom smešten u dolini, a drugim delom na okolnim brdima koja ovu dolinu okružuju sa severa, zapada i juga. Sa istočne strane valjevska kotlina je širom otvorena dolinom reke Kolubare.  Reka Kolubara gradsko naselje  deli na dva dela. Na desnoj obali nalaze se objekti stariji nego na drugoj (Tešnjar sa većim brojem kuća iz 19. veka). Na levoj obali se nalazi urbanističko jezgro ali i dve najstarije sačuvane građevine: Muselimov konak, podignut krajem 18. veka i Kula Nenadović, podignuta početkom 19. veka.",
    };

    await bulkInsertAboutCityData(aboutCityData, history);
  }
}
