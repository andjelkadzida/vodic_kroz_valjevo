// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Vodič kroz Valjevo';

  @override
  String get homePage => 'Početna';

  @override
  String get aboutCity => 'O gradu';

  @override
  String get sights => 'Znamenitosti';

  @override
  String sightName(Object name) {
    return 'Naziv znamenitost: $name';
  }

  @override
  String get sportRecreation => 'Sport i rekreacija';

  @override
  String get restaurantsAndHotels => 'Restorani i prenoćište';

  @override
  String get hotels => 'Hoteli';

  @override
  String get close => 'Zatvori';

  @override
  String get serbian => 'Srpski (Latinica)';

  @override
  String get serbianCyrl => 'Srpski (Ćirilica)';

  @override
  String get english => 'Engleski';

  @override
  String get german => 'Nemački';

  @override
  String get museum => 'Muzej';

  @override
  String get languageMenu => 'Meni za izbor jezika';

  @override
  String get startNavigation => 'Pokrenite navigaciju';

  @override
  String get tapToNavigateToPark => 'Dodirnite da biste navigirali do parka.';

  @override
  String get tapToNavigateToSportField =>
      'Dodirnite da biste navigirali do sportskog terena.';

  @override
  String get tapToNavigateToRestaurant =>
      'Dodirnite da biste navigirali do restorana.';

  @override
  String get tapToNavigateToHotel => 'Dodirnite da biste navigirali do hotela.';

  @override
  String get tapToNavigateToSight =>
      'Dodirnite da biste navigirali do znamenitosti.';

  @override
  String get settings => 'Podešavanja';

  @override
  String get openSettings => 'Otvorite podešavanja';

  @override
  String get connectionProblem =>
      'Zahtev nije moguće izvršiti. Proverite internet vezu i pokušajte ponovo.';

  @override
  String get networkSettingsHint =>
      'Uključite Wi-Fi ili mobilne podatke u podešavanjima uređaja.';

  @override
  String get networkSettingsIosHint =>
      'Uključite Wi-Fi ili mobilne podatke u Podešavanjima ili Kontrolnom centru.';

  @override
  String get networkSettingsFailed =>
      'Nije moguće otvoriti podešavanja uređaja.';

  @override
  String get retryConnection => 'Pokušaj ponovo';

  @override
  String image(Object name) {
    return 'Slika $name';
  }

  @override
  String get loading => 'Učitavanje podataka, molimo sačekajte...';

  @override
  String get errorLoadingData =>
      'Došlo je do greške prilikom učitavanja podataka.';

  @override
  String get noDataAvailable => 'Podaci nisu dostupni!';

  @override
  String get tapToHearSightDetails => 'Pročitaj detalje o znamenitosti';

  @override
  String get tapToHearParkDetails => 'Pročitaj detalje o parku';

  @override
  String get tapToHearSportDetails => 'Pročitaj detalje o sportskom terenu';

  @override
  String get tapToViewPark => 'Dodirnite da vidite detalje parka.';

  @override
  String get tapToViewSport => 'Dodirnite da vidite detalje sportskog terena.';

  @override
  String get tapToHearLegend => 'Pročitaj legendu o gradu';

  @override
  String get tapToHearHistory => 'Pročitaj istoriju grada';

  @override
  String readCityFact(String fact) {
    return 'Naglas pročitaj: $fact';
  }

  @override
  String tapToSeeSightDetails(Object name) {
    return 'Da biste videli više informacija o znamenitosti pod imenom $name, jednostavno dodirnite.';
  }

  @override
  String get legendOfTheCity => 'Legende o imenu grada';

  @override
  String starCount(num numberOfStars) {
    String _temp0 = intl.Intl.pluralLogic(
      numberOfStars,
      locale: localeName,
      other: '$numberOfStars zvezdice',
      one: '1 zvezdica',
    );
    return '$_temp0';
  }

  @override
  String get closeDialog => 'Zatvori dijalog';

  @override
  String get details => 'Detalji';

  @override
  String get hotelImage => 'Slika hotela';

  @override
  String get hotelName => 'Naziv hotela: ';

  @override
  String get restaurants => 'Restorani';

  @override
  String get restaurantName => 'Naziv restorana: ';

  @override
  String get restaurantImage => 'Slika restorana';

  @override
  String get sportFields => 'Sportski tereni';

  @override
  String get parks => 'Parkovi';

  @override
  String get valjevoCityImage => 'Slika grada Valjeva';

  @override
  String get chooseLanguage => 'Izaberite jezik';

  @override
  String get menu => 'Meni';

  @override
  String get getStarted => 'Počni';

  @override
  String get mapPage => 'Mapa grada';

  @override
  String get map => 'Mapa grada Valjeva';

  @override
  String get mapView => 'Prikaz mape';

  @override
  String get listView => 'Prikaz liste';

  @override
  String get previousItem => 'Prethodna stavka';

  @override
  String get nextItem => 'Sledeća stavka';

  @override
  String get previousPhoto => 'Prethodna fotografija';

  @override
  String get nextPhoto => 'Sledeća fotografija';

  @override
  String get zoomIn => 'Uvećaj';

  @override
  String get zoomOut => 'Umanji';

  @override
  String get resetZoom => 'Vrati uvećanje';

  @override
  String get movePhotoUp => 'Pomeri fotografiju nagore';

  @override
  String get movePhotoDown => 'Pomeri fotografiju nadole';

  @override
  String get movePhotoLeft => 'Pomeri fotografiju nalevo';

  @override
  String get movePhotoRight => 'Pomeri fotografiju nadesno';

  @override
  String get moveMapUp => 'Pomeri mapu nagore';

  @override
  String get moveMapDown => 'Pomeri mapu nadole';

  @override
  String get moveMapLeft => 'Pomeri mapu nalevo';

  @override
  String get moveMapRight => 'Pomeri mapu nadesno';

  @override
  String get resetMap => 'Vrati mapu';

  @override
  String get stopReading => 'Zaustavi čitanje';

  @override
  String get speechUnavailable =>
      'Čitanje nije dostupno. Proverite podešavanja govora na uređaju.';

  @override
  String get retryImage => 'Pokušaj ponovo da učitaš sliku';

  @override
  String positionInList(int current, int total) {
    return '$current od $total';
  }

  @override
  String get website => 'Veb-sajt';

  @override
  String menuItem(Object item) {
    return 'Stavka menija: $item';
  }

  @override
  String tapToOpen(Object item) {
    return 'Dodirni da otvoriš $item';
  }

  @override
  String imageOfSight(Object name) {
    return 'Slika znamenitosti $name';
  }

  @override
  String get tapToHearSightName => 'Dodirnite da biste čuli naziv znamenitosti';

  @override
  String get historyOfTheCity => 'Istorija grada';

  @override
  String get song =>
      'Kad dođes u bilo koji grad\n\nA u bilo koji grad se dolazi vrlo kasno\n\nKad dođes vrlo kasno u bilo koji grad\n\nAko taj grad slučajno bude Valjevo...';

  @override
  String get bugReport => 'Formular za prijavu grešaka';

  @override
  String get bugTitle => 'Naslov greške';

  @override
  String get bugDescription => 'Opis greške';

  @override
  String get operatingSystem => 'Operativni sistem';

  @override
  String get selectOS => 'Molimo vas da odaberete operativni sistem';

  @override
  String get selectOSLabel => 'Pritisnite da izaberete operativni sistem.';

  @override
  String get deviceModel => 'Model uređaja';

  @override
  String get osVersion => 'Verzija operativnog sistema';

  @override
  String get uploadFile => 'Otpremi datoteku';

  @override
  String get submit => 'Pošalji';

  @override
  String get enterDescription => 'Molimo unesite opis problema.';

  @override
  String get enterTitle => 'Molimo unesite naslov problema.';

  @override
  String get submissionFailed => 'Nije uspelo slanje izveštaja o grešci...';

  @override
  String get noFileSelected => 'Nijedna datoteka nije odabrana';

  @override
  String get bugTitleLabel => 'Polje za unos naslova greške';

  @override
  String get bugDescriptionLabel => 'Polje za unos opisa greške';

  @override
  String get osLabel => 'Padajući meni za operativni sistem';

  @override
  String get fileUploadLabel => 'Dugme za otpremanje datoteke';

  @override
  String changeLanguageLabel(Object lang) {
    return 'Promeni jezik na $lang';
  }

  @override
  String selectLanguageLabel(Object lang) {
    return 'Izaberite $lang';
  }

  @override
  String get bugReportSent => 'Izveštaj o grešci uspešno poslat.';

  @override
  String get ok => 'OK';

  @override
  String get photoSource => 'Izvor fotografija';

  @override
  String get copyrightOfImages => 'Autorsko pravo na fotografije';

  @override
  String get noInternetConnection => 'Nema internet konekcije!';

  @override
  String get aboutApp => 'O aplikaciji';

  @override
  String get appAuthor => '© 2026 Anđelka Džida';

  @override
  String get appLogo => 'Logo aplikacije';

  @override
  String get aboutAppLocalization =>
      'Lokalizacija: Naša aplikacija je dizajnirana za globalnu dostupnost, nudeći višejezičnu podršku koja obuhvata engleski, nemački i srpski jezik, uključujući i latinično i ćirilično pismo.';

  @override
  String get aboutAppAccessibility =>
      'Pristupačnost: Posvećeni smo tome da našu aplikaciju učinimo dostupnom svima, uključujući korisnike sa invaliditetom. Naša aplikacija sadrži funkcije kao što su podrška za čitače ekrana i prilagodljive veličine teksta.';

  @override
  String get aboutAppDescription =>
      'Istražite bez napora sa našom Tour Guide aplikacijom, vašim džepnim stručnjakom za putovanja. Zaronite u suštinu svake destinacije sa detaljnim vodičima za znamenitosti, hotele, restorane, parkove i sportske objekte. Navigacija je jednostavna, a uz bogate narative o vašem okruženju svako putovanje postaje doživljaj za pamćenje. Dizajnirana za pristupačnost, naša aplikacija osigurava besprekorno iskustvo za sve putnike. Krenite na put otkrića i dozvolite nam da vas vodimo do čuda sveta, sve iz dlana vaše ruke.';

  @override
  String get privacyPolicy => 'Politika privatnosti';

  @override
  String buttonFor(Object label) {
    return 'Dugme za $label';
  }

  @override
  String get songAuthor =>
      'Stihovi Matije Bećkovića iz pesme \'Kad dođeš u bilo koji grad\'';

  @override
  String get surface => 'Površina';

  @override
  String get elevation => 'Nadmorska visina';

  @override
  String get populationDensity => 'Gustina naseljenosti';

  @override
  String get population => 'Broj stanovnika';

  @override
  String citySurfaceValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString ha';
  }

  @override
  String citySurfaceSpoken(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString hektara';
  }

  @override
  String cityElevationValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString m';
  }

  @override
  String cityElevationSpoken(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString metara';
  }

  @override
  String cityDensityValue(double value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString st./km² ($year.)';
  }

  @override
  String cityDensitySpoken(double value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString stanovnika po kvadratnom kilometru $year. godine';
  }

  @override
  String cityPopulationValue(int value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString ($year.)';
  }

  @override
  String cityPopulationSpoken(int value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString stanovnika $year. godine';
  }

  @override
  String get district => 'Okrug';

  @override
  String get cityDay => 'Dan grada';

  @override
  String get saint => 'Slava grada';

  @override
  String get kolubaraDistrict => 'Kolubarski okrug';

  @override
  String get saintName => 'Trojice (Duhovi)';

  @override
  String get indicator => 'Indikator';

  @override
  String get openAboutDialog => 'Otvori dijalog o programu.';

  @override
  String get cityDayDate => '20. mart';

  @override
  String get termsOfUse => 'Uslovi korišćenja';

  @override
  String get infoByYou => 'Informacije koje ste pružili';

  @override
  String get infoByYouContent =>
      'Kada stupate u interakciju s nama kontaktiranjem, davanjem povratnih informacija ili popunjavanjem obrazaca, Vodič Kroz Valjevo može sakupiti dodatne podatke kao što su vaša lokacija, detalji o internet konekciji i više.';

  @override
  String get autoCollectedData =>
      'Informacije koje automatski sakuplja Vodič Kroz Valjevo';

  @override
  String get autoCollectedDataContent =>
      'Vodič Kroz Valjevo automatski sakuplja podatke kao što su informacije o uređaju kada koristite naše usluge ili aplikacije.';

  @override
  String get localStorage => 'Napomena o lokalnom skladištenju';

  @override
  String get localStorageContent =>
      'Da bi poboljšao naše usluge i stekao uvid u vaše obrasce interakcije, Vodič Kroz Valjevo koristi tehnologije za lokalno skladištenje. Molimo vas da imate u vidu da se vaše postavke i preferencije čuvaju direktno na vašem uređaju jer ne koristimo kolačiće.';

  @override
  String get useOfInfo => 'Korišćenje informacija';

  @override
  String get useOfInfoContent =>
      'Vodič Kroz Valjevo može koristiti vaše informacije za poboljšanje i pružanje naših usluga, praćenje vaših aktivnosti, komunikaciju sa vama, pružanje podrške korisnicima i osiguranje sigurnosti naših uslova i pravila.';

  @override
  String get thirdParty => 'Pristup trećih strana vašim informacijama';

  @override
  String get thirdPartyContent =>
      'Vaši podaci mogu biti podeljeni sa trećim stranama iz raznih razloga, uključujući, ali ne ograničavajući se na, saradnju sa pružaocima usluga i pridržavanje zakona, u skladu sa našim uslovima i pravilima.';

  @override
  String get tearmsOfAnd =>
      'Uslovi korišćenja i pravila o privatnosti trećih strana';

  @override
  String get tearmsOfAndContent =>
      'Priznajete da Vodič Kroz Valjevo koristi usluge trećih strana koje mi ne upravljamo niti obezbeđujemo, i vaša je odgovornost da pregledate njihove politike.';

  @override
  String get ongoingAmend => 'Tekuće izmene';

  @override
  String get ongoingAmendContent =>
      'Vodič Kroz Valjevo zadržava pravo da menja ovu politiku privatnosti, pri čemu izmene stupaju na snagu odmah po objavljivanju. Nastavkom korišćenja naše usluge nakon izmene, prihvatate te izmene.';

  @override
  String get contact => 'Kontakt';

  @override
  String get contactContent =>
      'Ako imate pitanja ili zabrinutosti u vezi sa ovom politikom privatnosti, molimo vas da nas kontaktirate putem e-pošte.';

  @override
  String get mapCredits => 'Zasluge za mape';

  @override
  String get mapCreditsContent =>
      'Priznajemo doprinose projekata poput Open Street Map u pružanju skalabilnih podataka o mapama.';

  @override
  String lastUpdated(Object date) {
    return 'Poslednje ažurirano $date';
  }

  @override
  String get termsContent =>
      'Dobrodošli u Vodič Kroz Valjevo, mobilnu aplikaciju koju je razvila i održava Anđelka Džida („mi“, „nas“ ili „naš“). Preuzimanjem, pristupanjem ili korišćenjem naše mobilne aplikacije, slažete se da budete vezani ovim Uslovima korišćenja („Uslovi“). Ako se ne slažete sa ovim Uslovima, molimo vas da ne koristite našu aplikaciju.';

  @override
  String get acceptanceTerms => 'Prihvatanje Uslova';

  @override
  String get acceptanceTermsContent =>
      'Slažete se da pristupanjem ili korišćenjem naše aplikacije pristajete na ove Uslove i našu Politiku privatnosti.';

  @override
  String get termsChanges => 'Promene Uslova korišćenja';

  @override
  String get termsChangesContent =>
      'Zadržavamo pravo da u bilo kom trenutku izmenimo ove Uslove. Vaše kontinuirano korišćenje aplikacije nakon promena ukazuje na vaše prihvatanje novih Uslova.';

  @override
  String get privacyContent =>
      'Naša Politika privatnosti opisuje kako postupamo s informacijama koje nam pružate kada koristite našu aplikaciju. Korišćenjem naše aplikacije slažete se sa prikupljanjem i korišćenjem informacija u skladu sa našom Politikom privatnosti.';

  @override
  String get userConduct => 'Ponašanje Korisnika';

  @override
  String get userConductContent =>
      'Slažete se da nećete učestvovati u bilo kom ponašanju koje je nezakonito, krši prava drugih ili je na drugi način neprihvatljivo.';

  @override
  String get intellectualProperty => 'Intelektualna Svojina';

  @override
  String get intellectualPropertyContent =>
      'Aplikacija i njen originalni sadržaj, funkcije i funkcionalnosti su i ostaće ekskluzivna svojina Anđelke Džide i njenih licencodavaca.';

  @override
  String get userGen => 'Sadržaj Generisan od Strane Korisnika';

  @override
  String get userGenContent =>
      'Možda ćete moći da dostavite sadržaj putem aplikacije. Zadržavate sva prava na svoj sadržaj, ali nam dajete neekskluzivnu, besplatnu licencu da koristimo, reprodukujemo, modifikujemo i prikazujemo vaš sadržaj u vezi sa aplikacijom.';

  @override
  String get thirdPartServices => 'Linkovi i Usluge Trećih Strana';

  @override
  String get thirdPartServicesContent =>
      'Naša aplikacija može sadržati linkove ka veb-sajtovima ili uslugama trećih strana koje nisu u našem vlasništvu ili pod našom kontrolom. Nismo odgovorni za sadržaj, politike privatnosti ili prakse bilo kog veb-sajta ili usluge trećih strana.';

  @override
  String get appChanges => 'Promene naše Aplikacije';

  @override
  String get appChangesContent =>
      'Zadržavamo pravo da modifikujemo, trajno ili privremeno prekinemo aplikaciju ili bilo koju uslugu na koju se povezuje, sa ili bez obaveštenja i bez odgovornosti prema vama.';

  @override
  String get contactUs => 'Kontaktirajte Nas';

  @override
  String get contactUsContent =>
      'Ako imate bilo kakvih pitanja o ovim Uslovima, molimo vas da nas kontaktirate na ';
}

