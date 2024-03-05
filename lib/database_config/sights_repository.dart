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
        'sight_image_path': 'images/sightsImages/muzej/muzej1.jpeg',
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
              'Museum building began in 1869, with the purpose of being a primary school. Following the ending of the construction in 1870, the newly established Valjevo Grammar school was also situated in the building.\n\nDuring World War I, this building, like most public structures in the city, was used for the needs of the Valjevo Hospital where numerous foregin medical misionswere helping Serbian doctors in suppressing a large epidemic of typhus.\n\nIn the following decades, secondary schools of economics and technical education, as well as a primary school were all situated here. The building became the home of the National Museum of Valjevo in 1969. Currently, there are a permanent exhibition (The Third Dimension of the Past - a Look from the Future), a gallery for occasional themed exhibits and the museum club in the building. The National Museum represents a valuable architectural structure In Valjevo, which was among the first buldings that were designed under the infuence of the Western Architecture. As such, it is classified among the Cultural Monuments of Exceptional Importance.',
          'de':
              'Der Museumsbau begann 1869 mit dem Ziel, eine Grundschule zu errichten. Nach Abschluss der Bauarbeiten im Jahr 1870 wurde auch das neu gegründete Valjevo Gymnasium in dem Gebäude untergebracht.\n\nWährend des Ersten Weltkriegs wurde dieses Gebäude, wie die meisten öffentlichen Einrichtungen in der Stadt, für die Bedürfnisse des Valjevo Krankenhauses genutzt, wo zahlreiche ausländische medizinische Missionen serbischen Ärzten halfen, eine große Typhusepidemie einzudämmen.\n\nIn den folgenden Jahrzehnten waren hier eine Sekundarschule für Wirtschaft und technische Bildung sowie eine Grundschule untergebracht. Das Gebäude wurde 1969 zum Sitz des Nationalmuseums Valjevo. Derzeit gibt es dort eine Dauerausstellung (Die dritte Dimension der Vergangenheit - ein Blick aus der Zukunft), eine Galerie für gelegentliche thematische Ausstellungen und den Museumsclub.\n\nDas Nationalmuseum stellt ein wertvolles architektonisches Bauwerk in Valjevo dar, das zu den ersten Gebäuden gehörte, die unter dem Einfluss der westlichen Architektur entworfen wurden. Als solches ist es unter den Kulturdenkmälern von außergewöhnlicher Bedeutung eingestuft.',
          'sr':
              'Izgradnja sadašnje zgrade Narodnog muzeja započeta je 1869. godine za potrebe gradske osnovne škole. Po završetku gradnje 1870. godine u njoj je bila smeštena i novosnovana Valjevska gimnazija.\n\nTokom Prvog svetskog rata zgrada je, kao i većina javnih objekata u gradu, korišćena za potrebe Valjevske bolnice, gde su brojne inostrane sanitetske misije pomagale srpskim lekarima u suzbijanju velike epidemije tifusa.\n\nU narednim decenijama ovde su bile smeštene Ekonomska, Tehnička i osnovna škola. Zgrada je postala dom Narodnog muzeja Valjevo 1969. godine. Danas se u ovoj zgradi nalazi stalna postavka muzeja "Treća dimenzija prošlosti - pogled iz budućnosti", galerija za povremene tematske izložbe, kao i muzejski klub.\n\nZgrada Narodnog muzeja predstavlja vredan arhitektonski objekat u Valjevu, koji je među prvim u ovom gradu bio sazidan pod uticajem zapadnoevropske arhitekture. Kao takav, svrstan je među spomenike kulture od velikog značaja.',
          'sr_Cyrl':
              'Изградња садашње зграде Народног музеја започета је 1869., године за потребе градске основне школе. Позавршетку градње 1870. године у њој је била смештена и новоснована Ваљевска гимназија.\n\nТoком Првог светског рата зградаје, као и већина јавних објеката у граду, коришћена за потребе Ваљевске болнице, где су бројне иностране санитетске мисије помагале српским лекарима у сузбијању велике епидемије тифуса.\n\nУ наредним деценијама овдесу биле смештене Економска, Техничка и основна школа. Зграда је постала дом Народног музеја Ваљево 1069. године. Данас се у овој згради налази стална поставка музеја "Трећа димензија прошлости погледшва будућности" галерија за повремене тематске изложбе, као и музејски клуб. Зграда Народног музеја представља вредан архитектонски објекат у Ваљеву, који је међу првима у овом граду био сазидан под утицајем западноевропске архитектуре. Као такав, сврстан је међу споменике културе од великог значаја.',
          'sr_Latn':
              'Izgradnja sadašnje zgrade Narodnog muzeja započeta je 1869. godine za potrebe gradske osnovne škole. Po završetku gradnje 1870. godine u njoj je bila smeštena i novosnovana Valjevska gimnazija.\n\nTokom Prvog svetskog rata zgrada je, kao i većina javnih objekata u gradu, korišćena za potrebe Valjevske bolnice, gde su brojne inostrane sanitetske misije pomagale srpskim lekarima u suzbijanju velike epidemije tifusa.\n\nU narednim decenijama ovde su bile smeštene Ekonomska, Tehnička i osnovna škola. Zgrada je postala dom Narodnog muzeja Valjevo 1969. godine. Danas se u ovoj zgradi nalazi stalna postavka muzeja "Treća dimenzija prošlosti - pogled iz budućnosti", galerija za povremene tematske izložbe, kao i muzejski klub.\n\nZgrada Narodnog muzeja predstavlja vredan arhitektonski objekat u Valjevu, koji je među prvim u ovom gradu bio sazidan pod uticajem zapadnoevropske arhitekture. Kao takav, svrstan je među spomenike kulture od velikog značaja.',
        },
      },
      // Muselimov konak
      {
        'sight_image_path':
            'images/sightsImages/muselimovKonak/muselimovKonak1.jpg',
        'sight_image_path2':
            'images/sightsImages/muselimovKonak/muselimovKonak2.jpeg',
        'sight_image_path3':
            'images/sightsImages/muselimovKonak/muselimovKonak3.jpg',
        'latitude': 44.26973928761971,
        'longitude': 19.88489479391643,
        'titles': {
          'en': 'Muselim\'s Residence',
          'de': 'Muselims Residenz',
          'sr': 'Muselimov konak',
          'sr_Cyrl': 'Муселимов конак',
          'sr_Latn': 'Muselimov konak',
        },
        'descriptions': {
          'en':
              'The oldest preserved building in Valjevo, erected at the end of the 18th century to serve as a residence to Muselim, the Turkish governor of the Valjevo nahiyah.\n\nThe ground floor was used for governmental purposes, while in the basement there was a dungeon. It was due to these prison rooms that this building has become a well-known and significan memento of Serbian history.\n\nThe dungeon in the basement was the place where the prominent. knezes Aleksa Nenadović and lija Birčanin were detained in 1804. From there they were taken to the banks of Kolubara and executed. Their heads were impaled and highlighted on the residence roof.\nThis event is remembered in history as the Slaughter of the Knezes ("Knez") was a title: borne by local Serbian chiefs under the Ottoman Empire) and itis considered to-have been the direct cause of the First Serbian Uprising and the liberation of Serbia from the centuries-long Turkish rule. Although this action saw dozens of prominent Serbs being executed, Aleksa Nenadović and Ilija Birčanin have remained the main symbols of the Slaughter of the Knezes\n\nMuselim\'s Residence building has served as the National Museum of Valjevo since 1951.\nCurrently, there is a permanent exhibition in the basement - The Slaughter of the Knezes, and the exhibition on the ground floor-Valjevo Nahiyahin the First and the Second Serbian Uprising.',
          'de':
              'Das älteste erhaltene Gebäude in Valjevo wurde Ende des 18. Jahrhunderts errichtet, um als Residenz für Muselim, den türkischen Gouverneur der Nahiye Valjevo, zu dienen.\n\nDas Erdgeschoss wurde für Regierungszwecke genutzt, während im Keller ein Kerker war. Es waren diese Gefängnisräume, die dieses Gebäude zu einem bekannten und bedeutenden Denkmal der serbischen Geschichte gemacht haben.\n\nDer Kerker im Keller war der Ort, an dem die prominenten Kneze Aleksa Nenadović und Ilija Birčanin 1804 festgehalten wurden. Von dort wurden sie an die Ufer der Kolubara gebracht und hingerichtet. Ihre Köpfe wurden aufgespießt und auf dem Dach der Residenz zur Schau gestellt. Dieses Ereignis bleibt in der Geschichte als das Massaker an den Knezen in Erinnerung ("Knez") war ein Titel, der von lokalen serbischen Anführern unter dem Osmanischen Reich getragen wurde) und gilt als direkte Ursache des Ersten Serbischen Aufstands und der Befreiung Serbiens von der jahrhundertelangen türkischen Herrschaft. Obwohl bei dieser Aktion Dutzende prominente Serben hingerichtet wurden, sind Aleksa Nenadović und Ilija Birčanin die Hauptsymbole des Massakers an den Knezen geblieben.\n\nDas Gebäude der Muselims Residenz dient seit 1951 als Nationalmuseum von Valjevo. Derzeit gibt es im Keller eine Dauerausstellung - Das Massaker an den Knezen, und die Ausstellung im Erdgeschoss - Die Nahiye Valjevo während des Ersten und Zweiten Serbischen Aufstands.',
          'sr':
              'Najstarija sačuvana zgrada u Valjevu, podignuta krajem 18. veka za potrebe Muselima, turskog upravnika Valjevske nahije.\n\nPrizemlje objekta bilo je rezervisano za administrativne prostorije, dok se u podrumu nalazila tamnica. Upravo je po ovim zatvorskim prostorijama zgrada postala poznata i zaslužila značajno mesto u srpskoj istoriji.\n\nPodrumska apsana bila je mesto gde su početkom 1804. godine bili zatočeni istaknuti kneževi Valjevske nahije Aleksa Nenadović i Ilija Birčanin. Odavde su odvedeni na obalu Kolubare, gde su pogubljeni. Nakon ubijanja njihove glave nabijene su na kolac i istaknute na krovu konaka. Ovaj događaj ostao je zapamćen u istoriji kao Seča knezova i smatra se neposrednim povodom za izbijanje Prvog srpskog ustanka i oslobođenja Srbije od vekovne turske prevlasti. Premda je u ovoj akciji dahija širom Srbije pogubljeno više desetina viđenijih Srba, Aleksa Nenadović i Ilija Birčanin ostali su upamćeni kao glavni simboli Seče knezova.\n\nZgrada Muselimovog konaka se od 1951. koristi za potrebe Narodnog muzeja Valjevo. Danas se u podrumu nalazi stalna izložba "Seča knezova", a u prizemlju izložba "Valjevska nahija i Valjevci u Prvom i Drugom srpskom ustanku".',
          'sr_Cyrl':
              'Најстарија сачувана зграда у Ваљеву, подигнута крајем 18. века за потребе Муселима, турског управника Ваљевске нахије.\n\nПриземље објекта било је резервисано за административне просторије, док се у подруму налазила тамница. Управо је по овим затворским просторијима зграда постала позната и заслужила значајно место у српској историји\n\nПодрумска апсана била је место где су почетком 1804. године били заточени истакнути кнежеви Ваљевске нахије Алекса Ненадовић и Илија Бирчанин. Одавде су одведени на обалу Колубаре, где су погубљени. Након убијања њихове главе набијене су на колац и истакнуте на крову конака.\nОвај догађај остао је запамћен у историји као Сеча кнезова и сматра се непосредним поводом за избијање Првог српског устанка и ослобођења Србије од вековне турске превласти. Премда је у овој акцији дахија широм Србије погубљено више десетина виђенијих Срба, Алекса Ненадовић и Илија Бирчанин остали су упамћени као главни симболи Сече кнезова.\n\nЗграда Муселимовог конака се од 1951. користи за потребе Народног музеја Ваљево. Данас се у подруму налази стална изложба "Сеча кнезова", а у приземљу изложба "Ваљевска нахија и Ваљевци у Првом и Другом српском устанку".',
          'sr_Latn':
              'Najstarija sačuvana zgrada u Valjevu, podignuta krajem 18. veka za potrebe Muselima, turskog upravnika Valjevske nahije.\n\nPrizemlje objekta bilo je rezervisano za administrativne prostorije, dok se u podrumu nalazila tamnica. Upravo je po ovim zatvorskim prostorijama zgrada postala poznata i zaslužila značajno mesto u srpskoj istoriji.\n\nPodrumska apsana bila je mesto gde su početkom 1804. godine bili zatočeni istaknuti kneževi Valjevske nahije Aleksa Nenadović i Ilija Birčanin. Odavde su odvedeni na obalu Kolubare, gde su pogubljeni. Nakon ubijanja njihove glave nabijene su na kolac i istaknute na krovu konaka. Ovaj događaj ostao je zapamćen u istoriji kao Seča knezova i smatra se neposrednim povodom za izbijanje Prvog srpskog ustanka i oslobođenja Srbije od vekovne turske prevlasti. Premda je u ovoj akciji dahija širom Srbije pogubljeno više desetina viđenijih Srba, Aleksa Nenadović i Ilija Birčanin ostali su upamćeni kao glavni simboli Seče knezova.\n\nZgrada Muselimovog konaka se od 1951. koristi za potrebe Narodnog muzeja Valjevo. Danas se u podrumu nalazi stalna izložba "Seča knezova", a u prizemlju izložba "Valjevska nahija i Valjevci u Prvom i Drugom srpskom ustanku".',
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
          'en':
              'Nenadović Tower is one of the symbols of the town of Valjevo. It was built in the spring of 1813, before the end of the First Serbian Uprising, to reinforce surveillance over Valjevo and store military supplies. The chief initiators of the construction of the building were Jakov Nenadović and his son Jevrem. The stone from the pulled-down Vitkovic Tower, located at the confluence of the Gradac and Kolubara rivers, was used as a building material. At the end of 1813, the insurgents found a lot of tortured Serbs inside the Tower. Serbian Duke Sima Nenadović, revolted by the actions of the Turks, ordered the Tower to be burnt, but it was renovated in 1836 by Prince Milos Obrenović.\n\nToday, the Nenadović Tower is fully reconstructed and protected, with the appropriate museum exhibition, which has been open for visitors since 2012.',
          'de':
              'Der Nenadović-Turm ist eines der Symbole der Stadt Valjevo. Er wurde im Frühjahr 1813, vor dem Ende des Ersten Serbischen Aufstands, erbaut, um die Überwachung über Valjevo zu verstärken und militärische Vorräte zu lagern. Die Hauptinitiatoren des Baus waren Jakov Nenadović und sein Sohn Jevrem. Als Baumaterial wurde der Stein des abgerissenen Vitkovic-Turms verwendet, der am Zusammenfluss der Flüsse Gradac und Kolubara lag. Ende 1813 fanden die Aufständischen viele gefolterte Serben innerhalb des Turms. Der serbische Herzog Sima Nenadović, empört über die Handlungen der Türken, befahl, den Turm niederzubrennen, aber er wurde 1836 von Fürst Miloš Obrenović renoviert.\n\nHeute ist der Nenadović-Turm vollständig rekonstruiert und geschützt, mit der entsprechenden Museumsausstellung, die seit 2012 für Besucher geöffnet ist.',
          'sr':
              'Kula Nenadovića je jedan od simbola grada Valjeva. Sagrađena je u proleće 1813. godine, pred kraj Prvog srpskog ustanka, radi pojačanja nadzora nad Valjevom i skladištenja ratnog materijala. Glavni inicijatori izgradnje bili su vojvoda Jakov Nenadović i njegov sin Jevrem. Kao graditeljski mateijral, korišćen je kamen porušebe Vitkovića kule, koja se nekada nalazila kod ušća reke Gradac u Kolubaru. Krajem 1813. godine ustanici su morali da napuste Valjevo, a kulu preuzimaju Turci i pretvaraju je u tamnicu. Pri ponovnom oslobođenju Valjeva 1815. godine ustanici su zatekli Kulu punu izmučenih Srba. Srpski vojvoda Sima Nenadović, revoltiran postupkom Turaka, je naredio da se kula zapali, da bi je knjaz Miloš Obrenović obnovio 1836. godine.\n\nDanas je Kula Nenadovića u potpunosti rekonstruisana i zaštićena, sa pripremljenom adekvatnom muzejskom postavkom, koja je za posetioce otvorena od 2012. godine.',
          'sr_Cyrl':
              'Кула Ненадовића је један од симбола града Ваљева. Саграђена је у пролеће 1813. године, пред крај Првог српског устанка, ради појачања надзора над Ваљевом и складиштења ратног материјала. Главни иницијатори изградње били су војвода Јаков Ненадовић и његов син Јеврем. Као градитељски материјал, коришћен је камен порушене Витковића куле, која се некада налазила код ушћа реке Градац у Колубару. Крајем 1813. године устаници су морали да напусте Ваљево, а кулу преузимају Турци и претварају је у тамницу. При поновном ослобођењу Ваљева 1815. године устаници су затекли Кулу пуну измучених Срба. Српски војвода Сима Ненадовић, револтиран поступком Турака, је наредио да се кула запали, да би је кнез Милош Обреновић обновио 1836. године.\n\nДанас је Кула Ненадовића у потпуности реконструисана и заштићена, са припремљеном адекватном музејском поставком, која је за посетиоце отворена од 2012. године.',
          'sr_Latn':
              'Kula Nenadovića je jedan od simbola grada Valjeva. Sagrađena je u proleće 1813. godine, pred kraj Prvog srpskog ustanka, radi pojačanja nadzora nad Valjevom i skladištenja ratnog materijala. Glavni inicijatori izgradnje bili su vojvoda Jakov Nenadović i njegov sin Jevrem. Kao graditeljski mateijral, korišćen je kamen porušebe Vitkovića kule, koja se nekada nalazila kod ušća reke Gradac u Kolubaru. Krajem 1813. godine ustanici su morali da napuste Valjevo, a kulu preuzimaju Turci i pretvaraju je u tamnicu. Pri ponovnom oslobođenju Valjeva 1815. godine ustanici su zatekli Kulu punu izmučenih Srba. Srpski vojvoda Sima Nenadović, revoltiran postupkom Turaka, je naredio da se kula zapali, da bi je knjaz Miloš Obrenović obnovio 1836. godine.\n\nDanas je Kula Nenadovića u potpunosti rekonstruisana i zaštićena, sa pripremljenom adekvatnom muzejskom postavkom, koja je za posetioce otvorena od 2012. godine.',
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
          'en':
              'This is the only high school in Valjevo and it is located in the very center of the city on Vuka Karadžića street.\n\nIt was founded on November 23, 1870, as a two-year gymnasium real school with 43 students. The building it still uses today was built in 1906. During World War I, it did not function as a school and for a time, the famous Valjevo hospital was also located in it.\n\nThe high school, as an educational institution, resumed its work in March 1918 as an eight-grade complete and coeducational real gymnasium. In the mid-1940s, it was divided into two high schools that operated during World War II, but the First became a Boys\' High School in April and the second a Girls\' High School. After the liberation, they became coeducational again and operated separately until 1951. The following year, the Higher Mixed Real Gymnasium was opened, which operated above Tešnjar (so-called čaršija) on the right bank of the Kolubara River until 1966. From September of the same year, it returned to its old building, where it still operates today.\n\nToday, the high school contains a ceremonial hall with forty-six caryatids, a hundred seats, and is equipped with modern technology for interactive teaching. It also has a school library with over 22,000 inventory units in both Serbian and foreign languages. Some of the famous personalities who are former students of Valjevo High School include: theologian Nikolaj Velimirović, poet Desanka Maksimović, poet Matija Bećković, painter Ljubomir Popović, actor Voja Brajović.',
          'de':
              'Dies ist das einzige Gymnasium in Valjevo und befindet sich im Zentrum der Stadt in der Vuka Karadžića Straße.\n\nEs wurde am 23. November 1870 als zweijährige Realschule mit 43 Schülern gegründet. Das heute noch genutzte Gebäude wurde 1906 erbaut. Während des Ersten Weltkriegs diente es nicht als Schule, und zeitweise war auch das berühmte Valjevo-Krankenhaus darin untergebracht.\n\nDas Gymnasium nahm seine Tätigkeit im März 1918 als achtjähriges vollständiges und koedukatives Realgymnasium wieder auf. Mitte der 1940er Jahre wurde es in zwei Gymnasien aufgeteilt, die auch während des Zweiten Weltkriegs funktionierten, wobei das erste im April zum Jungen- und das zweite zum Mädchengymnasium wurde. Nach der Befreiung wurden sie wieder koedukativ und arbeiteten bis 1951 getrennt. Im folgenden Jahr wurde das Höhere Gemischte Realgymnasium eröffnet, das bis 1966 über Tešnjar (sogenannte Čaršija) am rechten Ufer der Kolubara arbeitete. Ab September desselben Jahres kehrte es in sein altes Gebäude zurück, in dem es heute noch arbeitet.\n\nHeute verfügt das Gymnasium über einen Festsaal mit sechsundvierzig Karyatiden, hundert Sitzen und ist mit moderner Technologie für interaktiven Unterricht ausgestattet. Es besitzt auch eine Schulbibliothek mit über 22.000 Inventareinheiten in serbischer sowie in Fremdsprachen. Einige der berühmten Persönlichkeiten, die ehemalige Schüler des Valjevo Gymnasiums sind, umfassen: Theologe Nikolaj Velimirović, Dichterin Desanka Maksimović, Dichter Matija Bećković, Maler Ljubomir Popović, Schauspieler Voja Brajović.',
          'sr':
              'To je jedina gimanzija u Valjevu  i nalazi se u samom centru grada  u ulici Vuka Karadžića.\n\nOsnovana je 23.11.1870 god. kao dvogodišnja gimnazijska realka sa 43 učenika. Zgrada koju i danas koristi  izgrađena je 1906 god. U toku prvog svetskog rata nije  radila kao škola a jedno vreme  je u njoj bila smeštena i čuvena Valjevska bolnica.\n\nGimnazija, kao škola, sa radom je ponovo počela u martu 1918 god. kao osmorazredna potpuna i mešovita realna gimnazija. Sredinom 1940 god. podeljena je na dve gimnazije koje su radile i tokom Drugog svetskog rata, ali je Prva u aprilu postala Muška a druga Ženska gimnazija. Po oslobođenju su ponovo postale mešovite i radile odvojeno do 1951god. Naredne godine je otvorena Viša mešovita realna gimnazija, koja je do 1966. godine radila iznad Tešnjara (takozvane čaršije) na desnoj obali Kolubare. Od septembra iste godine vratila se u svoju staru zgradu u kojoj i danas radi.\n\nGimnazija danas sadrži svečanu salu sa četrdeset šest karijatida, sto mesta i opremljena je savremenom tehnologijom za interaktivnu nastavu. Poseduje i školsku biblioteku sa preko 22 000 inventarnih jedinica kako na srpskom tako i na stranim jezicima. Samo neke od znamenitih ličnosti, koji su bivši učenici Valjevske gimnazije su: Nikolaj Velimirović teolog, Desanka Maksimović pesnikinja, Matija Bećković pesnik, Ljubomir Popović slikar, Voja Brajović glumac.',
          'sr_Cyrl':
              'То је једина гимназија у Ваљеву и налази се у самом центру града у улици Вука Караџића.\n\nОснована је 23.11.1870. год. као двогодишња гимназијска реалка са 43 ученика. Зграда коју и данас користи изграђена је 1906. год. У току првог светског рата није радила као школа а једно време је у њој била смештена и чувена Ваљевска болница.\n\nГимназија, као школа, са радом је поново почела у марту 1918. год. као осморазредна потпуна и мешовита реална гимназија. Средином 1940. год. подељена је на две гимназије које су радиле и током Другог светског рата, али је Прва у априлу постала Мушка а друга Женска гимназија. По ослобођењу су поново постале мешовите и радиле одвојено до 1951. год. Наредне године је отворена Виша мешовита реална гимназија, која је до 1966. године радила изнад Тешњара (такозване чаршије) на десној обали Колубаре. Од септембра исте године вратила се у своју стару зграду у којој и данас ради.\n\nГимназија данас садржи свечану салу са четрдесет шест каријатида, сто места и опремљена је савременом технологијом за интерактивну наставу. Поседује и школску библиотеку са преко 22 000 инвентарних јединица како на српском тако и на страним језицима. Само неке од знаменитих личности, који су бивши ученици Ваљевске гимназије су: Николај Велимировић теолог, Десанка Максимовић песникиња, Матија Бећковић песник, Љубомир Поповић сликар, Воја Брајовић глумац.',
          'sr_Latn':
              'To je jedina gimanzija u Valjevu  i nalazi se u samom centru grada  u ulici Vuka Karadžića.\n\nOsnovana je 23.11.1870 god. kao dvogodišnja gimnazijska realka sa 43 učenika. Zgrada koju i danas koristi  izgrađena je 1906 god. U toku prvog svetskog rata nije  radila kao škola a jedno vreme  je u njoj bila smeštena i čuvena Valjevska bolnica.\n\nGimnazija, kao škola, sa radom je ponovo počela u martu 1918 god. kao osmorazredna potpuna i mešovita realna gimnazija. Sredinom 1940 god. podeljena je na dve gimnazije koje su radile i tokom Drugog svetskog rata, ali je Prva u aprilu postala Muška a druga Ženska gimnazija. Po oslobođenju su ponovo postale mešovite i radile odvojeno do 1951god. Naredne godine je otvorena Viša mešovita realna gimnazija, koja je do 1966. godine radila iznad Tešnjara (takozvane čaršije) na desnoj obali Kolubare. Od septembra iste godine vratila se u svoju staru zgradu u kojoj i danas radi.\n\nGimnazija danas sadrži svečanu salu sa četrdeset šest karijatida, sto mesta i opremljena je savremenom tehnologijom za interaktivnu nastavu. Poseduje i školsku biblioteku sa preko 22 000 inventarnih jedinica kako na srpskom tako i na stranim jezicima. Samo neke od znamenitih ličnosti, koji su bivši učenici Valjevske gimnazije su: Nikolaj Velimirović teolog, Desanka Maksimović pesnikinja, Matija Bećković pesnik, Ljubomir Popović slikar, Voja Brajović glumac.',
        },
      },
      // Saborna crkva Vaskrsenja Gospodnjeg
      {
        'sight_image_path': 'images/sightsImages/hram/hram1.jpg',
        'sight_image_path2': 'images/sightsImages/hram/hram2.jpg',
        'sight_image_path3': 'images/sightsImages/hram/hram3.jpg',
        'latitude': 44.274172769846494,
        'longitude': 19.889581685484366,
        'titles': {
          'en': 'Church of the Resurrection of the Christ',
          'de': 'Kirche der Auferstehung Christi',
          'sr': 'Saborna crkva Vaskrsenja Gospodnjeg',
          'sr_Cyrl': 'Саборна црква Васкрсења Господњег',
          'sr_Latn': 'Saborna crkva Vaskrsenja Gospodnjeg',
        },
        'descriptions': {
          'en':
              'The largest Orthodox temple in Valjevo. The Church of Resurrection of Christ is the principal Church of the Valjevo Eparchy of the Serbian Orthodox Church, which can fit more than 2,000 followers; this makes it one of the more significant places of worship in the Orthodox world.\n\nThe construction of the Church of Resurrection of Christ began in 1992 under the project of Ljubica Bošnjak, an architect from Belgrade; the temple was designed in Serbo-Byzantine style and was built at the Gradac River mouth; the Church of Resurrection is 46 meters long and 24 meters wide, while its height is 42 meters. These impressive measures make this religious building, the second largest one in Serbia, following the Church of St. Sava.\n\nOver the last few years, the works on the exterior of the Church have been completed, but the interior is yet to be finished.',
          'de':
              'Der größte orthodoxe Tempel in Valjevo. Die Kirche der Auferstehung Christi ist die Hauptkirche der Eparchie Valjevo der serbisch-orthodoxen Kirche, die mehr als 2.000 Gläubige fassen kann; dies macht sie zu einem der bedeutenderen Orte der Anbetung in der orthodoxen Welt.\n\nDer Bau der Kirche der Auferstehung Christi begann 1992 unter dem Projekt von Ljubica Bošnjak, einer Architektin aus Belgrad; der Tempel wurde im serbisch-byzantinischen Stil entworfen und an der Mündung des Flusses Gradac erbaut; die Kirche der Auferstehung ist 46 Meter lang und 24 Meter breit, während ihre Höhe 42 Meter beträgt. Diese beeindruckenden Maße machen dieses religiöse Gebäude zur zweitgrößten Kirche in Serbien, nach der Kirche des Heiligen Sava.\n\nIn den letzten Jahren wurden die Arbeiten am Äußeren der Kirche abgeschlossen, das Innere muss jedoch noch fertiggestellt werden.',
          'sr':
              'Najveći pravoslavni hram u Valjevu. Saborna crkva Vaskrsenja Gospodnjeg je središnja crkva Valjevske eparhije Srpske pravoslavne crkve, pod čiji krov može istovremeno da stane više od 2,000 vernika, što je čini jednom od većih bogomolja u čitavom pravoslavnom svetu.\n\nIzgradnja Sabornе crkve Vaskrsenja Gospodnjeg započeta je 1992. godine, prema projektu arhitekte Ljubice Bošnjak iz Beograda. Hram je projektovan srpsko-vizantijskom stilu i smešten je na ušću reke Gradac u Kolubaru.\n\nSaborna crkva Vaskrsenja Gospodnjeg dužine je 46, širine 24, dok je njena visina 42 metra, Impozantne dimenzije stavljaju ovaj verski objekat na drugo mesto po veličini u Srbiji. Veći je samo Hram Svetog Save u Beogradu. Tokom poslednjih godina završeni su radovi na eksterijeru hrama, ali njegova unutrašnjost još uvek nije završena.',
          'sr_Cyrl':
              'Највећи православни храм у Ваљеву. Саборна црква Васкрсења Господњег је средишња црква Ваљевске епархије Српске православне цркве, под чији кров може истовремено да стане више од 2,000 верника, што је чини једном од већих богомоља у читавом православном свету.\n\nИзградња Саборне цркве Васкрсења Господњег започета је 1992. године, према пројекту архитекте Љубице Бошњак из Београда. Храм је пројектован српско-византијском стилу и смештен је на ушћу реке Градац у Колубару.\n\nСаборна црква Васкрсења Господњег дужине је 16, ширине 24, док је њена висина 47 метара, Импозантне димензије стављају овај верски објекат на друго место по величини у Србији. Већи је само Храм Светог Саве у Београду. Током последњих година завршени су радови на екстеријеру храма, али његова унутрашњост још увек није завршена.',
          'sr_Latn':
              'Najveći pravoslavni hram u Valjevu. Saborna crkva Vaskrsenja Gospodnjeg je središnja crkva Valjevske eparhije Srpske pravoslavne crkve, pod čiji krov može istovremeno da stane više od 2,000 vernika, što je čini jednom od većih bogomolja u čitavom pravoslavnom svetu.\n\nIzgradnja Sabornе crkve Vaskrsenja Gospodnjeg započeta je 1992. godine, prema projektu arhitekte Ljubice Bošnjak iz Beograda. Hram je projektovan srpsko-vizantijskom stilu i smešten je na ušću reke Gradac u Kolubaru.\n\nSaborna crkva Vaskrsenja Gospodnjeg dužine je 46, širine 24, dok je njena visina 42 metra, Impozantne dimenzije stavljaju ovaj verski objekat na drugo mesto po veličini u Srbiji. Veći je samo Hram Svetog Save u Beogradu. Tokom poslednjih godina završeni su radovi na eksterijeru hrama, ali njegova unutrašnjost još uvek nije završena.',
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
          'en': '"Marko\'s Chair',
          'de': 'Markos Stuhl',
          'sr': 'Markova Stolica',
          'sr_Cyrl': 'Маркова Столица',
          'sr_Latn': 'Markova Stolica',
        },
        'descriptions': {
          'en':
              'The lookout point on Vidrak hill above the city, where the most beautiful view of Valjevo and its surroundings can be seen, is known as "Marko\'s Chair". \n\nThe place was named after the Serbian hero from the Middle Ages, Marko Kraljević. According to legend, Marko sat down to rest at the top of Vidrak hill, and his feet were in the Kolubara River. Hence, this small plateau, arranged for relaxation and walking, is called "Marko\'s Chair". The appearance of this place viewed from the air resembles a chair with a backrest.',
          'de':
              'Der Aussichtspunkt auf dem Vidrak-Hügel über der Stadt, von dem aus man den schönsten Blick auf Valjevo und seine Umgebung hat, ist als "Markos Stuhl" bekannt.\n\nDer Ort wurde nach dem serbischen Helden des Mittelalters, Marko Kraljević, benannt. Der Legende nach setzte sich Marko zum Ausruhen auf den Gipfel des Vidrak-Hügels, und seine Füße waren im Fluss Kolubara. Daher wird dieses kleine Plateau, das zum Entspannen und Spazieren eingerichtet ist, "Markos Stuhl" genannt. Das Aussehen dieses Ortes aus der Luft betrachtet ähnelt einem Stuhl mit einer Rückenlehne.',
          'sr':
              'Vidikovac na brdu Vidrak iznad grada, sa koga se pruža najlepši pogled na grad Valjevo i okolinu poznat je kao "Markova stolica".\n\nMesto je dobilo ime po srpskom junaku iz srednjeg veka, Marku Kraljeviću. Po legendi, Marko je seo da se odmori na vrhu brda Vidrak a stopala su mu bila u reci Kolubari. Otuda se ova mala zaravan, uređena za odmor i šetnju, naziva "Markova stolica". Izgled ovog mesta posmatran iz vazduha zaista podseća na stolicu sa naslonom.',
          'sr_Cyrl':
              'Видиковац на брду Видрак изнад града, са кога се пружа најлепши поглед на град Ваљево и околину познат је као "Маркова столица".\n\nМесто је добило име по српском јунаку из средњег века, Марку Краљевићу. По легенди, Марко је сео да се одмори на врху брда Видрак а стопала су му била у реци Колубари. Отуда се ова мала зараван, уређена за одмор и шетњу, назива "Маркова столица". Изглед овог места посматран из ваздуха заиста подсећа на столицу са наслоном.',
          'sr_Latn':
              'Vidikovac na brdu Vidrak iznad grada, sa koga se pruža najlepši pogled na grad Valjevo i okolinu poznat je kao "Markova stolica".\n\nMesto je dobilo ime po srpskom junaku iz srednjeg veka, Marku Kraljeviću. Po legendi, Marko je seo da se odmori na vrhu brda Vidrak a stopala su mu bila u reci Kolubari. Otuda se ova mala zaravan, uređena za odmor i šetnju, naziva "Markova stolica". Izgled ovog mesta posmatran iz vazduha zaista podseća na stolicu sa naslonom.',
        },
      },
      // Stevan Filipović
      {
        'sight_image_path': 'images/sightsImages/stevan/stevan1.jpg',
        'sight_image_path2': 'images/sightsImages/stevan/stevan2.jpg',
        'sight_image_path3': 'images/sightsImages/stevan/stevan3.jpg',
        'latitude': 44.276073,
        'longitude': 19.891073,
        'titles': {
          'en':
              'Monument to the Fighters of the Revolution (monument to Stevan Filipović)',
          'de':
              'Denkmal für die Kämpfer der Revolution (Denkmal für Stevan Filipović)',
          'sr': 'Spomenik borcima Revolucije (spomenik Stevanu Filipoviću)',
          'sr_Cyrl':
              'Споменик борцима Револуције (споменик Стевану Филиповићу)',
          'sr_Latn':
              'Spomenik borcima Revolucije (spomenik Stevanu Filipoviću)',
        },
        'descriptions': {
          'en':
              'The monument is located at the central part of the plateau on Vidrak hill, which rises above Valjevo, dominating its size, so it is visible from the city itself. It is dedicated to the eponymous national hero and the partisan fighters of the Valjevo region.\n\nStjepan Steva Filipović was born in 1916 in Opuzen, near Metković. He grew up in Mostar, where he finished elementary school and two grades of high school, and then he learned the electrician and locksmith trade in Kragujevac. Since 1940, he was a member of the illegal Communist Party of Yugoslavia. In 1941, he was sent to Valjevo on a party mission. As a loyal patriot and a good fighter, he was appointed the Kolubara battalion commander. He was also the political commissar of the Drina Partisan Detachment and then the commander of the Tamnava-Kolubara battalion. After the destruction of the same in battles, Steva was captured at the end of December 1941. Refusing to cooperate with the occupier, after torture and mistreatment in the Gestapo prison in Belgrade, he was sentenced to death by hanging. He was hanged on May 22, 1942, in the centre of Valjevo at the age of 26. On the gallows, with his arms raised high and fists clenched, he shouted anti-fascist slogans. He was proclaimed a national hero on December 14, 1949.\n\nThe Monument to the Revolution Fighters was erected in 1960 by sculptor Vojin Bakić and represents Steva Filipović just before the hanging.',
          'de':
              'Das Denkmal befindet sich im zentralen Teil des Plateaus auf dem Hügel Vidrak, der sich über Valjevo erhebt und aufgrund seiner Größe schon aus der Stadt selbst sichtbar ist. Es ist dem gleichnamigen Nationalhelden und den Partisanenkämpfern der Region Valjevo gewidmet.\n\nStjepan Steva Filipović wurde 1916 in Opuzen, in der Nähe von Metković, geboren. Er wuchs in Mostar auf, wo er die Grundschule und zwei Klassen des Gymnasiums absolvierte, und erlernte dann in Kragujevac den Beruf des Elektrikers und Schlossers. Seit 1940 war er Mitglied der illegalen Kommunistischen Partei Jugoslawiens. 1941 wurde er im Rahmen einer Parteimission nach Valjevo entsandt. Als treuer Patriot und guter Kämpfer wurde er zum Kommandeur des Kolubara-Bataillons ernannt. Er war auch politischer Kommissar des Drina-Partisanendetachements und später Kommandeur des Tamnava-Kolubara-Bataillons. Nach der Zerstörung desselben in den Kämpfen wurde Steva Ende Dezember 1941 gefangen genommen. Weil er die Zusammenarbeit mit den Besatzern ablehnte, wurde er nach Folter und Misshandlung im Gestapo-Gefängnis in Belgrad zum Tode durch Hängen verurteilt. Er wurde am 22. Mai 1942 im Zentrum von Valjevo im Alter von 26 Jahren gehängt. Auf dem Galgen rief er mit erhobenen Armen und geballten Fäusten antifaschistische Slogans. Am 14. Dezember 1949 wurde er zum Nationalhelden erklärt.\n\nDas Denkmal für die Kämpfer der Revolution wurde 1960 vom Bildhauer Vojin Bakić errichtet und stellt Steva Filipović unmittelbar vor der Hinrichtung dar.',
          'sr':
              'Spomenik je smešten na centralnom mestu platoa na brdu Vidrak, koje se uzdiže iznad Valjeva, dominira svojoj veličinom, tako da je vidljiv iz samog grada. Posvećen je istoimenom narodnom heroju i partizanskim borcima valjevskog kraja.\n\nStjepan Steva Filipović rođen 1916. u Opuzenu, kod Metkovića. Odrastao u Mostaru gde je završio osnovnu školu i dva razreda gimnazije a potom je u Kragujevcu učio električarski i bravarski zanat. Od 1940-e je član ilegalne Komunističke partije Jugoslavije. Od 1941-e po partijskom zadatku je bio upućen u Valjevo. Kao verni patriota i dobar borac postavljen je za komandanta Kolubarskog bataljona. Bio je i politički komesar Podrinjskog partizanskog odreda, a zatim i komandant Tamnavsko-Kolubarskog bataljona. Nakon uništenja istog u borbama, Steva je zarobljen krajem decembra 1941. godine. Odbijanjem saradnje sa okupatorom, nakon mučenje i zlostavljanja u zatvoru Gestapoa u Beogradu, osuđen je na smrt vešanjem. Obešen je 22. maja 1942. god. u centru Valjeva u 26-oj godini života. Na vešalima je sa uzdignutim rukama uvis i stisnutim pesnicama uzvikivao antifašističke parole. Proglašen je narodnim herojem 14. decembra 1949. godine.\n\nSpomenik borcima Revolucije je podignut 1960. godine, delo je vajara Vojina Bakića i predstavlja Stevu Filipovića neposredno pred vešanje.',
          'sr_Cyrl':
              'Споменик је смештен на централном месту платоа на брду Видрак, које се уздиже изнад Ваљева, доминира својом величином, тако да је видљив из самог града. Посвећен је истоименом народном хероју и партизанским борцима ваљевског краја.\n\nСтефан Стева Филиповић рођен 1916. у Опузену, код Метковића. Одрастао у Мостару где је завршио основну школу и два разреда гимназије а потом је у Крагујевцу учио електричарски и браварски занат. Од 1940-е је члан илегалне Комунистичке партије Југославије. Од 1941-е по партијском задатку је био упућен у Ваљево. Као верни патриота и добар борац постављен је за команданта Колубарског батаљона. Био је и политички комесар Подрињског партизанског одреда, а затим и командант Тамнавско-Колубарског батаљона. Након уништења истог у борбама, Стева је заробљен крајем децембра 1941. године. Одбијањем сарадње са окупатором, након мучења и злостављања у затвору Гестапоа у Београду, осуђен је на смрт вешањем. Обешен је 22. маја 1942. год. у центру Ваљева у 26-ој години живота. На вешалима је са уздигнутим рукама увис и стиснутим песницама узвикивао антифашистичке пароле. Проглашен је народним херојем 14. децембра 1949. године.\n\nСпоменик борцима Револуције је подигнут 1960. године, дело је вајара Војина Бакића и представља Стеву Филиповића непосредно пред вешање.',
          'sr_Latn':
              'Spomenik je smešten na centralnom mestu platoa na brdu Vidrak, koje se uzdiže iznad Valjeva, dominira svojoj veličinom, tako da je vidljiv iz samog grada. Posvećen je istoimenom narodnom heroju i partizanskim borcima valjevskog kraja.\n\nStjepan Steva Filipović rođen 1916. u Opuzenu, kod Metkovića. Odrastao u Mostaru gde je završio osnovnu školu i dva razreda gimnazije a potom je u Kragujevcu učio električarski i bravarski zanat. Od 1940-e je član ilegalne Komunističke partije Jugoslavije. Od 1941-e po partijskom zadatku je bio upućen u Valjevo. Kao verni patriota i dobar borac postavljen je za komandanta Kolubarskog bataljona. Bio je i politički komesar Podrinjskog partizanskog odreda, a zatim i komandant Tamnavsko-Kolubarskog bataljona. Nakon uništenja istog u borbama, Steva je zarobljen krajem decembra 1941. godine. Odbijanjem saradnje sa okupatorom, nakon mučenje i zlostavljanja u zatvoru Gestapoa u Beogradu, osuđen je na smrt vešanjem. Obešen je 22. maja 1942. god. u centru Valjeva u 26-oj godini života. Na vešalima je sa uzdignutim rukama uvis i stisnutim pesnicama uzvikivao antifašističke parole. Proglašen je narodnim herojem 14. decembra 1949. godine.\n\nSpomenik borcima Revolucije je podignut 1960. godine, delo je vajara Vojina Bakića i predstavlja Stevu Filipovića neposredno pred vešanje.',
        },
      },
      // Tešnjar
      {
        'sight_image_path': 'images/sightsImages/tesnjar/tesnjar1.jpg',
        'sight_image_path2': 'images/sightsImages/tesnjar/tesnjar2.jpg',
        'sight_image_path3': 'images/sightsImages/tesnjar/tesnjar3.jpg',
        'latitude': 44.29062866176497,
        'longitude': 19.876563654330376,
        'titles': {
          'en': 'Tešnjar (Turkish town on the right bank of the Kolubara)',
          'de': 'Tešnjar (Türkisches Viertel am rechten Ufer der Kolubara)',
          'sr': 'Tešnjar (Turska kasaba na desnoj obali Kolubare)',
          'sr_Cyrl': 'Тешњар (Турска касаба на десној обали Колубаре)',
          'sr_Latn': 'Tešnjar (Turska kasaba na desnoj obali Kolubare)',
        },
        'descriptions': {
          'en':
              'It has one street that follows the course of the Kolubara River and several smaller steep streets that descend the hill towards it. It contained shops, craft workshops, and commercial warehouses, so Tešnjar represented the commercial craft quarter of Valjevo, the marketplace. Most houses were built in the 19th century, but the existing style was respected. It retained its purpose for centuries until the mid-20th century, when it lost that function. The last decades of the 20th century began the process of restoration and conservation, which continues to this day.\n\nToday, Tešnjar is a tourist attraction. Scenes for many movies were filmed there. For example, "Zona Zamfirova", "The Hat of Professor Kosta Vujić", "The Notebook of Professor Mišković" and "Toma"...',
          'de':
              'Es hat eine Straße, die dem Verlauf des Flusses Kolubara folgt, und mehrere kleinere steile Straßen, die den Hügel hinabführen. Es beherbergte Geschäfte, Handwerksbetriebe und Handelslager, daher repräsentierte Tešnjar das Handels- und Handwerksviertel von Valjevo, den Marktplatz. Die meisten Häuser wurden im 19. Jahrhundert erbaut, aber der vorhandene Stil wurde respektiert. Es behielt seinen Zweck über Jahrhunderte bei, bis es Mitte des 20. Jahrhunderts diese Funktion verlor. Die letzten Jahrzehnte des 20. Jahrhunderts begannen den Prozess der Restaurierung und Konservierung, der bis heute andauert.\n\nHeute ist Tešnjar eine Touristenattraktion. Dort wurden Szenen für viele Filme gedreht. Zum Beispiel "Zona Zamfirova", "Der Hut des Professor Kosta Vujić", "Das Notizbuch des Professor Mišković" und "Toma"...',
          'sr':
              'Ima jednu ulicu koja prati tok reke Kolubare i nekoliko manjih strmih uličica koje se niz brdo spuštaju ka njoj. U njoj su se nalazile prodavnice, zanatske radionice, trgovački magacini zbog čega je Tešnjar predstavljao trgovinsko-zanatsku četvrt Valjeva ,čaršiju. Veći deo kuća je nastao u 19.veku ali se poštovao zatečeni stil. Svoju namenu zadržavao je vekovima, tačnije do polovine 20. veka,kada gubi tu svoju namenu. Poslednjih decenija 20. veka započeo je proces restauracije i konzervacije koji i danas traje.\n\nDanas je Tešnjar turistička atrakcija. Tu su snimane scene za mnoge filmove. Npr. "Zona Zamfirova", "Šešir profesora Koste Vujića", "Beležnica profesora Miškovića", "Toma"...',
          'sr_Cyrl':
              'Има једну улицу која прати ток реке Колубаре и неколико мањих стрмих уличица које се низ брдо спуштају ка њој. У њој су се налазиле продавнице, занатске радионице, трговачки магацини због чега је Тешњар представљао трговинско-занатску четврт Ваљева, чаршију. Већи део кућа је настао у 19. веку али се поштовао затечени стил. Своју намену задржавао је вековима, тачније до половине 20. века, када губи ту своју намену. Последњих деценија 20. века започео је процес рестаурације и конзервације који и данас траје.\n\nДанас је Тешњар туристичка атракција. Ту су снимане сцене за многе филмове. Нпр. "Зона Замфирова", "Шешир професора Косте Вујића", "Бележница професора Мишковића", "Тома"...',
          'sr_Latn':
              'Ima jednu ulicu koja prati tok reke Kolubare i nekoliko manjih strmih uličica koje se niz brdo spuštaju ka njoj. U njoj su se nalazile prodavnice, zanatske radionice, trgovački magacini zbog čega je Tešnjar predstavljao trgovinsko-zanatsku četvrt Valjeva ,čaršiju. Veći deo kuća je nastao u 19.veku ali se poštovao zatečeni stil. Svoju namenu zadržavao je vekovima, tačnije do polovine 20. veka,kada gubi tu svoju namenu. Poslednjih decenija 20. veka započeo je proces restauracije i konzervacije koji i danas traje.\n\nDanas je Tešnjar turistička atrakcija. Tu su snimane scene za mnoge filmove. Npr. "Zona Zamfirova", "Šešir profesora Koste Vujića", "Beležnica profesora Miškovića", "Toma"...',
        },
      },
      // Živojin Misić
      {
        'sight_image_path': 'images/sightsImages/zivojin/zivojin1.jpg',
        'sight_image_path2': 'images/sightsImages/zivojin/zivojin2.jpg',
        'sight_image_path3': 'images/sightsImages/zivojin/zivojin3.jpg',
        'latitude': 44.29052905178508,
        'longitude': 19.884803402764618,
        'titles': {
          'en': 'Živojin Mišić Square',
          'de': 'Živojin Mišić-Platz',
          'sr': 'Trg Živojina Mišića',
          'sr_Cyrl': 'Трг Живојина Мишића',
          'sr_Latn': 'Trg Živojina Mišića',
        },
        'descriptions': {
          'en':
              'In the very centre of the city, close to the White Bridge on the Kolubara River, there is a life-size statue of Živojin Mišić on its left bank. Along with the round grassy hillock on which it is set and the surrounding pedestrian zone, it forms the favourite square of the children of Valjevo.\n\nŽivojin Mišić was the most successful Serbian commander in the First World War. He was born in 1855 in the village of Struganik near Mionica and died in 1921 in Belgrade. He participated in all the military conflicts Serbia was involved in from 1877 to 1918. In December 1914, under his command, the Serbian army defeated the Austro-Hungarian Empire in the famous Battle of Kolubara, whose manoeuvres are still studied in military schools today. In honour of that victory, he was awarded the title of Duke. During the breakthrough of the Thessaloniki Front, he was the Chief of the Supreme Command, and until the end of the war, his troops demonstrated excellent performance several times. After the war, he participated in creating the Kingdom of Serbs, Croats, and Slovenes and was the Chief of the General Staff of the Kingdom\'s army. The state protects Duke Mišić\'s house in the village of Struganik as a cultural monument, and since 1987, it has been a museum.',
          'de':
              'Im Zentrum der Stadt, in der Nähe der Weißen Brücke am Fluss Kolubara, befindet sich auf dessen linker Seite eine lebensgroße Statue von Živojin Mišić. Zusammen mit dem runden, grasbewachsenen Hügel, auf dem sie steht, und der umliegenden Fußgängerzone bildet sie den Lieblingsplatz der Kinder von Valjevo.\n\nŽivojin Mišić war der erfolgreichste serbische Kommandant im Ersten Weltkrieg. Er wurde 1855 im Dorf Struganik bei Mionica geboren und starb 1921 in Belgrad. Er nahm an allen militärischen Konflikten teil, in die Serbien von 1877 bis 1918 verwickelt war. Im Dezember 1914 besiegte die serbische Armee unter seinem Kommando in der berühmten Schlacht von Kolubara das österreichisch-ungarische Kaiserreich, deren Manöver noch heute in Militärschulen studiert werden. Zu Ehren dieses Sieges wurde ihm der Titel eines Herzogs verliehen. Während des Durchbruchs der Thessaloniki-Front war er der Chef des Oberkommandos, und bis zum Ende des Krieges zeigten seine Truppen mehrmals hervorragende Leistungen. Nach dem Krieg beteiligte er sich an der Gründung des Königreichs der Serben, Kroaten und Slowenen und war der Chef des Generalstabs der Armee des Königreichs. Das Haus des Herzogs Mišić im Dorf Struganik steht unter dem Schutz des Staates als Kulturdenkmal und beherbergt seit 1987 ein Museum.',
          'sr':
              'U samom centru grada, u neposrednoj blizini Belog mosta na reci Kolubari, na njenoj levoj obali, nalazi se statua Živojina Mišića prirodne veličine. Zajedno sa okruglim travnatim uzvišenjem na kojem je postavljena i okolnom pešačkom zonom, čini omiljeni trg valjevskih mališana.\n\nŽivojin Mišić bio je najuspešniji srpski vojskovođa u Prvom svetskom ratu. Rođen je 1855. godine u selu Struganik kod Mionice i umro 1921. godine u Beogradu. Učestvovao je u svim ratnim sukobima u koje je Srbija bila upletena od 1877. do 1918. godine. U decembru 1914. godine, pod njegovom komandom, srpska vojska porazila je Austro-Ugarsku u čuvenoj Kolubarskoj bici, čiji se manevar i danas izučava na vojnim školama. U čast toj pobedi, dodeljena mu je titula vojvode. Tokom proboja Solunskog fronta bio je načelnik Vrhovne komande, a do kraja rata njegove trupe su se nekoliko puta odlično pokazale. Nakon rata, učestvovao je u stvaranju Kraljevine Srba, Hrvata i Slovenaca i bio je načelnik Generalštaba vojske Kraljevine. Kuća vojvode Mišića u selu Struganik, pod zaštitom je države kao spomenik kulture i od 1987. godine u njoj se nalazi muzej.',
          'sr_Cyrl':
              'У самом центру града, у непосредној близини Белог моста на реци Колубари, на њеној левој обали, налази се статуа Живојина Мишића природне величине. Заједно са округлим травнатим узвишењем на којем је постављена и околном пешачком зоном, чини омиљени трг ваљевских малишана.\n\nЖивојин Мишић био је најуспешнији српски војсковођа у Првом светском рату. Рођен је 1855. године у селу Струганик код Мионице и умро 1921. године у Београду. Учествовао је у свим ратним сукобима у које је Србија била уплетена од 1877. до 1918. године. У децембру 1914. године, под његовом командом, српска војска поразила је Аустро-Угарску у чувеној Колубарској бици, чији се маневар и данас изучава на војним школама. У част тој победи, додељена му је титула војводе. Током пробоја Солунског фронта био је начелник Врховне команде, а до краја рата његове трупе су се неколико пута одлично показале. Након рата, учествовао је у стварању Краљевине Срба, Хрвата и Словенаца и био је начелник Генералштаба војске Краљевине. Кућа војводе Мишића у селу Струганик, под заштитом је државе као споменик културе и од 1987. године у њој се налази музеј.',
          'sr_Latn':
              'U samom centru grada, u neposrednoj blizini Belog mosta na reci Kolubari, na njenoj levoj obali, nalazi se statua Živojina Mišića prirodne veličine. Zajedno sa okruglim travnatim uzvišenjem na kojem je postavljena i okolnom pešačkom zonom, čini omiljeni trg valjevskih mališana.\n\nŽivojin Mišić bio je najuspešniji srpski vojskovođa u Prvom svetskom ratu. Rođen je 1855. godine u selu Struganik kod Mionice i umro 1921. godine u Beogradu. Učestvovao je u svim ratnim sukobima u koje je Srbija bila upletena od 1877. do 1918. godine. U decembru 1914. godine, pod njegovom komandom, srpska vojska porazila je Austro-Ugarsku u čuvenoj Kolubarskoj bici, čiji se manevar i danas izučava na vojnim školama. U čast toj pobedi, dodeljena mu je titula vojvode. Tokom proboja Solunskog fronta bio je načelnik Vrhovne komande, a do kraja rata njegove trupe su se nekoliko puta odlično pokazale. Nakon rata, učestvovao je u stvaranju Kraljevine Srba, Hrvata i Slovenaca i bio je načelnik Generalštaba vojske Kraljevine. Kuća vojvode Mišića u selu Struganik, pod zaštitom je države kao spomenik kulture i od 1987. godine u njoj se nalazi muzej.',
        },
      },
      // Vuk Karadžić
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
          'en':
              'Vuk Stefanović Karadžić was born in the village of Tršić, near Loznica, in 1787. He is considered the greatest reformer of the Serbian language and spelling and the biggest collector of folk tales, poems and riddles in Serbian folklore. On top of that, he was the author of the first Serbian dictionary. He died in Vienna in February 1864.\n\nOn November 5, 1987, to mark the two hundredth birth anniversary of the founder of the modern Serbian language, a monument to Vuk Stefanović Karadžić was ceremonially unveiled at a newly formed square by the old railway station in Valjevo.In addition to a street with his name, Vuk received this massive monument in his honour that should correspond to the importance of his work.\n\nThe designer of the monument is Nikola Kolja Milunović, an academic sculptor from Belgrade. The monument to Vuk Stefanovic Karadžić is 7 metres high and made of Belovode sandstone.',
          'de':
              'Vuk Stefanović Karadžić wurde 1787 im Dorf Tršić in der Nähe von Loznica geboren. Er gilt als der größte Reformer der serbischen Sprache und Orthographie und als der größte Sammler von Volkserzählungen, Gedichten und Rätseln in der serbischen Folklore. Darüber hinaus war er der Autor des ersten serbischen Wörterbuchs. Er starb im Februar 1864 in Wien.\n\nAm 5. November 1987 wurde anlässlich des zweihundertsten Geburtstags des Begründers der modernen serbischen Sprache feierlich ein Denkmal für Vuk Stefanović Karadžić auf einem neu angelegten Platz bei der alten Bahnhofsstation in Valjevo enthüllt. Neben einer Straße mit seinem Namen erhielt Vuk dieses massive Denkmal zu seinen Ehren, das der Bedeutung seines Werks entsprechen sollte.\n\nDer Gestalter des Denkmals ist Nikola Kolja Milunović, ein akademischer Bildhauer aus Belgrad. Das Denkmal für Vuk Stefanović Karadžić ist 7 Meter hoch und aus Belovoder Sandstein gefertigt.',
          'sr':
              'Vuk Stefanović Karadžić rođen je 1787. godine u selu Tršiću, nedaleko od Loznice. Smatra se najvećim reformatorom srpskog jezika i pravopisa, kao i najvećim sakupljačem narodnih umotvorina. Autor je prvog rečnika srpskog jezika. Umro je februara 1864. godine u Beču.\n\nPovodom dvestote godišnjice rođenja utemeljivača srpskog jezika, u Valjevu je 5. novembra 1987. svečano otkriven spomenik Vuku Stefanoviću Karadžiću na tada novoformiranom trgu kod stare železničke stanice. Pored ulice sa njegovim imenom, Vuk je u Valjevu dobio monumentalni spomenik koji bi trebalo da odgovara važnosti njegovog dela.\n\nAutor spomenika je Nikola Kolja Milunović, akademski vajar iz Beograda. Spomenik je visok 7 metara i izrađen je od belovodskog peščara.',
          'sr_Cyrl':
              'Вук Стефановић Караџић рођен је 1787. године у селу Тршићу, недалеко од Лознице. Сматра се највећим реформатором српског језиика и правописа, као и највећим сакупљачем народних умотворина. Аутор је првог речника српског језика. Умро је фебруара 1864. године у Бечу.\n\nПоводом двестоте годишњице рођења утемељивача српског језика, у Ваљеву је 5. новембра 1987. свечано откривен споменик Вуку Стефановићу Караџићу на тада ноформираном тргу код старе железничке станице. Поред улице са његовим именом, Вук је у Ваљеву добио монументалан споменик који би требало да одговара важности његовог дела.\n\nАутор споменика је Никола Коља Милуновић, академски вајар из Београда. Споменик је висок 7 метара и израђен је од беловодског пешчара.',
          'sr_Latn':
              'Vuk Stefanović Karadžić rođen je 1787. godine u selu Tršiću, nedaleko od Loznice. Smatra se najvećim reformatorom srpskog jezika i pravopisa, kao i najvećim sakupljačem narodnih umotvorina. Autor je prvog rečnika srpskog jezika. Umro je februara 1864. godine u Beču.\n\nPovodom dvestote godišnjice rođenja utemeljivača srpskog jezika, u Valjevu je 5. novembra 1987. svečano otkriven spomenik Vuku Stefanoviću Karadžiću na tada novoformiranom trgu kod stare železničke stanice. Pored ulice sa njegovim imenom, Vuk je u Valjevu dobio monumentalni spomenik koji bi trebalo da odgovara važnosti njegovog dela.\n\nAutor spomenika je Nikola Kolja Milunović, akademski vajar iz Beograda. Spomenik je visok 7 metara i izrađen je od belovodskog peščara.',
        },
      },
      // Desanka Maksimović
      {
        'sight_image_path': 'images/sightsImages/desanka/desanka1.jpg',
        'sight_image_path2': 'images/sightsImages/desanka/desanka2.jpg',
        'sight_image_path3': 'images/sightsImages/desanka/desanka3.jpg',
        'latitude': 44.270027255683395,
        'longitude': 19.884004638877375,
        'titles': {
          'en': 'Square Desanka Maksimović',
          'de': 'Platz Desanka Maksimović',
          'sr': 'Trg Desanke Maksimović',
          'sr_Cyrl': 'Трг Десанке Максимовић',
          'sr_Latn': 'Trg Desanke Maksimović',
        },
        'descriptions': {
          'en':
              'Desanka Maksimović, a poet, a professor of literature and an academic, was born in 1898 in the village of Rabrovica near Valjevo. Shortly after her birth, her family moved to Brankovina.\n\nShe is considered to be one of the most prominent Serbian poets. Desanka Maksimović died in Belgrade in 1993 and was buried in Brankovina. Following her death, the Foundation of Desanka Maksimović was established, as well as a poetry award bearing her name.\n\nPeople from Valjevo wanted to repay the renowned poet; on October 27, 1990, a ceremonial unveiling of a monument dedicated to Desanka Maksimović. Due to her slight disapproval on account of being given too great an honour, it was decided that the memorial, as well as the square of which it was a part, would be dedicated to poetry and not directly to her life and works. Nevertheless, today, among the people from Valjevo, this area is better known as Desanka\'s Square, with the Desankas monument at its entrance. The main word, in honour of the monument unveiling, was given to a distinguished Serbian writer and academic, Matija Becković. \n\nThe memorial is the work of Aleksandar Zarin, an academic sculptor and a professor, and it was carved by an academic sculptor, Milija Glisić. The area around the monument was designed by Predrag Kojić, an architect, and the works were carried out by Jablanica Construction Company.',
          'de':
              'Desanka Maksimović, Dichterin, Literaturprofessorin und Akademikerin, wurde 1898 im Dorf Rabrovica bei Valjevo geboren. Kurz nach ihrer Geburt zog ihre Familie nach Brankovina.\n\nSie gilt als eine der bedeutendsten serbischen Dichterinnen. Desanka Maksimović starb 1993 in Belgrad und wurde in Brankovina beigesetzt. Nach ihrem Tod wurde die Stiftung Desanka Maksimović gegründet, sowie ein nach ihr benannter Lyrikpreis.\n\nDie Menschen aus Valjevo wollten der renommierten Dichterin etwas zurückgeben; am 27. Oktober 1990 wurde feierlich ein Denkmal zu Ehren von Desanka Maksimović enthüllt. Aufgrund ihrer leichten Missbilligung, eine zu große Ehre zu erhalten, wurde beschlossen, dass das Denkmal sowie der Platz, zu dem es gehört, der Lyrik gewidmet sein sollten und nicht direkt ihrem Leben und Werk. Dennoch ist dieser Bereich heute unter den Menschen aus Valjevo besser bekannt als Desankas Platz, mit dem Desankas Denkmal am Eingang. Das Hauptwort zur Ehre der Enthüllung des Denkmals wurde dem namhaften serbischen Schriftsteller und Akademiker Matija Bećković gegeben.\n\nDas Denkmal ist das Werk von Aleksandar Zarin, einem akademischen Bildhauer und Professor, und wurde von dem akademischen Bildhauer Milija Glišić geschnitzt. Die Umgebung des Denkmals wurde von Predrag Kojić, einem Architekten, entworfen und die Arbeiten wurden vom Bauunternehmen Jablanica durchgeführt.',
          'sr':
              'Desanka Maksimović, pesnikinja, profesorka književnosti i akademik, rođena je 1898. u selu Rabrovici, kod Valjeva, ali se brzo po njenom rođenju porodica preselila u Brankovinu.\n\nSmatra se jednom od najvećih srpskih pesnikinja. Preminula je 1993. godine u Beogradu, a sahranjena je u Brankovini. Odmah nakon njene smrti osnovana je Zadužbina Desanka Maksimović i ustanovljena pesnička nagrada s imenom poznate pesnikinje, čiji kontinuitet dodeljivanja i dalje traje.\n\nSlavnoj pesnikinji Valjevci su želeli da se oduže još za njenog života. Tako je 27. oktobra 1990. svečano otkriven spomenik Desanki Maksimović. Zbog malog negodovanja pesnikinje što joj se odaje velika čast, odlučeno je da spomenik, kao i trg na kojem se nalazi budu posvećeni pesništvu, a ne direktno njenom liku i delu. Ipak, danas je ovaj prostor među Valjevcima poznatiji kao Desankin trg sa Desankinim spomenikom u njegovom centralnom delu. Glavnu besedu u čast otvaranja spomenika održao je književnik i akademik Matija Bećković, koji nikad nije krio ljubav prema gradu na Kolubari.\n\nSpomenik je delo akademskog vajara i profesora Aleksandra Zarina, a isklesao ga je akademski vajar Milija Glišić. Plato oko spomenika projektovao je arhitekta Predrag Kojić, a radove je izvodilo Građevinsko preduzeće "Jablanica".',
          'sr_Cyrl':
              'Десанка Максимовић, песникиња, професорка књижевности и академик, рођена јe 1898. селу Рабровици, код Ваљева, али cе брзо по њеном рођењу породица преселила у Бранковину. \n\nСматра се једном од највећих српских песникиња. Преминула је 1993.године у Београду, а сахрањена је у Бранковини. Одмах након њене смрти основана је Задужбина Десанка Максимовић и установљена песничка награда с именом познате песникиње, чији континуитет додељивања и даље траје.\n\nСлавној песникињи Ваљевци су желели да се одуже још за њеног живота. Тако је 27.⁠ ⁠октобра 1990. свечано откривен споменик Десанки Максимовић. Због малог негодовања песникиње што јој се одаје. велика част, одлучено је да споменик, као и трг на којем се налази буду посвећени песништву, а не директно њеном лику и делу. Ипак, данас је овај простор међу Ваљевцима познатији као Десанкин трг са Десанкиним спомеником у његовом централном делу. Главну беседу у част отварања споменика одржао је књижевник и академик Матија Бећковић, који никад није крио љубав према граду на Колубари.\n\nСпоменик је дело академског вајара и професора Александра Зарина, а исклесао га је академски вајар Милија Глишић. Плато око у споменика пројектовао је архитекта Предраг Којић, а радове је изводило Грађевинско предузеће "Јабланица".',
          'sr_Latn':
              'Desanka Maksimović, pesnikinja, profesorka književnosti i akademik, rođena je 1898. u selu Rabrovici, kod Valjeva, ali se brzo po njenom rođenju porodica preselila u Brankovinu.\n\nSmatra se jednom od najvećih srpskih pesnikinja. Preminula je 1993. godine u Beogradu, a sahranjena je u Brankovini. Odmah nakon njene smrti osnovana je Zadužbina Desanka Maksimović i ustanovljena pesnička nagrada s imenom poznate pesnikinje, čiji kontinuitet dodeljivanja i dalje traje.\n\nSlavnoj pesnikinji Valjevci su želeli da se oduže još za njenog života. Tako je 27. oktobra 1990. svečano otkriven spomenik Desanki Maksimović. Zbog malog negodovanja pesnikinje što joj se odaje velika čast, odlučeno je da spomenik, kao i trg na kojem se nalazi budu posvećeni pesništvu, a ne direktno njenom liku i delu. Ipak, danas je ovaj prostor među Valjevcima poznatiji kao Desankin trg sa Desankinim spomenikom u njegovom centralnom delu. Glavnu besedu u čast otvaranja spomenika održao je književnik i akademik Matija Bećković, koji nikad nije krio ljubav prema gradu na Kolubari.\n\nSpomenik je delo akademskog vajara i profesora Aleksandra Zarina, a isklesao ga je akademski vajar Milija Glišić. Plato oko spomenika projektovao je arhitekta Predrag Kojić, a radove je izvodilo Građevinsko preduzeće "Jablanica".',
        },
      },
      // Gradac
    ];

    await bulkInsertSightsData(dataList);
  }
}
