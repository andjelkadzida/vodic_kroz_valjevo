import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_config/database_helper.dart';
import 'database_config/database_initializer.dart';
import 'localization/supported_languages.dart';
import 'pages/home_page.dart';
import 'text_to_speech/text_to_speech_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('isFirstRun') ?? true;

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
  final databaseInitializer = DatabaseInitializer(db);

  await Future.wait([
    databaseInitializer.initializeData(),
    dotenv.load(),
  ]);

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

  @override
  void initState() {
    super.initState();
    _instance = this;
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
  void dispose() {
    _instance = null;
    widget.database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _lang,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: Colors.transparent,
      ),
      home: const HomePage(),
    );
  }
}