/// The translations for Serbian, using the Cyrillic script (`sr_Cyrl`).
class AppLocalizationsSrCyrl extends AppLocalizationsSr {
  AppLocalizationsSrCyrl() : super('sr_Cyrl');

  @override
  String get appTitle => 'Водич кроз Ваљево';

  @override
  String get homePage => 'Почетна';

  @override
  String get aboutCity => 'О граду';

  @override
  String get sights => 'Знаменитости';

  @override
  String sightName(Object name) {
    return 'Назив знаменитости: $name';
  }

  @override
  String get sportRecreation => 'Спорт и рекреација';

  @override
  String get restaurantsAndHotels => 'Ресторани и преноћиште';

  @override
  String get hotels => 'Хотели';

  @override
  String get close => 'Затвори';

  @override
  String get serbian => 'Српски (Латиница)';

  @override
  String get serbianCyrl => 'Српски (Ћирилица)';

  @override
  String get english => 'Енглески';

  @override
  String get german => 'Немачки';

  @override
  String get museum => 'Музеј';

  @override
  String get languageMenu => 'Мени за избор језика';

  @override
  String get startNavigation => 'Покрените навигацију';

  @override
  String get tapToNavigateToPark => 'Додирните да бисте навигирали до парка.';

  @override
  String get tapToNavigateToSportField =>
      'Додирните да бисте навигирали до спортског терена.';

