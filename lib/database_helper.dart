import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "QuranMajid.db";
  static final _databaseVersion = 1;

//  static final tChapter = 'Chapter';
  static final tVerse = 'Verse';
//  static final table = 'Verse';

//  static final columnChapNo = 'chap_no';
//  static final columnName = 'name';
//  static final columnEnglishName = 'english_name';
//  static final columnTitle = 'title';
//  static final columnCity = 'city';

  static final columnId = 'id';
  static final columnChapNo = 'chap_no';
  static final columnIndex = 'v_no';
  static final columnArabicText = 'arabic_text';
  static final columnUrduText = 'urdu_text';
  static final columnArabicStartTime = 'arabic_start_time';
  static final columnArabicEndTime = 'arabic_end_time';
  static final columnUrduStartTime = 'urdu_start_time';
  static final columnUrduEndTime = 'urdu_end_time';

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
    String path = join(await getDatabasesPath(), _databaseName);
    print("Database Helper: -> $path");
    if (true) {
      await deleteDatabase(path);
    }
    bool fileExists = File(path).existsSync();
    if (!fileExists) {
      // Move checking database dir
      var byteData = await rootBundle.load('assets/QuranMajid.db');
      var bytes = byteData.buffer.asUint8List(0, byteData.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }
//    Database database = isReadOnly
//        ? await openReadOnlyDatabase(path)
//        : await openDatabase(path);
//    return database;
    return await await openDatabase(path);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tVerse (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnChapNo INTEGER,
            $columnIndex INTEGER,
            $columnArabicText TEXT,
            $columnUrduText TEXT,
            $columnArabicStartTime TEXT,
            $columnArabicEndTime TEXT,
            $columnUrduStartTime TEXT,
            $columnUrduEndTime TEXT
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(
      tVerse,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(tVerse);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tVerse'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db
        .update(tVerse, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tVerse, where: '$columnId = ?', whereArgs: [id]);
  }
}
