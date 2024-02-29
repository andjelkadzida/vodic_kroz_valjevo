import 'package:sqflite/sqflite.dart';

class SportsRepository {
  late Database _databaseInstance;

  SportsRepository(Database database) {
    _databaseInstance = database;
  }

  // Check if data exists returns true if sights data exists, false otherwise
  Future<bool> checkSportsDataExists() async {
    List<Map<String, dynamic>> sports = await _databaseInstance.query('Sports');
    return sports.isNotEmpty;
  }

  Future<void> bulkInsertSportsData(List<Map<String, dynamic>> dataList) async {
    // Begin the transaction
    await _databaseInstance.transaction((txn) async {
      var batch = txn.batch();
      for (var data in dataList) {
        // Add insert operation to the batch
        batch.rawInsert('''
          INSERT INTO Sports(
            sport_image_path,
            sport_image_path2,
            sport_image_path3,
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
          data['sport_image_path'],
          data['sport_image_path2'],
          data['sport_image_path3'],
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

  Future<void> sportsDataInsertion() async {
    List<Map<String, dynamic>> dataList = [
      // Peti Puk
      {
        'sport_image_path': 'images/sportsImages/petiPuk/radnicki1.jpg',
        'sport_image_path2': 'images/sportsImages/petiPuk/radnicki1.jpg',
        'sport_image_path3': 'images/sportsImages/petiPuk/radnicki1.jpg',
        'titles': {
          'en': 'Stadium of the FC Radnički Valjevo',
          'de': 'Stadion des FC Radnički Valjevo',
          'sr': 'Stadion FK Radnički Valjevo',
          'sr_Cyrl': 'Стадион ФК Раднички Ваљево',
          'sr_Latn': 'Stadion FK Radnički Valjevo',
        },
        'latitude': 44.28262046857639,
        'longitude': 19.891158538859084,
        'description': {
          'en':
              'Football Club Radnički, founded in 1967 in a part of Valjevo known as the Local Community Fifth Regiment, quickly stood out on the local sports scene and already won the championship among football teams in the area the following year. Unfortunately, in 1972, the club was forced to suspend its activities due to losing its playing field, which was given up for the construction of the November 27 Settlement. However, the passion for football among the residents of this part of Valjevo did not wane, leading to the club\'s re-establishment on June 20, 1979, when it officially received the name Radnički.\n\nSome of the notable players of this club are Slobodan Arsenijević, Radojica Karanović, Slobodan Radić, Živan Rakić…\n\nThe club is also proud of its fierce fans, the Wild Calves, who add a unique atmosphere to every match',
          'de':
              'Fußballclub Radnički, gegründet 1967 in einem Teil Valjevos, bekannt als die Lokalgemeinschaft Fünftes Regiment, zeichnete sich schnell auf der lokalen Sportbühne aus und gewann bereits im folgenden Jahr die Meisterschaft unter den Fußballmannschaften der Region. Leider musste der Verein 1972 seine Aktivitäten einstellen, da er sein Spielfeld verlor, das für den Bau der Siedlung 27. November aufgegeben wurde. Die Leidenschaft für Fußball unter den Bewohnern dieses Teils von Valjevo ließ jedoch nicht nach, was zur Neugründung des Clubs am 20. Juni 1979 führte, als er offiziell den Namen Radnički erhielt.\n\nEinige der bemerkenswerten Spieler dieses Clubs sind Slobodan Arsenijević, Radojica Karanović, Slobodan Radić, Živan Rakić…\n\nDer Club ist auch stolz auf seine leidenschaftlichen Fans, die Wilden Kälber, die jedem Spiel eine einzigartige Atmosphäre verleihen.',
          'sr':
              'Fudbalski klub Radnički, osnovan 1967. godine u delu Valjeva poznatom kao Mesna zajednica Peti puk, brzo se istakao na lokalnoj sportskoj sceni i već naredne godine osvojio prvenstvo među fudbalskim timovima u okolini. Nažalost, 1972. godine klub je bio primoran da obustavi svoje aktivnosti usled gubitka igrališta, koje je ustupljeno za izgradnju Naselja 27. novembar. Međutim, strast prema fudbalu među stanovnicima ovog dela Valjeva nije jenjavala, što je dovelo do ponovnog uspostavljanja kluba 20. juna 1979. godine, kada je i zvanično dobio ime Radnički.\n\nSamo neki od istaknutih igrača ovog kluba su: Slobodan Arsenijević, Radojica Karanović, Slobodan Radić, Živan Rakić…\n\nKlub se takođe ponosi svojim žestokim navijačima, Divljim Teladima, koji dodaju jedinstvenu atmosferu svakoj utakmici.',
          'sr_Cyrl':
              'Фудбалски клуб Раднички, основан 1967. године у делу Ваљева познатом као Месна заједница Пети пук, брзо се истакао на локалној спортској сцени и већ наредне године освојио првенство међу фудбалским тимовима у околини. Нажалост, 1972. године клуб је био приморан да обустави своје активности услед губитка игралишта, које је уступљено за изградњу Насеља 27. новембар. Међутим, страст према фудбалу међу становницима овог дела Ваљева није јењавала, што је довело до поновног успостављања клуба 20. јуна 1979. године, када је и званично добио име Раднички.\n\nСамо неки од истакнутих играча овог клуба су: Слободан Арсенијевић, Радојица Карановић, Слободан Радић, Живан Ракић…\n\nКлуб се такође поноси својим жестоким навијачима, Дивљим Теладима, који додају јединствену атмосферу свакој утакмици.',
          'sr_Latn':
              'Fudbalski klub Radnički, osnovan 1967. godine u delu Valjeva poznatom kao Mesna zajednica Peti puk, brzo se istakao na lokalnoj sportskoj sceni i već naredne godine osvojio prvenstvo među fudbalskim timovima u okolini. Nažalost, 1972. godine klub je bio primoran da obustavi svoje aktivnosti usled gubitka igrališta, koje je ustupljeno za izgradnju Naselja 27. novembar. Međutim, strast prema fudbalu među stanovnicima ovog dela Valjeva nije jenjavala, što je dovelo do ponovnog uspostavljanja kluba 20. juna 1979. godine, kada je i zvanično dobio ime Radnički.\n\nSamo neki od istaknutih igrača ovog kluba su: Slobodan Arsenijević, Radojica Karanović, Slobodan Radić, Živan Rakić…\n\nKlub se takođe ponosi svojim žestokim navijačima, Divljim Teladima, koji dodaju jedinstvenu atmosferu svakoj utakmici.',
        },
      },
      // Gradski stadion
      {
        'sport_image_path':
            'images/sportsImages/gradskiStadion/gradskiStadion1.jpg',
        'sport_image_path2':
            'images/sportsImages/gradskiStadion/gradskiStadion2.jpg',
        'sport_image_path3':
            'images/sportsImages/gradskiStadion/gradskiStadion3.jpg',
        'titles': {
          'en': 'Stadium of the FC Budućnost Krušik',
          'de': 'Stadion des FC Budućnost Krušik',
          'sr': 'Stadion FK Budućnost Krušik',
          'sr_Cyrl': 'Стадион ФК Будућност Крушик',
          'sr_Latn': 'Stadion FK Budućnost Krušik',
        },
        'latitude': 44.261982888560105,
        'longitude': 19.874679134004655,
        'description': {
          'en':
              'FK Budućnost Krušik 2014 was formed by the merger of FK Budućnost and FK Krušik in 2014, leaving a significant mark on the football history of Valjevo.\n\nFK Budućnost, founded as Radnički Club Sloga in 1920, has been carrying the name Budućnost since 1927. It successfully competed in the Second Federal League from 1969 to 1973, and a significant return to the Second League was recorded in 1993, after which the club entered an era of success, even competing for a spot in the First Federal League in 1998 against Budućnost from Podgorica.\n\nFK Krušik, established in 1946 by workers of "Vistad", quickly gained a reputation by competing in the Serbian League and qualifications for the Third Zone. The club achieved exceptional results, playing friendly matches against big teams such as Partizan and Red Star, attracting many spectators and investing in youth categories.',
          'de':
              'Der FK Budućnost Krušik 2014 entstand durch die Fusion von FK Budućnost und FK Krušik im Jahr 2014 und hinterließ eine bedeutende Spur in der Fußballgeschichte von Valjevo.\n\nDer FK Budućnost, gegründet als Radnički Club Sloga im Jahr 1920, trägt seit 1927 den Namen Budućnost. Er konkurrierte erfolgreich in der Zweiten Bundesliga von 1969 bis 1973, und eine bedeutende Rückkehr in die Zweite Liga wurde 1993 verzeichnet, nach der der Club eine Ära des Erfolgs betrat, sogar um einen Platz in der Ersten Bundesliga 1998 gegen Budućnost aus Podgorica konkurrierend.\n\nDer FK Krušik, 1946 von Arbeitern von "Vistad" gegründet, erlangte schnell einen Ruf durch die Teilnahme an der Serbischen Liga und den Qualifikationen für die Dritte Zone. Der Club erzielte außergewöhnliche Ergebnisse, spielte Freundschaftsspiele gegen große Teams wie Partizan und Roter Stern, zog viele Zuschauer an und investierte in Jugendspieler.',
          'sr':
              'FK Budućnost Krušik 2014 je nastao spajanjem FK Budućnost i FK Krušik 2014. godine, ostavivši značajan trag u fudbalskoj istoriji Valjeva.\n\nFK Budućnost, prvobitno osnovan kao Radnički klub Sloga 1920. godine, nosi ime Budućnost od 1927. Uspešno je konkurisao u Drugoj saveznoj ligi od 1969. do 1973, a veliki povratak u Drugu ligu zabeležen je 1993, nakon čega klub ulazi u eru uspeha, čak i takmičeći se za ulazak u Prvu saveznu ligu 1998. protiv podgoričke Budućnosti.\n\nFK Krušik, osnovan 1946. od radnika "Vistada", brzo je stekao ugled takmičeći se u Srpskoj ligi i kvalifikacijama za Treću zonu. Klub je postigao izuzetne rezultate, igrajući i prijateljske utakmice protiv velikih timova kao što su Partizan i Crvena Zvezda, privlačeći veliki broj gledalaca i ulažući u rad sa mlađim kategorijama.',
          'sr_Cyrl':
              'ФК Будућност Крушик 2014 је настао спајањем ФК Будућност и ФК Крушик 2014. године, оставивши значајан траг у фудбалској историји Ваљева.\n\nФК Будућност, првобитно основан као Раднички клуб Слога 1920. године, носи име Будућност од 1927. Успешно је конкурисао у Другој савезној лиги од 1969. до 1973, а велики повратак у Другу лигу забележен је 1993, након чега клуб улази у еру успеха, чак и такмичећи се за улазак у Прву савезну лигу 1998. против подгоричке Будућности.\n\nФК Крушик, основан 1946. од радника "Вистада", брзо је стекао углед утакмичећи се у Српској лиги и квалификацијама за Трећу зону. Клуб је постигао изузетне резултате, играјући и пријатељске утакмице против великих тимова као што су Партизан и Црвена Звезда, привлачећи велики број гледалаца и улажући у рад са млађим категоријама.',
          'sr_Latn':
              'FK Budućnost Krušik 2014 je nastao spajanjem FK Budućnost i FK Krušik 2014. godine, ostavivši značajan trag u fudbalskoj istoriji Valjeva.\n\nFK Budućnost, prvobitno osnovan kao Radnički klub Sloga 1920. godine, nosi ime Budućnost od 1927. Uspešno je konkurisao u Drugoj saveznoj ligi od 1969. do 1973, a veliki povratak u Drugu ligu zabeležen je 1993, nakon čega klub ulazi u eru uspeha, čak i takmičeći se za ulazak u Prvu saveznu ligu 1998. protiv podgoričke Budućnosti.\n\nFK Krušik, osnovan 1946. od radnika "Vistada", brzo je stekao ugled takmičeći se u Srpskoj ligi i kvalifikacijama za Treću zonu. Klub je postigao izuzetne rezultate, igrajući i prijateljske utakmice protiv velikih timova kao što su Partizan i Crvena Zvezda, privlačeći veliki broj gledalaca i ulažući u rad sa mlađim kategorijama.',
        },
      },
      // Tenis
      {
        'sport_image_path': 'images/sportsImages/tenis/tenis1.jpg',
        'sport_image_path2': 'images/sportsImages/tenis/tenis2.jpg',
        'sport_image_path3': 'images/sportsImages/tenis/tenis3.jpg',
        'titles': {
          'en': 'Tennis court',
          'de': 'Tennisplatz',
          'sr': 'Teniski teren',
          'sr_Cyrl': 'Тениски терен',
          'sr_Latn': 'Teniski teren',
        },
        'latitude': 44.26262278827975,
        'longitude': 19.876072656330674,
        'description': {
          'en':
              'Interest in tennis in Valjevo developed immediately after World War I, but it wasn\'t until 1927 that steps were taken to establish a tennis club. According to data from the Great Yugoslav Sports Almanac published in Belgrade in 1930, the founder of the Valjevo Tennis Club was high school professor Živorad Grbić, with enthusiastic support from Milo Babić, the city engineer.\n\nIn October 2023, the club hosted the Serbia Grand Prix tournament for young male and female tennis players up to 16 years old under the auspices of the Tennis Federation of Serbia.\n\nThe club has available courts covered with clay and concrete, which are open for use by all citizens.',
          'de':
              'Das Interesse an Tennis in Valjevo entwickelte sich unmittelbar nach dem Ersten Weltkrieg, aber erst 1927 wurden Schritte zur Gründung eines Tennisclubs unternommen. Laut Angaben aus dem Großen Jugoslawischen Sportalmanach, der 1930 in Belgrad veröffentlicht wurde, war der Gründer des Valjevo Tennisclubs der Gymnasialprofessor Živorad Grbić, mit begeisteter Unterstützung von Milo Babić, dem Stadtingenieur.\n\nIm Oktober 2023 richtete der Club das Serbia Grand Prix Turnier für junge männliche und weibliche Tennisspieler bis zu 16 Jahren unter der Schirmherrschaft des Tennisverbands von Serbien aus.\n\nDer Club verfügt über verfügbare Plätze, die mit Ton und Beton bedeckt sind und allen Bürgern zur Nutzung offenstehen.',
          'sr':
              'Interes za tenis u Valjevu se razvio neposredno nakon Prvog svetskog rata, ali tek 1927. godine preduzeti su koraci ka osnivanju teniskog kluba. Prema podacima iz Velikog jugoslovenskog sportskog almanaha objavljenog u Beogradu 1930, osnivač Valjevskog teniskog kluba bio je profesor gimnazije Živorad Grbić, uz entuzijastičnu podršku Mila Babića, gradskog inženjera.\n\nU oktobru 2023. godine, klub je ugostio Serbia Grand Prix turnir za mlade tenisere i teniserke do 16 godina, pod pokroviteljstvom Teniskog saveza Srbije.\n\nKlub ima na raspolaganju terene prekrivene šljakom i betonom, koji su otvoreni za korišćenje svim građanima.',
          'sr_Cyrl':
              'Интерес за тенис у Ваљеву се развио непосредно након Првог светског рата, али тек 1927. године предузети су кораци ка оснивању тениског клуба. Према подацима из Великог југословенског спортског алманаха објављеног у Београду 1930, оснивач Ваљевског тениског клуба био је професор гимназије Живорад Грбић, уз ентузијастичну подршку Мила Бабића, градског инжењера.\n\nУ октобру 2023. године, клуб је угостио Serbia Grand Prix турнир за младе тенисере и тенисерке до 16 година, под покровитељством Тениског савеза Србије.\n\nКлуб има на располагању терене прекривене шљаком и бетоном, који су отворени за коришћење свим грађанима.',
          'sr_Latn':
              'Interes za tenis u Valjevu se razvio neposredno nakon Prvog svetskog rata, ali tek 1927. godine preduzeti su koraci ka osnivanju teniskog kluba. Prema podacima iz Velikog jugoslovenskog sportskog almanaha objavljenog u Beogradu 1930, osnivač Valjevskog teniskog kluba bio je profesor gimnazije Živorad Grbić, uz entuzijastičnu podršku Mila Babića, gradskog inženjera.\n\nU oktobru 2023. godine, klub je ugostio Serbia Grand Prix turnir za mlade tenisere i teniserke do 16 godina, pod pokroviteljstvom Teniskog saveza Srbije.\n\nKlub ima na raspolaganju terene prekrivene šljakom i betonom, koji su otvoreni za korišćenje svim građanima.',
        },
      },
    ];

    await bulkInsertSportsData(dataList);
  }
}
