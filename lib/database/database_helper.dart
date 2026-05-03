import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sash_budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const floatType = 'REAL NOT NULL';
    const nullableTextType = 'TEXT';

    // 1. Families Table
    await db.execute('''
      CREATE TABLE families (
        id $idType,
        name $textType,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 2. Members Table
    await db.execute('''
      CREATE TABLE members (
        id $idType,
        family_id $integerType,
        name $textType,
        avatar_path $nullableTextType,
        role $textType,
        FOREIGN KEY (family_id) REFERENCES families (id) ON DELETE CASCADE
      )
    ''');

    // 3. Accounts Table
    await db.execute('''
      CREATE TABLE accounts (
        id $idType,
        family_id $integerType,
        name $textType,
        type $textType,
        balance REAL DEFAULT 0.0,
        FOREIGN KEY (family_id) REFERENCES families (id) ON DELETE CASCADE
      )
    ''');

    // 4. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon $textType,
        type $textType
      )
    ''');

    // 5. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        account_id $integerType,
        member_id $integerType,
        category_id $integerType,
        amount $floatType,
        date $textType,
        note $nullableTextType,
        type $textType,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // Seed Initial Data
    await _seedData(db);
  }

  Future _seedData(Database db) async {
    // Default Categories
    final List<CategoryModel> defaultCategories = [
      CategoryModel(name: 'Food', icon: '🍔', type: 'Expense'),
      CategoryModel(name: 'Transport', icon: '🚗', type: 'Expense'),
      CategoryModel(name: 'Rent', icon: '🏠', type: 'Expense'),
      CategoryModel(name: 'Shopping', icon: '🛍️', type: 'Expense'),
      CategoryModel(name: 'Bills', icon: '⚡', type: 'Expense'),
      CategoryModel(name: 'Salary', icon: '💰', type: 'Income'),
      CategoryModel(name: 'Bonus', icon: '🎁', type: 'Income'),
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', cat.toMap());
    }

    // Default Family & Member (Conceptual)
    final familyId = await db.insert('families', {'name': 'Default Family'});
    await db.insert('members', {
      'family_id': familyId,
      'name': 'Primary User',
      'role': 'Admin'
    });

    // Default Account
    await db.insert('accounts', {
      'family_id': familyId,
      'name': 'Cash',
      'type': 'Wallet',
      'balance': 0.0
    });
  }

  // CRUD Operations - Categories
  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await instance.database;
    final result = type != null 
        ? await db.query('categories', where: 'type = ?', whereArgs: [type])
        : await db.query('categories');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  // CRUD Operations - Accounts
  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await instance.database;
    return await db.query('accounts');
  }

  // CRUD Operations - Transactions
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    
    // Update account balance
    final accountId = row['account_id'];
    final amount = row['amount'];
    final type = row['type'];
    
    final accountResult = await db.query('accounts', where: 'id = ?', whereArgs: [accountId]);
    if (accountResult.isNotEmpty) {
      double currentBalance = accountResult.first['balance'] as double;
      double newBalance = type == 'Credit' ? currentBalance + amount : currentBalance - amount;
      await db.update('accounts', {'balance': newBalance}, where: 'id = ?', whereArgs: [accountId]);
    }

    return await db.insert('transactions', row);
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 10}) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT t.*, c.name as category_name, c.icon as category_icon 
      FROM transactions t 
      JOIN categories c ON t.category_id = c.id 
      ORDER BY t.date DESC 
      LIMIT $limit
    ''');
  }

  Future<double> getTotalBalance() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(balance) as total FROM accounts');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
