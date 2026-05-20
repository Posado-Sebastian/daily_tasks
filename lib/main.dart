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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}'),
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
