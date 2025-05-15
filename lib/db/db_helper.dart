//importación de los paquetes necesarios
import 'package:control_de_gastos/models/gastos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//gestión de la base de datos
//Esta clase es responsable de manejar la base de datos SQLite
class DBHelper {
  static Database? _database;
  static const String dbName = 'gastos.db';
  static const String _tableName = 'gastos';

  //Inicializa la base de datos
  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'gastos.db');

    return _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Crear la tabla de gastos
        // Esta tabla se utiliza para almacenar los gastos del usuario
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descripcion TEXT,
            monto REAL,
            categoria TEXT,
            fecha TEXT
          )
        ''');
        // Crear la tabla de configuración
        // Esta tabla se utiliza para almacenar la configuración de ingresos y gastos fijos
        await db.execute('''
          CREATE TABLE configuracion(
            id INTEGER PRIMARY KEY,
            ingresos REAL,
            gastosFijos REAL
        )
    ''');
      },
    );
  }

  //Método para insertar un gasto
  static Future<int> insertGasto(Gasto gasto) async {
    final db =
        _database ?? await initDB(); // Usamos _database que ya está abierto
    return db.insert(_tableName, gasto.toMap());
  }

  //Método para obtener todos los gastos
  static Future<List<Gasto>> getGastos() async {
    final db = _database ?? await initDB();
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Gasto.fromMap(maps[i]);
    });
  }

  // Método para eliminar un gasto por ID
  static Future<void> deleteGasto(int id) async {
    final db = _database ?? await initDB();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Método para eliminar todos los gastos
  static Future<void> deleteAllGastos() async {
    final db = _database ?? await initDB();
    await db.delete(_tableName);
  }

  // Metodo para actualiza gasto por ID
  static Future<int> updateGasto(Gasto gasto) async {
    final db = _database ?? await initDB();
    return await db.update(
      _tableName,
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  // Guardar configuración financiera
  // Este método se utiliza para guardar la configuración de ingresos y gastos fijos
  static Future<void> guardarConfiguracion(
    double ingresos,
    double gastosFijos,
  ) async {
    final db = _database ?? await initDB();
    // Actualizar la configuración financiera en la base de datos
    await db.insert('configuracion', {
      'id': 1, // ID fijo para la configuración
      'ingresos': ingresos,
      'gastosFijos': gastosFijos,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Leer configuración financiera
  // Este método se utiliza para leer la configuración de ingresos y gastos fijos
  static Future<Map<String, double>> obtenerConfiguracion() async {
    final db = _database ?? await initDB();

    final result = await db.query(
      'configuracion',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      final fila = result.first;
      return {
        'ingresos': fila['ingresos'] as double,
        'gastosFijos': fila['gastosFijos'] as double,
      };
    } else {
      return {'ingresos': 0.0, 'gastosFijos':0.0};
    }
    
  }
}

