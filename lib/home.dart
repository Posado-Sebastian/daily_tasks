import 'package:flutter/material.dart';
import 'bottomsheet.dart';
import 'db_helper.dart';
import 'task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> _tasks = [];

  static const _dayNames = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  String get _today => _dayNames[DateTime.now().weekday % 7];

  Future<void> _loadTasks() async {
    final all = await DbHelper.getTasks();
    setState(() {
      _tasks = all.where((task) => task.days.contains(_today)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks for today'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.title),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) async {
                      // Actualizar la task: cambiar isCompleted
                      final updated = Task(
                        id: task.id,
                        title: task.title,
                        isCompleted: value ?? false,
                        days: task.days,
                      );
                      await DbHelper.updateTask(updated);  
                      _loadTasks();  // recargar lista
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await DbHelper.deleteTask(task.id!);
                      _loadTasks();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return const BottomSheetWidget();
            },
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}