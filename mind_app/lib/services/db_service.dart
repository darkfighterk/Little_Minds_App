import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  // Get database instance
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'shopdb.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  // Get user for login
  Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // Insert new user (for registration)
  Future<bool> insertUser(String username, String password) async {
    final db = await database;

    // Check if user already exists
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existing.isNotEmpty) return false; // Already exists

    await db.insert('users', {'username': username, 'password': password});
    return true; // Successfully inserted
  }

  // Get all users (optional)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }
}
