import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'task.dart';
import 'task_log.dart';
import 'bottomsheet.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> _tasks = [];
  Map<int, TaskLog?> _todayLogs = {};

  int get _completedTasksCount {
    return _tasks.where(_isTaskDone).length;
  }

  double get _progressValue {
    if (_tasks.isEmpty) {
      return 0;
    }

    return _completedTasksCount / _tasks.length;
  }

  bool _isTaskDone(Task task) {
    return _todayLogs[task.id]?.status == 'done';
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DbHelper.getTasksForDate(DateTime.now());
    final Map<int, TaskLog?> logs = {};
    final today = DateTime.now();

    for (final task in tasks) {
      final taskId = task.id!;
      final existingLog = await DbHelper.getTaskLogForDate(taskId, today);

      if (existingLog == null) {
        final skippedLog = TaskLog(
          taskId: taskId,
          date: today,
          status: 'skipped',
        );
        await DbHelper.insertOrUpdateTaskLog(skippedLog);
        logs[taskId] = skippedLog;
      } else {
        logs[taskId] = existingLog;
      }
    }

    final List<Task> pendingTasks = [];
    final List<Task> completedTasks = [];
    for (final task in tasks) {
      if (logs[task.id]?.status == 'done') {
        completedTasks.add(task);
      } else {
        pendingTasks.add(task);
      }
    }

    setState(() {
      _tasks = [...pendingTasks, ...completedTasks];
      _todayLogs = logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = _completedTasksCount;
    final totalToday = _tasks.length;
    final progress = _progressValue;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedToday/$totalToday tasks completed',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${(progress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks for today'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      final isDone = _isTaskDone(task);
                      final firstDoneIndex = _tasks.indexWhere(_isTaskDone);
                      final shouldShowSeparator =
                          firstDoneIndex > 0 && index == firstDoneIndex;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (shouldShowSeparator)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDone ? Colors.black54 : null,
                              ),
                            ),
                            leading: Checkbox(
                              value: isDone,
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
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
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