  @override
  String get tapToNavigateToRestaurant =>
      'Додирните да бисте навигирали до ресторана.';

  @override
  String get tapToNavigateToHotel => 'Додирните да бисте навигирали до хотела.';

  @override
  String get tapToNavigateToSight =>
      'Додирните да бисте навигирали до знаменитости.';

  @override
  String get settings => 'Подешавања';

  @override
  String get openSettings => 'Отворите подешавања';

  @override
  String get connectionProblem =>
      'Захтев није могуће извршити. Проверите интернет везу и покушајте поново.';

  @override
  String get networkSettingsHint =>
      'Укључите Wi-Fi или мобилне податке у подешавањима уређаја.';

  @override
  String get networkSettingsIosHint =>
      'Укључите Wi-Fi или мобилне податке у Подешавањима или Контролном центру.';

  @override
  String get networkSettingsFailed =>
      'Није могуће отворити подешавања уређаја.';

  @override
  String get retryConnection => 'Покушај поново';

  @override
  String image(Object name) {
    return 'Слика $name';
  }

  @override
  String get loading => 'Учитавање података, молимо сачекајте...';

  @override
  String get errorLoadingData =>
      'Дошло је до грешке приликом учитавања података.';

  @override
  String get noDataAvailable => 'Подаци нису доступни!';

