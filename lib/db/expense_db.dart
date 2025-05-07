import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpenseDB {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;
    final path = await getDatabasesPath();
    final dbPath = join(path, 'expenses.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT,
            category TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<int> insertExpense(Expense expense) async {
    final db = await getDB();
    return await db.insert('expenses', expense.toMap());
  }

  static Future<List<Expense>> getAllExpenses() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  static Future<int> updateExpense(Expense expense) async {
    final db = await getDB();
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<int> deleteExpense(int id) async {
    final db = await getDB();
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
