// lib/screens/kanban_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

const List<String> _statuses = [
  'Запланировано',
  'В работе',
  'На проверке',
  'Готово',
];

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TaskProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = screenWidth / _statuses.length - 16;

    return Scaffold(
      appBar: AppBar(title: const Text('Канбан')),
      body: Row(
        children: _statuses.map((status) {
          final columnTasks = prov.byStatus(status)
            ..sort((a, b) => a.weight.compareTo(b.weight));
          return Expanded(
            child: DragTarget<Task>(
              onWillAccept: (task) => task != null && task.status != status,
              onAccept: (task) {
                task.status = status;
                prov.updateTask(task);
              },
              builder: (context, candidateData, rejectedData) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      status,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: columnTasks.map((t) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: LongPressDraggable<Task>(
                            data: t,
                            feedback: SizedBox(
                              width: columnWidth,
                              child: Material(
                                elevation: 4,
                                child: _TaskKanbanCard(task: t),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: _TaskKanbanCard(task: t),
                            ),
                            child: _TaskKanbanCard(task: t),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TaskKanbanCard extends StatelessWidget {
  final Task task;
  const _TaskKanbanCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.subtasks.isNotEmpty)
              Text('Прогресс: ${(task.progress * 100).round()}%'),
            Text('Вес: ${task.weight}'),
          ],
        ),
      ),
    );
  }
}
