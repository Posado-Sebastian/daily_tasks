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
  int _selectedIndex = 0;
  final DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90, 
          title: Text('${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Hello World!')),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Agregar'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendario'),
          ],
        ),
      ),
    );
  }
}
