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
          history_sr_Latn,
          about_city_image_path
        )
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
          'images/backgroundAndCoverImages/oGraduCover.jpg',
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
          'en': 'Valjevo: Home of Refugees After the Battle of Kosovo',
          'de':
              'Valjevo: Zuflucht der Flüchtlinge nach der Schlacht auf dem Amselfeld',
          'sr': 'Valjevo: Dom izbeglica posle Kosovskog boja',
          'sr_Cyrl': 'Ваљево: Дом избеглица после Косовског боја',
          'sr_Latn': 'Valjevo: Dom izbeglica posle Kosovskog boja'
        },
        'legend_description': {
          'en':
              'Immediately after the Battle of Kosovo, a throng of Serbian refugees, fleeing from the Turkish invasion, collapsed into the valley of Valjevo, where they settled, exhausted from the long flight, and named the town Valjevo.',
          'de':
              'Unmittelbar nach der Schlacht auf dem Amselfeld ergoss sich ein Strom serbischer Flüchtlinge, die vor dem Einfall der Türken flohen, in das Tal von Valjevo, wo sie sich erschöpft von der langen Flucht niederließen und die Stadt Valjevo nannten.',
          'sr':
              'Neposredno posle Kosovskog boja zbeg srpskih izbeglica, bežeći ispred najezde Turaka svaljao se u valjevsku kotlinu, gde su se nastanili iznemogli od dugog bežanja, nazvali grad Valjevo.',
          'sr_Cyrl':
              'Непосредно после Косовског боја збег српских избеглица, бежећи испред најезде Турака свалио се у ваљевску котлину, где су се настанили изнемогли од дугог бежања, назвали град Ваљево.',
          'sr_Latn':
              'Neposredno posle Kosovskog boja zbeg srpskih izbeglica, bežeći ispred najezde Turaka svaljao se u valjevsku kotlinu, gde su se nastanili iznemogli od dugog bežanja, nazvali grad Valjevo.',
        },
      },
      {
        'legend_title': {
          'en': 'Valjevo: City of Fulling Mills',
          'de': 'Valjevo: Stadt der Walkmühlen',
          'sr': 'Valjevo: Grad valjarica',
          'sr_Cyrl': 'Ваљево: Град ваљарица',
          'sr_Latn': 'Valjevo: Grad valjarica'
        },
        'legend_description': {
          'en':
              'The city owes its name to the numerous fulling mills that were supposedly scattered along the banks of the Kolubara river in the past, where cloth was rolled day and night. A more complex version is that oxen brought wool to the fulling mills for rolling, and the finished cloth was taken away. The combination of the words for fulling mill ("valjarica") and ox ("vo") created the name Valjevo.',
          'de':
              'Die Stadt verdankt ihren Namen den zahlreichen Walkmühlen, die einst entlang der Ufer des Flusses Kolubara verstreut gewesen sein sollen, wo Tag und Nacht Stoff gewalkt wurde. Eine komplexere Version besagt, dass Ochsen Wolle zu den Walkmühlen zum Walken brachten und das fertige Tuch abtransportiert wurde. Die Kombination der Wörter für Walkmühle ("valjarica") und Ochse ("vo") ergab den Namen Valjevo.',
          'sr':
              'Grad svoje ime duguje brojnim valjaricama koje su u prošlosti, navodno, bile načičkane duže obale Kolubare i u kojima se danonoćno valjalo sukno. Složenija varijanta je, da su se volovima do valjarica dovlačila vuna za valjanje, a odvlačilo gotovo sukno. Kombinacijom reči valjarica i vo nastalo je Valjevo.',
          'sr_Cyrl':
              'Град своје име дугује бројним ваљарицама које су у прошлости, наводно, биле начичкане дуж обале Колубаре и у којима се даноноћно ваљало сукно. Сложенија варијанта је, да су се воловима до ваљарица довлачила вуна за ваљање, а одвлачило готово сукно. Комбинацијом речи ваљарица и во настало је Ваљево.',
          'sr_Latn':
              'Grad svoje ime duguje brojnim valjaricama koje su u prošlosti, navodno, bile načičkane duže obale Kolubare i u kojima se danonoćno valjalo sukno. Složenija varijanta je, da su se volovima do valjarica dovlačila vuna za valjanje, a odvlačilo gotovo sukno. Kombinacijom reči valjarica i vo nastalo je Valjevo.',
        },
      },
      {
        'legend_title': {
          'en': 'Valjevo: The city of cultivated land and people.',
          'de': 'Valjevo: Stadt des bearbeiteten Landes und der Menschen',
          'sr': 'Valjevo: Grad valjane zemlje i ljudi',
          'sr_Cyrl': 'Ваљево: Град ваљане земље и људи',
          'sr_Latn': 'Valjevo: Grad valjane zemlje i ljudi'
        },
        'legend_description': {
          'en':
              'Valjevo got its name from the rolled land in its surroundings and the worthy people who cultivate it.',
          'de':
              'Valjevo verdankt seinen Namen dem bearbeiteten Land in seiner Umgebung und den tüchtigen Menschen, die es bestellen.',
          'sr':
              'Valjevo je dobilo ime po valjanoj zemlji u svojoj okolini i valjanim ljudima koji je obrađuju.',
          'sr_Cyrl':
              'Ваљево је добило име по ваљаној земљи у својој околини и ваљаним људима који је обрађују.',
          'sr_Latn':
              'Valjevo je dobilo ime po valjanoj zemlji u svojoj okolini i valjanim ljudima koji je obrađuju.',
        },
      },
      {
        'legend_title': {
          'en': 'Philosophical Assumption of the City\'s Name',
          'de': 'Philosophische Annahme des Stadtnamens',
          'sr': 'Filozofska pretpostavka imena grada',
          'sr_Cyrl': 'Филозофска претпоставка имена града',
          'sr_Latn': 'Filozofska pretpostavka imena grada'
        },
        'legend_description': {
          'en':
              'Philosophical Assumption\nValjevo owes its name to the valley surrounded by hills in which it is located, because the Latin word "Vallis" denotes a valley.',
          'de':
              'Philosophische Annahme\nValjevo verdankt seinen Namen dem von Hügeln umgebenen Tal, in dem es liegt, denn das lateinische Wort "Vallis" bedeutet Tal.',
          'sr':
              'Filozofska pretpostavka\nValjevo svoje ime duguje dolini okruženoj brdima u kojoj je smešteno, jer latinska reč "Vallis" označava dolinu.',
          'sr_Cyrl':
              'Филозофска претпоставка\nВаљево своје име дугује долини окруженој брдима у којој је смештено, јер латинска реч "Vallis" означава долину.',
          'sr_Latn':
              'Filozofska pretpostavka\nValjevo svoje ime duguje dolini okruženoj brdima u kojoj je smešteno, jer latinska reč "Vallis" označava dolinu.',
        },
      },
    ];

    Map<String, dynamic> history = {
      'en':
          'The city of Valjevo, according to the sources explored so far, is first mentioned in the documents preserved in the historical archive of Dubrovnik from the year 1393. Archaeological findings confirm that in the 14th century, during the reign of King Stefan Dragutin over Mačva (which included the area of Valjevo), there was a settlement inhabited by Serbian Orthodox people in this area.\n\nValjevo is located at 44° and 16" of northern latitude and 19° and 53" of eastern longitude.\n\nPart of the city is situated in the valley, and another part is on the surrounding hills encircle this valley from the north, west, and south. From the east, the Valjevo basin is widely open along the valley of the Kolubara River. The Kolubara River divides the urban settlement into two parts. On the right bank are older structures than on the other (Tešnjar with a more significant number of houses from the 19th century). On the left bank is the urban core and the two oldest preserved buildings: Muselim\'s Residence, built at the end of the 18th century, and Nenadović Tower, erected at the beginning of the 19th century.',
      'de':
          'Die Stadt Valjevo wird laut den bisher erforschten Quellen erstmals in den im historischen Archiv von Dubrovnik aus dem Jahr 1393 aufbewahrten Dokumenten erwähnt. Archäologische Funde bestätigen, dass es im 14. Jahrhundert, während der Herrschaft von König Stefan Dragutin über Mačva (zu dem auch das Gebiet von Valjevo gehörte), eine von serbisch-orthodoxen Menschen bewohnte Siedlung in dieser Gegend gab.\n\nValjevo liegt auf 44° und 16" nördlicher Breite und 19° und 53" östlicher Länge.\n\nEin Teil der Stadt befindet sich im Tal, und ein anderer Teil liegt auf den umgebenden Hügeln, die dieses Tal von Norden, Westen und Süden umschließen. Von Osten her ist das Valjevo-Becken weit offen entlang des Tals des Flusses Kolubara. Der Fluss Kolubara teilt die städtische Siedlung in zwei Teile. Am rechten Ufer befinden sich ältere Strukturen als am anderen (Tešnjar mit einer größeren Anzahl von Häusern aus dem 19. Jahrhundert). Am linken Ufer befindet sich der städtische Kern und die zwei ältesten erhaltenen Gebäude: Muselims Residenz, erbaut am Ende des 18. Jahrhunderts, und der Nenadović-Turm, errichtet zu Beginn des 19. Jahrhunderts.',
      'sr':
          'Grad Valjevo, prema do sada istraženim izvorima, prvi put se pominje u spisima sačuvanim u istorijskom arhivu Dubrovnika, iz 1393 godine. Arheološki nalazi potvrđuju da se već u 14.veku, u vreme vladavine kralja Stefana Dragutina Mačvom (u koju je ulazilo i područje Valjeva), na ovom prostoru nalazilo naselje nastanjeno srpskim pravoslavnim življem.\n\n Valjevo se nalazi na 44° i 16" severne geografske širine i 19° i 53" istočne geografske dužine.\n\nGrad je jednim svojim delom smešten u dolini, a drugim delom na okolnim brdima koja ovu dolinu okružuju sa severa, zapada i juga. Sa istočne strane valjevska kotlina je širom otvorena dolinom reke Kolubare.  Reka Kolubara gradsko naselje  deli na dva dela. Na desnoj obali nalaze se objekti stariji nego na drugoj (Tešnjar sa većim brojem kuća iz 19. veka). Na levoj obali se nalazi urbanističko jezgro ali i dve najstarije sačuvane građevine: Muselimov konak, podignut krajem 18. veka i Kula Nenadović, podignuta početkom 19. veka.',
      'sr_Cyrl':
          'Град Ваљево, према до сада истраженим изворима, први пут се помиње у списима сачуваним у историјском архиву Дубровника, из 1393 године. Археолошки налази потврђују да се већ у 14. веку, у време владавине краља Стефана Драгутина Мачвом (у коју је улазило и подручје Ваљева), на овом простору налазило насеље настањено српским православним живљем.\n\nВаљево се налази на 44° и 16" северне географске ширине и 19° и 53" источне географске дужине.\n\nГрад је једним својим делом смештен у долини, а другим делом на околним брдима која ову долину окружују са севера, запада и југа. Са источне стране ваљевска котлина је широм отворена долином реке Колубаре. Река Колубара градско насеље дела на два дела. На десној обали налазе се објекти старији него на другој (Тешњар са већим бројем кућа из 19. века). На левој обали се налази урбанистичко језгро али и две најстарије сачуване грађевине: Муселимов конак, подигнут крајем 18. века и Кула Ненадовић, подигнута почетком 19. века.',
      'sr_Latn':
          'Grad Valjevo, prema do sada istraženim izvorima, prvi put se pominje u spisima sačuvanim u istorijskom arhivu Dubrovnika, iz 1393 godine. Arheološki nalazi potvrđuju da se već u 14.veku, u vreme vladavine kralja Stefana Dragutina Mačvom (u koju je ulazilo i područje Valjeva), na ovom prostoru nalazilo naselje nastanjeno srpskim pravoslavnim življem.\n\n Valjevo se nalazi na 44° i 16" severne geografske širine i 19° i 53" istočne geografske dužine.\n\nGrad je jednim svojim delom smešten u dolini, a drugim delom na okolnim brdima koja ovu dolinu okružuju sa severa, zapada i juga. Sa istočne strane valjevska kotlina je širom otvorena dolinom reke Kolubare.  Reka Kolubara gradsko naselje  deli na dva dela. Na desnoj obali nalaze se objekti stariji nego na drugoj (Tešnjar sa većim brojem kuća iz 19. veka). Na levoj obali se nalazi urbanističko jezgro ali i dve najstarije sačuvane građevine: Muselimov konak, podignut krajem 18. veka i Kula Nenadović, podignuta početkom 19. veka.',
    };

    await bulkInsertAboutCityData(aboutCityData, history);
  }
}
