import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task.dart'; 

class DbHelper {
  
  static Future<Database> openOurDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'todo_list.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isCompleted INTEGER, date TEXT)',
        );
      },
    );
  }

  static Future<void> insertTask(Task task) async {
    final db = await openOurDatabase();
    
    await db.insert(
      'tasks',
      task.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Task>> getTasks() async {
    final db = await openOurDatabase();
    
    final List<Map<String, Object?>> taskMaps = await db.query('tasks');

    return [
      for (final map in taskMaps) Task.fromMap(map)
    ];
  }
}