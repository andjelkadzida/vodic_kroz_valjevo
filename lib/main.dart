import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_config/database_helper.dart';
import 'database_config/hotels_repository.dart';
import 'database_config/restaurants_repository.dart';
import 'database_config/sights_repository.dart';
import 'database_config/sports_repository.dart';
import 'localization/supported_languages.dart';
import 'pages/home_page.dart';
import 'text_to_speech/text_to_speech_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  if (isFirstRun) {
    await prefs.setBool('isFirstRun', true);
  }

  // Set the orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize the database
  final db = await DatabaseHelper.instance.getNamedDatabase();
  runApp(VodicKrozValjevo(database: db, isFirstRun: isFirstRun));
}

class VodicKrozValjevo extends StatefulWidget {
  final Database database;
  final bool isFirstRun;

  const VodicKrozValjevo(
      {Key? key, required this.database, required this.isFirstRun})
      : super(key: key);

  @override
  State<VodicKrozValjevo> createState() => _VodicKrozValjevo();

  // Setting language
  static void setLanguage(Locale newLanguage) {
    final appState = _VodicKrozValjevo._instance;
    appState?.setLanguage(newLanguage);
  }
}

class _VodicKrozValjevo extends State<VodicKrozValjevo> {
  static _VodicKrozValjevo? _instance;
  Locale? _lang;
  final flutterTts = FlutterTts();
  late SightsRepository sightsRepo;
  late SportsRepository sportsRepo;
  late HotelsRepository hotelsRepo;
  late RestaurantsRepository restaurantsRepo;

  @override
  void initState() {
    super.initState();
    _instance = this;
    sightsRepo = SightsRepository(widget.database);
    sportsRepo = SportsRepository(widget.database);
    hotelsRepo = HotelsRepository(widget.database);
    restaurantsRepo = RestaurantsRepository(widget.database);
    _initializeData();
  }

  void _initializeData() async {
    if (!(await sportsRepo.checkSportsDataExists())) {
      await sportsRepo.sportsDataInsertion();
    }

    if (!(await sightsRepo.checkSightsDataExist())) {
      await sightsRepo.sightsDataInsertion();
    }

    if (!(await hotelsRepo.checkHotelsDataExist())) {
      await hotelsRepo.hotelsDataInsertion();
    }

    if (!(await restaurantsRepo.checkRestaurantsDataExist())) {
      await restaurantsRepo.restaurantsDataInsertion();
    }

    await widget.database.close();
  }

  setLanguage(Locale lang) {
    setState(() {
      _lang = lang;
      TextToSpeechConfig.instance.setLanguage(lang.languageCode);
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((lang) => {setLanguage(lang)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _lang,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // builder: (context, child) => AccessibilityTools(child: child),
      home: const HomePage(),
    );
  }
}