  @override
  String get tapToHearSightDetails => 'Прочитај детаље о знаменитости';

  @override
  String get tapToHearParkDetails => 'Прочитај детаље о парку';

  @override
  String get tapToHearSportDetails => 'Прочитај детаље о спортском терену';

  @override
  String get tapToViewPark => 'Додирните да видите детаље парка.';

  @override
  String get tapToViewSport => 'Додирните да видите детаље спортског терена.';

  @override
  String get tapToHearLegend => 'Прочитај легенду о граду';

  @override
  String get tapToHearHistory => 'Прочитај историју града';

  @override
  String readCityFact(String fact) {
    return 'Наглас прочитај: $fact';
  }

  @override
  String tapToSeeSightDetails(Object name) {
    return 'Да бисте видели више информација о знаменитости под именом $name, једноставно додирните.';
  }

  @override
  String get legendOfTheCity => 'Легенде о имену града';

  @override
  String starCount(num numberOfStars) {
    String _temp0 = intl.Intl.pluralLogic(
      numberOfStars,
      locale: localeName,
      other: '$numberOfStars звездице',
      one: '1 звездица',
    );
    return '$_temp0';
  }

  @override
  String get closeDialog => 'Затвори дијалог';

  @override
  String get details => 'Детаљи';

  @override
  String get hotelImage => 'Слика хотела';

  @override
  String get hotelName => 'Назив хотела: ';

  @override
  String get restaurants => 'Ресторани';

  @override
  String get restaurantName => 'Назив ресторана: ';

  @override
  String get restaurantImage => 'Слика ресторана';

  @override
  String get sportFields => 'Спортски терени';

  @override
  String get parks => 'Паркови';

  @override
  String get valjevoCityImage => 'Слика града Ваљева';

  @override
  String get chooseLanguage => 'Изаберите језик';

  @override
  String get menu => 'Мени';

  @override
  String get getStarted => 'Почни';

  @override
  String get mapPage => 'Мапа града';

  @override
  String get map => 'Мапа града Ваљева';

  @override
  String get mapView => 'Приказ мапе';

  @override
  String get listView => 'Приказ листе';

  @override
  String get previousItem => 'Претходна ставка';

  @override
  String get nextItem => 'Следећа ставка';

  @override
  String get previousPhoto => 'Претходна фотографија';

  @override
  String get nextPhoto => 'Следећа фотографија';

  @override
  String get zoomIn => 'Увећај';

  @override
  String get zoomOut => 'Умањи';

  @override
  String get resetZoom => 'Врати увећање';

  @override
  String get movePhotoUp => 'Помери фотографију нагоре';

  @override
  String get movePhotoDown => 'Помери фотографију надоле';

  @override
  String get movePhotoLeft => 'Помери фотографију налево';

  @override
  String get movePhotoRight => 'Помери фотографију надесно';

  @override
  String get moveMapUp => 'Помери мапу нагоре';

  @override
  String get moveMapDown => 'Помери мапу надоле';

  @override
  String get moveMapLeft => 'Помери мапу налево';

  @override
  String get moveMapRight => 'Помери мапу надесно';

  @override
  String get resetMap => 'Врати мапу';

  @override
  String get stopReading => 'Заустави читање';

  @override
  String get speechUnavailable =>
      'Читање није доступно. Проверите подешавања говора на уређају.';

  @override
  String get retryImage => 'Покушај поново да учиташ слику';

  @override
  String positionInList(int current, int total) {
    return '$current од $total';
  }

  @override
  String get website => 'Веб-сајт';

  @override
  String menuItem(Object item) {
    return 'Ставка менија: $item';
  }

  @override
  String tapToOpen(Object item) {
    return 'Додирни да отвориш $item';
  }

  @override
  String imageOfSight(Object name) {
    return 'Слика знаменитости $name';
  }

  @override
  String get tapToHearSightName => 'Додирните да бисте чули назив знаменитости';

  @override
  String get historyOfTheCity => 'Историја града';

  @override
  String get song =>
      'Кад дођеш у било који град\n\nА у било који град се долази врло касно\n\nКад дођеш врло касно у било који град\n\nАко тај град случајно буде Ваљево...';

  @override
  String get bugReport => 'Формулар за пријаву грешака';

  @override
  String get bugTitle => 'Наслов грешке';

  @override
  String get bugDescription => 'Опис грешке';

  @override
  String get operatingSystem => 'Оперативни систем';

  @override
  String get selectOS => 'Молимо вас да одаберете оперативни систем';

  @override
  String get selectOSLabel => 'Притисните да изаберете оперативни систем.';

  @override
  String get deviceModel => 'Модел уређаја';

  @override
  String get osVersion => 'Верзија оперативног система';

  @override
  String get uploadFile => 'Отпреми датотеку';

  @override
  String get submit => 'Пошаљи';

  @override
  String get enterDescription => 'Молимо унесите опис проблема.';

  @override
  String get enterTitle => 'Молимо унесите наслов проблема.';

  @override
  String get submissionFailed => 'Није успело слање извештаја о грешци...';

  @override
  String get noFileSelected => 'Ниједна датотека није одабрана';

  @override
  String get bugTitleLabel => 'Поље за унос наслова грешке';

  @override
  String get bugDescriptionLabel => 'Поље за унос описа грешке';

  @override
  String get osLabel => 'Падајући мени за оперативни систем';

  @override
  String get fileUploadLabel => 'Дугме за отпремање датотеке';

  @override
  String changeLanguageLabel(Object lang) {
    return 'Промени језик на $lang';
  }

  @override
  String selectLanguageLabel(Object lang) {
    return 'Изаберите $lang';
  }

  @override
  String get bugReportSent => 'Извештај о грешци успешно послат.';

  @override
  String get ok => 'ОК';

  @override
  String get photoSource => 'Извор фотографија';

  @override
  String get copyrightOfImages => 'Ауторско право на фотографије';

  @override
  String get noInternetConnection => 'Нема интернет конекције!';

