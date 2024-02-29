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
            longitude,
            description_en, 
            description_de, 
            description_sr, 
            description_sr_Cyrl, 
            description_sr_Latn
          )
          VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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

  Future<void> parksDataInsertion() async {
    List<Map<String, dynamic>> dataList = [
      // Jadar (Park Vide Jocić)
      {
        'park_image_path': 'images/parksImages/jadar/jadar1.jpg',
        'park_image_path2': 'images/parksImages/jadar/jadar2.jpg',
        'park_image_path3': 'images/parksImages/jadar/jadar3.jpg',
        'titles': {
          'en': "Park Vide Jocić",
          'de': "Titel auf Deutsch",
          'sr': "Park Vide Jocić",
          'sr_Cyrl': "Парк Виде Јоцић",
          'sr_Latn': "Park Vide Jocić",
        },
        'latitude': 44.26955379468345,
        'longitude': 19.879072700675714,
        'description': {
          'en': 'Description in English',
          'de': 'Beschreibung auf Deutsch',
          'sr': 'Опис на српском',
          'sr_Cyrl': 'Опис на српском ћирилицом',
          'sr_Latn': 'Opis na srpskom latinicom',
        },
      },
      // Pećina
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
        'description': {
          'en': 'Description in English',
          'de': 'Beschreibung auf Deutsch',
          'sr': 'Опис на српском',
          'sr_Cyrl': 'Опис на српском ћирилицом',
          'sr_Latn': 'Opis na srpskom latinicom',
        },
      },
      // Peti Puk (Spomen park na Krušiku)
      {
        'park_image_path': 'images/parksImages/petiPuk/petiPuk1.jpg',
        'park_image_path2': 'images/parksImages/petiPuk/petiPuk2.jpg',
        'park_image_path3': 'images/parksImages/petiPuk/petiPuk3.jpg',
        'titles': {
          'en': "Memorial Park on Krušik",
          'de': "Gedenkpark auf Krušik",
          'sr': "Spomen park na Krušiku",
          'sr_Cyrl': "Спомен парк на Крушику",
          'sr_Latn': "Spomen park na Krušiku",
        },
        'latitude': 44.282386269219636,
        'longitude': 19.89021169469568,
        'description': {
          'en':
              "The partisan memorial cemetery is located on the hill of Krušik in the settlement \"Peti Puk\" next to the football stadium and sports centre.\n\nIt contains the graves of 313 fighters and participants of the People's Liberation Movement who militarily operated and lost their lives in the Valjevo region during the Second World War.\n\nThe most significant number of them, 261, were executed there on November 27, 1941.\n\nThe transformation into a memorial park was realized in 1956.\n\nIts present appearance was obtained through reconstruction in 1964, and just three years later, in 1967, a hearth with an \"eternal flame\" was built in the central part of the cemetery, which was lit on May 18, 1967, by the then president of the country, Josip Broz Tito.\n\nThe park contains monuments of stone and concrete on all three sides.\n\nAll of them have white marble plaques with dedications.\n\nAlong the paths are 67 memorial plaques made of sandstone with the names of the executed fighters.\n\nToday, it is a cultural monument, a memorial park used for the rest and recreation of the citizens of Valjevo.",
          'de':
              "Der Partisanen-Gedenkfriedhof befindet sich auf dem Hügel von Krušik in der Siedlung \"Peti Puk\" neben dem Fußballstadion und dem Sportzentrum.\n\nEr enthält die Gräber von 313 Kämpfern und Teilnehmern der Volksbefreiungsbewegung, die während des Zweiten Weltkriegs in der Region Valjevo militärisch tätig waren und ihr Leben verloren haben.\n\nDie größte Anzahl von ihnen, 261, wurden dort am 27. November 1941 hingerichtet.\n\nDie Umwandlung in einen Gedenkpark wurde 1956 realisiert.\n\nSein heutiges Aussehen wurde durch eine Rekonstruktion im Jahr 1964 erlangt, und nur drei Jahre später, im Jahr 1967, wurde in der zentralen Teil des Friedhofs ein Herd mit einer \"ewigen Flamme\" errichtet, die am 18. Mai 1967 vom damaligen Präsidenten des Landes, Josip Broz Tito, angezündet wurde.\n\nDer Park enthält Denkmäler aus Stein und Beton auf allen drei Seiten.\n\nAlle von ihnen haben weiße Marmorplaketten mit Widmungen.\n\nEntlang der Wege befinden sich 67 Gedenktafeln aus Sandstein mit den Namen der hingerichteten Kämpfer.\n\nHeute ist es ein Kulturdenkmal, ein Gedenkpark, der zur Erholung und Freizeitgestaltung der Bürger von Valjevo genutzt wird.",
          'sr':
              "Partizansko spomen groblje nalazi se na brdu Krušik u naselju \"Peti Puk\" pored fudbalskog stadiona i sportskog centra. Na njemu je sahranjeno 313 boraca i učesnika Narodno oslobodilačkog pokreta koji su vojno delovali i izgubili život na području valjevskog kraja za vreme Drugog svetskog rata. Najveći broj njih 261, su tu streljani 27 novembra 1941 godine. Pretvaranje u spomen park ostvareno je 1956 godine.\n\nDanašnji izgled je dobilo rekonstrukcijom 1964 god. a samo tri godine kasnije 1967 god. u središnjem delu groblja izgrađeno je ognjište sa \"večnim plamenom\" koji je 18.05.1967 god. upalio tadašnji predsednik države Josip Broz Tito.\n\nPark sadrži spomenike od kamena i betona sa sve tri pristupne strane. Na svima se nalaze bele mermerne spomen ploče sa posvetom. Duž staza postavljeno je 67 spomen ploča od peščara sa imenima streljanih boraca.\n\nDanas je to spomenik kulture, spomen park koji se koristi za odmor i rekreaciju građana Valjeva.",
          'sr_Cyrl':
              "Партизанско спомен гробље налази се на брду Крушик у насељу \"Пети Пук\" поред фудбалског стадиона и спортског центра. На њему је сахрањено 313 бораца и учесника Народно ослободилачког покрета који су војно деловали и изгубили живот на подручју ваљевског краја за време Другог светског рата. Највећи број њих 261, су ту стрељани 27 новембра 1941 године. Претварање у спомен парк остварено је 1956 године.\n\nДанашњи изглед је добило реконструкцијом 1964 год. а само три године касније 1967 год. у средишњем делу гробља изграђено је огњиште са \"вечним пламеном\" који је 18.05.1967 год. упалио тадашњи председник државе Јосип Броз Тито.\n\nПарк садржи споменике од камена и бетона са све три приступне стране. На свима се налазе беле мермерне спомен плоче са посветом. Дуж стаза постављено је 67 спомен плоча од пешчара са именима стрељаних бораца.\n\nДанас је то споменик културе, спомен парк који се користи за одмор и рекреацију грађана Ваљева.",
          'sr_Latn':
              "Partizansko spomen groblje nalazi se na brdu Krušik u naselju \"Peti Puk\" pored fudbalskog stadiona i sportskog centra. Na njemu je sahranjeno 313 boraca i učesnika Narodno oslobodilačkog pokreta koji su vojno delovali i izgubili život na području valjevskog kraja za vreme Drugog svetskog rata. Najveći broj njih 261, su tu streljani 27 novembra 1941 godine. Pretvaranje u spomen park ostvareno je 1956 godine.\n\nDanašnji izgled je dobilo rekonstrukcijom 1964 god. a samo tri godine kasnije 1967 god. u središnjem delu groblja izgrađeno je ognjište sa \"večnim plamenom\" koji je 18.05.1967 god. upalio tadašnji predsednik države Josip Broz Tito.\n\nPark sadrži spomenike od kamena i betona sa sve tri pristupne strane. Na svima se nalaze bele mermerne spomen ploče sa posvetom. Duž staza postavljeno je 67 spomen ploča od peščara sa imenima streljanih boraca.\n\nDanas je to spomenik kulture, spomen park koji se koristi za odmor i rekreaciju građana Valjeva.",
        },
      },
    ];
    await bulkInsertParksData(dataList);
  }
}
