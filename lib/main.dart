import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'models/transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String databasePath = await Transaction.getDefaultPath();
  File db = File(databasePath);
  if (db.existsSync()) {
    db.deleteSync(); // blow the DB away
  }
  TransactionProvider provider = await TransactionProvider().open();
  for (var i = 0; i < 5; i++) {
    provider.insert(Transaction(
        merchant: 'dummy merchant',
        value: 5,
        datePurchased: DateTime.now().toIso8601String(),
        category: 'lel'));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Banker';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme:
          ThemeData(primarySwatch: Colors.grey, backgroundColor: Colors.white),
      home: const MyHomePage(title: 'Banker'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  Future<List<Transaction>> getTransactions() async {
    TransactionProvider provider = await TransactionProvider().open();
    return provider.getTransactions();
  }

  List<DataRow> buildDataRows(List<Transaction>? data) {
    if (data == null) {
      throw ('Data returned from DB was null!');
    }
    return List<DataRow>.generate(data.length, (i) => buildDataRow(data[i], i));
  }

  DataRow buildDataRow(Transaction trans, int i) {
    List<String> cells = [
      trans.merchant,
      (trans.isDebit ? 1 : 0).toString(),
      trans.value.toString(),
      DateFormat.yMMMd('en_US').format(DateTime.parse(trans.datePurchased)),
      trans.category,
      trans.note
    ];
    return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          print(states);
          // Even rows will have a grey color.
          if (i.isEven) {
            return Colors.grey.withOpacity(0.3);
          }
          return null; // Use default value for other states and odd rows.
        }),
        cells: cells.map((e) => DataCell(Text(e))).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: FutureBuilder<List<Transaction>>(
            future: getTransactions(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Transaction>> snapshot) {
              if (snapshot.hasData) {
                return DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Merchant')),
                    DataColumn(label: Text('Flow')),
                    DataColumn(label: Text('Value (£)')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Note')),
                  ],
                  rows: buildDataRows(snapshot.data),
                );
              } else if (snapshot.hasError) {
                return const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                );
              } else {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