  @override
  String get aboutApp => 'О апликацији';

  @override
  String get appAuthor => '© 2026 Анђелка Џида';

  @override
  String get appLogo => 'Лого апликације';

  @override
  String get aboutAppLocalization =>
      'Локализација: Наша апликација је дизајнирана за глобалну доступност, нудећи вишејезичну подршку која обухвата енглески, немачки и српски језик, укључујући и латинично и ћирилично писмо.';

  @override
  String get aboutAppAccessibility =>
      'Приступачност: Посвећени смо томе да нашу апликацију учинимо доступном свима, укључујући кориснике са инвалидитетом. Наша апликација садржи функције као што су подршка за читаче екрана и прилагодљиве величине текста.';

  @override
  String get aboutAppDescription =>
      'Истражите без напора са нашом Tour Guide апликацијом, вашим џепним стручњаком за путовања. Зароните у суштину сваке дестинације са детаљним водичима за знаменитости, хотеле, ресторане, паркове и спортске објекте. Навигација је једноставна, а уз богате наративе о вашем окружењу свако путовање постаје доживљај за памћење. Дизајнирана за приступачност, наша апликација осигурава беспрекорно искуство за све путнике. Крените на пут открића и дозволите нам да вас водимо до чуда света, све из длана ваше руке.';

  @override
  String get privacyPolicy => 'Политика приватности';

  @override
  String buttonFor(Object label) {
    return 'Дугме за $label';
  }

  @override
  String get songAuthor => 'Матија Бећковић - \'Кад дођеш у било који град\'';

  @override
  String get surface => 'Површина';

  @override
  String get elevation => 'Надморска висина';

  @override
  String get populationDensity => 'Густина насељености';

  @override
  String get population => 'Број становника';

  @override
  String citySurfaceValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString ха';
  }

  @override
  String citySurfaceSpoken(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString хектара';
  }

  @override
  String cityElevationValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString м';
  }

  @override
  String cityElevationSpoken(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString метара';
  }

  @override
  String cityDensityValue(double value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString ст./км² ($year.)';
  }

  @override
  String cityDensitySpoken(double value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString становника по квадратном километру $year. године';
  }

  @override
  String cityPopulationValue(int value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString ($year.)';
  }

  @override
  String cityPopulationSpoken(int value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString становника $year. године';
  }

  @override
  String get district => 'Округ';

  @override
  String get cityDay => 'Дан града';

  @override
  String get saint => 'Слава града';

  @override
  String get kolubaraDistrict => 'Колубарски округ';

  @override
  String get saintName => 'Тројице (Духови)';

  @override
  String get indicator => 'Индикатор';

  @override
  String get openAboutDialog => 'Отвори дијалог о програму.';

  @override
  String get cityDayDate => '20. март';

  @override
  String get termsOfUse => 'Услови коришћења';

  @override
  String get infoByYou => 'Информације које сте пружили';

  @override
  String get infoByYouContent =>
      'Када ступате у интеракцију са нама контактирањем, давањем повратних информација или попуњавањем образаца, Водич Кроз Ваљево може сакупити додатне податке као што су ваша локација, детаљи о интернет конекцији и више.';

  @override
  String get autoCollectedData =>
      'Информације које аутоматски сакупља Водич Кроз Ваљево';

  @override
  String get autoCollectedDataContent =>
      'Водич Кроз Ваљево аутоматски сакупља податке као што су информације о уређају када користите наше услуге или апликације.';

  @override
  String get localStorage => 'Напомена о локалном складишту';

  @override
  String get localStorageContent =>
      'Да би побољшао наше услуге и стекао увид у ваше обрасце интеракција, Водич Кроз Ваљево користи технологије за локално складиштење. Молимо вас да имате у виду да се ваше поставке и преференције чувају директно на вашем уређају јер не користимо колачиће.';

  @override
  String get useOfInfo => 'Коришћење информација';

  @override
  String get useOfInfoContent =>
      'Водич Кроз Ваљево може користити ваше информације за побољшање и пружање наших услуга, праћење ваших активности, комуникацију са вама, пружање подршке корисницима и осигурање сигурности наших услова и правила.';

  @override
  String get thirdParty => 'Приступ трећих страна вашим информацијама';

  @override
  String get thirdPartyContent =>
      'Ваши подаци могу бити подељени са трећим странама из разних разлога, укључујући, али не ограничавајући се на, сарадњу са пружаоцима услуга и придржавање закона, у складу са нашим условима и правилима.';

  @override
  String get tearmsOfAnd =>
      'Услови коришћења и правила о приватности трећих страна';

  @override
  String get tearmsOfAndContent =>
      'Признајете да Водич Кроз Ваљево користи услуге трећих страна које ми не управљамо нити обезбеђујемо, и ваша је одговорност да прегледате њихове политике.';

  @override
  String get ongoingAmend => 'Текуће измене';

  @override
  String get ongoingAmendContent =>
      'Водич Кроз Ваљево задржава право да мења ову политику приватности, при чему измене ступају на снагу одмах по објављивању. Наставком коришћења наше услуге након измене, прихватате те измене.';

  @override
  String get contact => 'Контакт';

  @override
  String get contactContent =>
      'Ако имате питања или забринутости у вези са овом политиком приватности, молимо вас да нас контактирате путем е-поште.';

  @override
  String get mapCredits => 'Заслуге за мапе';

  @override
  String get mapCreditsContent =>
      'Признајемо доприносе пројеката попут Open Street Map у пружању скалабилних података о мапама.';

  @override
  String lastUpdated(Object date) {
    return 'Последње ажурирано $date';
  }

  @override
  String get termsContent =>
      'Добродошли у Водич Кроз Ваљево, мобилну апликацију коју је развила и одржава Анђелка Џида („ми“, „нас“ или „наш“). Преузимањем, приступањем или коришћењем наше мобилне апликације, слажете се да будете везани овим Условима коришћења („Услови“). Ако се не слажете са овим Условима, молимо вас да не користите нашу апликацију.';

  @override
  String get acceptanceTerms => 'Прихватање Услова';

  @override
  String get acceptanceTermsContent =>
      'Слажете се да приступањем или коришћењем наше апликације прихватате ове Услове и нашу Политику приватности.';

  @override
  String get termsChanges => 'Промене Услова коришћења';

  @override
  String get termsChangesContent =>
      'Задржавамо право да у било ком тренутку изменимо ове Услове. Ваше континуирано коришћење апликације након промена указује на ваше прихватање нових Услова.';

  @override
  String get privacyContent =>
      'Наша Политика приватности описује како поступамо с информацијама које нам пружате када користите нашу апликацију. Коришћењем наше апликације слажете се са прикупљањем и коришћењем информација у складу са нашом Политиком приватности.';

  @override
  String get userConduct => 'Понашање Корисника';

  @override
  String get userConductContent =>
      'Слажете се да нећете учествовати у било ком понашању које је незаконито, крши права других или је на други начин неприхватљиво.';

  @override
  String get intellectualProperty => 'Интелектуална Својина';

  @override
  String get intellectualPropertyContent =>
      'Апликација и њен оригинални садржај, функције и функционалности су и остаће ексклузивна својина Анђелке Џиде и њених лиценцодаваца.';

  @override
  String get userGen => 'Садржај Генерисан од Стране Корисника';

  @override
  String get userGenContent =>
      'Можда ћете моћи да доставите садржај путем апликације. Задржавате сва права на свој садржај, али нам дајете неексклузивну, бесплатну лиценцу да користимо, репродукујемо, модификујемо и приказујемо ваш садржај у вези са апликацијом.';

  @override
  String get thirdPartServices => 'Линкови и Услуге Трећих Страна';

  @override
  String get thirdPartServicesContent =>
      'Наша апликација може садржати линкове ка веб-сајтовима или услугама трећих страна које нису у нашем власништву или под нашом контролом. Нисмо одговорни за садржај, политике приватности или праксе било ког веб-сајта или услуге трећих страна.';

  @override
  String get appChanges => 'Промене наше Апликације';

  @override
  String get appChangesContent =>
      'Задржавамо право да модификујемо, трајно или привремено, прекинемо апликацију или било коју услугу на коју се повезује, са или без обавештења и одговорности према вама.';

  @override
  String get contactUs => 'Контактирајте нас';

  @override
  String get contactUsContent =>
      'Ако имате било каквих питања у вези са овим Условима, молимо вас да нас контактирате на ';
}

