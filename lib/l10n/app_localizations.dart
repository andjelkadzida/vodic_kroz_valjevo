import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('sr'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Valjevo tour guide'**
  String get appTitle;

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePage;

  /// No description provided for @aboutCity.
  ///
  /// In en, this message translates to:
  /// **'About the city'**
  String get aboutCity;

  /// No description provided for @sights.
  ///
  /// In en, this message translates to:
  /// **'Sights'**
  String get sights;

  /// No description provided for @sightName.
  ///
  /// In en, this message translates to:
  /// **'Name of the sight: {name}'**
  String sightName(Object name);

  /// No description provided for @sportRecreation.
  ///
  /// In en, this message translates to:
  /// **'Sport & recreation'**
  String get sportRecreation;

  /// No description provided for @restaurantsAndHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels & restaurants'**
  String get restaurantsAndHotels;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @serbian.
  ///
  /// In en, this message translates to:
  /// **'Serbian (Latin)'**
  String get serbian;

  /// No description provided for @serbianCyrl.
  ///
  /// In en, this message translates to:
  /// **'Serbian (Cyrillic)'**
  String get serbianCyrl;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @museum.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get museum;

  /// No description provided for @languageMenu.
  ///
  /// In en, this message translates to:
  /// **'Language menu'**
  String get languageMenu;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start navigation'**
  String get startNavigation;

  /// No description provided for @tapToNavigateToPark.
  ///
  /// In en, this message translates to:
  /// **'Tap to navigate to the park.'**
  String get tapToNavigateToPark;

  /// No description provided for @tapToNavigateToSportField.
  ///
  /// In en, this message translates to:
  /// **'Tap to navigate to the sports field.'**
  String get tapToNavigateToSportField;

  /// No description provided for @tapToNavigateToRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Tap to navigate to the restaurant.'**
  String get tapToNavigateToRestaurant;

  /// No description provided for @tapToNavigateToHotel.
  ///
  /// In en, this message translates to:
  /// **'Tap to navigate to the hotel.'**
  String get tapToNavigateToHotel;

  /// No description provided for @tapToNavigateToSight.
  ///
  /// In en, this message translates to:
  /// **'Tap to navigate to the sight.'**
  String get tapToNavigateToSight;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @connectionProblem.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the request. Check your internet connection and try again.'**
  String get connectionProblem;

  /// No description provided for @networkSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on Wi-Fi or mobile data in your device settings.'**
  String get networkSettingsHint;

  /// No description provided for @networkSettingsIosHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on Wi-Fi or mobile data in Settings or Control Center.'**
  String get networkSettingsIosHint;

  /// No description provided for @networkSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open device settings.'**
  String get networkSettingsFailed;

  /// No description provided for @retryConnection.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryConnection;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image of {name}'**
  String image(Object name);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading data, please wait...'**
  String get loading;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error occured during loading data.'**
  String get errorLoadingData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available!'**
  String get noDataAvailable;

  /// No description provided for @tapToHearSightDetails.
  ///
  /// In en, this message translates to:
  /// **'Read sight details aloud'**
  String get tapToHearSightDetails;

  /// No description provided for @tapToHearParkDetails.
  ///
  /// In en, this message translates to:
  /// **'Read park details aloud'**
  String get tapToHearParkDetails;

  /// No description provided for @tapToHearSportDetails.
  ///
  /// In en, this message translates to:
  /// **'Read sports field details aloud'**
  String get tapToHearSportDetails;

  /// No description provided for @tapToViewPark.
  ///
  /// In en, this message translates to:
  /// **'Tap to view park\'s details.'**
  String get tapToViewPark;

  /// No description provided for @tapToViewSport.
  ///
  /// In en, this message translates to:
  /// **'Tap to view sport field\'s details.'**
  String get tapToViewSport;

  /// No description provided for @tapToHearLegend.
  ///
  /// In en, this message translates to:
  /// **'Read the city legend aloud'**
  String get tapToHearLegend;

  /// No description provided for @tapToHearHistory.
  ///
  /// In en, this message translates to:
  /// **'Read the city history aloud'**
  String get tapToHearHistory;

  /// No description provided for @readCityFact.
  ///
  /// In en, this message translates to:
  /// **'Read {fact} aloud'**
  String readCityFact(String fact);

  /// No description provided for @tapToSeeSightDetails.
  ///
  /// In en, this message translates to:
  /// **'To view further information regarding the sight named {name}, simply tap on it.'**
  String tapToSeeSightDetails(Object name);

  /// No description provided for @legendOfTheCity.
  ///
  /// In en, this message translates to:
  /// **'Legends about the name of the city'**
  String get legendOfTheCity;

  /// No description provided for @starCount.
  ///
  /// In en, this message translates to:
  /// **'{numberOfStars, plural, =1{1 star} other{{numberOfStars} stars}}'**
  String starCount(num numberOfStars);

  /// No description provided for @closeDialog.
  ///
  /// In en, this message translates to:
  /// **'Close dialog'**
  String get closeDialog;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @hotelImage.
  ///
  /// In en, this message translates to:
  /// **'Hotel image'**
  String get hotelImage;

  /// No description provided for @hotelName.
  ///
  /// In en, this message translates to:
  /// **'Hotel name: '**
  String get hotelName;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @restaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name: '**
  String get restaurantName;

  /// No description provided for @restaurantImage.
  ///
  /// In en, this message translates to:
  /// **'Restaurant image'**
  String get restaurantImage;

  /// No description provided for @sportFields.
  ///
  /// In en, this message translates to:
  /// **'Sport fields'**
  String get sportFields;

  /// No description provided for @parks.
  ///
  /// In en, this message translates to:
  /// **'Parks'**
  String get parks;

  /// No description provided for @valjevoCityImage.
  ///
  /// In en, this message translates to:
  /// **'Image of the city of Valjevo'**
  String get valjevoCityImage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get chooseLanguage;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @mapPage.
  ///
  /// In en, this message translates to:
  /// **'City map'**
  String get mapPage;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map of the city of Valjevo'**
  String get map;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get mapView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @previousItem.
  ///
  /// In en, this message translates to:
  /// **'Previous item'**
  String get previousItem;

  /// No description provided for @nextItem.
  ///
  /// In en, this message translates to:
  /// **'Next item'**
  String get nextItem;

  /// No description provided for @previousPhoto.
  ///
  /// In en, this message translates to:
  /// **'Previous photo'**
  String get previousPhoto;

  /// No description provided for @nextPhoto.
  ///
  /// In en, this message translates to:
  /// **'Next photo'**
  String get nextPhoto;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @resetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get resetZoom;

  /// No description provided for @movePhotoUp.
  ///
  /// In en, this message translates to:
  /// **'Move photo up'**
  String get movePhotoUp;

  /// No description provided for @movePhotoDown.
  ///
  /// In en, this message translates to:
  /// **'Move photo down'**
  String get movePhotoDown;

  /// No description provided for @movePhotoLeft.
  ///
  /// In en, this message translates to:
  /// **'Move photo left'**
  String get movePhotoLeft;

  /// No description provided for @movePhotoRight.
  ///
  /// In en, this message translates to:
  /// **'Move photo right'**
  String get movePhotoRight;

  /// No description provided for @moveMapUp.
  ///
  /// In en, this message translates to:
  /// **'Move map up'**
  String get moveMapUp;

  /// No description provided for @moveMapDown.
  ///
  /// In en, this message translates to:
  /// **'Move map down'**
  String get moveMapDown;

  /// No description provided for @moveMapLeft.
  ///
  /// In en, this message translates to:
  /// **'Move map left'**
  String get moveMapLeft;

  /// No description provided for @moveMapRight.
  ///
  /// In en, this message translates to:
  /// **'Move map right'**
  String get moveMapRight;

  /// No description provided for @resetMap.
  ///
  /// In en, this message translates to:
  /// **'Reset map'**
  String get resetMap;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopReading;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech is unavailable. Check your device\'s text-to-speech settings.'**
  String get speechUnavailable;

  /// No description provided for @retryImage.
  ///
  /// In en, this message translates to:
  /// **'Retry loading image'**
  String get retryImage;

  /// No description provided for @positionInList.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String positionInList(int current, int total);

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @menuItem.
  ///
  /// In en, this message translates to:
  /// **'Menu Item: {item}'**
  String menuItem(Object item);

  /// No description provided for @tapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open {item}'**
  String tapToOpen(Object item);

  /// No description provided for @imageOfSight.
  ///
  /// In en, this message translates to:
  /// **'Image of sight {name}'**
  String imageOfSight(Object name);

  /// No description provided for @tapToHearSightName.
  ///
  /// In en, this message translates to:
  /// **'Touch to hear the name of the sight'**
  String get tapToHearSightName;

  /// No description provided for @historyOfTheCity.
  ///
  /// In en, this message translates to:
  /// **'City History'**
  String get historyOfTheCity;

  /// No description provided for @song.
  ///
  /// In en, this message translates to:
  /// **'When you come to any city\n\nAnd one comes to any ctiy very late\n\nWhen you come very late to any city\n\nIn case that city happens to be Valjevo...'**
  String get song;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report Form'**
  String get bugReport;

  /// No description provided for @bugReportIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong so we can improve the app.'**
  String get bugReportIntro;

  /// No description provided for @bugReportDetails.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get bugReportDetails;

  /// No description provided for @bugReportDeviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Device details'**
  String get bugReportDeviceDetails;

  /// No description provided for @bugReportDeviceNote.
  ///
  /// In en, this message translates to:
  /// **'These details are detected automatically.'**
  String get bugReportDeviceNote;

  /// No description provided for @bugReportAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment (optional)'**
  String get bugReportAttachment;

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get removeAttachment;

  /// No description provided for @bugTitle.
  ///
  /// In en, this message translates to:
  /// **'Bug Title'**
  String get bugTitle;

  /// No description provided for @bugDescription.
  ///
  /// In en, this message translates to:
  /// **'Bug Description'**
  String get bugDescription;

  /// No description provided for @operatingSystem.
  ///
  /// In en, this message translates to:
  /// **'Operating System'**
  String get operatingSystem;

  /// No description provided for @selectOS.
  ///
  /// In en, this message translates to:
  /// **'Please select an operating system'**
  String get selectOS;

  /// No description provided for @selectOSLabel.
  ///
  /// In en, this message translates to:
  /// **'Press to select the operating system.'**
  String get selectOSLabel;

  /// No description provided for @deviceModel.
  ///
  /// In en, this message translates to:
  /// **'Device Model'**
  String get deviceModel;

  /// No description provided for @osVersion.
  ///
  /// In en, this message translates to:
  /// **'Operating System Version'**
  String get osVersion;

  /// No description provided for @deviceInfoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some device details could not be detected and will not be included in the report.'**
  String get deviceInfoUnavailable;

  /// No description provided for @deviceInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get deviceInfoNotAvailable;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description of the issue.'**
  String get enterDescription;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title for the issue.'**
  String get enterTitle;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit bug report...'**
  String get submissionFailed;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @bugTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Bug title input field'**
  String get bugTitleLabel;

  /// No description provided for @bugDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Bug description input field'**
  String get bugDescriptionLabel;

  /// No description provided for @osLabel.
  ///
  /// In en, this message translates to:
  /// **'Operating system dropdown'**
  String get osLabel;

  /// No description provided for @fileUploadLabel.
  ///
  /// In en, this message translates to:
  /// **'File upload button'**
  String get fileUploadLabel;

  /// No description provided for @changeLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Change language to {lang}'**
  String changeLanguageLabel(Object lang);

  /// No description provided for @selectLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Select {lang}'**
  String selectLanguageLabel(Object lang);

  /// No description provided for @bugReportSent.
  ///
  /// In en, this message translates to:
  /// **'Bug report successfully sent.'**
  String get bugReportSent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @photoSource.
  ///
  /// In en, this message translates to:
  /// **'Source of the photos'**
  String get photoSource;

  /// No description provided for @copyrightOfImages.
  ///
  /// In en, this message translates to:
  /// **'Copyright of the photos'**
  String get copyrightOfImages;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection!'**
  String get noInternetConnection;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the application'**
  String get aboutApp;

  /// No description provided for @appAuthor.
  ///
  /// In en, this message translates to:
  /// **'© {year} Andjelka Dzida'**
  String appAuthor(int year);

  /// No description provided for @appLogo.
  ///
  /// In en, this message translates to:
  /// **'Application Logo'**
  String get appLogo;

  /// No description provided for @aboutAppLocalization.
  ///
  /// In en, this message translates to:
  /// **'Localization: Our application is designed for global accessibility, offering multilingual support that encompasses English, German, and Serbian, inclusive of both Latin and Cyrillic scripts.'**
  String get aboutAppLocalization;

  /// No description provided for @aboutAppAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility: We are committed to ensuring our app is accessible to everyone, including users with disabilities. Our app includes features such as screen reader support, adjustable text sizes.'**
  String get aboutAppAccessibility;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore effortlessly with our Tour Guide App, your pocket-sized travel expert. Dive into the essence of each destination with detailed guides on sights, hotels, restaurants, parks, and sports facilities. Navigate with ease and listen to rich narratives about your surroundings, making every journey an immersive experience. Designed for accessibility, our app ensures a seamless experience for all travelers. Embark on a journey of discovery and let us guide you to the wonders of the world, all from the palm of your hand'**
  String get aboutAppDescription;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @buttonFor.
  ///
  /// In en, this message translates to:
  /// **'Button for {label}'**
  String buttonFor(Object label);

  /// No description provided for @songAuthor.
  ///
  /// In en, this message translates to:
  /// **'Matija Bećković - \'When You Come to Any City\''**
  String get songAuthor;

  /// No description provided for @surface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surface;

  /// No description provided for @elevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation above sea level'**
  String get elevation;

  /// No description provided for @populationDensity.
  ///
  /// In en, this message translates to:
  /// **'Population density'**
  String get populationDensity;

  /// No description provided for @population.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get population;

  /// No description provided for @citySurfaceValue.
  ///
  /// In en, this message translates to:
  /// **'{value} ha'**
  String citySurfaceValue(int value);

  /// No description provided for @citySurfaceSpoken.
  ///
  /// In en, this message translates to:
  /// **'{value} hectares'**
  String citySurfaceSpoken(int value);

  /// No description provided for @cityElevationValue.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String cityElevationValue(int value);

  /// No description provided for @cityElevationSpoken.
  ///
  /// In en, this message translates to:
  /// **'{value} meters'**
  String cityElevationSpoken(int value);

  /// No description provided for @cityDensityValue.
  ///
  /// In en, this message translates to:
  /// **'{value} people/km² ({year})'**
  String cityDensityValue(double value, int year);

  /// No description provided for @cityDensitySpoken.
  ///
  /// In en, this message translates to:
  /// **'{value} people per square kilometer in {year}'**
  String cityDensitySpoken(double value, int year);

  /// No description provided for @cityPopulationValue.
  ///
  /// In en, this message translates to:
  /// **'{value} ({year})'**
  String cityPopulationValue(int value, int year);

  /// No description provided for @cityPopulationSpoken.
  ///
  /// In en, this message translates to:
  /// **'{value} people in {year}'**
  String cityPopulationSpoken(int value, int year);

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @cityDay.
  ///
  /// In en, this message translates to:
  /// **'City Day'**
  String get cityDay;

  /// No description provided for @saint.
  ///
  /// In en, this message translates to:
  /// **'City Patron Saint Day'**
  String get saint;

  /// No description provided for @kolubaraDistrict.
  ///
  /// In en, this message translates to:
  /// **'Kolubara District'**
  String get kolubaraDistrict;

  /// No description provided for @saintName.
  ///
  /// In en, this message translates to:
  /// **'Trojice (Duhovi)'**
  String get saintName;

  /// No description provided for @indicator.
  ///
  /// In en, this message translates to:
  /// **'Indicator'**
  String get indicator;

  /// No description provided for @cityFactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Key facts about Valjevo'**
  String get cityFactsTitle;

  /// No description provided for @openAboutDialog.
  ///
  /// In en, this message translates to:
  /// **'Open about dialog.'**
  String get openAboutDialog;

  /// No description provided for @cityDayDate.
  ///
  /// In en, this message translates to:
  /// **'20. March'**
  String get cityDayDate;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @infoByYou.
  ///
  /// In en, this message translates to:
  /// **'Information Provided by You'**
  String get infoByYou;

  /// No description provided for @infoByYouContent.
  ///
  /// In en, this message translates to:
  /// **'When you interact with us by contacting us, providing feedback, or completing forms, Vodič Kroz Valjevo may gather additional data like your location, internet connectivity details, and more.'**
  String get infoByYouContent;

  /// No description provided for @autoCollectedData.
  ///
  /// In en, this message translates to:
  /// **'Information Collected Automatically By Vodič Kroz Valjevo'**
  String get autoCollectedData;

  /// No description provided for @autoCollectedDataContent.
  ///
  /// In en, this message translates to:
  /// **'Vodič Kroz Valjevo automatically collects data such as your device information when you utilize our Services or Apps.'**
  String get autoCollectedDataContent;

  /// No description provided for @localStorage.
  ///
  /// In en, this message translates to:
  /// **'Local Storage Notice'**
  String get localStorage;

  /// No description provided for @localStorageContent.
  ///
  /// In en, this message translates to:
  /// **'To enhance our services and gain insights into your interaction patterns, Vodič Kroz Valjevo utilizes local storage technology. Please note that your settings and preferences are stored directly on your device, as we do not use cookies.'**
  String get localStorageContent;

  /// No description provided for @useOfInfo.
  ///
  /// In en, this message translates to:
  /// **'Use of Information'**
  String get useOfInfo;

  /// No description provided for @useOfInfoContent.
  ///
  /// In en, this message translates to:
  /// **'Vodič Kroz Valjevo may utilize your information to enhance and provide our Services, monitor your activities, communicate with you, offer customer support, and ensure the security of our Terms and Policy.'**
  String get useOfInfoContent;

  /// No description provided for @thirdParty.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Access to Your Information'**
  String get thirdParty;

  /// No description provided for @thirdPartyContent.
  ///
  /// In en, this message translates to:
  /// **'Your data may be shared with third parties as outlined in our Terms and Policy for various reasons, including but not limited to, collaboration with service providers and legal compliance.'**
  String get thirdPartyContent;

  /// No description provided for @tearmsOfAnd.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use and Privacy Policy of Third Parties'**
  String get tearmsOfAnd;

  /// No description provided for @tearmsOfAndContent.
  ///
  /// In en, this message translates to:
  /// **'You acknowledge that Vodič Kroz Valjevo utilizes third-party services, which we do not manage or secure, and it\'s your responsibility to review their policies.'**
  String get tearmsOfAndContent;

  /// No description provided for @ongoingAmend.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Amendments'**
  String get ongoingAmend;

  /// No description provided for @ongoingAmendContent.
  ///
  /// In en, this message translates to:
  /// **'Vodič Kroz Valjevo reserves the right to modify this Privacy Policy, with changes taking immediate effect upon posting. Continuous use of our Service post-modification implies your agreement to the amendments.'**
  String get ongoingAmendContent;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactContent.
  ///
  /// In en, this message translates to:
  /// **'For any inquiries or concerns regarding this Privacy Policy, please reach out to us via email.'**
  String get contactContent;

  /// No description provided for @mapCredits.
  ///
  /// In en, this message translates to:
  /// **'Map Credits'**
  String get mapCredits;

  /// No description provided for @mapCreditsContent.
  ///
  /// In en, this message translates to:
  /// **'We acknowledge the contributions of projects like Open Street Map in providing scalable map data.'**
  String get mapCreditsContent;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated {date}'**
  String lastUpdated(Object date);

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vodic Kroz Valjevo, a mobile application developed and maintained by Andjelka Dzida (\'we\', \'us\', or \'our\'). By downloading, accessing, or using our mobile application, you agree to be bound by these Terms of Service (\'Terms\'). If you do not agree to these Terms, please do not use our application.'**
  String get termsContent;

  /// No description provided for @acceptanceTerms.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get acceptanceTerms;

  /// No description provided for @acceptanceTermsContent.
  ///
  /// In en, this message translates to:
  /// **'You agree that by accessing or using our app, you are agreeing to these Terms and our Privacy Policy.'**
  String get acceptanceTermsContent;

  /// No description provided for @termsChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms of Service'**
  String get termsChanges;

  /// No description provided for @termsChangesContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these Terms at any time. Your continued use of the app following any changes indicates your acceptance of the new Terms.'**
  String get termsChangesContent;

  /// No description provided for @privacyContent.
  ///
  /// In en, this message translates to:
  /// **'Our Privacy Policy describes how we handle the information you provide to us when you use our app. By using our app, you agree to the collection and use of information in accordance with our Privacy Policy.'**
  String get privacyContent;

  /// No description provided for @userConduct.
  ///
  /// In en, this message translates to:
  /// **'User Conduct'**
  String get userConduct;

  /// No description provided for @userConductContent.
  ///
  /// In en, this message translates to:
  /// **'You agree not to engage in any conduct that is unlawful, infringes on the rights of others, or is otherwise objectionable.'**
  String get userConductContent;

  /// No description provided for @intellectualProperty.
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get intellectualProperty;

  /// No description provided for @intellectualPropertyContent.
  ///
  /// In en, this message translates to:
  /// **'The app and its original content, features, and functionality are and will remain the exclusive property of Andjelka Dzida and its licensors.'**
  String get intellectualPropertyContent;

  /// No description provided for @userGen.
  ///
  /// In en, this message translates to:
  /// **'User-Generated Content'**
  String get userGen;

  /// No description provided for @userGenContent.
  ///
  /// In en, this message translates to:
  /// **'You may be able to submit content through the app. You retain all rights to your content, but you grant us a non-exclusive, royalty-free license to use, reproduce, modify, and display your content in connection with the app.'**
  String get userGenContent;

  /// No description provided for @thirdPartServices.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Links and Services'**
  String get thirdPartServices;

  /// No description provided for @thirdPartServicesContent.
  ///
  /// In en, this message translates to:
  /// **'Our app may contain links to third-party websites or services that are not owned or controlled by us. We are not responsible for the content, privacy policies, or practices of any third-party websites or services.'**
  String get thirdPartServicesContent;

  /// No description provided for @appChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes to Our App'**
  String get appChanges;

  /// No description provided for @appChangesContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify or discontinue, temporarily or permanently, the app or any service to which it connects, with or without notice and without liability to you.'**
  String get appChangesContent;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about these Terms, please contact us at '**
  String get contactUsContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'sr':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppLocalizationsSrCyrl();
          case 'Latn':
            return AppLocalizationsSrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
