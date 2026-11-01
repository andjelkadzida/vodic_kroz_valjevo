// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Valjevo tour guide';

  @override
  String get homePage => 'Home';

  @override
  String get aboutCity => 'About the city';

  @override
  String get sights => 'Sights';

  @override
  String sightName(Object name) {
    return 'Name of the sight: $name';
  }

  @override
  String get sportRecreation => 'Sport & recreation';

  @override
  String get restaurantsAndHotels => 'Hotels & restaurants';

  @override
  String get hotels => 'Hotels';

  @override
  String get close => 'Close';

  @override
  String get serbian => 'Serbian (Latin)';

  @override
  String get serbianCyrl => 'Serbian (Cyrillic)';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get museum => 'Museum';

  @override
  String get languageMenu => 'Language menu';

  @override
  String get startNavigation => 'Start navigation';

  @override
  String get tapToNavigateToPark => 'Tap to navigate to the park.';

  @override
  String get tapToNavigateToSportField =>
      'Tap to navigate to the sports field.';

  @override
  String get tapToNavigateToRestaurant => 'Tap to navigate to the restaurant.';

  @override
  String get tapToNavigateToHotel => 'Tap to navigate to the hotel.';

  @override
  String get tapToNavigateToSight => 'Tap to navigate to the sight.';

  @override
  String get settings => 'Settings';

  @override
  String get openSettings => 'Open Settings';

  @override
  String image(Object name) {
    return 'Image of $name';
  }

  @override
  String get loading => 'Loading data, please wait...';

  @override
  String get errorLoadingData => 'Error occured during loading data.';

  @override
  String get noDataAvailable => 'No data available!';

  @override
  String get tapToHearSightDetails =>
      'Tap to hear details about the sight. Tap twice to stop.';

  @override
  String get tapToHearParkDetails =>
      'Tap to hear details about the park. Tap twice to stop.';

  @override
  String get tapToHearSportDetails =>
      'Tap to hear details about the sport field. Tap twice to stop.';

  @override
  String get tapToViewPark => 'Tap to view park\'s details.';

  @override
  String get tapToViewSport => 'Tap to view sport field\'s details.';

  @override
  String get tapToHearLegend =>
      'Tap to hear the legend of the city name. Tap twice to stop.';

  @override
  String get tapToHearHistory =>
      'Tap to hear the city\'s history. Tap twice to stop.';

  @override
  String tapToSeeSightDetails(Object name) {
    return 'To view further information regarding the sight named $name, simply tap on it.';
  }

  @override
  String get legendOfTheCity => 'Legends about the name of the city';

  @override
  String starCount(num numberOfStars) {
    String _temp0 = intl.Intl.pluralLogic(
      numberOfStars,
      locale: localeName,
      other: '$numberOfStars stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get closeDialog => 'Close dialog';

  @override
  String get details => 'Details';

  @override
  String get hotelImage => 'Hotel image';

  @override
  String get hotelName => 'Hotel name: ';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get restaurantName => 'Restaurant name: ';

  @override
  String get restaurantImage => 'Restaurant image';

  @override
  String get sportFields => 'Sport fields';

  @override
  String get parks => 'Parks';

  @override
  String get valjevoCityImage => 'Image of the city of Valjevo';

  @override
  String get chooseLanguage => 'Select language';

  @override
  String get menu => 'Menu';

  @override
  String get getStarted => 'Get Started';

  @override
  String get mapPage => 'City map';

  @override
  String get map => 'Map of the city of Valjevo';

  @override
  String get website => 'Website';

  @override
  String menuItem(Object item) {
    return 'Menu Item: $item';
  }

  @override
  String tapToOpen(Object item) {
    return 'Tap to open $item';
  }

  @override
  String imageOfSight(Object name) {
    return 'Image of sight $name';
  }

  @override
  String get tapToHearSightName => 'Touch to hear the name of the sight';

  @override
  String get historyOfTheCity => 'City History';

  @override
  String get song =>
      'When you come to any city\n\nAnd one comes to any ctiy very late\n\nWhen you come very late to any city\n\nIn case that city happens to be Valjevo...';

  @override
  String get bugReport => 'Bug Report Form';

  @override
  String get bugTitle => 'Bug Title';

  @override
  String get bugDescription => 'Bug Description';

  @override
  String get operatingSystem => 'Operating System';

  @override
  String get selectOS => 'Please select an operating system';

  @override
  String get selectOSLabel => 'Press to select the operating system.';

  @override
  String get deviceModel => 'Device Model';

  @override
  String get osVersion => 'Operating System Version';

  @override
  String get uploadFile => 'Upload File';

  @override
  String get submit => 'Submit';

  @override
  String get enterDescription => 'Please enter a description of the issue.';

  @override
  String get enterTitle => 'Please enter a title for the issue.';

  @override
  String get submissionFailed => 'Failed to submit bug report...';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get bugTitleLabel => 'Bug title input field';

  @override
  String get bugDescriptionLabel => 'Bug description input field';

  @override
  String get osLabel => 'Operating system dropdown';

  @override
  String get fileUploadLabel => 'File upload button';

  @override
  String changeLanguageLabel(Object lang) {
    return 'Change language to $lang';
  }

  @override
  String selectLanguageLabel(Object lang) {
    return 'Select $lang';
  }

  @override
  String get bugReportSent => 'Bug report successfully sent.';

  @override
  String get ok => 'OK';

  @override
  String get photoSource => 'Source of the photos';

  @override
  String get copyrightOfImages => 'Copyright of the photos';

  @override
  String get noInternetConnection => 'No Internet Connection!';

  @override
  String get aboutApp => 'About the application';

  @override
  String get appAuthor => '© 2024 Andjelka Dzida';

  @override
  String get appLogo => 'Application Logo';

  @override
  String get aboutAppLocalization =>
      'Localization: Our application is designed for global accessibility, offering multilingual support that encompasses English, German, and Serbian, inclusive of both Latin and Cyrillic scripts.';

  @override
  String get aboutAppAccessibility =>
      'Accessibility: We are committed to ensuring our app is accessible to everyone, including users with disabilities. Our app includes features such as screen reader support, adjustable text sizes.';

  @override
  String get aboutAppDescription =>
      'Explore effortlessly with our Tour Guide App, your pocket-sized travel expert. Dive into the essence of each destination with detailed guides on sights, hotels, restaurants, parks, and sports facilities. Navigate with ease and listen to rich narratives about your surroundings, making every journey an immersive experience. Designed for accessibility, our app ensures a seamless experience for all travelers. Embark on a journey of discovery and let us guide you to the wonders of the world, all from the palm of your hand';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String buttonFor(Object label) {
    return 'Button for $label';
  }

  @override
  String get songAuthor => 'Matija Bećković - \'When You Come to Any City\'';

  @override
  String get surface => 'Surface';

  @override
  String get elevation => 'Elevation above sea level';

  @override
  String get populationDensity => 'Population density';

  @override
  String get population => 'Population';

  @override
  String get district => 'District';

  @override
  String get cityDay => 'City Day';

  @override
  String get saint => 'City Patron Saint Day';

  @override
  String get kolubaraDistrict => 'Kolubara District';

  @override
  String get saintName => 'Trojice (Duhovi)';

  @override
  String get indicator => 'Indicator';

  @override
  String get openAboutDialog => 'Open about dialog.';

  @override
  String get cityDayDate => '20. March';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get infoByYou => 'Information Provided by You';

  @override
  String get infoByYouContent =>
      'When you interact with us by contacting us, providing feedback, or completing forms, Vodič Kroz Valjevo may gather additional data like your location, internet connectivity details, and more.';

  @override
  String get autoCollectedData =>
      'Information Collected Automatically By Vodič Kroz Valjevo';

  @override
  String get autoCollectedDataContent =>
      'Vodič Kroz Valjevo automatically collects data such as your device information when you utilize our Services or Apps.';

  @override
  String get localStorage => 'Local Storage Notice';

  @override
  String get localStorageContent =>
      'To enhance our services and gain insights into your interaction patterns, Vodič Kroz Valjevo utilizes local storage technology. Please note that your settings and preferences are stored directly on your device, as we do not use cookies.';

  @override
  String get useOfInfo => 'Use of Information';

  @override
  String get useOfInfoContent =>
      'Vodič Kroz Valjevo may utilize your information to enhance and provide our Services, monitor your activities, communicate with you, offer customer support, and ensure the security of our Terms and Policy.';

  @override
  String get thirdParty => 'Third-Party Access to Your Information';

  @override
  String get thirdPartyContent =>
      'Your data may be shared with third parties as outlined in our Terms and Policy for various reasons, including but not limited to, collaboration with service providers and legal compliance.';

  @override
  String get tearmsOfAnd => 'Terms of Use and Privacy Policy of Third Parties';

  @override
  String get tearmsOfAndContent =>
      'You acknowledge that Vodič Kroz Valjevo utilizes third-party services, which we do not manage or secure, and it\'s your responsibility to review their policies.';

  @override
  String get ongoingAmend => 'Ongoing Amendments';

  @override
  String get ongoingAmendContent =>
      'Vodič Kroz Valjevo reserves the right to modify this Privacy Policy, with changes taking immediate effect upon posting. Continuous use of our Service post-modification implies your agreement to the amendments.';

  @override
  String get contact => 'Contact';

  @override
  String get contactContent =>
      'For any inquiries or concerns regarding this Privacy Policy, please reach out to us via email.';

  @override
  String get mapCredits => 'Map Credits';

  @override
  String get mapCreditsContent =>
      'We acknowledge the contributions of projects like Open Street Map in providing scalable map data.';

  @override
  String lastUpdated(Object date) {
    return 'Last Updated $date';
  }

  @override
  String get termsContent =>
      'Welcome to Vodic Kroz Valjevo, a mobile application developed and maintained by Andjelka Dzida (\'we\', \'us\', or \'our\'). By downloading, accessing, or using our mobile application, you agree to be bound by these Terms of Service (\'Terms\'). If you do not agree to these Terms, please do not use our application.';

  @override
  String get acceptanceTerms => 'Acceptance of Terms';

  @override
  String get acceptanceTermsContent =>
      'You agree that by accessing or using our app, you are agreeing to these Terms and our Privacy Policy.';

  @override
  String get termsChanges => 'Changes to Terms of Service';

  @override
  String get termsChangesContent =>
      'We reserve the right to modify these Terms at any time. Your continued use of the app following any changes indicates your acceptance of the new Terms.';

  @override
  String get privacyContent =>
      'Our Privacy Policy describes how we handle the information you provide to us when you use our app. By using our app, you agree to the collection and use of information in accordance with our Privacy Policy.';

  @override
  String get userConduct => 'User Conduct';

  @override
  String get userConductContent =>
      'You agree not to engage in any conduct that is unlawful, infringes on the rights of others, or is otherwise objectionable.';

  @override
  String get intellectualProperty => 'Intellectual Property';

  @override
  String get intellectualPropertyContent =>
      'The app and its original content, features, and functionality are and will remain the exclusive property of Andjelka Dzida and its licensors.';

  @override
  String get userGen => 'User-Generated Content';

  @override
  String get userGenContent =>
      'You may be able to submit content through the app. You retain all rights to your content, but you grant us a non-exclusive, royalty-free license to use, reproduce, modify, and display your content in connection with the app.';

  @override
  String get thirdPartServices => 'Third-Party Links and Services';

  @override
  String get thirdPartServicesContent =>
      'Our app may contain links to third-party websites or services that are not owned or controlled by us. We are not responsible for the content, privacy policies, or practices of any third-party websites or services.';

  @override
  String get appChanges => 'Changes to Our App';

  @override
  String get appChangesContent =>
      'We reserve the right to modify or discontinue, temporarily or permanently, the app or any service to which it connects, with or without notice and without liability to you.';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsContent =>
      'If you have any questions about these Terms, please contact us at ';
}
