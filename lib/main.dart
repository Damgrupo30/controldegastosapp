//importación de paquetes necesarios
import 'package:flutter/material.dart';
import 'package:control_de_gastos/db/db_helper.dart';
import 'package:control_de_gastos/screens/home_screen.dart';

void main() async {
  // Inicializamos la base de datos antes de arrancar la app
  WidgetsFlutterBinding.ensureInitialized();
  // Aseguramos que la base de datos esté inicializada antes de usarla
  await DBHelper.initDB();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuramos el tema de la aplicación
    return MaterialApp(
      title: 'Gestión de Gastos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green[600],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[300],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),

      // Pantalla inicial de la aplicación
      home: const HomeScreen(),
    );
  }
}
