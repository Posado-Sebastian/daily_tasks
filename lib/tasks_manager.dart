import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'task.dart';

class TasksManager extends StatefulWidget {
  const TasksManager({super.key});

  @override
  State<TasksManager> createState() => _TasksManagerState();
}

class _TasksManagerState extends State<TasksManager> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DbHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text('Tasks'),
        centerTitle: true,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks yet'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.days.join(', ')),
                  trailing: Switch(
                    value: task.isActive,
                    onChanged: (value) async {
                      final updated = Task(
                        id: task.id,
                        title: task.title,
                        days: task.days,
                        isActive: value,
                      );
                      await DbHelper.updateTask(updated);
                      _loadTasks();
                    },
                  ),
                );
              },
            ),
    );
  }
}
