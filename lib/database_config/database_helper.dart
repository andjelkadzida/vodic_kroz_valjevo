import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../localization/supported_languages.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  static DatabaseHelper get instance => _instance;

  Future<Database> getNamedDatabase() async {
    String dbName = 'valjevo_tour_guide.db';
    String path = join(await getDatabasesPath(), dbName);

    // Checking if the database is already open, if not, open it
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _database = await openDatabase(path,
        version: 1,
        readOnly: false,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade);

    return _database!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS Sights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sight_image_path TEXT,
            sight_image_path2 TEXT,
            sight_image_path3 TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            title_en TEXT,
            title_de TEXT,
            title_sr TEXT,
            title_sr_Cyrl TEXT,
            title_sr_Latn TEXT,
            description_en TEXT,
            description_de TEXT,
            description_sr TEXT,
            description_sr_Cyrl TEXT,
            description_sr_Latn TEXT
          )
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS Sports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sport_image_path TEXT,
            sport_image_path2 TEXT,
            sport_image_path3 TEXT,
            title_en TEXT,
            title_de TEXT,
            title_sr TEXT,
            title_sr_Cyrl TEXT,
            title_sr_Latn TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            description_en TEXT,
            description_de TEXT,
            description_sr TEXT,
            description_sr_Cyrl TEXT,
            description_sr_Latn TEXT
          )
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS Parks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            park_image_path TEXT,
            park_image_path2 TEXT,
            park_image_path3 TEXT,
            title_en TEXT,
            title_de TEXT,
            title_sr TEXT,
            title_sr_Cyrl TEXT,
            title_sr_Latn TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            description_en TEXT,
            description_de TEXT,
            description_sr TEXT,
            description_sr_Cyrl TEXT,
            description_sr_Latn TEXT
          )
        ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS Hotels (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hotel_image_path TEXT,
          hotel_image_path2 TEXT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          title_en TEXT,
          title_de TEXT,
          title_sr TEXT,
          title_sr_Cyrl TEXT,
          title_sr_Latn TEXT,
          website TEXT,
          noStars INT
        )
    ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS Restaurants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            restaurant_image_path TEXT,
            restaurant_image_path2 TEXT,
            restaurant_images_resource TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            title_en TEXT,
            title_de TEXT,
            title_sr TEXT,
            title_sr_Cyrl TEXT,
            title_sr_Latn TEXT
            )
        ''');

    await db.execute('''CREATE TABLE IF NOT EXISTS AboutCity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        legend_title_en TEXT,
        legend_title_de TEXT,
        legend_title_sr TEXT,
        legend_title_sr_Cyrl TEXT,
        legend_title_sr_Latn TEXT,
        legend_description_en TEXT,
        legend_description_de TEXT,
        legend_description_sr TEXT,
        legend_description_sr_Cyrl TEXT,
        legend_description_sr_Latn TEXT,
        history_en TEXT,
        history_de TEXT,
        history_sr TEXT,
        history_sr_Cyrl TEXT,
        history_sr_Latn TEXT,
        about_city_image_path TEXT
      )''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS Sights');
      await db.execute('DROP TABLE IF EXISTS Sports');
      await db.execute('DROP TABLE IF EXISTS Parks');
      await db.execute('DROP TABLE IF EXISTS Hotels');
      await db.execute('DROP TABLE IF EXISTS Restaurants');
      await db.execute('DROP TABLE IF EXISTS AboutCity');
      await _onCreate(db, newVersion);
    }
  }

  static Future<void> _onDowngrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion > newVersion) {
      await db.execute('DROP TABLE IF EXISTS Sights');
      await db.execute('DROP TABLE IF EXISTS Sports');
      await db.execute('DROP TABLE IF EXISTS Parks');
      await db.execute('DROP TABLE IF EXISTS Hotels');
      await db.execute('DROP TABLE IF EXISTS Restaurants');
      await db.execute('DROP TABLE IF EXISTS AboutCity');
      await _onCreate(db, newVersion);
    }
  }

  // Checking database connection
  static Widget buildFutureState<T>({
    required BuildContext context,
    required AsyncSnapshot<T> snapshot,
    required Widget Function(T data) onData,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: Semantics(
          tooltip: localization(context).loading,
          child: CircularProgressIndicator(
            semanticsLabel: localization(context).loading,
          ),
        ),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
            '${localization(context).errorLoadingData}: ${snapshot.error}'),
      );
    } else if (!snapshot.hasData ||
        (snapshot.data is List && (snapshot.data as List).isEmpty)) {
      return Center(
        child: Text(localization(context).noDataAvailable),
      );
    }
    // Handle the case when data is available
    return onData(snapshot.data as T);
  }
}
