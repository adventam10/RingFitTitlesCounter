import 'dart:async';
import 'database_helper.dart';

const _columnCount = 'count';
const _columnName = 'name';
const _columnSkill = 'skill';

class ExerciseCountRepository {
  final _version = 1;
  final _table = 'exercise_counts';


  static DatabaseHelper? _dbHelper;

  Future<DatabaseHelper> get dbHelper async {
    if (_dbHelper != null) {
      return _dbHelper!;
    }
    _dbHelper = DatabaseHelper();
    await initDb();
    return _dbHelper!;
  }

  Future<void> initDb() async {
    final columns = [
      Column(_columnName, ColumnType.text, true),
      Column(_columnCount, ColumnType.integer, true),
      Column(_columnSkill, ColumnType.integer, true),
    ];
    final db = await dbHelper;
    await db.open(_version, _table, columns);
  }

  Future<void> save(ExerciseCount exerciseCount) async {
    final db = await dbHelper;
    await db.insert(_table, exerciseCount.toMap());
  }

  Future<void> update(ExerciseCount exerciseCount) async {
    final db = await dbHelper;
    await db.update(_table, exerciseCount.toMap());
  }

  Future<List<ExerciseCount>> fetchAll() async {
    final db = await dbHelper;
    final maps = await db.getAll(_table);
    final exerciseCounts = <ExerciseCount>[];
    for (var i = 0; i < maps.length; i++) {
      exerciseCounts.add(ExerciseCount.fromMap(maps[i]));
    }
    return exerciseCounts;
  }
}

class ExerciseCount {
  ExerciseCount(this.id, this.count, this.skill, this.name);
  ExerciseCount.fromMap(Map<String, Object?> map) {
    id = map['id']! as int;
    name = map[_columnName]! as String;
    count = map[_columnCount]! as int;
    skill = map[_columnSkill]! as int;
  }

  late int id;
  late int count;
  late int skill;
  late String name;

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      _columnName: name,
      _columnCount: count,
      _columnSkill: skill
    };
    map['id'] = id;
    return map;
  }
}