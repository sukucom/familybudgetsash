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
    const integerType = 'INTEGER NOT NULL';
    const floatType = 'REAL NOT NULL';
    const nullableTextType = 'TEXT';

    await db.execute('''
      CREATE TABLE families (
        id $idType,
        name $textType,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

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

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon $textType,
        type $textType
      )
    ''');

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

    await _seedData(db);
  }

  Future _seedData(Database db) async {
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

    final familyId = await db.insert('families', {'name': 'Default Family'});
    await db.insert('members', {
      'family_id': familyId,
      'name': 'Primary User',
      'role': 'Admin'
    });

    await db.insert('accounts', {
      'family_id': familyId,
      'name': 'Cash',
      'type': 'Wallet',
      'balance': 0.0
    });
  }

  // CRUD Operations - Families
  Future<Map<String, dynamic>?> getFamily() async {
    final db = await instance.database;
    final result = await db.query('families', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateFamilyName(String name) async {
    final db = await instance.database;
    return await db.update('families', {'name': name});
  }

  // CRUD Operations - Members
  Future<List<Map<String, dynamic>>> getMembers() async {
    final db = await instance.database;
    return await db.query('members');
  }

  Future<int> insertMember(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('members', row);
  }

  Future<int> deleteMember(int id) async {
    final db = await instance.database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await instance.database;
    final result = type != null 
        ? await db.query('categories', where: 'type = ?', whereArgs: [type])
        : await db.query('categories');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await instance.database;
    return await db.query('accounts');
  }

  Future<int> insertAccount(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('accounts', row);
  }

  Future<int> deleteAccount(int id) async {
    final db = await instance.database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    
    final accountId = row['account_id'];
    final amount = (row['amount'] as num).toDouble();
    final type = row['type'];
    
    final accountResult = await db.query('accounts', where: 'id = ?', whereArgs: [accountId]);
    if (accountResult.isNotEmpty) {
      double currentBalance = (accountResult.first['balance'] as num).toDouble();
      double newBalance = type == 'Credit' ? currentBalance + amount : currentBalance - amount;
      await db.update('accounts', {'balance': newBalance}, where: 'id = ?', whereArgs: [accountId]);
    }

    return await db.insert('transactions', row);
  }

  Future<void> updateTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    final int id = row['id'];
    
    final oldTxResult = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (oldTxResult.isEmpty) return;
    final oldTx = oldTxResult.first;
    
    final double oldAmount = (oldTx['amount'] as num).toDouble();
    final String oldType = oldTx['type'].toString();
    final int oldAccountId = (oldTx['account_id'] as num).toInt();
    
    final oldAccountResult = await db.query('accounts', where: 'id = ?', whereArgs: [oldAccountId]);
    if (oldAccountResult.isNotEmpty) {
      double bal = (oldAccountResult.first['balance'] as num).toDouble();
      double revertedBal = oldType == 'Credit' ? bal - oldAmount : bal + oldAmount;
      await db.update('accounts', {'balance': revertedBal}, where: 'id = ?', whereArgs: [oldAccountId]);
    }

    final double newAmount = (row['amount'] as num).toDouble();
    final String newType = row['type'];
    final int newAccountId = (row['account_id'] as num).toInt();
    
    final newAccountResult = await db.query('accounts', where: 'id = ?', whereArgs: [newAccountId]);
    if (newAccountResult.isNotEmpty) {
      double bal = (newAccountResult.first['balance'] as num).toDouble();
      double finalBal = newType == 'Credit' ? bal + newAmount : bal - newAmount;
      await db.update('accounts', {'balance': finalBal}, where: 'id = ?', whereArgs: [newAccountId]);
    }

    await db.update('transactions', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransaction(int id) async {
    final db = await instance.database;
    
    final txResult = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (txResult.isNotEmpty) {
      final tx = txResult.first;
      final double amount = (tx['amount'] as num).toDouble();
      final String type = tx['type'].toString();
      final int accountId = (tx['account_id'] as num).toInt();
      
      final accResult = await db.query('accounts', where: 'id = ?', whereArgs: [accountId]);
      if (accResult.isNotEmpty) {
        double bal = (accResult.first['balance'] as num).toDouble();
        double newBal = type == 'Credit' ? bal - amount : bal + amount;
        await db.update('accounts', {'balance': newBal}, where: 'id = ?', whereArgs: [accountId]);
      }
    }
    
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 10}) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT t.*, c.name as category_name, c.icon as category_icon, a.name as account_name
      FROM transactions t 
      JOIN categories c ON t.category_id = c.id 
      JOIN accounts a ON t.account_id = a.id
      ORDER BY t.date DESC 
      LIMIT $limit
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsDetailed() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT t.amount, t.date, t.type, t.note, c.name as category, a.name as account
      FROM transactions t 
      JOIN categories c ON t.category_id = c.id 
      JOIN accounts a ON t.account_id = a.id
      ORDER BY t.date DESC
    ''');
  }

  Future<void> insertTransactionsBatch(List<Map<String, dynamic>> transactions) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var tx in transactions) {
      batch.insert('transactions', tx);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCategorySpending({String? timeframe}) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT c.name, c.icon, SUM(t.amount) as total 
      FROM transactions t 
      JOIN categories c ON t.category_id = c.id 
      WHERE t.type = 'Debit'
      GROUP BY c.id
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
