import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "report.db";
  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

 void _createTables(Database db, int version) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS report (
      name TEXT NOT NULL,
      total_amount REAL NOT NULL,
      totalServiceFee REAL NOT NULL,
      no_of_ticket INT NOT NULL,
      date TEXT NOT NULL,
      plate TEXT NOT NULL,
      level TEXT NOT NULL,
      destination TEXT NOT NULL
    )
  ''');
}

}