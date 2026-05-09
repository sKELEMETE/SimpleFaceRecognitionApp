import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static final DBService instance = DBService._init();

  static Database? _database;

  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('faces.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        embedding TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(String name, List<double> embedding) async {
    final db = await instance.database;

    return db.insert(
      'users',
      {
        'name': name,
        'embedding': jsonEncode(embedding),
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final db = await instance.database;

    return db.query('users');
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}