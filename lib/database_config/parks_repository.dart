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
          'en': 'Vida Jocić Park (Park on the Jadar)',
          'de': 'Vida Jocić Park (Park am Jadar)',
          'sr': 'Park Vide Jocić (Park na Jadru)',
          'sr_Cyrl': 'Парк Виде Јоцић (Парк на Јадру)',
          'sr_Latn': 'Park Vide Jocić (Park na Jadru)',
        },
        'latitude': 44.26955379468345,
        'longitude': 19.879072700675714,
        'description': {
          'en':
              'It is dedicated to the sculptor Vida Jocić, whose sculptures are within its 1.2 hectares. The park was landscaped in 1892, and the 17th Infantry Regiment of the Royal Serbian Army carried out the work. Since 1925, the city has taken over its care. Since 1969, the park has been adorned with sculptures by Vida Jocić. In 1990, a monument to the national hero Dragojlo Dudić was relocated to the central part of the park. It was reconstructed in 2015, and after the floods of 2014, it represents an oasis of art and nature close to the city centre. The park features sculptures of the national hero Miloš Dunić, the national hero Žikica Jovanović Španac, activist Živan Đurđević, teacher and national hero Dara Pavlović, and student and secretary of the League of Communist Youth of Yugoslavia (SKOJ) for Valjevo, Milivoje Radosavljević.',
          'de':
              'Er ist der Bildhauerin Vida Jocić gewidmet, deren Skulpturen sich auf seinen 1,2 Hektar befinden. Der Park wurde 1892 angelegt, und die Arbeiten wurden vom 17. Infanterieregiment der Königlich Serbischen Armee durchgeführt. Seit 1925 hat die Stadt die Pflege übernommen. Seit 1969 wird der Park mit Skulpturen von Vida Jocić geschmückt. Im Jahr 1990 wurde ein Denkmal für den Nationalhelden Dragojlo Dudić in den zentralen Teil des Parks verlegt. Es wurde 2015 rekonstruiert und stellt nach den Überschwemmungen von 2014 eine Oase der Kunst und Natur nahe dem Stadtzentrum dar. Der Park beherbergt Skulpturen des Nationalhelden Miloš Dunić, des Nationalhelden Žikica Jovanović Španac, des Aktivisten Živan Đurđević, der Lehrerin und Nationalheldin Dara Pavlović und des Studenten und Sekretärs der Liga der Kommunistischen Jugend Jugoslawiens (SKOJ) für Valjevo, Milivoje Radosavljević.',
          'sr':
              'Posvećen vajarki Vidi Jocić čije se skulpture nalaze u njegovih 1,2 hektara površine. Park je uređen 1892. godine, a radove je izveo 17. pešadijski Puk vojske Kraljevine Srbije. Od 1925. godine grad je preuzeo brigu o njemu . Od 1969. godine park krase skulpture Vide Jocić. U centralni deo parka 1990. godine je premešten spomenik narodnom heroju Dragojlu Dudiću. Rekonstruisan je 2015. godine, a nakon poplava 2014. i predstavlja oazu umetnosti i prirode nadomak centra grada. U parku se nalaze skulpture  narodnog heroja Miloša Dunića , narodnog heroja Žikice Jovanovića Španca, aktiviste Živana Đurđevića, učiteljice i narodnog heroja Dare Pavlović i studenta i sekretara SKOJ-a za Valjevo Milivoja Radosavljevića.',
          'sr_Cyrl':
              'Посвећен вајарки Види Јоцић чије се скулптуре налазе у његових 1,2 хектара површине. Парк је уређен 1892. године, а радове је извео 17. пешадијски Пук војске Краљевине Србије. Од 1925. године град је преузео бригу о њему. Од 1969. године парк красе скулптуре Виде Јоцић. У централни део парка 1990. године је премештен споменик народном хероју Драгољу Дудићу. Реконструисан је 2015. године, а након поплава 2014. и представља оазу уметности и природе надомак центра града. У парку се налазе скулптуре народног хероја Милоша Дунића, народног хероја Жикице Јовановића Шпанца, активисте Живана Ђурђевића, учитељице и народног хероја Даре Павловић и студента и секретара СКОЈ-а за Ваљево Миливоја Радосављевића.',
          'sr_Latn':
              'Posvećen vajarki Vidi Jocić čije se skulpture nalaze u njegovih 1,2 hektara površine. Park je uređen 1892. godine, a radove je izveo 17. pešadijski Puk vojske Kraljevine Srbije. Od 1925. godine grad je preuzeo brigu o njemu . Od 1969. godine park krase skulpture Vide Jocić. U centralni deo parka 1990. godine je premešten spomenik narodnom heroju Dragojlu Dudiću. Rekonstruisan je 2015. godine, a nakon poplava 2014. i predstavlja oazu umetnosti i prirode nadomak centra grada. U parku se nalaze skulpture  narodnog heroja Miloša Dunića , narodnog heroja Žikice Jovanovića Španca, aktiviste Živana Đurđevića, učiteljice i narodnog heroja Dare Pavlović i studenta i sekretara SKOJ-a za Valjevo Milivoja Radosavljevića.',
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
          'en':
              'Pećina Park, located on the left bank of the Kolubara River, is one of the symbols of the city of Valjevo. It was named after a karst cave on the right bank of the river, discovered in 1974. The park is close to the city centre and consists of three parts: the first includes areas for sports activities - a tennis court, football stadium, and mini-golf course. The second segment comprises a fitness trail that is 682 meters long and one and a half meters wide and surrounds a children\'s park with numerous amenities for the youngest population. The third area encompasses grassy and forested parts with many different types of trees, especially lindens and conifers. This place is a favourite for rest and recreation among the people of Valjevo.',
          'de':
              'Der Pećina Park, gelegen am linken Ufer des Flusses Kolubara, ist eines der Symbole der Stadt Valjevo. Er wurde nach einer Karsthöhle auf dem rechten Flussufer benannt, die 1974 entdeckt wurde. Der Park liegt in unmittelbarer Nähe zum Stadtzentrum und besteht aus drei Teilen: Der erste umfasst Bereiche für sportliche Aktivitäten – einen Tennisplatz, ein Fußballstadion und eine Minigolfanlage. Der zweite Abschnitt besteht aus einem Fitnesspfad, der 682 Meter lang und eineinhalb Meter breit ist und einen Kinderspielplatz mit zahlreichen Einrichtungen für die jüngste Bevölkerung umgibt. Der dritte Bereich umfasst grasbewachsene und bewaldete Teile mit vielen verschiedenen Baumarten, insbesondere Linden und Nadelbäumen. Dieser Ort ist bei den Bewohnern Valjevos beliebt zum Ausruhen und für Freizeitaktivitäten.',
          'sr':
              'Park pećina je jedan od simbola grada Valjeva, smešten na levoj obali Kolubare. Dobio je ime po kraškoj pećini koja se nalazi na desnoj obali reke i otkrivena je 1974. godine. Park se nalazi u neposrednoj blizini centra grada i sastoji se od tri dela: prvi obuhvata terene za sportske aktivnosti - teniski teren, fudbalski stadion i teren za mini golf. Drugi segment čini trim staza dužine 682 metra i širine jedan i po metar, koja okružuje dečiji park sa brojnim sadržajima za najmlađu populaciju. Treća oblast obuhvata travnate i šumovite delove sa mnogo različitih vrsta drveća, naročito lipa i četinara. Ovo mesto je omiljeno za odmor i rekreaciju među Valjevcima.',
          'sr_Cyrl':
              'Парк пећина је један од симбола града Ваљева, смештен на левој обали Колубаре. Добио је име по крашкој пећини која се налази на десној обали реке и откривена је 1974. године. Парк се налази у непосредној близини центра града и састоји се од три дела: први обухвата терене за спортске активности - тениски терен, фудбалски стадион и терен за мини голф. Други сегмент чини трим стаза дужине 682 метра и ширине један и по метар, која окружује дечији парк са бројним садржајима за најмлађу популацију. Трећа област обухвата травнате и шумовите делове са много различитих врста дрвећа, нарочито липа и четинара. Ово место је омиљено за одмор и рекреацију међу Ваљевцима.',
          'sr_Latn':
              'Park pećina je jedan od simbola grada Valjeva, smešten na levoj obali Kolubare. Dobio je ime po kraškoj pećini koja se nalazi na desnoj obali reke i otkrivena je 1974. godine. Park se nalazi u neposrednoj blizini centra grada i sastoji se od tri dela: prvi obuhvata terene za sportske aktivnosti - teniski teren, fudbalski stadion i teren za mini golf. Drugi segment čini trim staza dužine 682 metra i širine jedan i po metar, koja okružuje dečiji park sa brojnim sadržajima za najmlađu populaciju. Treća oblast obuhvata travnate i šumovite delove sa mnogo različitih vrsta drveća, naročito lipa i četinara. Ovo mesto je omiljeno za odmor i rekreaciju među Valjevcima.',
        },
      },
      // Peti Puk (Spomen park na Krušiku)
      {
        'park_image_path': 'images/parksImages/petiPuk/petiPuk1.jpg',
        'park_image_path2': 'images/parksImages/petiPuk/petiPuk2.jpg',
        'park_image_path3': 'images/parksImages/petiPuk/petiPuk3.jpg',
        'titles': {
          'en': 'Memorial Park on Krušik',
          'de': 'Gedenkpark auf Krušik',
          'sr': 'Spomen park na Krušiku',
          'sr_Cyrl': 'Спомен парк на Крушику',
          'sr_Latn': 'Spomen park na Krušiku',
        },
        'latitude': 44.282386269219636,
        'longitude': 19.89021169469568,
        'description': {
          'en':
              'The partisan memorial cemetery is located on the hill of Krušik in the settlement "Peti Puk" next to the football stadium and sports centre.\n\nIt contains the graves of 313 fighters and participants of the People\'s Liberation Movement who militarily operated and lost their lives in the Valjevo region during the Second World War.\n\nThe most significant number of them, 261, were executed there on November 27, 1941.\n\nThe transformation into a memorial park was realized in 1956.\n\nIts present appearance was obtained through reconstruction in 1964, and just three years later, in 1967, a hearth with an "eternal flame" was built in the central part of the cemetery, which was lit on May 18, 1967, by the then president of the country, Josip Broz Tito.\n\nThe park contains monuments of stone and concrete on all three sides.\n\nAll of them have white marble plaques with dedications.\n\nAlong the paths are 67 memorial plaques made of sandstone with the names of the executed fighters.\n\nToday, it is a cultural monument, a memorial park used for the rest and recreation of the citizens of Valjevo.',
          'de':
              'Der Partisanen-Gedenkfriedhof befindet sich auf dem Hügel von Krušik in der Siedlung "Peti Puk" neben dem Fußballstadion und dem Sportzentrum.\n\nEr enthält die Gräber von 313 Kämpfern und Teilnehmern der Volksbefreiungsbewegung, die während des Zweiten Weltkriegs in der Region Valjevo militärisch tätig waren und ihr Leben verloren haben.\n\nDie größte Anzahl von ihnen, 261, wurden dort am 27. November 1941 hingerichtet.\n\nDie Umwandlung in einen Gedenkpark wurde 1956 realisiert.\n\nSein heutiges Aussehen wurde durch eine Rekonstruktion im Jahr 1964 erlangt, und nur drei Jahre später, im Jahr 1967, wurde in der zentralen Teil des Friedhofs ein Herd mit einer "ewigen Flamme" errichtet, die am 18. Mai 1967 vom damaligen Präsidenten des Landes, Josip Broz Tito, angezündet wurde.\n\nDer Park enthält Denkmäler aus Stein und Beton auf allen drei Seiten.\n\nAlle von ihnen haben weiße Marmorplaketten mit Widmungen.\n\nEntlang der Wege befinden sich 67 Gedenktafeln aus Sandstein mit den Namen der hingerichteten Kämpfer.\n\nHeute ist es ein Kulturdenkmal, ein Gedenkpark, der zur Erholung und Freizeitgestaltung der Bürger von Valjevo genutzt wird.',
          'sr':
              'Partizansko spomen groblje nalazi se na brdu Krušik u naselju "Peti Puk" pored fudbalskog stadiona i sportskog centra. Na njemu je sahranjeno 313 boraca i učesnika Narodno oslobodilačkog pokreta koji su vojno delovali i izgubili život na području valjevskog kraja za vreme Drugog svetskog rata. Najveći broj njih 261, su tu streljani 27 novembra 1941 godine. Pretvaranje u spomen park ostvareno je 1956 godine.\n\nDanašnji izgled je dobilo rekonstrukcijom 1964 god. a samo tri godine kasnije 1967 god. u središnjem delu groblja izgrađeno je ognjište sa "večnim plamenom" koji je 18.05.1967 god. upalio tadašnji predsednik države Josip Broz Tito.\n\nPark sadrži spomenike od kamena i betona sa sve tri pristupne strane. Na svima se nalaze bele mermerne spomen ploče sa posvetom. Duž staza postavljeno je 67 spomen ploča od peščara sa imenima streljanih boraca.\n\nDanas je to spomenik kulture, spomen park koji se koristi za odmor i rekreaciju građana Valjeva.',
          'sr_Cyrl':
              'Партизанско спомен гробље налази се на брду Крушик у насељу "Пети Пук" поред фудбалског стадиона и спортског центра. На њему је сахрањено 313 бораца и учесника Народно ослободилачког покрета који су војно деловали и изгубили живот на подручју ваљевског краја за време Другог светског рата. Највећи број њих 261, су ту стрељани 27 новембра 1941 године. Претварање у спомен парк остварено је 1956 године.\n\nДанашњи изглед је добило реконструкцијом 1964 год. а само три године касније 1967 год. у средишњем делу гробља изграђено је огњиште са "вечним пламеном" који је 18.05.1967 год. упалио тадашњи председник државе Јосип Броз Тито.\n\nПарк садржи споменике од камена и бетона са све три приступне стране. На свима се налазе беле мермерне спомен плоче са посветом. Дуж стаза постављено је 67 спомен плоча од пешчара са именима стрељаних бораца.\n\nДанас је то споменик културе, спомен парк који се користи за одмор и рекреацију грађана Ваљева.',
          'sr_Latn':
              'Partizansko spomen groblje nalazi se na brdu Krušik u naselju "Peti Puk" pored fudbalskog stadiona i sportskog centra. Na njemu je sahranjeno 313 boraca i učesnika Narodno oslobodilačkog pokreta koji su vojno delovali i izgubili život na području valjevskog kraja za vreme Drugog svetskog rata. Najveći broj njih 261, su tu streljani 27 novembra 1941 godine. Pretvaranje u spomen park ostvareno je 1956 godine.\n\nDanašnji izgled je dobilo rekonstrukcijom 1964 god. a samo tri godine kasnije 1967 god. u središnjem delu groblja izgrađeno je ognjište sa "večnim plamenom" koji je 18.05.1967 god. upalio tadašnji predsednik države Josip Broz Tito.\n\nPark sadrži spomenike od kamena i betona sa sve tri pristupne strane. Na svima se nalaze bele mermerne spomen ploče sa posvetom. Duž staza postavljeno je 67 spomen ploča od peščara sa imenima streljanih boraca.\n\nDanas je to spomenik kulture, spomen park koji se koristi za odmor i rekreaciju građana Valjeva.',
        },
      },
    ];
    await bulkInsertParksData(dataList);
  }
}
