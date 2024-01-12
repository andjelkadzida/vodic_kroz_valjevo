import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    _database = await openDatabase(path,
        version: 3,
        readOnly: false,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade);

    return _database!;
  }

  static void _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS Sights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sights_image_path BLOB,
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
          CREATE TABLE IF NOT EXISTS SportsAndRecreation (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sports_image_path BLOB,
            title_en TEXT,
            title_de TEXT,
            title_sr TEXT,
            title_sr_Cyrl TEXT,
            title_sr_Latn TEXT
          )
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS Hotels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hotel_image_path BLOB,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            title_en TEXT,
            title_de TEXT,
            title_sr TEXT,
            title_sr_Cyrl TEXT,
            title_sr_Latn TEXT,
            noStars INT
            )
        ''');
  }

  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('''
          DROP TABLE IF EXISTS Sights;
          DROP TABLE IF EXISTS SportsAndRecreation;
          DROP TABLE IF EXISTS Hotels;
        ''');
      _onCreate(db, newVersion);
    }
  }

  static void _onDowngrade(
      Database db, int currentVersion, int newVersion) async {
    File dbFile = File(db.path);

    currentVersion = await db.getVersion();
    if (currentVersion > newVersion) {
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      _onCreate(db, newVersion);
    }
  }

  // Checking database connection
  static Widget buildFutureState<T>({
    required BuildContext context,
    required AsyncSnapshot<T> snapshot,
    required Widget Function(T data) onData,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Semantics(
        label: localization(context).loading,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (snapshot.hasError) {
      return Semantics(
        label: localization(context).errorLoadingData,
        child: Center(
          child: Text(
              '${localization(context).errorLoadingData}: ${snapshot.error}'),
        ),
      );
    } else if (!snapshot.hasData ||
        (snapshot.data is List && (snapshot.data as List).isEmpty)) {
      return Semantics(
        label: localization(context).noDataAvailable,
        child: Center(child: Text(localization(context).noDataAvailable)),
      );
    }
    // Handle the case when data is available
    return onData(snapshot.data as T);
  }

  // Image loader
  static Future<Uint8List> loadImageAsUint8List(String imagePath) async {
    ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }
}
