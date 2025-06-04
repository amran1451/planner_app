// lib/services/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/subtask.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'planner.db');
    return await openDatabase(
      path,
      version: 2, // bumped from 1 to 2
      onCreate: (db, version) async {
        // создаём обе таблицы сразу при первой установке
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            weight INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE subtasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            is_done INTEGER NOT NULL,
            FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // если БД была версии 1, создаём недостающую таблицу subtasks
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS subtasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL,
              title TEXT NOT NULL,
              is_done INTEGER NOT NULL,
              FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }

  // ---- Task CRUD ----

  Future<int> insertTask(Task t) async {
    final db = await database;
    return db.insert('tasks', t.toMap());
  }

  Future<int> updateTask(Task t) async {
    final db = await database;
    return db.update(
      'tasks',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    final tasks = <Task>[];
    for (var m in maps) {
      final subs = await getSubtasks(m['id'] as int);
      tasks.add(Task.fromMap(m, subs));
    }
    return tasks;
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final iso = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'tasks',
      where: 'date LIKE ?',
      whereArgs: ['${iso}%'],
    );
    final tasks = <Task>[];
    for (var m in maps) {
      final subs = await getSubtasks(m['id'] as int);
      tasks.add(Task.fromMap(m, subs));
    }
    return tasks;
  }

  // ---- Subtask CRUD ----

  Future<int> insertSubtask(Subtask s) async {
    final db = await database;
    return db.insert('subtasks', s.toMap());
  }

  Future<int> updateSubtask(Subtask s) async {
    final db = await database;
    return db.update(
      'subtasks',
      s.toMap(),
      where: 'id = ?',
      whereArgs: [s.id],
    );
  }

  Future<int> deleteSubtask(int id) async {
    final db = await database;
    return db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subtask>> getSubtasks(int taskId) async {
    final db = await database;
    final maps = await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return maps.map((m) => Subtask.fromMap(m)).toList();
  }
}
