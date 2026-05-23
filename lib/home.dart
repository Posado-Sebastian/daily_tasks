import 'package:flutter/material.dart';
import 'bottomsheet.dart';
import 'db_helper.dart';
import 'task.dart';
import 'task_log.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> _tasks = [];
  Map<int, TaskLog?> _todayLogs = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DbHelper.getTasksForDate(DateTime.now());
    final Map<int, TaskLog?> logs = {};
    for (final task in tasks) {
      logs[task.id!] = await DbHelper.getTaskLogForDate(task.id!, DateTime.now());
    }
    setState(() {
      _tasks = tasks;
      _todayLogs = logs;
    });
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
                    value: _todayLogs[task.id]?.status == 'done',
                    onChanged: (value) async {
                      final log = TaskLog(
                        taskId: task.id!,
                        date: DateTime.now(),
                        status: (value ?? false) ? 'done' : 'skipped',
                      );
                      await DbHelper.insertOrUpdateTaskLog(log);
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
            isScrollControlled: true,
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