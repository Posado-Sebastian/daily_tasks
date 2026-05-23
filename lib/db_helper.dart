import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task.dart'; 
import 'task_log.dart';  

class DbHelper {
	static const _databaseName = 'todo_list.db';
	static const _databaseVersion = 2;
	static const _tasksTable = 'tasks';
	static const _taskLogsTable = 'task_logs';

	static Future<Database> openOurDatabase() async {
		final databasePath = await getDatabasesPath();
		final path = join(databasePath, _databaseName);

		return openDatabase(
			path,
			version: _databaseVersion,
			onConfigure: (db) async {
				await db.execute('PRAGMA foreign_keys = ON');
			},
			onCreate: (db, version) async {
				await _createSchema(db);
			},
		);
	}

	static Future<void> _createSchema(Database db) async {
		await db.execute('''
			CREATE TABLE $_tasksTable(
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				title TEXT NOT NULL,
				days TEXT NOT NULL,
				startDate TEXT,
				endDate TEXT
			)
		''');

		await db.execute('''
			CREATE TABLE $_taskLogsTable(
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				taskId INTEGER NOT NULL,
				date TEXT NOT NULL,
				status TEXT NOT NULL,
				UNIQUE(taskId, date),
				FOREIGN KEY(taskId) REFERENCES $_tasksTable(id) ON DELETE CASCADE
			)
		''');
	}

	static Future<int> insertTask(Task task) async {
		final db = await openOurDatabase();

		return db.insert(
			_tasksTable,
			task.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace,
		);
	}

	static Future<List<Task>> getTasks() async {
		final db = await openOurDatabase();
		final taskMaps = await db.query(_tasksTable, orderBy: 'id DESC');

		return [for (final map in taskMaps) Task.fromMap(map)];
	}

	static Future<int> updateTask(Task task) async {
		final db = await openOurDatabase();

		return db.update(
			_tasksTable,
			task.toMap(),
			where: 'id = ?',
			whereArgs: [task.id],
		);
	}

	static Future<int> deleteTask(int id) async {
		final db = await openOurDatabase();

		return db.delete(
			_tasksTable,
			where: 'id = ?',
			whereArgs: [id],
		);
	}

	static Future<List<Task>> getTasksForDate(DateTime date) async {
		final allTasks = await getTasks();
		final dayNames = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
		final dayCode = dayNames[date.weekday % 7];
		final normalizedDate = DateTime(date.year, date.month, date.day);

		return allTasks.where((task) {
			final startsBeforeOrToday = task.startDate == null ||
					!DateTime(
						task.startDate!.year,
						task.startDate!.month,
						task.startDate!.day,
					).isAfter(normalizedDate);
			final endsAfterOrToday = task.endDate == null ||
					!DateTime(
						task.endDate!.year,
						task.endDate!.month,
						task.endDate!.day,
					).isBefore(normalizedDate);

			return startsBeforeOrToday &&
					endsAfterOrToday &&
					task.days.contains(dayCode);
		}).toList();
	}

	static Future<void> insertOrUpdateTaskLog(TaskLog taskLog) async {
		final db = await openOurDatabase();

		await db.insert(
			_taskLogsTable,
			taskLog.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace,
		);
	}

	static Future<TaskLog?> getTaskLogForDate(int taskId, DateTime date) async {
		final db = await openOurDatabase();
		final normalizedDate = DateTime(date.year, date.month, date.day)
				.toIso8601String();

		final logMaps = await db.query(
			_taskLogsTable,
			where: 'taskId = ? AND date = ?',
			whereArgs: [taskId, normalizedDate],
			limit: 1,
		);

		if (logMaps.isEmpty) {
			return null;
		}

		return TaskLog.fromMap(logMaps.first);
	}

	static Future<List<TaskLog>> getLogsForTask(int taskId) async {
		final db = await openOurDatabase();
		final logMaps = await db.query(
			_taskLogsTable,
			where: 'taskId = ?',
			whereArgs: [taskId],
			orderBy: 'date DESC',
		);

		return [for (final map in logMaps) TaskLog.fromMap(map)];
	}

	static Future<List<TaskLog>> getLogsBetweenDates(
		DateTime start,
		DateTime end,
	) async {
		final db = await openOurDatabase();
		final startDate = DateTime(start.year, start.month, start.day)
				.toIso8601String();
		final endDate = DateTime(end.year, end.month, end.day).toIso8601String();

		final logMaps = await db.query(
			_taskLogsTable,
			where: 'date >= ? AND date <= ?',
			whereArgs: [startDate, endDate],
			orderBy: 'date DESC',
		);

		return [for (final map in logMaps) TaskLog.fromMap(map)];
	}
}