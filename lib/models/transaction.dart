import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String tableName = 'transactions';
const String columnId = '_id';
const String columnMerchant = 'merchant';
const String columnisDebit = 'is_debit';
const String columnValue = 'value';
const String columnCurrency = 'currency';
const String columnDatePurchased = 'date_purchased';
const String columnCategory = 'category';
const String columnNote = 'note';

class Transaction {
  int? id;
  String merchant;
  bool isDebit;
  int value;
  String currency;
  String datePurchased;
  String category;
  String note;

  Transaction({
    required this.merchant,
    this.isDebit = true,
    required this.value,
    this.currency = 'GBP',
    required this.datePurchased,
    required this.category,
    this.note = "",
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnMerchant: merchant,
      columnisDebit: isDebit ? 1 : 0,
      columnValue: value,
      columnCurrency: currency,
      columnDatePurchased: datePurchased,
      columnCategory: category,
      columnNote: note,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  static Future<String> getDefaultPath() async {
    return join(await getDatabasesPath(), 'db.sqlite3');
  }

  @override
  String toString() {
    return 'Transaction{id: $id, merchant: $merchant , date: $datePurchased}';
  }

  Transaction.fromMap(Map<String, dynamic> map)
      : id = map[columnId],
        merchant = map[columnMerchant],
        isDebit = map[columnisDebit] == 1,
        value = map[columnValue],
        currency = map[columnCurrency],
        category = map[columnCategory],
        datePurchased = map[columnDatePurchased],
        note = map[columnNote];
}

class TransactionProvider {
  Database? db;

  Future<TransactionProvider> open({String? path}) async {
    String databasePath = path ?? join(await getDatabasesPath(), 'db.sqlite3');
    await Sqflite.setDebugModeOn();
    db = await openDatabase(databasePath, version: 1, singleInstance: true,
        onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableName ( 
          $columnId integer primary key autoincrement, 
          $columnMerchant text not null,
          $columnisDebit integer not null,
          $columnValue integer not null,
          $columnCurrency text not null,
          $columnDatePurchased text not null,
          $columnCategory text not null,
          $columnNote text not null
        )
      ''');
    });
    return this;
  }

  Future<Transaction> insert(Transaction trans) async {
    if (db == null) {
      throw ('Database object does not exist!');
    }
    trans.id = await db!.insert(tableName, trans.toMap());
    return trans;
  }

  Future<Transaction?> getTransactionById(int id) async {
    if (db == null) {
      throw ('Database object does not exist!');
    }
    List<Map<String, dynamic>> maps = await db!.query(tableName,
        columns: null, where: '$columnId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Transaction>> getTransactions() async {
    if (db == null) {
      throw ('Database object does not exist!');
    }
    List<Map<String, dynamic>> maps =
        await db!.query(tableName, columns: null, where: null, limit: 5);
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> delete(int id) async {
    if (db == null) {
      throw ('Database object does not exist!');
    }
    return await db!.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Transaction trans) async {
    if (db == null) {
      throw ('Database object does not exist!');
    }
    return await db!.update(tableName, trans.toMap(),
        where: '$columnId = ?', whereArgs: [trans.id]);
  }

  Future close() async {
    if (db == null) {
      throw ('Database object does not exist!');
    }
    db!.close();
  }
}
