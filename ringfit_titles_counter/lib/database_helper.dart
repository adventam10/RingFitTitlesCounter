import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String _columnId = 'id';

class Column {
  // ignore: avoid_positional_boolean_parameters
  Column(this.key, this.type, this.nullable);

  String key;
  ColumnType type;
  bool nullable;

  String get text {
    var value = key;
    switch (type) {
      case ColumnType.text:
        value += ' TEXT';
        break;
      case ColumnType.integer:
        value += ' INTEGER';
        break;
    }
    if (!nullable) {
      value += ' NOT NULL';
    }
    return value;
  }
}

enum ColumnType {
  text,
  integer,
}

class DatabaseHelper {
  late Database db;

  Future<void> open(
      int version, String table, List<Column> columns
      ) async {
    final directoryPath = await getDatabasesPath();
    final path = join(directoryPath, 'ringfit.db');
    final text = columns.map((e) => e.text).join(',');
    db = await openDatabase(path, version: version,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE $table (
          $_columnId INTEGER PRIMARY KEY,
          $text)
          ''');
        });
  }

  Future<int> insert(String table, Map<String, Object?> map) async {
    final targetId = await db.insert(table, map);
    return targetId;
  }

  Future<List<Map<String, Object?>>> getAll(String table) async {
    final maps = await db.rawQuery('SELECT * FROM $table');
    return maps;
  }

  Future<Map<String, Object?>?> getMap(
      String table, int id, List<String> columns
      ) async {
    final columnList = [_columnId, ...columns];
    final List<Map<dynamic, dynamic>> maps = await db.query(table,
        columns: columnList,
        where: '$_columnId = ?',
        whereArgs: [id]);
    return maps.first as Map<String, Object?>?;
  }

  Future<int> delete(String table, int id) async {
    final targetId = await db.delete(table, where: '$_columnId = ?', whereArgs: [id]);
    return targetId;
  }

  Future<int> update(String table, Map<String, Object?> map) async {
    final targetId = await db.update(
        table,
        map,
        where: '$_columnId = ?',
        whereArgs: [map[_columnId]! as int]
    );
    return targetId;
  }

  Future<void> close() async => db.close();
}