import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbAsistente {
  
  static Future<Database> abrirBaseDatos() async {
    final rutaDireccion = await getDatabasesPath();
    final rutaCompleta = join(rutaDireccion, 'mis_tareas.db');

    return openDatabase(
      rutaCompleta,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tareas(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, completada INTEGER, fecha TEXT)',
        );
      },
    );
  }

  static Future<void> insertarTarea(String textoTarea, DateTime fechaTarea) async {
    final db = await abrirBaseDatos();
    
    await db.insert(
      'tareas',
      {
        'titulo': textoTarea,
        'completada': 0, 
        'fecha': fechaTarea.toIso8601String(), 
      },
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerTareas() async {
    final db = await abrirBaseDatos();
    return await db.query('tareas');
  }
}