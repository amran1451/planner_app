// lib/providers/task_provider.dart

import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../services/database_helper.dart';

class TaskProvider extends ChangeNotifier {
  final db = DatabaseHelper();
  List<Task> tasks = [];

  Future<void> loadAll() async {
    tasks = await db.getAllTasks();
    notifyListeners();
  }

  Future<void> loadByDate(DateTime date) async {
    tasks = await db.getTasksByDate(date);
    notifyListeners();
  }

  Future<void> addTask(Task t) async {
    final id = await db.insertTask(t);
    for (final s in t.subtasks) {
      s.taskId = id;
      await db.insertSubtask(s);
    }
    await loadByDate(t.date);
  }

  Future<void> updateTask(Task t) async {
    await db.updateTask(t);
    for (final s in t.subtasks) {
      if (s.id == null) {
        s.taskId = t.id!;
        await db.insertSubtask(s);
      } else {
        await db.updateSubtask(s);
      }
    }
    await loadByDate(t.date);
  }

  Future<void> deleteTask(int id, DateTime date) async {
    await db.deleteTask(id);
    await loadByDate(date);
  }

  Future<void> toggleSubtask(Subtask s, DateTime date) async {
    s.isDone = !s.isDone;
    await db.updateSubtask(s);
    await loadByDate(date);
  }

  List<Task> byStatus(String status) =>
      tasks.where((t) => t.status == status).toList();
}
