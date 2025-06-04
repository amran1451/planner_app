// lib/screens/task_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../providers/task_provider.dart';

class TaskEditScreen extends StatefulWidget {
  const TaskEditScreen({Key? key}) : super(key: key);

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _form = GlobalKey<FormState>();
  late Task _edited;
  late DateTime _selectedDate;
  bool _isNew = true;
  final _subtaskCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _selectedDate = args['date'] as DateTime;
    if (args.containsKey('task')) {
      _isNew = false;
      _edited = args['task'] as Task;
    } else {
      _edited = Task(title: '', date: _selectedDate, subtasks: []);
    }
  }

  void _addSubtask() {
    final text = _subtaskCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _edited.subtasks =
            List.from(_edited.subtasks)..add(Subtask(taskId: _edited.id ?? 0, title: text));
      });
      _subtaskCtrl.clear();
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    final prov = Provider.of<TaskProvider>(context, listen: false);
    if (_isNew) {
      await prov.addTask(_edited);
    } else {
      await prov.updateTask(_edited);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Новая задача' : 'Редактировать задачу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _edited.title,
                decoration: const InputDecoration(labelText: 'Заголовок'),
                validator: (v) => v!.isEmpty ? 'Введите заголовок' : null,
                onSaved: (v) => _edited.title = v!,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Дата'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) {
                    setState(() {
                      _selectedDate = d;
                      _edited.date = d;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _edited.status,
                decoration: const InputDecoration(labelText: 'Статус'),
                items: const [
                  'Запланировано',
                  'В работе',
                  'На проверке',
                  'Готово',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _edited.status = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _edited.weight,
                decoration: const InputDecoration(labelText: 'Вес (1–5)'),
                items: [1, 2, 3, 4, 5]
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.toString())))
                    .toList(),
                onChanged: (v) => setState(() => _edited.weight = v!),
              ),
              const SizedBox(height: 16),
              const Text('Подзадачи', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskCtrl,
                      decoration: const InputDecoration(hintText: 'Название подзадачи'),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addSubtask),
                ],
              ),
              ..._edited.subtasks.map((s) {
                return ListTile(
                  title: Text(s.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _edited.subtasks = List.from(_edited.subtasks)..remove(s);
                      });
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
            ],
          ),
        ),
      ),
    );
  }
}
