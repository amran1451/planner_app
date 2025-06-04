// lib/models/task.dart

import 'subtask.dart';

class Task {
  int? id;
  String title;
  DateTime date;
  String status;
  int weight;
  List<Subtask> subtasks;

  Task({
    this.id,
    required this.title,
    required this.date,
    this.status = 'Запланировано',
    this.weight = 1,
    this.subtasks = const [],
  });

  /// Процент выполнения по подзадачам
  double get progress {
    if (subtasks.isEmpty) return 0;
    final done = subtasks.where((s) => s.isDone).length;
    return done / subtasks.length;
  }

  /// Создать из карты БД
  factory Task.fromMap(Map<String, dynamic> m, List<Subtask> subs) => Task(
        id: m['id'] as int?,
        title: m['title'] as String,
        date: DateTime.parse(m['date'] as String),
        status: m['status'] as String,
        weight: m['weight'] as int,
        subtasks: subs,
      );

  /// Преобразовать в карту для БД
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'status': status,
        'weight': weight,
      };
}
