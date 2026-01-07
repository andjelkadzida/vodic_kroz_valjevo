// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Valjevo Reiseleiter';

  @override
  String get homePage => 'Startseite';

  @override
  String get aboutCity => 'Über Stadt';

  @override
  String get sights => 'Sehenswürdigkeiten';

  @override
  String sightName(Object name) {
    return 'Name der Sehenswürdigkeit: $name';
  }

  @override
  String get sportRecreation => 'Sport & Erholung';

  @override
  String get restaurantsAndHotels => 'Hotels & Gaststätten';

  @override
  String get hotels => 'Hotels';

  @override
  String get close => 'Schließen';

  @override
  String get serbian => 'Serbisch (Latein)';

  @override
  String get serbianCyrl => 'Serbisch (Kyrillisch)';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get museum => 'Museum';

  @override
  String get languageMenu => 'Sprachmenü';

  @override
  String get startNavigation => 'Navigation starten';

  @override
  String get tapToNavigateToPark =>
      'Tippen Sie hier, um zum Park zu navigieren.';

  @override
  String get tapToNavigateToSportField =>
      'Tippen Sie hier, um zum Sportplatz zu navigieren.';

  @override
  String get tapToNavigateToRestaurant =>
      'Tippen Sie hier, um zum Restaurant zu navigieren.';

  @override
  String get tapToNavigateToHotel =>
      'Tippen Sie hier, um zum Hotel zu navigieren.';

  @override
  String get tapToNavigateToSight =>
      'Tippen Sie hier, um zur Sehenswürdigkeit zu navigieren.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String image(Object name) {
    return 'Build von $name';
  }

  @override
  String get loading => 'Daten werden geladen, bitte warten...';

  @override
  String get errorLoadingData => 'Fehler beim Laden der Daten aufgetreten.';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar!';

  @override
  String get tapToHearSightDetails =>
      'Tippen Sie, um Details über die Sehenswürdigkeit zu hören. Tippen Sie zweimal, um zu stoppen.';

  @override
  String get tapToHearParkDetails =>
      'Tippen, um Details über den Park zu hören. Zweimal tippen, um anzuhalten.';

  @override
  String get tapToHearSportDetails =>
      'Tippen, um Details über das Sportfeld zu hören. Zweimal tippen, um anzuhalten.';

  @override
  String get tapToViewPark => 'Tippen, um Details zum Park anzuzeigen.';

  @override
  String get tapToViewSport => 'Tippen, um Details zum Sportfeld anzuzeigen.';

  @override
  String get tapToHearLegend =>
      'Tippen Sie, um die Legende des Stadtnamens zu hören. Tippen Sie zweimal, um zu stoppen.';

  @override
  String get tapToHearHistory =>
      'Tippen Sie, um die Stadtgeschichte zu hören. Tippen Sie zweimal, um zu stoppen.';

  @override
  String tapToSeeSightDetails(Object name) {
    return 'Um weitere Informationen zu der Sehenswürdigkeit namens $name zu sehen, tippen Sie einfach darauf.';
  }

  @override
  String get legendOfTheCity => 'Legenden über den Namen der Stadt';

  @override
  String starCount(num numberOfStars) {
    String _temp0 = intl.Intl.pluralLogic(
      numberOfStars,
      locale: localeName,
      other: '$numberOfStars Sterne',
      one: '1 Stern',
    );
    return '$_temp0';
  }

  @override
  String get closeDialog => 'Dialog schließen';

  @override
  String get details => 'Details';

  @override
  String get hotelImage => 'Hotelbild';

  @override
  String get hotelName => 'Hotelname: ';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get restaurantName => 'Restaurantname: ';

  @override
  String get restaurantImage => 'Restaurantbuild';

  @override
  String get sportFields => 'Sportplätze';

  @override
  String get parks => 'Parks';

  @override
  String get valjevoCityImage => 'Bild der Stadt Valjevo';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get menu => 'Menü';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get mapPage => 'Stadtkarte';

  @override
  String get map => 'Stadtplan von Valjevo';

  @override
  String get website => 'Webseite';

  @override
  String menuItem(Object item) {
    return 'Menüpunkt: $item';
  }

  @override
  String tapToOpen(Object item) {
    return 'Tippen, um zu öffnen $item';
  }

  @override
  String imageOfSight(Object name) {
    return 'Bild der Sehenswürdigkeit $name';
  }

  @override
  String get tapToHearSightName =>
      'Berühren, um den Namen der Sehenswürdigkeit zu hören';

  @override
  String get historyOfTheCity => 'Stadtgeschichte';

  @override
  String get song =>
      'Wenn du in irgendeine Stadt kommst\n\nUnd in irgendeine Stadt kommt man sehr spät\n\nWenn du sehr spät in irgendeine Stadt kommst\n\nWenn diese Stadt zufällig Valjevo ist...';

  @override
  String get bugReport => 'Fehlerberichtsformular';

  @override
  String get bugTitle => 'Fehlerbezeichnung';

  @override
  String get bugDescription => 'Fehlerbeschreibung';

  @override
  String get operatingSystem => 'Betriebssystem';

  @override
  String get selectOS => 'Bitte wählen Sie ein Betriebssystem aus.';

  @override
  String get selectOSLabel => 'Drücken Sie, um das Betriebssystem auszuwählen.';

  @override
  String get deviceModel => 'Gerätemodell';

  @override
  String get osVersion => 'Betriebssystemversion';

  @override
  String get uploadFile => 'Datei hochladen';

  @override
  String get submit => 'Einreichen';

  @override
  String get enterDescription =>
      'Bitte geben Sie eine Beschreibung des Problems ein.';

  @override
  String get enterTitle => 'Bitte geben Sie einen Titel für das Problem ein.';

  @override
  String get submissionFailed => 'Fehler beim Einreichen des Fehlerberichts...';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt';

  @override
  String get bugTitleLabel => 'Eingabefeld für Fehlertitel';

  @override
  String get bugDescriptionLabel => 'Eingabefeld für Fehlerbeschreibung';

  @override
  String get osLabel => 'Betriebssystem-Dropdown';

  @override
  String get fileUploadLabel => 'Datei-Upload-Button';

  @override
  String changeLanguageLabel(Object lang) {
    return 'Sprache ändern in $lang';
  }

  @override
  String selectLanguageLabel(Object lang) {
    return 'Wähle $lang';
  }

  @override
  String get bugReportSent => 'Fehlerbericht erfolgreich gesendet.';

  @override
  String get ok => 'OK';

  @override
  String get photoSource => 'Quelle der Fotos';

  @override
  String get copyrightOfImages => 'Urheberrecht der Fotos';

  @override
  String get noInternetConnection => 'Keine Internetverbindung!';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get appAuthor => '© 2024 Andjelka Dzida';

  @override
  String get appLogo => 'Anwendungslogo';

  @override
  String get aboutAppLocalization =>
      'Lokalisierung: Unsere Anwendung ist für globale Zugänglichkeit konzipiert und bietet mehrsprachige Unterstützung, die Englisch, Deutsch und Serbisch umfasst, einschließlich der lateinischen und kyrillischen Schriftsysteme.';

  @override
  String get aboutAppAccessibility =>
      'Zugänglichkeit: Wir setzen uns dafür ein, unsere App für jeden zugänglich zu machen, einschließlich Nutzern mit Behinderungen. Unsere App beinhaltet Funktionen wie Screenreader-Unterstützung und anpassbare Textgrößen.';

  @override
  String get aboutAppDescription =>
      'Erkunden Sie mühelos mit unserer Tour Guide App, Ihrem Taschenreiseexperten. Tauchen Sie ein in das Wesen jedes Ziels mit detaillierten Führern zu Sehenswürdigkeiten, Hotels, Restaurants, Parks und Sportanlagen. Navigieren Sie mit Leichtigkeit und hören Sie sich reiche Erzählungen über Ihre Umgebung an, die jede Reise zu einem immersiven Erlebnis machen. Unsere App ist für Barrierefreiheit konzipiert und gewährleistet ein nahtloses Erlebnis für alle Reisenden. Begeben Sie sich auf eine Entdeckungsreise und lassen Sie sich von uns zu den Wundern der Welt führen, alles aus der Handfläche.';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String buttonFor(Object label) {
    return 'Taste für $label';
  }

  @override
  String get songAuthor =>
      'Matija Bećković - \'Wenn du in eine beliebige Stadt kommst\'';

  @override
  String get surface => 'Fläche';

  @override
  String get elevation => 'Höhe über dem Meeresspiegel';

  @override
  String get populationDensity => 'Bevölkerungsdichte';

  @override
  String get population => 'Bevölkerung';

  @override
  String get district => 'Bezirk';

  @override
  String get cityDay => 'Stadttag';

  @override
  String get saint => 'Stadt Schutzpatron Tag';

  @override
  String get kolubaraDistrict => 'Kolubara Bezirk';

  @override
  String get saintName => 'Trojice (Duhovi)';

  @override
  String get indicator => 'Anzeige';

  @override
  String get openAboutDialog => 'Öffnen Sie den Info-Dialog.';

  @override
  String get cityDayDate => '20. März';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get infoByYou => 'Von Ihnen bereitgestellte Informationen';

  @override
  String get infoByYouContent =>
      'Wenn Sie mit uns interagieren, indem Sie uns kontaktieren, Feedback geben oder Formulare ausfüllen, kann Vodič Kroz Valjevo zusätzliche Daten wie Ihren Standort, Internetverbindungsdetails und mehr sammeln.';

  @override
  String get autoCollectedData =>
      'Automatisch von Vodič Kroz Valjevo gesammelte Informationen';

  @override
  String get autoCollectedDataContent =>
      'Vodič Kroz Valjevo sammelt automatisch Daten wie Ihre Geräteinformationen, wenn Sie unsere Dienste oder Apps nutzen.';

  @override
  String get localStorage => 'Hinweis zum lokalen Speicher';

  @override
  String get localStorageContent =>
      'Um unsere Dienste zu verbessern und Einblicke in Ihre Interaktionsmuster zu gewinnen, verwendet Vodič Kroz Valjevo Technologien für lokalen Speicher. Bitte beachten Sie, dass Ihre Einstellungen und Präferenzen direkt auf Ihrem Gerät gespeichert werden, da wir keine Cookies verwenden.';

  @override
  String get useOfInfo => 'Nutzung der Informationen';

  @override
  String get useOfInfoContent =>
      'Vodič Kroz Valjevo kann Ihre Informationen nutzen, um unsere Dienste zu verbessern und bereitzustellen, Ihre Aktivitäten zu überwachen, mit Ihnen zu kommunizieren, Kundenunterstützung anzubieten und die Sicherheit unserer Bedingungen und Richtlinien zu gewährleisten.';

  @override
  String get thirdParty => 'Zugriff Dritter auf Ihre Informationen';

  @override
  String get thirdPartyContent =>
      'Ihre Daten können aus verschiedenen Gründen, einschließlich, aber nicht beschränkt auf, Zusammenarbeit mit Dienstleistern und rechtliche Einhaltung, gemäß unseren Bedingungen und Richtlinien mit Dritten geteilt werden.';

  @override
  String get tearmsOfAnd =>
      'Nutzungsbedingungen und Datenschutzrichtlinien Dritter';

  @override
  String get tearmsOfAndContent =>
      'Sie erkennen an, dass Vodič Kroz Valjevo Dienste Dritter nutzt, die wir nicht verwalten oder sichern, und es liegt in Ihrer Verantwortung, deren Richtlinien zu überprüfen.';

  @override
  String get ongoingAmend => 'Laufende Änderungen';

  @override
  String get ongoingAmendContent =>
      'Vodič Kroz Valjevo behält sich das Recht vor, diese Datenschutzrichtlinie zu ändern, wobei Änderungen sofort nach der Veröffentlichung in Kraft treten. Die fortgesetzte Nutzung unseres Dienstes nach einer Änderung impliziert Ihre Zustimmung zu den Änderungen.';

  @override
  String get contact => 'Kontakt';

  @override
  String get contactContent =>
      'Bei Fragen oder Bedenken bezüglich dieser Datenschutzrichtlinie wenden Sie sich bitte per E-Mail an uns.';

  @override
  String get mapCredits => 'Kartencredits';

  @override
  String get mapCreditsContent =>
      'Wir erkennen die Beiträge von Projekten wie Open Street Map bei der Bereitstellung skalierbarer Kartendaten an.';

  @override
  String lastUpdated(Object date) {
    return 'Zuletzt aktualisiert am $date';
  }

  @override
  String get termsContent =>
      'Willkommen bei Vodic Kroz Valjevo, einer mobilen Anwendung, die von Andjelka Dzida entwickelt und gepflegt wird („wir“, „uns“ oder „unser“). Durch das Herunterladen, Zugreifen oder Benutzen unserer mobilen Anwendung erklären Sie sich mit diesen Nutzungsbedingungen („Bedingungen“) einverstanden. Wenn Sie diesen Bedingungen nicht zustimmen, verwenden Sie bitte unsere Anwendung nicht.';

  @override
  String get acceptanceTerms => 'Akzeptanz der Bedingungen';

  @override
  String get acceptanceTermsContent =>
      'Sie erklären sich damit einverstanden, dass Sie durch den Zugriff auf oder die Nutzung unserer App diesen Bedingungen und unserer Datenschutzrichtlinie zustimmen.';

  @override
  String get termsChanges => 'Änderungen der Nutzungsbedingungen';

  @override
  String get termsChangesContent =>
      'Wir behalten uns das Recht vor, diese Bedingungen jederzeit zu ändern. Ihre fortgesetzte Nutzung der App nach Änderungen bedeutet Ihre Akzeptanz der neuen Bedingungen.';

  @override
  String get privacyContent =>
      'Unsere Datenschutzrichtlinie beschreibt, wie wir die Informationen, die Sie uns bei der Nutzung unserer App zur Verfügung stellen, behandeln. Durch die Nutzung unserer App stimmen Sie der Erfassung und Verwendung von Informationen in Übereinstimmung mit unserer Datenschutzrichtlinie zu.';

  @override
  String get userConduct => 'Benutzerverhalten';

  @override
  String get userConductContent =>
      'Sie erklären sich damit einverstanden, kein rechtswidriges Verhalten zu zeigen, das die Rechte anderer verletzt oder in anderer Weise anstößig ist.';

  @override
  String get intellectualProperty => 'Geistiges Eigentum';

  @override
  String get intellectualPropertyContent =>
      'Die App und ihre ursprünglichen Inhalte, Funktionen und Funktionalitäten sind und bleiben das ausschließliche Eigentum von Andjelka Dzida und seinen Lizenzgebern.';

  @override
  String get userGen => 'Von Benutzern erzeugte Inhalte';

  @override
  String get userGenContent =>
      'Sie können Inhalte über die App einreichen. Sie behalten alle Rechte an Ihren Inhalten, gewähren uns jedoch eine nicht-exklusive, gebührenfreie Lizenz, Ihre Inhalte in Verbindung mit der App zu verwenden, zu reproduzieren, zu ändern und anzuzeigen.';

  @override
  String get thirdPartServices => 'Links und Dienste Dritter';

  @override
  String get thirdPartServicesContent =>
      'Unsere App kann Links zu Websites oder Diensten Dritter enthalten, die nicht uns gehören oder von uns kontrolliert werden. Wir sind nicht verantwortlich für den Inhalt, die Datenschutzrichtlinien oder die Praktiken von Websites oder Diensten Dritter.';

  @override
  String get appChanges => 'Änderungen an unserer App';

  @override
  String get appChangesContent =>
      'Wir behalten uns das Recht vor, die App oder einen Dienst, mit dem sie verbunden ist, zeitweise oder dauerhaft zu ändern oder einzustellen, mit oder ohne Ankündigung und ohne Haftung Ihnen gegenüber.';

  @override
  String get contactUs => 'Kontaktieren Sie uns';

  @override
  String get contactUsContent =>
      'Wenn Sie Fragen zu diesen Bedingungen haben, kontaktieren Sie uns bitte unter ';
}
