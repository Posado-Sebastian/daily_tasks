import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final DateTime _selectedDate = DateTime.now();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          title: Text(
            '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('Hello World!')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigatorKey.currentState?.push(
              MaterialPageRoute<void>(
                builder: (context) => const AddTask(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
class AddTask extends StatelessWidget {
  const AddTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('add task')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}