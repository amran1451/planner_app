// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TaskProvider>(context);
    final total = prov.tasks.length;
    final done = prov.tasks.where((t) => t.status == 'Готово').length;
    final pending = total - done;

    return Scaffold(
      appBar: AppBar(title: const Text('Дашборд')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Всего задач: $total'),
            Text('Завершено: $done'),
            Text('В работе/Запланировано: $pending'),
          ],
        ),
      ),
    );
  }
}