/// The translations for Serbian, using the Latin script (`sr_Latn`).
class AppLocalizationsSrLatn extends AppLocalizationsSr {
  AppLocalizationsSrLatn() : super('sr_Latn');

  @override
  String get appTitle => 'Vodič kroz Valjevo';

  @override
  String get homePage => 'Početna';

  @override
  String get aboutCity => 'O gradu';

  @override
  String get sights => 'Znamenitosti';

  @override
  String sightName(Object name) {
    return 'Naziv znamenitost: $name';
  }

  @override
  String get sportRecreation => 'Sport i rekreacija';

  @override
  String get restaurantsAndHotels => 'Restorani i prenoćište';

  @override
  String get hotels => 'Hoteli';

  @override
  String get close => 'Zatvori';

  @override
  String get serbian => 'Srpski (Latinica)';

  @override
  String get serbianCyrl => 'Srpski (Ćirilica)';

  @override
  String get english => 'Engleski';

  @override
  String get german => 'Nemački';

  @override
  String get museum => 'Muzej';

  @override
  String get languageMenu => 'Meni za izbor jezika';

  @override
  String get startNavigation => 'Pokrenite navigaciju';

  @override
  String get tapToNavigateToPark => 'Dodirnite da biste navigirali do parka.';

  @override
  String get tapToNavigateToSportField =>
      'Dodirnite da biste navigirali do sportskog terena.';

  @override
  String get tapToNavigateToRestaurant =>
      'Dodirnite da biste navigirali do restorana.';

  @override
  String get tapToNavigateToHotel => 'Dodirnite da biste navigirali do hotela.';

  @override
  String get tapToNavigateToSight =>
      'Dodirnite da biste navigirali do znamenitosti.';

  @override
  String get settings => 'Podešavanja';

  @override
  String get openSettings => 'Otvorite podešavanja';

  @override
  String get connectionProblem =>
      'Zahtev nije moguće izvršiti. Proverite internet vezu i pokušajte ponovo.';

  @override
  String get networkSettingsHint =>
      'Uključite Wi-Fi ili mobilne podatke u podešavanjima uređaja.';

  @override
  String get networkSettingsIosHint =>
      'Uključite Wi-Fi ili mobilne podatke u Podešavanjima ili Kontrolnom centru.';

  @override
  String get networkSettingsFailed =>
      'Nije moguće otvoriti podešavanja uređaja.';

  @override
  String get retryConnection => 'Pokušaj ponovo';

  @override
  String image(Object name) {
    return 'Slika $name';
  }

  @override
  String get loading => 'Učitavanje podataka, molimo sačekajte...';

  @override
  String get errorLoadingData =>
      'Došlo je do greške prilikom učitavanja podataka.';

  @override
  String get noDataAvailable => 'Podaci nisu dostupni!';

  @override
  String get tapToHearSightDetails => 'Pročitaj detalje o znamenitosti';

  @override
  String get tapToHearParkDetails => 'Pročitaj detalje o parku';

  @override
  String get tapToHearSportDetails => 'Pročitaj detalje o sportskom terenu';

  @override
  String get tapToViewPark => 'Dodirnite da vidite detalje parka.';

  @override
  String get tapToViewSport => 'Dodirnite da vidite detalje sportskog terena.';

  @override
  String get tapToHearLegend => 'Pročitaj legendu o gradu';

  @override
  String get tapToHearHistory => 'Pročitaj istoriju grada';

  @override
  String readCityFact(String fact) {
    return 'Naglas pročitaj: $fact';
  }

  @override
  String tapToSeeSightDetails(Object name) {
    return 'Da biste videli više informacija o znamenitosti pod imenom $name, jednostavno dodirnite.';
  }

  @override
  String get legendOfTheCity => 'Legende o imenu grada';

  @override
  String starCount(num numberOfStars) {
    String _temp0 = intl.Intl.pluralLogic(
      numberOfStars,
      locale: localeName,
      other: '$numberOfStars zvezdice',
      one: '1 zvezdica',
    );
    return '$_temp0';
  }

  @override
  String get closeDialog => 'Zatvori dijalog';

  @override
  String get details => 'Detalji';

  @override
  String get hotelImage => 'Slika hotela';

  @override
  String get hotelName => 'Naziv hotela: ';

  @override
  String get restaurants => 'Restorani';

  @override
  String get restaurantName => 'Naziv restorana: ';

  @override
  String get restaurantImage => 'Slika restorana';

  @override
  String get sportFields => 'Sportski tereni';

  @override
  String get parks => 'Parkovi';

  @override
  String get valjevoCityImage => 'Slika grada Valjeva';

  @override
  String get chooseLanguage => 'Izaberite jezik';

  @override
  String get menu => 'Meni';

  @override
  String get getStarted => 'Počni';

  @override
  String get mapPage => 'Mapa grada';

  @override
  String get map => 'Mapa grada Valjeva';

  @override
  String get mapView => 'Prikaz mape';

  @override
  String get listView => 'Prikaz liste';

  @override
  String get previousItem => 'Prethodna stavka';

