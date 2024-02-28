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
          'en': 'National Museum Valjevo',
          'de': 'Nationalmuseum Valjevo',
          'sr': 'Narodni muzej Valjevo',
          'sr_Cyrl': 'Народни музеј Ваљево',
          'sr_Latn': 'Narodni muzej Valjevo',
        },
        'descriptions': {
          'en':
              "Museum building began in 1869, with the purpose of being a primary school. Following the ending of the construction in 1870, the newly established Valjevo Grammar school was also situated in the building.\nDuring World War I, this building, like most public structures in the city, was used for the needs of the Valjevo Hospital where numerous foregin medical misionswere helping Serbian doctors in suppressing a large epidemic of typhus.\nIn the following decades, secondary schools of economics and technical education, as well as a primary school were all situated here. The building became the home of the National Museum of Valjevo in 1969. Currently, there are a permanent exhibition (The Third Dimension of the Past - a Look from the Future), a gallery for occasional themed exhibits and the museum club in the building. The National Museum represents a valuable architectural structure In Valjevo, which was among the first buldings that were designed under the infuence of the Western Architecture. As such, it is classified among the Cultural Monuments of Exceptional Importance.",
          'de':
              "Der Museumsbau begann 1869 mit dem Ziel, eine Grundschule zu errichten. Nach Abschluss der Bauarbeiten im Jahr 1870 wurde auch das neu gegründete Valjevo Gymnasium in dem Gebäude untergebracht.\nWährend des Ersten Weltkriegs wurde dieses Gebäude, wie die meisten öffentlichen Einrichtungen in der Stadt, für die Bedürfnisse des Valjevo Krankenhauses genutzt, wo zahlreiche ausländische medizinische Missionen serbischen Ärzten halfen, eine große Typhusepidemie einzudämmen.\nIn den folgenden Jahrzehnten waren hier eine Sekundarschule für Wirtschaft und technische Bildung sowie eine Grundschule untergebracht. Das Gebäude wurde 1969 zum Sitz des Nationalmuseums Valjevo. Derzeit gibt es dort eine Dauerausstellung (Die dritte Dimension der Vergangenheit - ein Blick aus der Zukunft), eine Galerie für gelegentliche thematische Ausstellungen und den Museumsclub.\nDas Nationalmuseum stellt ein wertvolles architektonisches Bauwerk in Valjevo dar, das zu den ersten Gebäuden gehörte, die unter dem Einfluss der westlichen Architektur entworfen wurden. Als solches ist es unter den Kulturdenkmälern von außergewöhnlicher Bedeutung eingestuft.",
          'sr':
              "Izgradnja sadašnje zgrade Narodnog muzeja započeta je 1869. godine za potrebe gradske osnovne škole. Po završetku gradnje 1870. godine u njoj je bila smeštena i novosnovana Valjevska gimnazija.\nTokom Prvog svetskog rata zgrada je, kao i većina javnih objekata u gradu, korišćena za potrebe Valjevske bolnice, gde su brojne inostrane sanitetske misije pomagale srpskim lekarima u suzbijanju velike epidemije tifusa.\nU narednim decenijama ovde su bile smeštene Ekonomska, Tehnička i osnovna škola. Zgrada je postala dom Narodnog muzeja Valjevo 1969. godine. Danas se u ovoj zgradi nalazi stalna postavka muzeja 'Treća dimenzija prošlosti - pogled iz budućnosti', galerija za povremene tematske izložbe, kao i muzejski klub.\nZgrada Narodnog muzeja predstavlja vredan arhitektonski objekat u Valjevu, koji je među prvim u ovom gradu bio sazidan pod uticajem zapadnoevropske arhitekture. Kao takav, svrstan je među spomenike kulture od velikog značaja.",
          'sr_Cyrl':
              "Изградња садашње зграде Народног музеја започета је 1869., године за потребе градске основне школе. Позавршетку градње 1870. године у њој је била смештена и новоснована Ваљевска гимназија.\nТoком Првог светског рата зградаје, као и већина јавних објеката у граду, коришћена за потребе Ваљевске болнице, где су бројне иностране санитетске мисије помагале српским лекарима у сузбијању велике епидемије тифуса.\nУ наредним деценијама овдесу биле смештене Економска, Техничка и основна школа. Зграда је постала дом Народног музеја Ваљево 1069. године. Данас се у овој згради налази стална поставка музеја 'Тређа димензија прошлости погледшва будућности' галерија за повремене тематске изложбе, као и музејски клуб. Зграда Народног музеја представља вредан архитектонски објекат у Ваљеву, који је међу првима у овом граду био сазидан под утицајем западноевропске архитектуре. Као такав, сврстан је међу споменике културе од великог значаја",
          'sr_Latn':
              "Izgradnja sadašnje zgrade Narodnog muzeja započeta je 1869. godine za potrebe gradske osnovne škole. Po završetku gradnje 1870. godine u njoj je bila smeštena i novosnovana Valjevska gimnazija.\nTokom Prvog svetskog rata zgrada je, kao i većina javnih objekata u gradu, korišćena za potrebe Valjevske bolnice, gde su brojne inostrane sanitetske misije pomagale srpskim lekarima u suzbijanju velike epidemije tifusa.\nU narednim decenijama ovde su bile smeštene Ekonomska, Tehnička i osnovna škola. Zgrada je postala dom Narodnog muzeja Valjevo 1969. godine. Danas se u ovoj zgradi nalazi stalna postavka muzeja 'Treća dimenzija prošlosti - pogled iz budućnosti', galerija za povremene tematske izložbe, kao i muzejski klub.\nZgrada Narodnog muzeja predstavlja vredan arhitektonski objekat u Valjevu, koji je među prvim u ovom gradu bio sazidan pod uticajem zapadnoevropske arhitekture. Kao takav, svrstan je među spomenike kulture od velikog značaja.",
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
