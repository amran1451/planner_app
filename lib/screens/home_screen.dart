// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

const List<String> _statuses = [
  'Запланировано',
  'В работе',
  'На проверке',
  'Готово',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false)
        .loadByDate(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TaskProvider>(context);
    // сортируем: сначала незавершённые по весу, потом готовые по весу
    final all = prov.tasks;
    final notDone = all.where((t) => t.status != 'Готово').toList()
      ..sort((a, b) => a.weight.compareTo(b.weight));
    final done = all.where((t) => t.status == 'Готово').toList()
      ..sort((a, b) => a.weight.compareTo(b.weight));
    final tasks = [...notDone, ...done];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой Планер'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.view_kanban),
            onPressed: () => Navigator.pushNamed(context, '/kanban'),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(DateTime.now().year - 1),
            lastDate: DateTime(DateTime.now().year + 2),
            onDateChanged: (date) {
              setState(() => _selectedDate = date);
              prov.loadByDate(date);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('Нет задач на этот день'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final t = tasks[i];
                      return Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child:
                              const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          prov.deleteTask(t.id!, _selectedDate);
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/edit',
                              arguments: {'task': t, 'date': _selectedDate},
                            ).then((_) {
                              prov.loadByDate(_selectedDate);
                            });
                          },
                          child: TaskCard(
                            task: t,
                            onSubtaskToggle: (idx, val) {
                              prov.toggleSubtask(
                                  t.subtasks[idx], _selectedDate);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/edit',
            arguments: {'date': _selectedDate},
          ).then((_) {
            prov.loadByDate(_selectedDate);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Карточка задачи с возможностью менять статус и подзадачами
class TaskCard extends StatelessWidget {
  final Task task;
  final void Function(int subtaskIndex, bool isDone) onSubtaskToggle;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onSubtaskToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и меню смены статуса
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: task.status,
                  onSelected: (newStatus) {
                    task.status = newStatus;
                    Provider.of<TaskProvider>(context, listen: false)
                        .updateTask(task);
                  },
                  itemBuilder: (_) => _statuses
                      .map((s) => PopupMenuItem(value: s, child: Text(s)))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.status == 'Готово'
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(task.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (task.subtasks.isNotEmpty) ...[
              LinearProgressIndicator(value: task.progress, minHeight: 6),
              const SizedBox(height: 4),
              Text('${(task.progress * 100).round()}%'),
              const SizedBox(height: 8),
            ],
            ...List.generate(
              task.subtasks.length,
              (idx) {
                final sub = task.subtasks[idx];
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(sub.title),
                  value: sub.isDone,
                  onChanged: (val) {
                    if (val != null) onSubtaskToggle(idx, val);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
