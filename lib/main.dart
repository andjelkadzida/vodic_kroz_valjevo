import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vodic_kroz_valjevo/database_config/database_helper.dart';
import 'package:vodic_kroz_valjevo/database_config/sights_repository.dart';
import 'package:vodic_kroz_valjevo/database_config/sports_repository.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/pages/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final db = await DatabaseHelper.getNamedDatabase();
  runApp(VodicKrozValjevo(database: db));
}

class VodicKrozValjevo extends StatefulWidget {
  final Database database;

  const VodicKrozValjevo({Key? key, required this.database}) : super(key: key);

  @override
  State<VodicKrozValjevo> createState() => _VodicKrozValjevo();

  // Setting language
  static void setLanguage(BuildContext buildContext, Locale newLanguage) {
    _VodicKrozValjevo? appState =
        buildContext.findAncestorStateOfType<_VodicKrozValjevo>();
    appState?.setLanguage(newLanguage);
  }
}

class _VodicKrozValjevo extends State<VodicKrozValjevo> {
  Locale? _lang;
  final flutterTts = FlutterTts();
  late SightsRepository sightsRepo;
  late SportsRepository sportsRepo;

  @override
  void initState() {
    super.initState();
    sightsRepo = SightsRepository(widget.database);
    sportsRepo = SportsRepository(widget.database);
    _initializeData();
  }

  void _initializeData() async {
    bool sportsExist = await sportsRepo.chechSportsDataExists();
    bool sightsExist = await sightsRepo.checkSightsDataExist();

    if (!sportsExist) {
      await sportsRepo.sportsDataInsertion();
    }

    if (!sightsExist) {
      await sightsRepo.sightsDataInsertion();
    }
  }

  setLanguage(Locale lang) {
    setState(() {
      _lang = lang;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((lang) => {setLanguage(lang)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Flutter Text-To-Speech voice configuration
    flutterTts.setLanguage(COUNTRY_CODE);
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: _lang,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // builder: (context, child) => AccessibilityTools(child: child),
      home: HomePage(),
    );
  }
}
