import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "QuranMajid.db";
  static final _databasePathBundle = "'assets/QuranMajid.db'";
  static final _tVerse = 'Verse';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    return _openDatabase(_databaseName, _databasePathBundle);
  }

  Future<Database> _openDatabase(
    String databaseName,
    String databasePathBundle, {
    bool isReadOnly = true,
    bool deleteFirst = false,
  }) async {
    // Copy from project assets to device
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, databaseName);
    if (deleteFirst) {
      await deleteDatabase(path);
    }
    bool fileExists = File(path).existsSync();
    if (!fileExists) {
      // Move checking database dir
      var byteData = await rootBundle.load(databasePathBundle);
      var bytes = byteData.buffer.asUint8List(0, byteData.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }
    Database database = isReadOnly
        ? await openReadOnlyDatabase(path)
        : await openDatabase(path);
    return database;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(_tVerse);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tVerse'));
  }

  /// Close previous opened Database
  Future<void> disposeDatabase() async {
    if (_database != null) await _database.close();
    _database = null;
  }
}
