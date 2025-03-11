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
    return await openDatabase(path, version: 2, onCreate: _createTables, onUpgrade: _onUpgrade);
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

    // Create tickets table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tailure TEXT NOT NULL,
        level TEXT NOT NULL,
        plate TEXT NOT NULL,
        date TEXT NOT NULL,
        destination TEXT NOT NULL,
        departure TEXT NOT NULL,
        uniqueId TEXT NOT NULL,
        tariff REAL NOT NULL,
        charge REAL NOT NULL,
        association TEXT NOT NULL,
        distance TEXT NOT NULL,
        is_uploaded INTEGER DEFAULT 0
      )
    ''');
  }

  // Handle database upgrades
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add tickets table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tickets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tailure TEXT NOT NULL,
          level TEXT NOT NULL,
          plate TEXT NOT NULL,
          date TEXT NOT NULL,
          destination TEXT NOT NULL,
          departure TEXT NOT NULL,
          uniqueId TEXT NOT NULL,
          tariff REAL NOT NULL,
          charge REAL NOT NULL,
          association TEXT NOT NULL,
          distance TEXT NOT NULL,
          is_uploaded INTEGER DEFAULT 0
        )
      ''');
    }
  }

  // Method to check and ensure the tickets table exists with correct schema
  Future<void> ensureTicketsTable() async {
    final db = await database;
    // Check if the tickets table exists
    var tableInfo = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='tickets';");
    if (tableInfo.isEmpty) {
      print('Tickets table does not exist, creating it...');
      await _createTicketsTable(db);
      return;
    }
    
    // Verify the structure
    try {
      // Try a simple query to confirm the table structure
      await db.rawQuery('SELECT tailure, level, plate, date, destination, departure, uniqueId, tariff, charge, association, distance, is_uploaded FROM tickets LIMIT 1');
      print('Tickets table structure verified successfully');
    } catch (e) {
      print('Tickets table has incorrect structure, recreating it: $e');
      // Drop and recreate the table if it has incorrect structure
      await db.execute('DROP TABLE tickets');
      await _createTicketsTable(db);
    }
  }
  
  Future<void> _createTicketsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tailure TEXT NOT NULL,
        level TEXT NOT NULL,
        plate TEXT NOT NULL,
        date TEXT NOT NULL,
        destination TEXT NOT NULL,
        departure TEXT NOT NULL,
        uniqueId TEXT NOT NULL,
        tariff REAL NOT NULL,
        charge REAL NOT NULL,
        association TEXT NOT NULL,
        distance TEXT NOT NULL,
        is_uploaded INTEGER DEFAULT 0
      )
    ''');
    print('Tickets table created successfully');
  }
}