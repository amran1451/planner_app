// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/task_edit_screen.dart';
import 'screens/kanban_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  return MultiProvider(
  providers: [
  ChangeNotifierProvider(create: (_) => TaskProvider()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: Consumer<ThemeProvider>(
  builder: (context, themeProv, _) => MaterialApp(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Planner',
        theme: ThemeData(primarySwatch: Colors.blue),
  darkTheme: ThemeData.dark(),
  themeMode: themeProv.themeMode,
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/edit': (_) => const TaskEditScreen(),
          '/kanban': (_) => const KanbanScreen(),
          '/dashboard': (_) => const DashboardScreen(),
        },
  ),
      ),
    );
  }
}
