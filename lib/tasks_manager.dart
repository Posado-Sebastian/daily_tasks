import 'package:flutter/material.dart';
import 'bottomsheet.dart';
import 'db_helper.dart';
import 'models/task.dart';

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

  Future<void> _openEditBottomSheet(Task task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetWidget(task: task);
      },
    );
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
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
                onTap: () => _openEditBottomSheet(task),
                title: Text(task.title),
                subtitle: Text(task.scheduleLabel),
                trailing: Switch(
                  value: task.isActive,
                  onChanged: (value) async {
                    final updated = Task(
                      id: task.id,
                      title: task.title,
                      days: task.days,
                      specificDate: task.specificDate,
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