  @override
  String get nextItem => 'Sledeća stavka';

  @override
  String get previousPhoto => 'Prethodna fotografija';

  @override
  String get nextPhoto => 'Sledeća fotografija';

  @override
  String get zoomIn => 'Uvećaj';

  @override
  String get zoomOut => 'Umanji';

  @override
  String get resetZoom => 'Vrati uvećanje';

  @override
  String get movePhotoUp => 'Pomeri fotografiju nagore';

  @override
  String get movePhotoDown => 'Pomeri fotografiju nadole';

  @override
  String get movePhotoLeft => 'Pomeri fotografiju nalevo';

  @override
  String get movePhotoRight => 'Pomeri fotografiju nadesno';

  @override
  String get moveMapUp => 'Pomeri mapu nagore';

  @override
  String get moveMapDown => 'Pomeri mapu nadole';

  @override
  String get moveMapLeft => 'Pomeri mapu nalevo';

  @override
  String get moveMapRight => 'Pomeri mapu nadesno';

  @override
  String get resetMap => 'Vrati mapu';

  @override
  String get stopReading => 'Zaustavi čitanje';

  @override
  String get speechUnavailable =>
      'Čitanje nije dostupno. Proverite podešavanja govora na uređaju.';

  @override
  String get retryImage => 'Pokušaj ponovo da učitaš sliku';

  @override
  String positionInList(int current, int total) {
    return '$current od $total';
  }

  @override
  String get website => 'Veb-sajt';

  @override
  String menuItem(Object item) {
    return 'Stavka menija: $item';
  }

  @override
  String tapToOpen(Object item) {
    return 'Dodirni da otvoriš $item';
  }

  @override
  String imageOfSight(Object name) {
    return 'Slika znamenitosti $name';
  }

  @override
  String get tapToHearSightName => 'Dodirnite da biste čuli naziv znamenitosti';

  @override
  String get historyOfTheCity => 'Istorija grada';

  @override
  String get song =>
      'Kad dođes u bilo koji grad\n\nA u bilo koji grad se dolazi vrlo kasno\n\nKad dođes vrlo kasno u bilo koji grad\n\nAko taj grad slučajno bude Valjevo...';

  @override
  String get bugReport => 'Formular za prijavu grešaka';

  @override
  String get bugTitle => 'Naslov greške';

  @override
  String get bugDescription => 'Opis greške';

  @override
  String get operatingSystem => 'Operativni sistem';

  @override
  String get selectOS => 'Molimo vas da odaberete operativni sistem';

  @override
  String get selectOSLabel => 'Pritisnite da izaberete operativni sistem.';

  @override
  String get deviceModel => 'Model uređaja';

  @override
  String get osVersion => 'Verzija operativnog sistema';

  @override
  String get uploadFile => 'Otpremi datoteku';

  @override
  String get submit => 'Pošalji';

  @override
  String get enterDescription => 'Molimo unesite opis problema.';

  @override
  String get enterTitle => 'Molimo unesite naslov problema.';

  @override
  String get submissionFailed => 'Nije uspelo slanje izveštaja o grešci...';

  @override
  String get noFileSelected => 'Nijedna datoteka nije odabrana';

  @override
  String get bugTitleLabel => 'Polje za unos naslova greške';

  @override
  String get bugDescriptionLabel => 'Polje za unos opisa greške';

  @override
  String get osLabel => 'Padajući meni za operativni sistem';

  @override
  String get fileUploadLabel => 'Dugme za otpremanje datoteke';

  @override
  String changeLanguageLabel(Object lang) {
    return 'Promeni jezik na $lang';
  }

  @override
  String selectLanguageLabel(Object lang) {
    return 'Izaberite $lang';
  }

  @override
  String get bugReportSent => 'Izveštaj o grešci uspešno poslat.';

  @override
  String get ok => 'OK';

  @override
  String get photoSource => 'Izvor fotografija';

  @override
  String get copyrightOfImages => 'Autorsko pravo na fotografije';

  @override
  String get noInternetConnection => 'Nema internet konekcije!';

  @override
  String get aboutApp => 'O aplikaciji';

  @override
  String get appAuthor => '© 2026 Anđelka Džida';

  @override
  String get appLogo => 'Logo aplikacije';

  @override
  String get aboutAppLocalization =>
      'Lokalizacija: Naša aplikacija je dizajnirana za globalnu dostupnost, nudeći višejezičnu podršku koja obuhvata engleski, nemački i srpski jezik, uključujući i latinično i ćirilično pismo.';

  @override
  String get aboutAppAccessibility =>
      'Pristupačnost: Posvećeni smo tome da našu aplikaciju učinimo dostupnom svima, uključujući korisnike sa invaliditetom. Naša aplikacija sadrži funkcije kao što su podrška za čitače ekrana i prilagodljive veličine teksta.';

  @override
  String get aboutAppDescription =>
      'Istražite bez napora sa našom Tour Guide aplikacijom, vašim džepnim stručnjakom za putovanja. Zaronite u suštinu svake destinacije sa detaljnim vodičima za znamenitosti, hotele, restorane, parkove i sportske objekte. Navigacija je jednostavna, a uz bogate narative o vašem okruženju svako putovanje postaje doživljaj za pamćenje. Dizajnirana za pristupačnost, naša aplikacija osigurava besprekorno iskustvo za sve putnike. Krenite na put otkrića i dozvolite nam da vas vodimo do čuda sveta, sve iz dlana vaše ruke.';

  @override
  String get privacyPolicy => 'Politika privatnosti';

  @override
  String buttonFor(Object label) {
    return 'Dugme za $label';
  }

  @override
  String get songAuthor => 'Matija Bećković - \'Kad dođeš u bilo koji grad\'';

  @override
  String get surface => 'Površina';

  @override
  String get elevation => 'Nadmorska visina';

  @override
  String get populationDensity => 'Gustina naseljenosti';

  @override
  String get population => 'Broj stanovnika';

