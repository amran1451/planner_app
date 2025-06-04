// lib/models/subtask.dart

class Subtask {
  int? id;
  int taskId;
  String title;
  bool isDone;

  Subtask({
    this.id,
    required this.taskId,
    required this.title,
    this.isDone = false,
  });

  factory Subtask.fromMap(Map<String, dynamic> m) => Subtask(
        id: m['id'] as int?,
        taskId: m['task_id'] as int,
        title: m['title'] as String,
        isDone: (m['is_done'] as int) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'task_id': taskId,
        'title': title,
        'is_done': isDone ? 1 : 0,
      };
}
