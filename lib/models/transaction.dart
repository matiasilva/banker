import 'package:sqflite/sqflite.dart';

const String tableName = 'transactions';
const String columnId = '_id';
const String columnMerchant = 'merchant';
const String columnisDebit = 'is_debit';
const String columnValue = 'value';
const String columnCurrency = 'currency';
const String columnDatePurchased = 'date_purchased';
const String columnNote = 'note';

class Transaction {
  int id;
  String merchant;
  bool isDebit;
  int value;
  String currency;
  String datePurchased;
  String note;

  Transaction({
    required this.id,
    required this.merchant,
    this.isDebit = true,
    required this.value,
    this.currency = 'GBP',
    required this.datePurchased,
    this.note = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'isDebit': isDebit,
      'value': value,
      'currency': currency,
      'datePurchased': datePurchased,
      'note': note,
    };
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
        datePurchased = map[columnDatePurchased],
        note = map[columnNote];
}

class TodoProvider {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableName ( 
          $columnId integer primary key autoincrement, 
          $columnMerchant text not null,
          $columnisDebit integer not null,
          $columnValue integer not null,
          $columnCurrency text not null,
          $columnDatePurchased text not null
          $columnNote text not null
        )
      ''');
    });
  }

  Future<Transaction> insert(Transaction trans) async {
    trans.id = await db.insert(tableName, trans.toMap());
    return trans;
  }

  Future<List<Transaction>> getTransactions(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: [columnId, columnMerchant, columnValue, columnDatePurchased],
        where: '$columnId = ?',
        whereArgs: [id]);
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> delete(int id) async {
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Transaction trans) async {
    return await db.update(tableName, trans.toMap(),
        where: '$columnId = ?', whereArgs: [trans.id]);
  }

  Future close() async => db.close();
}