  @override
  String citySurfaceValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString ha';
  }

  @override
  String citySurfaceSpoken(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString hektara';
  }

  @override
  String cityElevationValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString m';
  }

  @override
  String cityElevationSpoken(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString metara';
  }

  @override
  String cityDensityValue(double value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString st./km² ($year.)';
  }

  @override
  String cityDensitySpoken(double value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString stanovnika po kvadratnom kilometru $year. godine';
  }

  @override
  String cityPopulationValue(int value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString ($year.)';
  }

  @override
  String cityPopulationSpoken(int value, int year) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString stanovnika $year. godine';
  }

  @override
  String get district => 'Okrug';

  @override
  String get cityDay => 'Dan grada';

  @override
  String get saint => 'Slava grada';

  @override
  String get kolubaraDistrict => 'Kolubarski okrug';

  @override
  String get saintName => 'Trojice (Duhovi)';

  @override
  String get indicator => 'Indikator';

  @override
  String get openAboutDialog => 'Otvori dijalog o programu.';

  @override
  String get cityDayDate => '20. mart';

  @override
  String get termsOfUse => 'Uslovi korišćenja';

  @override
  String get infoByYou => 'Informacije koje ste pružili';

  @override
  String get infoByYouContent =>
      'Kada stupate u interakciju s nama kontaktiranjem, davanjem povratnih informacija ili popunjavanjem obrazaca, Vodič Kroz Valjevo može sakupiti dodatne podatke kao što su vaša lokacija, detalji o internet konekciji i više.';

  @override
  String get autoCollectedData =>
      'Informacije koje automatski sakuplja Vodič Kroz Valjevo';

  @override
  String get autoCollectedDataContent =>
      'Vodič Kroz Valjevo automatski sakuplja podatke kao što su informacije o uređaju kada koristite naše usluge ili aplikacije.';

  @override
  String get localStorage => 'Napomena o lokalnom skladištenju';

  @override
  String get localStorageContent =>
      'Da bi poboljšao naše usluge i stekao uvid u vaše obrasce interakcije, Vodič Kroz Valjevo koristi tehnologije za lokalno skladištenje. Molimo vas da imate u vidu da se vaše postavke i preferencije čuvaju direktno na vašem uređaju jer ne koristimo kolačiće.';

  @override
  String get useOfInfo => 'Korišćenje informacija';

  @override
  String get useOfInfoContent =>
      'Vodič Kroz Valjevo može koristiti vaše informacije za poboljšanje i pružanje naših usluga, praćenje vaših aktivnosti, komunikaciju sa vama, pružanje podrške korisnicima i osiguranje sigurnosti naših uslova i pravila.';

  @override
  String get thirdParty => 'Pristup trećih strana vašim informacijama';

  @override
  String get thirdPartyContent =>
      'Vaši podaci mogu biti podeljeni sa trećim stranama iz raznih razloga, uključujući, ali ne ograničavajući se na, saradnju sa pružaocima usluga i pridržavanje zakona, u skladu sa našim uslovima i pravilima.';

  @override
  String get tearmsOfAnd =>
      'Uslovi korišćenja i pravila o privatnosti trećih strana';

  @override
  String get tearmsOfAndContent =>
      'Priznajete da Vodič Kroz Valjevo koristi usluge trećih strana koje mi ne upravljamo niti obezbeđujemo, i vaša je odgovornost da pregledate njihove politike.';

  @override
  String get ongoingAmend => 'Tekuće izmene';

  @override
  String get ongoingAmendContent =>
      'Vodič Kroz Valjevo zadržava pravo da menja ovu politiku privatnosti, pri čemu izmene stupaju na snagu odmah po objavljivanju. Nastavkom korišćenja naše usluge nakon izmene, prihvatate te izmene.';

  @override
  String get contact => 'Kontakt';

  @override
  String get contactContent =>
      'Ako imate pitanja ili zabrinutosti u vezi sa ovom politikom privatnosti, molimo vas da nas kontaktirate putem e-pošte.';

  @override
  String get mapCredits => 'Zasluge za mape';

  @override
  String get mapCreditsContent =>
      'Priznajemo doprinose projekata poput Open Street Map u pružanju skalabilnih podataka o mapama.';

  @override
  String lastUpdated(Object date) {
    return 'Poslednje ažurirano $date';
  }

  @override
  String get termsContent =>
      'Dobrodošli u Vodič Kroz Valjevo, mobilnu aplikaciju koju je razvila i održava Anđelka Džida („mi“, „nas“ ili „naš“). Preuzimanjem, pristupanjem ili korišćenjem naše mobilne aplikacije, slažete se da budete vezani ovim Uslovima korišćenja („Uslovi“). Ako se ne slažete sa ovim Uslovima, molimo vas da ne koristite našu aplikaciju.';

  @override
  String get acceptanceTerms => 'Prihvatanje Uslova';

  @override
  String get acceptanceTermsContent =>
      'Slažete se da pristupanjem ili korišćenjem naše aplikacije pristajete na ove Uslove i našu Politiku privatnosti.';

  @override
  String get termsChanges => 'Promene Uslova korišćenja';

  @override
  String get termsChangesContent =>
      'Zadržavamo pravo da u bilo kom trenutku izmenimo ove Uslove. Vaše kontinuirano korišćenje aplikacije nakon promena ukazuje na vaše prihvatanje novih Uslova.';

  @override
  String get privacyContent =>
      'Naša Politika privatnosti opisuje kako postupamo s informacijama koje nam pružate kada koristite našu aplikaciju. Korišćenjem naše aplikacije slažete se sa prikupljanjem i korišćenjem informacija u skladu sa našom Politikom privatnosti.';

  @override
  String get userConduct => 'Ponašanje Korisnika';

  @override
  String get userConductContent =>
      'Slažete se da nećete učestvovati u bilo kom ponašanju koje je nezakonito, krši prava drugih ili je na drugi način neprihvatljivo.';

  @override
  String get intellectualProperty => 'Intelektualna Svojina';

  @override
  String get intellectualPropertyContent =>
      'Aplikacija i njen originalni sadržaj, funkcije i funkcionalnosti su i ostaće ekskluzivna svojina Anđelke Džide i njenih licencodavaca.';

  @override
  String get userGen => 'Sadržaj Generisan od Strane Korisnika';

  @override
  String get userGenContent =>
      'Možda ćete moći da dostavite sadržaj putem aplikacije. Zadržavate sva prava na svoj sadržaj, ali nam dajete neekskluzivnu, besplatnu licencu da koristimo, reprodukujemo, modifikujemo i prikazujemo vaš sadržaj u vezi sa aplikacijom.';

  @override
  String get thirdPartServices => 'Linkovi i Usluge Trećih Strana';

  @override
  String get thirdPartServicesContent =>
      'Naša aplikacija može sadržati linkove ka veb-sajtovima ili uslugama trećih strana koje nisu u našem vlasništvu ili pod našom kontrolom. Nismo odgovorni za sadržaj, politike privatnosti ili prakse bilo kog veb-sajta ili usluge trećih strana.';

  @override
  String get appChanges => 'Promene naše Aplikacije';

  @override
  String get appChangesContent =>
      'Zadržavamo pravo da modifikujemo, trajno ili privremeno prekinemo aplikaciju ili bilo koju uslugu na koju se povezuje, sa ili bez obaveštenja i bez odgovornosti prema vama.';

  @override
  String get contactUs => 'Kontaktirajte Nas';

  @override
  String get contactUsContent =>
      'Ako imate bilo kakvih pitanja o ovim Uslovima, molimo vas da nas kontaktirate na ';
}
